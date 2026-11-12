from pathlib import Path

d = Path("europe_draft.bas").read_text(encoding="ascii").splitlines()
L = lambda a, b: d[a - 1 : b]  # draft lines a..b, 1-based, inclusive

out = ["SUB europe"]
out += L(2, 4)
out += [
    "SELECT CASE look",
    "\tCASE 2: a = 63: x = 40: y = 0",
    "\tCASE 3: a = 10: x = 10: y = 30",
    "\tCASE 4: a = 30: x = 10: y = 10",
    "\tCASE ELSE: a = 0: x = 34: y = 0",
    "END SELECT",
]
out += L(27, 27)
out += ["c& = 65536 * a + 256 * x + y", "PALETTE 2, c&"]
out += L(52, 112)
out += ["IF look = 2 THEN"]
out += ["\t" + s for s in L(116, 123)]
out += ["END IF"]
out += [
    "DEF SEG = VARSEG(mtn(1))",
    'BLOAD "mtn.vga", VARPTR(mtn(1))',
    "DEF SEG",
    "FOR k = 1 TO 19",
    "\tPUT (mtnx(k), mtny(k)), mtn, PSET",
    "\tPUT (mtnx(k) + 10, mtny(k) + 20), mtn, PSET",
    "NEXT k",
    "labels",
    "showcities",
    "disband",
    "FOR i = 1 TO 2: CALL stax(i): NEXT i",
    "IF commerce > 0 THEN",
    "\tCOLOR 14",
    "\tx = 140: y = 405",
    "\tCIRCLE (x, y), 70, 13, , , .25",
    "\tPAINT (x, y), 3, 13",
    '\tstencil x - 32, y - 8, "RAID COMMERCE", 0',
    "END IF",
    "ships",
    "END SUB",
]
assert not any(s.startswith("'?") for s in out), [s for s in out if s.startswith("'?")]
Path("europe.bas").write_text("\n".join(out) + "\n", encoding="ascii")
print(len(out), "lines")
