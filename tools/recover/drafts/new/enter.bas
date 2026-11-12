SUB enter (who)
FOR k = 3 TO 6
	o = u892(k)
	u892(k) = u892(k) + who
	IF u892(k) > 99 THEN u892(k) = 99
	IF u892(k) < 0 THEN u892(k) = 0
	IF o <= 50 AND u892(k) > 50 THEN
		CALL image2(u836$(k) + " has entered the WAR!", 4)
		FOR i = 1 TO cities
			IF cityo(i) = k AND occupied(i) = 0 AND cityp(i) = 0 THEN
				cityp(i) = k
				CALL cityicon(i)
			END IF
		NEXT i
	END IF
NEXT k
END SUB
