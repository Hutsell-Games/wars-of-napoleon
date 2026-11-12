SUB bossarmy
FOR i = 1 TO cities
	IF occupied(i) > 0 THEN
		s = 1: IF occupied(i) > 25 THEN s = 2
		CALL starfin(a, b, s)
		FOR k = a TO b
			IF armysize(k) > 0 THEN
				IF armyloc(k) = i THEN
					IF armysize(k) > armysize(occupied(i)) THEN occupied(i) = k
				END IF
			END IF
		NEXT k
	END IF
NEXT i
END SUB
