SUB cityicon (i)
c = 9: IF cityp(i) > 1 THEN c = 4
IF cityp(i) = 0 THEN c = 7
o = cityo(i)
IF u892(o) <= 50 AND occupied(i) = 0 THEN
	IF cityo(i) > 1 AND cityo(i) < 7 THEN c = 2 ELSE c = 7
	cityp(i) = 0
END IF
x = cityx(i): y = cityy(i)
IF fort(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
IF fort(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
CIRCLE (cityx(i), cityy(i)), 4, 0
CIRCLE (cityx(i), cityy(i)), 3, c
PAINT (cityx(i), cityy(i)), c, c
IF i = capcity(1) OR i = capcity(2) THEN COLOR 14: LINE (x - 4, y)-(x + 4, y): LINE (x, y - 4)-(x, y + 4)
FOR j = 1 TO 6: IF matrix(i, j) > 0 THEN CALL icon(i, matrix(i, j), 11)
NEXT j
END SUB
