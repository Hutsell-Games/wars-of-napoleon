DEFINT A-Z
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB center (y%, a$)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB image2 (a$, s%)
DECLARE SUB maptext ()
DECLARE SUB mountain (xx%, yy%)
DECLARE SUB mxw (wide%)
DECLARE SUB roman (target%, a$)
DECLARE SUB stax (who%)
' $INCLUDE: 'won.bi'

SUB barnacle (who)
navysize(who) = navysize(who) - 1
IF navysize(who) < 1 THEN navyloc(who) = 0
END SUB

SUB bossarmy
FOR i = 1 TO cities
	IF occupied(i) > 0 THEN
		s = 1: IF occupied(i) > 25 THEN s = 2
		CALL starfin(a, b, s)
		FOR k = a TO b
			IF armysize(k) > 0 THEN
				IF armyloc(k) = i THEN
					IF armysize(k) > armysize(occupied(i)) THEN occupied(i) = k
				END IF
			END IF
		NEXT k
	END IF
NEXT i
END SUB

SUB bub2 (limit)
DO
	swaps% = FALSE
	FOR i = 1 TO limit - 1
	IF brray(i) > brray(i + 1) THEN
		SWAP brray(i), brray(i + 1)
		swaps% = i
	END IF
	NEXT i
LOOP WHILE swaps%
END SUB

SUB bubble (limit)
DO
	swaps% = FALSE
	FOR i = 1 TO limit - 1
	IF mtx$(i) > mtx$(i + 1) THEN
		SWAP mtx$(i), mtx$(i + 1)
		SWAP array(i), array(i + 1)
		swaps% = i
	END IF
	NEXT i
LOOP WHILE swaps%
END SUB

SUB BuffClear
DEF SEG = 0
POKE 1050, 30: POKE 1052, 30
END SUB

SUB bunting
SCREEN 12
LINE (530, 100)-(638, 380), 2, BF
LINE (535, 280)-(638, 380), 7, BF
LINE (535, 100)-(638, 279), 8, BF
LINE (535, 100)-(639, 380), 4, B
PSET (580, 200)
DRAW "S7C14E3U2E4U4E3H5E3H6D5"
DRAW "G3F4G4F1G1H7E1H2E3H2E4H3E3H2G5F1G3D1G3D3G2D1F2G2H3U1H2E2H3G3D7F3D5F10R14U2"
PAINT (570, 190), 4, 14
LINE (540, 200)-(630, 300), 7, BF
LINE (540, 200)-(630, 300), 0, B
d = 0
FOR i = 180 TO 200: d = d + 1: LINE (580 - d, i)-(590 + d, i), 7: NEXT i
FOR i = 1 TO 10: LINE (540 + 8 * i, 230)-(544 + 8 * i, 280), 0, BF: NEXT i
LINE (540, 250)-(630, 260), 7, BF
LINE (536, 202)-(540, 298), 0, BF
LINE (578, 181)-(569, 200), 0
LINE -(558, 200), 0
LINE -(578, 181), 0
PAINT (572, 190), 0
LINE (540, 280)-(630, 282), 0, B
FOR i = 1 TO 5: LINE (570, 280 + 4 * i)-(600, 280 + 4 * i), 0, B: NEXT i
LINE (566, 280)-(569, 300), 0, BF
LINE (601, 280)-(602, 300), 0, B
DRAW "S4BG80BE102BU81C14E3U2E4U4E3H5E3H6D5"
DRAW "G3F4G4F1G1H7E1H2E3H2E4H3E3H2G5F1G3D1G3D3G2D1F2G2H3U1H2E2H3G3D7F3D5F10R13BH5"
x = POINT(0): y = POINT(1)
PAINT (x, y), 4, 14
DRAW "BD2BL17BH12BE2BU4BD1BL3C15H2E3H3L2H2L3H1E3H5L4"
DRAW "H2U2H3L3G5H2U2H2U3H3G1L5U4H3G1L2U4H3L2D54F2R4E2F3R2E4F5R2E2F1D1G2D2F1E1"
DRAW "F1E17R8U2BH4BL3BL7"
x = POINT(0): y = POINT(1)
PAINT (x, y), 0, 15
DRAW "C15U1H3G1L1H2L2G2BH5C15U2H2U2H2L1H1U1E2H4L2H1U2H2L2"
DRAW "BG2BD3BG2BD5C15R2F2G1F2E1F3R1D2G2BF5BE13BD69BR1BD1BG1BU1"
DRAW "C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
x = POINT(0): y = POINT(1)
PAINT (x, y), 4, 14
DRAW "BF50C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
x = POINT(0): y = POINT(1)
PAINT (x, y), 4, 14
DRAW "BU45C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
x = POINT(0): y = POINT(1)
PAINT (x, y), 4, 14
LINE (638, 350)-(600, 300), 0
LINE -(568, 300), 0
LINE -(600, 380), 0
LINE -(636, 380), 0
LINE -(638, 350), 0
PAINT (600, 320), 8, 0
CALL tick(turbo!)
END SUB

SUB calendar
LINE (135, 320)-(230, 350), 0, BF
LINE (125, 310)-(220, 340), 3, BF
LINE (125, 310)-(220, 340), 13, B
COLOR 13
LOCATE 21, 18: PRINT UCASE$(LEFT$(month$(month), 3)); ","; RTRIM$(STR$(year))
END SUB

SUB cancel (side)
CALL starfin(star, fin, (side))
counter:
CALL clrrite
	size = 0
	FOR j = star TO fin
	a$ = armyname$(j): IF LEN(a$) > 10 THEN x = INSTR(a$, " "): a$ = RIGHT$(a$, LEN(a$) - x)
	IF armyloc(j) > 0 AND armymove(j) > 0 THEN size = size + 1: mtx$(size) = a$: array(size) = armyloc(j)
	NEXT j
	CALL bubble(size)
	tlx = 67: tly = 2: wtype = 2
	mtx$(0) = "Cancel"
	IF size < 1 THEN CALL clrbot: COLOR 11: PRINT "No units have orders to cancel"; : EXIT SUB
	CALL menu(1)
	SELECT CASE choose
	 CASE 1 TO size
		target = array(choose)
	       
		FOR i = star TO fin
		IF armyloc(i) = target THEN x = INSTR(armyname$(i), mtx$(choose)): IF x > 0 AND armymove(i) > 0 THEN index = i
		NEXT i

		CALL clrbot: COLOR 11: PRINT armyname$(index); " has cancelled move to "; city$(armymove(index)); : CALL TICK(turbo + 1)
		CALL icon(armyloc(index), armymove(index), 4)
		armymove(index) = 0: IF noise > 0 THEN SOUND 2999, .5
		CALL stax(side)
	 CASE ELSE
		GOTO finix
	END SELECT
finix:
	CALL clrrite
END SUB

SUB capture (active, c, s, flag)
	cityp(c) = s: o = cityo(c)
	a$ = armyname$(active) + " has captured " + city$(c)
	CALL clrbot
	COLOR 11: PRINT a$;
	IF (s = 1 AND o <> 1) OR (s = 2 AND (o = 1 OR o > 6)) THEN
		IF u892(o) <= 50 THEN
			u892(o) = 75
			CALL image2(u836$(o) + " has been invaded!", 4)
		END IF
	END IF
	IF o > 1 AND o < 7 THEN
		FOR i = 1 TO cities
			IF cityo(i) = o AND occupied(i) = 0 AND cityp(i) = 0 THEN
				cityp(i) = cityo(i)
				CALL cityicon(i)
			END IF
		NEXT i
	END IF
	IF side = 1 AND active < 26 AND noise > 1 THEN
		PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
	END IF
	IF side = 2 AND active > 25 AND noise > 1 THEN
		SELECT CASE u558(active)
			CASE 2: PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"
			CASE 3: PLAY "MLmFt180o2MNc4c4MLd4o1b4.o2c8d4MN"
			CASE 4: PLAY "mFT170o3c4.d-8c4o2b-4a-4g4f2MN"
			CASE 5: PLAY "mFMSt160o1a8.e16a8o2c4.o1a4."
			CASE ELSE: PLAY "MFT220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
		END SELECT
	END IF
	CALL flashcity(c)
	CALL clrbot
	victory(s) = victory(s) + cityv(c)
	IF c = capcity(3 - s) THEN
		victory(s) = victory(s) + 100
		victory(3 - s) = victory(3 - s) - 100
		IF victory(3 - s) < 0 THEN victory(3 - s) = 0
		a$ = force$(3 - s) + " OBJECTIVE captured !"
		CALL scribe(a$, 1)
		CALL image2(city$(capcity(3 - s)) + " has fallen!", 4)
		capcity(3 - s) = 0
		CALL bunting
	END IF
	IF fort(c) > 0 AND flag > 0 THEN fort(c) = fort(c) - 1: x = cityx(c): y = cityy(c): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF: CALL showcities
END SUB

SUB center (y, a$)
x = LEN(a$)
x = 26 - x \ 2
LOCATE y, 7 + x: PRINT a$
END SUB

SUB cityicon (i)
c = 9: IF cityp(i) > 1 THEN c = 4
IF cityp(i) = 0 THEN c = 7
o = cityo(i)
IF u892(o) <= 50 AND occupied(i) = 0 THEN
	IF cityo(i) > 1 AND cityo(i) < 7 THEN c = 2 ELSE c = 7
	cityp(i) = 0
