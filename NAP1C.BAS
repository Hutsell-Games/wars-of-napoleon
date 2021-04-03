DEFINT A-Z
DECLARE SUB Mickey (a$, lButton%, rButton%, xc%, yc%)
REM $INCLUDE: 'nap10.bi'
'============================================================================
'                       CIVAR MENU 2.2 for EGA
'============================================================================
'       sdtext$() = screen display text before menu appears (1-25)
'       tlx  = top left x  (if zero, automatically centered)
'       tly = top left y   (if zero, automatically centered)
'       size = # rows (current maximum=21)
'       mtx$() = text for menu
'                mtx$(0) = heading (blank defaults to M E N U)
'                mtx$(1-size) are options in menu
'       choose = option selected (row #)
'            -1 indicates ESC key pressed
'            entering with choose+20 causes choose to be default entry
'       colour = color attribute
'       hilite = highlight color

SUB menu
	DEFINT A-Z
	PCOPY 0, 1
	SCREEN 9, , 1, 1
	IF colour = 0 THEN colour = 7
	LOCATE 1, 1, 0
	IF mtx$(0) = "" THEN mtx$(0) = "M E N U"

	IF wide = 0 THEN GOSUB mxw
	IF tlx = 0 THEN GOSUB noadjust
	IF choose < 21 THEN choose = 1
	IF choose > 21 THEN choose = choose - 21: IF choose > 21 THEN choose = 1
	row = choose: IF row = 0 THEN row = 1
	IF row > size THEN row = 1
	choose = row
	row1 = row
     
	IF tly = 0 THEN tly = INT(11.5 - .5 * size)
	IF tly + size > 21 THEN tly = 21 - size
     
	brx = tlx + wide + 1
	bry = tly + size + 3
     
	COLOR colour
	LINE (8 * tlx, 14 * (tly) - 4)-(8 * (tlx + wide + 2), 14 * (tly + size + 2) + 4), 0, BF
	LINE (8 * tlx, 14 * (tly) - 4)-(8 * (tlx + wide + 2), 14 * (tly + size + 2) + 4), colour, B
	LINE (8 * tlx, 14 * tly + 19)-(8 * (tlx + wide + 2), 14 * tly + 22), colour, B
	LINE (8 * (tlx + wide + 2) + 1, 14 * tly + 8)-(8 * (tlx + wide + 3) + 1, 14 * (tly + size + 3) + 1), 0, BF
	LINE (8 * (tlx + 1) + 4, 14 * (tly + size + 2) + 5)-(8 * (tlx + wide + 2) + 1, 14 * (tly + size + 3) + 1), 0, BF
	COLOR colour
	b1 = INT(.5 * (wide - LEN(mtx$(0))) + .5) + 1
     
	LOCATE tly + 1, tlx + b1: PRINT mtx$(0)

	FOR i = 1 TO size
	LOCATE tly + 2 + i, tlx + 2: PRINT mtx$(i)
	NEXT i

sel1:
	COLOR hilite
	LOCATE tly + 2 + row, tlx + 2: PRINT mtx$(row)
	GOSUB crsr
	IF ASC(a$) = 13 GOTO called
	COLOR colour
	LOCATE tly + 2 + row1, tlx + 2: PRINT mtx$(row1)
	choose = row
	GOTO sel1

crsr:
	DO: a$ = INKEY$: LOOP WHILE a$ = ""
akey5:
	IF ASC(a$) = 32 THEN choose = 99: GOTO called
	IF ASC(a$) = 13 THEN RETURN
	IF LEN(a$) = 2 GOTO arrows
	IF ASC(a$) = 27 THEN choose = -1: GOTO called
		row1 = row
		FOR k = 1 TO size
		c1$ = UCASE$(a$)
		c2$ = UCASE$(LEFT$(mtx$(k), 1))
		IF c1$ = c2$ THEN row = k: choose = row: GOSUB limits: GOTO called
		NEXT k
	GOTO crsr
arrows:
	a$ = RIGHT$(a$, 1)
	row1 = row
	 IF a$ = "G" THEN row = 1: GOSUB limits: RETURN
	 IF a$ = "H" THEN row = row - 1: GOSUB limits: RETURN
	 IF a$ = "I" THEN row = 1:  GOSUB limits: RETURN
	 IF a$ = "O" THEN row = size: GOSUB limits: RETURN
	 IF a$ = "P" THEN row = row + 1: GOSUB limits: RETURN
	 IF a$ = "Q" THEN row = size: GOSUB limits: RETURN
	 IF a$ = "ƒ" THEN LOCATE 1, 1: PRINT FRE(-1)
	 RETURN
limits:
	IF row > size THEN row = 1
	IF row < 1 THEN row = size
	RETURN
mxw:
	wide = LEN(mtx$(0)) + 3
     
	ndx = 0
	FOR i = 1 TO size
	l = LEN(mtx$(i))
	IF l > wide THEN wide = l: ndx = i
	NEXT i
	   
	RETURN
noadjust:
	IF tlx = 0 THEN tlx = INT(39 - .5 * wide)
	RETURN

called:
	IF quiet > 0 THEN SOUND 700, .5
	COLOR colour
	SCREEN 9, , 0, 0
END SUB

