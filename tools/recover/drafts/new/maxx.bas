SUB maxx
CALL tick(5)
GOSUB fame
FOR s = 1 TO 2: FOR i = 1 TO 5
IF victory(s) < matrix(s, i) GOTO oldskor
	FOR j = 5 TO i + 1 STEP -1
	matrix(s, j) = matrix(s, j - 1)
	city$(5 * (s - 1) + j) = city$(5 * (s - 1) + j - 1)
	NEXT j
COLOR 15, 1: IF s = 2 THEN COLOR 4, 7
IF player = 1 AND s <> side THEN a$ = "COMPUTER": GOTO automate
who4:
LOCATE 9, 26: COLOR 14, 4: PRINT "A NEW HIGH SCORE !"
PLAY "MFT220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
PLAY "T220P8o1g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
PLAY "T220P8o1a16a16o2d8e8d8o1a8f8a8o2d8o1a8f8a8o2d2"
PLAY "T220P8o1g16g16o2c8d8c8o1g8e8g8o2c8o1g8e8g8o2c2P1"
IF LEN(DIR$("vic.exe")) > 0 THEN SHELL "vic.exe"
GOSUB fame
COLOR 14, 5: COLOR 15, 5
LOCATE 12, 1: PRINT force$(s); " ARMY HAS A NEW HIGH SCORE of "; victory(s)
PRINT "New Entry into "; force$(s); " HALL of FAME in place "; i
PRINT "What is name of "; force$(s); " commander"; : INPUT a$: IF a$ = "" GOTO who4
automate:
city$(5 * (s - 1) + i) = a$
matrix(s, i) = victory(s): GOTO foun
oldskor:
NEXT i
foun:
NEXT s
OPEN "O", 1, "hiscore.nws"
FOR s = 1 TO 2: FOR i = 1 TO 5
	WRITE #1, city$(5 * (s - 1) + i), matrix(s, i)
NEXT i: NEXT s: CLOSE #1
GOSUB fame
CALL tick(2)
LOCATE 20, 1: PRINT "Game Over"
CALL tick(9)
pcode = 1
EXIT SUB

fame:
SCREEN 0: COLOR 14, 5: CLS : COLOR 11, 0
LOCATE 2, 7: PRINT STRING$(57, "²")
LOCATE 9, 7: PRINT STRING$(57, "²")
FOR k = 1 TO 6: LOCATE 2 + k, 7: PRINT "²"; SPACE$(55); "²": NEXT k
OPEN "I", 1, "hiscore.nws"
FOR j = 1 TO 2
	COLOR 14, 4: LOCATE 3, 30 * (j - 1) + 10: PRINT force$(j); " HALL of FAME"
	COLOR 15, 0: FOR k = 1 TO 5
	INPUT #1, city$(5 * (j - 1) + k), matrix(j, k)
	LOCATE 3 + k, 30 * (j - 1) + 8: PRINT k, city$(5 * (j - 1) + k), matrix(j, k)
NEXT k: NEXT j: CLOSE #1
RETURN
END SUB
