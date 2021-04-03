DEFINT A-Z
DECLARE SUB align (index%, x%, y%)
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB brittle (who%)
DECLARE SUB despair (index%)
DECLARE SUB squares (index%, flag%)
DECLARE SUB namer (file$, s%, F%, a$)
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB Near1 (index%, Enemy%, near%)
DECLARE SUB over (flag%)
DECLARE SUB randarm (k%)
DECLARE SUB randmap ()
DECLARE SUB replace (y%, x%, z%)
DECLARE SUB routed (index%, flag%)
DECLARE SUB startmap ()
DECLARE SUB vistarg (active%, flag%)
REM $INCLUDE: 'nap10.bi'
RANDOMIZE TIMER: CLS

DIM SHARED Image(1 TO 1564), IAlly(60), CAlly(60), AAlly(60), GAlly(60)
DIM SHARED IFrench(60), CFrench(60), AFrench(60), GFrench(60)
DIM SHARED Cterr(60), Hterr(60), Sterr(60), Fterr(60)
DIM SHARED Tterr(60), Mterr(60), Oterr(60), Rterr(60)
DIM SHARED Wterr(60), Vterr(60), Bridge(60), Xhair(60)
DIM SHARED Explo(60), Death(60), Boat(60), RAlly(60), RFrench(60)
DIM SHARED WFrench(60), Wally(60), HSFrench(60), HSAlly(60), LAAlly(60), LAFrench(60)
choose = 22: GOSUB lodecfg
mdly! = mdsp: IF mdsp = 5 THEN mdly! = 10
OPEN "I", 1, "equip.dat"
	FOR k = 0 TO 5: INPUT #1, equip$(k): NEXT k
CLOSE #1
CALL iconload
menu6:
	ON ERROR GOTO 0
menu7:
	SCREEN 9
	IF quiet > 0 THEN SOUND 1900, 1: SOUND 2000, 1

hilite = 14
OPEN "I", 1, "battle.$$$"
INPUT #1, SCENARIO$, side, sidex(1), sidex(2), commander$(sidex(1)), vp&(sidex(1)), leadbase(sidex(1)), expbase(sidex(1)), commander$(sidex(2)), vp&(sidex(2)), leadbase(sidex(2)), expbase(sidex(2)), difficult, fort, quiet
CLOSE #1
CALL randmap
setupx = 1 + INT(4 * RND)
timelimit = 25 + 5 * fort
IF vp&(1) > 200 AND vp&(2) > 200 THEN timelimit = 40 + 5 * fort
IF side = sidex(2) THEN
	timelimit = timelimit + 10
	bold = 3
	IF RND > .5 THEN bold = 4: IF RND > .5 THEN bold = 5
END IF
timelimit = timelimit + .1 * obstruct
unitsize& = vp&(1): IF vp&(2) > vp&(1) THEN unitsize& = vp&(2)
unitsize& = 3 * unitsize&
IF unitsize& < 500 THEN unitsize& = 500
bigg(2) = most
FOR k = 1 TO 2
vp&(k) = vp&(k) * 100           'scale up unit size
NEXT k
FOR k = 1 TO 2
CALL randarm(k)
NEXT k
seelimit = 18: IF RND > .8 THEN seelimit = 10 + INT(9 * RND)
name$(1) = commander$(1)
name$(41) = commander$(2)
IF name$(41) = "Napoleon" THEN
	leader(41) = 5: xper(41) = 5: morale(41) = 5
END IF
FOR k = 1 TO most
	IF strength(k) > 0 THEN
		z = ASC(MID$(sdtext$((unity(k) + 1)), unitx(k), 1))
		terrain(k) = z
	END IF
NEXT k

FOR i = 1 TO 2
	k = sidex(i)
	a = leader(1): IF k = 1 THEN a = leader(41)
	elan(k) = 80 + 5 * (expbase(k) - 3) + 5 * (a - 3)
	CALL brittle(k)
NEXT i

