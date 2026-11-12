"""bunting (WON2.06) from its lift2bas draft, with the loops and POINT lines
written by hand from the disassembly."""
import re
from pathlib import Path

d = Path("bunting_draft.bas").read_text(encoding="ascii").splitlines()
out = ["SUB bunting"]
i = 0
pending_point = False
while i < len(d):
    s = d[i]
    if s.startswith("'? B$ENRA") or s.startswith("'? B$EXSA") or "retf" in s:
        i += 1
        continue
    if s.startswith("'? B$PSET() after N1I2("):
        x, y = re.search(r"N1I2\((\d+), (\d+)\)", s).groups()
        out.append(f"PSET ({x}, {y})")
        i += 1
        continue
    if s.startswith("'? 0896"):
        # the roof: lines widening downwards
        out += [
            "d = 0",
            "FOR i = 180 TO 200: d = d + 1: LINE (580 - d, i)-(590 + d, i), 7: NEXT i",
            "FOR i = 1 TO 10: LINE (540 + 8 * i, 230)-(544 + 8 * i, 280), 0, BF: NEXT i",
        ]
        while not d[i].startswith("LINE (540, 250)"):
            i += 1
        continue
    if s.startswith("'? 0a24"):
        out.append("FOR i = 1 TO 5: LINE (570, 280 + 4 * i)-(600, 280 + 4 * i), 0, B: NEXT i")
        while not d[i].startswith("LINE (566, 280)"):
            i += 1
        continue
    if s.startswith("'? B$PNT1(0)"):
        out.append("x = POINT(0): y = POINT(1)")
        while not d[i].startswith("PAINT (local1c, local1e)"):
            i += 1
        out.append(d[i].replace("local1c", "x").replace("local1e", "y"))
        i += 1
        continue
    if s.startswith("'? proc:WON2.42(turbo!)"):
        out.append("CALL tick(turbo!)")
        i += 1
        continue
    if s.startswith("'?"):
        raise SystemExit(f"not handled: {s}")
    out.append(s)
    i += 1
out.append("END SUB")
Path("new/bunting.bas").write_text("\n".join(out) + "\n", encoding="ascii")
print(len(out), "lines")
