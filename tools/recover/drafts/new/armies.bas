SUB armies
CALL movefrom(index, target): IF target > 0 AND index > 0 GOTO tent
	IF index = -1 THEN mflag = 1
	GOTO dudd
tent:
tlx = 67: tly = 12

COLOR 11: LOCATE 11, 68: PRINT city$(target)
size = 0
mtx$(0) = "To"
FOR i = 1 TO 6
	IF matrix(target, i) > 0 THEN
		x = matrix(target, i)
		IF matrix(target, 7) < 90 THEN
addto:
			size = size + 1: mtx$(size) = city$(matrix(target, i)): array(size) = matrix(target, i)
		ELSE
			IF matrix(x, 7) < 90 GOTO addto
			IF navyloc(side) = target AND navyloc(3 - side) <> x GOTO addto
			FOR k = 1 TO 4
				IF u2a0(k) = target OR u2a0(k) = x GOTO nextone
			NEXT k
			GOTO addto
		END IF
	END IF
nextone:
NEXT i
IF size < 1 THEN CALL clrbot: PRINT "No legal moves for "; armyname$(index); : CALL TICK(9): EXIT SUB
CALL bubble(size)

hilite = 10: colour = 3: CALL menu(2): CALL clrrite
IF choose < 0 GOTO dudd
IF (month > 10 OR month < 4) AND supply(index) = 0 AND cityp(array(choose)) <> side THEN COLOR 11: CALL clrbot: PRINT "OUT OF SUPPLY ... cannot move"; : CALL TICK(9): CALL clrbot: GOTO dudd

CALL clrbot: PRINT "Army "; index; " "; armyname$(index); " is moving from "; city$(target); " to "; city$(array(choose));
IF noise > 0 THEN SOUND 2200, .5: SOUND 2900, .7
CALL icon(target, array(choose), 1)
armymove(index) = array(choose): CALL TICK(turbo!): CALL clrbot
CALL clrrite
dudd:
END SUB
