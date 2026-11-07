"""Map the COMMON SHARED variables of Civil War Strategy to their places in a program.

Usage:
  python -I commonmap.py FILE.BI UNPACKED.EXE RUNTIME.tsv MODULES PAIRS.tsv OBJ...

FILE.BI is the include file with the COMMON SHARED statements (CWS14.BI).
Its layout is worked out from BC's sizes: INTEGER 2 bytes, SINGLE and LONG
4, DOUBLE 8, a string 4, an array's descriptor 46. DEFINT A-Z is assumed,
as in CWS14.BI. For CWS14.BI this gives 2,238 bytes, the size of COMMON in
Hutsell's objects.

PAIRS.tsv is the output of pairprocs.py. In each pair that is "same" or
"changed", the instructions in equal runs are matched one to one; where the
object's instruction refers to COMMON+d, the program's word gives the place
in the program. The program's COMMON starts where its module header says.

Prints each variable with its offset in Civil War Strategy and the offsets
the program uses for it (with the number of instructions that say so), then
the offsets the program reads or writes directly that no variable explains.
"""
import collections
import difflib
import re
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from codecmp import instructions  # noqa: E402
from procsplit import canonicalize, runtime_aliases, split_all, views_from_exe, views_from_obj  # noqa: E402

SIZES = {"%": 2, "!": 4, "&": 4, "#": 8, "$": 4, "": 2}
ARRAY = 46
DIRECT = re.compile(r"\[(0x[0-9a-f]+|\d+)\]")


def layout(bi_path):
    rows, off = [], 0
    for line in Path(bi_path).read_text(encoding="latin1").splitlines():
        m = re.match(r"\s*COMMON\s+SHARED\s+(.*)", line, re.I)
        if not m:
            continue
        for v in m.group(1).split("'")[0].split(","):
            v = v.strip()
            arr = v.endswith("()")
            name = v[:-2] if arr else v
            suf = name[-1] if name[-1] in "%!&#$" else ""
            size = ARRAY if arr else SIZES[suf]
            rows.append((off, name + ("()" if arr else ""), size))
            off += size
    return rows, off


def main():
    if len(sys.argv) < 7:
        raise SystemExit(__doc__)
    bi, exe, rt_tsv, modules, pairs_tsv = sys.argv[1:6]
    objs = sys.argv[6:]
    rows, total = layout(bi)
    print(f"{bi}: {len(rows)} variables, {total} bytes")
    eviews, _, _ = views_from_exe(exe, rt_tsv, modules.split(","))
    eprocs = split_all(eviews)
    common = struct.unpack_from("<H", eviews[0].data, 0x18)[0]
    end = struct.unpack_from("<H", eviews[0].data, 0x0E)[0]
    print(f"program: COMMON at DGROUP+{common:04x}, {end - common} bytes (to the first module's data)")
    oviews = [v for o in objs for v in views_from_obj(o)]
    canonicalize(oviews, runtime_aliases(rt_tsv))
    oprocs = split_all(oviews)
    by_name = {pr.label: (v, pr) for v in oviews for pr in oprocs[v.module]}
    by_label = {pr.label: (v, pr) for v in eviews for pr in eprocs[v.module]}
    votes = collections.defaultdict(collections.Counter)  # CWS offset -> program offsets
    for line in Path(pairs_tsv).read_text(encoding="ascii").splitlines()[1:]:
        f = line.split("\t")
        if f[4] not in ("same", "changed"):
            continue
        (e, pe), (o, po) = by_label[f[0]], by_name[f[6]]
        a, b = instructions(o, po.start, po.end), instructions(e, pe.start, pe.end)
        sm = difflib.SequenceMatcher(None, [i.shape for i in a], [i.shape for i in b], autojunk=False)
        for bl in sm.get_matching_blocks():
            for k in range(bl.size):
                ia, ib = a[bl.a + k], b[bl.b + k]
                for off in range(ia.addr, ia.addr + ia.size):
                    r = o.refs.get(off)
                    if r and r[0] == "COMMON":
                        w = struct.unpack_from("<H", e.data, ib.addr + off - ia.addr)[0]
                        votes[r[1]][(w - common) & 0xFFFF] += 1
    explained = set()
    print("\ncws_offset\tvariable\tsize\tprogram_offsets")
    for off, name, size in rows:
        seen = collections.Counter()
        for d in range(size):
            for w, n in votes.get(off + d, {}).items():
                seen[(w - d) & 0xFFFF] += n
        if seen:
            best = seen.most_common(1)[0][0]
            explained.update(range(best, best + size))
        text = ", ".join(f"{w:04x} ({n})" for w, n in seen.most_common(3)) or "-"
        print(f"{off:04x}\t{name}\t{size}\t{text}")
    # Direct references [addr] in all the program's code, inside COMMON.
    direct = collections.Counter()
    for v in eviews:
        for i in instructions(v, 0x2E, len(v.data)):
            for m in DIRECT.finditer(i.text):
                a = int(m.group(1), 0)
                if common <= a < end:
                    direct[a - common] += 1
    rest = sorted(o for o in direct if o not in explained)
    print(f"\nprogram offsets read or written directly that no variable explains: {len(rest)}")
    print(" ".join(f"{o:04x}({direct[o]})" for o in rest))


if __name__ == "__main__":
    main()
