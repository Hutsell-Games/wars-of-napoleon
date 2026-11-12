"""Draft of WON.BAS: Civil War Strategy's CWSTRAT.BAS (edited by edits_won.py),
new procedures from new\\NAME.bas, and stubs for those not written yet."""
import re
from pathlib import Path

import edits_won

cws = Path("cws-orig/CWSTRAT.BAS").read_text(encoding="latin1").splitlines()
first_sub = next(i for i, l in enumerate(cws) if re.match(r"SUB ", l))
lines = edits_won.apply(cws)

# (name, where from, parameters of a stub) in WON's order.
ORDER = [
    ("animate", "new", ""), ("armies", "new", ""), ("battle", "new", ""), ("combine", "new", ""),
    ("filer", "new", ""), ("flashcity", "new", ""), ("fortify", "new", ""), ("icon", "new", ""),
    ("movefrom", "new", ""), ("newarmy", "new", ""), ("newcity", "cws1", ""), ("placearmy", "new", ""),
    ("recruit", "new", ""), ("showcities", "new", ""), ("snapshot", "cws1", ""), ("strong", "cws1", ""),
    ("tupdate", "new", ""),
]


def sub(name):
    start = next(i for i, l in enumerate(lines) if re.match(rf"(SUB|FUNCTION) {name}\b", l, re.I))
    end = next(i for i in range(start, len(lines)) if re.match(r"END (SUB|FUNCTION)", lines[i], re.I))
    return lines[start : end + 1]


# The module-level code: everything before the first SUB of the edited file.
head_end = next(i for i, l in enumerate(lines) if re.match(r"SUB ", l))
body = [l.replace("cws14.bi", "won.bi") for l in lines[:head_end]]
# The module-level code written so far for Wars of Napoleon replaces the
# start of Civil War Strategy's; the rest of CWSTRAT's follows for now.
MAIN = [Path("new/won_main1.txt")]
CWS_FROM = 278  # first line of CWSTRAT.BAS not yet replaced
written = [l for f in MAIN for l in f.read_text(encoding="latin1").splitlines()]
# Find where CWS_FROM lands after the edits: mark the line, edit, look for the mark.
MARK = "' @@CWS_FROM@@"
marked = edits_won.apply(cws[: CWS_FROM - 1] + [MARK + cws[CWS_FROM - 1]] + cws[CWS_FROM:])
start = next(i for i, l in enumerate(marked) if l.startswith(MARK))
body = written + lines[start:head_end]
# WON's own subroutines at the end of the module code replace CWS's, from
# topbar: to the end of the module code.
t0 = next(i for i, l in enumerate(body) if l.startswith("topbar:"))
t1 = len(body)  # WON has no DATA: CWS's font DATA is dropped
body[t0:t1] = Path("new/won_tail.txt").read_text(encoding="latin1").splitlines()
for name, where, params in ORDER:
    if where == "new":
        f = Path(f"new/{name}.bas")
        part = f.read_text(encoding="latin1").splitlines() if f.exists() else (
            [f"SUB {name} ({params})" if params else f"SUB {name}", "END SUB"])
    else:
        part = sub(name)
    body += [""] + part
Path("src").mkdir(exist_ok=True)
Path("src/WON.BAS").write_bytes(("\r\n".join(body) + "\r\n").encode("latin1"))
print(len(body), "lines")