TICK 2
flag = 1
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ******************    BEGIN MAIN GAME LOOP    ******************  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
ON ERROR GOTO 0
SCREEN 9, , 0, 0
CALL mainmap
	CALL clrbot: COLOR 4: PRINT "Initializing";
	FOR i = 1 TO 2: CALL Compact(i): NEXT i
	CALL lowtime
	FOR k = 1 TO bigg(2): Visible(k) = 0
	IF strength(k) > 0 AND uorder(k) <> 99 AND terrain(k) = 233 THEN CALL victory(k)
	NEXT k

	s = 1: F = bigg(side): IF side = 2 THEN s = m2
	FOR active = s TO F: IF strength(active) > 0 AND uorder(active) <> 99 THEN Visible(active) = 1: CALL see(active)
	NEXT active

	startit! = TIMER
IF file$ = "ERROR" GOTO menu7
CALL refresh
    
nother: CALL order: IF LEN(file$) > 1 GOTO nother
IF file$ = "๔" THEN file$ = "": END
IF file$ = "๕" THEN file$ = "": flag = 0: GOTO menu7
GOTO nother
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ    END   MAIN GAME LOOP    ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
lodecfg:
	RESTORE
	FOR k = 1 TO 5: READ adj1$(k): NEXT k
	FOR k = 1 TO 5: READ adj2$(k): NEXT k
	FOR k = 1 TO 5: READ adj3$(k): NEXT k
	FOR k = 1 TO 2: READ sname$(k): NEXT k
	FOR k = 1 TO 5: READ xplev$(k): NEXT k
	FOR k = 1 TO 5: READ ledlev$(k): NEXT k
	FOR k = 1 TO 5: READ morlev$(k): NEXT k
	bold = 3: seelimit = 18: side = 1: mdsp = 3
	limber = 1
	rely = 4: stakk = 3: lineofsight = 1: artcap = 1
	RETURN

DATA Timid,Cautious,Normal,Bold,Reckless
DATA Very Easy,Easy,Normal,Hard,Very Hard
DATA VERY Fast,Fast,Normal,Slow,VERY Slow
DATA Allies,French
DATA Green,Raw,Veteran,Seasoned,Hardened
DATA Inept,Weak,Good,Strong,Brilliant
DATA Beaten,Low,Good,High,Fearless

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
	IF LEFTY$(defend) = "่" THEN unit$(defend) = "Infantry": flag = flag + 2
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
a$ = "I่CGALSwR": unitx(0) = 1: strength(0) = 1
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
LOCATE 9, 56: PRINT "10 	 -15%"  'ฐ
LOCATE 10, 57: PRINT "2 	   0" '้
LOCATE 11, 57: PRINT "8 	  +9%"'๏
LOCATE 12, 57: PRINT "2 	  +3%" 'þ
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
	DEF SEG = VARSEG(Image(1))
	BLOAD "stdicon.ega", VARPTR(Image(1))
	DEF SEG

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
	DEF SEG = VARSEG(Image(1))
	BLOAD "alticon.ega", VARPTR(Image(1))
	DEF SEG

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
	DEF SEG = VARSEG(Image(1))
	BLOAD "terrain.ega", VARPTR(Image(1))
	DEF SEG
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
	DEF SEG = VARSEG(Image(1))
	BLOAD "misc.ega", VARPTR(Image(1))
	DEF SEG
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
	IF t$ = "I" OR t$ = "G" OR t$ = "่" OR t$ = "R" THEN
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
IF LEFTY$(attack) = "่" THEN roll! = roll! + .02: bonus = bonus + .05 * leader(attack)
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
	IF LEFTY$(attack) = "่" THEN pct# = pct# - .02

	IF prd! >= .07 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0
	IF terrain(defend) = 35 THEN pct# = pct# + .03
	IF prd! >= pct# THEN CALL retreat(defend, attack)

	IF rflag = 0 AND pra! < pct# - .01 AND INSTR("AL", u$) = 0 THEN CALL pursue(attack, x2, y2, 0)
