"""Copy a procedure from the draft src/WON.BAS to new/NAME.bas (if it is not
there yet) and apply text replacements to it, each of which must match once.

Usage: python procedit.py NAME FILE_OF_REPLACEMENTS
The file holds pairs of lines: the old text, then the new text. A new text of
<DEL> deletes the old text. "\\t" in either stands for a tab, "\\n" for a
line break, "\\xNN" for the byte NN (CP437 box characters)."""
import re
import sys
from pathlib import Path

name, reps_file = sys.argv[1], sys.argv[2]
p = Path(f"new/{name}.bas")
if not p.exists():
    src = Path("src/WON.BAS").read_text(encoding="latin1").splitlines()
    a = next(i for i, l in enumerate(src) if re.match(rf"(SUB|FUNCTION) {name}\b", l, re.I))
    b = next(i for i in range(a, len(src)) if re.match(r"END (SUB|FUNCTION)", src[i], re.I))
    p.write_bytes(("\n".join(src[a : b + 1]) + "\n").encode("latin1"))
s = p.read_bytes().decode("latin1")
lines = Path(reps_file).read_text(encoding="latin1").splitlines()
def unescape(x):
    x = re.sub(r"\\x([0-9a-fA-F]{2})", lambda m: chr(int(m.group(1), 16)), x)
    return x.replace("\\t", "\t").replace("\\n", "\n")


for old, new in zip(lines[0::2], lines[1::2]):
    old = unescape(old)
    new = "" if new == "<DEL>" else unescape(new)
    n = s.count(old)
    if n != 1:
        raise SystemExit(f"{n} matches for {old!r}")
    if new == "" and (old + "\n") in s:
        old += "\n"
    s = s.replace(old, new)
p.write_bytes(s.encode("latin1"))
mk = Path("make_won.py")
t = mk.read_text()
t2 = t.replace(f'("{name}", "cws1", "")', f'("{name}", "new", "")')
if t2 != t:
    mk.write_text(t2)
print(f"new/{name}.bas written")
