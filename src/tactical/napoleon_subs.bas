'============================================================================
' NAPOLEON.BAS Subroutines - Extracted for WON integration
'============================================================================
' Main program code (lines 7-95) has been removed to prevent execution when included
' All SUB and FUNCTION definitions from original NAPOLEON.BAS are preserved here
'============================================================================
' Note: The original NAPOLEON.BAS had executable code at module level that would
' run when included. This file contains only SUB/FUNCTION definitions.
'============================================================================

DEFINT A-Z
DECLARE SUB align (index%, x%, y%)
DECLARE SUB randarm (k%)
DECLARE SUB randmap ()
REM $INCLUDE: 'nap10.bi'

SUB cannon (attack, defend)
	IF defend = 0 THEN uorder(attack) = 0: EXIT SUB
	IF Visible(defend) = 0 OR uorder(defend) = 99 THEN EXIT SUB
	CALL los(attack, defend, F, 0)

	SELECT CASE F
	CASE IS < 0
		EXIT SUB
	CASE 0
		IF (attack < m2 AND side = 1) OR (attack > m1 AND side = 2) THEN
			CALL clrbot: COLOR 14: PRINT "NOT IN LINE OF SIGHT !"; : TICK mdly!: CALL clrbot: EXIT SUB
		END IF
	CASE ELSE
	END SELECT

	CALL ranger(attack, vantage)
	PLAY "MF"
	d = 2 * ABS(unity(attack) - unity(defend)) + ABS(unitx(attack) - unitx(defend))
	IF d > vantage THEN EXIT SUB

	bonus = 2 * difficult - 4: IF difficult > 3 AND attack > m1 THEN bonus = bonus + 2
	CALL YouorMe(attack, F): IF F > 0 THEN bonus = 0
	CALL YouorMe(defend, F): IF F > 0 THEN CALL inspect(defend)

	u$ = LEFTY$(attack)
	movesleft = 0
	COLOR 4: IF attack > m1 THEN COLOR 9
	clrbot
	PRINT name$(attack);
	COLOR 11: PRINT " cannons fired at "; name$(defend);
	c = POS(0)
	y = 14 * unity(attack): x = 8 * unitx(attack)
	CIRCLE (x + 6, y + 6), 4, 14
	PAINT (x + 6, y + 6), 12, 14

	CALL los(attack, defend, F, 1)

	IF uorder(attack) > -1 THEN uorder(attack) = 0

	flag = 1 + bonus: IF RND > .8 THEN flag = flag + 1
	IF d > .5 * vantage THEN flag = .7 * flag: IF d > .7 * vantage THEN flag = .3 * flag
	IF RND > .9 THEN flag = flag + 3
	IF d < 3.5 + plus THEN flag = flag * 1.5 + 10 * RND + 6
	IF LEFTY$(defend) = CHR$(219) THEN unit$(defend) = "Infantry": flag = flag + 2
	flag = flag + 5 * RND
	IF LEFTY$(defend) = "L" THEN flag = flag + 2
	IF LEFTY$(defend) = "w" THEN unit$(defend) = RIGHT$(unit$(defend), LEN(unit$(defend)) - 1): CALL SHOWUNIT(defend)
	FOR i = 1 TO 5: IF quiet > 0 THEN SOUND 250 * RND + 37, .05
	CALL SHOWUNIT(defend): TICK .01
	PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET: TICK .02
	NEXT i
	dx = .01 * flag * strength(attack): killed = dx
	killed2 = .01 * flag * strength(defend): a = terrain(defend): IF a = 42 OR a = 254 THEN killed2 = .5 * killed2
	IF a = 46 OR a = 61 THEN killed2 = 2 * killed2
	IF a = 35 THEN killed2 = .3 * killed2
	IF killed2 < killed THEN killed = killed2
	IF killed < 1 THEN killed = 1 + 10 * RND: IF killed > strength(defend) THEN killed = strength(defend)
	LOCATE 23, c: PRINT "... killing "; killed; : TICK mdly!
	Visible(attack) = 1
	CALL SHOWUNIT(defend)
	CALL SHOWUNIT(attack)

	CALL despair(defend)

	dx = .05 * strength(defend)
	IF terrain(defend) = 35 THEN dx = .1 * strength(defend)
	IF 15 * RND < leader(defend) + morale(defend) THEN dx = dx + .02 * strength(defend)
	strength(defend) = strength(defend) - killed
	IF strength(defend) < 1 THEN CALL wipeout(defend): IF defend = 0 THEN EXIT SUB
	IF killed > dx THEN
		IF RND > .1 * morale(defend) THEN CALL retreat(defend, attack)
	END IF
	i = 1: IF defend > m1 THEN i = 2
	score&(i) = score&(i) + killed
sunk:
	toa(attack) = timex + 1 + 4 * RND
	IF morale(attack) < 3 THEN toa(attack) = toa(attack) + 1: IF morale(attack) < 2 THEN toa(attack) = toa(attack) + 3
	IF leader(attack) < 3 THEN toa(attack) = toa(attack) + 2
	toa(defend) = timex + 2 + 6 * RND: IF RND > .7 THEN toa(defend) = toa(defend) + 3
	CALL scrcol(2)
	IF unity(attack) = objy AND unitx(attack) = objx GOTO Explode
	CALL YouorMe(attack, F): IF F > 0 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0: GOTO Explode
	IF uorder(defend) = 0 AND rely > 1 AND RND > .4 + .1 * bold AND morale(defend) > 3 THEN
		IF LEFTY$(defend) <> "A" THEN
			uorder(defend) = 100 * unity(attack) + unitx(attack)
			CALL flee(defend)
		END IF
	END IF
Explode:
	pct! = 0: IF LEFTY$(attack) = "A" THEN pct! = .01
	IF RND < 1 - .003 * difficult - pct! THEN EXIT SUB
	COLOR 4: IF attack > m1 THEN COLOR 9

	x = .01 * strength(attack) + .05 * RND * strength(attack)
	IF x > 100 THEN x = 90 + 10 * RND
	IF quiet > 0 THEN FOR k = 1 TO 5: SOUND 40, 1: ATTENTION attack, 12: SOUND 50, .7: NEXT k
	PUT (8 * unitx(attack), 14 * unity(attack)), Explo, PSET
	CALL clrbot: COLOR 12: PRINT "CANNON EXPLODED !"; x; " of "; name$(attack); "'s men killed";
	toa(attack) = toa(attack) + 3: score&(3 - i) = score&(3 - i) + x: CALL scrcol(2)
	strength(attack) = strength(attack) - x
	CALL despair(attack)
	TICK mdly!: CALL SHOWUNIT(attack)
END SUB

SUB flash (index)
IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB
flick:
	y = 14 * unity(index): x = 8 * unitx(index)
	LINE (x, y)-(x + 12, y + 12), 12, B
	PUT (x, y), Explo, PSET: TICK .03
	CALL Tara(unitx(index), unity(index) + 1, 0)
	IF quiet > 0 THEN SOUND 300, .15
	CALL SHOWUNIT(index): TICK .01
END SUB

SUB help
SCREEN 9, , 1, 1
CLS
LINE (1, 321)-(639, 336), 3, BF
COLOR 11: LOCATE 24, 35: PRINT " press any key ";
COLOR 15: LOCATE 1, 1
PRINT "ICON  Unit Type"
a$ = "I" + CHR$(219) + "CGALSwR": unitx(0) = 1: strength(0) = 1
FOR k = 1 TO 9
unity(0) = k: Visible(0) = 1
unit$(0) = MID$(a$, k, 1): CALL SHOWUNIT(0)
COLOR 3: LOCATE k + 1, 6
	SELECT CASE k
	CASE 1
	PRINT "Infantry"
	CASE 2
	PRINT "Charging Infantry"
	CASE 3
	PRINT "Cavalry"
	CASE 4
	PRINT "General"
	CASE 5
	PRINT "Smooth Bore Cannon"
	CASE 6
	PRINT "Limbered Artillery"
	CASE 7
	PRINT "Hollow Square"
	CASE 8
	PRINT "WAITING Unit"
	CASE 9
	PRINT "ROUTED Unit"
	CASE ELSE
	END SELECT
NEXT k
LOCATE 1, 40: COLOR 15: PRINT "ICON Terrain ";
COLOR 4: PRINT "Move Turns ";
COLOR 2: PRINT "Defend Bonus"
x = 320
PUT (x, 14), Tterr, PSET
PUT (x, 28), Fterr, PSET
PUT (x, 42), Rterr, PSET
PUT (x, 56), Cterr, PSET
PUT (x, 70), Sterr, PSET
PUT (x, 84), Bridge, PSET
PUT (x, 98), Hterr, PSET
PUT (x, 112), Wterr, PSET
PUT (x, 126), Oterr, PSET
PUT (x, 140), Mterr, PSET
PUT (x, 154), Vterr, PSET
COLOR 3
a$ = "Trees Fort Road Clear Swamp Bridge Hill Water OBJCTV Mtn Village "

FOR k = 1 TO 11
x = INSTR(a$, " ")
t$ = LEFT$(a$, x - 1)
a$ = MID$(a$, x + 1)
LOCATE k + 1, 45: PRINT t$
NEXT k
COLOR 14
LOCATE 2, 57: PRINT "3 	  +5%" '*
LOCATE 3, 57: PRINT "2 	  +10%"'#
LOCATE 4, 57: PRINT "1 	   0"  '+
LOCATE 5, 57: PRINT "2 	   0"  '.
LOCATE 6, 57: PRINT "6 	  -5%" '=
LOCATE 7, 57: PRINT "1 	   0"  '[
LOCATE 8, 57: PRINT "4 	  +6%" '^
LOCATE 9, 56: PRINT "10 	 -15%"
LOCATE 10, 57: PRINT "2 	   0"
LOCATE 11, 57: PRINT "8 	  +9%"
LOCATE 12, 57: PRINT "2 	  +3%"
COLOR 4: LOCATE 4, 70: PRINT "*": LOCATE 5, 70: PRINT "*"
LOCATE 13, 45: PRINT "* Defend is -15% vs. Attack Cav"
LINE (420, 14)-(480, 168), 4, B
LINE (510, 14)-(580, 168), 2, B
COLOR 15: LOCATE 14, 2: PRINT "HOT KEYS": COLOR 3
LINE (1, 180)-(639, 195), 4, B
PRINT "  ire (ARTILLERY)"
PRINT "  imber/Unlimber (ARTILLERY)"
PRINT " i spire unit (GENERAL)"
PRINT "   cancel unit orders (GENERAL)"
PRINT "  harge (INFANTRY)"
PRINT "  quare Form/Unform (INFANTRY)"
PRINT "  ntelligence"
PRINT "  ove to destination"

LOCATE 21, 41: PRINT "iew Line of Sight"
LOCATE 22, 41: PRINT "ait Unit";

LOCATE 15, 41: PRINT "AME SCORE"
LOCATE 16, 41: PRINT "RDER OF BATTLE"
LOCATE 17, 41: PRINT "UIET SOUND TOGGLE"
COLOR 14
LOCATE 15, 1: PRINT " F": PRINT " L": LOCATE 17, 3: PRINT "N"
PRINT " X": PRINT " C": PRINT " S": PRINT " I": PRINT " M"
LOCATE 21, 40: PRINT "V": LOCATE 22, 40: PRINT "W"
COLOR 10: LOCATE 15, 40: PRINT "G": LOCATE 16, 40: PRINT "O"
LOCATE 17, 40: PRINT "Q"
LINE (0, 280)-(500, 310), 14, B, &H101
COLOR 14: LOCATE 22, 65: PRINT "(all units)"

TICK 99: strength(0) = 0: Visible(0) = 0
SCREEN 9, , 0, 0
TICK .5
END SUB

SUB iconload
SCREEN 9
LOCATE 1, 1: COLOR 11: PRINT "Loading Icons"
'----------------------------------------------------------------------------
'                            UNIT Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "stdicon.ega", Image(1)

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), IAlly
	GET (101, 115)-(116, 128), CAlly
	GET (101, 129)-(116, 142), AAlly
	GET (101, 143)-(116, 156), GAlly
       
	GET (117, 101)-(132, 114), IFrench
	GET (117, 115)-(132, 128), CFrench
	GET (117, 129)-(132, 142), AFrench
	GET (117, 143)-(132, 156), GFrench
'----------------------------------------------------------------------------
'                            UNIT Icons..... ALTICON
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "alticon.ega", Image(1)

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), LAAlly
	GET (101, 115)-(116, 128), HSFrench
	GET (101, 129)-(116, 142), WFrench
	GET (101, 143)-(116, 156), RAlly

	GET (117, 101)-(132, 114), LAFrench
	GET (117, 115)-(132, 128), HSAlly
	GET (117, 129)-(132, 142), Wally
	GET (117, 143)-(132, 156), RFrench
'----------------------------------------------------------------------------
'                            Terrain Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "terrain.ega", Image(1)
	PUT (200, 100), Image, PSET
	GET (200, 101)-(215, 114), Cterr
	GET (200, 115)-(215, 128), Hterr
	GET (200, 129)-(215, 142), Sterr
	GET (200, 143)-(215, 156), Fterr
	GET (217, 101)-(232, 114), Tterr
	GET (217, 115)-(232, 128), Mterr
	GET (217, 129)-(232, 142), Oterr
	GET (217, 143)-(232, 156), Rterr
'----------------------------------------------------------------------------
'                         Miscellaneous Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "misc.ega", Image(1)
	PUT (300, 100), Image, PSET
	GET (300, 101)-(315, 114), Wterr
	GET (300, 115)-(315, 128), Vterr
	GET (300, 129)-(315, 142), Explo
	GET (300, 143)-(315, 156), Bridge
	GET (317, 101)-(332, 114), Xhair
	GET (317, 115)-(332, 128), Death
	GET (317, 129)-(332, 142), Boat
END SUB

SUB los (index, Enemy, F, flag)
'  F=-1 : friendly  F=0 : no LOS    F=1 : Enemy in LOS
' flag=cursor flag   0=invisible  1=visible
	IF lineofsight = 0 THEN F = 1: EXIT SUB
	F = 0
	IF index = Enemy THEN F = -1: EXIT SUB

	plus = 1
	SELECT CASE terrain(index)
		CASE 94
		plus = 2
		CASE 176
		plus = 5
		CASE 239
		plus = 3
	END SELECT

	xnew = unitx(index): ynew = unity(index)
	spin = 0
DO
	spin = spin + 1: IF spin > 99 THEN F = 0: EXIT SUB
	dxs = SGN(unitx(Enemy) - xnew)
	dys = SGN(unity(Enemy) - ynew)
	dx = ABS(unitx(Enemy) - xnew)
	dy = ABS(unity(Enemy) - ynew)
	IF dx > 4 * dy THEN xnew = xnew + 2 * dxs: GOTO hilit
	IF dxs = 0 THEN dxs = 1: IF xnew > 28 THEN dxs = -1
	xnew = xnew + dxs: ynew = ynew + dys
hilit:
	z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
	IF (z = 42 OR z = 254) THEN plus = plus - 1
	IF z = 94 THEN plus = plus - 2
	IF z = 239 THEN plus = plus - 5
	IF xnew = unitx(Enemy) AND ynew = unity(Enemy) THEN F = 1: EXIT SUB
	IF plus < 1 THEN F = 0: EXIT SUB
	IF flag > 0 THEN PUT (8 * xnew, 14 * ynew), Xhair, XOR: TICK .03: PUT (8 * xnew, 14 * ynew), Xhair, XOR
LOOP
END SUB

SUB musket (attack, defend, z)
'============================================================================
'                                Attacker fires first
'============================================================================
CALL YouorMe(attack, F)
PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET
IF F = 0 THEN
	roll! = .05 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
ELSE
	roll! = .15
END IF
t$ = LEFTY$(defend)
IF t$ = "w" THEN unit$(defend) = MID$(unit$(defend), 2): CALL SHOWUNIT(defend)

CALL proximity(attack, bonus)
fbase = .2 * z * strength(attack)
SELECT CASE terrain(defend)
	CASE 94: roll! = .09
	CASE 239: roll! = .06
	CASE 61: roll! = .2
	CASE 42: roll! = .1
	CASE 58, 254: roll! = .12
	CASE 35: roll! = .05
	CASE 176: roll! = 2 * roll!
	CASE ELSE
END SELECT

IF morale(attack) > 3 THEN roll! = roll! + .05: IF morale(attack) = 5 THEN roll! = roll! + .05
IF leader(attack) > 3 THEN roll! = roll! + .05: IF leader(attack) = 5 THEN roll! = roll! + .05
IF morale(attack) < 2 THEN roll! = roll! - .1
IF leader(attack) < 2 THEN roll! = roll! - .1
u$ = LEFTY$(attack): IF u$ = "G" THEN roll! = roll! - .2  'General Unit
IF u$ = "L" THEN roll! = .2 * roll!   'Limbered

IF pct# < .8 THEN roll! = .5 * roll!                       'scale down light attacks
IF roll! < .01 THEN roll! = .01                            'Minimum
'============================================================================
'                      Bonus for Cavalry Charge & Charging Infantry
'============================================================================
flag = 0
IF (terrain(defend) = 43) OR (terrain(defend) = 46) AND LEFTY$(attack) = "C" THEN
	IF t$ = "C" THEN
reroll:
		x = 0: x1 = 0
		IF RND < .15 * morale(attack) THEN x = 1
		IF RND < .15 * morale(defend) THEN x1 = 1
		IF x = x1 GOTO reroll
		IF x = 0 THEN
			CALL routed(attack, 3)
		ELSE
			CALL routed(defend, 3)
		END IF
	END IF
	IF t$ = "I" OR t$ = "G" OR t$ = CHR$(219) OR t$ = "R" THEN
smash:
		roll! = roll! + .1
		bonus = bonus + .1 * leader(attack)
		flag = 1
		IF RND > .5 THEN CALL routed(defend, 3)
		CALL SHOWUNIT(defend): toa(defend) = timex + z
	ELSE
		IF LEFTY$(defend) = "S" AND RND < .18 * morale(defend) THEN
			roll! = .5 * roll!
			IF RND > .18 * morale(attack) THEN
				CALL routed(attack, 3)
			END IF
		ELSE
			GOTO smash
		END IF
	END IF
END IF
IF LEFTY$(attack) = CHR$(219) THEN roll! = roll! + .02: bonus = bonus + .05 * leader(attack)
IF LEFTY$(defend) = "R" THEN roll! = roll! * 2

index = 2: IF attack > m1 THEN index = 1