seeme:
	IF LEFTY$(attack) = "่" THEN unit$(attack) = "Infantry"
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
	IF timelimit - timex <= 0 THEN CALL clrbot: COLOR 14: PRINT "Time expired - battle of "; SCENARIO$; " is over "; : TICK 99: CALL expire: file$ = "๕": EXIT SUB
	FOR k = 1 TO 2: CALL brittle(k): NEXT k

	CALL scrcol(2)

	FOR active = 1 TO bigg(2): CALL BuffClear
	t$ = LEFTY$(active)
	SELECT CASE t$
		CASE "A"
			movesleft = 1
		CASE "I", "G", "L"
			movesleft = 2
		CASE "่"
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
	IF uorder(active) = 99 THEN GOSUB canplace: IF uorder(active) = 99 THEN movesleft = 0: GOTO sleep2
	IF t$ = "w" THEN CALL rest(active): uorder(active) = 0: GOTO sleep2
	flag = 1
stillgoing:
	CALL YouorMe(active, F): IF F = 0 THEN GOSUB otherside: GOTO asleep
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
	GOSUB cline
'============================================================================
'                     Get Keyboard Command
'============================================================================
wait3:
	commnd$ = INKEY$: IF commnd$ = "" GOTO wait3
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

	CASE 27: GOSUB noise1: GOTO wait2
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
		IF t$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "่nfantry": toa(active) = timex + 1: CALL BUTTON(58, 25, 4, "Charge", 1): : GOSUB noise1: GOTO asleep
	CASE 70
		IF INSTR("A", t$) > 0 THEN dx = 1: GOTO fodder
	CASE 71: IF a = 2 GOTO moven
		GOSUB ahead
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
		GOSUB allterr
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
	CASE 87: CALL BUTTON(41, 25, 4, "Wait", 1): GOSUB whoa1: GOTO asleep
	CASE 88: IF t$ = "G" THEN GOSUB cancel: IF y > 0 GOTO asleep ELSE GOTO wait2
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
	IF LEFTY$(active) = "S" THEN CALL clrbot: COLOR 14: PRINT "Hollow squares may not move"; : GOSUB noise1: GOTO wait3
	IF limber > 0 AND INSTR("A", t$) > 0 THEN
		IF LEFTY$(active) <> "L" THEN CALL limbo(active, 2): IF LEFTY$(active) = "L" GOTO asleep ELSE GOTO wait2
	END IF
	xloc = unitx(active): yloc = unity(active)
	CALL curser(commnd$, xloc, yloc)
	IF yloc = unity(active) AND xloc = unitx(active) THEN GOSUB noise1: GOTO wait3
	CALL placeunit(xloc, yloc, active)
	IF uorder(active) = 1 THEN COLOR 14: clrbot: PRINT "Cannot move in that direction "; : GOSUB noise2: CALL TICK(1): uorder(active) = 0: GOTO wait2
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
IF a$ = "I" OR a$ = "่" AND (terrain(active) = 43 OR terrain(active) = 46) THEN
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
	IF a$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN unit$(active) = "่nfantry": CALL SHOWUNIT(active): toa(active) = timex + 1: RETURN
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
IF uorder(active) > 0 THEN CALL cupdate(active)
CALL see(active)
IF uorder(active) > 0 AND movesleft > 0 GOTO speed
movesleft = 0
RETURN
'============================================================================
'                              Sounds
'============================================================================
noise1: IF quiet > 0 THEN SOUND 1900, 1
	RETURN
noise2: IF quiet > 0 THEN SOUND 400, .7
	RETURN
noise3: IF quiet > 0 THEN SOUND 600, 2: SOUND 900, 2
	RETURN
'============================================================================
'                               Stats on Unit Under Cursor
'============================================================================
stats:
CALL inspect(id)
CALL YouorMe(id, F): IF F > 0 THEN IF uorder(id) > 99 AND dx <> 4 THEN CALL target(id): GOSUB inlin
RETURN
'============================================================================
cline:
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
	RETURN
