"""Turn the drawing statements of a lifted listing into BASIC.

Usage: python -I lift2bas.py LIFTED.txt > OUT.bas

LIFTED.txt is the output of "disasm.py ... LABEL --lift". The runtime calls
that make up BC's graphics statements are turned back into the statement:

  B$CSCN(1, n, 2)                        SCREEN n
  B$SCLS(-1)                             CLS
  B$N1I2(x, y) B$PSTC(c)                 PSET (x, y), c
  B$N1I2(x, y) B$PAIN(p, b)              PAINT (x, y), p, b
  [B$N1I2(a, b)] B$N2I2(c, d) B$LINE(k, -1, m)
                                         LINE [(a, b)]-(c, d), k[, B | BF]
  B$DRAW("...")                          DRAW "..."

Every other line becomes a comment starting with "'?", to be written by
hand from the listing. The output is a draft; the compare tool decides.
"""
import re
import sys
from pathlib import Path

CALL = re.compile(r"^[0-9a-f]{4}  (B\$\w+|proc:[\w.]+)\((.*)\)$")


def args_of(text):
    """Split call arguments, keeping quoted strings whole."""
    out, cur, quoted = [], "", False
    for ch in text:
        if ch == '"':
            quoted = not quoted
        if ch == "," and not quoted:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    lines = Path(sys.argv[1]).read_text(encoding="ascii").splitlines()
    out = []
    p1 = p2 = None  # pending first and second point
    for line in lines:
        if line.startswith(";"):
            continue
        m = CALL.match(line)
        if not m:
            out.append("'? " + line.strip())
            continue
        name, a = m.group(1), args_of(m.group(2))
        if name == "B$N1I2":
            p1 = a
            continue
        if name == "B$N2I2":
            p2 = a
            continue
        if name == "B$CSCN" and len(a) == 3 and a[0] == "1":
            out.append(f"SCREEN {a[1]}")
        elif name == "B$SCLS" and a == ["-1"]:
            out.append("CLS")
        # -1 stands for an argument left out: the default color or border.
        elif name == "B$PSTC" and p1:
            color = "" if a[0] == "-1" else f", {a[0]}"
            out.append(f"PSET ({p1[0]}, {p1[1]}){color}")
        elif name == "B$PAIN" and p1 and len(a) == 2:
            border = "" if a[1] == "-1" else f", {a[1]}"
            out.append(f"PAINT ({p1[0]}, {p1[1]}), {a[0]}{border}")
        elif name == "B$LINE" and p2 and len(a) == 3 and a[1] == "-1":
            start = f"({p1[0]}, {p1[1]})" if p1 else ""
            box = {"0": "", "1": "B", "2": "BF"}.get(a[2], f"?{a[2]}")
            if a[0] == "-1":
                tail = f", , {box}" if box else ""
            else:
                tail = f", {a[0]}" + (f", {box}" if box else "")
            out.append(f"LINE {start}-({p2[0]}, {p2[1]}){tail}")
        elif name == "B$DRAW" and len(a) == 1:
            out.append(f"DRAW {a[0]}")
        else:
            pts = (f" after N1I2({', '.join(p1)})" if p1 else "") + (f" N2I2({', '.join(p2)})" if p2 else "")
            out.append(f"'? {name}({', '.join(a)}){pts}")
        p1 = p2 = None
    print("\n".join(out))


if __name__ == "__main__":
    main()
