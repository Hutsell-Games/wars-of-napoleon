from pathlib import Path

"""Edits that turn Civil War Strategy's procedures into WON2's.
Line numbers are those of the original file, before any edit."""

# file key -> [(line, old text, new text)]
EDITS = {"cws1": [
    (1670, "CALL usa", "CALL europe"),
    # navy: WON's procedure that redraws the cities is showcities (WON.14).
    (1563, "CALL showcity", "CALL showcities"),
    (1571, "CALL showcity", "CALL showcities"),
    # navy: an objective, not a capital.
    (1568, '"The CAPITAL steadfastly stands loyal"', '"The OBJECTIVE CITY steadfastly stands loyal"'),
    # iterate: 50 armies, 25 a side.
    (1346, "FOR i = 1 TO 40", "FOR i = 1 TO 50"),
    (1353, "FOR i = 1 TO 40", "FOR i = 1 TO 50"),
    (1354, "IF i > 20", "IF i > 25"),
    (1376, "FOR i = 1 TO 20", "FOR i = 1 TO 25"),
    (1377, "FOR i = 21 TO 40", "FOR i = 26 TO 50"),
    (1356, "a = 1: IF realism > 0 THEN CALL cutoff(s, armyloc(i), a)", "a = 1: CALL cutoff(s, armyloc(i), a)"),
    (1371, "IF RND > .8 AND armysize(i) > 50 THEN", "IF armysize(i) > 10 THEN"),
], "cws2": [
    (766, "SUB report (who)", "SUB report (who, mode)"),
    # scribe: Wars of Napoleon's history file.
    (1117, '"cws.his"', '"nws.his"'),
    # The map of Europe instead of the United States.
    (302, "CALL usa", "CALL europe"),
    (971, "CALL usa", "CALL europe"),
    # victor: the missing space is added (so the text is the one of line 1797).
    (1803, '"side close to"', '" side close to"'),
    # relieve: the menu one column further left.
    (752, "tlx = 67", "tlx = 66"),
    # 50 armies, 25 a side, where Civil War Strategy has 40 and 20.
    (976, "IF index > 20", "IF index > 25"),
    (993, "(side = 1 AND defend > 20) OR (side = 2 AND defend < 21)", "(side = 1 AND defend > 25) OR (side = 2 AND defend < 26)"),
    (998, "IF defend > 20", "IF defend > 25"),
    (706, "FOR i = 1 TO 40", "FOR i = 1 TO 50"),
    (1191, "star = 1: fin = 20: IF who = 2 THEN star = 21: fin = 40",
     "star = 1: fin = 25: IF who = 2 THEN star = 26: fin = 50"),
    # endit: the condition is an objective, not a capital.
    (285, '"Capital Captured"', '"Objective Captured"'),
    # victor: 25 armies a side; warn 3 months ahead; income out of vptotal.
    (1761, "FOR j = 1 TO 20", "FOR j = 1 TO 25"),
    (1763, "FOR j = 21 TO 40", "FOR j = 26 TO 50"),
    (1767, "AND month < vicflag(1) THEN", "AND vicflag(1) - month < 3 THEN"),
    (1776, "income(i) / (income(1) + income(2))", "income(i) / vptotal"),
    (1796, "income(i) / (income(1) + income(2))", "income(i) / vptotal"),
]}
# file key -> {line: [lines inserted after it]}
INSERT_AFTER = {"cws1": {}, "cws2": {
    # victor: losing army 1 (Napoleon's) ends the game.
    1770: ["\tIF armyloc(1) = 0 THEN j = 8: victory(1) = victory(1) + 300: GOTO finis"],
}}
# file key -> {(first, last): [lines replacing them]}
REPLACE_CWS1_NAVY = {
    # navy: choosing what the computer's fleet does.
    (1416, 1417): [
        "\t\tIF u7ca > 0 THEN chx = 3",
        "\t\tIF commerce = 3 - who AND raider > 0 THEN chx = 4",
        "\t\tIF who = 2 AND navyloc(3 - who) <> 99 AND RND > .7 THEN chx = 4",
        "\t\tIF grudge > 0 THEN chx = 3",
    ],
    (1435, 1435): [
        '\tIF who = cityp(navyloc(who)) THEN mtx$(2) = "-": choose = 22',
        '\tIF who = 2 AND navyloc(who) = 35 AND cityp(navyloc(who)) <> 1 THEN mtx$(2) = "-": choose = 22',
    ],
    (1440, 1440): ['mtx$(4) = "Raid": IF navysize(who) < 1 OR who = commerce THEN mtx$(4) = "-"'],
    (1443, 1444): [
        "\tn = who: IF who = 2 THEN n = 3",
        '\tIF navysize(who) > 1 AND cityp(navyloc(who)) = 0 THEN IF u892(n) > 50 OR cityo(navyloc(who)) > 6 THEN size = 5: mtx$(5) = "Invasion": CALL void(navyloc(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5',
    ],
    (1447, 1449): [
        "IF chx > 0 THEN IF nflag > 0 AND chx > 1 THEN EXIT SUB ELSE choose = chx: GOTO anchor",
        "IF nflag > 0 AND choose <> 1 THEN EXIT SUB",
        "CALL menu(0)",
    ],
    # navy, CASE 1: building ships; no ironclads.
    (1458, 1495): [
        "\tIF chx = 1 THEN",
        "\t\tIF navysize(who) > 9 THEN EXIT SUB",
        "\t\tIF RND < .07 * navysize(who) THEN EXIT SUB",
        "\tEND IF",
        "\tIF chx = 0 AND navysize(who) > 9 THEN GOTO ahoy",
        "",
        "\tIF chx = 0 AND navyloc(who) > 0 THEN",
        "\t\tIF who <> cityp(navyloc(who)) GOTO ahoy",
        "\t\tIF matrix(navyloc(who), 7) < 90 GOTO ahoy",
        "\tEND IF",
        "\tnavysize(who) = navysize(who) + 1",
        "\tIF navysize(who) > 1 GOTO add2ship",
        "ships:",
        '\tmtx$(0) = "Port": size = 0: tlx = 67: tly = 12',
        "\tFOR i = 1 TO cities: IF matrix(i, 7) > 90 AND cityp(i) = who AND navyloc(3 - who) <> i THEN size = size + 1: mtx$(size) = city$(i): array(size) = i",
    ],
    (1496, 1496): [
        "\tNEXT i",
        "\tIF who = 2 AND cityp(35) <> 1 THEN size = size + 1: mtx$(size) = city$(35): array(size) = 35",
    ],
    (1499, 1499): ["\t\tnavysize(who) = 0"],
    (1503, 1503): ["\tIF chx = 0 THEN CALL menu(0)"],
    (1531, 1531): [
        "\tIF who = cityp(navyloc(who)) GOTO ahoy",
        "\tIF who = 2 AND navyloc(who) = 35 AND cityp(navyloc(who)) <> 1 GOTO ahoy",
    ],
    (1552, 1552): ["\t\tnavyloc(who) = 0: navysize(who) = 0: GOSUB box2"],
    # navy, CASE 3 (sail): no ship types; the menu city is u73a's when set.
    (1578, 1578): [],
    (1583, 1583): ["\tFOR i = 1 TO cities: IF matrix(i, 7) > 90 AND navyloc(who) <> i THEN size = size + 1: mtx$(size) = city$(i): array(size) = i"],
    (1597, 1597): ["\tcolour = 3: tlx = 67: tly = 6"],
    (1599, 1600): [
        "\tCALL menu(0): IF choose < 1 THEN EXIT SUB",
        "admiral:",
        "\tIF u73a > 0 THEN choose = 1: array(choose) = u73a",
    ],
    (1608, 1608): ["\tIF navyloc(who) <= cities THEN"],
    (1622, 1622): ["\t\tCALL shipicon(who)"],
    (1624, 1635): ["\tCALL schooner", "\tTICK 2 * turbo!"],
    # navy, CASE 4 (raid).
    (1643, 1643): [],
    (1645, 1645): ["\tIF navysize(who) < 1 OR (who = side AND who = commerce) GOTO ahoy"],
    (1654, 1654): ["\t\tCALL shipicon(who)"],
    (1656, 1667): ["\tCALL schooner", "\tTICK 2 * turbo!"],
    # navy, CASE 5 (invasion): the new army belongs to a nation.
    (1680, 1680): [
        "\tm = who: IF who = 2 THEN m = 3",
        "\tc = navyloc(who): CALL newarmy((who), empty, c, m)",
    ],
    # navy: the naval battle and the subroutines, as Wars of Napoleon has them.
    (1696, 1843): Path("new_navy_battle.txt").read_text().splitlines(),
    (1505, 1506): [
        "\tIF choose < 1 GOTO ahoy",
        "\tnavyloc(who) = array(choose)",
        "\tIF u73a > 0 THEN navyloc(who) = u73a",
    ],
}
# Civil War Strategy's CWSTRAT2.BAS, 0-based, for lines reused as they are.
CWS2 = Path("cws-orig/CWSTRAT2.BAS").read_text(encoding="latin1").splitlines()
REPLACE_CWS2_REPORT = {
    # report: a second argument picks the page directly.
    (767, 778): [
        "DIM summ(cities)",
        "IF who > 100 GOTO batrep",
        "IF mode <> 0 THEN choose = mode: GOTO pick",
        'mtx$(0) = "Information"',
        'mtx$(1) = force$(side) + " Armies"',
        'mtx$(2) = force$(3 - side) + " Armies"',
        'mtx$(3) = "Cities"',
        'mtx$(4) = "Force Summary"',
        'mtx$(5) = "Intelligence"',
        'mtx$(6) = "Battles": size = 6',
        'IF history > 0 AND LEN(DIR$("nws.his")) > 0 THEN mtx$(7) = "Recap": size = 7',
        "tlx = 64: tly = 6",
        "CALL menu(0)",
        "pick:",
    ],
    (782, 782): ["\tCALL europe"],
    (806, 807): [
        "\ty = (victory(who) / x) * 100",
        '\tPRINT "("; LTRIM$(RTRIM$(STR$(y))); " %)"',
    ],
    (810, 813): [
        'COLOR c: PRINT control(who); "/"; cities; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(control(who) * 2.5 + .5): PRINT x; "%)";',
        'PRINT TAB(50); : COLOR 12: PRINT "Objective: "; city$(capcity(who))',
        "y = income(who) + income(3 - who)",
    ],
    (809, 809): [],
    (871, 871): ["CALL europe"],
    (878, 878): ["\tw = 10: IF armysize(k) < 1000 THEN w = 9"],
    (882, 882): ["\tLOCATE y + j, x: PRINT SPACE$(w);"],
    (888, 888): ["\tLINE (8 * (x - 1) - 1, 16 * (y - 1) - 1)-(8 * (x + w - 1) + 1, 16 * (y + 3) + 1), 15, B"],
    (897, 897): ["FOR k = 1 TO cities"],
    (899, 899): ["\t\tFOR j = 1 TO 50"],
    (905, 906): ["CLS : CALL europe", "FOR k = 1 TO cities"],
    (908, 908): ["\tc = 9: IF cityp(k) <> 1 THEN c = 7"],
    (910, 910): ["\tLOCATE INT(cityy(k) / 16 + 1), cityx(k) / 8: PRINT LTRIM$(RTRIM$(STR$(summ(k))))"],
    # report: the city page, 60 lines high, with the nations' attitudes.
    (846, 865): [
        "CLS : LOCATE 1, 1: COLOR 14: WIDTH , 60",
        'PRINT "City Report"; TAB(20); month$(month); ","; year: COLOR 15',
        'PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"',
        "FOR i = 1 TO 34: COLOR 7: a$ = u836$(cityo(i)): IF cityp(i) = 1 THEN COLOR 9: a$ = \"French\"",
        'IF cityp(i) = 2 THEN COLOR 4: a$ = "Allies"',
        'IF cityp(i) < 1 OR cityp(i) > 2 THEN IF cityo(i) > 1 AND cityo(i) < 7 THEN COLOR 2: a$ = "(peace)": n = n + 1',
        "LOCATE 2 + i, 1: PRINT i; TAB(6); city$(i); TAB(17); a$; TAB(33); cityv(i)",
        "NEXT i",
        "",
        "FOR i = 35 TO cities: COLOR 7: a$ = u836$(cityo(i)): IF cityp(i) = 1 THEN COLOR 9: a$ = \"French\"",
        'IF cityp(i) = 2 THEN COLOR 4: a$ = "Allies"',
        'IF cityp(i) < 1 OR cityp(i) > 2 THEN IF cityo(i) > 1 AND cityo(i) < 7 THEN COLOR 2: a$ = "(peace)": n = n + 1',
        "LOCATE -32 + i, 41: PRINT i; TAB(46); city$(i); TAB(57); a$; TAB(71); cityv(i)",
        "NEXT i",
        "LINE (1, 15)-(630, 15), 15",
        "LINE (1, 300)-(639, 300), 15",
        'COLOR 9: LOCATE 40, 1: PRINT "Side    No. Cities   Income    Cash"',
        "COLOR 9: PRINT force$(1); TAB(12); control(1); TAB(23); income(1); TAB(32); cash(1)",
        "COLOR 4: PRINT force$(2); TAB(12); control(2); TAB(23); income(2); TAB(32); cash(2)",
        'COLOR 2: PRINT "peace"; TAB(12); n',
        "COLOR 7: PRINT force$(0); TAB(12); cities - control(1) - control(2) - n",
        "LINE (1, 370)-(320, 370), 15",
        "LINE (320, 300)-(638, 420), 13, B",
        "FOR k = 1 TO 10",
        "\tLOCATE k + 40, 50: COLOR 15: PRINT u836$(k); TAB(65);",
        "\tSELECT CASE u892(k)",
        '\t\tCASE IS < 25: a$ = "PEACE": COLOR 2',
        '\t\tCASE IS <= 50: a$ = "UNEASE": COLOR 14',
        '\t\tCASE ELSE: a$ = "WAR!": COLOR 4',
        "\tEND SELECT",
        "\tPRINT a$;",
        "NEXT k",
        "CALL TICK(99)",
        "WIDTH , 30",
        "GOTO redraw",
    ],
    # report: the battle summary names both sides; no armyxy pictures.
    (918, 937): [
        "batrep:",
        "CALL clrbot",
        "VIEW (200, 123)-(400, 284)",
        "CLS 1",
        "VIEW",
        "LINE (200, 123)-(400, 284), 15, B",
        "COLOR 14",
        'LOCATE 9, 32: PRINT "BATTLE SUMMARY"',
        "LINE (200, 176)-(400, 230), 15, B",
        "LINE (200, 230)-(400, 284), 15, B",
        "LINE (290, 176)-(345, 284), 15, B",
        'COLOR 9: LOCATE 11, 38: PRINT force$(1); " "; : COLOR 4: PRINT force$(2)',
        "COLOR 14",
        'LOCATE 13, 27: PRINT "BATTLES"',
        'LOCATE 14, 27: PRINT "WON"',
        'LOCATE 16, 27: PRINT "MEN LOST"',
        'LOCATE 17, 27: PRINT "(1000\'s)"',
        "COLOR 9: LOCATE 14, 38: PRINT batwon(1)",
        "COLOR 4: LOCATE 14, 45: PRINT batwon(2)",
        "COLOR 9: LOCATE 17, 38: PRINT INT(.1 * casualty&(1))",
        "COLOR 4: LOCATE 17, 45: PRINT INT(.1 * casualty&(2))",
    ],
    (953, 953): ['OPEN "I", 2, "nws.his"'],
    (967, 968): [
        'COLOR 14: LOCATE 29, 29: PRINT "press a key";: CALL TICK(99)',
        "redraw:",
    ],
    (816, 816): ["z = 0: x = 0: FOR i = star TO fin"],
    (827, 838): [
        "NEXT i",
        "CALL starfin(star, fin, 3 - who)",
        "FOR i = star TO fin",
        "IF armyloc(i) > 0 AND ((who = 1 AND i > 25) OR (who = 2 AND i < 26)) THEN z = z + armysize(i)",
        "NEXT i",
        CWS2[827],
        'PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(z)); "00 ]"',
        CWS2[829],
        'PRINT " "; force$(who); " NAVY has "; navysize(who); " ship(s) ";',
        'IF navyloc(who) > 0 AND navyloc(who) < 99 THEN PRINT "in "; city$(navyloc(who)) ELSE PRINT',
        CWS2[829],
    ],
}
REPLACE_CWS2_VICTOR = {
    # victor: the end of the game, as Wars of Napoleon has it.
    (1817, 1876): [
        "\t\tCASE 5",
        '\t\ta$ = "OBJECTIVE CAPTURED"',
        "\t\tCASE 6",
        '\t\ta$ = STR$(vicflag(6)) + ":1 ARMY STRENGTH RATIO"',
        "\t\tCASE 7",
        '\t\ta$ = "HOSTILITIES ENDED"',
        "\t\tCASE 8",
        '\t\ta$ = "NAPOLEON UTTERLY DEFEATED"',
        "END SELECT",
        "\tCLS",
        "\tc = 1: IF i = 2 THEN c = 7",
        "\tLINE (0, 0)-(639, 479), 4, BF",
        "\tLINE (0, 40)-(550, 460), 0, BF",
        "\tCALL europe",
        "\tLINE (70, 140)-(485, 265), 0, BF",
        "\tLINE (50, 120)-(465, 250), c, BF",
        "\tLINE (50, 120)-(465, 250), 4, B",
        "\tCOLOR 14",
        '\tt$ = force$(i) + " SIDE IS WINNING"',
        '\tCALL center(10, force$(i) + " SIDE IS WINNING WITH" + STR$(victory(i)) + " VP\'s")',
        "",
        "\tCOLOR 15",
        '\tt$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"',
        "\tCALL center(12, t$)",
        "\tCALL center(14, a$)",
        "",
        '\tmtx$(0) = "End Game"',
        '\tmtx$(1) = "Yes"',
        '\tmtx$(2) = "No-Override"',
        "\tsize = 2: colour = 4",
        "\ttlx = 27: tly = 18",
        "\thilite = 15",
        "\tIF j = 7 THEN size = 1",
        "\tCALL menu(0)",
        "",
        "\tIF choose <> 1 THEN",
        "\t\tvictory(3 - side) = victory(3 - side) + 300",
        "\t\tvicflag(j) = -1",
        "\t\tCALL europe",
        "\t\tCALL calendar",
        "\t\tEXIT SUB",
        "\tEND IF",
        "\tIF j = 7 THEN victory(i) = victory(i) + 100",
        "",
        "\tthrill = i",
        "\tCALL europe: CALL report(100 + side, 0)",
        '\tCOLOR 15: LOCATE 2, 27: t$ = force$(i) + " VICTORY  VP\'s=" + STR$(victory(i)): PRINT t$',
    ],
}
REPLACE = {"cws1": {
    # smarts: the computer's turn, as Wars of Napoleon has it.
    (2170, 2170): ["CALL events", "nflag = 0"],
    (2173, 2174): [
        "CALL clrbot",
        'COLOR c: PRINT force$(who); " Side is making decisions";',
        "IF who = 1 AND armyloc(1) = 16 THEN u73a = armyloc(1) ELSE u73a = 0",
    ],
    (2185, 2185): ["IF cost > cash(who) GOTO signup", "IF RND > .3 GOTO signup"],
    (2265, 2265): [],
    (2272, 2272): [
        "x = armysize(i): IF supply(i) < 1 AND RND > .1 GOTO deadman",
        "a = u558(i): IF u892(a) <= 50 GOTO deadman",
    ],
    (2292, 2293): [
        "\tIF i > 1 THEN IF cityp(armymove(i)) = who THEN y = occupied(armymove(i)): IF y > 0 THEN IF armymove(y) = x THEN armymove(i) = 0: GOTO deadman",
        "\tIF side = 1 AND capcity(2) = 42 THEN IF cityx(armyloc(1)) > 440 AND cityx(armyloc(i)) > 500 AND cityx(armymove(i)) < 500 THEN armymove(i) = 0: GOTO deadman",
        "\tm = armymove(i)",
        "\tIF matrix(target, 7) < 90 GOTO noboat",
        "\tIF matrix(m, 7) < 90 GOTO noboat",
        "\t\tIF navyloc(who) <> target OR navyloc(3 - who) = m THEN",
        "\t\t\tz = 0",
        "\t\t\tFOR k = 1 TO 4: IF u2a0(k) = target OR u2a0(k) = m THEN z = 1: EXIT FOR",
        "\t\t\tNEXT k",
        "\t\t\tIF i <> 0 THEN",
        "\t\t\t\tIF navyloc(3 - who) = m THEN u7ca = m ELSE u7ca = target",
        "\t\t\t\tarmymove(i) = 0",
        "\t\t\t\tGOTO deadman",
        "\t\t\tEND IF",
        "\t\tEND IF",
        "noboat:",
    ],
    (2209, 2210): [
        "\tCALL showcities",
        "\tIF who = 2 AND navysize(2) < 1 AND RND > .5 AND cash(2) < 222 GOTO signup",
    ],
    (2216, 2216): ["IF who = 2 AND navysize(2) < 1 AND cash(2) > 100 THEN CALL navy(2, 1): nflag = 1: IF cash(who) < 100 GOTO isok"],
    (2226, 2255): [
        "dock:",
        "\tIF who = 1 AND u73a > 0 THEN",
        "\t\tIF navysize(who) > 0 AND u73a = 0 THEN",
        "\t\t\tCALL navy(who, 1): nflag = 1",
        "\t\tELSE",
        "\t\t\tCALL navy(who, 3): nflag = 1",
        "\t\tEND IF",
        "\tEND IF",
        "\tIF navyloc(who) = 99 THEN",
        "\t\tIF RND < .9 THEN CALL navy(who, 3): nflag = 1",
        "\t\tGOTO movearmy",
        "\tEND IF",
        "\tIF cash(who) >= 100 AND navysize(who) <= 9 AND cityp(navyloc(who)) = who AND u73a = 0 THEN CALL navy(who, 1): nflag = 1",
        "movenavy:",
        "\tIF navysize(who) = 0 THEN navyloc(who) = 0",
        "\tIF navyloc(who) = 0 GOTO movearmy",
        "\tIF u7ca > 0 THEN CALL navy(who, 3): nflag = 1: GOTO movearmy",
        "\tIF navyloc(who) <> 99 THEN",
        "\t\tIF cityp(navyloc(who)) = who THEN CALL navy(who, 3): nflag = 1: GOTO movearmy",
        "\t\tIF cityp(navyloc(who)) = 0 THEN CALL navy(who, 3): nflag = 1: GOTO movearmy",
        "\tELSE",
        "\t\tIF RND < .5 THEN CALL navy(who, 3): nflag = 1",
        "\t\tGOTO movearmy",
        "\tEND IF",
        "\tIF cityp(navyloc(who)) <> who THEN",
        "\t\tIF occupied(navyloc(who)) = 0 OR RND > .3 THEN",
        "\t\t\tCALL navy(who, 2): nflag = 1",
        "\t\tELSE",
        "\t\t\tCALL navy(who, 3): nflag = 1",
        "\t\tEND IF",
        "\tEND IF",
    ],

    # iterate: an army with no friendly city next to it loses half its supply.
    (1364, 1364): [
        "y = armyloc(i)",
        "FOR j = 1 TO 6: IF matrix(y, j) > 0 AND cityp(matrix(y, j)) = s THEN GOTO supplied",
        "NEXT j",
        "supply(i) = .5 * supply(i) - 1",
        "supplied:",
        "COLOR 13",
    ],
    (1375, 1375): [],
    (1379, 1379): [
        "IF side = 1 AND y > 0 THEN aggress! = x / y ELSE IF side = 1 THEN aggress! = 1",
        "CALL enter(-1)",
        "CALL disband",
    ],
    # shipicon has one parameter in Wars of Napoleon.
    (1510, 1510): ["	PSET (400, 465), 0: CALL shipicon(who)"],
    (1517, 1517): ["	PSET (400, 465), 0: CALL shipicon(who)"],
    (2140, 2140): ["CALL shipicon(who)"],
    (2592, 2592): ["		PSET (500, 465), 0: CALL shipicon(commerce)"],
}, "cws2": {
    # evaluate: the computer's move scores, as Wars of Napoleon has them.
    (323, 409): Path("new_evaluate.txt").read_text().splitlines(),
    # capture: rewritten for Wars of Napoleon (nations, their reaction, music by nation).
    (188, 207): [
        "SUB capture (active, c, s, flag)",
        "\tcityp(c) = s: o = cityo(c)",
        '\ta$ = armyname$(active) + " has captured " + city$(c)',
        "\tCALL clrbot",
        "\tCOLOR 11: PRINT a$;",
        "\tIF (s = 1 AND o <> 1) OR (s = 2 AND (o = 1 OR o > 6)) THEN",
        "\t\tIF u892(o) <= 50 THEN",
        "\t\t\tu892(o) = 75",
        '\t\t\tCALL image2(u836$(o) + " has been invaded!", 4)',
        "\t\tEND IF",
        "\tEND IF",
        "\tIF o > 1 AND o < 7 THEN",
        "\t\tFOR i = 1 TO cities",
        "\t\t\tIF cityo(i) = o AND occupied(i) = 0 AND cityp(i) = 0 THEN",
        "\t\t\t\tcityp(i) = cityo(i)",
        "\t\t\t\tCALL cityicon(i)",
        "\t\t\tEND IF",
        "\t\tNEXT i",
        "\tEND IF",
        "\tIF side = 1 AND active < 26 AND noise > 1 THEN",
        '\t\tPLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."',
        "\tEND IF",
        "\tIF side = 2 AND active > 25 AND noise > 1 THEN",
        "\t\tSELECT CASE u558(active)",
        '\t\t\tCASE 2: PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"',
        '\t\t\tCASE 3: PLAY "MLmFt180o2MNc4c4MLd4o1b4.o2c8d4MN"',
        '\t\t\tCASE 4: PLAY "mFT170o3c4.d-8c4o2b-4a-4g4f2MN"',
        '\t\t\tCASE 5: PLAY "mFMSt160o1a8.e16a8o2c4.o1a4."',
        '\t\t\tCASE ELSE: PLAY "MFT220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"',
        "\t\tEND SELECT",
        "\tEND IF",
        "\tCALL flashcity(c)",
        "\tCALL clrbot",
        "\tvictory(s) = victory(s) + cityv(c)",
        "\tIF c = capcity(3 - s) THEN",
        "\t\tvictory(s) = victory(s) + 100",
        "\t\tvictory(3 - s) = victory(3 - s) - 100",
        "\t\tIF victory(3 - s) < 0 THEN victory(3 - s) = 0",
        '\t\ta$ = force$(3 - s) + " OBJECTIVE captured !"',
        "\t\tCALL scribe(a$, 1)",
        '\t\tCALL image2(city$(capcity(3 - s)) + " has fallen!", 4)',
        "\t\tcapcity(3 - s) = 0",
        "\t\tCALL bunting",
        "\tEND IF",
        "\tIF fort(c) > 0 AND flag > 0 THEN fort(c) = fort(c) - 1: x = cityx(c): y = cityy(c): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF: CALL showcities",
        "END SUB",
    ],
    # shipicon: always the wooden ship, with a French or British flag.
    (1140, 1171): [
        "SUB shipicon (who)",
        "	x = POINT(0) - 10: y = POINT(1) - 10",
        "	CIRCLE (x, y), 18, 9, , , .4",
        "	PAINT (x + 3, y + 4), 9, 9",
        "	CIRCLE (x, y), 18, 10, , , .4",
        '	DRAW "BF5R5D1C4L20C0H1R22E1L9": DRAW "BL6": DRAW "C0L10H1L1H2": DRAW "BR9D2"',
        '	DRAW "C0U9": DRAW "BR13": DRAW "C0D9BU7R3"',
        '	DRAW "C0L7BL5C0L7BD3BL2BD1BL1BD1C0R11BR3": DRAW "C0R10BL12"',
        "	PSET (x + 8, y - 1)",
        "	GOSUB jack",
        "EXIT SUB",
        "jack:",
        "	SELECT CASE who",
        "	CASE 1",
        '	DRAW "C1U4R1D4R1C15U4R1D4R1C4U4R1D4"',
        "	CASE 2",
        "	LINE (x + 8, y - 1)-(x + 13, y - 5), 1, BF",
        "	PSET (x + 8, y - 1), 1",
        '	DRAW "BU2C4R5BD2Bl2U4"',
        "	END SELECT",
        "	RETURN",
        "END SUB",
    ],
    # stax: a grey disc with the number of armies in the city.
    (1199, 1200): [
        "	x = cityx(target) - 14: y = cityy(target) - 11",
        "	k = 0",
        "	FOR j = star TO fin",
        "		IF armysize(j) > 0 AND armyloc(j) = target THEN k = k + 1",
        "	NEXT j",
        "	IF k > 1 THEN",
        "		CIRCLE (x + 1, y - 2), 3, 8",
        "		PAINT (x, y), 8, 8",
        "		PSET (x, y), 15",
        '		DRAW "C14S4" + font$(k + 27)',
        "	END IF",
    ],
    # clrrite: paint the right panel instead of VIEW and CLS 1.
    (244, 246): ["LINE (528, 60)-(638, 435), 2, BF"],
    # endit: shares of cities out of `cities`, not 40.
    (271, 272): [
        '	a$ = STR$(ABS(INT(vicflag(3) / cities * 100))) + "% Cities"',
        '	t$ = STR$(ABS(vicflag(4))) + "% Total Income"',
    ],
    # relieve: the menu holds the army's city; no sorting; no clrrite.
    (722, 722): ["	array(size) = armyloc(i)"],
    (727, 727): [],
    (733, 733): ["x = array(choose): index = occupied(x)"],
    (730, 730): ["CALL menu(2)"],
    (748, 748): [],
    (753, 753): ["CALL menu(0)"],
    # retreat: the menu is sorted no more, and is shown with switch 2.
    (1005, 1007): ["	CALL menu(2)"],
    # roman: the French and the Allies; a number over 20 goes round again.
    (1013, 1015): [
        'a$ = "French ": IF target > 25 THEN a$ = "Allies "',
        "IF target > 25 THEN target = target - 25",
        'tens: IF target > 10 THEN a$ = a$ + "X": target = target - 10',
    ],
    (1028, 1028): ['	a$ = a$ + "X"', "	CASE IS > 10", "	GOTO tens"],
    # resupply: no realism switch; the supply line is always checked.
    (977, 977): [], (980, 980): [],
    # image2: the message box is at row 22; a long message is cut and measured again.
    (599, 603): [
        "fit: mtx$(1) = a$",
        "tlx = 32 - LEN(a$) \\ 2",
        "tly = 22: size = 1",
        "CALL mxw(wide)",
        "IF wide > 58 THEN wide = 58: a$ = LEFT$(a$, 58): GOTO fit",
    ],
}}


def apply(key, lines):
    lines = list(lines)
    for n, old, new in EDITS[key]:
        if old not in lines[n - 1]:
            raise SystemExit(f"{key} line {n}: {old!r} not in {lines[n - 1]!r}")
        lines[n - 1] = lines[n - 1].replace(old, new, 1)
    ops = [(n, "insert", v) for n, v in INSERT_AFTER[key].items()]
    ops += [(a, "replace", (b, v)) for (a, b), v in REPLACE[key].items()]
    if key == "cws2":
        ops += [(a, "replace", (b, v)) for (a, b), v in REPLACE_CWS2_VICTOR.items()]
        ops += [(a, "replace", (b, v)) for (a, b), v in REPLACE_CWS2_REPORT.items()]
    if key == "cws1":
        ops += [(a, "replace", (b, v)) for (a, b), v in REPLACE_CWS1_NAVY.items()]
    for n, kind, v in sorted(ops, key=lambda t: -t[0]):
        if kind == "insert":
            lines[n:n] = v
        else:
            last, new = v
            lines[n - 1 : last] = new
    return lines