wait5:
	commnd$ = INKEY$: IF commnd$ = "" GOTO wait5
	dxs = ASC(UCASE$(commnd$)): dys = LEN(commnd$)
	IF dxs = 27 OR dxs = 32 OR dxs = 76 OR dxs = 88 THEN RETURN
	IF dxs = 13 THEN RETURN
	IF dys = 1 AND ASC(commnd$) > 48 AND ASC(commnd$) < 58 THEN RETURN
	IF dys < 2 GOTO wait5
	a = LEN(commnd$)
	commnd$ = RIGHT$(commnd$, 1)

	SELECT CASE ASC(commnd$)
	CASE 59
		CALL help
		GOTO wait5
	CASE 68
		 IF a = 2 THEN CLS : file$ = "๔": EXIT SUB
	CASE ELSE
	END SELECT

	RETURN
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                             Late Arrivals                          บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
canplace:
	CALL whois(unitx(active), unity(active), id, active)
	IF id > 0 THEN RETURN
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
		ATTENTION active, 15: IF quiet > 0 THEN GOSUB noise1
		NEXT k
	END IF

	CALL YouorMe(active, F)
	IF F > 0 AND t$ = "G" THEN RETURN
	CALL Near2(active, Enemy, d)
	TICK .5 * mdly!
	IF Enemy = 0 OR RND > .5 THEN uorder(active) = 100 * objy + objx: RETURN
	IF t$ = "A" THEN CALL cannon(active, Enemy): RETURN
	uorder(active) = 100 * unity(Enemy) + unitx(Enemy)
	IF F > 0 THEN TICK .2 * mdly!
	RETURN
'============================================================================
'                               cancel orders
'============================================================================
cancel:
CALL clrbot: PRINT " General "; name$(active); " cancelling orders : ";
x = 0: y = 0: s = 1: F = bigg(side): IF side = 2 THEN s = m2
FOR i = s TO F
IF strength(i) = 0 OR uorder(i) < 1 OR uorder(i) = 99 GOTO corpse
IF LEFTY$(i) = "R" GOTO corpse
y = y + 1
IF RND < .2 * leader(active) THEN
	uorder(i) = 0
	CALL ATTENTION(i, 13)
	IF quiet > 0 THEN SOUND 2900, .1: TICK .02
	GOTO corpse
END IF
x = x + 1
corpse:
NEXT i
IF y = 0 THEN PRINT "NO UNITS UNDER ORDERS"; : TICK .2 * mdly!: CALL clrbot: RETURN
movesleft = movesleft - 1
PRINT y - x; " of "; y; " units obeyed"; : TICK .2 * mdly!: CALL clrbot
RETURN
'============================================================================
'                               Score Hot Key
'============================================================================
ahead:
	CALL expire
	CALL mainmap: CALL refresh: CALL inspect(active)
	RETURN
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
		GOSUB flash
	END IF

	IF dx <> 2 GOTO wait2
	uorder(active) = 100 * yloc + xloc
	IF limber > 0 AND INSTR("A", t$) > 0 THEN
		CALL limbo(active, 2)
		GOSUB flash
		IF LEFTY$(active) = "L" GOTO asleep ELSE GOTO wait2
	END IF
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
	IF d = 0 GOTO wait2
	IF dx = 2 AND d < 4 THEN
		uorder(active) = 100 * yloc + xloc
		CALL cupdate(active)
		IF uorder(active) = 1 THEN uorder(active) = 0: CALL TICK(.5): GOSUB flash: GOTO wait2
		uorder(active) = 0
		GOTO asleep
	ELSE
		CALL target(active)
		GOSUB flash
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
	GOSUB inlin

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
	CALL whois(xloc, yloc, id, 0): IF id > 0 THEN GOSUB stats
	GOSUB Awaken
	COLOR 13: LOCATE 23, 68: PRINT d;
	CASE ELSE
