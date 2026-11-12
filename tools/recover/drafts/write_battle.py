"""Write new/battle.bas: WON's battle, from the disassembly of WON.03 and
Civil War Strategy's battle."""
from pathlib import Path

HALF = "\xab"  # CP437 one half
BAR = "\xb2"  # CP437 dark shade

text = f'''SUB battle (attack, defend, win, lose)
IF armysize(defend) < 1 THEN armysize(defend) = 1
IF armysize(attack) < 1 THEN armysize(attack) = 1

CALL icon(armyloc(defend), 0, 9)
LINE (528, 60)-(638, 435), 0, BF
y = 68: COLOR 11
c = 9: IF attack > 25 THEN c = 4
a$ = armyname$(attack): IF LEN(a$) > 11 THEN a$ = LEFT$(a$, 11)
COLOR c: LOCATE 5, y: PRINT a$
LOCATE 6, y: CALL strong(attack)
x = .01 * armysize(attack): IF x > TCR THEN x = TCR
LOCATE 7, y: PRINT "Base    "; x
IF armysize(attack) / armysize(defend) > .2 THEN x = x + .3 * armylead(attack) + .3 * armyexper(attack): IF x > TCR THEN x = TCR
IF armyexper(attack) > 8 THEN x = x + 1: IF x > TCR THEN x = TCR
IF attack = 1 THEN x = 2 * x
LOCATE 8, y: PRINT "Ldr/Exp "; x
IF armysize(attack) < 15 THEN x = .5 * x: IF x > TCR THEN x = TCR
IF armysize(attack) / armysize(defend) <= .5 THEN x = x - 2: IF x < 1 THEN x = 1
IF armysize(attack) / armysize(defend) > 3 THEN x = x + 2: IF x > TCR THEN x = TCR
IF armysize(attack) / armysize(defend) > 10 THEN x = TCR
IF armysize(attack) / armysize(defend) <= .2 THEN x = 1
LOCATE 9, y: PRINT "Outman  "; x
IF supply(attack) < 1 THEN x = .5 * x: COLOR 13
LOCATE 10, y: PRINT "Supply  "; x: COLOR c
IF x < 1 THEN x = 1
'                       Adjust attack advantage
IF attack < 26 AND side = 2 AND difficult > 3 THEN x = x + 2 * difficult - 6
IF attack > 25 AND side = 1 AND difficult < 3 THEN x = x + 6 - 2 * difficult
COLOR c
IF u558(attack) <> u1da4(attack) THEN x = .7 * x: COLOR 13
LOCATE 11, y: PRINT "Cohesion"; x
LOCATE 12, y: PRINT "Difclt  "; x
IF x > TCR THEN x = TCR
COLOR 11: LOCATE 13, y: PRINT "Attack  "; x
LINE (530, 191)-(635, 207), 11, B

x1 = .013 * armysize(defend) + 1
a$ = armyname$(defend): IF LEN(a$) > 11 THEN a$ = LEFT$(a$, 11)
COLOR 13 - c: LOCATE 15, y: PRINT a$
LOCATE 16, y: CALL strong(defend)
LOCATE 17, y: PRINT "Base    "; INT(.01 * armysize(defend))
LOCATE 18, y: PRINT "Defense "; x1
IF armysize(defend) / armysize(attack) > .2 THEN x1 = x1 + .3 * armylead(defend) + .3 * armyexper(defend): IF x1 > TCR THEN x1 = TCR
IF armyexper(defend) > 8 THEN x1 = x1 + 1: IF x1 > TCR THEN x1 = TCR
IF defend = 1 THEN x1 = 2 * x1
LOCATE 19, y: PRINT "Ldr/Exp "; x1
IF armysize(defend) < 15 THEN x1 = .5 * x1

R! = armysize(defend) / armysize(attack)
SELECT CASE R!
	CASE IS > 10
		x1 = TCR
	CASE IS > 1.5
		x1 = x1 + 2
	CASE IS < .5
		x1 = .8 * x1
	CASE IS < .2
		x1 = .5 * x1
END SELECT
	IF x1 < 1 THEN x1 = 1
	IF x1 > TCR THEN x1 = TCR

LOCATE 20, y: PRINT "Outman  "; x1
IF supply(defend) < 1 THEN x1 = .5 * x1: COLOR 13
LOCATE 21, y: PRINT "Supply  "; x1: COLOR 13 - c
IF u558(defend) <> u1da4(defend) THEN x1 = .7 * x1: COLOR 13
LOCATE 22, y: PRINT "Cohesion"; x1
IF x1 < 1 THEN x1 = 1
'                       Adjust defend advantage
IF defend < 26 AND side = 2 AND difficult > 3 THEN x1 = x1 + 2 * difficult - 6
IF defend > 25 AND side = 1 AND difficult < 3 THEN x1 = x1 + 6 - 2 * difficult
LOCATE 23, y: PRINT "Difclt  "; x1

a$ = "Fort": IF armymove(defend) = 0 THEN x1 = x1 * (1 + .5 * fort(armyloc(defend)))
IF x1 > TCR THEN x1 = TCR
IF fort(armyloc(defend)) > 0 AND armymove(defend) = 0 THEN
	COLOR 13: a$ = "Fort+"
	IF fort(armyloc(defend)) = 2 THEN a$ = "Fort++"
END IF
LOCATE 24, y: PRINT a$; TAB(76); x1
IF x1 > TCR THEN x1 = TCR
COLOR 11: LOCATE 25, y: PRINT "Defend  "; x1
LINE (530, 383)-(635, 400), 11, B

spin = 0
scale = x: IF x1 > scale THEN scale = x1
scale = scale + 1

odds! = x / (x + x1): a = INT(100 * odds!): IF a < 1 THEN a = 1
a$ = LTRIM$(RTRIM$(STR$(a))) + "%"
COLOR 14: LOCATE 27, y: PRINT "Odds:  "; a$;
LINE (530, 412)-(635, 435), 14, B
LINE (528, 410)-(637, 437), 14, B
CALL TICK(9)
FOR i = 1 TO 2: IF supply(i) > 0 THEN supply(i) = supply(i) - 1
NEXT i
IF u8c0 <= 0 GOTO grapple
IF LEN(DIR$("rrs.exe")) <> 0 GOTO grapple
IF armysize(attack) / armysize(defend) > 3 XOR armysize(defend) / armysize(attack) > 3 GOTO grapple
'                       Fight the battle in the tactical game
	x = armysize(attack): x1 = armysize(defend)
	t$ = " OUT OF SUPPLY : FIGHTS AT {HALF} STRENGTH"
	IF supply(attack) < 1 THEN x = x \\ 2: CALL image2(armyname$(attack) + t$, 4)
	IF supply(defend) < 1 THEN x1 = x1 \\ 2: CALL image2(armyname$(defend) + t$, 4)
	t$ = " : LOW COHESION = 30% PENALTY"
	IF u558(attack) <> u1da4(attack) THEN x = .7 * x: CALL image2(armyname$(attack) + t$, 4)
	IF u558(defend) <> u1da4(defend) THEN x1 = .7 * x1: CALL image2(armyname$(defend) + t$, 4)
	OPEN "O", 1, "battle.$$$"
	a = 1: y = 2: IF attack < 25 THEN a = 2: y = 1
	WRITE #1, city$(armyloc(defend)), 3 - side, a, y, armyname$(attack), x, armylead(attack), armyexper(attack), armyname$(defend), x1, armylead(attack), armyexper(defend), difficult, fort(armyloc(defend)), noise
	CLOSE #1
	SHELL "napoleon.exe"
	OPEN "I", 1, "outcome.&&&"
	INPUT #1, w, killa, killd
	CLOSE #1
	SELECT CASE w
		CASE 1
			win = attack: lose = defend
		CASE ELSE
			win = defend: lose = attack
	END SELECT
	CALL europe
	w = 1: IF win > 25 THEN w = 4
	CALL image2(armyname$(win) + " is VICTORIOUS in " + city$(armyloc(defend)), w)
	CALL calendar
	CALL disband
	GOTO tally
'---------------------------------------------------------------------------
grapple:
	hit = 0: hit1 = 0
	star = scale * RND: fin = scale * RND
	IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	IF star <= x THEN hit = 1
	IF fin <= x1 THEN hit1 = 1

	IF hit = 0 AND hit1 = 0 GOTO grapple
	IF hit = 1 AND hit1 = 1 GOTO grapple
	win = defend: lose = attack: IF hit = 1 THEN win = attack: lose = defend
'---------------------------------------------------------------------------
	a$ = "French": IF win > 25 THEN a$ = "Allies"
	a = 1: IF win > 25 THEN a = 2
	CALL image2(a$ + " VICTORY in " + city$(armyloc(defend)) + " : " + armyname$(win) + " beats " + armyname$(lose), 4)
'===========================================================================
	pct! = .01 * DEFAC - .03 * fort(armyloc(defend)): IF win = attack THEN pct! = 1.3 * pct!
	SELECT CASE armysize(defend)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armysize(attack) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killd)
'...........................................................................
	pct! = .01 * ATKFAC + .02 * fort(armyloc(defend)): IF win = defend THEN pct! = 1.5 * pct!
	SELECT CASE armysize(attack)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armysize(defend) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killa)
'===========================================================================

	killa = .8 * killa + .2 * killd: IF killa < 1 THEN killa = 1
	killd = .8 * killd + .2 * killa: IF killd < 1 THEN killd = 1
	IF killa > 9 * killd THEN killa = 9 * killd
	IF killd > 5 * killa THEN killd = 5 * killa

tally:
IF killa >= armysize(attack) THEN killa = armysize(attack) - 1
IF killd >= armysize(defend) THEN killd = armysize(defend) - 1
'---------------------------------------------------------------------------
x = INT(100 * odds!): IF x < 1 THEN x = 1
a$ = LTRIM$(RTRIM$(STR$(x))) + "%"

COLOR c
CALL clrbot: PRINT "Attack Loss: ";
PRINT LTRIM$(RTRIM$(STR$(killa)) + "00"); "/";
CALL strong(attack)
PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / armysize(attack)))))); "%) {BAR}";
COLOR 13 - c: PRINT "{BAR} Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
CALL strong(defend)
PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killd / armysize(defend)))))); "%)";
'---------------------------------------------------------------------------
mtx$(1) = " (" + LTRIM$(RTRIM$(STR$(killa) + "00")) + "/" + LTRIM$(STR$(armysize(attack)) + "00") + ") "
t$ = " (" + LTRIM$(RTRIM$(STR$(killd) + "00")) + "/" + LTRIM$(STR$(armysize(defend)) + "00") + ")"
mtx$(2) = t$
IF win = defend THEN mtx$(2) = mtx$(1): mtx$(1) = t$
mtx$(3) = "*" + armyname$(win): mtx$(4) = armyname$(lose)
IF win = defend THEN mtx$(3) = armyname$(win): mtx$(4) = "*" + armyname$(lose)
a$ = city$(armyloc(defend)) + ": " + mtx$(3) + mtx$(1) + " defeats " + mtx$(4) + mtx$(2)
CALL scribe(a$, 0)

IF player = 1 AND (side = 1 AND attack > 25) OR (side = 2 AND attack < 26) THEN
CALL TICK(9)
END IF

armysize(attack) = armysize(attack) - killa
armysize(defend) = armysize(defend) - killd
CALL TICK(2)
'---------------------------------------------------------------------------
s = 1: IF attack > 2 THEN s = 2
casualty&(s) = casualty&(s) + killa
casualty&(3 - s) = casualty&(3 - s) + killd
'---------------------------------------------------------------------------
s = 1: IF win > 25 THEN s = 2
IF armysize(defend) < 1 THEN armysize(defend) = 1
batwon(s) = batwon(s) + 1
victory(s) = victory(s) + 1
IF s = 1 THEN x = 5 ELSE x = -2
CALL enter(x)
IF s = 1 THEN
	IF u558(attack) = 1 THEN x = defend ELSE x = attack
	u892(u558(x)) = u892(u558(x)) + 10
END IF
CALL icon(armyloc(defend), 0, 8)
LINE (528, 60)-(638, 435), 2, BF
END SUB
'''
Path("new/battle.bas").write_bytes(text.replace("\r\n", "\n").encode("latin1"))
print("new/battle.bas written")
