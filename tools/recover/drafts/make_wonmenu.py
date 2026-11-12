"""First draft of WONMENU.BAS from CWSMENU.BAS, europe.bas and WONMENU's
module-level code read from WON.EXE."""
import re
from pathlib import Path

import edits_wonmenu

cws = Path("cws-orig/CWSMENU.BAS").read_text(encoding="latin1").splitlines()
cws = edits_wonmenu.apply(cws)


def sub(name):
    start = next(i for i, l in enumerate(cws) if re.match(rf"SUB {name}\b", l, re.I))
    end = next(i for i in range(start, len(cws)) if cws[i].upper().startswith("END SUB"))
    return cws[start : end + 1]


head = [
    "DEFINT A-Z",
    "DECLARE SUB choices (b1%, wide%)",
    "DECLARE SUB mxw (wide%)",
    "DECLARE SUB stax (who%)",
    "' $INCLUDE: 'won.bi'",
] + cws[7:24] + [
    "y = 68: COLOR 11: LOCATE 1, y: PRINT \"Attacker\"",
    "c = 9: IF attack > 25 THEN c = 7",
    "COLOR c: LOCATE 3, y: PRINT armyname$(attack)",
    "LOCATE 4, y: CALL strong(attack)",
]
europe = Path("europe.bas").read_text(encoding="ascii").splitlines()
body = head
for part in (sub("choices"), europe, sub("menu"), sub("mxw"), sub("schooner")):
    body += [""] + part
Path("src").mkdir(exist_ok=True)
Path("src/WONMENU.BAS").write_bytes(("\r\n".join(body) + "\r\n").encode("ascii"))
print(len(body), "lines")
