"""Print a procedure of a program as readable disassembly.

Usage:
  python -I disasm.py UNPACKED.EXE RUNTIME.tsv MODULES LABEL... [--lift] [--bi FILE.BI]

MODULES names the program's modules, separated by commas (WON,WON2,WONMENU).
LABEL is a procedure label from procsplit.py (WONMENU.02), or MODULE(module)
for the module-level code.

Each instruction is printed with its offset in the module. Calls are named:
runtime routines by the runtime map, game procedures by their labels. A
number that is the place of a constant in one of the modules' BC_CN
segments is followed by the constant: a string literal in quotes, or a
SINGLE or DOUBLE value. A number inside COMMON is followed by COMMON+offset.

--lift folds the arguments pushed before each call into the call's line,
such as B$DRAW("C10R2F1") or B$N1I2(500, 185): most statements then read
off directly. Locals show as localN (bp-N) and parameters as argN (bp+N).

--bi FILE.BI names each COMMON place with its variable, from the layout of
the include file's COMMON SHARED statements (commonmap.py).
"""
import re
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from codecmp import HEADER, instructions  # noqa: E402
from compare import dgroup_of, module_level  # noqa: E402
from procsplit import load_runtime_map, split_all, views_from_exe  # noqa: E402

NUM = re.compile(r"0x[0-9a-f]+|\b\d+\b")


class Data:
    """DGROUP with the places of each module's constants and of COMMON."""

    def __init__(self, image, dgroup, views, bi=None):
        self.image, self.dgroup = image, dgroup
        self.names = {}  # COMMON offset -> (name, size), from --bi
        if bi:
            from commonmap import layout

            for off, name, size in layout(bi)[0]:
                self.names[off] = (name, size)
        hdr = [(v.module, struct.unpack_from("<H", v.data, 0x20)[0]) for v in views]
        starts = sorted(s for _, s in hdr)
        # A module's BC_CN runs to the next one, or for the last, 8 KB at most.
        self.cn = [(s, starts[i + 1] if i + 1 < len(starts) else s + 0x2000) for i, s in enumerate(starts)]
        self.common = struct.unpack_from("<H", views[0].data, 0x18)[0]
        self.common_end = min(struct.unpack_from("<H", v.data, 0x0E)[0] for v in views)

    def word(self, off):
        return struct.unpack_from("<H", self.image, self.dgroup + off)[0]

    def string_at(self, x):
        """BC 7.1 far-string literal: far pointer, then (pointer, length), then the text."""
        for desc in (x, x - 4):
            try:
                if self.word(desc) != desc + 4:
                    continue
                n = self.word(desc + 6)
                text = self.image[self.dgroup + desc + 8 : self.dgroup + desc + 8 + n]
            except struct.error:
                continue
            if len(text) == n and all(32 <= c < 127 for c in text):
                return text.decode("ascii")
        return None

    def explain(self, x):
        for s, e in self.cn:
            if s <= x < e:
                text = self.string_at(x)
                if text is not None:
                    return '"' + text + '"'
                single = struct.unpack_from("<f", self.image, self.dgroup + x)[0]
                double = struct.unpack_from("<d", self.image, self.dgroup + x)[0]
                if abs(single) > 1e-6 and abs(single) < 1e9:
                    return f"{single:g}!"
                if abs(double) > 1e-9 and abs(double) < 1e12:
                    return f"{double:g}#"
                return None
        if self.common <= x < self.common_end:
            off = x - self.common
            for start, (name, size) in self.names.items():
                if start <= off < start + size:
                    return name if off == start else f"{name}+{off - start}"
            return f"COMMON+{off:04x}"
        return None


