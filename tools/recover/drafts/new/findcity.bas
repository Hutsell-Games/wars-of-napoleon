SUB findcity (c, x, y)
c = 0
FOR i = 1 TO cities
	IF ABS(cityx(i) - x) + ABS(cityy(i) - y) < 13 THEN c = i: EXIT FOR
NEXT i
END SUB
