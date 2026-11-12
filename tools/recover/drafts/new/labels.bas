SUB labels
FOR i = 1 TO cities
	f = 0
	p = POINT(cityx(i) + 10, cityy(i) + 12): IF p = 1 THEN f = 10
	CALL stencil(cityx(i) - 12, cityy(i) + 10, city$(i), f)
NEXT i
END SUB
