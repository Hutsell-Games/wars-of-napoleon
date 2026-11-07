"""Show how a procedure of the program differs from its source, statement by statement.

Usage: python -I stmtdiff.py DRAFT.bas SOURCE.BAS NAME

DRAFT.bas is lift2bas.py's output for the program's procedure. SOURCE.BAS
holds the paired procedure NAME (Civil War Strategy's). Both are cut into
statements: lines are split at colons outside strings, spaces are
collapsed, case is ignored, and comments are dropped. The draft's "'?"
lines (not converted) are kept as they are, so they show where the
listing must be read by hand.

Prints a diff of the two statement lists, with the source's line number
for each statement, so the source can be edited in place and keep
Hutsell's layout.
"""
import difflib
import re
import sys
from pathlib import Path


def statements(lines, keep_unconverted=False):
    out = []
    for n, line in enumerate(lines, 1):
        s = line.strip()
        if s.startswith("'?"):
            if keep_unconverted:
                out.append((n, s))
            continue
        cur, quoted = "", False
        for ch in s + ":":
            if ch == '"':
                quoted = not quoted
            if ch == "'" and not quoted:
                break
            if ch == ":" and not quoted:
                t = re.sub(r"\s+", " ", cur).strip()
                if t:
                    out.append((n, t))
                cur = ""
            else:
                cur += ch
        if cur.strip() and not cur.strip().startswith("'"):
            out.append((n, re.sub(r"\s+", " ", cur).strip()))
    return out


def norm(s):
    s = s.upper()
    s = re.sub(r"^CALL (\w+)\((.*)\)$", r"\1 \2", s)
    s = re.sub(r"\s*,\s*", ", ", s)
    return s


def main():
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    draft = statements(Path(sys.argv[1]).read_text(encoding="latin1").splitlines(), keep_unconverted=True)
    src = Path(sys.argv[2]).read_text(encoding="latin1").splitlines()
    name = sys.argv[3]
    start = next(i for i, l in enumerate(src) if re.match(rf"\s*(SUB|FUNCTION)\s+{name}\b", l, re.I))
    end = next(i for i in range(start, len(src)) if re.match(r"\s*END\s+(SUB|FUNCTION)", src[i], re.I))
    body = [(n + start, s) for n, s in statements(src[start + 1 : end])]
    a = [norm(s) for _, s in body]
    b = [norm(s) for _, s in draft]
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        for k in range(i1, i2):
            print(f"- line {body[k][0] + 1}: {body[k][1]}")
        for k in range(j1, j2):
            print(f"+ {draft[k][1]}")
        print()
    print(f"{sum(bl.size for bl in sm.get_matching_blocks())} of {len(a)} source statements equal")


if __name__ == "__main__":
    main()
