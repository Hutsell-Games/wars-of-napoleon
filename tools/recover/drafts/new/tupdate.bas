SUB tupdate
flag = 0
CALL bossarmy
IF player = 1 THEN CALL smarts: nflag = 0
FOR i = 1 TO 50
IF armyloc(i) > 0 AND armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
NEXT i
CALL clrbot: PRINT "press any key for "; month$(month); ","; year; " events";
CALL TICK(9)
GOSUB upbox
'==========================================================================
'                       Assign Time of Action
'==========================================================================
FOR i = 1 TO 50
brray(i) = 999
IF armymove(i) < 0 THEN armymove(i) = 0
IF armyloc(i) > 0 AND armymove(i) > 0 THEN brray(i) = INT(4 + 4 * RND) * 100 + i
IF supply(i) < 1 AND armymove(i) > 0 THEN brray(i) = 900 + i
SELECT CASE armysize(i)         'bigger armies move slower
	CASE IS > 400
		IF brray(i) < 900 THEN brray(i) = brray(i) + 100: x = 2
	CASE IS > 800
		IF brray(i) < 800 THEN brray(i) = brray(i) + 200: x = 3
	CASE IS > 1000
		IF brray(i) < 700 THEN brray(i) = brray(i) + 300: x = 4
	CASE ELSE
		x = 1
END SELECT
IF brray(i) <> 999 AND armylead(i) > 10 * RND THEN
		brray(i) = brray(i) - 100 * (armylead(i) \ 2)
		IF brray(i) < 100 THEN brray(i) = 100 + i
END IF
NEXT i

CALL bub2(50)
'==========================================================================
'                       Begin Main Loop
'==========================================================================
FOR j = 1 TO 50
flag = 0
IF brray(j) = 999 GOTO allthru
active = INT(brray(j) / 100): active = brray(j) - 100 * active: s = 1: IF active > 25 THEN s = 2
IF armymove(active) < 1 GOTO digin
COLOR 11: CALL clrbot: PRINT armyname$(active); " is moving to "; city$(armymove(active));

supply(active) = supply(active) - 1: IF supply(active) < 0 THEN supply(active) = 0: CALL TICK(turbo!): CALL clrbot: PRINT armyname$(active); " is out of supplies !";

CALL placearmy(active)
CALL icon(armyloc(active), armymove(active), 5)

CALL animate(active, 1)
'==========================================================================
target = armymove(active)
IF occupied(target) = 0 GOTO easy
IF (s = 1 AND occupied(target) < 26) OR (s = 2 AND occupied(target) > 25) GOTO friend ELSE GOTO enemy
'==========================================================================
'                         Join Forces
'==========================================================================
friend:
COLOR 11: CALL clrbot: PRINT armyname$(active); " and "; armyname$(occupied(target)); " meet in "; city$(target); : CALL TICK(turbo!)
CALL icon(armymove(active), 0, 6)
CALL clrbot
GOTO easy
'==========================================================================
'                       Attack
'==========================================================================
enemy:
CALL icon(target, 0, 3)
defend = occupied(target)

COLOR 11: CALL clrbot: PRINT armyname$(active); " attacks "; armyname$(defend); " in "; city$(armyloc(defend)); : CALL TICK(turbo! - 1)
IF armysize(defend) > 0 THEN CALL battle(active, defend, win, lose): flag = 1
IF armyexper(win) < 10 THEN armyexper(win) = armyexper(win) + 1

IF armysize(lose) < 2 THEN
	a$ = armyname$(lose) + "'s army is crushed in " + city$(armyloc(defend))
	CALL scribe(a$, 2)
	index = lose: GOTO crushed
END IF

'==========================================================================
'                       Attacker Loses
'==========================================================================
IF win = active GOTO kickbutt
armymove(active) = armyloc(active)
armyloc(active) = target
COLOR 11: CALL clrbot: PRINT armyname$(active); " withdraws to "; city$(armymove(active));

CALL animate(active, 1)

armyloc(active) = armymove(active)
CALL placearmy(active)
occupied(armyloc(active)) = active
armymove(active) = -2
	      
IF 11 * RND > armylead(defend) THEN CALL icon(armyloc(defend), armymove(defend), 4): IF armymove(defend) > 0 THEN armymove(defend) = -2

