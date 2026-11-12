SUB disband
FOR i = 1 TO cities
	IF occupied(i) > 0 THEN
		x = occupied(i)
		IF armysize(x) > 0 AND u892(u558(x)) <= 50 THEN
			s = 1: IF u558(x) > 1 THEN s = 2
			cash(s) = cash(s) + .2 * armysize(x)
			armysize(x) = 0: armyloc(x) = 0
			lname$(x) = armyname$(x)
			CALL image2(u836$(u558(x)) + " " + armyname$(x) + " army has disbanded", 4)
			armyname$(x) = ""
		ELSE
			IF armyloc(x) > 0 THEN CALL placearmy(x)
		END IF
	END IF
NEXT i
END SUB
