SUB animate (index, flag)
CALL placearmy(index)
from = armyloc(index): to2 = armymove(index): armyloc(index) = 0
x = cityx(from) - 12
y = cityy(from) - 11
x1 = .5 * (cityx(to2) + cityx(from))
y1 = .5 * (cityy(to2) + cityy(from))

CALL occupy(from): IF occupied(from) > 0 AND flag = 0 THEN CALL placearmy(occupied(from))

	GET (x - 7, y - 7)-(x + 9, y + 6), anima
	c = POINT(x - 1, y - 9): IF c <> 1 THEN c = 2
	IF occupied(from) = 0 THEN LINE (x - 9, y - 8)-(x + 10, y + 8), c, BF: GET (x - 9, y - 7)-(x + 9, y + 6), graphic ELSE CALL placearmy(occupied(from))

	FOR i = 2 TO 8
	x1 = .1 * (i * cityx(to2) + (10 - i) * cityx(from))
	y1 = .1 * (i * cityy(to2) + (10 - i) * cityy(from))
	GET (x1 - 10, y1 - 10)-(x1 + 9, y1 + 9), image
	PUT (x1 - 10, y1 - 10), anima, PSET
	IF turbo! > 1 THEN CALL TICK(.05) ELSE CALL TICK(.02)
	IF noise > 0 THEN SOUND 200, .1: SOUND 50, .1
	PUT (x1 - 10, y1 - 10), image, PSET
	NEXT i
	armyloc(index) = from
	IF occupied(from) = 0 THEN PUT (x - 9, y - 7), graphic, PSET
END SUB