CALL TICK(turbo!): GOTO digin
'==========================================================================
'                       Defender Retreats
'==========================================================================
kickbutt:
	CALL icon(armyloc(active), target, 4)
	IF armymove(defend) > 0 THEN CALL icon(target, armymove(defend), 4)

	CALL retreat(defend, flee): IF flee > 0 THEN move2 = flee: GOTO outta

	best = 0: flee = 0
	FOR i = 1 TO 6
	x = matrix(target, i)
	IF x > 0 AND (cityp(x) = 3 - s) AND cityv(x) > best THEN
		IF best = 0 THEN
			flee = i: best = cityv(x)
		ELSE
			IF occupied(x) = 0 THEN flee = i: best = cityv(x)
		END IF
	END IF
	NEXT i
	IF flee = 0 GOTO deadmeat
	move2 = matrix(target, flee)
outta:
	CALL placearmy(defend)                  ' in old city

	armymove(defend) = move2
	CALL animate(defend, 0)                 ' animate retreat
       
	armyloc(defend) = move2
	occupied(move2) = defend
	CALL clrbot
	PRINT armyname$(defend) + " is withdrawing to " + city$(move2);

	CALL placearmy(defend)                  ' in new city
       
	CALL icon(target, 0, 6)
	armymove(defend) = -2
	GOTO holdon

deadmeat:
	index = defend
	z = 1: IF index > 25 THEN z = 2
	a$ = force$(z) + " " + armyname$(index) + " surrenders to " + armyname$(active) + " in " + city$(armyloc(index))
	CALL scribe(a$, 2)
crushed:
	IF noise > 1 AND s <> side THEN PLAY "MFMST220o3g8g8g8o4c2"
	IF armymove(index) > 0 THEN CALL icon(armyloc(index), armymove(index), 4)
	x = 15: IF s = side THEN x = -15
	CALL enter(s)
	victory(3 - s) = victory(3 - s) + 25
	IF index > 1 THEN
surr:
		x = cityx(target) - 12: y = cityy(target) - 11
		CALL cityicon(target)
		FOR k = 0 TO 7
			LINE (x - 7, y - 7)-(x + 9, y + 4), 2, BF
			LINE (x + k - 7, y + k - 7)-(x - k + 8, y - k + 5), 5, BF
			CALL TICK(.15)
		NEXT k
		LINE (x - 7, y - 7)-(x + 9, y + 4), 2, BF
		LINE (x + 8, y - 2)-(x + 8, y + 5), 0
		CIRCLE (x + 1, y - 2), 8, 15, , , .4
		LINE (x - 7, y)-(x + 8, y + 5), 15, BF
		PAINT (x, y - 2), 15
		PSET (x - 6, y + 4), 15
		DRAW "c0S4" + font$(18) + "BR2" + font$(9) + "BR2" + font$(16)
		CALL TICK(1)
		armyloc(index) = 0: lname$(index) = "": armyname$(index) = ""
		armysize(index) = 0: armylead(index) = 0
		armyexper(index) = 0: armymove(index) = 0: supply(index) = 0
		supply(active) = supply(active) + supply(index): supply(index) = 0
		IF supply(active) > 10 THEN supply(active) = 10
	ELSE
		IF occupied(16) = 0 THEN
			n = 16: IF player = 1 AND side = 2 THEN u73a = n
		ELSE
			IF n = 0 THEN CALL image2("Napoleon banished to St. Helena", 1): GOTO surr
		END IF
		IF n = 0 THEN CALL image2("Napoleon banished to St. Helena", 1): GOTO surr
		armyloc(1) = n: armysize(1) = 10: cityp(n) = 1: occupied(n) = 1
		CALL image2("Napoleon removed to " + city$(n), 3)
		victory(1) = victory(1) / 2
		FOR k = 1 TO 25: armysize(k) = armysize(k) / 2: NEXT k
		CALL placearmy(1)
		CALL enter(-25)
		IF active = 1 GOTO digin
	END IF
	CALL TICK(9)
	IF armyloc(active) = 0 GOTO digin
