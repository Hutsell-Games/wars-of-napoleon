SUB combine (who)
	colour = 3: target = 0: hilite = 3
	tlx = 67: tly = 6
	CALL starfin(star, fin, who)
	size = 0
	FOR i = 1 TO cities
		IF cityp(i) = who AND occupied(i) > 0 THEN
			FOR j = star TO fin
			IF armyloc(j) = i AND occupied(i) <> j AND armymove(j) = 0 THEN size = size + 1: mtx$(size) = city$(i): array(size) = i: EXIT FOR
			NEXT j
		END IF
	NEXT i
	
	IF size = 0 THEN who = -1: EXIT SUB

	IF who <> side THEN choose = 1 + INT(size * RND): GOTO join
	mtx$(0) = "Join"
		choose = 31: hilite = 11
		CALL menu(0)
join:
		IF choose < 1 GOTO nocity2
		target = array(choose)
		CALL clrbot: PRINT "Combining "; force$(who); " armies in "; city$(target); :  CALL TICK(turbo!)

		armysize(0) = 0: armylead(0) = 0: armyexper(0) = 0: armyloc(0) = target
		armyname$(0) = "": supply(0) = 0: armymove(0) = 0
'...........................................................................
		best = 0: x = 0: spin = 0
		FOR j = star TO fin
		IF armymove(j) <> 0 OR armyloc(j) <> target OR armysize(j) = 0 GOTO dork1
		IF armysize(0) + armysize(j) > 4000 THEN CALL clrbot: PRINT "Cannot combine "; armyname$(j); "... TOO LARGE"; : CALL TICK(turbo!): GOTO dork1

		IF armylead(j) > x THEN
			x = armylead(j)
			armyname$(0) = armyname$(j)
			armylead(0) = armylead(j)
			best = j
		END IF

		armysize(0) = armysize(0) + armysize(j)
		IF armysize(0) < 1 GOTO dork1
		pct! = (armysize(j) / armysize(0))
		spin = spin + 1
		armyexper(0) = (1 - pct!) * armyexper(0) + pct! * armyexper(j)
		CALL clrbot: PRINT armyname$(j); " is combining his "; : CALL strong(j): PRINT " forces"; : CALL TICK(turbo!)
		supply(0) = supply(0) + supply(j)
		IF supply(0) > 10 THEN supply(0) = 10
		armysize(j) = 0: armyloc(j) = 0: armyexper(j) = 0: armymove(j) = 0
		lname$(j) = armyname$(j)
		armylead(j) = 0: supply(j) = 0: armyname$(j) = ""
dork1:
		NEXT j

		CALL clrbot
		IF who <> side AND spin = 0 THEN EXIT SUB
		IF spin = 0 THEN
				PRINT "No valid armies to combine at this time in "; city$(target);
				TICK turbo!
				EXIT SUB
		END IF
		armysize(best) = armysize(0): armylead(best) = armylead(0)
		armyexper(best) = armyexper(0): supply(best) = supply(0)
		armyloc(best) = target
		armyname$(best) = armyname$(0)
		lname$(best) = ""
		IF spin > 1 THEN
		PRINT "New army "; best; " of "; : CALL strong(best): PRINT " is commanded by "; armyname$(best);
		armymove(best) = -1
		ELSE
		PRINT "Only 1 eligible army -- cannot combine at this time";
		END IF
		IF who = side THEN CALL TICK(turbo!)
		IF noise > 0 THEN SOUND 4000, .7
	       
		CALL showcities
		CALL placearmy(best)
		CALL icon(target, 0, 6)
		occupied(target) = best
		CALL stax(who)
nocity2:
END SUB