END SELECT
       
	GOSUB wait5
	IF ASC(commnd$) = 13 GOTO here2
	CALL curser(commnd$, xloc, yloc)

	GOSUB flash
	PUT (8 * x, 14 * y), Xhair, XOR
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))

	SELECT CASE dxs
	CASE 27
	GOSUB flash: CALL refresh: GOTO wait2
	CASE 32
	GOSUB flash: CALL rest(active): GOTO asleep
	CASE 76
	GOSUB flash: CALL limbo(active, 1): GOTO asleep
	CASE 87
	GOSUB whoa1: GOTO asleep
	CASE ELSE
	END SELECT

	GOTO movex
'...........................................................................
here2:
	IF dx = 2 OR dx = 5 GOTO here
	IF dx = 3 THEN GOSUB flash: GOTO wait2
	IF dx = 4 THEN GOSUB flash: GOTO RAlly
	CALL whois(xloc, yloc, Enemy, active)
	IF Enemy = 0 OR Visible(Enemy) = 0 THEN
			GOSUB flash
			GOSUB noise3
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
		GOSUB flash
		GOSUB noise3
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
Awaken:
	IF LEFTY$(id) = "w" THEN
		CALL YouorMe(id, F)
		IF F > 0 THEN
			unit$(id) = RIGHT$(unit$(id), LEN(unit$(id)) - 1)
			CALL SHOWUNIT(id)
			GOSUB flash
		END IF
	END IF
	RETURN
allterr:
FOR k = 1 TO bigg(2)
IF strength(k) > 0 AND uorder(k) <> 99 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
NEXT k
RETURN
inlin:
	COLOR 11: clrbot: PRINT "INTELLIGENCE: move cursor over units"; : COLOR 15: PRINT "  (ESC when done) ";
	LOCATE 23, 61: COLOR 11: PRINT "Range :";
	RETURN
flash:
	PUT (8 * xloc, 14 * yloc), Xhair, XOR: RETURN
whoa1:
	COLOR 15: unit$(active) = "w" + unit$(active): clrbot: PRINT name$(active); " is WAITING until alerted"; : TICK .1 * mdly!: CALL rest(active): RETURN

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
	IF LEFTY$(Enemy) = "่" THEN unit$(Enemy) = "Infantry"
	GOTO rumble
try2:
	IF LEFTY$(index) = "I" AND morale(index) > 2 AND (terrain(index) = 43 OR terrain(index) = 46) THEN unit$(index) = "่nfantry": toa(index) = timex + 1: EXIT SUB
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
	CASE "่"
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
	IF LEFTY$(index) = "่" AND (RND > .97 OR (terrain(index) <> 43 AND terrain(index) <> 46)) THEN unit$(index) = "Infantry": toa(index) = timex + 2 + 2 * RND
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
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                    Special Cleanup -Contacted Units                บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

special:
uorder(index) = 1
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ                            Combine Units                           บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
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
COLOR 15: LOCATE 15, 63: PRINT ""
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
dx = 41: file$ = "french.dat": IF who = 1 THEN file$ = "allies.dat": dx = 1

COLOR 4: LOCATE 23, 1: PRINT "Placing armies ... "
CALL arrange(who, xloc, yloc)

LINE (455, 110)-(622, 140), 4, B
allarm = vp&(who) / unitsize&

FOR i = 1 TO allarm
	spin = 0
	index = 40 * (who - 1) + i
coord:
	spin = spin + 1: IF spin > 99 GOTO muster
	GOSUB xxyy

	unitx(index) = xx - 10 + 20 * RND
	unity(index) = yy - 5 + 10 * RND
	IF unitx(index) < 2 THEN unitx(index) = 2
	IF unitx(index) > 54 THEN unitx(index) = 54
	IF unity(index) < 2 THEN unity(index) = 1
	IF unity(index) > 20 THEN unity(index) = 20

	GOSUB odd: IF flag = 0 GOTO chek2
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

xxyy:
	xx = xloc: yy = yloc
	IF xx = 99 THEN xx = 1 + INT(54 * RND)
	IF yy = 99 THEN yy = 1 + INT(24 * RND)
	RETURN