CALL normal(fbase * roll!, fbase * roll! * (1 - roll!), killed)
killed = killed + bonus
IF killed < 1 THEN killed = 1
IF killed > strength(defend) THEN killed = strength(defend)
dx = killed
CALL flash(defend)
FOR k = 1 TO .02 * killed
IF killed > 49 THEN score&(index) = score&(index) + 50: CALL scrcol(2): dx = dx - 50
CALL flash(defend)
NEXT k
score&(index) = score&(index) + dx
CALL scrcol(2)
CALL SHOWUNIT(defend)

'============================================================================
'                                Defender returns fire
'============================================================================
CALL YouorMe(defend, F)
IF F = 0 THEN
	roll! = .053 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
ELSE
	roll! = .16
END IF

fbase = .2 * z * strength(defend)
CALL proximity(defend, bonus)
SELECT CASE terrain(attack)
	CASE 94: roll! = .1
	CASE 239: roll! = .07
	CASE 61: roll! = .21
	CASE 42: roll! = .11
	CASE 58, 254: roll! = .13
	CASE 35: roll! = .06
	CASE 176: roll! = 2 * roll!
	CASE ELSE
END SELECT
IF morale(defend) > 4 THEN roll! = roll! + .05: IF morale(defend) = 5 THEN roll! = roll! + .05
IF leader(defend) > 4 THEN roll! = roll! + .05: IF leader(defend) = 5 THEN roll! = roll! + .05
IF morale(defend) < 2 THEN roll! = roll! - .1
IF leader(defend) < 2 THEN roll! = roll! - .1
SELECT CASE t$
	CASE "G"
		roll! = roll! - .1
	CASE "L"
		roll! = .05
	CASE "R"
		roll! = .02
	CASE "S"
		IF u$ <> "C" THEN roll! = roll! / 4
END SELECT
IF u$ = "L" THEN roll! = 5 * roll!: IF roll! > 1 THEN roll! = 1

IF pct# < .8 THEN roll! = .5 * roll!
IF roll! < .02 THEN roll! = .02
IF bonus < .05 * killed THEN bonus = .05 * killed

CALL normal(fbase * roll!, fbase * roll! * (1 - roll!), killed2)
killed2 = killed2 + bonus
IF killed2 < 1 THEN killed2 = 1
IF killed2 > strength(attack) THEN killed2 = strength(attack)
dx = killed2
CALL flash(attack)
FOR k = 1 TO .02 * killed2
IF killed2 > 49 THEN score&(3 - index) = score&(3 - index) + 50: CALL scrcol(2): dx = dx - 50
CALL flash(attack)
NEXT k
score&(3 - index) = score&(3 - index) + dx
CALL scrcol(2)
CALL SHOWUNIT(attack)

toa(attack) = timex + z: IF leader(attack) < 3 THEN toa(attack) = toa(attack) + 1
safe:
	clrbot
	COLOR 12: PRINT " CASUALTIES ";
	a$ = sname$(1): COLOR 7: IF attack > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 20: PRINT " "; a$; killed2;
	a$ = sname$(1): COLOR 7: IF defend > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 50: PRINT " "; a$; killed;
	TICK mdly!

	pra! = killed2 / (strength(attack) + 1) - .01 * (morale(attack) + leader(attack))
	prd! = killed / (strength(defend) + 1) - .01 * (morale(defend) + leader(defend))
	xold = unitx(attack): yold = unity(attack): x2 = unitx(defend): y2 = unity(defend)
       
	strength(attack) = strength(attack) - killed2
	CALL wipeout(attack): IF attack = 0 THEN morale(defend) = morale(defend) + 1

	strength(defend) = strength(defend) - killed: CALL wipeout(defend): IF defend = 0 THEN morale(attack) = morale(attack) + 1

	x0 = 0
	IF INSTR("AL", t$) > 0 AND INSTR("AL", u$) = 0 AND artcap > 0 THEN x0 = INT(killed / 20): IF strength(defend) < 1 THEN IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0): GOTO seeme
	IF strength(defend) < 1 THEN IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0): GOTO seeme
'...........................................................................
'                       check for attacker retreat
'...........................................................................
	IF attack = 0 GOTO coffin
	CALL proximity(attack, bonus)
	r! = .02: IF bonus < 10 THEN r! = .01
	IF pra! >= r! THEN uorder(attack) = 0
	rflag = 0
	pct# = .02 * difficult: IF bonus > 9 THEN pct# = pct# + .03
	IF LEFTY$(attack) = "C" AND flag = 0 THEN pct# = pct# - .01
	IF pra! >= pct# THEN CALL retreat(attack, defend): rflag = 1
	IF prd! < pct# AND INSTR("AL", t$) = 0 THEN CALL pursue(defend, xold, yold, 0)
'...........................................................................
'                       check for defender retreat
'...........................................................................
coffin:
	IF defend = 0 THEN toa(attack) = timex + 1: GOTO seeme

	CALL proximity(defend, bonus)
	r! = .02: IF bonus < 10 THEN r! = .01
	IF prd! >= r! AND uorder(defend) > -1 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0
	pct# = .05: IF bonus > 9 THEN pct# = pct# + .03

	IF morale(defend) > 4 THEN pct# = pct# + .02
	IF flag = 1 AND LEFTY$(defend) <> "R" THEN pct# = pct# - .05  'cavalry charge
	IF LEFTY$(attack) = CHR$(219) THEN pct# = pct# - .02

	IF prd! >= .07 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0
	IF terrain(defend) = 35 THEN pct# = pct# + .03
	IF prd! >= pct# THEN CALL retreat(defend, attack)

	IF rflag = 0 AND pra! < pct# - .01 AND INSTR("AL", u$) = 0 THEN CALL pursue(attack, x2, y2, 0)
seeme:
	IF LEFTY$(attack) = CHR$(219) THEN unit$(attack) = "Infantry"
	CALL SHOWUNIT(attack): CALL SHOWUNIT(defend)
END SUB

SUB order
	flag = 0
	CALL BuffClear
'============================================================================
'                       Find Time of Next Action
'============================================================================
	told = timex
	CALL lowtime
	IF bold < 4 AND timex = .5 * timelimit AND possess <> 3 - side THEN bold = 4
	IF timex > .8 * timelimit AND possess <> 3 - side THEN bold = 5
notime:
	IF timelimit - timex <= 0 THEN CALL clrbot: COLOR 14: PRINT "Time expired - battle of "; SCENARIO$; " is over "; : TICK 99: CALL expire: file$ = CHR$(219): EXIT SUB
	FOR k = 1 TO 2: CALL brittle(k): NEXT k

	CALL scrcol(2)

	FOR active = 1 TO bigg(2): CALL BuffClear
	t$ = LEFTY$(active)
	SELECT CASE t$
		CASE "A"
			movesleft = 1
		CASE "I", "G", "L"
			movesleft = 2
		CASE CHR$(219)
			movesleft = 3
		CASE "C"
			movesleft = 4
		CASE "R"
routedunit:
			movesleft = 4
			CALL routed(active, 0)
			IF LEFTY$(active) = "R" THEN
				IF uorder(active) = 0 THEN CALL flee(active)
				CALL cupdate(active)
				IF uorder(active) = 0 THEN movesleft = 0
				GOTO asleep
			END IF
		CASE "S"
			uorder(active) = 0
		CASE ELSE
			movesleft = 2
	END SELECT

	IF strength(active) < 1 OR toa(active) > timex THEN movesleft = 0: GOTO snore
	IF uorder(active) = 99 THEN CALL CanPlaceUnit(active): IF uorder(active) = 99 THEN movesleft = 0: GOTO sleep2
	IF t$ = "w" THEN CALL rest(active): uorder(active) = 0: GOTO sleep2
	flag = 1
stillgoing:
	CALL YouorMe(active, F): IF F = 0 THEN GOTO otherside: GOTO asleep
'============================================================================
human:
	y0 = 14 * unity(active): x0 = 8 * unitx(active)
	IF rely = 1 OR INSTR("A", t$) > 0 THEN IF uorder(active) > 99 THEN uorder(active) = 0

	clrbot
	IF uorder(active) > 0 THEN
		CALL cupdate(active)
		IF uorder(active) = 1 THEN movesleft = 0
		GOTO asleep
	END IF

	CALL inspect(active)
	IF flag > 0 THEN
		FOR k = 1 TO 2: ATTENTION active, 14: NEXT k
		IF quiet > 0 THEN SOUND 1200, .1
	END IF
	flag = 0

	CALL ranger(active, vantage)
wait2:
	IF LEFTY$(active) = "R" GOTO routedunit
	LITEUP x0, y0, 14
	CALL DrawCommandLine(active, t$, limber)
'============================================================================
'                     Get Keyboard Command
'============================================================================
wait3:
	DO
		commnd$ = INKEY$
	LOOP WHILE commnd$ = ""
kez:
	a = LEN(commnd$): commnd$ = RIGHT$(commnd$, 1)
	z = ASC(UCASE$(commnd$))
SELECT CASE z
	CASE 19: recon = 1 - recon
		SOUND 1999, .5
		FOR k = 1 TO bigg(2)
			IF strength(k) > 0 AND recon = 0 AND Visible(k) = 0 THEN CALL Tara(unitx(k), unity(k) + 1, terrain(k))
			CALL SHOWUNIT(k)
		NEXT k

	CASE 27: CALL PlayNoise1: GOTO wait2
	CASE 32: CALL BUTTON(27, 25, 4, "rest", 1)
		 CALL rest(active): GOTO asleep
	CASE 59  'F1
		CALL help
		GOTO wait3
	CASE 61  'F3
		CALL mainmap: CALL refresh: CALL inspect(active)
	CASE 64:
		IF t$ = "G" THEN
		dx = 5
		CALL BUTTON(58, 25, 4, "(X)ancel", 0)
		GOTO fodder
		END IF
	CASE 67:
		 IF a = 2 THEN
			PCOPY 0, 1
			SCREEN 9, , 1, 1
			CALL BUTTON(70, 21, 1, "F9:RETREAT", 1)
			LINE (110, 110)-(360, 210), 0, BF
			LINE (100, 100)-(350, 200), 5, BF
			LINE (110, 110)-(340, 190), 15, B
			COLOR 15: LOCATE 10, 20: PRINT "STRATEGIC RETREAT ?"
			LOCATE 12, 22: PRINT "(20% PENALTY!)"
			TICK 3
			a$ = "RETREAT?"
			CALL YesNo(a$)
			IF a$ = "Y" THEN
				score&(side) = score&(side) + .2 * strength(side)
				CALL over(side)
			END IF
			SCREEN 9, , 0, 0
		 END IF
		IF t$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "Infantry": toa(active) = timex + 1: CALL BUTTON(58, 25, 4, "Charge", 1): : CALL PlayNoise1: GOTO asleep
	CASE 70
		IF INSTR("A", t$) > 0 THEN dx = 1: GOTO fodder
	CASE 71: IF a = 2 GOTO moven
		CALL RefreshAhead(active)
	CASE 72: IF a = 2 GOTO moven
	CASE 73: IF a = 2 GOTO moven
		 CALL BUTTON(33, 25, 4, "Intell", 1)
		 dx = 3: GOTO fodder
	CASE 75: IF a = 2 GOTO moven
	CASE 76:
		 IF INSTR("AL", t$) > 0 THEN
			CALL BUTTON(58, 25, 4, "Limber", 1)
			CALL limbo(active, -1): GOTO asleep
		 END IF
	CASE 77: IF a = 2 GOTO moven
		dx = 2: GOTO fodder
	CASE 78:
		 IF t$ = "G" THEN
		 CALL BUTTON(67, 25, 4, "i(N)spire", 1)
		 dx = 4: GOTO fodder
		 END IF
	CASE 79: IF a = 2 GOTO moven
		 CALL report: CALL inspect(active): GOTO wait2
	CASE 80: IF a = 2 GOTO moven
	CASE 81: IF a = 2 GOTO moven
		quiet = 1 - quiet: CALL scrcol(12)
		IF quiet > 0 THEN SOUND 1700, .3
		GOTO wait3
	CASE 82: CALL BUTTON(27, 25, 4, "rest", 1)
		 CALL rest(active): GOTO asleep
	CASE 83
		IF LEFTY$(active) = "S" THEN
			CALL squares(active, 1)
			GOTO asleep
		END IF
		IF LEFTY$(active) = "I" THEN
			CALL squares(active, 2)
			toa(index) = timex + 2
			GOTO asleep
		END IF
	CASE 84
		CALL UpdateAllTerrain
		CALL clrbot: PRINT "Terrain"; TAB(60); "(press a key)...";
		TICK 5
		CALL refresh
	CASE 86
		PCOPY 0, 1
		SCREEN 9, , 1, 1
		CALL vistarg(active, 1)
		CALL ranger(active, vantage)
		FOR k = 2 TO 21
			s = 2: IF INT(.5 * k) * 2 = k THEN s = 3
			FOR j = s TO 54 STEP 2
				unitx(0) = j: unity(0) = k - 1
				terrain(0) = ASC(MID$(sdtext$(unity(0) + 1), unitx(0)))
				d = 2 * ABS(unity(active) - unity(0)) + ABS(unitx(active) - unitx(0))
				IF d <= vantage THEN
					CALL los(active, 0, F, 0)
					IF F <> 0 THEN PUT (8 * j, 14 * (k - 1)), Xhair, XOR
				END IF
			NEXT j
		NEXT k
		CALL clrbot: PRINT "Visible Enemy Units and Terrain"; TAB(60); "(press a key)...";
		TICK 99
		SCREEN 9, , 0, 0
	CASE 87: CALL BUTTON(41, 25, 4, "Wait", 1): CALL WaitUnit(active): GOTO asleep
	CASE 88: IF t$ = "G" THEN CALL CancelOrders(active, side, x, y): IF y > 0 GOTO asleep ELSE GOTO wait2
	CASE ELSE
		IF a < 2 THEN clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
END SELECT
GOTO wait2
'============================================================================
' orders:   <0=dug in   0=none   1=blocked  99=hidden  >99=moveto destination
'============================================================================
'                     Move Unit & Check for Sighting
'============================================================================
moven:
	IF LEFTY$(active) = "S" THEN CALL clrbot: COLOR 14: PRINT "Hollow squares may not move"; : CALL PlayNoise1: GOTO wait3
	IF limber > 0 AND INSTR("A", t$) > 0 THEN
		IF LEFTY$(active) <> "L" THEN CALL limbo(active, 2): IF LEFTY$(active) = "L" GOTO asleep ELSE GOTO wait2
	END IF
	xloc = unitx(active): yloc = unity(active)
	CALL curser(commnd$, xloc, yloc)
	IF yloc = unity(active) AND xloc = unitx(active) THEN CALL PlayNoise1: GOTO wait3
	CALL placeunit(xloc, yloc, active)
	IF uorder(active) = 1 THEN COLOR 14: clrbot: PRINT "Cannot move in that direction "; : CALL PlayNoise2: CALL TICK(1): uorder(active) = 0: GOTO wait2
	CALL inspect(active)
asleep:
	CALL SHOWUNIT(active)
	IF INSTR("AL", t$) > 0 THEN CALL refresh
sleep2:
	IF strength(active) > 0 AND uorder(active) <> 99 THEN CALL see(active)
snore:
	IF uorder(active) = 1 THEN uorder(active) = 0
	IF movesleft > 0 GOTO stillgoing
	IF toa(active) <= timex THEN toa(active) = timex + 1
	CALL valid(active)
NEXT active
FOR s = 1 TO 2
IF elan(s) < 30 AND waver(s) = 0 THEN
	waver(s) = 1
	PCOPY 0, 1
	SCREEN 9, , 1, 1
	LINE (90, 110)-(410, 200), 0, BF
	LINE (80, 100)-(400, 190), 4, BF
	LINE (85, 105)-(395, 185), 154, B
	LOCATE 11, 17: PRINT sname$(s); " army beginning to waver!"
'1812 Finale
	IF quiet > 0 THEN PLAY "T220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
	TICK 99
	SCREEN 9, , 0, 0
END IF
NEXT s
EXIT SUB
'============================================================================
'                               Enemy Update
'============================================================================
' GOSUB otherside converted to SUB - Note: Uses GOTO for flow control within order SUB
' This is a complex function that would require significant refactoring to eliminate all GOTOs
' For now, keeping the label but converting GOSUB call to direct code execution
' The label remains for GOTO targets within the order SUB
otherside:
IF flag = 0 THEN CALL kleer: flag = 1
COLOR 11: CALL clrbot: LOCATE 23, 50: PRINT name$(active); "'s TURN";
IF strength(active) < 1 THEN movesleft = 0: RETURN
'............................................................................
	a$ = LEFTY$(active)
IF a$ = "S" THEN
	CALL Near1(active, Enemy, d)
	IF timex > .8 * timelimit AND possess <> 3 - side AND bold > 3 THEN
		CALL squares(active, 1)
		GOTO asleep
	END IF

	IF Enemy > 0 AND LEFTY$(Enemy) = "C" AND d < 9 THEN
		movesleft = 0
		GOTO asleep
	ELSE
		CALL squares(active, 1)
		GOTO asleep
	END IF
END IF
IF a$ = "I" OR a$ = CHR$(219) AND (terrain(active) = 43 OR terrain(active) = 46) THEN
	CALL Near1(active, Enemy, d)
	IF Enemy > 0 AND LEFTY$(Enemy) = "C" AND d < 9 THEN
		x = 1.5: IF possess = 3 - side THEN x = 2
		IF bold > 3 THEN x = x * 3 / bold
		IF strength(active) < x * strength(Enemy) THEN
			IF unitx(Enemy) <> objx AND unity(Enemy) <> objy THEN
				CALL squares(active, 2)
				GOTO asleep
			END IF
		END IF
	END IF
	IF a$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "Infantry": CALL SHOWUNIT(active): toa(active) = timex + 1: RETURN
END IF
'............................................................................
IF INSTR("AL", a$) THEN
	CALL Near2(active, Enemy, d)
	IF INSTR("A", a$) > 0 AND Enemy > 0 THEN CALL cannon(active, Enemy): CALL refresh: RETURN
	IF INSTR("A", a$) > 0 AND Enemy = 0 THEN CALL limbo(active, 0): RETURN
	IF Enemy > 0 AND a$ = "L" THEN CALL limbo(active, 0): RETURN
END IF
'............................................................................
d = 2 * ABS(unity(active) - objy) + ABS(unitx(active) - objx)
IF d < 8 AND possess <> 3 - side AND a$ <> "R" THEN uorder(active) = 100 * objy + objx
				
IF uorder(active) > 0 THEN
	CALL cupdate(active)
	IF uorder(active) = 1 THEN movesleft = 0
	RETURN
END IF
IF morale(active) < 3 THEN CALL rest(active): RETURN
CALL general(active)
CALL valid(active)
speed:
DO
	IF uorder(active) > 0 THEN CALL cupdate(active)
	CALL see(active)
	IF uorder(active) = 0 OR movesleft = 0 THEN EXIT DO
