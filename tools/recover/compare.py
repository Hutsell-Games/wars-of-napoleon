"""Compare compiled modules with the same modules in a shipped program.

Usage:
  python -I compare.py UNPACKED.EXE RUNTIME.tsv OBJ... [--show LABEL]

UNPACKED.EXE is the shipped program after unlzexe91.py, and RUNTIME.tsv its
runtime map from runtimemap.py. Each OBJ is a module compiled by
calibrate_bc.py; its code segment MODULE_CODE is compared with the module
MODULE of the program (its "bl" marker). The procedures are paired in
order: BC emits them in the order of the source, so the source must keep
the order of the program.

Each procedure, and the module-level code, is reported as:

  exact   equal byte for byte; each fixup means the same thing (the same
          runtime routine, the paired procedure, the same place in data)
  shape   the same instructions with other numbers (see codecmp.py)
  NN%     the share of instructions in matching runs, with the first
          instruction that differs

Then each module's constant segment BC_CN (string literals and floating-
point constants, in the order of first use) is compared with the bytes at
its place in the program's DGROUP. Its place is learned from the fixups of
the procedures whose shapes are equal.

--show LABEL prints the instructions of one procedure side by side (the
program's label, such as WON2.12, or "WON2(module)").

As a check of the tool, Civil War Strategy's objects compiled with /Fs
compare as exact with the unpacked CWS.EXE.
"""
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from codecmp import HEADER, Bases, collect_bases, exact_diff, header_bases, header_diff, instructions, shape_match  # noqa: E402
from omflib import read_library  # noqa: E402
from procsplit import Proc, canonicalize, load_runtime_map, runtime_aliases, split_all, views_from_exe, views_from_obj  # noqa: E402


def module_level(view, procs, end=None):
    """The module-level code as a pseudo-procedure list of pieces (start, end)."""
    pieces = []
    p = HEADER
    for pr in procs:
        if pr.start > p:
            pieces.append((p, pr.start))
        p = pr.end
    end = len(view.data) if end is None else end
    if end > p:
        pieces.append((p, end))
    return pieces


def piece_insns(view, pieces):
    out = []
    for s, e in pieces:
        out += instructions(view, s, e)
    return out


def dgroup_of(image, runtime):
    addr = next(a for a, n in runtime.items() if n == "__dataseg")
    return struct.unpack_from("<H", image, addr)[0] * 16


def side_by_side(a, b, limit=None):
    import difflib

    sm = difflib.SequenceMatcher(None, [i.shape for i in a], [i.shape for i in b], autojunk=False)
    shown = 0
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        for k in range(max(i2 - i1, j2 - j1)):
            x = a[i1 + k] if i1 + k < i2 else None
            y = b[j1 + k] if j1 + k < j2 else None
            mark = " " if tag == "equal" else "|"
            if mark == " " and x and y and x.text != y.text and "far proc" not in x.text:
                mark = "*"  # same shape, other numbers
            if mark != "|" and x and y and x.size != y.size:
                mark = "#"  # same shape, other size: a short jump against a near one
            left = f"{x.addr:04x} {x.text}" if x else ""
            right = f"{y.addr:04x} {y.text}" if y else ""
            print(f"{left:46} {mark} {right}")
            shown += 1
            if limit and shown >= limit:
                return


