"""Pair each procedure of a program with a procedure of other code.

Usage:
  python -I pairprocs.py UNPACKED.EXE RUNTIME.tsv MODULES OBJ... [--tsv OUT.tsv]

MODULES names the program's modules, separated by commas (WON,WON2,WONMENU).
Each OBJ is a module whose procedures have names: for Wars of Napoleon,
Hutsell's Civil War Strategy objects. RUNTIME.tsv is the program's runtime
map; it also gives the runtime names of the objects' calls.

Each program procedure is compared with each object procedure by shape
(codecmp.py): the share of their instructions that lie in equal runs of 4 or
more. Pairs whose sizes differ more than threefold are not compared.

Then each module is paired in order (ordered_pairs): the QBX editor keeps a
module's procedures in alphabetical order, so the names paired with a
module's procedures must be in alphabetical order too. A procedure moved to
another module still pairs, since every module is matched against all names.

A row gives the procedure's size, frame (bytes of locals) and number of
parameters; the name paired in order, its score and the same facts for it;
and the best name by score alone, if that is another. A pair is:

  same     shapes equal
  changed  50% or more of the instructions align
  new      less than 50%, or no name fits in order: written from its
           disassembly
"""
import difflib
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from codecmp import instructions  # noqa: E402
from procsplit import canonicalize, runtime_aliases, split_all, views_from_exe, views_from_obj  # noqa: E402

FLOOR = 0.15  # a pair scoring less is not used by the ordered pairing


def shape_ratio(x, y):
    if x == y:
        return 1.0
    sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
    if sm.real_quick_ratio() < FLOOR or sm.quick_ratio() < FLOOR:
        return 0.0
    same = sum(bl.size for bl in sm.get_matching_blocks() if bl.size >= 4)
    return 2 * same / (len(x) + len(y))


def ordered_pairs(labels, names, score, floor=FLOOR):
    """Pair a module's procedures (in program order) with names (in
    alphabetical order) so that the pairs keep both orders and the sum of
    scores is greatest. Pairs scoring below floor are left out. Returns
    {label: name}."""
    n, m = len(labels), len(names)
    best = [[0.0] * (m + 1) for _ in range(n + 1)]
    for i in range(n - 1, -1, -1):
        for j in range(m - 1, -1, -1):
            s = score.get((labels[i], names[j]), 0.0)
            take = s + best[i + 1][j + 1] if s >= floor else -1.0
            best[i][j] = max(take, best[i + 1][j], best[i][j + 1])
    out = {}
    i = j = 0
    while i < n and j < m:
        s = score.get((labels[i], names[j]), 0.0)
        if s >= floor and abs(best[i][j] - (s + best[i + 1][j + 1])) < 1e-9:
            out[labels[i]] = names[j]
            i += 1
            j += 1
        elif best[i][j] == best[i + 1][j]:
            i += 1
        else:
            j += 1
    return out


def kind_of(r):
    return "same" if r == 1.0 else "changed" if r >= 0.5 else "new"


def main():
    args = sys.argv[1:]
    tsv = None
    if "--tsv" in args:
        i = args.index("--tsv")
        tsv = Path(args[i + 1])
        del args[i : i + 2]
    if len(args) < 4:
        raise SystemExit(__doc__)
    exe, rt_tsv, modules, objs = args[0], args[1], args[2].split(","), args[3:]
    eviews, _, _ = views_from_exe(exe, rt_tsv, modules)
    eprocs = split_all(eviews)
    oviews = [v for o in objs for v in views_from_obj(o)]
    canonicalize(oviews, runtime_aliases(rt_tsv))
    oprocs = split_all(oviews)
    cands = {}  # name -> (module, proc, shapes)
    for v in oviews:
        for pr in oprocs[v.module]:
            cands[pr.label] = (v.module, pr, [i.shape for i in instructions(v, pr.start, pr.end)])
    names = sorted(cands, key=str.upper)
    score = {}
    for v in eviews:
        for pe in eprocs[v.module]:
            shapes = [i.shape for i in instructions(v, pe.start, pe.end)]
            for name, (_, po, oshapes) in cands.items():
                if max(len(shapes), len(oshapes)) > 3 * max(1, min(len(shapes), len(oshapes))):
                    continue
                score[(pe.label, name)] = shape_ratio(shapes, oshapes)
    head = ("label", "size", "frame", "params", "kind", "align", "cws_name", "cws_module",
            "cws_size", "cws_frame", "cws_params", "best_by_score")
    rows = []
    for v in eviews:
        labels = [pe.label for pe in eprocs[v.module]]
        paired = ordered_pairs(labels, names, score)
        for pe in eprocs[v.module]:
            name = paired.get(pe.label)
            r = score.get((pe.label, name), 0.0) if name else 0.0
            top = max(((s, n) for (lab, n), s in score.items() if lab == pe.label), default=(0.0, None))
            other = f"{top[1]} {top[0]:.0%}" if top[1] and top[1] != name else "-"
            if name:
                mod, po, _ = cands[name]
                rows.append((pe.label, pe.size, pe.frame, pe.params, kind_of(r), f"{r:.0%}",
                             name, mod, po.size, po.frame, po.params, other))
            else:
                rows.append((pe.label, pe.size, pe.frame, pe.params, "new", "-",
                             "-", "-", "-", "-", "-", other))
    print("\t".join(head))
    for r in rows:
        print("\t".join(str(x) for x in r))
    counts, sizes = {}, {}
    for r in rows:
        counts[r[4]] = counts.get(r[4], 0) + 1
        sizes[r[4]] = sizes.get(r[4], 0) + r[1]
    total = sum(sizes.values())
    for k in ("same", "changed", "new"):
        print(f"{k:8} {counts.get(k, 0):3} procedures, {sizes.get(k, 0):6} bytes ({sizes.get(k, 0) / total:.0%})")
    used = {r[6] for r in rows}
    print("names not paired:", " ".join(n for n in names if n not in used))
    if tsv:
        with tsv.open("w", encoding="ascii", newline="\n") as f:
            f.write("\t".join(head) + "\n")
            for r in rows:
                f.write("\t".join(str(x) for x in r) + "\n")


if __name__ == "__main__":
    main()