LOOP
movesleft = 0
RETURN
'============================================================================
'                              Sounds
'============================================================================
' GOSUB labels converted to SUBs - noise functions
SUB PlayNoise1
	IF quiet > 0 THEN SOUND 1900, 1
END SUB

SUB PlayNoise2
	IF quiet > 0 THEN SOUND 400, .7
END SUB

SUB PlayNoise3
	IF quiet > 0 THEN SOUND 600, 2: SOUND 900, 2
END SUB
'============================================================================
'                               Stats on Unit Under Cursor
'============================================================================
' GOSUB stats converted to SUB
SUB ShowUnitStats (id AS INTEGER, dx AS INTEGER)
	DIM F AS INTEGER
	CALL inspect(id)
	CALL YouorMe(id, F): IF F > 0 THEN IF uorder(id) > 99 AND dx <> 4 THEN CALL target(id): CALL ShowIntelligenceLine
END SUB
'============================================================================
' GOSUB cline converted to SUB
SUB DrawCommandLine (active AS INTEGER, t$ AS STRING, limber AS INTEGER)
	COLOR 14: CALL clrbot
	PRINT "UNIT"; active; name$(active);
	LINE (4, 334)-(639, 349), 8, BF
	COLOR 8
	CALL BUTTON(27, 25, 4, "rest", 0)
	CALL BUTTON(33, 25, 4, "Intell", 0)
	CALL BUTTON(41, 25, 4, "Wait", 0)
	CALL BUTTON(70, 21, 1, "F9:RETREAT", 0)
	SELECT CASE t$
		CASE "A", "L"
			IF limber > 0 THEN
			CALL BUTTON(58, 25, 4, "Limber", 0)
			END IF
		CASE "I"
		IF morale(active) > 2 AND (terrain(active) = 46 OR terrain(active) = 43) THEN
			CALL BUTTON(58, 25, 4, "Charge", 0)
		END IF
		CASE "G"
			CALL BUTTON(58, 25, 4, "(X)ancel", 0)
			CALL BUTTON(67, 25, 4, "i(N)spire", 0)
		CASE ELSE
	END SELECT
	COLOR 11
END SUB
' GOSUB wait5 converted to SUB - Uses loop instead of recursion
SUB WaitForKeypress (commnd$ AS STRING, dxs AS INTEGER, dys AS INTEGER)
	DIM a AS INTEGER
	DO
		commnd$ = INKEY$
		IF commnd$ <> "" THEN
			dxs = ASC(UCASE$(commnd$)): dys = LEN(commnd$)
			IF dxs = 27 OR dxs = 32 OR dxs = 76 OR dxs = 88 THEN EXIT DO
			IF dxs = 13 THEN EXIT DO
			IF dys = 1 AND ASC(commnd$) > 48 AND ASC(commnd$) < 58 THEN EXIT DO
			IF dys >= 2 THEN
				a = LEN(commnd$)
				commnd$ = RIGHT$(commnd$, 1)
				SELECT CASE ASC(commnd$)
				CASE 59
					CALL help
				CASE 68
					IF a = 2 THEN CLS : file$ = CHR$(219): EXIT DO
				CASE ELSE
					EXIT DO
				END SELECT
			END IF
		END IF
	LOOP
END SUB
'---------------------------------------------------------------------------
' Late Arrivals
'---------------------------------------------------------------------------
' GOSUB canplace converted to SUB
SUB CanPlaceUnit (active AS INTEGER)
	DIM id AS INTEGER
	DIM s AS INTEGER
	DIM a$ AS STRING
	DIM F AS INTEGER
	DIM Enemy AS INTEGER
	DIM d AS INTEGER
	DIM k AS INTEGER
	DIM x AS INTEGER
	DIM y AS INTEGER
	DIM t$ AS STRING
	
	CALL whois(unitx(active), unity(active), id, active)
	IF id > 0 THEN EXIT SUB
	s = 1: IF active > m1 THEN s = 2
	uorder(active) = 0: a$ = unit$(active)
	CALL YouorMe(active, F): IF F > 0 THEN Visible(active) = 1: a$ = name$(active)
	clrbot
	COLOR 15: PRINT sname$(s); " "; a$; " is joining the battle";
	CALL see(active)
	t$ = LEFTY$(active)
	IF limber > 0 AND INSTR("A", t$) > 0 THEN unit$(active) = "L" + unit$(active): t$ = LEFTY$(active)
	y = 14 * unity(active): x = 8 * unitx(active)

	IF Visible(active) > 0 THEN
		FOR k = 1 TO 5
		ATTENTION active, 15: IF quiet > 0 THEN CALL PlayNoise1
		NEXT k
	END IF

	CALL YouorMe(active, F)
	IF F > 0 AND t$ = "G" THEN EXIT SUB
	CALL Near2(active, Enemy, d)
	TICK .5 * mdly!
	IF Enemy = 0 OR RND > .5 THEN uorder(active) = 100 * objy + objx: EXIT SUB
	IF t$ = "A" THEN CALL cannon(active, Enemy): EXIT SUB
	uorder(active) = 100 * unity(Enemy) + unitx(Enemy)
	IF F > 0 THEN TICK .2 * mdly!
END SUB
'============================================================================
'                               cancel orders
'============================================================================
' GOSUB cancel converted to SUB
SUB CancelOrders (active AS INTEGER, side AS INTEGER, x AS INTEGER, y AS INTEGER)
	DIM s AS INTEGER
	DIM F AS INTEGER
	DIM i AS INTEGER
	
	CALL clrbot: PRINT " General "; name$(active); " cancelling orders : ";
	x = 0: y = 0: s = 1: F = bigg(side): IF side = 2 THEN s = m2
	FOR i = s TO F
	IF strength(i) = 0 OR uorder(i) < 1 OR uorder(i) = 99 GOTO cancel_corpse
	IF LEFTY$(i) = "R" GOTO cancel_corpse
	y = y + 1
	IF RND < .2 * leader(active) THEN
		uorder(i) = 0
		CALL ATTENTION(i, 13)
		IF quiet > 0 THEN SOUND 2900, .1: TICK .02
		GOTO cancel_corpse
	END IF
	x = x + 1
cancel_corpse:
	NEXT i
	IF y = 0 THEN PRINT "NO UNITS UNDER ORDERS"; : TICK .2 * mdly!: CALL clrbot: EXIT SUB
	movesleft = movesleft - 1
	PRINT y - x; " of "; y; " units obeyed"; : TICK .2 * mdly!: CALL clrbot
END SUB
'============================================================================
'                               Score Hot Key
'============================================================================
' GOSUB ahead converted to SUB
SUB RefreshAhead (active AS INTEGER)
	CALL expire
	CALL mainmap: CALL refresh: CALL inspect(active)
END SUB
'============================================================================
'                                  Inspire Unit
'============================================================================
RAlly:
	CALL whois(xloc, yloc, index, active)
	IF index = 0 OR (side = 1 AND index > m1) OR (side = 2 AND index < m2) GOTO wait2
	IF LEFTY$(index) = "w" THEN unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1): CALL SHOWUNIT(index): GOTO wait2
	IF d > .8 * vantage THEN COLOR 12: clrbot: PRINT "Too far to communicate"; : TICK mdly!: GOTO wait2
	clrbot
	IF leader(active) + morale(active) + xper(active) + 2 * RND < leader(index) + morale(index) + xper(index) THEN COLOR 12: PRINT name$(active); " cannot rally "; unit$(index); : leader(active) = leader(active) - 1: GOTO payit
	COLOR 11: PRINT unit$(index); " is rallying...";
	FOR k = 1 TO 3: ATTENTION index, 14
	IF quiet > 0 THEN SOUND 900, 1: SOUND 999, .7
	NEXT k
	IF LEFTY$(index) <> "R" THEN
		toa(active) = toa(index): toa(index) = timex
		IF morale(index) < 4 THEN morale(index) = morale(index) + 1
	ELSE
		unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		CALL SHOWUNIT(index)
	END IF
	
	uorder(index) = 0
payit:
	CALL despair(active)
	CALL SHOWUNIT(active)
	CALL valid(active)
	movesleft = 0
	TICK 2
	GOTO asleep
'============================================================================
'                                  Move order
'============================================================================
here:
	COLOR 14: CALL clrbot
	IF toa(active) <= timex THEN toa(active) = timex + 1
	IF dx = 5 THEN
		PRINT unit$(active); " "; name$(active); " has given orders to move to ("; xloc; ","; yloc; ") and";
		s = 1: F = bigg(1): IF side = 2 THEN s = m2: F = bigg(2)
		dy = 0: FOR k = s TO F
			d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
			IF d <= .5 * vantage THEN
				IF strength(k) > 0 AND uorder(k) > -1 AND uorder(k) < 99 THEN uorder(k) = uorder(active): dy = dy + 1
			END IF
		NEXT k
		PRINT dy; "units obeyed";
		CALL FlashCursor(xloc, yloc)
	END IF

	IF dx <> 2 GOTO wait2
	uorder(active) = 100 * yloc + xloc
	IF limber > 0 AND INSTR("A", t$) > 0 THEN
		CALL limbo(active, 2)
		CALL FlashCursor(xloc, yloc)
		IF LEFTY$(active) = "L" GOTO asleep ELSE GOTO wait2
	END IF
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
	IF d = 0 GOTO wait2
	IF dx = 2 AND d < 4 THEN
		uorder(active) = 100 * yloc + xloc
		CALL cupdate(active)
		IF uorder(active) = 1 THEN uorder(active) = 0: CALL TICK(.5): CALL FlashCursor(xloc, yloc): GOTO wait2
		uorder(active) = 0
		GOTO asleep
	ELSE
		CALL target(active)
		CALL FlashCursor(xloc, yloc)
		CALL clrbot
		GOTO asleep
	END IF
		GOTO asleep
'============================================================================
'           Cursor Controlled Movements  1=cannon  2=move  3=spy
'============================================================================
fodder:
SELECT CASE dx
      CASE 1  'cannon
	IF limber = 1 AND LEFTY$(active) = "L" THEN CALL limbo(active, 2): IF LEFTY$(active) = "L" THEN EXIT SUB
	CALL vistarg(active, 0)
	COLOR 11: clrbot: PRINT "CANNONADE > RANGE:"; vantage; TAB(25); "DISTANCE:"; TAB(60); "TERRAIN:";
     
      CASE 2, 5 'move
	IF rely = 1 THEN COLOR 12: CALL clrbot: PRINT "MAXIMUM RELIABILITY : Move Orders Not Allowed": TICK 2: GOTO wait2
	COLOR 11: clrbot
	IF dx = 2 THEN PRINT "Hit ENTER to order unit to move to cursor position";
	IF dx = 5 THEN PRINT "GROUP MOVE ORDERS : Hit ENTER to order group to move to cursor position";
     
      CASE 3  'intelligence
	CALL ShowIntelligenceLine

      CASE 4  'inspire
	IF LEFTY$(active) <> "G" THEN GOTO wait2
	COLOR 11: clrbot: PRINT "INSPIRE : move cursor over friendly unit and press ENTER";
	COLOR 13: PRINT " Range ";
      CASE ELSE
END SELECT

movew:
	yloc = unity(active): xloc = unitx(active): y = yloc: x = xloc

	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
	PUT (8 * x, 14 * y), Xhair, XOR

movex:
	y = yloc: x = xloc: id = 0
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
SELECT CASE dx
      CASE 1  'cannon
	COLOR 11: LOCATE 23, 40: PRINT SPACE$(19);
	CALL whois(xloc, yloc, id, 0)
	COLOR 14: IF d > vantage THEN COLOR 12
	LOCATE 23, 35: PRINT d; " ";
	CALL Tara(69, 23, z)

	IF d <= vantage AND id > 0 AND Visible(id) > 0 THEN
		LOCATE 23, 40: COLOR 11: PRINT name$(id);
	END IF

      CASE 2, 5  'move
      CASE 3, 4 'intelligence & inspire
	CALL whois(xloc, yloc, id, 0): IF id > 0 THEN CALL ShowUnitStats(id, dx)
	CALL AwakenUnit(id, xloc, yloc)
	COLOR 13: LOCATE 23, 68: PRINT d;
	CASE ELSE
END SELECT
       
	CALL WaitForKeypress(commnd$, dxs, dys)
	IF ASC(commnd$) = 13 GOTO here2
	CALL curser(commnd$, xloc, yloc)

	CALL FlashCursor(xloc, yloc)
	PUT (8 * x, 14 * y), Xhair, XOR
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))

	SELECT CASE dxs
	CASE 27
	CALL FlashCursor(xloc, yloc): CALL refresh: GOTO wait2
	CASE 32
	CALL FlashCursor(xloc, yloc): CALL rest(active): GOTO asleep
	CASE 76
	CALL FlashCursor(xloc, yloc): CALL limbo(active, 1): GOTO asleep
	CASE 87
	CALL WaitUnit(active): GOTO asleep
	CASE ELSE
	END SELECT

	GOTO movex
'...........................................................................
here2:
	IF dx = 2 OR dx = 5 GOTO here
	IF dx = 3 THEN CALL FlashCursor(xloc, yloc): GOTO wait2
	IF dx = 4 THEN CALL FlashCursor(xloc, yloc): GOTO RAlly
	CALL whois(xloc, yloc, Enemy, active)
	IF Enemy = 0 OR Visible(Enemy) = 0 THEN
			CALL FlashCursor(xloc, yloc)
			CALL PlayNoise3
			CALL clrbot
			PRINT "NO ENEMY AT THAT LOCATION !"
			TICK mdly!
			CALL refresh
			GOTO fodder
	END IF

	IF t$ = "L" AND Enemy <> 0 THEN CALL limbo(active, 2): GOTO asleep

	IF d < 4 AND (active < m2 AND Enemy < m2) OR (active > m1 AND Enemy > m1) THEN dx = 2: GOTO here

	CALL los(active, Enemy, F, 0)
	IF Visible(Enemy) = 0 THEN Visible(Enemy) = 1

	a$ = ""
	IF d > vantage THEN a$ = "ENEMY IS OUT OF RANGE !"
	IF F < 1 THEN a$ = "NOT IN LINE OF SIGHT !"
	IF a$ <> "" THEN
		CALL FlashCursor(xloc, yloc)
		CALL PlayNoise3
		CALL clrbot
		PRINT a$
		TICK .2 * mdly!
		GOTO fodder
	END IF

	IF quiet < 1 GOTO blast
	FOR k = 1 TO 6: SOUND 37 + 40 * RND, 1: NEXT k
	FOR k = 4000 TO 2800 STEP -100: SOUND k, .8: NEXT k
blast:

	CALL cannon(active, Enemy)
dudd:
	GOTO asleep
'============================================================================
'                      Show Visible Targets
'============================================================================
vistarg:
	s = 1: F = bigg(1): IF side = 1 THEN s = m2: F = bigg(2): c = 0
	FOR k = s TO F
	IF Visible(k) > 0 THEN
		d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
		IF d > vantage THEN
			c = 1
			ELSE
			c = 0: flag = 0
			IF lineofsight > 0 THEN CALL los(active, k, flag, 0)
		END IF
		IF flag < 1 OR c > 0 THEN CALL Tara(unitx(k), unity(k) + 1, terrain(k))
	END IF
	NEXT k
'============================================================================
'                      Awaken Waited Unit
'============================================================================
' GOSUB Awaken converted to SUB
SUB AwakenUnit (id AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)
	DIM F AS INTEGER
	IF LEFTY$(id) = "w" THEN
		CALL YouorMe(id, F)
		IF F > 0 THEN
			unit$(id) = RIGHT$(unit$(id), LEN(unit$(id)) - 1)
			CALL SHOWUNIT(id)
			CALL FlashCursor(xloc, yloc)
		END IF
	END IF
END SUB
' GOSUB allterr converted to SUB
SUB UpdateAllTerrain
	DIM k AS INTEGER
	FOR k = 1 TO bigg(2)
	IF strength(k) > 0 AND uorder(k) <> 99 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
	NEXT k
END SUB
' GOSUB inlin converted to SUB
SUB ShowIntelligenceLine
	COLOR 11: clrbot: PRINT "INTELLIGENCE: move cursor over units"; : COLOR 15: PRINT "  (ESC when done) ";
	LOCATE 23, 61: COLOR 11: PRINT "Range :";
END SUB
' GOSUB flash converted to SUB
SUB FlashCursor (xloc AS INTEGER, yloc AS INTEGER)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
END SUB
' GOSUB whoa1 converted to SUB
SUB WaitUnit (active AS INTEGER)
	COLOR 15: unit$(active) = "w" + unit$(active): clrbot: PRINT name$(active); " is WAITING until alerted"; : TICK .1 * mdly!: CALL rest(active)
END SUB

END SUB

SUB placeunit (xloc, yloc, index)
t$ = LEFTY$(index)
IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB
CALL YouorMe(index, flag): IF flag > 0 GOTO ours
IF unity(index) = objy AND unitx(index) = objx THEN uorder(index) = 0: xloc = unitx(index): yloc = unity(index): GOTO ours
IF possess <> 3 - side AND uorder(index) = 100 * objy + objx GOTO ours
IF uorder(index) > -1 AND morale(index) < 4 THEN
	IF 15 * RND > morale(index) + leader(index) THEN uorder(index) = 0: CALL rest(index): EXIT SUB
END IF
'============================================================================
'                    Enemy Checks for Proximity of Our Units
'============================================================================
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL Near2(index, Enemy, near)
	IF Enemy = 0 GOTO ours
	IF INSTR("A", t$) = 0 GOTO notart
	GOTO ours
	CALL cannon(index, Enemy)
	EXIT SUB
notart:
	IF INSTR("GL", t$) > 0 GOTO ours

	IF uorder(index) > 0 AND RND > .1 * bold GOTO ours

	pct! = strength(index) / strength(Enemy)
	pct! = pct! * .002 * RND * leader(index) * morale(index)
	t$ = LEFTY$(Enemy)
	IF INSTR("AGL", t$) > 0 THEN pct! = pct! + 1
	IF Visible(Enemy) > 0 AND near > 3 AND pct! > 1.8 - .2 * bold THEN uorder(index) = 100 * unity(Enemy) + unitx(Enemy): GOTO try2

	IF near > 3 GOTO try2
	uorder(index) = 0
	xloc = unitx(Enemy): yloc = unity(Enemy)
	IF pct! > 2 + .1 * bold GOTO fire1
	IF pct! > .5 + .1 * bold GOTO ours
       
	uorder(index) = 0: dxs = SGN(unitx(index) - unitx(Enemy)): dxy = SGN(unity(index) - unity(Enemy)): xloc = unitx(index) + 2 * dxs: yloc = unity(index) + 2 * dys
	GOTO ours
