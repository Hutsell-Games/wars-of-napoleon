SUB ships
FOR s = 1 TO 2
IF navysize(s) = 0 OR navyloc(s) = 0 THEN navyloc(s) = 0: GOTO sink
IF navyloc(s) = 99 THEN x = 150: y = 420: GOTO float
SELECT CASE matrix(navyloc(s), 7)
	CASE 96: x = cityx(navyloc(s)) + 50: y = cityy(navyloc(s)) + 10
	CASE 97: x = cityx(navyloc(s)) - 15: y = cityy(navyloc(s)) + 10
	CASE 98: x = cityx(navyloc(s)) + 25: y = cityy(navyloc(s)) - 10
	CASE 99: x = cityx(navyloc(s)) + 5: y = cityy(navyloc(s)) + 30
END SELECT
IF navyloc(s) = 24 THEN y = y + 5: x = x - 5
float:
	PSET (x, y), 1
	CALL shipicon(s)
sink:
NEXT s
END SUB
