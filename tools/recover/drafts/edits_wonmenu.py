# (line in CWSMENU.BAS, old text, new text); applied in place.
EDITS = [
    (344, "(182, 419)", "(182, 409)"), (344, "(191, 429)", "(191, 419)"),
    (344, "(230, 426)", "(230, 416)"), (344, "(275, 432)", "(275, 422)"),
    (345, "(314, 418)", "(314, 408)"), (345, "(354, 431)", "(354, 421)"),
    (345, "(390, 421)", "(390, 411)"), (345, "(390, 422)", "(390, 412)"),
    (346, "(413, 427)", "(413, 417)"), (346, "(437, 419)", "(437, 409)"),
    (346, "(447, 401)", "(447, 391)"), (346, "(447, 377)", "(447, 387)"),
    (347, "(401, 377)", "(401, 387)"),
    (348, "(300, 415)", "(300, 405)"),
    (370, "(232, 327)-(225, 350)", "(202, 327)-(195, 350)"), (370, "(233, 385)", "(203, 385)"),
    (372, "(232, 327)", "(202, 327)"),
    (380, "(360, 328)", "(320, 328)"),
    (381, "(351, 347)", "(311, 347)"), (381, "(355, 367)", "(315, 367)"),
    (382, "(357, 382)", "(317, 382)"),
    (427, "(149, 346)-(188, 345)", "(109, 396)-(148, 395)"),
    (431, "(227, 354)-(236, 383)", "(207, 354)-(216, 383)"),
    (432, "(233, 357)", "(233, 347)"), (432, "(227, 354)", "(207, 354)"),
    (443, "(356, 359)-(359, 380)", "(316, 359)-(319, 380)"),
    (444, "(356, 360)", "(316, 360)"),
    (460, "(431, 378)", "(431, 388)"),
    (461, "(438, 378)", "(438, 388)"),
    (466, "(183, 415)", "(186, 415)"), (466, "(192, 426)", "(198, 420)"), (466, "(212, 426)", "(212, 418)"),
    (471, "(445, 381)-(445, 400)", "(445, 391)-(438, 410)"), (471, "(435, 417)", "(435, 413)"),
    (472, "(413, 424)", "(413, 420)"),
    (473, "(437, 384)", "(437, 388)"), (473, "(445, 382)", "(445, 391)"),
    (474, "(440, 388)", "(440, 390)"),
]
# Lines inserted after a line of CWSMENU.BAS.
INSERT_AFTER = {
    # choices: keep the menu on the screen.
    25: ["IF 8 * (tlx + wide + 1) + 7 > 639 THEN tlx = 78 - wide"],
    # menu: a local array to save the screen under the menu.
    149: ["DIM box(1 TO 13000)"],
    # menu: keep the menu and its shadow on the screen.
    155: ["edge: IF 8 * (tlx + wide + 1) + 13 > 639 THEN tlx = tlx - 1: GOTO edge"],
    # menu: save the screen, then draw the box with choices.
    185: ["\tGET (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 13, 16 * (tly + size + 2) + 14), box"],
    # menu, after a move: redraw the army in the city left.
    247: ["\t\t\tIF occupied(array(row1)) > 0 THEN CALL placearmy(occupied(array(row1)))"],
    # schooner: one more figure.
    388: ["", "LINE (140, 370)-(240, 270): LINE -(160, 380): LINE -(140, 370)", "PAINT (150, 370), 15"],
}
# Lines first..last of CWSMENU.BAS replaced.
REPLACE = {
    # choices: VIEW / CLS 1 / VIEW became a black box and its shadow.
    (28, 30): [
        "LINE (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 7, 16 * (tly + size + 2) + 7), 0, BF",
        "LINE (8 * tlx, 16 * tly - 5)-(8 * (tlx + wide + 1) + 13, 16 * (tly + size + 2) + 13), 0, BF",
    ],
    # menu: the box is drawn by choices only.
    (172, 184): [""],
    # menu, CASE 1 goes on to show the army in the city, as CASE 2 does.
    (190, 192): [
        "\t\tCASE 1: CALL icon(array(row), 0, 7): GOTO occ",
        "\t\tCASE 2: CALL icon(array(row), 0, 9)",
        "occ:",
        "\t\t\ttarget = occupied(array(row))",
    ],
    # menu, CASE 2: the army's name is no longer shown in the menu row.
    (195, 195): [],
    (197, 199): ["\t\t\tCOLOR 12", "\t\t\tCOLOR hilite", "\t\t\tLOCATE tly + 2 + row, tlx + 2: PRINT mtx$(row);", "showsize:"],
    (204, 205): [
        "\t\t\tflag = 0",
        "\t\t\tLINE (8 * tlx, 16 * (tly + size + 3))-(8 * (tlx + 12), 16 * (tly + size + 4)), 2, BF",
    ],
    # menu, CASE 4: the army's name and size instead of armystat.
    (207, 207): [
        "\t\tCASE 4: CALL clrbot",
        "\t\t\ttarget = array(row)",
        "\t\t\tLOCATE tly + 4 + size, tlx + 1: PRINT SPACE$(12);",
        "\t\t\ta$ = armyname$(target): IF LEN(a$) > 11 THEN a$ = LEFT$(a$, 11)",
        "\t\t\tCOLOR 15",
        "\t\t\tLOCATE tly + 5 + size, tlx + 1: PRINT SPACE$(12);",
        "\t\t\tLOCATE tly + 5 + size, tlx + 1: PRINT a$;",
        "\t\t\tGOTO showsize",
    ],
    # menu: no CASE 8 (the generals' faces, the only use of graft()).
    (210, 225): [],
    # menu: no screen saver key.
    (256, 256): [],
    # menu: the arrow and function keys of Wars of Napoleon.
    (266, 299): [
        "arrows:",
        "\ta$ = RIGHT$(a$, 1)",
        "\tIF a$ = \">\" THEN",
        "\t\tCALL report(side, 4)",
        "\t\tchoose = -1",
        "\t\tGOTO called",
        "\tEND IF",
        "\tIF a$ = \";\" THEN",
        "\t\tPUT (8 * tlx - 6, 16 * tly - 11), box, PSET",
        "\t\tLINE (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 13, 16 * (tly + size - 3) + 14), 0, BF",
        "\t\tLINE (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 13, 16 * (tly + size - 3) + 14), 15, B",
        "\t\tCOLOR 14: LOCATE tly + 1, tlx + 1: PRINT \"Hot Keys\"",
        "\t\tCOLOR 15",
        "\t\tLOCATE tly + 2, tlx + 1: PRINT \"F1:Help\"",
        "\t\tLOCATE tly + 3, tlx + 1: PRINT \"F3:Redraw\"",
        "\t\tLOCATE tly + 4, tlx + 1: PRINT \"F4:Forces\"",
        "\t\tLOCATE tly + 5, tlx + 1: PRINT \"F7:EndTurn\"",
        "\t\tCALL tick(99)",
        "\t\tchoose = -1",
        "\t\tGOTO called",
        "\tEND IF",
        "\trow1 = row",
        "\t IF a$ = \"H\" THEN row = row - 1: GOSUB limits: RETURN",
        "\t IF a$ = \"I\" THEN row = 1: GOSUB limits: RETURN",
        "\t IF a$ = \"P\" THEN row = row + 1: GOSUB limits: RETURN",
        "\t IF a$ = \"Q\" THEN row = size: GOSUB limits: RETURN",
        "\t IF a$ = \"=\" AND switch = 0 THEN",
        "\t\tCLS",
        "\t\tCALL europe",
        "\t\tCALL calendar",
        "\t\tCALL choices(b1, wide)",
        "\t\tRETURN",
        "\t END IF",
        "\t IF a$ = \"A\" AND switch = 0 THEN",
        "\t\tchoose = 99",
        "\t\tGOTO called",
        "\t END IF",
        "\t RETURN",
    ],
    # menu: no screen saver.
    (308, 313): [],
    # menu: put back the screen under the menu; no VIEW to reset.
    (316, 316): ["\tCOLOR colour", "\tPUT (8 * tlx - 6, 16 * tly - 11), box, PSET"],
    (324, 324): [],
}


def apply(lines):
    lines = list(lines)
    for n, old, new in EDITS:
        if old not in lines[n - 1]:
            raise SystemExit(f"line {n}: {old!r} not in {lines[n - 1]!r}")
        lines[n - 1] = lines[n - 1].replace(old, new, 1)
    ops = [(n, "insert", v) for n, v in INSERT_AFTER.items()] + [(a, "replace", (b, v)) for (a, b), v in REPLACE.items()]
    for n, kind, v in sorted(ops, key=lambda t: -t[0]):
        if kind == "insert":
            lines[n:n] = v
        else:
            last, new = v
            lines[n - 1 : last] = new
    return lines