odd:    flag = 0
	IF (unitx(index) + unity(index)) <> INT(.5 * (unitx(index) + unity(index))) * 2 THEN flag = 1
	RETURN
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
IF LEN(DIR$("quotes.dat")) > 0 THEN
	OPEN "I", 1, "quotes.dat"
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
	IF RND > r! GOTO moret
	xloc = 4 + 50 * RND: yloc = 4 + 16 * RND
	x1 = xloc: y1 = yloc
	r! = .2 + .3 * RND: x = 8 * RND
	IF fort = 0 OR side = sidex(2) GOTO morerd
morewat:                        ' water
	IF RND > .9 THEN x = 8 * RND
	GOSUB nearhere: GOSUB adjx: GOSUB lim1: IF flag = 1 GOTO nowat
	CALL replace(yloc, xloc, 176)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOTO morewat
nowat:
	IF x1 > 0 THEN xloc = x1: yloc = y1: x1 = 0: GOTO morewat
	IF RND > .6 GOTO trees
moret:
	GOSUB rloc
	IF RND < .5 THEN yloc = 0: GOSUB adjx: x = 6: IF RND > .5 THEN x = 8: GOTO morerd
	yloc = 21: GOSUB adjx: x = 1: IF RND > .5 THEN x = 3
morerd:                         ' road
	GOSUB nearhere: GOSUB lim1: IF flag = 1 OR spin > 99 GOTO endrd
	CALL replace(yloc, xloc, 43)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOTO morerd
endrd:
	spin = 0
	IF RND > .8 GOTO nowat

trees:                          ' trees
	GOSUB rloc
newtree:
	x = 8 * RND: GOSUB nearhere: GOSUB lim1: IF flag = 1 GOTO endtree
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 GOTO newtree
	CALL replace(yloc, xloc, 42)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOTO newtree
endtree:
	IF obstruct > 80 GOTO donehere
	IF RND > .4 GOTO trees

hills:                          ' hills
	GOSUB rloc: r! = .3 + .6 * RND
morehill:
	x = 8 * RND: GOSUB nearhere: GOSUB lim1: IF flag = 1 GOTO endhill
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 GOTO morehill
	a = 239: IF RND < .8 THEN a = 94
	CALL replace(yloc, xloc, a)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	GOTO morehill
endhill:
	IF obstruct > 80 GOTO donehere
	IF RND > .4 GOTO hills

other:                          ' other features
	GOSUB rloc: r! = .1
morestuf:
	GOSUB lim1: IF flag = 1 GOTO donehere
xtrastuf:
	z = ASC(MID$(sdtext$(yloc + 1), xloc, 1)): IF z <> 46 GOTO other
	z = 35
	IF RND > .2 + .2 * fort THEN z = 254
	IF RND > .4 + .1 * fort THEN z = 61
	CALL replace(yloc, xloc, z)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	IF RND > .5 - .1 * fort THEN GOSUB nearhere: GOTO xtrastuf
	IF obstruct > 80 GOTO donehere
	IF RND > .1 GOTO other
	GOTO donehere
'============================================================================
rloc:
	xloc = 2 + 53 * RND: yloc = 1 + 19 * RND
	IF xloc + yloc <> INT((xloc + yloc) / 2) * 2 THEN GOSUB adjx
	RETURN
nearhere:
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
	IF RND < r! THEN GOSUB rloc
END SELECT
	IF xloc < 1 THEN xloc = 1
	IF yloc > 21 THEN yloc = 21
	IF xloc > 55 THEN xloc = 55
	IF yloc < 1 THEN yloc = 1
	RETURN
adjx:
	IF xloc + yloc = INT((xloc + yloc) / 2) * 2 THEN RETURN
	IF xloc > 2 THEN xloc = xloc - 1: RETURN
	IF xloc < 54 THEN xloc = xloc + 1: RETURN
lim1:
	flag = 0
	IF xloc > 54 OR xloc < 2 THEN flag = 1
	IF yloc > 20 OR yloc < 1 THEN flag = 1
	spin = spin + 1
	RETURN
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
t$ = MID$(sdtext$(y + 1), x, 1): IF t$ = "้" THEN nobj = nobj - 1
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

