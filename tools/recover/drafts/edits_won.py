"""Edits that turn Civil War Strategy's CWSTRAT.BAS into WON.BAS.
Line numbers are those of the original file, before any edit."""
from pathlib import Path

CWS1 = Path("cws-orig/CWSTRAT.BAS").read_text(encoding="latin1").splitlines()

# The start of the module-level code (lines 1-277) and every procedure are
# written in new\; only the edits below, to CWS lines 278-704, are used.
# [(line, old text, new text)]
EDITS = []
# Whole-file text changes (regular expressions).
TEMP_SUBS = []
# {line: [lines inserted after it]}
INSERT_AFTER = {}
# {(first, last): [lines replacing them]}
REPLACE = {
    # Supply: no realism switch; an army with any supply is skipped.
    (318, 322): [
        "\t\tIF armyloc(i) = 0 OR supply(i) > 0 GOTO alone",
        "\t\tCALL cutoff(side, armyloc(i), a)",
        CWS1[320],
    ],
    # No Capital command; Detach is CASE 5 and open to both sides.
    (339, 361): [
        "'-------------------------------------------------------------------------",
        "'                               Detach",
        "'-------------------------------------------------------------------------",
        "\t\tCASE 5",
        "\tCOLOR 14: CALL clrbot: PRINT \"DETACH UNIT\";",
    ],
    (364, 364): ["\tCALL commander(side, empty): IF empty = 0 GOTO menu0"],
    (370, 371): [
        CWS1[369],
        "\tu558(empty) = u558(index)",
        "\tCOLOR 11: CALL clrbot: PRINT force$(side); \" Unit #\"; empty; \" with \"; : CALL strong(empty):"
        " PRINT \" men detached under \"; armyname$(empty); : CALL TICK(turbo!): IF noise > 0 THEN SOUND 2222, 1",
    ],
    # Drill is CASE 6, Relieve CASE 7.
    (378, 379): ["\t\tCASE 6", "\tCOLOR 14: CALL clrbot: PRINT \"DRILL ARMY\""],
    (392, 392): ["\t\tCASE 7"],
    (398, 398): ["\t\tchosit = 27"],
    (401, 401): ["\tchoose = 21 + chosit: GOTO optmen"],
    # The Utility menu: no Graphics, Jan Campgn, Realism or Chk Links;
    # Tactical and Save CFG are new.
    (405, 430): [
        "\tCASE 7",
        "utile:",
        "\tchosit = 28",
        "\tmtx$(0) = \"Utility\"",
        "\tmtx$(1) = force$(side)",
        "\tmtx$(2) = \"1 Player\": IF player = 2 THEN mtx$(2) = \"2 Player\"",
        "\tmtx$(3) = \"Noise\": IF noise > 0 THEN mtx$(3) = mtx$(3) + STRING$(noise, \"*\")",
        "\tmtx$(4) = \"NO Tactical\": IF u8c0 > 0 THEN mtx$(4) = \"Tactical \xfb\"",
        "\tmtx$(5) = \"Display\" + STR$(turbo!)",
        "\ta$ = STR$(difficult): IF side = 1 THEN a$ = STR$(6 - difficult)",
        "\tmtx$(6) = \"Balance\" + a$",
        "\tmtx$(7) = \"End Cond\"",
        "\ta$ = \"\xfb\": IF randbal = 0 THEN a$ = \"\"",
        "\tmtx$(8) = \"Rndom Evt \" + a$",
        "\tmtx$(9) = \"Vary Start\"",
        "\ta$ = \"\xfb\": IF history = 0 THEN a$ = \"\"",
        "\tmtx$(10) = \"History \" + a$",
        "\tsize = 10: tlx = 66: tly = 11",
        "\tCOLOR 11: LOCATE tly - 2, 67: PRINT \"esc=Main Menu\"",
        "\tIF player = 1 THEN size = 11: mtx$(11) = \"Aggress\" + STR$(bold)",
        "\tsize = size + 1: mtx$(size) = \"Save CFG\"",
        "\tCALL menu(-1): CALL clrrite",
    ],
    (441, 442): ["\t\tchoose = 22: GOTO utile"],
    # No Graphics option; Sounds is CASE 3.
    (452, 469): ["\t    CASE 3"],
    (480, 481): ["\t\tIF noise > 0 THEN SOUND 999, .5", "\t\tchoose = 24: GOTO utile"],
    # Display is CASE 4 ... Aggression CASE 11, then Save CFG.
    (485, 665): [
        "\t    CASE 4",
        "\t\tu8c0 = 1 - u8c0",
        "\t\tIF LEN(DIR$(\"rrs.exe\")) > 0 THEN u8c0 = 0: m$ = \"Linked tactical game in Registered Game Only\": CALL image2(m$, 4)",
        "\t\tIF noise > 0 THEN SOUND 1999, .5",
        "\t\tchoose = 25: GOTO utile",
        "'-------------------------------------------------------------------------",
        "'                               Display Speed",
        "'-------------------------------------------------------------------------",
        "\t    CASE 5",
    ] + CWS1[485:491] + [
        "\t\ttlx = 67: tly = 15: size = 4",
    ] + CWS1[493:501] + [
        "\t\tEND SELECT",
        "\t\tchoose = 26: GOTO utile",
    ] + CWS1[508:511] + [
        "\t   CASE 6",
        CWS1[512],
        CWS1[513],
        "\t\tmtx$(1) = \"Allied ++\"",
        "\t\tmtx$(2) = \"Allied +\"",
        CWS1[516],
        "\t\tmtx$(4) = \"French +\"",
        "\t\tmtx$(5) = \"French ++\"",
    ] + CWS1[519:525] + [
        "\t\tusadv = 75 * difficult: IF player = 2 THEN usadv = 10 * difficult",
        "\t\tchoose = 27: GOTO utile",
    ] + CWS1[527:540] + [
        "\t\t mtx$(2) = \"Favor Allies\": IF randbal = 3 THEN mtx$(2) = mtx$(2) + \" \x11\"",
        CWS1[541],
        "\t\t mtx$(4) = \"Favor French\": IF randbal = 7 THEN mtx$(4) = mtx$(4) + \" \x11\"",
    ] + CWS1[543:565] + [
        "\t\t CALL europe",
    ] + CWS1[566:591] + [
        CWS1[598],
        CWS1[599],
    ] + CWS1[600:605] + [
        "\t\tCALL europe",
    ] + CWS1[606:608] + [
        "'                               History",
        "'-------------------------------------------------------------------------",
        "\t   CASE 10",
        CWS1[642],
        "\t\ta$ = \"OFF\": IF history = 1 THEN a$ = \"ON\": GOSUB history: CALL europe",
        CWS1[644],
        "\t\tchoose = 31: GOTO utile",
        "'-------------------------------------------------------------------------",
        "'                               Aggression",
        "'-------------------------------------------------------------------------",
        "\t   CASE 11",
    ] + CWS1[650:662] + [
        "\t\tchoose = 32: GOTO utile",
        "\t\tCASE size",
        "\t\tGOSUB savecfg: GOTO utile",
        CWS1[663],
        CWS1[664],
    ],
    # Files is CASE 8. After loading a game from the start menu, go on to
    # the calendar (goon:).
    (669, 669): ["\tCASE 8"],
    (672, 672): ["\tchoose = 23: chosit = 29: IF year = 1861 THEN choose = 22"],
    (678, 678): ["\tsize = 4: tlx = 66: tly = 15"],
    (687, 693): [
        "\t\t\tIF replay = 0 THEN GOTO menu0 ELSE replay = 0: GOTO goon",
        "\t\tCASE 3",
        "\t\t\tGOSUB savecfg",
        "\t\t\tCLS",
        "\t\t\tGOTO newgame",
    ],
}


def apply(lines):
    import re

    lines = [l for l in lines]
    for pat, rep in TEMP_SUBS:
        lines = [re.sub(pat, rep, l) for l in lines]
    for n, old, new in EDITS:
        if old not in lines[n - 1]:
            raise SystemExit(f"line {n}: {old!r} not in {lines[n - 1]!r}")
        lines[n - 1] = lines[n - 1].replace(old, new, 1)
    ops = [(n, "insert", v) for n, v in INSERT_AFTER.items()]
    ops += [(a, "replace", (b, v)) for (a, b), v in REPLACE.items()]
    for n, kind, v in sorted(ops, key=lambda t: -t[0]):
        if kind == "insert":
            lines[n:n] = v
        else:
            last, new = v
            lines[n - 1 : last] = new
    return lines