fire1:
	IF LEFTY$(Enemy) = CHR$(219) THEN unit$(Enemy) = "Infantry"
	GOTO rumble
try2:
	IF LEFTY$(index) = "I" AND morale(index) > 2 AND (terrain(index) = 43 OR terrain(index) = 46) THEN unit$(index) = "Infantry": toa(index) = timex + 1: EXIT SUB
	IF morale(index) < 4 THEN CALL rest(index)
'============================================================================
'                    Continue with Move Orders
'============================================================================
ours:
told = terrain(index)
IF xloc > 55 THEN xloc = 55: movesleft = 0: EXIT SUB
IF xloc < 2 THEN xloc = 2: movesleft = 0: EXIT SUB
IF yloc > 20 THEN yloc = 20: movesleft = 0: EXIT SUB
IF yloc < 1 THEN yloc = 1: movesleft = 0: EXIT SUB
z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
'============================================================================
'                    Check for presence of Invisible Units
'============================================================================
CALL whois(xloc, yloc, Enemy, index)
IF Enemy = 0 GOTO rechex
IF index < m2 AND Enemy < m2 GOTO special
IF index > m1 AND Enemy > m1 GOTO special
IF Enemy > 0 THEN CALL SHOWUNIT(Enemy): GOTO rumble
GOTO rechex
'============================================================================
'                            Engage if enemy is present
'============================================================================
rumble:
COLOR 14
IF side = 1 AND index > m1 THEN COLOR 15
IF side = 2 AND index < m2 THEN COLOR 14
'============================================================================
'                              Engage in Combat
'============================================================================
IF flag > 0 THEN CALL inspect(index)
CALL combat(index, Enemy)
IF uorder(index) = 0 THEN movesleft = 0
IF flag > 0 THEN CALL inspect(index)
'============================================================================
CALL SHOWUNIT(index)

IF toa(index) < timex + 2 THEN toa(index) = timex + 2
IF difficult < 5 THEN EXIT SUB
IF flag = 0 THEN toa(index) = toa(index) - 2
IF toa(index) <= timex THEN toa(index) = timex + 1
EXIT SUB

rechex:
terrain(index) = z
IF LEFTY$(index) = "R" AND z = 233 THEN uorder(index) = 0: EXIT SUB
IF recon = 1 THEN Visible(index) = 1
IF Visible(index) > 0 THEN CALL SHOWUNIT(index)
'============================================================================
'       calculate time of action penalty from unit type
'============================================================================
	u$ = LEFTY$(index)
	SELECT CASE u$
	CASE "I"
	plus = 2
	CASE CHR$(219)
	plus = 0
	CASE "C"
	plus = 0
	CASE "A", "L"
	plus = 1 + limber
	CASE "G"
	plus = 1
	CASE ELSE
	plus = 1
	END SELECT
'============================================================================
'       calculate time of action penalty from terrain and formation
'============================================================================
	dx = 0: IF INSTR("AL", u$) THEN dx = 4

	SELECT CASE terrain(index)
	CASE 35  'fort
	Pnlty = 2
	CASE 42  'forest
	Pnlty = 3
	IF u$ = "L" THEN Pnlty = 4 + dx: movesleft = 0
	IF u$ = "C" THEN movesleft = 0
	CASE 43, 91 'road or bridge
	Pnlty = 1
	CASE 46  'clear
	Pnlty = 2: IF u$ = "C" THEN Pnlty = 1
	CASE 94  'hill
	Pnlty = 4
	IF u$ = "L" THEN Pnlty = 5 + dx: movesleft = 0
	IF u$ = "C" THEN movesleft = 0
	CASE 61 'swamp
	Pnlty = 6
	IF INSTR("CL", u$) > 0 THEN Pnlty = 8 + dx
	movesleft = 0
	CASE 176 'water
	Pnlty = 10: movesleft = 0
	CASE 233 'objective
	Pnlty = 2
	CASE 239 'mountain
	Pnlty = 8: movesleft = 0
	CASE 254 'village
	Pnlty = 2
	IF u$ = "I" OR u$ = "G" THEN Pnlty = 1
	IF u$ = "C" THEN movesleft = movesleft - 1
	CASE ELSE
	Pnlty = 2
	END SELECT
'============================================================================
'           modify time of action penalty based on unit morale & leader
'============================================================================
	IF morale(index) < 3 THEN Pnlty = Pnlty + 1
	IF leader(index) < 3 THEN Pnlty = Pnlty + 1: IF leader(index) = 1 THEN Pnlty = Pnlty + 1
'============================================================================
'                        Update Time of Action
'============================================================================
	a = Pnlty / 2: IF a < 1 THEN a = 1
	movesleft = movesleft - a
	toa(index) = timex + Pnlty + plus
	IF LEFTY$(index) = CHR$(219) AND (RND > .97 OR (terrain(index) <> 43 AND terrain(index) <> 46)) THEN unit$(index) = "Infantry": toa(index) = timex + 2 + 2 * RND
	CALL YouorMe(active, F)
	IF F = 0 THEN
		IF toa(index) > timex + 1 AND difficult > 2 THEN
			IF RND < .05 * (difficult - 2) THEN toa(active) = timex + 1
		END IF
	END IF

IF unitx(index) = xloc AND unity(index) = yloc THEN EXIT SUB

IF strength(index) > 0 THEN CALL Tara(unitx(index), unity(index) + 1, 0)

unitx(index) = xloc: unity(index) = yloc
CALL SHOWUNIT(index)
IF quiet > 0 THEN SOUND 900, .1: TICK .05
IF terrain(index) = 233 THEN CALL victory(index)
EXIT SUB
'...........................................................................
IF quiet > 0 THEN SOUND 1900, .5
EXIT SUB
'---------------------------------------------------------------------------
' Special Cleanup - Contacted Units
'---------------------------------------------------------------------------

special:
uorder(index) = 1
'---------------------------------------------------------------------------
' Combine Units
'---------------------------------------------------------------------------
CALL YouorMe(Enemy, F)
IF Enemy = 0 THEN EXIT SUB
IF LEFTY$(Enemy) = "w" THEN unit$(Enemy) = RIGHT$(unit$(Enemy), LEN(unit$(Enemy)) - 1): CALL SHOWUNIT(Enemy)
IF LEFTY$(index) = "R" OR LEFTY$(Enemy) = "R" THEN movesleft = 0: EXIT SUB
IF strength(index) + strength(Enemy) > (unitsize& / 3) * (stakk - 1) THEN
	IF F > 0 THEN
		CALL clrbot
		COLOR 11
		IF uorder(index) = 0 THEN PRINT "Units are TOO BIG to stack ( Limit ="; 500 * stakk; ")";
		uorder(index) = 1: movesleft = 0
		TICK .2 * mdly!
		EXIT SUB
	ELSE
		movesleft = 0
		EXIT SUB
	END IF
END IF
'...........................................................................
IF LEFTY$(Enemy) = "L" THEN unit$(Enemy) = RIGHT$(unit$(Enemy), LEN(unit$(Enemy)) - 1): CALL SHOWUNIT(Enemy)
a$ = LEFTY$(index): t$ = LEFTY$(Enemy)
IF F = 0 AND (a$ <> t$) THEN EXIT SUB

IF F > 0 THEN
	LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 13
	LITEUP 8 * unitx(index), 14 * unity(index), 14
END IF

IF uorder(index) > 1 THEN EXIT SUB
uorder(index) = 0
IF quiet > 0 THEN SOUND 300, .3

CALL kleer
COLOR 14: LOCATE 12, 58: PRINT "Unit "; index;
LOCATE 13, 58: PRINT name$(index)
LOCATE 14, 58: PRINT unit$(index)
COLOR 15: LOCATE 15, 63: PRINT CHR$(18)
COLOR 11: LOCATE 16, 58: PRINT "Unit "; Enemy;
LOCATE 17, 58: PRINT name$(Enemy)
LOCATE 18, 58: PRINT unit$(Enemy)
IF F = 0 GOTO cluster

u$ = "Stack Units"
CALL YesNo(u$)
CALL scrcol(1)
IF u$ <> "Y" THEN CALL SHOWUNIT(Enemy): EXIT SUB
'...........................................................................
cluster:
IF Visible(index) > 0 THEN clrbot: COLOR 11: PRINT name$(index); " stacking with "; name$(Enemy);
IF quiet > 0 THEN SOUND 3000, 2
x = index
IF t$ = "G" AND a$ <> "G" THEN x = Enemy: GOTO how2
IF strength(Enemy) > strength(index) THEN x = Enemy
how2:
r! = strength(index) / (strength(index) + strength(Enemy))
morale(index) = r! * morale(index) + (1 - r!) * morale(Enemy)
leader(index) = r! * leader(index) + (1 - r!) * leader(Enemy)
toa(index) = timex + 3: IF leader(index) = 5 THEN toa(index) = timex + 1
strength(index) = strength(index) + strength(Enemy)
CALL Tara(unitx(index), unity(index) + 1, 0)
unitx(index) = unitx(Enemy): unity(index) = unity(Enemy)
terrain(index) = terrain(Enemy): name$(index) = name$(x)
IF a$ = t$ GOTO alike
IF INSTR("AL", a$) > 0 AND INSTR("AL", t$) > 0 THEN unit$(index) = "Artillery": GOTO alike
IF a$ = "G" OR t$ = "G" THEN unit$(index) = "General": GOTO alike
unit$(index) = "Infantry": IF leader(index) < 3 AND morale(index) > 2 THEN morale(index) = morale(index) - 1

alike:
strength(Enemy) = 0: leader(Enemy) = 0: unit$(Enemy) = "": toa(Enemy) = 0
IF F = 0 AND Visible(index) > 0 THEN FOR k = 1 TO mdly!: CALL ATTENTION(index, 13): NEXT k: TICK mdly!: EXIT SUB
IF Visible(index) > 0 THEN COLOR 14: ATTENTION index, 14
CALL YouorMe(index, F)
CALL clrbot
IF F = 1 THEN
PRINT "STACKED UNIT is "; unit$(index); " Unit"; index; " named "; name$(index); " with strength "; strength(index);
ELSE
PRINT sname$(3 - side); " units are stacking";
END IF
TICK mdly!
END SUB

SUB randarm (s)
who = sidex(s)
dx = 41: file$ = "data\french.dat": IF who = 1 THEN file$ = "data\allies.dat": dx = 1

COLOR 4: LOCATE 23, 1: PRINT "Placing armies ... "
CALL arrange(who, xloc, yloc)

LINE (455, 110)-(622, 140), 4, B
allarm = vp&(who) / unitsize&

FOR i = 1 TO allarm
	spin = 0
	index = 40 * (who - 1) + i
coord:
	spin = spin + 1: IF spin > 99 GOTO muster
	DIM xx AS INTEGER
	DIM yy AS INTEGER
	DIM flag AS INTEGER
	CALL CalculateXY(xx, yy, xloc, yloc)

	unitx(index) = xx - 10 + 20 * RND
	unity(index) = yy - 5 + 10 * RND
	IF unitx(index) < 2 THEN unitx(index) = 2
	IF unitx(index) > 54 THEN unitx(index) = 54
	IF unity(index) < 2 THEN unity(index) = 1
	IF unity(index) > 20 THEN unity(index) = 20

	CALL CheckOddHex(index, flag): IF flag = 0 GOTO chek2
	IF unitx(index) < 54 THEN unitx(index) = unitx(index) + 1: GOTO chek2
	IF unitx(index) > 2 THEN unitx(index) = unitx(index) - 1: GOTO chek2
	IF unity(index) < 20 THEN unity(index) = unity(index) + 1: GOTO chek2
	IF unity(index) > 1 THEN unity(index) = unity(index) - 1
chek2:
	z = ASC(MID$(sdtext$((unity(index) + 1)), unitx(index), 1))
	IF z = 32 OR z = 176 GOTO coord
	CALL whois(unitx(index), unity(index), Enemy, index)
	IF Enemy > 0 THEN GOTO coord
SELECT CASE i
	CASE 1: armx = 3
	CASE IS < .1 * allarm + (2 * RND): armx = 3
	CASE IS < .3 * allarm + (2 * RND): armx = 1
	CASE IS < .5 * allarm + (2 * RND): armx = 2: IF allarm < 11 AND RND > .5 THEN amrx = 4
	CASE ELSE: armx = 4
END SELECT
	unit$(index) = equip$(armx)
SELECT CASE armx
CASE IS < 2     'artillery
	strength(index) = unitsize& * (.5 + .2 * RND)
CASE 2          'cavalry
	strength(index) = unitsize& * (.7 + .2 * RND)
CASE 3          'general
	strength(index) = unitsize& * (.5 + .2 * RND)
CASE 4, 5       'infantry
	strength(index) = unitsize& * (1.1 + .4 * RND)
CASE ELSE
END SELECT

CALL namer(file$, dx, index - 1, a$)
name$(index) = a$
IF i = allarm THEN name$(index) = "RESERVES": morale(i) = 5: leader(i) = 5: xper(i) = 5: toa(i) = 5

morale(index) = 3 - 1 + 2 * RND
leader(index) = .5 * leadbase(sidex(s)) - 1 + 2 * RND
IF leader(index) > 3 AND morale(index) < 3 THEN morale(index) = morale(index) + 1
IF index = 41 AND name$(index) = "Napoleon" THEN leader(index) = 5
xper(index) = expbase(who) + (-1 + 2 * RND)
IF xper(index) > 3 AND leader(index) < 3 THEN leader(index) = 3
IF leader(index) < 2 AND morale(index) > 2 THEN leader(index) = 2
IF LEFTY$(index) = "C" AND leader(index) < 4 AND RND > .5 THEN leader(index) = 4
IF LEFTY$(index) = "G" AND leader(index) < 4 AND RND > .5 THEN leader(index) = 4
	uorder(index) = 0: toa(index) = 0
	IF RND > .9 THEN toa(index) = 25 * RND: IF RND > .5 OR toa(index) > 15 THEN uorder(index) = 99
	IF side = sidex(2) AND who = side AND LEFTY$(index) <> "G" AND toa(index) = 0 AND RND > .5 THEN toa(index) = 1 + INT(3 * RND): IF fort > 0 THEN unit$(index) = "w" + unit$(index)
	IF i = allarm THEN uorder(i) = 99: toa(i) = .5 * timelimit
count:
CALL SHOWUNIT(index)
vp&(who) = vp&(who) - strength(index)
IF vp&(who) < 0 GOTO muster
CALL valid(index)
NEXT i

muster:
IF vp&(who) < strength(allarm) AND strength(allarm) > vp&(who) THEN strength(allarm) = strength(allarm) + vp&(who)

IF s = 2 THEN
	x = m2: x1 = 1: IF who = 1 THEN x1 = m2: x = 1
	SELECT CASE fort
		CASE 0
			xloc = .8 * unitx(x) + .2 * unitx(x1)
			yloc = .8 * unity(x) + .2 * unity(x1)
			IF INT(xloc + yloc) MOD 2 <> 0 THEN
				IF xloc < 54 THEN xloc = xloc + 1 ELSE xloc = xloc - 1
			END IF
		CASE 1, 2
			xloc = unitx(x)
			yloc = unity(x)
			possess = sidex(2)
	END SELECT
	IF (xloc + yloc) <> INT(.5 * (xloc + yloc)) * 2 THEN xloc = xloc + 1
	CALL replace(yloc, xloc, 233)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	objx = xloc: objy = yloc
END IF
EXIT SUB

' GOSUB xxyy converted to SUB
SUB CalculateXY (xx AS INTEGER, yy AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)
	xx = xloc: yy = yloc
	IF xx = 99 THEN xx = 1 + INT(54 * RND)
	IF yy = 99 THEN yy = 1 + INT(24 * RND)
END SUB

' GOSUB odd converted to SUB
SUB CheckOddHex (index AS INTEGER, flag AS INTEGER)
	flag = 0
	IF (unitx(index) + unity(index)) <> INT(.5 * (unitx(index) + unity(index))) * 2 THEN flag = 1
END SUB

SUB randmap
SCREEN 9, , 1, 1
CLS : COLOR 14
LINE (0, 0)-(213, 460), 1, BF: LINE (214, 0)-(426, 460), 15, BF
LINE (427, 0)-(639, 460), 4, BF
CIRCLE (320, 165), 300, 14, , , .1
PAINT (320, 172), 0, 14
a$ = "Setting Up Battle of " + SCENARIO$: LOCATE 11, 40 - .5 * LEN(a$): PRINT a$
a$ = commander$(sidex(1)) + " is attacking " + commander$(sidex(2)): LOCATE 13, 40 - .5 * LEN(a$): PRINT a$
' QB64-compatible file existence check
IF _FILEEXISTS("data\quotes.dat") THEN
	OPEN "I", 1, "data\quotes.dat"
	INPUT #1, n
	a = 1 + INT(RND * n)
	FOR k = 1 TO a
	INPUT #1, a$
	NEXT k
	CLOSE #1
	LOCATE 18, 40 - .5 * LEN(a$): PRINT CHR$(34); a$; CHR$(34)
END IF
SCREEN 9, , 0, 1
choose = 1
IF RND > .5 THEN
	choose = 2: IF RND > .5 THEN choose = 3
END IF
r! = 0: IF choose = 2 THEN r! = .5
IF choose = 3 THEN r! = .99
CALL startmap
CALL mainmap
FOR k = 1 TO most: strength(k) = 0: NEXT k
'============================================================================
'                            Place Terrain Features
'============================================================================
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	IF RND > r! GOTO moret
	xloc = 4 + 50 * RND: yloc = 4 + 16 * RND
	x1 = xloc: y1 = yloc
	r! = .2 + .3 * RND: x = 8 * RND
	IF fort = 0 OR side = sidex(2) GOTO morerd
morewat:                        ' water
	DO
		IF RND > .9 THEN x = 8 * RND
		CALL MoveNearHere(x, xloc, yloc, r!): CALL AdjustHexX(xloc, yloc): CALL CheckLimits(xloc, yloc, flag, spin): IF flag = 1 THEN EXIT DO
		CALL replace(yloc, xloc, 176)
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
	LOOP
nowat:
	IF x1 > 0 THEN xloc = x1: yloc = y1: x1 = 0: GOTO morewat
	IF RND > .6 GOTO trees
moret:
	CALL RandomLocation(xloc, yloc)
	IF RND < .5 THEN yloc = 0: CALL AdjustHexX(xloc, yloc): x = 6: IF RND > .5 THEN x = 8: GOTO morerd
	yloc = 21: CALL AdjustHexX(xloc, yloc): x = 1: IF RND > .5 THEN x = 3
