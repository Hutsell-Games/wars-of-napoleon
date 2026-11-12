"""Write new/filer.bas: WON's filer, from the disassembly of WON.05 and
Civil War Strategy's filer."""
from pathlib import Path

CHECK = "\xfb"  # CP437 check mark, appended to saved-game names that exist

text = f'''SUB filer (switch)
SELECT CASE switch
	CASE -1
	OPEN "I", 1, "gamedata.ini"
	FOR i = 0 TO 2: INPUT #1, force$(i): NEXT i
	FOR i = 1 TO 12: INPUT #1, u836$(i): NEXT i
	FOR i = 1 TO 12: INPUT #1, month$(i): NEXT i
	INPUT #1, ATKFAC, DEFAC, TCR
	FOR i = 1 TO 19: INPUT #1, mtnx(i), mtny(i): NEXT i
	FOR k = 1 TO 36: INPUT #1, font$(k): NEXT k
	FOR k = 1 TO 4: INPUT #1, u2a0(k): NEXT k
	CLOSE #1
	OPEN "I", 1, "nws.cfg"
	INPUT #1, side, noise, difficult, bold, player, turbo!, randbal, history, u8c0
	CLOSE #1
	EXIT SUB

	CASE 1
	GOSUB lead
	f$ = "nws" + u29c$ + ".ini"
	OPEN "I", 1, f$
	INPUT #1, month, year
'               set end game conditions
	FOR i = 1 TO 6: INPUT #1, vicflag(i): NEXT i
	vicflag(3) = .67 * vicflag(3)
	INPUT #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: INPUT #1, u892(k): NEXT k
	INPUT #1, a             ' number of French armies
FOR i = 1 TO a
	INPUT #1, u558(i), armyloc(i), armysize(i), armyexper(i), supply(i): occupied(armyloc(i)) = i: armyname$(i) = lname$(i): armylead(i) = rating(i): lname$(i) = ""
NEXT i
	INPUT #1, a             ' number of Allied armies
FOR i = 26 TO 25 + a
	INPUT #1, u558(i), armyloc(i), armysize(i), armyexper(i), supply(i)
	occupied(armyloc(i)) = i: armyname$(i) = lname$(i): lname$(i) = "": armylead(i) = rating(i): lname$(i) = ""
NEXT i
FOR i = 1 TO 2: INPUT #1, cash(i): NEXT i
	INPUT #1, navysize(1), navyloc(1)
	INPUT #1, navysize(2), navyloc(2)
	INPUT #1, capcity(1), capcity(2)
	CLOSE #1

	CASE 2
	IF LEN(DIR$("*.sav")) = 0 THEN choose = -1: EXIT SUB
	mtx$(0) = "Load"
	size = 0
	FOR k = 1 TO 9
		t$ = "nws" + LTRIM$(STR$(k)) + ".sav"
		IF LEN(DIR$(t$)) > 0 THEN
			size = size + 1: mtx$(size) = t$: array(size) = k
		END IF
	NEXT k
	tlx = 67: tly = 14 - .5 * size
	CALL menu(0)
	IF choose < 1 THEN EXIT SUB
	z = 0
reopen:
	OPEN "I", 1, "nws" + LTRIM$(STR$(array(choose))) + ".sav"
	COLOR 11: CALL clrbot: PRINT "Loading";
	INPUT #1, u29c$, month, year, usadv, a
	IF z = 0 THEN CLOSE #1: GOSUB lead: z = 1: GOTO reopen
	FOR i = 1 TO 6: INPUT #1, vicflag(i): NEXT i
	INPUT #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: INPUT #1, u892(k): NEXT k
	FOR i = 1 TO 50: INPUT #1, armyname$(i), u558(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	IF armyloc(i) > 0 THEN
		IF armyname$(i) = lname$(i) THEN
			lname$(i) = ""
		ELSE
			who = 1: IF i > 25 THEN who = 2
			CALL starfin(star, fin, who)
			FOR k = star TO fin
			IF armyname$(i) = lname$(k) THEN lname$(k) = "": EXIT FOR
			NEXT k
		END IF
	END IF
	NEXT i
	FOR i = 1 TO cities: INPUT #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: INPUT #1, cash(i), control(i), income(i), victory(i), capcity(i)
	INPUT #1, navysize(i), navyloc(i), navymove(i), commerce
	NEXT i

	CLOSE #1
	u73a = 0: IF player = 1 AND side = 2 AND armyloc(1) = 16 THEN u73a = armyloc(1)
	IF switch = 9 THEN EXIT SUB
	OPEN "I", 1, "nws.cfg"
	INPUT #1, myside, noise, difficult, bold, player, turbo!, randbal, history, u8c0
	CLOSE #1
	IF player = 1 AND side = 2 AND armyloc(1) = 16 THEN u73a = armyloc(1)
	SCREEN 12: CLS
	CLOSE #1: CALL europe: CALL clrbot
	side = a
	CALL calendar

	CASE 3
	mtx$(0) = "Save Game"
	FOR k = 1 TO 8
	mtx$(k) = "nws" + LTRIM$(STR$(k)) + ".sav"
	IF LEN(DIR$(mtx$(k))) > 0 THEN mtx$(k) = mtx$(k) + " {CHECK}"
	NEXT k
	tlx = 67: size = 8
	CALL menu(0)
	IF choose < 1 THEN EXIT SUB
	COLOR 11: CALL clrbot: PRINT "Saving";
savit:
	OPEN "O", 1, "nws" + LTRIM$(STR$(choose)) + ".sav"
	WRITE #1, u29c$, month, year, usadv, side
	FOR i = 1 TO 6: WRITE #1, vicflag(i): NEXT i
	WRITE #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: WRITE #1, u892(k): NEXT k
	FOR i = 1 TO 50: WRITE #1, armyname$(i), u558(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	NEXT i
	FOR i = 1 TO cities: WRITE #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: WRITE #1, cash(i), control(i), income(i), victory(i), capcity(i)
	WRITE #1, navysize(i), navyloc(i), navymove(i), commerce
	NEXT i
	CLOSE #1

	myside = side
	IF myside < 1 OR myside > 2 THEN myside = 1
	OPEN "O", 1, "nws.cfg"
	WRITE #1, myside, noise, difficult, bold, player, turbo!, randbal, history, u8c0, bold
	CLOSE #1
	CLS : CALL europe

	CASE 9
	choose = 9: GOTO savit
END SELECT
EXIT SUB

lead:
	OPEN "I", 1, "lead" + u29c$ + ".dat"
	FOR i = 1 TO 25: INPUT #1, lname$(i), rating(i): u1da4(i) = 1: NEXT i
	FOR i = 26 TO 50: INPUT #1, u1da4(i), lname$(i), rating(i): NEXT i
	CLOSE #1
	OPEN "I", 1, "euro" + u29c$ + ".map"
	FOR i = 1 TO cities
		INPUT #1, a, city$(i), cityx(i), cityy(i), cityo(i), cityv(i)
		vptotal = vptotal + cityv(i)
		a = cityo(i): IF cityo(i) > 1 THEN a = 2
		cityp(i) = a
		CALL occupy(i)
		IF occupied(i) > 0 THEN IF occupied(i) < 25 THEN cityp(i) = 1 ELSE cityp(i) = 2
		FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j
		INPUT #1, fort(i)
	NEXT i
	CLOSE #1
	RETURN
END SUB
'''
Path("new/filer.bas").write_bytes(text.encode("latin1"))
print("new/filer.bas written")
