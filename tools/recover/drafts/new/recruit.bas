SUB recruit (who)
	IF cash(who) < 100 THEN EXIT SUB
	size = 0: COLOR 12
	mtx$(0) = "Recruit"
	IF who = side AND rflag > 0 THEN FOR i = 1 TO rflag: x = rcity(i): mtx$(i) = city$(x): array(i) = x: NEXT i: size = rflag: GOTO alldone
	max = 11: IF RND > .8 THEN max = max - 1
	IF difficult < 3 THEN max = max + 1

	FOR i = 1 TO cities
	IF control(who) > 0 THEN pct! = max / control(who) ELSE pct! = .5
	IF size = 0 AND i > 30 THEN pct! = .5
	IF size < 2 AND i > 50 THEN pct! = .5
	array(i) = 0
	IF occupied(i) > 0 AND cityp(i) = who THEN pct! = .6: IF armysize(occupied(i)) > 4000 THEN pct! = 0
	IF u892(cityo(i)) <= 50 THEN pct! = 0
	IF who = 1 THEN
		IF RND < pct! AND cityp(i) = who AND (cityo(i) = who OR cityo(i) > 6) THEN GOSUB addcity: IF size > max - 1 GOTO alldone
	ELSE
		IF RND < pct! AND cityp(i) = who AND cityo(i) > 1 THEN GOSUB addcity: IF size > max - 1 GOTO alldone
	END IF
	NEXT i
	GOTO alldone
addcity:
	size = size + 1
	mtx$(size) = city$(i)
	array(size) = i
	RETURN
alldone:
	IF size = 0 GOTO menu1
	IF who = side AND rflag = 0 THEN FOR i = 1 TO size: rcity(i) = array(i): NEXT i: rflag = size
	CALL bubble(size)
'............................................................................
levy:
	IF cash(who) < 100 GOTO menu1
	IF (who = side) OR (player = 2) THEN CALL clrbot: PRINT force$(who); " funds available "; cash(who);
	tlx = 67: tly = 8: colour = 3
	IF who <> side THEN GOSUB randsel: GOTO auto1

	IF choose > 0 THEN choose = 21 + choose
	hilite = 14: CALL menu(2): CALL clrrite
	IF choose < 1 GOTO menu1
auto1:
	empty = 0
	index = array(choose)
	CALL occupy(index)
	IF occupied(index) > 0 THEN i = occupied(index): GOTO add2
	CALL commander((who), empty)

	IF who <> side AND empty = 0 GOTO menu1
	IF empty = 0 GOTO levy
	armyloc(empty) = index
	GOSUB playb
	CALL newarmy(who, empty, index, 0)
	GOTO levy
'............................................................................
add2:
	target = array(choose)
	a$ = ""
	x = 2 * cityv(armyloc(i))
	CALL cutoff(who, target, a)
	IF a < 1 THEN x = x \ 3: a$ = " ISOLATED !"
	armysize(i) = armysize(i) + 4 * cityv(target)
	IF armyloc(1) = target THEN armysize(i) = armysize(i) + 4 * cityv(target)

	GOSUB playb
	cash(who) = cash(who) - 100
	from = armyloc(i): x = cityx(from) - 12: y = cityy(from) - 11
	CALL icon(armyloc(i), 0, 2)
	IF noise > 0 THEN SOUND 2222, 1
	COLOR 11: CALL clrbot: PRINT "Army "; i; armyname$(i); " in "; city$(armyloc(i)); " strength increased to "; : CALL strong(i)
	IF a$ <> "" THEN PRINT a$;
	CALL placearmy(i)
	CALL TICK(turbo! - .5)
	GOTO levy
randsel:
		choose = 0: x = 0
		FOR i = 1 TO size
		target = array(i)
		LOCATE 14 + i, 69
		x = occupied(target)
		IF x = 0 XOR armysize(x) < 155 THEN choose = i
		IF x = 1 THEN choose = i: RETURN
		NEXT i

	IF choose = 0 THEN choose = 1 + INT(RND * size)
		x = 0
		FOR i = 1 TO size
		target = array(i)
		IF occupied(target) = 0 THEN
			y = 3 * cityv(target) + 33
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		ELSE
			y = 2 * cityv(target) + 20
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		END IF
		IF y > x AND RND > .5 THEN x = y: choose = i
		NEXT i
	IF cash(who) < 100 THEN choose = size
	RETURN
playb:
	IF side = 1 AND difficult < 3 THEN armysize(empty) = armysize(empty) - 5 * difficult + 15
	IF side = 2 AND difficult > 3 THEN armysize(empty) = armysize(empty) + 5 * difficult - 15
	RETURN
menu1:
END SUB
