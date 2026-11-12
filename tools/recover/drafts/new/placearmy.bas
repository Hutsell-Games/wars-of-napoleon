SUB placearmy (which)
x = cityx(armyloc(which)) - 19
y = cityy(armyloc(which)) - 18
SELECT CASE which
	CASE IS < 26
		IF which = 1 THEN PUT (x, y), nap, PSET ELSE PUT (x, y), fren, PSET
	CASE ELSE
		SELECT CASE u558(which)
			CASE 2
				PUT (x, y), nat2, PSET
			CASE 3
				PUT (x, y), nat3, PSET
			CASE 4
				PUT (x, y), nat4, PSET
			CASE 5
				PUT (x, y), nat5, PSET
			CASE 6
				PUT (x, y), nat6, PSET
			CASE ELSE
				PUT (x, y), nat2, PSET
		END SELECT
END SELECT
IF supply(which) < 1 THEN
	x = x + 2: y = y + 8
	PSET (x, y), 13: DRAW "C11S8"
	DRAW font$(19)
	DRAW "S4"
END IF
END SUB