morerd:                         ' road
	DO
		CALL MoveNearHere(x, xloc, yloc, r!): CALL CheckLimits(xloc, yloc, flag, spin): IF flag = 1 OR spin > 99 THEN EXIT DO
		CALL replace(yloc, xloc, 43)
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
	LOOP
endrd:
	spin = 0
	IF RND > .8 GOTO nowat

trees:                          ' trees
	CALL RandomLocation(xloc, yloc)
newtree:
	DO
		x = 8 * RND: CALL MoveNearHere(x, xloc, yloc, r!): CALL CheckLimits(xloc, yloc, flag, spin): IF flag = 1 THEN EXIT DO
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 THEN
			CALL replace(yloc, xloc, 42)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		END IF
	LOOP WHILE z <> 46
endtree:
	IF obstruct > 80 GOTO donehere
	IF RND > .4 GOTO trees

hills:                          ' hills
	CALL RandomLocation(xloc, yloc): r! = .3 + .6 * RND
morehill:
	DO
		x = 8 * RND: CALL MoveNearHere(x, xloc, yloc, r!): CALL CheckLimits(xloc, yloc, flag, spin): IF flag = 1 THEN EXIT DO
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 THEN
			a = 239: IF RND < .8 THEN a = 94
			CALL replace(yloc, xloc, a)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		END IF
	LOOP WHILE z <> 46
endhill:
	IF obstruct > 80 GOTO donehere
	IF RND > .4 GOTO hills

other:                          ' other features
	CALL RandomLocation(xloc, yloc): r! = .1
morestuf:
	CALL CheckLimits(xloc, yloc, flag, spin): IF flag = 1 GOTO donehere
xtrastuf:
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 GOTO other
	z = 35
	IF RND > .2 + .2 * fort THEN z = 254
	IF RND > .4 + .1 * fort THEN z = 61
	CALL replace(yloc, xloc, z)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	IF RND > .5 - .1 * fort THEN CALL MoveNearHere(x, xloc, yloc, r!): GOTO xtrastuf
	IF obstruct > 80 GOTO donehere
	IF RND > .1 GOTO other
	GOTO donehere
'============================================================================
' GOSUB rloc converted to SUB
SUB RandomLocation (xloc AS INTEGER, yloc AS INTEGER)
	xloc = 2 + 53 * RND: yloc = 1 + 19 * RND
	IF xloc + yloc <> INT((xloc + yloc) / 2) * 2 THEN CALL AdjustHexX(xloc, yloc)
END SUB

' GOSUB nearhere converted to SUB
SUB MoveNearHere (x AS INTEGER, xloc AS INTEGER, yloc AS INTEGER, r! AS SINGLE)
	SELECT CASE x
		CASE 1
		xloc = xloc - 1: yloc = yloc - 1
		CASE 2
		yloc = yloc - 1
		CASE 3
		xloc = xloc - 1: yloc = yloc - 1
		CASE 4
		xloc = xloc - 2
		CASE 5
		xloc = xloc + 2
		CASE 6
		xloc = xloc - 1: yloc = yloc + 1
		CASE 7
		yloc = yloc + 1
		CASE 8
		xloc = xloc - 1: yloc = yloc + 1
		CASE ELSE
		xloc = 54
		IF RND < r! THEN CALL RandomLocation(xloc, yloc)
	END SELECT
	IF xloc < 1 THEN xloc = 1
	IF yloc > 21 THEN yloc = 21
	IF xloc > 55 THEN xloc = 55
	IF yloc < 1 THEN yloc = 1
END SUB

' GOSUB adjx converted to SUB
SUB AdjustHexX (xloc AS INTEGER, yloc AS INTEGER)
	IF xloc + yloc = INT((xloc + yloc) / 2) * 2 THEN EXIT SUB
	IF xloc > 2 THEN xloc = xloc - 1: EXIT SUB
	IF xloc < 54 THEN xloc = xloc + 1: EXIT SUB
END SUB

' GOSUB lim1 converted to SUB
SUB CheckLimits (xloc AS INTEGER, yloc AS INTEGER, flag AS INTEGER, spin AS INTEGER)
	flag = 0
	IF xloc > 54 OR xloc < 2 THEN flag = 1
	IF yloc > 20 OR yloc < 1 THEN flag = 1
	spin = spin + 1
END SUB
donehere:
END SUB

SUB replace (y, x, z)
IF y < 1 OR y > 20 THEN EXIT SUB
IF x < 2 OR x > 56 OR x = 55 THEN EXIT SUB
SELECT CASE z
	CASE 43
		obstruct = obstruct + 1
	CASE 61, 94
		obstruct = obstruct + 3
	CASE 176, 239
		obstruct = obstruct + 5
END SELECT
CALL Tara(x, y + 1, z)
PUT (8 * x, 14 * y), Xhair, XOR
t$ = MID$(sdtext$(y + 1), x, 1): IF t$ = CHR$(219) THEN nobj = nobj - 1
a1$ = LEFT$(sdtext$(y + 1), x - 1)
a2$ = RIGHT$(sdtext$(y + 1), LEN(sdtext$(y + 1)) - x)
sdtext$(y + 1) = a1$ + CHR$(z) + a2$
IF z = 233 THEN nobj = nobj + 1
CALL Terra(z, a$)
IF repeat > 0 AND repeat <> z THEN repeat = z: COLOR 12: LOCATE 8, 62: PRINT "DUPLICATE ": CALL Tara(72, 8, z): SOUND 3100, .5
CALL whois(x, y, Enemy, 0): IF Enemy > 0 THEN terrain(Enemy) = z
END SUB

SUB SHOWUNIT (index)
	IF recon = 0 AND Visible(index) = 0 THEN EXIT SUB
	IF strength(index) < 1 AND unit$(index) <> "X" THEN EXIT SUB
	IF uorder(index) = 99 THEN EXIT SUB
		y = 14 * unity(index): x = 8 * unitx(index)

		a = ASC(LEFTY$(index))
	       
		SELECT CASE a
		CASE 65   'Artillery
		IF index > 40 THEN PUT (x, y), AAlly, PSET ELSE PUT (x, y), AFrench, PSET
		CASE 67   'Cavalry
		IF index > 40 THEN PUT (x, y), CAlly, PSET ELSE PUT (x, y), CFrench, PSET
		CASE 71   'General
		IF index > 40 THEN PUT (x, y), GAlly, PSET ELSE PUT (x, y), GFrench, PSET
		CASE 73   'Infantry
		IF index > 40 THEN PUT (x, y), IAlly, PSET ELSE PUT (x, y), IFrench, PSET
		CASE 76 'Limbered Artillery
		IF index > 40 THEN PUT (x, y), LAAlly, PSET ELSE PUT (x, y), LAFrench, PSET
		CASE 82 'Routed Unit
		IF index > 40 THEN PUT (x, y), RAlly, PSET ELSE PUT (x, y), RFrench, PSET
		EXIT SUB
		CASE 83 'Hollow square
		IF index < 41 THEN PUT (x, y), HSAlly, PSET ELSE PUT (x, y), HSFrench, PSET
		CASE 88   'Death
		PUT (x, y), Death, PSET: unit$(index) = "DEAD"
		CASE 119  'wait
		IF index < 41 THEN PUT (x, y), Wally, PSET ELSE PUT (x, y), WFrench, PSET
		uorder(index) = 0: movesleft = 0
		CASE 232   'Charge Infantry
		IF index > 40 THEN
			PUT (x, y), IAlly, PSET: c = 15
		ELSE
			PUT (x, y), IFrench, PSET: c = 4
		END IF
		CIRCLE (x + 6, y + 6), 4, c
		CASE 238
		PUT (x, y), Death, PSET
		CASE ELSE
		END SELECT
IF (side = 1 AND index > m1) OR (side = 2 AND index < m2) THEN EXIT SUB
dx = 7: IF side = 2 THEN dx = 1
IF uorder(index) > 0 THEN LINE (x, y)-(x + 12, y + 12), dx, B
END SUB

SUB Tara (x, y, a)
IF a = 0 THEN t$ = MID$(sdtext$(y), x, 1): a = ASC(t$)
z = 8 * x: c = 14 * (y - 1)
	SELECT CASE a
	CASE 35
	PUT (z, c), Fterr, PSET
	CASE 42
	PUT (z, c), Tterr, PSET
	CASE 43
	PUT (z, c), Rterr, PSET
	CASE 46
	PUT (z, c), Cterr, PSET
	CASE 61
	PUT (z, c), Sterr, PSET
	CASE 91
	PUT (z, c), Bridge, PSET
	CASE 94
	PUT (z, c), Hterr, PSET
	CASE 176
	PUT (z, c), Wterr, PSET
	CASE 233
	PUT (z, c), Oterr, PSET
	SELECT CASE possess
	CASE 1
	PAINT (z + 6, c + 4), 4, 15
	CASE 2
	PAINT (z + 6, c + 4), 1, 15
	END SELECT
	CASE 239
	PUT (z, c), Mterr, PSET
	CASE 254
	PUT (z, c), Vterr, PSET
	CASE ELSE
	END SELECT
dirt:
END SUB

SUB Terra (k, a$)
		SELECT CASE k
		CASE 35
		a$ = "Fort"
		CASE 42
		a$ = "Trees"
		CASE 43, 47, 92
		a$ = "Road "
		CASE 46
		a$ = "Clear"
		CASE 61
		a$ = "Swamp"
		CASE 91
		a$ = "Bridge"
		CASE 94
		a$ = "Hill"
		CASE 123, 125, 126
		a$ = "River"
		CASE 176
		a$ = "Water"
		CASE 233
		a$ = "OBJCTV"
		CASE 239
		a$ = "Mtn"
		CASE 254
		a$ = "Village"
		CASE ELSE
		a$ = CHR$(k) + "Unknown"
		END SELECT
END SUB

SUB vistarg (active, flag)
CALL ranger(active, vantage)
s = 1: a = bigg(1): IF side = 1 THEN s = m2: a = bigg(2): c = 0
FOR k = s TO a
	IF Visible(k) > 0 THEN
		d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
		IF d > vantage THEN
			IF unitx(k) > 1 AND unitx(k) < 55 AND unity(k) > 0 AND unity(k) < 21 THEN c = 1
		ELSE
			c = 0: F = 0
			IF lineofsight > 0 THEN CALL los(active, k, F, 0)
			IF flag > 0 AND F > 0 THEN PUT (8 * unitx(k), 14 * unity(k)), Xhair, XOR
		END IF
		IF F < 1 OR c > 0 THEN
			IF unitx(k) > 0 AND unity(k) > 0 THEN
				CALL Tara(unitx(k), unity(k) + 1, terrain(k))
			END IF
		END IF
	END IF
NEXT k
END SUB

'============================================================================
' SUB definitions from NAP1A.BAS (merged into single file)
'============================================================================

SUB arrange (who, xloc, yloc)
SELECT CASE setupx
	CASE 1
		IF who = 1 THEN
			xloc = 13: yloc = 99
		ELSE
			xloc = 40: yloc = 99
		END IF
	CASE 2
		IF who = 1 THEN
			xloc = 99: yloc = 6
		ELSE
			xloc = 99: yloc = 18
		END IF
	CASE 3
		IF who = 1 THEN
			xloc = 40: yloc = 99
		ELSE
			xloc = 13: yloc = 99
		END IF
	CASE 4
		IF who = 1 THEN
			xloc = 27: yloc = 6
		ELSE
			xloc = 27: yloc = 18
		END IF
	CASE 5
		IF who = 1 THEN
			xloc = 99: yloc = 6
		ELSE
			xloc = 99: yloc = 18
		END IF
END SELECT
END SUB

SUB ATTENTION (index, c)
y = 14 * unity(index): x = 8 * unitx(index)
LINE (x, y)-(x + 15, y + 13), c, BF: TICK .05
CALL SHOWUNIT(index): TICK .05
END SUB

SUB brittle (who%)
IF elan(who%) > 100 THEN elan(who%) = 100
IF elan(who%) < 1 THEN
	elan(who%) = 0
	LINE (40, 110)-(420, 200), 0, BF
	c = 4: IF who% = 2 THEN c = 1
	LINE (40, 100)-(410, 190), c, BF
	LINE (50, 110)-(400, 180), 4, B
	COLOR 15: LOCATE 11, 10: PRINT "Entire " + sname$(who%) + " army has BROKEN IN PANIC !"
	IF quiet > 0 THEN PLAY "t180o3c4c8.c16g4.P8e4g8.e16c2"
	TICK 3
	CALL over(who%)
END IF
END SUB

SUB BuffClear
' QB64 doesn't need direct memory access for keyboard buffer
' Keyboard input is handled automatically by QB64
' Removed DEF SEG and POKE operations for QB64 compatibility
END SUB

SUB BUTTON (x, y, c, a$, z)
IF z < 0 THEN flag = 1: z = ABS(z)
depress:
a$ = UCASE$(a$)
xc = 8 * (x - 1) - 4: yc = 14 * (y - 1) - 2
a = LEN(a$) * 8
LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), 0, BF
LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), c, B
COLOR c: LOCATE y, x: PRINT a$;
dx = 7: IF z <> 0 THEN dx = 8
PAINT (xc + 4, yc + 2), dx, c
i = LEN(a$)

FOR k = 1 TO i
IF INSTR("ABDOPQR46890", MID$(a$, k, 1)) > 0 THEN
	xloc = 8 * (x + k - 1) - 5: yloc = 14 * y - 9
	IF INSTR("B08", MID$(a$, k, 1)) > 0 THEN PAINT (xloc, yloc + 2), dx, c
	IF INSTR("4", MID$(a$, k, 1)) > 0 THEN PAINT (xloc, yloc + 1), dx, c
	IF INSTR("6", MID$(a$, k, 1)) > 0 THEN PAINT (xloc, yloc + 3), dx, c
	PAINT (xloc, yloc - 1), dx, c
END IF
NEXT k

dx = 15: dy = 0: IF z > 0 THEN dx = 0: dy = 15
LINE (xc + 1, yc + 1)-(xc + a + 5, yc + 1), dx
LINE (xc + 1, yc + 1)-(xc + 1, yc + 16), dx
LINE (xc + 1, yc + 16)-(xc + a + 6, yc + 16), dy
LINE (xc + a + 6, yc + 1)-(xc + a + 6, yc + 16), dy
IF y = 1 THEN LINE (xc + 1, yc + 2)-(xc + a + 5, yc + 2), dx
IF flag > 0 THEN TICK .1: z = 0: flag = 0: GOTO depress
END SUB

SUB clrbot
LOCATE 23, 1: PRINT SPACE$(80); : LOCATE 23, 1
END SUB

SUB combat (index, Enemy)
IF Enemy = 0 OR uorder(index) = 99 OR index = Enemy THEN GOTO cancel2
a$ = LEFTY$(index)
IF a$ = "R" THEN movesleft = 0: GOTO cancel2
tlx = 60: tly = 3: colour = 12: size = 4
mtx$(0) = "COMBAT MENU"
mtx$(1) = "Light Skirmish"
mtx$(2) = "Medium Fight"
mtx$(3) = "Heavy Attack"
mtx$(4) = "All-out Assault"

IF Visible(index) < 1 THEN Visible(index) = 1: SHOWUNIT (index)
CALL YouorMe(index, flag): IF flag > 0 GOTO manual

roll! = mdly!
pct# = strength(index) / strength(Enemy) + .1 * bold - .3
IF terrain(Enemy) = 94 THEN pct# = .6 * pct#
IF terrain(Enemy) = 239 THEN pct# = .4 * pct#
IF terrain(Enemy) = 61 THEN pct# = 1.2 * pct#
IF terrain(Enemy) = 42 THEN pct# = .8 * pct#
IF terrain(Enemy) = 254 THEN pct# = .8 * pct#
IF terrain(Enemy) = 35 OR terrain(index) = 35 THEN pct# = .5 * pct#
IF terrain(Enemy) = 233 THEN pct# = 2 * pct#
CALL valid(Enemy)
pct# = pct# * (morale(index) / morale(Enemy)) * (leader(index) / leader(Enemy))
d = 2 * ABS(unity(index) - objy) + ABS(unitx(index) - objx)
IF possess <> 3 - side AND d < seelimit THEN IF pct# < 1 THEN pct# = pct# + .3
CALL proximity(attack, bonus): IF bonus > 5 THEN pct# = pct# + .1
IF bold > 3 THEN pct# = pct# + .5
SELECT CASE pct#
	CASE IS > 2
	choose = 4
	CASE IS > 1.5
	choose = 3
	CASE IS > 1
	choose = 2
	CASE IS > .4
	choose = 1
	CASE ELSE
	dxs = SGN(unitx(index) - unitx(Enemy)): dys = SGN(unity(index) - unity(Enemy))
	uorder(index) = 100 * (unity(index) + dys) + unitx(index) + dxs
	GOTO cancel2
END SELECT

IF terrain(Enemy) = 233 THEN choose = choose + 1: IF timelimit - timex < 10 THEN choose = 4
IF leader(index) < 3 THEN choose = 3 - INT(2 * RND)
IF morale(index) < 3 THEN choose = choose - 1
IF RND > .9 THEN choose = choose - 1: IF RND < .5 THEN choose = choose + 2
IF bold > 3 AND RND > .7 THEN choose = choose + 1: IF bold = 5 AND RND > .5 THEN choose = 4
IF bold < 3 AND RND > .5 THEN choose = choose - 1: IF bold = 1 AND RND > .5 THEN choose = 1
SELECT CASE a$
	CASE "G"
		choose = choose - 2
	CASE "A"
		CALL cannon(index, Enemy): GOTO cancel2
	CASE "C"
		IF LEFTY$(Enemy) = "S" THEN choose = choose - 1
	CASE "L"
		IF choose < 4 THEN CALL limbo(index, 0): GOTO cancel2
END SELECT
IF d < .3 * seelimit THEN choose = choose + 1
IF timelimit - timex < 20 AND possess <> 3 - side THEN choose = choose + 1
IF LEFTY$(Enemy) = "R" THEN choose = choose + 2

IF choose > 4 THEN choose = 4
IF choose < 1 THEN GOTO cancel2
CALL inspect(Enemy)
GOTO tally

manual:
LITEUP 8 * unitx(index), 14 * unity(index), 14
LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

roll! = .1

x = INT(strength(Enemy) / 100) - 1 + 2 * RND
x = x * 100: IF x < 100 THEN x = 50
R! = strength(index) / x
COLOR 11: CALL clrbot: PRINT name$(index); " vs."; name$(Enemy); "  Str:"; x;
COLOR 10: IF R! < 1 THEN COLOR 12
SELECT CASE R!
	CASE IS < .67: x = 1: y = 1 / R!
	CASE IS < .8: x = 2: y = 3
	CASE IS < .9: x = 4: y = 5
	CASE IS < 1.3: x = 1: y = 1
	CASE IS < 1.6: x = 3: y = 2
	CASE ELSE: x = R!: y = 1
