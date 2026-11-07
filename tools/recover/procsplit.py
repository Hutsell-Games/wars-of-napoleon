"""Split BASIC PDS 7.1 module code into its SUBs and FUNCTIONs.

Usage:
  python -I procsplit.py UNPACKED.EXE RUNTIME.tsv MODULE... [--tsv OUT.tsv]
  python -I procsplit.py FILE.OBJ... [--tsv OUT.tsv]

BC compiles each SUB and FUNCTION to the same entry and exit:

  mov cx, FRAME        B9 lo hi    bytes of local frame
  mov bx, TEMPS        BB lo hi
  call far B$ENRA      9A ...      enter the procedure
  ...
  call far B$EXSA      9A ...      leave the procedure
  retf ARGS            CA lo hi    two bytes per parameter

A procedure runs from its entry to the RETF after its last B$EXSA. The
module-level code lies between procedures, in source order: where a SUB
starts, the module-level code jumps over it.

With an unpacked program, MODULE names the modules to split (WON, WON2,
WONMENU); each one's code starts with BC's marker "bl" + the name padded
to 8 characters, and runs to the next marker or to the runtime. The far
calls are named with the runtime map of runtimemap.py. A procedure has no
name in a program, so it is labeled MODULE.NN in order; procedures that
other modules call are marked.

With object files, each procedure gets the name of its public symbol.

Prints one row per procedure: label, start, size, FRAME, TEMPS, the number
of parameters, the number of runtime calls and calls to game procedures,
and who calls it. --tsv writes the same rows to a file.
"""
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from omflib import read_library  # noqa: E402
from unlzexe91 import read_mz  # noqa: E402


@dataclass
class CodeView:
    """One module's code, from a linked program or an object file.

    data:   the code bytes, offset 0 = start of the module's code segment
    fixed:  1 for each byte that LINK fills in
    calls:  offset of a CALL FAR (the 9A byte) -> the callee's name, for
            runtime routines ("B$PESD") and game procedures ("proc:NAME")
    refs:   offset of a fixed word -> (segment name, displacement), for words
            that point into a data segment (object files only)
    """
    module: str
    data: bytes
    fixed: bytearray
    calls: dict = field(default_factory=dict)
    refs: dict = field(default_factory=dict)
    base: int = 0  # linear address in the program (0 for an object file)
    publics: dict = field(default_factory=dict)  # offset -> name (object files)


@dataclass
class Proc:
    module: str
    label: str
    start: int  # offset in the module's code
    end: int  # offset after the RETF
    frame: int
    temps: int
    params: int
    callers: set = field(default_factory=set)

    @property
    def size(self):
        return self.end - self.start


def load_runtime_map(path):
    names = {}
    for line in Path(path).read_text(encoding="ascii").splitlines()[1:]:
        addr, name = line.split("\t")[:2]
        names.setdefault(int(addr, 16), name)
    return names


def runtime_aliases(path):
    """Map each runtime name to the name the runtime map gives its address
    first: two public names at one address (B$SASS and B$SAS1) are one routine."""
    first = {}
    alias = {}
    for line in Path(path).read_text(encoding="ascii").splitlines()[1:]:
        addr, name = line.split("\t")[:2]
        alias[name.upper()] = first.setdefault(int(addr, 16), name)
    return alias


def canonicalize(views, alias):
    """Rename the runtime calls of object-file views to the runtime map's names."""
    for v in views:
        for p, name in v.calls.items():
            if not name.startswith("proc:"):
                v.calls[p] = alias.get(name.upper(), name)


def views_from_exe(exe_path, runtime_tsv, modules):
    """Return (views, image, mz) for the named modules of an unpacked program."""
    mz = read_mz(Path(exe_path).read_bytes())
    image = bytes(mz.data)
    runtime = load_runtime_map(runtime_tsv)
    rt_start = min(runtime)
    starts = []
    for name in modules:
        marker = b"bl" + name.upper().encode().ljust(8)[:8]
        p = image.find(marker)
        if p < 0 or p >= rt_start:
            raise SystemExit(f"module {name}: marker not found")
        starts.append((p, name.upper()))
    starts.sort()
    # Every module's code starts on a paragraph with its marker, so a module
    # ends where the next marker is, named or not.
    marks = [
        p for p in range(0, rt_start, 16)
        if image[p : p + 2] == b"bl" and all(c == 0x20 or 0x30 <= c <= 0x5A or c == 0x5F for c in image[p + 2 : p + 10])
    ]
    relocs = {seg * 16 + off for off, seg in mz.relocs}
    views = []
    for s, name in starts:
        e = min([m for m in marks if m > s] + [rt_start])
        data = image[s:e]
        fixed = bytearray(len(data))
        calls = {}
        for p in range(len(data) - 4):
            if data[p] == 0x9A and s + p + 3 in relocs:
                off, seg = struct.unpack_from("<HH", data, p + 1)
                target = seg * 16 + off
                fixed[p + 1 : p + 5] = b"\1\1\1\1"
                if target in runtime:
                    calls[p] = runtime[target]
                elif target < rt_start:
                    calls[p] = f"addr:{target:05x}"
                else:
                    calls[p] = f"rt:{target:05x}"
        for r in relocs:
            if s <= r < e:
                fixed[r - s : r - s + 2] = b"\1\1"
        views.append(CodeView(name, data, fixed, calls, {}, s))
    return views, image, mz


