"""Draft of WON2.BAS: Civil War Strategy's procedures (edited by edits_won2.py),
new procedures from new\\NAME.bas, and stubs for those not written yet."""
import re
from pathlib import Path

import edits_won2

SOURCES = {
    "cws1": "cws-orig/CWSTRAT.BAS",
    "cws2": "cws-orig/CWSTRAT2.BAS",
}
text = {}
for key, path in SOURCES.items():
    lines = Path(path).read_text(encoding="latin1").splitlines()
    text[key] = edits_won2.apply(key, lines)

# (name, where from, parameters of a stub) in WON2's order.
ORDER = [
    ("barnacle", "new", "who"), ("bossarmy", "new", ""), ("bub2", "cws2", ""), ("bubble", "cws2", ""),
    ("BuffClear", "new", ""), ("bunting", "new", ""), ("calendar", "new", ""), ("cancel", "cws2", ""),
    ("capture", "cws2", ""), ("center", "cws2", ""), ("cityicon", "new", "c"), ("clrbot", "cws2", ""),
    ("clrrite", "cws2", ""), ("commander", "cws2", ""), ("cutoff", "cws1", ""), ("disband", "new", ""),
    ("endit", "cws2", ""), ("enter", "new", "who"), ("evaluate", "cws2", ""), ("events", "new", ""),
    ("findcity", "new", "a, b, c"), ("image2", "cws2", ""), ("init", "new", ""), ("iterate", "cws1", ""),
    ("labels", "new", ""), ("maxx", "new", ""), ("navy", "cws1", ""), ("normal", "cws1", ""),
    ("occupy", "cws2", ""), ("relieve", "cws2", ""), ("report", "cws2", ""), ("resupply", "cws2", ""),
    ("retreat", "cws2", ""), ("roman", "cws2", ""), ("scribe", "cws2", ""), ("shipicon", "cws2", ""),
    ("ships", "new", ""), ("smarts", "cws1", ""), ("starfin", "cws2", ""), ("stax", "cws2", ""),
    ("stencil", "new", "x, y, a$, f"), ("tick", "cws2", ""), ("victor", "cws2", ""), ("void", "cws2", ""),
]


def sub(lines, name):
    start = next(i for i, l in enumerate(lines) if re.match(rf"(SUB|FUNCTION) {name}\b", l, re.I))
    end = next(i for i in range(start, len(lines)) if re.match(r"END (SUB|FUNCTION)", lines[i], re.I))
    return lines[start : end + 1]


head = text["cws2"][:11]  # DEFINT, DECLAREs, $INCLUDE
head = [l.replace("cws14.bi", "won.bi") for l in head]
body = list(head)
for name, where, params in ORDER:
    if where == "new":
        f = Path(f"new/{name}.bas")
        part = f.read_text(encoding="latin1").splitlines() if f.exists() else (
            [f"SUB {name} ({params})" if params else f"SUB {name}", "END SUB"])
    else:
        part = sub(text[where], name)
    body += [""] + part
Path("src").mkdir(exist_ok=True)
Path("src/WON2.BAS").write_bytes(("\r\n".join(body) + "\r\n").encode("latin1"))
print(len(body), "lines")
