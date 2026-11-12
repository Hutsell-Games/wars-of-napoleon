"""First draft of WON.BI: CWS14.BI's DECLAREs, plus the procedures of
Wars of Napoleon named so far, and the COMMON SHARED and DIM SHARED layout
read from WON.EXE (WONMENU's module-level B$DDIM calls and commonmap.py).
Names uNNN are placeholders: the variable at COMMON offset NNN (hex)."""
import re
from pathlib import Path

src = Path("cws-orig/CWS14.BI").read_text(encoding="latin1").splitlines()
decl = [l for l in src if l.startswith("DECLARE")]
new = [
    "DECLARE SUB barnacle (who%)",
    "DECLARE SUB bossarmy ()",
    "DECLARE SUB BuffClear ()",
    "DECLARE SUB bunting ()",
    "DECLARE SUB cityicon (c%)",
    "DECLARE SUB enter (who%)",
    "DECLARE SUB findcity (c%, x%, y%)",
    "DECLARE SUB init ()",
    "DECLARE SUB disband ()",
    "DECLARE SUB calendar ()",
    "DECLARE SUB europe ()",
    "DECLARE SUB labels ()",
    "DECLARE SUB showcities ()",
    "DECLARE SUB stencil (x%, y%, a$, f%)",
]
# Procedures whose parameters changed in Wars of Napoleon.
changed = {
    "report": "DECLARE SUB report (who%, mode%)",
    "shipicon": "DECLARE SUB shipicon (who%)",
    "newarmy": "DECLARE SUB newarmy (who%, empty%, target%, nat%)",
}
key = lambda l: re.match(r"DECLARE \w+ (\w+)", l).group(1).lower()
decl = [changed.get(key(l), l) for l in decl]
names = {key(l) for l in decl}
decl += [l for l in new if key(l) not in names]
decl.sort(key=lambda l: re.match(r"DECLARE \w+ (\w+)", l).group(1).lower())

common = """\
COMMON SHARED choose%, tlx%, tly%, size%, mtx$(), wtype%, colour%, hilite%
COMMON SHARED cityx(), cityy(), cityv(), cityp(), city$(), lname$(), filel
COMMON SHARED cash(), control(), matrix(), income(), anima(), rating()
COMMON SHARED nflag, bold, turbo!, mtn(), u29c$, u2a0()
COMMON SHARED image(), force$(), armyloc(), armyname$(), player, aggress!
COMMON SHARED armysize(), armylead(), armyexper(), supply(), month$()
COMMON SHARED rcity(), price(), vicflag(), batwon(), cityo(), u558()
COMMON SHARED armymove(), month, year, array(), mflag, side, ATKFAC, DEFAC, TCR
COMMON SHARED navyloc(), navysize(), navymove(), occupied(), vptotal, fort()
COMMON SHARED victory(), noise, capcity(), difficult, usadv, u73a
COMMON SHARED font$(), brray(), randbal, casualty&()
COMMON SHARED rflag, u7ca, pcode, history, thrill, commerce, raider, grudge
COMMON SHARED mtnx(), mtny(), cities, u836$(), u864(), u892(), u8c0"""

dims = """\
DIM SHARED cityx(cities), cityy(cities), cityv(cities), cityp(cities), city$(cities), lname$(50), rcity(12)
DIM SHARED cash(2), control(2), matrix(cities, 7), income(2), anima(300), rating(50)
DIM SHARED mtx$(29), image(300), force$(2), armyloc(50), armyname$(50), vicflag(6)
DIM SHARED armysize(50), armylead(50), armyexper(50), supply(50), month$(12)
DIM SHARED armymove(50), array(cities), mtn(1 TO 128), u892(12), u2a0(9)
DIM SHARED navyloc(2), navysize(2), navymove(2), occupied(cities), fort(cities)
DIM SHARED victory(2), capcity(2), price(3), u558(50)
DIM SHARED font$(36), brray(cities), casualty&(2), batwon(2), cityo(cities)
DIM SHARED mtnx(19), mtny(19), u836$(12), u864(2)
DIM SHARED u1da4(50)"""

out = ["DEFINT A-Z"] + decl + [
    "'" + "=" * 74,
    "' Recovered from WON.EXE (docs\\recovery.md). uNNN: not yet identified,",
    "' the variable at COMMON offset NNN (hex).",
    "'" + "=" * 74,
] + common.splitlines() + ["cities = 67"] + dims.splitlines()
Path("WON.BI").write_bytes(("\r\n".join(out) + "\r\n").encode("ascii"))
print(len(decl), "declares")