END SELECT
PRINT "  Ratio ="; x; ":"; y; " ";
COLOR 11: PRINT "  Terrain ="; : x = POS(0)
CALL Tara(x, 23, terrain(Enemy))
IF LEFTY$(index) = "C" AND (terrain(index) = 46 OR terrain(index) = 43) AND (terrain(Enemy) = 46 OR terrain(Enemy) = 43) THEN
	CALL BUTTON(10, 25, 14, "CAVALRY CHARGE", 1)
END IF
CALL menu
CALL scrcol(1)
CALL inspect(index)

tally:
IF choose = -1 XOR choose = 99 THEN movesleft = 0: uorder(index) = 0: GOTO cancel2
LITEUP 8 * unitx(index), 14 * unity(index), 14
LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

s = 1: IF index > m1 THEN s = 2

CALL clrbot: COLOR 12
IF LEFTY$(index) = "C" AND (terrain(index) = 46 OR terrain(index) = 43) AND (terrain(Enemy) = 46 OR terrain(Enemy) = 43) THEN
	COLOR 14
	PRINT sname$(s); " "; name$(index); " CALVARY CHARGE vs. "; name$(Enemy)
	IF quiet > 0 THEN PLAY "MBMST170o3c16.c16c16.c16c16.c16g16.e16g16.e16g16.e16c1MN"
ELSE
  PRINT sname$(s); " Unit : "; name$(index); " => "; RTRIM$(mtx$(choose)); " vs. "; name$(Enemy);
END IF
IF quiet < 1 THEN TICK mdly!

IF LEFTY$(Enemy) = CHR$(219) THEN unit$(Enemy) = "Infantry"
CALL musket(index, Enemy, choose): movesleft = 0
GOTO cancel2

cancel2:
CALL SHOWUNIT(Enemy)
IF LEFTY$(index) <> "R" AND RND > .05 + .15 * difficult THEN uorder(index) = 0
END SUB

SUB Compact (flag)
s = 1: F = m1: IF flag = 2 THEN s = m2: F = most
	FOR k = s TO F - 1
IF strength(k) > 0 GOTO occupy
	FOR j = k + 1 TO F
	IF strength(j) = 0 GOTO slider
	name$(k) = name$(j)
	unit$(k) = unit$(j)
	morale(k) = morale(j)
	leader(k) = leader(j)
	strength(k) = strength(j)
	unitx(k) = unitx(j)
	unity(k) = unity(j)
	terrain(k) = terrain(j)
	toa(k) = toa(j)
	uorder(k) = uorder(j)
	xper(k) = xper(j)
	strength(j) = 0: GOTO occupy
slider:
	NEXT j
occupy:
	NEXT k
FOR k = s TO F: IF strength(k) = 0 THEN bigg(flag) = k - 1: EXIT SUB
NEXT k
	bigg(flag) = F
END SUB

SUB cupdate (index)
IF strength(index) < 1 OR uorder(index) = 99 OR uorder(index) = 0 THEN movesleft = 0: EXIT SUB
	t$ = LEFTY$(index)
	IF limber > 0 AND t$ = "A" THEN uorder(index) = 0: EXIT SUB
	y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
	ynew = unity(index): xnew = unitx(index)
	dx = ABS(x - unitx(index)): dy = ABS(y - unity(index))
	IF dx + dy <> 0 GOTO notdone
	CALL YouorMe(index, F): IF F > 0 THEN CALL flash(index): uorder(index) = 0
	uorder(index) = 0: GOTO slide
notdone:
	dxs = SGN(x - unitx(index)): dys = SGN(y - unity(index))
	IF dy > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) + dxs: z = SCREEN(ynew + 1, xnew): IF z = 43 OR z = 46 OR z = 233 OR z = 254 THEN GOTO slide
	IF dy = 0 THEN xnew = unitx(index) + 2 * dxs: z = SCREEN(ynew + 1, xnew): IF z = 35 OR z = 43 OR z = 46 OR z = 233 OR z = 254 THEN GOTO slide
	ynew = unity(index): xnew = unitx(index)
	IF RND > .4 AND dx > dy THEN xnew = unitx(index) + 2 * dxs: GOTO slide
	IF dy > 0 AND dx > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) + dxs: GOTO slide
	IF dx > 1 THEN xnew = unitx(index) + 2 * dxs
	IF dy > 0 THEN ynew = unity(index) + dys: xnew = unitx(index) - 1: IF xnew < 2 THEN xnew = xnew + 2
slide:
	COLOR 4: IF index > 10 THEN COLOR 9
	CALL placeunit(xnew, ynew, index)
END SUB

SUB curser (a$, xloc, yloc)
SELECT CASE a$
	CASE "G"
gee:
	IF yloc = 1 THEN EXIT SUB
	xloc = xloc - 1
	yloc = yloc - 1
	CASE "H"
	IF RND > .5 GOTO gee ELSE GOTO eye
	CASE "I"
eye:
	IF yloc = 1 THEN EXIT SUB
	xloc = xloc + 1
	yloc = yloc - 1
	CASE "K"
	xloc = xloc - 2
	yloc = yloc
	CASE "M"
	xloc = xloc + 2
	yloc = yloc
	CASE "O"
oh:
	IF yloc = 20 THEN EXIT SUB
	xloc = xloc - 1
	yloc = yloc + 1
	CASE "P"
	IF RND > .5 GOTO oh ELSE GOTO que
	CASE "Q"
que:
	IF yloc = 20 THEN EXIT SUB
	yloc = yloc + 1
	xloc = xloc + 1

	CASE "1"
	yloc = 20: xloc = 2
	CASE "2"
	yloc = 20
	CASE "3"
	yloc = 20: xloc = 54
	CASE "4"
	xloc = 2
	CASE "5"
	yloc = 10: xloc = 28
	CASE "6"
	xloc = 54
	CASE "7"
	yloc = 1: xloc = 1
	CASE "8"
	yloc = 1
	CASE "9"
	yloc = 1: xloc = 55
	CASE ELSE
END SELECT
IF xloc > 53 THEN xloc = 54
IF xloc < 2 THEN xloc = 2
IF yloc < 1 THEN yloc = 1
IF yloc > 20 THEN yloc = 20
z = INT(.5 * (xloc + yloc)) * 2 - xloc - yloc
IF z <> 0 AND xloc < 27 THEN xloc = xloc + 1
IF z <> 0 AND xloc > 26 THEN xloc = xloc - 1
END SUB

SUB despair (index)
IF xper(index) = 5 AND RND < .99 THEN EXIT SUB
IF xper(index) = 4 AND RND < .88 THEN EXIT SUB
IF leader(index) = 5 AND RND < .9 THEN EXIT SUB
IF leader(index) = 4 AND RND < .7 THEN EXIT SUB
pct! = .5
SELECT CASE leader(index)
	CASE 1
	pct! = .8
	CASE 2
	pct! = .6
END SELECT

IF xper(index) = 2 THEN pct! = pct! + .1
IF xper(index) = 1 THEN pct! = pct! + .2

IF RND > pct! THEN EXIT SUB
IF morale(index) > 1 THEN morale(index) = morale(index) - 1
END SUB

SUB expire
x = 0: IF possess = side THEN x = 10 * difficult
'---------------------------------------------------------------------------
COLOR 11
CLS
PRINT "Scenario :"; SCENARIO$
PRINT "Player   :";
COLOR 15: IF side = 2 THEN COLOR 9
PRINT sname$(side)
COLOR 15: PRINT "Attacker :";
COLOR 4: IF sidex(1) = 2 THEN COLOR 9
PRINT sname$(sidex(1)); TAB(20); "("; commander$(sidex(1)); ")"
COLOR 15: PRINT "Defender :";
COLOR 9: IF sidex(2) = 1 THEN COLOR 4
PRINT sname$(sidex(2)); TAB(20); "("; commander$(sidex(2)); ")"
COLOR 11
PRINT "Difficulty :"; adj2$(difficult)
PRINT "Visibility Range :"; seelimit
PRINT "Enemy Aggressiveness :"; adj1$(bold)
PRINT "Turns Left :"; timelimit - timex; "/"; timelimit
LOCATE 10, 19: PRINT "Side"; TAB(31); "Losses"; TAB(40); "Esprit de Corps"
COLOR 14: LOCATE 12, 40: PRINT STRING$(10, CHR$(219))
COLOR 14: LOCATE 14, 40: PRINT STRING$(10, CHR$(219))
FOR k = 1 TO 2
	IF elan(k) < 1 THEN elan(k) = 0
NEXT k
x = elan(sidex(2)) * .1
a$ = STRING$(x, CHR$(219))
COLOR 4: IF sidex(2) = 2 THEN COLOR 9
LOCATE 14, 19: PRINT sname$(sidex(2)); TAB(30); score&(sidex(2)); TAB(40); a$
IF elan(sidex(2)) < 30 THEN COLOR 15: LOCATE 14, 60: PRINT "BREAKING!"
COLOR 4: IF sidex(1) = 2 THEN COLOR 9
x = elan(sidex(1)) * .1
a$ = STRING$(x, CHR$(219))
LOCATE 12, 19: PRINT sname$(sidex(1)); TAB(30); score&(sidex(1)); TAB(40); a$
IF elan(sidex(1)) < 30 THEN COLOR 15: LOCATE 12, 60: PRINT "BREAKING!"
LINE (100, 150)-(450, 206), 3, B
IF possess <> 0 THEN
	a$ = sname$(possess) + " SIDE IS WINNING!"
	COLOR 15: LOCATE 17, 33 - .5 * LEN(a$): PRINT a$
END IF
TICK 99
IF timelimit - timex <= 0 THEN CALL over(3 - possess)
END SUB

SUB flee (defend)
IF LEFTY$(defend) <> "R" AND strength(defend) > 50 AND morale(defend) > 1 THEN EXIT SUB
who = 1: IF defend > m1 THEN who = 2
CALL arrange(who, xloc, yloc)
SELECT CASE xloc
	CASE 13: xloc = 2: yloc = 11
	CASE 40: xloc = 52: yloc = 12
	CASE 27: IF yloc = 6 THEN yloc = 1 ELSE yloc = 18
	CASE 99:
	IF yloc = 6 THEN yloc = 1: xloc = 27
	IF yloc = 18 THEN yloc = 20: xloc = 28
	CASE ELSE
END SELECT
IF xloc > 0 AND yloc > 0 THEN uorder(defend) = 100 * yloc + xloc
END SUB

SUB general (index)
IF strength(index) < 1 GOTO best    ' unit is DEAD
IF strength(index) < 50 OR morale(index) < 2 GOTO afraid  ' unit is Weak
IF uorder(index) < 0 AND INSTR("AHB", LEFTY$(index)) > 0 THEN EXIT SUB
IF uorder(index) < 0 GOTO best      ' unit is DUG IN
IF uorder(index) = 99 GOTO best     ' unit is DELAYED
s = 1: IF index > m1 THEN s = 2
IF possess <> s AND RND > .2 AND LEFTY$(index) <> "R" THEN uorder(index) = 100 * objy + objx: EXIT SUB
IF uorder(index) > 0 AND RND < .15 * bold GOTO mine
	t$ = LEFTY$(index): IF t$ = "A" AND RND > .03 + .01 * bold GOTO mine
	IF t$ = "G" AND RND > .03 * bold GOTO mine
	d = ABS(unity(index) - objy) + ABS(unitx(index) - objx)
	CALL ranger(index, vantage): IF d > vantage AND RND < .1 * bold GOTO mine
	uorder(index) = 100 * objy + objx: GOTO best
mine:
CALL see(index): IF uorder(index) > 0 GOTO best
a = terrain(index): IF a = 239 GOTO best
IF (a = 94 OR a = 35) AND RND < .99 GOTO best
IF a = 42 AND RND < .95 GOTO best

	DIM z AS INTEGER
	DIM y AS INTEGER
	DIM x AS INTEGER
	IF unity(index) > 1 THEN y = unity(index) - 1: x = unitx(index) - 1: IF EvaluateLocation%(x, y, z, index) THEN GOTO improve
	IF unity(index) > 1 THEN y = unity(index) - 1: x = unitx(index) + 1: IF EvaluateLocation%(x, y, z, index) THEN GOTO improve
	IF unity(index) < 22 THEN y = unity(index) + 1: x = unitx(index) - 1: IF EvaluateLocation%(x, y, z, index) THEN GOTO improve
	IF unity(index) < 22 THEN y = unity(index) + 1: x = unitx(index) + 1: IF EvaluateLocation%(x, y, z, index) THEN GOTO improve
	IF unitx(index) > 1 THEN x = unitx(index) - 2: y = unity(index): IF EvaluateLocation%(x, y, z, index) THEN GOTO improve
	IF unitx(index) < 59 THEN x = unitx(index) + 2: y = unity(index): IF EvaluateLocation%(x, y, z, index) THEN GOTO improve

a = 1 + INT(m1 * RND): IF side = 2 THEN a = a + m1
IF (strength(a) > 0 AND uorder(a) <> 99) AND LEFTY$(index) <> "R" THEN uorder(index) = 100 * unity(a) + unitx(a)
GOTO best

' GOSUB eval converted to SUB - Returns true if location should trigger improve
FUNCTION EvaluateLocation% (x AS INTEGER, y AS INTEGER, z AS INTEGER, index AS INTEGER)
	IF x < 1 THEN x = 1
	IF x > 59 THEN x = 59
	IF y < 1 THEN y = 1
	IF y > 22 THEN y = 22
	z = SCREEN(y + 1, x)
	IF z = 35 OR z = 42 XOR z = 94 XOR z = 239 THEN
		EvaluateLocation% = 1
	ELSE
		EvaluateLocation% = 0
	END IF
END FUNCTION

afraid:
CALL flee(index)
GOTO best

improve:
uorder(index) = 100 * y + x

best:
toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
END SUB

SUB inspect (index)
	IF index < 1 THEN EXIT SUB
	CALL kleer
	c = 4: IF index > 40 THEN c = 9
	COLOR c
	CALL YouorMe(index, F)
	IF F = 0 THEN LOCATE 12, 67: COLOR 11: PRINT sname$(3 - side)
	IF recon = 1 THEN F = 1
	LOCATE 12, 58: PRINT "Unit "; index;
	COLOR c: LOCATE 13, 58: PRINT name$(index)
	LOCATE 14, 58: PRINT unit$(index)

	CALL valid(index)
	x = strength(index): IF F = 0 THEN x = INT(strength(index) / 100 - 2 + 4 * RND) * 100: IF x < 10 THEN x = 50
	COLOR c: IF F = 1 AND strength(index) < 200 THEN COLOR 5: IF strength(index) < 100 THEN COLOR 12
	LOCATE 15, 58: PRINT "Strength:" + STR$(x)
	COLOR c
	IF morale(index) < 2 THEN COLOR 6: IF morale(index) = 1 THEN COLOR 13
	IF F > 0 THEN LOCATE 16, 58: PRINT "Morale : "; morlev$(morale(index))
	COLOR c
	IF leader(index) < 2 THEN COLOR 6: IF leader(index) = 1 THEN COLOR 13
	IF F > 0 THEN LOCATE 17, 58: PRINT "Leader : "; ledlev$(leader(index))
	COLOR c
	IF xper(index) < 2 THEN COLOR 6: IF xper(index) = 1 THEN COLOR 13
	LOCATE 18, 58: PRINT "Exper  : "; xplev$(xper(index))

	LOCATE 19, 58: PRINT "Terr: ": CALL Tara(62, 19, terrain(index))
	LOCATE 19, 67: PRINT "Moves :"; RTRIM$(STR$(movesleft))
	LINE (453, 152)-(631, 267), 4, B
	END SUB

SUB kleer
LINE (454, 153)-(630, 266), 0, BF
END SUB

FUNCTION LEFTY$ (index)
LEFTY$ = LEFT$(unit$(index), 1)
END FUNCTION

SUB limbo (index, flag)
IF limber = 0 THEN EXIT SUB
t$ = LEFTY$(index)
IF flag < 1 GOTO limb1
IF t$ <> "L" GOTO stuck
	COLOR 11: clrbot: PRINT "Artillery units must be UNIMBERED to fire";
	mtx$(0) = "UNLIMBER ?"
	GOTO hitch
stuck:
	COLOR 11: clrbot: PRINT "Artillery units must be LIMBERED to move";
	mtx$(0) = "Limber ?"
hitch:
	mtx$(1) = "Yes"
	mtx$(2) = "No"
	tly = 2: colour = 5
	tlx = 58: size = 2
	CALL menu
	SELECT CASE choose
		CASE 1
		CASE ELSE
		EXIT SUB
	END SELECT
limb1:
	IF INSTR("AH", t$) > 0 THEN unit$(index) = "L" + unit$(index): a$ = "Limbered": GOTO rollon
	IF t$ = "L" THEN unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1): a$ = "UNLIMBERED": GOTO rollon
	EXIT SUB
rollon:
	movesleft = 0
	toa(index) = toa(index) + 2 + 2 * RND
	IF leader(index) < 3 THEN toa(index) = toa(index) + 1
	CALL YouorMe(index, F)
	IF F = 0 THEN
		IF t$ = "L" THEN
			uorder(index) = 100 * objy + objx
			IF Visible(index) > 0 THEN CALL SHOWUNIT(index): EXIT SUB
		END IF
		EXIT SUB
	END IF
	IF quiet > 0 THEN SOUND 1600, .3: TICK .05: SOUND 1700, .3
	CALL ATTENTION(index, 13)
	CALL inspect(index)
	COLOR 11: CALL clrbot: PRINT "Artillery Unit "; name$(index); " is "; a$; : TICK .1 * mdly!
END SUB

SUB LITEUP (x0, y0, c)
LINE (x0, y0)-(x0 + 14, y0 + 13), c, B
LINE (x0 + 1, y0 + 1)-(x0 + 13, y0 + 12), c, B
END SUB

SUB lowtime
	timex = 32767
	FOR k = 1 TO bigg(2)
	IF strength(k) > 0 AND toa(k) < timex THEN timex = toa(k)
	NEXT k
END SUB

SUB mainmap
COLOR 2, 0: SCREEN 9: CLS
count = 0
LINE (10, 0)-(639, 300), 8, BF
x = INSTR(SCENARIO$, "|"): IF x > 0 THEN SCENARIO$ = LEFT$(SCENARIO$, x - 1)
IF LEN(SCENARIO$) > 55 THEN SCENARIO$ = LEFT$(SCENARIO$, 55)
COLOR 15: x = 55 - LEN(SCENARIO$): x = .5 * x + 1: LOCATE 1, x: PRINT SCENARIO$
FOR k = 2 TO 21
	s = 2: IF INT(.5 * k) * 2 = k THEN s = 1
	FOR j = s TO 54 STEP 2
	CALL Tara(j, k, 0)
	NEXT j
