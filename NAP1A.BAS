DEFINT A-Z
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB brittle (who%)
DECLARE SUB routed (index%, flag%)
DECLARE SUB ishi (x%)
DECLARE SUB over (flag%)
REM $INCLUDE: 'nap10.bi'

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

SUB brittle (who)
IF elan(who) > 100 THEN elan(who) = 100
IF elan(who) < 1 THEN
	elan(who) = 0
	LINE (40, 110)-(420, 200), 0, BF
	c = 4: IF who = 2 THEN c = 1
	LINE (40, 100)-(410, 190), c, BF
	LINE (50, 110)-(400, 180), 4, B
	COLOR 15: LOCATE 11, 10: PRINT "Entire " + sname$(who) + " army has BROKEN IN PANIC !"
	IF quiet > 0 THEN PLAY "t180o3c4c8.c16g4.P8e4g8.e16c2"
	TICK 3
	CALL over(who)
END IF
END SUB

SUB BuffClear
DEF SEG = 0
POKE 1050, 30: POKE 1052, 30
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

IF LEFTY$(Enemy) = "è" THEN unit$(Enemy) = "Infantry"
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
COLOR 14: LOCATE 12, 40: PRINT STRING$(10, "°")
COLOR 14: LOCATE 14, 40: PRINT STRING$(10, "°")
FOR k = 1 TO 2
	IF elan(k) < 1 THEN elan(k) = 0
NEXT k
x = elan(sidex(2)) * .1
a$ = STRING$(x, "²")
COLOR 4: IF sidex(2) = 2 THEN COLOR 9
LOCATE 14, 19: PRINT sname$(sidex(2)); TAB(30); score&(sidex(2)); TAB(40); a$
IF elan(sidex(2)) < 30 THEN COLOR 15: LOCATE 14, 60: PRINT "BREAKING!"
COLOR 4: IF sidex(1) = 2 THEN COLOR 9
x = elan(sidex(1)) * .1
a$ = STRING$(x, "²")
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

IF y > 1 THEN y = unity(index) - 1: x = unitx(index) - 1: GOSUB eval
IF y > 1 THEN y = unity(index) - 1: x = unitx(index) + 1: GOSUB eval
IF y < 22 THEN y = unity(index) + 1: x = unitx(index) - 1: GOSUB eval
IF y < 22 THEN y = unity(index) + 1: x = unitx(index) + 1: GOSUB eval
IF x > 1 THEN x = unitx(index) - 2: GOSUB eval
IF x < 59 THEN x = unitx(index) + 2: GOSUB eval

a = 1 + INT(m1 * RND): IF side = 2 THEN a = a + m1
IF (strength(a) > 0 AND uorder(a) <> 99) AND LEFTY$(index) <> "R" THEN uorder(index) = 100 * unity(a) + unitx(a)
GOTO best

eval:
IF x < 1 THEN x = 1
IF x > 59 THEN x = 59
IF y < 1 THEN y = 1
IF y > 22 THEN y = 22
z = SCREEN(y + 1, x): IF z = 35 OR z = 42 XOR z = 94 XOR z = 239 GOTO improve
RETURN

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
x = INSTR(sdtext$(k), "é"): IF x > 0 THEN objx = x: objy = k - 1: count = count + 1
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
OPEN "O", 1, "outcome.&&&"
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
	GOSUB fog
	IF side = 2 AND Visible(k) = 0 GOTO hide1
	IF uorder(k) = 99 GOTO hide1
	t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
	IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
	IF t >= 20 AND flag = 0 THEN
	COLOR 4
	PRINT bigg(1); mtx$(1); total&
	GOSUB hold8: CLS
	flag = 1
	COLOR 11
END IF
hide1: NEXT k
COLOR 4
PRINT bigg(1); mtx$(1); total&: GOSUB hold8: CLS

