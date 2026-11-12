SUB stencil (x, y, a$, f)
FOR i = 1 TO LEN(a$)
	c = ASC(MID$(UCASE$(a$), i, 1)) - 64
	z = POINT(x + 5 * (i - 1), y): PSET (x + 5 * (i - 1), y), z
	DRAW "S4C" + LTRIM$(RTRIM$(STR$(f)))
	IF c > 0 AND c < 27 THEN DRAW font$(c)
	IF c < 0 AND c <> -32 THEN c = c + 43: DRAW font$(c)
NEXT i
END SUB
