"""tupdate: the raze menu, the realism test, and everything from upbox: to
the end, as WON.EXE has them."""
from pathlib import Path

p = Path("new/tupdate.bas")
s = p.read_bytes().decode("latin1")


def rep(old, new):
    global s
    assert s.count(old) == 1, old
    s = s.replace(old, new)


rep("\t\tCALL menu(0)\n\t\tCALL clrrite\n\t\tIF choose = 2 GOTO smoke", "\t\tCALL menu(0)\n\t\tIF choose = 2 GOTO smoke")
rep("\t\tIF realism > 0 AND cityy(c) > 150 THEN", "\t\tIF cityy(c) > 150 THEN")
rep("\t\t\tCALL showcity\n", "\t\t\tCALL showcities\n")

top = "\xc9" + "\xcd" * 10 + "\xbb"
mid = "\xba  UPDATE  \xba"
bot = "\xc8" + "\xcd" * 10 + "\xbc"
tail = f'''upbox:
LINE (525, 90)-(630, 305), 2, BF
COLOR 14: LOCATE 12, 67: PRINT "{top}"
LOCATE 13, 67: PRINT "{mid}"
LOCATE 14, 67: PRINT "{bot}"
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
'''
i = s.index("upbox:\n")
s = s[:i] + tail
p.write_bytes(s.encode("latin1"))
print("tupdate edited")