END IF
x = cityx(i): y = cityy(i)
IF fort(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
IF fort(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
CIRCLE (cityx(i), cityy(i)), 4, 0
CIRCLE (cityx(i), cityy(i)), 3, c
PAINT (cityx(i), cityy(i)), c, c
IF i = capcity(1) OR i = capcity(2) THEN COLOR 14: LINE (x - 4, y)-(x + 4, y): LINE (x, y - 4)-(x, y + 4)
FOR j = 1 TO 6: IF matrix(i, j) > 0 THEN CALL icon(i, matrix(i, j), 11)
NEXT j
END SUB

SUB clrbot
LOCATE 29, 1: PRINT SPACE$(79);
LOCATE 29, 1
END SUB

SUB clrrite
LINE (528, 60)-(638, 435), 2, BF
END SUB

SUB commander (who, empty)
	empty = 0
	CALL starfin(star, fin, who)
	FOR i = star TO fin
	IF armyloc(i) = 0 AND lname$(i) <> "" THEN empty = i: EXIT SUB
	NEXT i

'                 generic leaders if set list is exhausted
	FOR i = star TO fin
	IF armyloc(i) = 0 THEN
		x = i
		CALL roman(x, a$)
		empty = i
		lname$(i) = a$
		rating(i) = 1 + 8 * RND
		EXIT SUB
	END IF
	NEXT i
	CALL clrbot: PRINT "No more "; force$(who); " commanders available"; : CALL TICK(turbo!)
END SUB

SUB cutoff (who, target, a)
a = 0
FOR j = 1 TO 6
y = matrix(target, j)
IF y > 0 AND cityp(y) = who THEN a = a + 1
NEXT j
END SUB

SUB disband
FOR i = 1 TO cities
	IF occupied(i) > 0 THEN
		x = occupied(i)
		IF armysize(x) > 0 AND u892(u558(x)) <= 50 THEN
			s = 1: IF u558(x) > 1 THEN s = 2
			cash(s) = cash(s) + .2 * armysize(x)
			armysize(x) = 0: armyloc(x) = 0
			lname$(x) = armyname$(x)
			CALL image2(u836$(u558(x)) + " " + armyname$(x) + " army has disbanded", 4)
			armyname$(x) = ""
		ELSE
			IF armyloc(x) > 0 THEN CALL placearmy(x)
		END IF
	END IF
NEXT i
END SUB

SUB endit
	a$ = STR$(ABS(INT(vicflag(3) / cities * 100))) + "% Cities"
	t$ = STR$(ABS(vicflag(4))) + "% Total Income"
	mtx$(8) = "Time: " + month$(vicflag(1)) + STR$(ABS(vicflag(2)))
	mtx$(9) = RTRIM$(STR$(ABS(vicflag(6)))) + ":1 Force Ratio"
	COLOR 15: LOCATE 1, 1: PRINT "Press ENTER to toggle ending conditions";
	COLOR 14: PRINT "				ESC when done"
what4:
	FOR i = 2 TO 6: IF vicflag(i) > 0 THEN mtx$(i - 1) = "û " ELSE mtx$(i - 1) = "  "
	NEXT i
	choose = chosit
	mtx$(0) = "Victory Conditions"
	mtx$(1) = mtx$(1) + mtx$(8)
	mtx$(2) = mtx$(2) + a$
	mtx$(3) = mtx$(3) + t$
	mtx$(4) = mtx$(4) + "Objective Captured"
	mtx$(5) = mtx$(5) + mtx$(9)
	mtx$(6) = "DONE"
	wtype = 2: colour = 3: size = 6: hilite = 14
	CALL menu(0)
	chosit = 21 + choose
SELECT CASE choose
	CASE 1
	vicflag(2) = -vicflag(2)
	CASE 2 TO 5
	vicflag(choose + 1) = -vicflag(choose + 1)
	CASE ELSE
	GOTO cheer
END SELECT
	GOTO what4
cheer:
	CLS
	CALL europe
END SUB

SUB enter (who)
FOR k = 3 TO 6
	o = u892(k)
	u892(k) = u892(k) + who
	IF u892(k) > 99 THEN u892(k) = 99
	IF u892(k) < 0 THEN u892(k) = 0
	IF o <= 50 AND u892(k) > 50 THEN
		CALL image2(u836$(k) + " has entered the WAR!", 4)
		FOR i = 1 TO cities
			IF cityo(i) = k AND occupied(i) = 0 AND cityp(i) = 0 THEN
				cityp(i) = k
				CALL cityicon(i)
			END IF
		NEXT i
	END IF
NEXT k
END SUB

SUB evaluate (index, x)
foe = 3 - side
from = armyloc(index)
x = 200: IF aggress! > 1.5 THEN x = 80: IF aggress! > 2 THEN x = 20: IF aggress! > 3 THEN x = 5
CALL void(from, defend): IF defend = 0 THEN x = 0
IF bold > 1 THEN x = .5 * x

best = armysize(index)

FOR j = 1 TO 6: array(j) = -1
a = matrix(from, j): IF a > 0 THEN IF occupied(a) > 0 THEN best = best - armysize(occupied(a)): y = 1
NEXT j: best = .01 * best
IF bold > 0 THEN best = best + 20 * bold

CALL starfin(star, fin, 3 - side)

FOR j = 1 TO 6
	y = -1: a = matrix(from, j): IF a = 0 THEN max = j - 1: GOTO alleval
      
	c = occupied(a)
	FOR k = star TO fin: IF armyloc(k) > 0 THEN IF armymove(k) = a AND c = 0 GOTO alle
	NEXT k
	
	y = best - x * fort(from) - cityv(from) + 30 * RND
	IF vicflag(2) - year < 1 AND vicflag(1) - month < 7 THEN y = y + 50
	IF fort(from) > 0 THEN IF index = occupied(from) AND index > 1 THEN y = y - 15
	IF a = capcity(side) THEN IF vicflag(5) > 0 THEN y = y + 20
	IF cityp(a) <> 3 - side THEN IF index < 26 THEN y = y + 5 * cityv(a) + 10 * fort(a) ELSE y = y - 5 * cityv(a)
	IF index = 1 THEN y = y + 100
	IF cityp(a) <> side GOTO ourn
	   IF c = 0 THEN y = y + 10 * cityv(a): GOTO ourn
	   x1 = 10: IF fort(a) = 1 THEN x1 = 15: IF fort(a) = 3 THEN x1 = 20

	   IF armysize(c) > 0 THEN
		odds! = armysize(index) / (x1 * .1 * armysize(c))
		IF index = 1 THEN y = y + 50
		IF supply(c) < 1 THEN y = y + 20
		IF armyloc(c) = capcity(side) THEN y = y + 25
	   ELSE
		odds! = 5
	   END IF
	   IF odds! > .5 AND a = capcity(side) AND vicflag(5) > 0 THEN y = y + 200

	   IF armysize(index) < 15 THEN y = y - 300: odds! = .1
	   IF bold < 3 AND armysize(index) < 40 AND odds! < .8 THEN y = 0
	   y = y - 15
	   IF odds! < .5 THEN y = y - 200
	   IF bold = 0 AND RND > .9 THEN y = y + 10 * (armylead(index) - armylead(c) + armyexper(index) - armylead(index))
	   IF supply(index) < 1 THEN y = y - 100
	   SELECT CASE odds! + .5 * bold
		CASE IS < .3
		y = -9999
		CASE IS < .5
		y = y - 300
		CASE IS <= .8
		y = y - 20
		CASE .8 TO 1.2
		y = y - 5
		CASE 1.2 TO 1.5
		y = y + 10
		CASE ELSE
		y = y + .5 * (armysize(index) - armysize(c)) + 50 * RND
	   END SELECT
ourn:
	IF cityp(a) = 3 - side AND c > 0 AND armymove(c) = 0 THEN y = y - armysize(c)
	IF side = 1 AND cityy(a) < cityy(from) THEN y = y + 2
	IF side = 2 AND cityy(a) > cityy(from) THEN y = y + 2
	IF (foe = 1 AND cityp(capcity(side)) <> 1) OR (foe = 2 AND cityp(capcity(side)) = 1) THEN
		cx = cityx(capcity(side)): cy = cityy(capcity(side))
	ELSE
		x1 = 0: cx = 0: cy = 0
		CALL starfin(star, fin, side)
		FOR i = star TO fin
			IF armysize(i) > 0 THEN cx = cx + cityx(armyloc(i)): cy = cy + cityy(armyloc(i)): x1 = x1 + 1
		NEXT i
		cx = cx / (x1 + .1): cy = cy / (x1 + .1)
	END IF
	x1 = ABS(cx - cityx(from)) + 1.2 * ABS(cy - cityy(from)) - ABS(cx - cityx(a)) - 1.2 * ABS(cy - cityy(a))
	y = y + 1.2 * x1
'---------------------------------------------------------------------------
	FOR k = 1 TO 6: m = matrix(a, k): IF m = 0 GOTO tally3
	IF cityp(m) = 0 THEN y = y + 3 * cityv(m) + 2 * fort(m)
	IF cityp(m) = side THEN y = y + 3 * cityv(m) + 2 * fort(m)
	IF cityp(m) = side AND c > 0 THEN
		odds! = 5 - 4 * RND
		IF armysize(c) > 0 THEN odds! = armysize(index) / armysize(c) ELSE odds! = 5
		IF odds! < 1 THEN y = y - 2
	END IF
	IF cityp(m) = capcity(side) THEN y = y + 50
tally3:
	NEXT k
'---------------------------------------------------------------------------
	array(j) = y
alle:
NEXT j: max = 6
alleval:
x = 0: best = 0
FOR j = 1 TO max
IF array(j) < 0 GOTO allof
	IF array(j) > x THEN x = array(j): best = j
allof:
NEXT j
	IF defend > armysize(index) AND array(best) < 50 THEN best = 0
	x = best
END SUB

SUB events
'==========================================================================
'                              Special Events
'==========================================================================
IF randbal = 0 THEN EXIT SUB
plus = difficult: IF side = 1 THEN plus = 6 - difficult
pct! = .05 * (difficult - 3) + .1
IF navysize(2) < 10 AND RND > .2 AND year = 1805 AND month = 11 THEN
	CALL clrbot: COLOR 14: PRINT "Nelson has defeated the French fleet at Trafalgar";
	empty = navyloc(2): who = 2: navysize(2) = 10
	GOTO launch
END IF
IF RND > pct! THEN EXIT SUB

CALL image2("SPECIAL EVENT...", 14)
who = 1: IF RND > .1 * randbal THEN who = 2

SELECT CASE who
	CASE 1
	IF RND > .7 GOTO allsides
	IF RND > .5 OR navysize(who) > 9 GOTO mercen
newships:
	IF navysize(who) > 0 AND navyloc(who) <> 99 THEN empty = navyloc(who): GOTO float1
		empty = 0
		FOR i = 1 TO cities
		IF cityp(i) = who AND matrix(i, 7) > 90 AND navyloc(3 - who) <> i THEN empty = i: EXIT FOR
		NEXT i
	IF empty = 0 GOTO mercen
float1:
	IF navyloc(who) = 99 THEN
		CALL scribe(force$(who) + " have windfall tax revenues", 2)
		cash(who) = cash(who) + 100 + 200 * RND
		IF who = 1 THEN GOTO dull1 ELSE GOTO dull2
	END IF
	CALL scribe(force$(who) + " side has built new ships", 2)
	navysize(who) = navysize(who) + plus + 1
launch:
	IF navysize(who) > 10 THEN navysize(who) = 10
	navyloc(who) = empty: CALL ships
	IF who = 1 THEN GOTO dull1 ELSE GOTO dull2
mercen:
	IF RND < .7 GOTO egypt
	CALL scribe("The Emperor rallies new forces to the French side", 2)
	n = 0
	FOR i = 1 TO 25
		IF n > 9 GOTO dull2
		IF armysize(i) > 0 AND RND > .5 THEN armysize(i) = 1.5 * armysize(i) + plus: n = n + 1
	NEXT i
	GOTO dull1
egypt:
	CALL scribe("Treasures from Egypt give France extra income", 2)
	cash(1) = cash(1) + 150 * plus
	GOTO dull1

	CASE 2
	IF RND > .7 GOTO allsides
	IF RND > .5 AND navysize(who) < 9 GOTO newships
	CALL commander((who), empty)
	IF empty > 0 THEN
		FOR k = 1 TO 99
		t = INT(24 * RND) + 2
		IF armyloc(t) > 0 AND armysize(t) > 0 AND armyloc(t) <> capcity(3 - who) THEN
			FOR j = 1 TO 25: IF j <> k AND armyloc(j) = armyloc(t) GOTO nextk
			NEXT j
			CALL image2("Traitor " + armyname$(t) + " has given his army to " + lname$(empty), 4)
			armyloc(empty) = armyloc(t)
			armysize(empty) = armysize(t)
			armyname$(empty) = lname$(empty)
			lname$(empty) = ""
			armylead(empty) = armylead(t)
			armyexper(empty) = armyexper(t)
			supply(empty) = supply(t)
			u558(empty) = u558(t)
			armyloc(t) = 0
			lname$(t) = ""
			armyname$(t) = ""
			armysize(t) = 0: armylead(t) = 0: armyexper(t) = 0: armymove(t) = 0: supply(t) = 0
			cityp(armyloc(empty)) = 2
			CALL cityicon(armyloc(empty))
			CALL placearmy(empty)
			occupied(armyloc(empty)) = empty
			GOTO dull2
		END IF
nextk:
		NEXT k
	END IF
	CALL scribe("Hapsburgs add to Allied war chest", 2)
	cash(1) = cash(1) + 100 * plus
	GOTO dull2
END SELECT
EXIT SUB

allsides:
	c = 0
	FOR k = 1 TO cities
		IF occupied(k) = 0 AND cityp(k) = who THEN
			IF who = 1 THEN
				IF cityo(k) <> who AND RND > .5 THEN c = k: GOTO revolt
			ELSE
				IF (cityo(k) = 1 OR cityo(k) > 6) AND RND > .5 THEN c = k: GOTO revolt
			END IF
		END IF
	NEXT k
	EXIT SUB
revolt:
	CALL image2("The citizens of " + city$(c) + " have revolted!", 4)
	cityp(c) = 0
	CALL flashcity(c)
	IF noise > 0 THEN FOR k = 1 TO 10: SOUND 50 + 500 * RND, .5: NEXT k
	EXIT SUB

dull2:
	IF noise = 2 THEN PLAY "T220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
	CALL tick(9)
	EXIT SUB
dull1:
	IF noise = 2 THEN PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
	CALL tick(9)
END SUB

SUB findcity (c, x, y)
c = 0
FOR i = 1 TO cities
	IF ABS(cityx(i) - x) + ABS(cityy(i) - y) < 13 THEN c = i: EXIT FOR
NEXT i
END SUB

SUB image2 (a$, s)
DIM g2(1 TO 8000)
fit: mtx$(1) = a$
tlx = 32 - LEN(a$) \ 2
tly = 22: size = 1
CALL mxw(wide)
IF wide > 58 THEN wide = 58: a$ = LEFT$(a$, 58): GOTO fit
x = 8 * (tlx + wide)
y = 16 * (tly + 1)
	GET (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 15, 16 * (tly + 3) + 7), g2
	VIEW (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3) + 4)
	CLS 1
	VIEW
	LINE (8 * tlx, 16 * tly - 1)-(8 * (tlx + wide + 1) + 15, 16 * (tly + 3) + 7), 0, BF
	LINE (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3)), s, BF
	LINE (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3)), 15, B
	COLOR 14
	LOCATE tly + 2, tlx + 2: PRINT a$
	CALL TICK(9)
	PUT (8 * tlx - 4, 16 * tly - 3), g2, PSET
