SUB init
mtx$(0) = "Start Year"
f$ = DIR$("nws*.ini")
colour = 3
GOSUB getlist
CALL clrbot
LOCATE 29, 1: PRINT "Loading "; u29c$
EXIT SUB

getlist:
	size = 0
	IF LEN(f$) = 0 THEN choose = -1: EXIT SUB
	size = size + 1
	mtx$(size) = LTRIM$(MID$(f$, 4, 4))
	array(size) = size
	DO WHILE f$ <> "" AND size < 21
		f$ = DIR$
		f$ = LTRIM$(MID$(f$, 4, 4))
		IF f$ = "" THEN EXIT DO
		size = size + 1
		mtx$(size) = f$
		array(size) = size
	LOOP
	CALL bubble((size))
	tlx = 18: tly = 14 - .5 * size
	CALL menu(11)
	IF choose < 0 THEN choose = -1: EXIT SUB
	u29c$ = mtx$(choose)
	IF LEN(u29c$) < 1 THEN choose = -1: EXIT SUB
	RETURN
END SUB