x = INSTR(sdtext$(k), CHR$(219)): IF x > 0 THEN objx = x: objy = k - 1: count = count + 1
NEXT k
	CALL scrcol(0)
	IF count = 1 GOTO dork2
dork2:
	LINE (10, 0)-(639, 300), 4, B
	CALL BUTTON(58, 1, 4, "F1:HELP", 0)
	CALL BUTTON(71, 1, 4, "F3:REDRAW", 0)
END SUB

SUB namer (file$, s, F, a$)
a$ = ""
spin = 0
redoz:
spin = spin + 1
' QB64-compatible file existence check
IF NOT _FILEEXISTS(file$) THEN
	a$ = "Unknown"
	EXIT SUB
END IF
OPEN "I", 1, file$
	INPUT #1, a
	x = 1 + INT(a * RND)
	FOR j = 1 TO x
		INPUT #1, a$
	NEXT j
CLOSE #1
FOR k = s TO F
	IF strength(k) > 0 THEN
		IF name$(k) = a$ THEN
			IF spin < 50 GOTO redoz
		END IF
	END IF
NEXT k
IF a$ = "" THEN a$ = "Elmo"
END SUB

SUB Near1 (index, Enemy, near)
	t$ = LEFTY$(index)
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL ranger(index, vantage)
	near = 32767: Enemy = 0
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2): flag = 0

	FOR i = s TO F
	IF strength(i) < 1 OR uorder(i) = 99 GOTO nota
	d = 2 * ABS(unity(index) - unity(i)) + ABS(unitx(index) - unitx(i))
	IF d > vantage GOTO nota
	IF d < near THEN near = d: Enemy = i
nota:
	NEXT i
END SUB

SUB Near2 (index, Enemy, near)
	t$ = LEFTY$(index)
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL ranger(index, vantage)
	near = 32767: Enemy = 0
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2): flag = 0

	FOR i = s TO F
	IF strength(i) < 1 OR uorder(i) = 99 GOTO deadog
	d = 2 * ABS(unity(index) - unity(i)) + ABS(unitx(index) - unitx(i))
	IF d > vantage GOTO deadog

	dx = 100 - d
	IF t$ = "R" THEN dx = dx + 150
	IF INSTR("AL", t$) = 0 THEN
		IF strength(i) > 1.2 * strength(index) THEN dx = dx - 20
		IF strength(index) > 1.2 * strength(i) THEN dx = dx + 20
		IF strength(index) > 2 * strength(i) THEN dx = dx + 50
		ELSE
		CALL los(index, i, F, 0)
		IF Visible(i) = 0 THEN Visible(i) = 1
		IF F = 1 THEN dx = 5 ELSE dx = -999
	END IF
	IF d < near THEN dx = dx + 20
	a$ = LEFTY$(i): IF a$ = "w" THEN a$ = MID$(unit$(i), 2, 1)
	IF INSTR("AEHL", a$) > 0 THEN dx = dx + 50 + 150 * RND
	IF d < 8 THEN dx = dx + 20
	IF d < 6 THEN dx = dx + 50
	IF d < 4 THEN dx = dx + 100: : IF INSTR("AEHLB", t$) THEN dx = dx + 100 + 20 * RND
	IF terrain(i) = 233 THEN dx = dx + 150
	IF dx > flag THEN near = d: flag = dx: Enemy = i
deadog: NEXT i

IF possess <> 3 - side AND 2 * ABS(unity(index) - objy) + ABS(unitx(index) - objx) < 4 THEN Enemy = 0
END SUB

SUB normal (xbar, vary, result)
' NOTE : vary is VARIANCE
pct! = 0
FOR k = 1 TO 12: pct! = pct! + RND: NEXT k
pct! = pct! - 5.5
result = xbar + pct! * SQR(vary)
END SUB

SUB over (flag)
OPEN "O", 1, "data\outcome.&&&"
WRITE #1, 3 - sidex(flag), .01 * score&(sidex(1)), .01 * score&(sidex(2))    'scale down unit size
CLOSE #1
END
END SUB

SUB proximity (index, bonus)
s = 1: F = bigg(1): IF index > m1 THEN s = m2: F = bigg(2)
bonus = 0
FOR k = s TO F
	IF index = k OR uorder(k) = 99 GOTO toofar4
	IF 2 * ABS(unity(index) - unity(k)) + ABS(unitx(index) - unitx(k)) > 3 GOTO toofar4
	IF morale(k) + leader(k) > 7 THEN bonus = bonus + 2: IF leader(k) = 4 THEN bonus = bonus + 2
	a$ = LEFTY$(k)
	SELECT CASE a$
		CASE "G"
			bonus = bonus + .15 * leader(k)
			IF leader(k) = 5 THEN bonus = bonus + leader(k)
		CASE "R"
			bonus = -10
	END SELECT
toofar4: NEXT k
END SUB

SUB pursue (index, x, y, flag)
IF uorder(index) = 99 THEN EXIT SUB
a$ = LEFTY$(index)
SELECT CASE a$
	CASE "R", "S"
		EXIT SUB
END SELECT
z = ASC(MID$(sdtext$(y + 1), x, 1))
CALL whois(x, y, Enemy, index): IF Enemy > 0 THEN EXIT SUB

	CALL YouorMe(index, F)
	IF F = 0 OR rely = 5 GOTO blindly
	BuffClear
	t$ = "Pursue ?"
	LITEUP 8 * unitx(index), 14 * unity(index), 14
	CALL YesNo(t$): CALL scrcol(1): IF t$ = "Y" GOTO runn ELSE EXIT SUB

blindly:
IF unity(index) = objy AND unitx(index) = objx THEN EXIT SUB

a = terrain(index)
IF (a <> z) AND (z = 233 OR z = 239 OR z = 35) GOTO runn

IF ((a = 94 OR a = 239 OR a = 35)) AND RND < .9 THEN EXIT SUB
IF a = 42 AND RND < .7 THEN EXIT SUB

IF z = 61 AND RND < .7 THEN EXIT SUB
IF z = 43 OR z = 46 AND RND < .15 * bold GOTO runn
IF morale(index) < 2 THEN EXIT SUB


runn:
IF flag = 0 GOTO runn2
'============================================================================
'                             Artillery Capture
'============================================================================
 s = 1: IF index > m1 THEN s = 2
	id = 0
	IF s = 1 AND bigg(1) < m1 THEN id = bigg(1) + 1
	IF s = 2 AND bigg(2) < most THEN id = bigg(2) + 1
	IF id = 0 GOTO runn2
IF flag > .05 * strength(index) THEN flag = .05 * strength(index)
IF flag < 1 GOTO runn2
strength(id) = 10 * flag: strength(index) = strength(index) - strength(id)
unitx(id) = x: unity(id) = y: terrain(id) = z: uorder(id) = 0
morale(id) = morale(index): leader(id) = leader(index)
name$(id) = "CAPTURED": unit$(id) = "Artillery": Visible(id) = 1
toa(id) = timex + 5
CALL clrbot: COLOR 14: PRINT flag; sname$(3 - s); " artillery pieces CAPTURED ";
CALL Compact(s)
FOR k = 1 TO mdly!: CALL ATTENTION(id, 14): NEXT k
CALL SHOWUNIT(id)
TICK 99
EXIT SUB


runn2:
CALL Tara(unitx(index), unity(index) + 1, 0)
unity(index) = y: unitx(index) = x: terrain(index) = z
IF quiet > 0 THEN
	IF (side = 1 AND index < m2) OR (side = 2 AND index > m1) THEN CALL SHOWUNIT(index): PLAY "MST220o3g8g8g8o4c2MN"
END IF
IF morale(index) < 5 THEN morale(index) = morale(index) + 1 ELSE IF xper(index) < 4 THEN xper(index) = xper(index) + 1
IF leader(index) < 5 AND morale(index) > 3 THEN leader(index) = leader(index) + 1
IF z = 233 THEN SHOWUNIT (index): CALL victory(index)
IF a$ = "R" THEN CALL routed(index, 0): EXIT SUB
END SUB

SUB ranger (attack, vantage)
vantage = seelimit: IF terrain(attack) = 94 THEN vantage = seelimit + 2
IF terrain(attack) = 239 THEN vantage = seelimit + 4
IF terrain(attack) = 42 THEN vantage = seelimit - 2
IF terrain(attack) = 61 THEN vantage = seelimit - 4
END SUB

SUB refresh
	FOR k = 1 TO bigg(2)
	IF uorder(k) = 99 GOTO leave1
	IF recon = 1 GOTO showit
	CALL YouorMe(k, F): IF F > 0 THEN Visible(k) = 1: GOTO showit
	IF Visible(k) > 0 GOTO showit
	IF strength(k) > 0 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
	GOTO leave1
showit:
	IF strength(k) > 0 THEN CALL SHOWUNIT(k)
leave1: NEXT k
END SUB

SUB report
COLOR 11: CLS : flag = 0
total& = 0
COLOR 4
PRINT sname$(1); " Forces"
mtx$(0) = "Unit #   Name        Strength  Type        Morale    Leadership Experience"
mtx$(1) = "Units    " + sname$(1) + " Forces:"
PRINT mtx$(0)
COLOR 11
total& = 0: FOR k = 1 TO bigg(1): total& = total& + strength(k): NEXT k
t = 0
FOR k = 1 TO bigg(1)
	DIM a$ AS STRING
	DIM B$ AS STRING
	DIM c$ AS STRING
	CALL FormatUnitStats(k, a$, B$, c$)
	IF side = 2 AND Visible(k) = 0 GOTO hide1
	IF uorder(k) = 99 GOTO hide1
	t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
	IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
	IF t >= 20 AND flag = 0 THEN
	COLOR 4
	PRINT bigg(1); mtx$(1); total&
	CALL WaitForKey: CLS
	flag = 1
	COLOR 11
END IF
hide1: NEXT k
COLOR 4
PRINT bigg(1); mtx$(1); total&: CALL WaitForKey: CLS

total& = 0: FOR k = m2 TO bigg(2): total& = total& + strength(k): NEXT k
COLOR 9: PRINT sname$(2); " Forces"
PRINT mtx$(0)
mtx$(1) = "Units    " + sname$(2) + " Forces:"
t = 0
COLOR 11
FOR k = m2 TO bigg(2)
	DIM a$ AS STRING
	DIM B$ AS STRING
	DIM c$ AS STRING
	CALL FormatUnitStats(k, a$, B$, c$)
	IF side = 1 AND Visible(k) = 0 GOTO hide2
	IF uorder(k) = 99 GOTO hide2
	t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
	IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
IF t >= 20 AND flag = 0 THEN
	COLOR 9
	PRINT bigg(2) - m1; mtx$(1); total&: CALL WaitForKey: CLS
	PRINT sname$(2); " Forces"
	PRINT mtx$(0)
	flag = 1
	COLOR 11
END IF
hide2: NEXT k
COLOR 9
PRINT bigg(2) - m1; mtx$(1); total&: CALL WaitForKey
GOTO runner

' GOSUB hold8 converted to SUB
SUB WaitForKey
	LOCATE 24, 1: PRINT "hit a key";
	DO WHILE INKEY$ = "": LOOP
END SUB

' GOSUB fog converted to SUB
SUB FormatUnitStats (k AS INTEGER, a$ AS STRING, B$ AS STRING, c$ AS STRING)
	CALL valid(k)
	a$ = morlev$(morale(k))
	B$ = ledlev$(leader(k))
	c$ = xplev$(xper(k))
END SUB
CALL YouorMe(k, F): IF F = 1 THEN a = strength(k): RETURN
a = .7 * strength(k) + .6 * RND * strength(k)
IF RND > .7 THEN a$ = "?": IF RND > .5 THEN a$ = "Fearless"
IF RND > .7 THEN B$ = "?": IF RND > .5 THEN B$ = "Brilliant"
IF RND > .7 THEN c$ = "?": IF RND > .5 THEN c$ = "Elite"
RETURN

runner:
CLS
CALL mainmap
CALL refresh
END SUB

SUB rest (k)
	IF morale(k) < leader(k) THEN morale(k) = morale(k) + 1
	IF morale(k) < 3 THEN morale(k) = morale(k) + 1
	IF RND < .2 * leader(k) AND morale(k) < 3 THEN morale(k) = morale(k) + 1
	toa(k) = timex + 1
	movesleft = 0
	CALL SHOWUNIT(k)
	CALL YouorMe(k, F): IF F = 0 THEN EXIT SUB
	IF LEFTY$(k) <> "w" THEN
		COLOR 15
		clrbot
		PRINT name$(k); " is resting for 1 turn";
		CALL TICK(.1 * mdly!)
	END IF
END SUB

SUB retreat (index, defend)
IF LEFTY$(index) = "A" THEN
	IF RND > .15 * morale(index) THEN
		unit$(index) = "LArtillery"
		CALL routed(index, 1)
	END IF
EXIT SUB
END IF

IF LEFTY$(index) = "S" THEN CALL routed(index, 1)
IF uorder(index) = 99 GOTO rip
rflag = 0
id = 1: IF index > m1 THEN id = 2
IF strength(index) < 1 GOTO rip

FOR k = 1 TO mdly!
ATTENTION index, 13
NEXT k

clrbot
s = 1: IF index > m1 THEN s = 2
COLOR 13: PRINT sname$(s); " unit "; name$(index); " must pull back ";
rout = 0: uorder(index) = 0

dxs = SGN(unitx(defend) - unitx(index)): dys = SGN(unity(defend) - unity(index))
flag = 10 * dys + dxs
xnew = unitx(index): ynew = unity(index)

SELECT CASE flag
CASE -11
a$ = "QOM"
CASE -9
a$ = "OKQ"
CASE -1
a$ = "MIQ"
CASE 1
a$ = "KOG"
CASE 9
a$ = "IGM"
CASE 11
a$ = "GKI"
CASE -10
a$ = "OQ"
CASE 10
a$ = "GI"
CASE ELSE
END SELECT
'============================================================================
dx = LEN(a$)
FOR k = 1 TO dx
xnew = unitx(index): ynew = unity(index)
CALL curser(MID$(a$, k, 1), xnew, ynew)
	CALL CheckRunLocation(xnew, ynew, id, blox): IF blox = 0 GOTO woe
NEXT k
'============================================================================
rout = 1 + .05 * strength(index): IF RND > .5 THEN rout = rout * 2
score&(id) = score&(id) + rout
CALL scrcol(2)
CALL flash(index)
COLOR 15: IF index > m1 THEN COLOR 9
clrbot
PRINT "EXTRA DAMAGE TAKEN :"; rout; " ";
SHOWUNIT (index)
morale(index) = morale(index) - 1: morale(defend) = morale(defend) + 1
leader(index) = leader(index) - 1: leader(defend) = leader(defend) + 1
CALL flee(index)
GOTO woe

' GOSUB run1 converted to SUB
SUB CheckRunLocation (xnew AS INTEGER, ynew AS INTEGER, id AS INTEGER, blox AS INTEGER)
	DIM z AS INTEGER
	DIM Enemy AS INTEGER
	
	blox = 0
	IF xnew < 1 XOR xnew > 55 THEN blox = 1: EXIT SUB
	IF ynew < 1 XOR ynew > 20 THEN blox = 1: EXIT SUB
	z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
	IF z = 233 THEN
		IF possess <> id THEN blox = 1
	END IF
	CALL whois(xnew, ynew, Enemy, 0): IF Enemy > 0 THEN blox = 1
END SUB

woe:
IF blox > 0 GOTO steady
CALL Tara(unitx(index), unity(index) + 1, 0)

COLOR 4: IF index > m1 THEN COLOR 9
	unitx(index) = xnew: unity(index) = ynew
       
	FOR k = 1 TO mdly!
	ATTENTION index, 13
	NEXT k
       
	CALL YouorMe(defend, F)
	u$ = LEFTY$(defend)

	IF F = 0 THEN
		uorder(defend) = 100 * ynew + xnew
	ELSE
		IF rely > 2 AND INSTR("A", u$) = 0 THEN uorder(defend) = 100 * ynew + xnew
	END IF
	
	terrain(index) = z
	IF z = 233 THEN CALL TICK(mdly!): CALL victory(index)

steady: IF rout = 0 THEN TICK .2 * mdly!
	morale(index) = morale(index) - 1: IF morale(index) < 0 THEN morale(index) = 1
	killed = 1 + .02 * strength(index) + rout: IF killed > strength(index) THEN killed = strength(index)

score&(id) = score&(id) + killed
strength(index) = strength(index) - killed
CALL scrcol(2)
IF RND > .2 THEN leader(index) = leader(index) - 2: IF rout > 0 THEN leader(index) = leader(index) - INT(10 * RND)
	IF rout = 0 THEN
		IF RND > .18 * morale(index) THEN CALL routed(index, 3)
		GOTO rip
	END IF
	IF quiet > 0 THEN
		IF index > m1 THEN PLAY "T150O3L8C;FCFG;A4G" ELSE PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
	END IF
	IF RND > .05 * xper(index) THEN CALL routed(index, 3)
	IF quiet < 1 THEN TICK mdly!
rip:
	CALL wipeout(index)
	CALL YouorMe(index, F): IF F > 0 THEN CALL inspect(index)
	CALL SHOWUNIT(index)
END SUB

SUB routed (index, flag)
SELECT CASE flag
	CASE 0  'morale check
		x = morale(index): IF x < leader(index) THEN x = leader(index)
		IF RND < .05 * x GOTO reform ELSE EXIT SUB
	CASE 1  'rout
broken:
		IF LEFTY$(index) = "S" THEN unit$(index) = "Infantry"
		IF LEFTY$(index) <> "R" THEN unit$(index) = "R" + unit$(index)
		morale(index) = 1
		CALL flee(index)
		s = 1: IF index > m1 THEN s = 2
		elan(s) = elan(s) - 3
	CASE 2  'recover
reform:
		IF LEFTY$(index) <> "R" THEN EXIT SUB
		s = 1: IF index > m1 THEN s = 2
		IF RND > .01 * elan(s) THEN EXIT SUB
		unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		FOR k = 1 TO 2: ATTENTION index, 14
		IF quiet > 0 THEN SOUND 1800, .3: TICK .1
		NEXT k
		CALL clrbot: COLOR 15: PRINT name$(index); " has rallied";
		IF quiet > 0 THEN SOUND 900, 1: SOUND 999, .7
		uorder(index) = 0: movesleft = movesleft - 1
		TICK mdly!
	EXIT SUB
	toa(index) = timex + 2: movesleft = 0
	CALL SHOWUNIT(index)
	IF quiet > 0 THEN SOUND 1600, .5: TICK .05: SOUND 1700, .5
	CALL ATTENTION(index, 13)
	CALL inspect(index)
	CASE 3
		IF RND < .1 * xper(index) THEN EXIT SUB
		IF leader(index) > 3 THEN IF RND < .1 * leader(index) THEN EXIT SUB
		GOTO broken