END SUB

SUB init
mtx$(0) = "Start Year"
f$ = DIR$("nws*.ini")
colour = 3
GOSUB getlist
CALL clrbot
LOCATE 29, 1: PRINT "Loading "; u29c$
EXIT SUB

getlist:
	size = 0
	IF LEN(f$) = 0 THEN choose = -1: EXIT SUB
	size = size + 1
	mtx$(size) = LTRIM$(MID$(f$, 4, 4))
	array(size) = size
	DO WHILE f$ <> "" AND size < 21
		f$ = DIR$
		f$ = LTRIM$(MID$(f$, 4, 4))
		IF f$ = "" THEN EXIT DO
		size = size + 1
		mtx$(size) = f$
		array(size) = size
	LOOP
	CALL bubble((size))
	tlx = 18: tly = 14 - .5 * size
	CALL menu(11)
	IF choose < 0 THEN choose = -1: EXIT SUB
	u29c$ = mtx$(choose)
	IF LEN(u29c$) < 1 THEN choose = -1: EXIT SUB
	RETURN
END SUB

SUB iterate
'---------------------------------------------------------------------------
FOR i = 1 TO 50: IF armyloc(i) > 0 THEN CALL placearmy(i)
NEXT i
'---------------------------------------------------------------------------
month = month + 2
IF month > 12 THEN month = 1: year = year + 1
'---------------------------------------------------------------------------
s = 1
FOR i = 1 TO 50: IF armyloc(i) < 1 GOTO rip
IF i > 25 THEN s = 2
IF cash(s) >= .2 * armysize(i) THEN
	a = 1: CALL cutoff(s, armyloc(i), a)
	IF a > 0 THEN
		supply(i) = supply(i) + 1
		cash(s) = cash(s) - .2 * armysize(i)
	END IF
END IF
IF (month < 7 OR month > 10) AND matrix(armyloc(i), 7) < 99 THEN supply(i) = supply(i) - 1
IF matrix(armyloc(i), 7) = 99 AND navyloc(3 - s) = armyloc(i) THEN supply(i) = supply(i) - 1: CALL clrbot: PRINT armyname$(i); " is blockaded"; : CALL TICK(turbo!)
y = armyloc(i)
FOR j = 1 TO 6: IF matrix(y, j) > 0 AND cityp(matrix(y, j)) = s THEN GOTO supplied
NEXT j
supply(i) = .5 * supply(i) - 1
supplied:
COLOR 13
IF supply(i) < 1 THEN
	supply(i) = 0
	CALL clrbot
	PRINT armyname$(i); " is out of supplies";
	CALL placearmy(i)
	CALL TICK(turbo!)
	IF armysize(i) > 10 THEN armysize(i) = .9 * armysize(i)
END IF
rip:
NEXT i
y = 0: FOR i = 1 TO 25: y = y + .1 * armysize(i): NEXT i
x = 0: FOR i = 26 TO 50: x = x + .1 * armysize(i): NEXT i
IF side = 2 AND x > 0 THEN aggress! = y / x ELSE aggress! = 1
IF side = 1 AND y > 0 THEN aggress! = x / y ELSE IF side = 1 THEN aggress! = 1
CALL enter(-1)
CALL disband
END SUB

SUB labels
FOR i = 1 TO cities
	f = 0
	p = POINT(cityx(i) + 10, cityy(i) + 12): IF p = 1 THEN f = 10
	CALL stencil(cityx(i) - 12, cityy(i) + 10, city$(i), f)
NEXT i
END SUB

SUB maxx
CALL tick(5)
GOSUB fame
FOR s = 1 TO 2: FOR i = 1 TO 5
IF victory(s) < matrix(s, i) GOTO oldskor
	FOR j = 5 TO i + 1 STEP -1
	matrix(s, j) = matrix(s, j - 1)
	city$(5 * (s - 1) + j) = city$(5 * (s - 1) + j - 1)
	NEXT j
COLOR 15, 1: IF s = 2 THEN COLOR 4, 7
IF player = 1 AND s <> side THEN a$ = "COMPUTER": GOTO automate
who4:
LOCATE 9, 26: COLOR 14, 4: PRINT "A NEW HIGH SCORE !"
PLAY "MFT220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
PLAY "T220P8o1g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
PLAY "T220P8o1a16a16o2d8e8d8o1a8f8a8o2d8o1a8f8a8o2d2"
PLAY "T220P8o1g16g16o2c8d8c8o1g8e8g8o2c8o1g8e8g8o2c2P1"
IF LEN(DIR$("vic.exe")) > 0 THEN SHELL "vic.exe"
GOSUB fame
COLOR 14, 5: COLOR 15, 5
LOCATE 12, 1: PRINT force$(s); " ARMY HAS A NEW HIGH SCORE of "; victory(s)
PRINT "New Entry into "; force$(s); " HALL of FAME in place "; i
PRINT "What is name of "; force$(s); " commander"; : INPUT a$: IF a$ = "" GOTO who4
automate:
city$(5 * (s - 1) + i) = a$
matrix(s, i) = victory(s): GOTO foun
oldskor:
NEXT i
foun:
NEXT s
OPEN "O", 1, "hiscore.nws"
FOR s = 1 TO 2: FOR i = 1 TO 5
	WRITE #1, city$(5 * (s - 1) + i), matrix(s, i)
NEXT i: NEXT s: CLOSE #1
GOSUB fame
CALL tick(2)
LOCATE 20, 1: PRINT "Game Over"
CALL tick(9)
pcode = 1
EXIT SUB

fame:
SCREEN 0: COLOR 14, 5: CLS : COLOR 11, 0
LOCATE 2, 7: PRINT STRING$(57, "²")
LOCATE 9, 7: PRINT STRING$(57, "²")
FOR k = 1 TO 6: LOCATE 2 + k, 7: PRINT "²"; SPACE$(55); "²": NEXT k
OPEN "I", 1, "hiscore.nws"
FOR j = 1 TO 2
	COLOR 14, 4: LOCATE 3, 30 * (j - 1) + 10: PRINT force$(j); " HALL of FAME"
	COLOR 15, 0: FOR k = 1 TO 5
	INPUT #1, city$(5 * (j - 1) + k), matrix(j, k)
	LOCATE 3 + k, 30 * (j - 1) + 8: PRINT k, city$(5 * (j - 1) + k), matrix(j, k)