def operand(text, data):
    """A readable name for the value an instruction loads or pushes."""
    m = re.fullmatch(r"(?:word ptr )?\[bp ([-+]) (0x[0-9a-f]+|\d+)\]", text)
    if m:
        n = int(m.group(2), 0)
        return f"local{n:x}" if m.group(1) == "-" else f"arg{n:x}"
    m = re.fullmatch(r"(?:word ptr )?\[(0x[0-9a-f]+|\d+)\]", text)
    if m:
        x = int(m.group(1), 0)
        note = data.explain(x)
        return note if note else f"[{x:04x}]"
    m = re.fullmatch(r"0x[0-9a-f]+|\d+", text)
    if m:
        x = int(text, 0)
        note = data.explain(x) if x >= 0x40 else None
        # Only a constant (a string, or a number ending in ! or #) names an
        # immediate; a place in COMMON is just as likely a plain number.
        if note and (note.startswith('"') or note.endswith(("!", "#"))):
            return note
        return str(x - 0x10000 if x >= 0x8000 else x)
    return text


def lift(insns, data):
    """Fold the pushes before each call into one line: CALL(args). Other
    instructions are printed as they are. ax, bx, cx, dx and si are tracked
    through simple loads, so that "mov ax, 5 / push ax" shows as 5."""
    regs = {}
    args = []
    out = []
    for i in insns:
        mnem, _, ops = i.text.partition(" ")
        parts = [p.strip() for p in ops.split(",")] if ops else []
        if i.text.startswith("call far"):
            out.append(f"{i.addr:04x}  {i.text[9:]}({', '.join(args)})")
            args, regs = [], {}
            continue
        if mnem == "mov" and len(parts) == 2 and parts[0] in ("ax", "bx", "cx", "dx", "si", "di"):
            regs[parts[0]] = operand(parts[1], data)
            continue
        if mnem == "xor" and len(parts) == 2 and parts[0] == parts[1]:
            regs[parts[0]] = "0"
            continue
        if mnem == "push" and parts:
            args.append(regs.get(parts[0], operand(parts[0], data)))
            continue
        for p in list(regs):
            if parts and parts[0] == p:
                del regs[p]
        if args:
            out.append(f"      ; pushed so far: {', '.join(args)}")
        out.append(f"{i.addr:04x}  {i.text}")
    return out


def main():
    args = sys.argv[1:]
    lifted = "--lift" in args
    if lifted:
        args.remove("--lift")
    bi = None
    if "--bi" in args:
        k = args.index("--bi")
        bi = args[k + 1]
        del args[k : k + 2]
    if len(args) < 4:
        raise SystemExit(__doc__)
    exe, rt_tsv, modules, labels = args[0], args[1], args[2].split(","), args[3:]
    views, image, _ = views_from_exe(exe, rt_tsv, modules)
    procs = split_all(views)
    data = Data(image, dgroup_of(image, load_runtime_map(rt_tsv)), views, bi)
    for want in labels:
        for v in views:
            if want == f"{v.module}(module)":
                pieces = module_level(v, procs[v.module])
                ranges = pieces
            else:
                pr = next((p for p in procs[v.module] if p.label == want), None)
                if pr is None:
                    continue
                ranges = [(pr.start, pr.end)]
                print(f"; {pr.label}: {pr.size} bytes, frame {pr.frame}, temps {pr.temps}, {pr.params} parameters")
            for s, e in ranges:
                print(f"; --- {s:04x}-{e:04x}")
                if lifted:
                    print("\n".join(lift(instructions(v, max(s, HEADER), e), data)))
                    continue
                for i in instructions(v, max(s, HEADER), e):
                    notes = []
                    if not i.text.startswith(("call", "j", "loop")):
                        for m in NUM.finditer(i.text):
                            x = int(m.group(0), 0)
                            # An immediate may be a constant's place or just a number:
                            # only constants are named. A COMMON place is named only
                            # for a memory operand, [x].
                            in_brackets = f"[{m.group(0)}]" in i.text
                            note = data.explain(x) if x >= 0x40 else None
                            is_common = note and (note.startswith("COMMON") or note[0].isalpha())
                            # An array is addressed through its descriptor: mov si, place.
                            if note and (in_brackets or not is_common or i.text.startswith("mov si,")):
                                notes.append(note)
                    tail = ("    ; " + ", ".join(notes)) if notes else ""
                    print(f"{i.addr:04x}  {i.text}{tail}")


if __name__ == "__main__":
    main()