total& = 0: FOR k = m2 TO bigg(2): total& = total& + strength(k): NEXT k
COLOR 9: PRINT sname$(2); " Forces"
PRINT mtx$(0)
mtx$(1) = "Units    " + sname$(2) + " Forces:"
t = 0
COLOR 11
FOR k = m2 TO bigg(2)
	GOSUB fog
	IF side = 1 AND Visible(k) = 0 GOTO hide2
	IF uorder(k) = 99 GOTO hide2
	t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
	IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
IF t >= 20 AND flag = 0 THEN
	COLOR 9
	PRINT bigg(2) - m1; mtx$(1); total&: GOSUB hold8: CLS
	PRINT sname$(2); " Forces"
	PRINT mtx$(0)
	flag = 1
	COLOR 11
END IF
hide2: NEXT k
COLOR 9
PRINT bigg(2) - m1; mtx$(1); total&: GOSUB hold8
GOTO runner

hold8:
LOCATE 24, 1: PRINT "hit a key";
DO WHILE INKEY$ = "": LOOP
RETURN

fog:
CALL valid(k)
a$ = morlev$(morale(k))
B$ = ledlev$(leader(k))
c$ = xplev$(xper(k))
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
GOSUB run1: IF blox = 0 GOTO woe
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

run1:
blox = 0
IF xnew < 1 XOR xnew > 55 THEN blox = 1: RETURN
IF ynew < 1 XOR ynew > 20 THEN blox = 1: RETURN
z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
IF z = 233 THEN
	IF possess <> id THEN blox = 1
END IF
CALL whois(xnew, ynew, Enemy, 0): IF Enemy > 0 THEN blox = 1
RETURN

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

	COLOR 9: LOCATE 4, 65: PRINT " "; UCASE$(sname$(2)): IF side = 2 THEN LOCATE 4, 60: PRINT ""
	LOCATE 5, 59: PRINT "LOSSES     :"; score&(2)
	COLOR 14: LOCATE 6, 62: IF possess = 2 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 9
     
	LINE (454, 95)-(631, 141), 7, B
	LINE (455, 96)-(630, 140), 0, BF
	COLOR 4: LOCATE 8, 65: PRINT " "; UCASE$(sname$(1)): IF side = 1 THEN LOCATE 8, 60: PRINT ""
	LOCATE 9, 59: PRINT "LOSSES     :"; score&(1)
	COLOR 14: LOCATE 10, 62: IF possess = 1 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 4: LOCATE 2, 59: PRINT "Time Left :";
	GOSUB tim1
ELSE
	IF flag > 10 THEN GOSUB tim1: EXIT SUB
	COLOR 9
	IF side = 2 THEN LOCATE 4, 60: PRINT ""
	LOCATE 5, 71: PRINT score&(2)
	COLOR 4
	IF side = 1 THEN LOCATE 8, 60: PRINT ""
	LOCATE 9, 71: PRINT score&(1)
	COLOR 14
	GOSUB tim1
END IF
EXIT SUB
tim1:
IF flag = 0 OR flag = 12 THEN CALL BUTTON(58, 21, 4, "QUIET", 1 - quiet)
IF timex = 32767 THEN RETURN
COLOR 15: IF timelimit - timex < 21 THEN COLOR 12: IF bold < 4 THEN bold = 4
LOCATE 2, 70: PRINT timelimit - timex
RETURN
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
	sdtext$(1) = "É" + STRING$(53, "Í") + "»"
	sdtext$(2) = "º . . . . . . . . . . . . . . . . . . . . . . . . . . º"
	sdtext$(3) = "º. . . . . . . . . . . . . . . . . . . . . . . . . . .º"
	sdtext$(22) = "È" + STRING$(53, "Í") + "¼"
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
IF index < m2 AND possess <> 1 THEN possess = 1: GOSUB yanks: s = m2: F = bigg(2)
IF index > m1 AND possess <> 2 THEN possess = 2: GOSUB franks: s = 1: F = bigg(1)
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
franks: IF quiet > 0 THEN PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
	RETURN
yanks: IF quiet > 0 THEN PLAY "T150O3L8C;FCFG;A4G"
       RETURN
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