def main():
    args = sys.argv[1:]
    show = None
    if "--show" in args:
        i = args.index("--show")
        show = args[i + 1]
        del args[i : i + 2]
    if len(args) < 3:
        raise SystemExit(__doc__)
    exe, rt_tsv, objs = args[0], args[1], args[2:]
    obj_views = {}
    obj_mods = {}
    for o in objs:
        for v in views_from_obj(o):
            obj_views[v.module] = v
        for m in read_library(o):
            for s in m.segments[1:]:
                if s is not None and s.name.upper().endswith("_CODE"):
                    obj_mods[s.name[:-5]] = m
    canonicalize(obj_views.values(), runtime_aliases(rt_tsv))
    exe_views, image, _ = views_from_exe(exe, rt_tsv, list(obj_views))
    runtime = load_runtime_map(rt_tsv)
    dgroup = dgroup_of(image, runtime)
    eprocs = split_all(exe_views)
    oprocs = split_all(list(obj_views.values()))
    # The program's label of each paired procedure -> the object's name.
    pairs = {}
    name_of = {}
    for ev in exe_views:
        a, b = oprocs[ev.module], eprocs[ev.module]
        if len(a) != len(b):
            print(f"{ev.module}: {len(a)} procedures compiled, {len(b)} in the program; pairing the first {min(len(a), len(b))} in order")
        pairs[ev.module] = list(zip(a, b))
        for po, pe in pairs[ev.module]:
            name_of[pe.label] = po.label
    totals = {"exact": 0, "shape": 0, "differs": 0}
    for ev in exe_views:
        ov = obj_views[ev.module]
        bases = Bases()
        collect_bases(ov, ev, pairs[ev.module], bases)
        header_bases(ov, ev, bases)
        # A word pointing into the module's own code (a GOSUB target with /E)
        # is an offset from the module's start, in the object and the program
        # alike. Voting would learn a wrong base while earlier procedures
        # still differ in size.
        bases.known[f"{ev.module}_CODE"] = 0
        print(f"\n{ev.module}: code {len(ov.data)} bytes compiled, {len(ev.data)} in the program (with padding)")
        e22 = struct.unpack_from("<H", ov.data, 0x22)[0], struct.unpack_from("<H", ev.data, 0x22)[0]
        hd = header_diff(ov, ev)
        print(f"  header: word +22 is {e22[0]:04x} compiled, {e22[1]:04x} in the program (nonzero with /E);"
              + (f" other bytes differ at {', '.join(f'+{k:02x}' for k in hd)}" if hd else " otherwise equal"))
        rows = list(pairs[ev.module])
        # The module-level code, after the header, as one more pseudo-procedure.
        ml_o = module_level(ov, oprocs[ev.module])
        tail = len(ov.data) - (oprocs[ev.module][-1].end if oprocs[ev.module] else 0)
        e_end = (eprocs[ev.module][-1].end if eprocs[ev.module] else 0) + max(tail, 0)
        ml_e = module_level(ev, eprocs[ev.module], min(e_end, len(ev.data)))
        for po, pe in rows + [(None, None)]:
            if po is None:
                label, name = f"{ev.module}(module)", "(module)"
                a, b = piece_insns(ov, ml_o), piece_insns(ev, ml_e)
                diff = None
                if len(ml_o) != len(ml_e):
                    diff = (0, f"{len(ml_o)} pieces against {len(ml_e)}")
                for (s1, e1), (s2, e2) in zip(ml_o, ml_e):
                    d = exact_diff(ov, ev, Proc("", "", s1, e1, 0, 0, 0), Proc("", "", s2, e2, 0, 0, 0), bases, name_of)
                    if d is not None:
                        diff = (s1 + d[0], d[1])
                        break
            else:
                label, name = pe.label, po.label
                a, b = instructions(ov, po.start, po.end), instructions(ev, pe.start, pe.end)
                diff = exact_diff(ov, ev, po, pe, bases, name_of)
            ratio, first = shape_match(a, b)
            if first is None and diff is None:
                status = "exact"
            elif first is None:
                status = "shape"
            else:
                status = "differs"
            totals[status] += 1
            line = f"  {label:13} {name:14} "
            if status == "exact":
                line += "exact"
            elif status == "shape":
                where = f" at {diff[0]:04x}: {diff[1]}" if isinstance(diff, tuple) else ""
                line += f"shape{where}"
            else:
                i, j = first
                x = f"{a[i].addr:04x} {a[i].text}" if i < len(a) else "(end)"
                y = f"{b[j].addr:04x} {b[j].text}" if j < len(b) else "(end)"
                line += f"{ratio:4.0%}  first difference: {x}  /  program {y}"
            print(line)
            if show == label:
                side_by_side(a, b)
        # The constant segment.
        m = obj_mods.get(ev.module)
        cn = next((s for s in m.segments[1:] if s is not None and s.name == "BC_CN"), None) if m else None
        base = bases.base("BC_CN")
        if cn is None or base is None:
            print("  BC_CN: place not known")
        else:
            start = dgroup + base
            got = image[start : start + cn.size]
            bad = [k for k in range(cn.size) if not cn.fixed[k] and (k >= len(got) or got[k] != cn.data[k])]
            if bad:
                print(f"  BC_CN: {cn.size} bytes at DGROUP+{base:04x}; {len(bad)} differ, the first at +{bad[0]:04x}")
            else:
                print(f"  BC_CN: {cn.size} bytes at DGROUP+{base:04x}; equal")
    print(f"\n{totals['exact']} exact, {totals['shape']} shape, {totals['differs']} differ")


if __name__ == "__main__":
    main()