NEXT k: NEXT j: CLOSE #1
RETURN
END SUB

SUB navy (who, chx)
DIM hit(2)
IF chx > 0 THEN
	IF navyloc(who) < 1 THEN
		chx = 1
	ELSE
		IF u7ca > 0 THEN chx = 3
		IF commerce = 3 - who AND raider > 0 THEN chx = 4
		IF who = 2 AND navyloc(3 - who) <> 99 AND RND > .7 THEN chx = 4
		IF grudge > 0 THEN chx = 3
	END IF
END IF
COLOR 11
ahoy:
cost = 100: cityp(0) = who
IF chx = 0 THEN CALL clrbot: PRINT "Funds available "; cash(who);
IF chx = 1 THEN
	IF cash(who) < cost THEN EXIT SUB
	IF navysize(who) > 9 THEN EXIT SUB
END IF
mtx$(0) = "Ships"
mtx$(1) = "Build"
IF navyloc(who) <> 99 THEN
IF cash(who) < cost OR navysize(who) > 9 OR cityp(navyloc(who)) <> who THEN mtx$(1) = "-": choose = 23
END IF
mtx$(2) = "Attack"
IF navyloc(who) <> 99 THEN
	IF who = cityp(navyloc(who)) THEN mtx$(2) = "-": choose = 22
	IF who = 2 AND navyloc(who) = 35 AND cityp(navyloc(who)) <> 1 THEN mtx$(2) = "-": choose = 22