def views_from_obj(path):
    """Return the code view of each module in an object file."""
    out = []
    for m in read_library(path):
        for si, seg in enumerate(m.segments):
            if seg is None or not seg.is_code() or not seg.size:
                continue
            data = bytes(seg.data)
            calls, refs = {}, {}
            for off, t in seg.targets.items():
                loc, kind, idx, disp, self_rel = t
                name = m.target_name(t)
                if loc == 3 and off >= 1 and data[off - 1] == 0x9A:
                    calls[off - 1] = name if name.upper().startswith("B$") else f"proc:{name}"
                elif kind == "seg":
                    d = disp if disp is not None else struct.unpack_from("<H", data, off)[0]
                    refs[off] = (name, d)
            publics = {o: n for n, psi, o in m.publics if psi == si}
            modname = seg.name[:-5] if seg.name.upper().endswith("_CODE") else m.name
            out.append(CodeView(modname, data, seg.fixed, calls, refs, 0, publics))
    return out


def find_procs(view):
    """Split a module's code into procedures."""
    d = view.data
    entries = [
        p for p in range(len(d) - 9)
        if d[p] == 0xB9 and d[p + 3] == 0xBB and view.calls.get(p + 6) == "B$ENRA"
    ]
    exits = sorted(p for p, n in view.calls.items() if n == "B$EXSA")
    procs = []
    for i, p in enumerate(entries):
        nxt = entries[i + 1] if i + 1 < len(entries) else len(d)
        ends = [x for x in exits if p < x < nxt and d[x + 5] == 0xCA]
        if not ends:
            raise SystemExit(f"{view.module}: procedure at {p:04x} has no exit")
        end = ends[-1] + 8
        frame, temps = struct.unpack_from("<H", d, p + 1)[0], struct.unpack_from("<H", d, p + 4)[0]
        args = struct.unpack_from("<H", d, end - 2)[0]
        label = view.publics.get(p) or f"{view.module}.{i + 1:02d}"
        procs.append(Proc(view.module, label, p, end, frame, temps, args // 2))
    return procs


def name_game_calls(views, procs_by_module):
    """In a linked program, turn calls to game code addresses into proc:LABEL,
    and record who calls each procedure."""
    by_addr = {}
    for v in views:
        for pr in procs_by_module[v.module]:
            by_addr[v.base + pr.start] = pr
    for v in views:
        for p, name in list(v.calls.items()):
            if name.startswith("addr:"):
                pr = by_addr.get(int(name[5:], 16))
                if pr is not None:
                    v.calls[p] = f"proc:{pr.label}"


def mark_callers(views, procs_by_module):
    by_label = {pr.label: pr for prs in procs_by_module.values() for pr in prs}
    for v in views:
        prs = procs_by_module[v.module]
        for p, name in v.calls.items():
            if not name.startswith("proc:"):
                continue
            callee = by_label.get(name[5:])
            if callee is None:
                continue
            here = next((pr.label for pr in prs if pr.start <= p < pr.end), f"{v.module}(module)")
            callee.callers.add((v.module, here))


def split_all(views):
    procs = {v.module: find_procs(v) for v in views}
    if any(v.base for v in views):
        name_game_calls(views, procs)
    mark_callers(views, procs)
    return procs


def summary_rows(views, procs):
    rows = []
    for v in views:
        for pr in procs[v.module]:
            rt = sum(1 for p, n in v.calls.items() if pr.start <= p < pr.end and not n.startswith(("proc:", "addr:")))
            gp = sum(1 for p, n in v.calls.items() if pr.start <= p < pr.end and n.startswith("proc:"))
            outside = sorted(label for mod, label in pr.callers if mod != v.module)
            rows.append((
                pr.label, f"{v.base + pr.start:05x}", pr.size, pr.frame, pr.temps, pr.params, rt, gp,
                ",".join(outside) if outside else "-",
            ))
    return rows


def main():
    args = sys.argv[1:]
    tsv = None
    if "--tsv" in args:
        i = args.index("--tsv")
        tsv = Path(args[i + 1])
        del args[i : i + 2]
    if not args:
        raise SystemExit(__doc__)
    if args[0].upper().endswith(".EXE"):
        if len(args) < 3:
            raise SystemExit(__doc__)
        views, _, _ = views_from_exe(args[0], args[1], args[2:])
    else:
        views = [v for a in args for v in views_from_obj(a)]
    procs = split_all(views)
    head = ("label", "start", "size", "frame", "temps", "params", "rt_calls", "proc_calls", "called_from_other_modules")
    rows = summary_rows(views, procs)
    for v in views:
        n = len(procs[v.module])
        in_procs = sum(pr.size for pr in procs[v.module])
        print(f"{v.module}: {len(v.data)} bytes, {n} procedures with {in_procs} bytes, module-level code and padding {len(v.data) - in_procs}")
    print("\t".join(head))
    for r in rows:
        print("\t".join(str(x) for x in r))
    if tsv:
        with tsv.open("w", encoding="ascii", newline="\n") as f:
            f.write("\t".join(head) + "\n")
            for r in rows:
                f.write("\t".join(str(x) for x in r) + "\n")


if __name__ == "__main__":
    main()
