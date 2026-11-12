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