END SELECT
END SUB

SUB scrcol (flag)            '0=full draw  1=menu clear   2 or more =update info only
IF flag = 1 THEN LINE (454, 30)-(631, 152), 8, BF
IF flag < 2 THEN
	LINE (453, 153)-(630, 266), 4, B
	LINE (449, 2)-(449, 299), 4, B
	LINE (453, 13)-(631, 28), 4, B
	LINE (454, 14)-(630, 27), 0, BF
	LINE (454, 40)-(631, 86), 9, B
	LINE (455, 41)-(630, 85), 0, BF

	COLOR 9: LOCATE 4, 65: PRINT " "; UCASE$(sname$(2)): IF side = 2 THEN LOCATE 4, 60: PRINT CHR$(16)
	LOCATE 5, 59: PRINT "LOSSES     :"; score&(2)
	COLOR 14: LOCATE 6, 62: IF possess = 2 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 9
     
	LINE (454, 95)-(631, 141), 7, B
	LINE (455, 96)-(630, 140), 0, BF
	COLOR 4: LOCATE 8, 65: PRINT " "; UCASE$(sname$(1)): IF side = 1 THEN LOCATE 8, 60: PRINT CHR$(16)
	LOCATE 9, 59: PRINT "LOSSES     :"; score&(1)
	COLOR 14: LOCATE 10, 62: IF possess = 1 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 4: LOCATE 2, 59: PRINT "Time Left :";
	CALL UpdateTimeDisplay(flag)
ELSE
	IF flag > 10 THEN CALL UpdateTimeDisplay(flag): EXIT SUB
	COLOR 9
	IF side = 2 THEN LOCATE 4, 60: PRINT CHR$(16)
	LOCATE 5, 71: PRINT score&(2)
	COLOR 4
	IF side = 1 THEN LOCATE 8, 60: PRINT CHR$(16)
	LOCATE 9, 71: PRINT score&(1)
	COLOR 14
	CALL UpdateTimeDisplay(flag)
END IF
EXIT SUB
' GOSUB tim1 converted to SUB
SUB UpdateTimeDisplay (flag AS INTEGER)
	IF flag = 0 OR flag = 12 THEN CALL BUTTON(58, 21, 4, "QUIET", 1 - quiet)
	IF timex = 32767 THEN EXIT SUB
	COLOR 15: IF timelimit - timex < 21 THEN COLOR 12: IF bold < 4 THEN bold = 4
	LOCATE 2, 70: PRINT timelimit - timex
END SUB
END SUB

SUB see (attack)
IF strength(attack) < 1 OR uorder(attack) = 99 OR LEFTY$(attack) = "R" GOTO nosee
CALL YouorMe(attack, flag)
u$ = LEFTY$(attack)

seehim:
	CALL ranger(attack, vantage)
	s = m2: F = bigg(2): IF attack > m1 THEN s = 1: F = bigg(1)
	FOR defend = s TO F
	IF strength(defend) < 1 OR uorder(defend) = 99 GOTO ourboy
	IF defend = attack GOTO ourboy
	IF attack < m2 AND defend < m2 GOTO ourboy
	IF attack > m1 AND defend > m1 GOTO ourboy
	d = 2 * ABS(unity(attack) - unity(defend)) + ABS((unitx(attack) - unitx(defend)))
	IF d < 4 THEN
		GOTO suresee
	END IF

	IF d > vantage GOTO ourboy
	IF lineofsight > 0 THEN
		CALL los(attack, defend, F, 0)
		IF F = 0 GOTO ourboy
	END IF
'============================================================================
'                               Reveal Unit
'============================================================================
suresee:
	CALL SHOWUNIT(defend): CALL SHOWUNIT(attack)
	IF terrain(defend) = 42 AND d > 4 GOTO ourboy
	Visible(attack) = 1: Visible(defend) = 1
	IF INSTR("AG", u$) > 0 GOTO ourboy
	IF RND > .05 * bold GOTO ourboy

	pct! = strength(attack) / strength(defend)
	pct! = pct! * .3 * leader(attack) * morale(attack) / d
	IF pct! < 1.2 - .1 * bold GOTO ourboy
	IF uorder(attack) > 0 AND RND > .15 * bold GOTO ourboy
	IF uorder(attack) = 100 * objy + objx AND RND < .95 GOTO ourboy
	IF flag = 0 THEN IF RND > 1 - .1 * bold THEN uorder(attack) = 100 * objy + objx: EXIT SUB
	IF flag > 0 THEN
		IF LEFTY$(attack) = "C" THEN IF RND > .5 OR LEFTY$(defend) = "S" THEN uorder(attack) = 0: GOTO ourboy
		IF morale(attack) + leader(attack) + xper(attack) > 8 THEN uorder(attack) = 0: GOTO ourboy
	END IF
	uorder(attack) = 100 * unity(defend) + unitx(defend)
	IF strength(defend) < 50 OR morale(defend) < 2 THEN CALL flee(defend)
	a$ = LEFTY$(defend)
	IF INSTR("AG", a$) > 0 GOTO ourboy
	IF a$ <> "R" THEN uorder(defend) = 100 * unity(attack) + unitx(attack): GOTO brave
	GOTO ourboy
brave:
	CALL YouorMe(attack, flag): IF flag > 0 THEN index = attack: GOTO me1
	CALL YouorMe(defend, flag): IF flag > 0 THEN index = defend: GOTO me1
	GOTO ourboy
me1:
	IF RND < .1 * leader(index) - .1 * rely THEN uorder(index) = 0
	IF rely = 1 THEN uorder(index) = 0
	CALL proximity(index, bonus): IF bonus > 10 THEN uorder(index) = 0
	t$ = LEFTY$(index)
	IF INSTR("GA", t$) > 0 THEN uorder(index) = 0
ourboy:
	NEXT defend
	IF unity(attack) = objy AND unitx(attack) = objx THEN uorder(attack) = 0
nosee:
END SUB

SUB squares (index, flag)
SELECT CASE flag
	CASE 1                                  'to infantry
		unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		CALL SHOWUNIT(index)
		IF quiet > 0 THEN SOUND 1700, .3
		uorder(index) = 0: movesleft = 0
		toa(index) = timex + 1 + 2 * RND
	CASE 2                                  'to square
		IF RND > .1 * (morale(index) + leader(index) + xper(index)) THEN
			movesleft = 0
			CALL YouorMe(index, F): IF F = 0 THEN EXIT SUB
			CALL clrbot
			PRINT name$(index); " could not form a hollow square"; : TICK 1
			IF quiet > 0 THEN SOUND 200, 1
			EXIT SUB
		END IF
		unit$(index) = "S" + unit$(index)
		CALL SHOWUNIT(index)
		IF quiet > 0 THEN SOUND 1800, .3
		uorder(index) = 0: movesleft = 0
		toa(index) = timex + 1 + 2 * RND
END SELECT
END SUB

SUB startmap
	sdtext$(1) = CHR$(219) + STRING$(53, CHR$(219)) + CHR$(219)
	sdtext$(2) = CHR$(219) + " . . . . . . . . . . . . . . . . . . . . . . . . . . " + CHR$(219)
	sdtext$(3) = CHR$(219) + ". . . . . . . . . . . . . . . . . . . . . . . . . . ." + CHR$(219)
	sdtext$(22) = CHR$(219) + STRING$(53, CHR$(219)) + CHR$(219)
	sdtext$(23) = ""
	sdtext$(24) = ""
	FOR k = 4 TO 20 STEP 2
	sdtext$(k) = sdtext$(2)
	sdtext$(k + 1) = sdtext$(3)
	NEXT k
END SUB

SUB target (index)
PCOPY 0, 1
SCREEN 9, , 1, 1
y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
IF x > 54 THEN uorder(index) = 0: EXIT SUB
clrbot
COLOR 11: PRINT name$(index); " is moving to location at "; x; ","; y;
LINE (8 * unitx(index) + 8, 14 * unity(index) + 6)-(8 * x + 8, 14 * y + 6), 15
CIRCLE (8 * x + 8, 14 * y + 6), 3, 15
IF quiet > 0 THEN SOUND 3000, .2
TICK .2 * mdly!
SCREEN 9, , 0, 0
END SUB

SUB TICK (sec!)
start! = TIMER
sec! = ABS(sec!)
IF sec! < 1 THEN
	DO WHILE TIMER - start! < sec!: LOOP: EXIT SUB
END IF
DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP: EXIT SUB
END SUB

SUB valid (index)
IF morale(index) < 1 THEN morale(index) = 1
IF leader(index) < 1 THEN leader(index) = 1
IF morale(index) > 5 THEN morale(index) = 5
IF leader(index) > 5 THEN leader(index) = 5
IF xper(index) < 1 THEN xper(index) = 1
IF xper(index) > 5 THEN xper(index) = 5
IF LEFTY$(index) <> "R" THEN
	IF xper(index) > 3 AND morale(index) < 2 THEN morale(index) = 2
	IF xper(index) = 5 AND morale(index) < 3 THEN morale(index) = 3
END IF
END SUB

SUB victory (index)
IF index < 1 OR terrain(index) <> 233 THEN EXIT SUB
COLOR 4: IF index > 40 THEN COLOR 9
CALL clrbot: COLOR 15: PRINT name$(index); " has taken the objective !";
possess = 1
IF index < m2 AND possess <> 1 THEN possess = 1: CALL PlayYanksSound: s = m2: F = bigg(2)
IF index > m1 AND possess <> 2 THEN possess = 2: CALL PlayFranksSound: s = 1: F = bigg(1)
elan(possess) = elan(possess) + 10: CALL brittle(possess)
FOR k = s TO F
	IF INSTR("GRA", LEFTY$(k)) = 0 AND uorder(k) <> 99 THEN uorder(k) = 100 * objy + objx
NEXT k
	IF possess = 1 THEN
		s = 1: F = bigg(1)
	ELSE
		s = m2: F = bigg(2)
	END IF
FOR k = s TO F
IF uorder(k) > 0 AND uorder(k) <> 99 THEN uorder(k) = 0
NEXT k
CALL scrcol(1)
CALL TICK(.1 * mdly!)
EXIT SUB
' GOSUB franks converted to SUB
SUB PlayFranksSound
	IF quiet > 0 THEN PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
END SUB

' GOSUB yanks converted to SUB
SUB PlayYanksSound
	IF quiet > 0 THEN PLAY "T150O3L8C;FCFG;A4G"
END SUB
END SUB

SUB whois (x, y, Enemy, index)
Enemy = 0
FOR k = 1 TO bigg(2)
IF strength(k) < 1 OR uorder(k) = 99 OR index = k GOTO nobody
IF unitx(k) = x AND unity(k) = y THEN
	Enemy = k: EXIT SUB
END IF
nobody:
NEXT k
END SUB

SUB wipeout (index)
IF index < 1 OR strength(index) > 0 OR unitx(index) = 1 THEN EXIT SUB
COLOR 9: a$ = sname$(2): x = 1
IF index < m2 THEN COLOR 4: a$ = sname$(1): x = 2
elan(x) = elan(x) + 5: elan(3 - x) = elan(3 - x) - 5
IF LEFTY$(index) = "G" THEN elan(x) = elan(x) - 10
FOR k = 1 TO 2: CALL brittle(k): NEXT k
CALL clrbot: LOCATE 23, 15: PRINT a$; " unit "; name$(index); " has been eliminated";
CALL scrcol(2)
uorder(index) = 0: strength(index) = 0
unit$(index) = "X"
CALL SHOWUNIT(index)
unit$(index) = ""
IF quiet > 0 THEN PLAY "MBt120l16o1mna4a8.aa2"
CALL TICK(.3): CALL TICK(.8 * mdly!)
CALL Tara(unitx(index), unity(index) + 1, 0)

s = 1: IF index > m1 THEN s = 2
CALL Compact(s): index = 0: IF strength(1) > 0 AND strength(41) > 0 THEN EXIT SUB

dx = 0: FOR k = 1 TO bigg(1): IF strength(k) > 0 THEN dx = 1: EXIT FOR
NEXT k
dy = 0: FOR k = m2 TO bigg(2): IF strength(k) > 0 THEN dy = 1: EXIT FOR
NEXT k

IF dx > 0 AND dy > 0 THEN EXIT SUB
s = 2: IF dx = 0 THEN s = 1
COLOR 14: CALL clrbot: PRINT sname$(s); " forces ANNIHILATED : Bonus = 250"; : vp&(3 - s) = vp&(3 - s) + 250
CALL TICK(99): CALL expire: CALL TICK(99): END

END SUB

SUB YesNo (a$)
IF a$ <> "" THEN mtx$(0) = a$
tly = 2: colour = 4
tlx = 62 - .5 * LEN(mtx$(0))
mtx$(1) = "No"
mtx$(2) = "Yes"
size = 2: CALL menu
a$ = "N": IF choose = 2 THEN a$ = "Y"
END SUB

SUB YouorMe (index, F)
F = 0: IF side = 1 AND index < m2 THEN F = 1
IF side = 2 AND index > m1 THEN F = 1
END SUB

'============================================================================
' SUB definitions from NAP1C.BAS (merged into single file)
'============================================================================

SUB menu
	DEFINT A-Z
	PCOPY 0, 1
	SCREEN 9, , 1, 1
	IF colour = 0 THEN colour = 7
	LOCATE 1, 1, 0
	IF mtx$(0) = "" THEN mtx$(0) = "M E N U"

	IF wide = 0 THEN CALL CalculateMenuWidth(wide, ndx, size)
	IF tlx = 0 THEN CALL AdjustMenuPosition(tlx, wide)
	IF choose < 21 THEN choose = 1
	IF choose > 21 THEN choose = choose - 21: IF choose > 21 THEN choose = 1
	row = choose: IF row = 0 THEN row = 1
	IF row > size THEN row = 1
	choose = row
	row1 = row
     
	IF tly = 0 THEN tly = INT(11.5 - .5 * size)
	IF tly + size > 21 THEN tly = 21 - size
     
	brx = tlx + wide + 1
	bry = tly + size + 3
     
	COLOR colour
	LINE (8 * tlx, 14 * (tly) - 4)-(8 * (tlx + wide + 2), 14 * (tly + size + 2) + 4), 0, BF
	LINE (8 * tlx, 14 * (tly) - 4)-(8 * (tlx + wide + 2), 14 * (tly + size + 2) + 4), colour, B
	LINE (8 * tlx, 14 * tly + 19)-(8 * (tlx + wide + 2), 14 * tly + 22), colour, B
	LINE (8 * (tlx + wide + 2) + 1, 14 * tly + 8)-(8 * (tlx + wide + 3) + 1, 14 * (tly + size + 3) + 1), 0, BF
	LINE (8 * (tlx + 1) + 4, 14 * (tly + size + 2) + 5)-(8 * (tlx + wide + 2) + 1, 14 * (tly + size + 3) + 1), 0, BF
	COLOR colour
	b1 = INT(.5 * (wide - LEN(mtx$(0))) + .5) + 1
     
	LOCATE tly + 1, tlx + b1: PRINT mtx$(0)

	FOR i = 1 TO size
	LOCATE tly + 2 + i, tlx + 2: PRINT mtx$(i)
	NEXT i

sel1:
	COLOR hilite
	LOCATE tly + 2 + row, tlx + 2: PRINT mtx$(row)
	CALL GetMenuKey(a$, row, row1, size, choose)
	IF ASC(a$) = 13 GOTO called
	COLOR colour
	LOCATE tly + 2 + row1, tlx + 2: PRINT mtx$(row1)
	choose = row
	GOTO sel1

' GOSUB crsr converted to SUB - Note: Uses GOTO for flow control
SUB GetMenuKey (a$ AS STRING, row AS INTEGER, row1 AS INTEGER, size AS INTEGER, choose AS INTEGER)
	DIM k AS INTEGER
	DIM c1$ AS STRING
	DIM c2$ AS STRING
	
	DO: a$ = INKEY$: LOOP WHILE a$ = ""
akey5:
	IF ASC(a$) = 32 THEN choose = 99: EXIT SUB
	IF ASC(a$) = 13 THEN EXIT SUB
	IF LEN(a$) = 2 GOTO arrows
	IF ASC(a$) = 27 THEN choose = -1: EXIT SUB
		row1 = row
		FOR k = 1 TO size
		c1$ = UCASE$(a$)
		c2$ = UCASE$(LEFT$(mtx$(k), 1))
		IF c1$ = c2$ THEN row = k: choose = row: CALL LimitRow(row, size): EXIT SUB
		NEXT k
	CALL GetMenuKey(a$, row, row1, size, choose)
	EXIT SUB
arrows:
	a$ = RIGHT$(a$, 1)
	row1 = row
	 IF a$ = "G" THEN row = 1: CALL LimitRow(row, size): EXIT SUB
	 IF a$ = "H" THEN row = row - 1: CALL LimitRow(row, size): EXIT SUB
	 IF a$ = "I" THEN row = 1: CALL LimitRow(row, size): EXIT SUB
	 IF a$ = "O" THEN row = size: CALL LimitRow(row, size): EXIT SUB
	 IF a$ = "P" THEN row = row + 1: CALL LimitRow(row, size): EXIT SUB
	 IF a$ = "Q" THEN row = size: CALL LimitRow(row, size): EXIT SUB
END SUB
	 ' FRE(-1) not supported in QB64 - debug memory display feature removed
	 ' IF a$ = "" THEN LOCATE 1, 1: PRINT FRE(-1)
	 RETURN
' GOSUB limits converted to SUB
SUB LimitRow (row AS INTEGER, size AS INTEGER)
	IF row > size THEN row = 1
	IF row < 1 THEN row = size
END SUB

' GOSUB mxw converted to SUB
SUB CalculateMenuWidth (wide AS INTEGER, ndx AS INTEGER, size AS INTEGER)
	DIM i AS INTEGER
	DIM l AS INTEGER
	
	wide = LEN(mtx$(0)) + 3
     
	ndx = 0
	FOR i = 1 TO size
	l = LEN(mtx$(i))
	IF l > wide THEN wide = l: ndx = i
	NEXT i
END SUB

' GOSUB noadjust converted to SUB
SUB AdjustMenuPosition (tlx AS INTEGER, wide AS INTEGER)
	IF tlx = 0 THEN tlx = INT(39 - .5 * wide)
END SUB

called:
	IF quiet > 0 THEN SOUND 700, .5
	COLOR colour
	SCREEN 9, , 0, 0
END SUB