ELSE
mtx$(1) = "-": mtx$(2) = "-": choose = 24
END IF
mtx$(3) = "Sail": IF navyloc(who) < 1 THEN mtx$(3) = "-": IF chx = 3 THEN chx = 1
mtx$(4) = "Raid": IF navysize(who) < 1 OR who = commerce THEN mtx$(4) = "-"
tlx = 67: tly = 12: size = 4
IF navyloc(who) <> 99 THEN
	n = who: IF who = 2 THEN n = 3
	IF navysize(who) > 1 AND cityp(navyloc(who)) = 0 THEN IF u892(n) > 50 OR cityo(navyloc(who)) > 6 THEN size = 5: mtx$(5) = "Invasion": CALL void(navyloc(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
END IF

IF chx > 0 THEN IF nflag > 0 AND chx > 1 THEN EXIT SUB ELSE choose = chx: GOTO anchor
IF nflag > 0 AND choose <> 1 THEN EXIT SUB
CALL menu(0)
anchor:
'---------------------------------------------------------------------------
SELECT CASE choose
'---------------------------------------------------------------------------
'                               Build Ship
'---------------------------------------------------------------------------
	CASE 1
	IF cash(who) < cost OR navyloc(who) = 99 GOTO ahoy
	IF chx = 1 THEN
		IF navysize(who) > 9 THEN EXIT SUB
		IF RND < .07 * navysize(who) THEN EXIT SUB
	END IF
	IF chx = 0 AND navysize(who) > 9 THEN GOTO ahoy

	IF chx = 0 AND navyloc(who) > 0 THEN
		IF who <> cityp(navyloc(who)) GOTO ahoy
		IF matrix(navyloc(who), 7) < 90 GOTO ahoy
	END IF
	navysize(who) = navysize(who) + 1
	IF navysize(who) > 1 GOTO add2ship
ships:
	mtx$(0) = "Port": size = 0: tlx = 67: tly = 12
	FOR i = 1 TO cities: IF matrix(i, 7) > 90 AND cityp(i) = who AND navyloc(3 - who) <> i THEN size = size + 1: mtx$(size) = city$(i): array(size) = i
	NEXT i
	IF who = 2 AND cityp(35) <> 1 THEN size = size + 1: mtx$(size) = city$(35): array(size) = 35
	IF chx = 1 THEN choose = 1 + INT(size * RND)
	IF size < 1 THEN
		navysize(who) = 0
		IF chx = 0 THEN CALL clrbot: PRINT "NO SHIPYARDS AVAILABLE !"; : EXIT SUB
		IF chx = 1 THEN EXIT SUB
	END IF
	IF chx = 0 THEN CALL menu(0)

	IF choose < 1 GOTO ahoy
	navyloc(who) = array(choose)
	IF u73a > 0 THEN navyloc(who) = u73a
	cash(who) = cash(who) - cost: navysize(who) = 1
	x = cityx(array(choose)) + 25: y = cityy(array(choose)) + 25: CALL ships
	CALL clrbot: COLOR 11: PRINT force$(who); " is building NEW fleet in "; city$(array(choose));
	PSET (400, 465), 0: CALL shipicon(who)
	IF noise > 0 THEN SOUND 3000, 1
	CALL TICK(turbo!)
	GOTO ahoy
add2ship:
	cash(who) = cash(who) - cost
	CALL clrbot: PRINT force$(who); " navy increased to "; navysize(who);
	PSET (400, 465), 0: CALL shipicon(who)
	CALL ships
	IF noise > 0 THEN SOUND 3000, 1
	CALL TICK(turbo!)
'---------------------------------------------------------------------------
'                               Attack City
'---------------------------------------------------------------------------
	CASE 2
	IF navyloc(who) = 99 GOTO ahoy
	IF chx = 2 AND cityp(navyloc(who)) = who THEN EXIT SUB
	IF chx = 2 AND occupied(navyloc(who)) > 0 AND RND > .5 THEN chx = 3: GOTO anchor
	IF chx = 2 AND cityp(navyloc(who)) = 0 THEN chx = 3: GOTO ahoy
	IF navyloc(who) < 1 THEN EXIT SUB
	IF who = side THEN nflag = 1
	IF who = cityp(navyloc(who)) GOTO ahoy
	IF who = 2 AND navyloc(who) = 35 AND cityp(navyloc(who)) <> 1 GOTO ahoy
	CALL clrbot: COLOR 12: PRINT force$(who); " fleet bombards "; city$(navyloc(who));
	CALL icon(navyloc(who), 0, 3)
	      
	target = navyloc(who): index = occupied(target): IF index = 0 GOTO deserted
	pct! = .005 * navysize(who) + .02 * RND: killd = armysize(index) * pct!: IF killd < 1 THEN killd = 1
	CALL clrbot: PRINT armyname$(index); " suffered "; 100 * killd; " casualties";
	x = .5 * navysize(who) + 1: IF x > supply(index) THEN x = supply(index)
	supply(index) = supply(index) - x
	CALL TICK(turbo!)
	armysize(index) = armysize(index) - killd: IF armysize(index) < 1 THEN armysize(index) = 1
	EXIT SUB
deserted:
	IF fort(target) = 0 GOTO blast
	IF RND < .7 + .03 * (navysize(who) - fort(target)) GOTO hurt1
	CALL barnacle(who)
	CALL clrbot
	PRINT force$(cityp(target)); " shore battery sunk an attacking ship!"; navysize(who); "ship(s) left! ";
	IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5
	CALL TICK(turbo!)
	IF navysize(who) < 1 THEN
		navyloc(who) = 0: navysize(who) = 0: GOSUB box2
		LOCATE 12, 27: PRINT force$(who); " fleet eliminated"
		CALL TICK(9)
		victory(3 - who) = victory(3 - who) + 5
		IF who = side THEN grudge = 0
		GOTO sail3
	END IF
	GOTO deserted
hurt1:
	CALL clrbot: PRINT city$(target); " fortifications damaged";
	fort(target) = fort(target) - 1: x = cityx(target): y = cityy(target): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
	CALL showcities
	CALL TICK(turbo!)
	EXIT SUB
blast:
	IF RND > .25 + .07 * navysize(who) THEN CALL clrbot: PRINT "Citizens of "; city$(target); " stand firm against the attack"; : CALL TICK(turbo!): EXIT SUB
	IF navyloc(who) = capcity(3 - who) THEN CALL clrbot: PRINT "The OBJECTIVE CITY steadfastly stands loyal"; : CALL TICK(turbo!): EXIT SUB
	cityp(navyloc(who)) = 0
	CALL clrbot: PRINT city$(navyloc(who)); " is now  NEUTRAL";
	CALL showcities
	victory(who) = victory(who) + cityv(navyloc(who))
	EXIT SUB
'---------------------------------------------------------------------------
'                               Sail
'---------------------------------------------------------------------------
	CASE 3
	IF navysize(who) < 1 AND chx > 0 THEN EXIT SUB
	IF navyloc(who) < 1 OR navysize(who) < 1 THEN CALL clrbot: PRINT "No ships remain"; : TICK 1: GOTO ahoy

	size = 0
	FOR i = 1 TO cities: IF matrix(i, 7) > 90 AND navyloc(who) <> i THEN size = size + 1: mtx$(size) = city$(i): array(size) = i
	NEXT i
	IF chx = 3 THEN
		IF size = 0 THEN EXIT SUB
		IF grudge > 0 THEN choose = 1: array(1) = navyloc(3 - who): GOTO admiral
		GOSUB nest: IF choose > 0 GOTO admiral ELSE EXIT SUB
	END IF
	COLOR 11: LOCATE 11, 68
	IF navyloc(who) < 41 THEN
		PRINT city$(navyloc(who))
	ELSE
		PRINT "Raiding"
	END IF
	mtx$(0) = "To"
	colour = 3: tlx = 67: tly = 6
      
	CALL menu(0): IF choose < 1 THEN EXIT SUB
admiral:
	IF u73a > 0 THEN choose = 1: array(choose) = u73a
	IF array(choose) = navyloc(who) THEN EXIT SUB
	IF array(choose) < 1 THEN EXIT SUB
	IF navysize(who) < 1 GOTO ships
	IF who = side THEN nflag = 1
	GOSUB box2
	LOCATE 10, 25: PRINT force$(who); " fleet of"; navysize(who); "ship(s) is sailing"
	LOCATE 11, 25: PRINT "From ";
	IF navyloc(who) <= cities THEN
		PRINT city$(navyloc(who));
	ELSE
		PRINT "Raiding";
	END IF
	PRINT " to ";
	IF array(choose) <> 99 THEN
		PRINT city$(array(choose));
	ELSE
		PRINT "Raid Commerce";
	END IF

	FOR i = 1 TO navysize(who)
		PSET (120 + 41 * i, 210), 0
		CALL shipicon(who)
	NEXT i
	CALL schooner
	TICK 2 * turbo!
	navyloc(who) = array(choose)
	IF navyloc(1) = navyloc(2) GOTO pirate
	GOTO sail3
'---------------------------------------------------------------------------
'                               Raid Commerce
'---------------------------------------------------------------------------
	CASE 4
	IF navysize(who) < 1 AND chx > 0 THEN EXIT SUB
	IF navysize(who) < 1 OR (who = side AND who = commerce) GOTO ahoy

	IF who = side THEN nflag = 1
	GOSUB box2
	LOCATE 10, 25: PRINT force$(who); " fleet of"; navysize(who); "ship(s) is sailing"
	LOCATE 11, 25: PRINT "to RAID "; force$(3 - who); " COMMERCE !"

	FOR i = 1 TO navysize(who)
		PSET (120 + 41 * i, 210), 0
		CALL shipicon(who)
	NEXT i
	CALL schooner
	TICK 2 * turbo!
	navyloc(who) = 99: commerce = who
	IF navyloc(1) = navyloc(2) GOTO pirate
	CLS : CALL europe
	EXIT SUB
'---------------------------------------------------------------------------
'                               Invasion
'---------------------------------------------------------------------------
	CASE 5
	CALL commander((who), empty)
	IF chx > 0 AND empty = 0 THEN chx = 3: GOTO anchor
	x = 35
	CALL barnacle(who)
	m = who: IF who = 2 THEN m = 3
	c = navyloc(who): CALL newarmy((who), empty, c, m)
	cash(who) = cash(who) + 100     'compensate for cost of recruiting new army
	CALL capture(empty, c, who, 0)
	armysize(empty) = x
	IF who = side THEN nflag = 1
	EXIT SUB
'---------------------------------------------------------------------------
'                               Exit
'---------------------------------------------------------------------------
	CASE ELSE
	EXIT SUB
END SELECT
GOTO ahoy
'---------------------------------------------------------------------------
'                               Ship vs. Ship
'---------------------------------------------------------------------------
pirate:
	CALL BuffClear: CLS : LOCATE 1, 30: COLOR 11: PRINT "NAVAL COMBAT"
	FOR k = 1 TO 2
	hit(k) = 10
	NEXT k
	CALL schooner
cannon:
	LOCATE 9, 1: PRINT SPACE$(79)
	LOCATE 15, 1: PRINT SPACE$(79)
	x = 10: y = 100
	COLOR 9: LOCATE 5, 25: PRINT "French"; navysize(1); "ship(s)"
	GOSUB boxes
	COLOR 1
	FOR i = 1 TO navysize(1)
	x = x + 50: PSET (x, y)
	CALL shipicon(1)
	NEXT i
	COLOR 4: LOCATE 11, 23: PRINT "ENGLAND "; navysize(2); "ship(s)"
	LINE (10, 180)-(530, 210), 1, BF
	LINE (10, 180)-(530, 210), 11, B
	x = 10: y = 200
	COLOR 1
	FOR i = 1 TO navysize(2)
	x = x + 50: PSET (x, y)
	CALL shipicon(2)
	NEXT i
	COLOR 11
wave:
	mtx$(0) = "Options"
	mtx$(1) = "Attack"
	mtx$(2) = "Retreat"
	pct! = .05: IF who = 1 THEN pct! = -.05
	IF chx > 0 THEN choose = 1: GOTO powder

	size = 2: colour = 3: hilite = 14: tlx = 60: tly = 22: CALL menu(0)
	CALL BuffClear
powder:
	SELECT CASE choose
	 CASE 1
firemore:
	 IF noise > 0 THEN IF PEEK(1052) = 30 THEN CALL icon(1, 1, 12): CALL TICK(.1): SOUND 77, .3: SOUND 59, .3
	 IF RND <= .5 + pct! GOTO hitem ELSE GOTO hitme1
	 GOTO firemore
hitem:
	 hit(3 - who) = hit(3 - who) - 1: GOSUB showhit: IF hit(3 - who) > 0 GOTO firemore
	 x = 10 + 50 * navysize(3 - who)
	 y = 90: IF who = 1 THEN y = 190
	 GOSUB xout
	 c = 9: IF who = 1 THEN c = 4
	 COLOR c: LOCATE 17, 5: PRINT force$(3 - who); " ship SUNK!"
	 IF PEEK(1052) = 30 THEN CALL TICK(turbo! + 1)
	 GOSUB clr1
	 CALL barnacle(3 - who)
	 IF navysize(3 - who) < 1 THEN
		LOCATE 17, 5: COLOR 12
		PRINT force$(3 - who); " fleet DEFEATED"
		CALL TICK(turbo!)
		navyloc(3 - who) = 0: navysize(3 - who) = 0
		victory(3 - who) = victory(3 - who) + 10
		IF who = side THEN grudge = 1 ELSE grudge = 0
		GOTO sail3
	 END IF
	 hit(3 - who) = 10
	 GOTO cannon
hitme1:
	 hit(who) = hit(who) - 1: GOSUB showhit: IF hit(who) > 0 GOTO firemore
	 x = 10 + 50 * navysize(who)
	 y = 190: IF who = 1 THEN y = 90
	 GOSUB xout
	 c = 9: IF who = 2 THEN c = 4
	 COLOR c: LOCATE 17, 5: PRINT force$(who); " ship SUNK!"
	 IF PEEK(1052) = 30 THEN CALL TICK(turbo!)
	 GOSUB clr1
	 CALL barnacle(who)
	 IF navysize(who) < 1 THEN
		LOCATE 19, 5: COLOR 12
		PRINT "Attacking "; force$(who); " fleet has been ELIMINATED !"
		CALL TICK(turbo!)
		navyloc(who) = 0: navysize(who) = 0
		victory(who) = victory(who) + 10
		IF who <> side THEN grudge = 1 ELSE grudge = 0
		GOTO sail3
	 END IF
	 hit(who) = 10
	 GOTO cannon

	 CASE 2
	 target = 0
	 FOR i = 1 TO cities
	 IF cityp(i) <> 3 - who AND navyloc(who) <> i AND matrix(i, 7) > 90 THEN target = i: IF RND > .3 GOTO found1
	 NEXT i
	 IF target > 0 GOTO found1
	 CALL clrbot: COLOR 11: PRINT force$(who); " cannot escape !"; : CALL TICK(2): GOTO wave
found1:
	 CALL clrbot: COLOR 11: PRINT force$(who); " is retreating to "; city$(target); : CALL TICK(turbo!)
	 navyloc(who) = target
	 GOTO sail3
	 CASE ELSE
	 GOTO wave
	 END SELECT
	 GOTO pirate
'---------------------------------------------------------------------------
'                               Subs
'---------------------------------------------------------------------------
showhit:
	 LOCATE 9, 6 * navysize(1): PRINT hit(1); " ";
	 LOCATE 15, 6 * navysize(2): PRINT hit(2); " ";
	 IF noise = 0 THEN IF PEEK(1052) = 30 THEN TICK .1 * turbo!
	 RETURN
clr1:
	COLOR 11: LINE (30, 250)-(180, 280), 3, BF: RETURN
nest:
	IF u7ca > 0 THEN
		FOR k = 1 TO size
		IF mtx$(k) = city$(u7ca) THEN choose = k: u7ca = 0: RETURN
		NEXT k
	END IF
	best = 0: x = 0
	FOR i = 1 TO size
	target = array(i)
	IF cityp(target) = 0 THEN
		IF u892(cityo(target)) < 51 GOTO neutral
		best = i: IF RND > .2 THEN choose = best: RETURN
	END IF

	IF target = navyloc(3 - who) THEN IF navysize(who) >= navysize(3 - who) AND RND > .1 THEN choose = i: RETURN
	IF cityp(target) <> who THEN
		best = i: x = x + 1
		IF RND > .8 THEN choose = best: RETURN
	END IF
neutral:
	NEXT i
	IF best = 0 THEN
		choose = 1 + INT(RND * size)
	ELSE
		choose = best
	END IF
	RETURN
boxes:
	LINE (10, 80)-(530, 110), 1, BF
	LINE (10, 80)-(530, 110), 11, B
	RETURN
box2:
	CLS
	LINE (100, 110)-(550, 240), 1, B
	LINE (95, 115)-(555, 235), 7, B
	RETURN
xout:
		PSET (x, y)
		DRAW "S5C15G5F5G3H5G5H3E5H5E3F5E5F3"
		PAINT (x - 3, y + 1), 12, 15
	RETURN
sail3:
	commerce = 0
	FOR k = 1 TO 2
	IF navyloc(k) = 99 THEN commerce = k
	NEXT k
	CLS : CALL europe
END SUB

SUB normal (xbar, vary, result)
' NOTE : vary is VARIANCE
pct! = 0
FOR k = 1 TO 12: pct! = pct! + RND: NEXT k
pct! = pct! - 5.5
result = xbar + pct! * SQR(vary)
END SUB

SUB occupy (x)
occupied(x) = 0
FOR i = 1 TO 50
IF armyloc(i) = x THEN occupied(x) = i: GOTO holdup
NEXT i
holdup:
END SUB

SUB relieve (who)
colour = 3: target = 0: hilite = 3
tlx = 67: tly = 2
CALL starfin(star, fin, who)
size = 0
FOR i = star TO fin
IF armysize(i) > 0 AND armyloc(i) > 0 AND armymove(i) = 0 THEN
	size = size + 1
	mtx$(size) = armyname$(i)
	IF LEN(mtx$(size)) > 11 THEN mtx$(size) = LEFT$(mtx$(size), 11)
	array(size) = armyloc(i)
END IF
NEXT i

IF size = 0 THEN EXIT SUB
mtx$(0) = "Relieve"
choose = 31: hilite = 11
CALL menu(2)

IF choose < 1 THEN EXIT SUB
x = array(choose): index = occupied(x)
CALL icon(armyloc(index), 0, 9)

t$ = armyname$(index)
lname$(index) = t$

size = 0
FOR i = star TO fin
IF lname$(i) <> "" THEN
	size = size + 1
	mtx$(size) = lname$(i)
	IF LEN(mtx$(size)) > 11 THEN mtx$(size) = LEFT$(mtx$(size), 11)
	array(size) = i
END IF
NEXT i

have2:
mtx$(0) = "New Leader"
tlx = 66: tly = 2
CALL menu(0)
IF choose < 1 GOTO have2
armymove(index) = -1
armylead(index) = rating(array(choose))
IF armylead(index) > 0 THEN armylead(index) = armylead(index) - 1
IF armyexper(index) > 0 THEN armyexper(index) = armyexper(index) - 1
COLOR 15: CALL clrbot: PRINT lname$(array(choose)); " has replaced "; t$; " in "; city$(armyloc(index)); : TICK 9
armyname$(index) = lname$(array(choose))
lname$(array(choose)) = ""
CALL icon(armyloc(index), 0, 8)
CALL clrbot
END SUB

SUB report (who, mode)
DIM summ(cities)
IF who > 100 GOTO batrep
IF mode <> 0 THEN choose = mode: GOTO pick
mtx$(0) = "Information"
mtx$(1) = force$(side) + " Armies"
mtx$(2) = force$(3 - side) + " Armies"
mtx$(3) = "Cities"
mtx$(4) = "Force Summary"
mtx$(5) = "Intelligence"
mtx$(6) = "Battles": size = 6
IF history > 0 AND LEN(DIR$("nws.his")) > 0 THEN mtx$(7) = "Recap": size = 7
tlx = 64: tly = 6
CALL menu(0)
pick:
SELECT CASE choose
CASE IS < 0
	CLS
	CALL europe
	EXIT SUB
CASE 2: who = 3 - side
CASE 3: GOTO cityrep
CASE 4: GOTO frep
CASE 5: GOTO srep
CASE 6: GOTO batrep
CASE 7: GOTO recap
CASE ELSE
END SELECT
'..........................................................................
'                               Army Report
'..........................................................................
IF choose < 0 GOTO endrep
IF choose = 4 GOTO frep
CALL starfin(star, fin, who)
CLS : LOCATE 1, 1: c = 9: IF who = 2 THEN c = 15
COLOR c
PRINT " Report for "; force$(who); " Forces"; TAB(30); month$(month); ","; year; TAB(49); : COLOR 14: PRINT " Victory Points "; victory(who);
IF c = 15 THEN c = 7
x = victory(who) + victory(3 - who)
IF x = 0 THEN
	PRINT
ELSE
	y = (victory(who) / x) * 100
	PRINT "("; LTRIM$(RTRIM$(STR$(y))); " %)"
END IF
COLOR c: PRINT control(who); "/"; cities; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(control(who) * 2.5 + .5): PRINT x; "%)";
PRINT TAB(50); : COLOR 12: PRINT "Objective: "; city$(capcity(who))
y = income(who) + income(3 - who)
PRINT income(who); "/"; y; TAB(15); "INCOME"; TAB(40); "("; : x = (income(who) / vptotal) * 100: PRINT x; "%)   "; : COLOR 14: PRINT "Cash:"; cash(who)
COLOR 11: PRINT " #      Name             Size  Location   Ldr Exp Suply Move To"
z = 0: x = 0: FOR i = star TO fin
COLOR c
IF armyloc(i) < 1 GOTO deadeye
x = x + armysize(i)
PRINT i; TAB(5); armyname$(i); TAB(25); : y = CSRLIN
CALL strong(i): PRINT TAB(32); city$(armyloc(i));
IF who <> side THEN PRINT : GOTO deadeye
PRINT TAB(43); armylead(i); TAB(47); armyexper(i); TAB(52); supply(i);
PRINT TAB(57); : IF armymove(i) > -1 THEN PRINT city$(armymove(i)) ELSE PRINT "Resting"
IF fort(armyloc(i)) > 0 THEN LOCATE y, 68: PRINT "FORT +"; fort(armyloc(i))
deadeye:
NEXT i
CALL starfin(star, fin, 3 - who)
FOR i = star TO fin
IF armyloc(i) > 0 AND ((who = 1 AND i > 25) OR (who = 2 AND i < 26)) THEN z = z + armysize(i)
NEXT i
PRINT " "; STRING$(70, "Ä")
PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(z)); "00 ]"
PRINT " "; STRING$(70, "Ä")
PRINT " "; force$(who); " NAVY has "; navysize(who); " ship(s) ";
IF navyloc(who) > 0 AND navyloc(who) < 99 THEN PRINT "in "; city$(navyloc(who)) ELSE PRINT
PRINT " "; STRING$(70, "Ä")
LINE (0, 0)-(639, 449), 15, B
LINE (0, 62)-(639, 62), 15
GOTO endrep
'..........................................................................
'                               City Report
'..........................................................................
cityrep:
CLS : LOCATE 1, 1: COLOR 14: WIDTH , 60
PRINT "City Report"; TAB(20); month$(month); ","; year: COLOR 15
PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"
FOR i = 1 TO 34: COLOR 7: a$ = u836$(cityo(i)): IF cityp(i) = 1 THEN COLOR 9: a$ = "French"
IF cityp(i) = 2 THEN COLOR 4: a$ = "Allies"
IF cityp(i) < 1 OR cityp(i) > 2 THEN IF cityo(i) > 1 AND cityo(i) < 7 THEN COLOR 2: a$ = "(peace)": n = n + 1
LOCATE 2 + i, 1: PRINT i; TAB(6); city$(i); TAB(17); a$; TAB(33); cityv(i)
NEXT i

FOR i = 35 TO cities: COLOR 7: a$ = u836$(cityo(i)): IF cityp(i) = 1 THEN COLOR 9: a$ = "French"
IF cityp(i) = 2 THEN COLOR 4: a$ = "Allies"
IF cityp(i) < 1 OR cityp(i) > 2 THEN IF cityo(i) > 1 AND cityo(i) < 7 THEN COLOR 2: a$ = "(peace)": n = n + 1
LOCATE -32 + i, 41: PRINT i; TAB(46); city$(i); TAB(57); a$; TAB(71); cityv(i)
NEXT i
LINE (1, 15)-(630, 15), 15
LINE (1, 300)-(639, 300), 15
COLOR 9: LOCATE 40, 1: PRINT "Side    No. Cities   Income    Cash"
COLOR 9: PRINT force$(1); TAB(12); control(1); TAB(23); income(1); TAB(32); cash(1)
COLOR 4: PRINT force$(2); TAB(12); control(2); TAB(23); income(2); TAB(32); cash(2)
COLOR 2: PRINT "peace"; TAB(12); n
COLOR 7: PRINT force$(0); TAB(12); cities - control(1) - control(2) - n
LINE (1, 370)-(320, 370), 15
LINE (320, 300)-(638, 420), 13, B
FOR k = 1 TO 10
	LOCATE k + 40, 50: COLOR 15: PRINT u836$(k); TAB(65);
	SELECT CASE u892(k)
		CASE IS < 25: a$ = "PEACE": COLOR 2
		CASE IS <= 50: a$ = "UNEASE": COLOR 14
		CASE ELSE: a$ = "WAR!": COLOR 4
	END SELECT
	PRINT a$;
NEXT k
CALL TICK(99)
WIDTH , 30
GOTO redraw
'..........................................................................
'                               Intelligence
'..........................................................................
srep:
c = 9: IF side = 2 THEN c = 7
CALL europe
CALL starfin(star, fin, side)
FOR k = star TO fin
	IF armysize(k) > 0 THEN
	COLOR c
	x = cityx(armyloc(k))
	y = cityy(armyloc(k))
	w = 10: IF armysize(k) < 1000 THEN w = 9
	x = x / 8 - 2: y = y / 16
	IF y > 26 THEN y = 26
	FOR j = 0 TO 3
	LOCATE y + j, x: PRINT SPACE$(w);
	NEXT j
	LOCATE y, x: PRINT "Siz:"; : CALL strong(k)
	LOCATE y + 1, x: PRINT "Ldr:"; armylead(k)
	LOCATE y + 2, x: PRINT "Xpr:"; armyexper(k)
	LOCATE y + 3, x: PRINT "Sup:"; supply(k);
	LINE (8 * (x - 1) - 1, 16 * (y - 1) - 1)-(8 * (x + w - 1) + 1, 16 * (y + 3) + 1), 15, B
	TICK 1
END IF
NEXT k
GOTO endrep
'..........................................................................
'                               Force Summary
'..........................................................................
frep:
FOR k = 1 TO cities
	IF occupied(k) > 0 THEN
		FOR j = 1 TO 50
		IF armyloc(j) = k THEN summ(k) = summ(k) + armysize(j)
		NEXT j
	END IF
NEXT k

CLS : CALL europe
FOR k = 1 TO cities
IF summ(k) > 0 THEN
	c = 9: IF cityp(k) <> 1 THEN c = 7
	COLOR c
	LOCATE INT(cityy(k) / 16 + 1), cityx(k) / 8: PRINT LTRIM$(RTRIM$(STR$(summ(k))))
END IF
NEXT k
COLOR 14: LOCATE 1, 20: PRINT "Total Forces in Cities (100's)"
GOTO endrep
'..........................................................................
'                               Battle Report
'..........................................................................
batrep:
CALL clrbot
VIEW (200, 123)-(400, 284)
CLS 1
VIEW
LINE (200, 123)-(400, 284), 15, B
COLOR 14
LOCATE 9, 32: PRINT "BATTLE SUMMARY"
LINE (200, 176)-(400, 230), 15, B
LINE (200, 230)-(400, 284), 15, B
LINE (290, 176)-(345, 284), 15, B
COLOR 9: LOCATE 11, 38: PRINT force$(1); " "; : COLOR 4: PRINT force$(2)
COLOR 14
LOCATE 13, 27: PRINT "BATTLES"
LOCATE 14, 27: PRINT "WON"
LOCATE 16, 27: PRINT "MEN LOST"
LOCATE 17, 27: PRINT "(1000's)"
COLOR 9: LOCATE 14, 38: PRINT batwon(1)
COLOR 4: LOCATE 14, 45: PRINT batwon(2)
COLOR 9: LOCATE 17, 38: PRINT INT(.1 * casualty&(1))
COLOR 4: LOCATE 17, 45: PRINT INT(.1 * casualty&(2))
IF history > 0 AND who > 2 THEN
	OPEN "O", #1, "battsumm"
	PRINT #1, " SIDE      BATTLES WON       LOSSES"
	FOR k = 1 TO 2
	a$ = " ": IF thrill = k THEN a$ = "*"
	PRINT #1, a$; force$(k), batwon(k), 100 * casualty&(k)
	NEXT k
	CLOSE #1
END IF
GOTO endrep
'..........................................................................
'                               Recap (History)
'..........................................................................
recap:
CLS : x = 0
OPEN "I", 2, "nws.his"
DO WHILE NOT EOF(2)
INPUT #2, a$
COLOR 7: IF INSTR(a$, "[") THEN COLOR 15
IF INSTR(a$, ">") THEN COLOR 14
IF INSTR(a$, "..") THEN COLOR 11
IF INSTR(a$, "!") THEN COLOR 12
LOCATE 29, 1: PRINT a$
x = x + 1
IF x > 27 THEN TICK .4
LOOP
CLOSE #2

endrep:
COLOR 14: LOCATE 29, 29: PRINT "press a key";: CALL TICK(99)
redraw:
IF who < 3 THEN
	CLS
	CALL europe
END IF
END SUB

SUB resupply (index)
		who = 1: IF index > 25 THEN who = 2
			CALL cutoff(who, armyloc(index), a)
			IF a < 1 THEN EXIT SUB
		IF armysize(index) > 0 THEN x = cash(who) / armysize(index) * 10
		y = x + supply(index): IF y > 5 THEN x = 5 - supply(index)
		IF x < 1 THEN CALL clrbot: PRINT "Not enough funds in the Treasury to supply "; armyname$(index); : GOTO nocash
		supply(index) = supply(index) + x: cash(who) = cash(who) - .1 * x * armysize(index)
		CALL clrbot: PRINT armyname$(index); " has received supplies "; : IF noise > 0 THEN SOUND 4500, .5
nocash:
		CALL TICK(turbo!): IF cash(who) < 0 THEN cash(who) = 0
END SUB

SUB retreat (defend, x)
x = 0
IF player = 1 THEN
	IF (side = 1 AND defend > 25) OR (side = 2 AND defend < 26) THEN EXIT SUB
END IF

hilite = 13: colour = 3: tlx = 67: tly = 5: size = 0
y = armyloc(defend)
who = 1: IF defend > 25 THEN who = 2
FOR k = 1 TO 6
	IF matrix(y, k) > 0 AND cityp(matrix(y, k)) = who THEN size = size + 1: mtx$(size) = city$(matrix(y, k)): array(size) = matrix(y, k)
NEXT k
	IF size = 0 THEN EXIT SUB
	IF size = 1 THEN x = array(1): EXIT SUB
	mtx$(0) = "Retreat"
	CALL menu(2)
	IF choose < 0 OR choose > size THEN x = 0: EXIT SUB
	x = array(choose)
END SUB

SUB roman (target, a$)
a$ = "French ": IF target > 25 THEN a$ = "Allies "
IF target > 25 THEN target = target - 25
tens: IF target > 10 THEN a$ = a$ + "X": target = target - 10
SELECT CASE target
	CASE IS < 4
	x = target: GOSUB add1s
	CASE 4
	a$ = a$ + "IV"
	CASE 5 TO 8
	a$ = a$ + "V"
	x = target - 5
	GOSUB add1s
	CASE 9
	a$ = a$ + "IX"
	CASE 10
	a$ = a$ + "X"
	CASE IS > 10
	GOTO tens
END SELECT
EXIT SUB

add1s:
IF x > 0 THEN FOR k = 1 TO x: a$ = a$ + "I": NEXT k
RETURN

END SUB

SUB scribe (a$, flag)
SELECT CASE flag
		CASE 1: CALL clrbot: PRINT a$;
		CASE 2: CALL image2(a$, 4)
END SELECT
IF history > 0 THEN
	OPEN "A", 2, "nws.his"
	a$ = LTRIM$(RTRIM$(a$))
	PRINT #2, a$
	CLOSE #2
END IF
END SUB

SUB shipicon (who)
	x = POINT(0) - 10: y = POINT(1) - 10
	CIRCLE (x, y), 18, 9, , , .4
	PAINT (x + 3, y + 4), 9, 9
	CIRCLE (x, y), 18, 10, , , .4
	DRAW "BF5R5D1C4L20C0H1R22E1L9": DRAW "BL6": DRAW "C0L10H1L1H2": DRAW "BR9D2"
	DRAW "C0U9": DRAW "BR13": DRAW "C0D9BU7R3"
	DRAW "C0L7BL5C0L7BD3BL2BD1BL1BD1C0R11BR3": DRAW "C0R10BL12"
	PSET (x + 8, y - 1)
	GOSUB jack
EXIT SUB
jack:
	SELECT CASE who
	CASE 1
	DRAW "C1U4R1D4R1C15U4R1D4R1C4U4R1D4"
	CASE 2
	LINE (x + 8, y - 1)-(x + 13, y - 5), 1, BF
	PSET (x + 8, y - 1), 1
	DRAW "BU2C4R5BD2Bl2U4"
	END SELECT
	RETURN
END SUB

SUB ships
FOR s = 1 TO 2
IF navysize(s) = 0 OR navyloc(s) = 0 THEN navyloc(s) = 0: GOTO sink
IF navyloc(s) = 99 THEN x = 150: y = 420: GOTO float
SELECT CASE matrix(navyloc(s), 7)
	CASE 96: x = cityx(navyloc(s)) + 50: y = cityy(navyloc(s)) + 10
	CASE 97: x = cityx(navyloc(s)) - 15: y = cityy(navyloc(s)) + 10
	CASE 98: x = cityx(navyloc(s)) + 25: y = cityy(navyloc(s)) - 10
	CASE 99: x = cityx(navyloc(s)) + 5: y = cityy(navyloc(s)) + 30
END SELECT
IF navyloc(s) = 24 THEN y = y + 5: x = x - 5
float:
	PSET (x, y), 1
	CALL shipicon(s)
sink:
NEXT s
END SUB

SUB smarts
CALL events
nflag = 0
slush = 0: who = 3 - side
c = 9: IF side = 1 THEN c = 15
CALL clrbot
COLOR c: PRINT force$(who); " Side is making decisions";
IF who = 1 AND armyloc(1) = 16 THEN u73a = armyloc(1) ELSE u73a = 0
CALL starfin(star, fin, who)
'==========================================================================
'                       Check Supply
'==========================================================================
FOR i = star TO fin: IF armyloc(i) > 0 AND supply(i) < 1 THEN CALL resupply(i)
NEXT i
'==========================================================================
'                       Fortify Capital or Other City
'==========================================================================
cost = 200
IF cost > cash(who) GOTO signup
IF RND > .3 GOTO signup

target = 0: IF occupied(capcity(who)) = 0 OR fort(capcity(who)) > 1 GOTO city2
target = capcity(who)
IF cityp(target) = who GOTO capital ELSE GOTO city2
IF target > 0 GOTO capital

city2:
IF 1 + RND < bold + aggress! GOTO signup
target = 0: FOR i = star TO fin
x = armyloc(i): IF x = 0 OR armymove(occupied(x)) < 0 OR armymove(i) < 0 GOTO endlook
IF fort(x) > 1 GOTO endlook
	CALL void(x, defend): IF defend > armysize(i) THEN target = armyloc(i): GOTO capital
endlook:
NEXT i

capital:
	IF target = 0 GOTO signup
	IF fort(target) > 1 GOTO signup
	fort(target) = fort(target) + 1
	x = occupied(target): armymove(x) = -1
	cash(who) = cash(who) - cost
	CALL clrbot: PRINT city$(target); " fortifications increased to "; fort(target);
	CALL icon(target, 0, 6)
	CALL showcities
	IF who = 2 AND navysize(2) < 1 AND RND > .5 AND cash(2) < 222 GOTO signup
	IF 3 * RND > 1 + aggress! AND cash(who) >= cost GOTO city2
'==========================================================================
'                       Recruit New Armies
'==========================================================================
signup:
IF who = 2 AND navysize(2) < 1 AND cash(2) > 100 THEN CALL navy(2, 1): nflag = 1: IF cash(who) < 100 GOTO isok
GOSUB enufarmies
IF x > 2 + 3 * side + 3 * RND GOTO isok
IF navysize(who) < 5 AND cash(who) > 100 AND navyloc(who) <> 99 THEN IF cityp(navyloc(who)) = who THEN slush = slush + 100: cash(who) = cash(who) - 100: IF cash(who) < 100 GOTO isok
CALL recruit(who)
'==========================================================================
'                         Naval Commands
'==========================================================================
isok:
	cash(who) = cash(who) + slush
dock:
	IF who = 1 AND u73a > 0 THEN
		IF navysize(who) > 0 AND u73a = 0 THEN
			CALL navy(who, 1): nflag = 1
		ELSE
			CALL navy(who, 3): nflag = 1
		END IF
	END IF
	IF navyloc(who) = 99 THEN
		IF RND < .9 THEN CALL navy(who, 3): nflag = 1
		GOTO movearmy
	END IF
	IF cash(who) >= 100 AND navysize(who) <= 9 AND cityp(navyloc(who)) = who AND u73a = 0 THEN CALL navy(who, 1): nflag = 1
movenavy:
	IF navysize(who) = 0 THEN navyloc(who) = 0
	IF navyloc(who) = 0 GOTO movearmy
	IF u7ca > 0 THEN CALL navy(who, 3): nflag = 1: GOTO movearmy
	IF navyloc(who) <> 99 THEN
		IF cityp(navyloc(who)) = who THEN CALL navy(who, 3): nflag = 1: GOTO movearmy
		IF cityp(navyloc(who)) = 0 THEN CALL navy(who, 3): nflag = 1: GOTO movearmy
	ELSE
		IF RND < .5 THEN CALL navy(who, 3): nflag = 1
		GOTO movearmy
	END IF
	IF cityp(navyloc(who)) <> who THEN
		IF occupied(navyloc(who)) = 0 OR RND > .3 THEN
			CALL navy(who, 2): nflag = 1
		ELSE
			CALL navy(who, 3): nflag = 1
		END IF
	END IF
'==========================================================================
'                       Give Move Orders to Each Army
'==========================================================================
movearmy:
	CALL ships
'---------------------------------------------------------------------------
'                               Check to Combine
'---------------------------------------------------------------------------
a = who: CALL combine(a)
'---------------------------------------------------------------------------
'                               Top Priority
'---------------------------------------------------------------------------
FOR i = star TO fin
target = armyloc(i)
IF armyloc(i) < 1 OR armymove(i) < 0 GOTO deadman
x = armysize(i): IF supply(i) < 1 AND RND > .1 GOTO deadman
a = u558(i): IF u892(a) <= 50 GOTO deadman

choose = 0

CALL void(target, defend)

IF defend > 0 AND target = capcity(who) AND occupied(target) = i GOTO deadman   'hold capital
IF target <> capcity(who) GOTO nocap
IF vicflag(5) = 0 GOTO nocap
	FOR j = 1 TO 6
	k = matrix(target, j): IF j = 0 GOTO nocap
	CALL void(k, flag): IF flag > 0 GOTO deadman
	NEXT j
nocap:
CALL evaluate(i, best): IF best = 0 GOTO deadman
move9:
	IF best = 0 THEN choose = 1 + INT((j - 1) * RND)
	IF choose = 0 THEN choose = best
	armymove(i) = matrix(target, choose)

	IF i > 1 THEN IF cityp(armymove(i)) = who THEN y = occupied(armymove(i)): IF y > 0 THEN IF armymove(y) = x THEN armymove(i) = 0: GOTO deadman
	IF side = 1 AND capcity(2) = 42 THEN IF cityx(armyloc(1)) > 440 AND cityx(armyloc(i)) > 500 AND cityx(armymove(i)) < 500 THEN armymove(i) = 0: GOTO deadman
	m = armymove(i)
	IF matrix(target, 7) < 90 GOTO noboat
	IF matrix(m, 7) < 90 GOTO noboat
		IF navyloc(who) <> target OR navyloc(3 - who) = m THEN
			z = 0
			FOR k = 1 TO 4: IF u2a0(k) = target OR u2a0(k) = m THEN z = 1: EXIT FOR
			NEXT k
			IF i <> 0 THEN
				IF navyloc(3 - who) = m THEN u7ca = m ELSE u7ca = target
				armymove(i) = 0
				GOTO deadman
			END IF
		END IF
noboat:

	IF turbo! > 1 THEN
		COLOR c: CALL clrbot
		PRINT armyname$(i); " plans to move from "; city$(armyloc(i)); " to "; city$(armymove(i));
	END IF
		CALL icon(armyloc(i), armymove(i), 1)
		CALL icon(armyloc(i), armymove(i), 9)
	CALL TICK(turbo! - 1)
	PUT (cityx(armyloc(i)) - 20, cityy(armyloc(i)) - 19), image, PSET
deadman:
NEXT i
	FOR i = star TO fin
	IF armymove(i) = 0 AND armyexper(i) < 6 AND armyexper(i) < armylead(i) THEN
		armyexper(i) = armyexper(i) + 1

		IF turbo! > 1 THEN
		CALL clrbot
			PRINT armyname$(i); " has drilled to reach experience level "; armyexper(i);
		END IF
		armymove(i) = -1
		CALL TICK(turbo! - 1)
	END IF
	NEXT i
EXIT SUB
'---------------------------------------------------------------------------
enufarmies:
CALL starfin(star, fin, 3 - who)
FOR i = star TO fin
	IF armyloc(i) > 0 THEN y = y + .1 * armysize(i)
NEXT i
CALL starfin(star, fin, who)
x = 0: z = 0: FOR i = star TO fin: IF armyloc(i) > 0 THEN x = x + 1: z = z + .1 * armysize(i)
NEXT i
IF y > z THEN x = x - 2
IF y > 2 * z THEN x = 0
RETURN
'---------------------------------------------------------------------------
END SUB

SUB starfin (star, fin, who)
star = 1: fin = 25: IF who = 2 THEN star = 26: fin = 50
END SUB

SUB stax (who)
CALL starfin(star, fin, who)
FOR i = star TO fin
IF armysize(i) > 0 AND occupied(armyloc(i)) <> i THEN
	target = armyloc(i)
	x = cityx(target) - 14: y = cityy(target) - 11
	k = 0
	FOR j = star TO fin
		IF armysize(j) > 0 AND armyloc(j) = target THEN k = k + 1
	NEXT j
	IF k > 1 THEN
		CIRCLE (x + 1, y - 2), 3, 8
		PAINT (x, y), 8, 8
		PSET (x, y), 15
		DRAW "C14S4" + font$(k + 27)
	END IF
END IF
NEXT i
END SUB

SUB stencil (x, y, a$, f)
FOR i = 1 TO LEN(a$)
	c = ASC(MID$(UCASE$(a$), i, 1)) - 64
	z = POINT(x + 5 * (i - 1), y): PSET (x + 5 * (i - 1), y), z
	DRAW "S4C" + LTRIM$(RTRIM$(STR$(f)))
	IF c > 0 AND c < 27 THEN DRAW font$(c)
	IF c < 0 AND c <> -32 THEN c = c + 43: DRAW font$(c)
NEXT i
END SUB

SUB TICK (sec!)
start! = TIMER
DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP
END SUB

SUB victor
	x = 0: FOR j = 1 TO 25: IF armyloc(j) > 0 THEN x = x + armysize(j)
	NEXT j
	y = 0: FOR j = 26 TO 50: IF armyloc(j) > 0 THEN y = y + armysize(j)
	NEXT j

	CALL clrbot: COLOR 14
	IF vicflag(2) > 0 AND year >= vicflag(2) AND vicflag(1) - month < 3 THEN
		a$ = "Time almost expired (" + month$(vicflag(1)) + "," + STR$(vicflag(2)) + ")"
		CALL image2(a$, 4)
	END IF
	IF armyloc(1) = 0 THEN j = 8: victory(1) = victory(1) + 300: GOTO finis
    FOR i = 1 TO 2
	IF (i = 1 AND y = 0) OR (i = 2 AND x = 0) THEN j = 7: victory(i) = victory(i) + 300: GOTO finis

	IF year >= vicflag(2) AND month >= vicflag(1) AND vicflag(2) > 0 THEN j = 2: GOTO finis
	IF control(i) >= vicflag(3) AND vicflag(3) > 0 THEN j = 3: GOTO finis
	IF income(i) / vptotal >= .01 * vicflag(4) AND vicflag(4) > 0 THEN j = 4: GOTO finis
	IF vicflag(5) > 0 AND capcity(3 - i) = 0 AND capcity(i) > 0 THEN j = 5: GOTO finis

	IF vicflag(6) > 0 THEN
		IF i = 1 THEN
			IF y = 0 THEN j = 7: GOTO finis
			IF x / y > vicflag(6) THEN j = 6: GOTO finis
		END IF
		IF i = 2 THEN
			IF x = 0 THEN j = 7: GOTO finis
			IF y / x > vicflag(6) THEN j = 6: GOTO finis
		END IF
	END IF

	CALL clrbot: COLOR 14
	IF vicflag(3) > 0 AND control(i) >= .9 * vicflag(3) THEN
		a$ = force$(i) + " side almost controls" + STR$(vicflag(3)) + " cities"
		CALL image2(a$, 4)
	END IF

	IF vicflag(4) > 0 AND income(i) / vptotal >= .009 * vicflag(4) THEN
		a$ = force$(i) + " side close to" + STR$(vicflag(4)) + " % of total income"
		CALL image2(a$, 4)
	END IF

	IF vicflag(6) > 0 AND x > 0 AND y > 0 THEN
		IF (i = 1 AND x / y > .9 * vicflag(6)) OR (i = 2 AND y / x > .9 * vicflag(6)) THEN
		a$ = force$(i) + " side close to" + STR$(vicflag(6)) + ":1 strength ratio"
		CALL image2(a$, 4)
		END IF
	END IF
	GOTO stale

finis:
	SELECT CASE j
		CASE IS < 3
		a$ = "TIME EXPIRED"
		CASE 3
		a$ = STR$(2.5 * vicflag(3)) + "% CITIES CONTROLLED"
		CASE 4
		a$ = STR$(vicflag(4)) + " % OF TOTAL INCOME"
		CASE 5
		a$ = "OBJECTIVE CAPTURED"
		CASE 6
		a$ = STR$(vicflag(6)) + ":1 ARMY STRENGTH RATIO"
		CASE 7
		a$ = "HOSTILITIES ENDED"
		CASE 8
		a$ = "NAPOLEON UTTERLY DEFEATED"
END SELECT
	CLS
	c = 1: IF i = 2 THEN c = 7
	LINE (0, 0)-(639, 479), 4, BF
	LINE (0, 40)-(550, 460), 0, BF
	CALL europe
	LINE (70, 140)-(485, 265), 0, BF
	LINE (50, 120)-(465, 250), c, BF
	LINE (50, 120)-(465, 250), 4, B
	COLOR 14
	t$ = force$(i) + " SIDE IS WINNING"
	CALL center(10, force$(i) + " SIDE IS WINNING WITH" + STR$(victory(i)) + " VP's")

	COLOR 15
	t$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"
	CALL center(12, t$)
	CALL center(14, a$)

	mtx$(0) = "End Game"
	mtx$(1) = "Yes"
	mtx$(2) = "No-Override"
	size = 2: colour = 4
	tlx = 27: tly = 18
	hilite = 15
	IF j = 7 THEN size = 1
	CALL menu(0)

	IF choose <> 1 THEN
		victory(3 - side) = victory(3 - side) + 300
		vicflag(j) = -1
		CALL europe
		CALL calendar
		EXIT SUB
	END IF
	IF j = 7 THEN victory(i) = victory(i) + 100

	thrill = i
	CALL europe: CALL report(100 + side, 0)
	COLOR 15: LOCATE 2, 27: t$ = force$(i) + " VICTORY  VP's=" + STR$(victory(i)): PRINT t$
death:
	COLOR 14: LOCATE 4, 40 - .5 * LEN(a$)
	IF history > 0 THEN
		CALL scribe(t$, 0)
		CALL scribe(a$, 0)
	END IF
	PRINT a$: CALL maxx
	EXIT SUB
stale:
    NEXT i
END SUB

SUB void (a, y)
  y = 0
FOR j = 1 TO 6
  x = matrix(a, j): IF x = 0 GOTO tally5
  IF cityp(x) = side AND occupied(x) > 0 THEN y = y + armysize(occupied(x))
	FOR k = 1 TO 6: m = matrix(x, k): IF m = 0 OR m = a GOTO tally4
	IF cityp(m) = side AND occupied(m) > 0 THEN y = y + .1 * armysize(occupied(m))
tally4:
	NEXT k
NEXT j
tally5:
END SUB