'---------------------------------------------------------------------------
'                       check for more defenders !
'---------------------------------------------------------------------------
holdon:
	CALL occupy(target): IF occupied(target) = 0 GOTO easy
	CALL bossarmy
	COLOR 11: CALL clrbot: PRINT "There are still defenders in "; city$(target); : CALL TICK(99)
	GOTO enemy
'==========================================================================
'                       Move Into New City
'==========================================================================
easy:
armyloc(active) = target: armymove(active) = -2
CALL occupy(armyloc(active))
CALL placearmy(active)
'---------------------------------------------------------------------------
'                            City Capture
'---------------------------------------------------------------------------
	IF cityp(armyloc(active)) = s GOTO horde
	c = armyloc(active)
	IF player = 1 AND s = side AND fort(c) > 0 AND flag = 0 THEN
		tlx = 67: tly = 15
		hilite = 15: colour = 3
		mtx$(0) = "Raze ?"
		mtx$(1) = "No"
		mtx$(2) = "Yes"
		size = 2
		CALL menu(0)
		IF choose = 2 GOTO smoke
	END IF
	IF player = 1 AND s <> side AND fort(c) > 0 AND flag = 0 THEN
		IF cityy(c) > 150 THEN
smoke:
			fort(c) = 0
			x = cityx(c)
			y = cityy(c)
			LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
			CALL showcities
			CALL clrbot
			PRINT armyname$(active); " has destroyed the forts at "; city$(c);
			TICK 3
		END IF
	END IF
	CALL capture(active, c, s, flag)
horde:
IF supply(active) < 10 THEN supply(active) = supply(active) + 1: IF RND > .8 GOTO horde
digin:
NEXT j
GOTO allthru

upbox:
LINE (525, 90)-(630, 305), 2, BF
COLOR 14: LOCATE 12, 67: PRINT "ษออออออออออป"
LOCATE 13, 67: PRINT "บ  UPDATE  บ"
LOCATE 14, 67: PRINT "ศออออออออออผ"
RETURN

allthru:
CALL image2("Game will end in " + month$(vicflag(1)) + STR$(ABS(vicflag(2))), 5)
IF navysize(commerce) < 1 THEN commerce = 0
IF commerce > 0 THEN
	CALL clrbot
	IF RND < .8 + .02 * navysize(commerce) THEN
		raider = .05 * navysize(commerce) * (1 + RND) * (income(3 - commerce))
		IF raider < 1 THEN raider = 1
		IF raider / income(3 - commerce) > .4 THEN raider = (.3 + .1 * RND) * income(3 - commerce)
		COLOR 15: PRINT force$(commerce); " raiders have sunk $"; raider; " of "; force$(3 - commerce); " commerce";
		COLOR 14: LOCATE 26, 14: PRINT "$$"
		IF noise > 1 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
		IF commerce = side THEN grudge = 1
		TICK 9
		LINE (100, 400)-(120, 415), 3, BF
	ELSE
		raider = 0
		CALL barnacle(commerce)
		COLOR 15: PRINT force$(commerce); " raiders have lost a ship ("; navysize(commerce); " remain)";
		IF noise > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
		IF navyloc(commerce) > 0 THEN
			TICK 9
			GOTO allthru
		ELSE
			commerce = 0
			LINE (120, 400)-(160, 420), 3, BF
			FOR k = 1 TO 3: CIRCLE (140, 410), 3 * k, 11: NEXT k
			TICK 9
			LINE (120, 400)-(160, 420), 3, BF
			CALL ships
		END IF
	END IF
END IF

CALL ships: CALL iterate

CALL clrbot
CALL calendar
IF control(1) > 40 THEN victory(1) = victory(1) + 5: IF control(1) > 50 THEN victory(1) = victory(1) + 10
IF side = 2 AND control(1) < 11 THEN aggress! = aggress! + .7

IF victory(1) < 1 THEN victory(1) = 0
IF control(2) > 40 THEN victory(2) = victory(2) + 5: IF control(2) > 50 THEN victory(2) = victory(1) + 10
IF side = 1 AND control(2) < 11 THEN aggress! = aggress! + .7
FOR k = 1 TO 2: CALL stax(k): NEXT k
IF player = 2 THEN CALL clrbot: COLOR 14: PRINT "press a key"; : CALL TICK(9)
END SUB
