DEFINT A-Z
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB normal (xbar%, vary%, result%)
DECLARE SUB relieve (who%)
DECLARE SUB retreat (active%, x%)
DECLARE SUB stax (who%)
' $INCLUDE: 'won.bi'

IF LEN(DIR$("arch2.exe")) > 0 AND COMMAND$ = "" THEN CLS : SHELL "arch2.exe": GOTO regist
SCREEN 12
GOSUB tricolor
LINE (0, 0)-(213, 480), 1, BF
LINE (214, 0)-(427, 480), 15, BF
LINE (428, 0)-(639, 480), 4, BF
COLOR 14: LOCATE 14, 33: PRINT "Wars of Napoleon"
CIRCLE (320, 224), 300, 14, , , .1
PAINT (100, 224), 0, 14
LOCATE 15, 35: PRINT "STRATEGY GAME"
CIRCLE (150, 440), 130, 14, , , .1
COLOR 14: LOCATE 28, 9: PRINT "(c) 1997 W. R. Hutsell"
PAINT (30, 440), 0, 14
LOCATE 28, 60: PRINT "v1.16"
TICK 2
CLS
regist:
IF LEN(DIR$("rrs.exe")) = 0 THEN
	SCREEN 12
	LINE (70, 210)-(563, 286), 4, BF
	LINE (71, 212)-(561, 284), 15, B
	COLOR 15: LOCATE 15, 34: PRINT "Please Note"
	LOCATE 16, 19: PRINT "This is your registered copy of the game."
	LOCATE 17, 11: PRINT "It is NOT Shareware and should not be further distributed."
	TICK 2
END IF
newgame:
rflag = 0: nflag = 0: mflag = 0: commerce = 0: pcode = 0
FOR k = 1 TO 50: armysize(k) = 0: armyloc(k) = 0: armymove(k) = 0: armylead(k) = 0: armyname$(k) = "": NEXT k
FOR k = 1 TO 2
navysize(k) = 0: navyloc(k) = 0: navymove(k) = 0: victory(k) = 0
NEXT k

filel = 1: vicflag(1) = 1
IF LEN(DIR$("mtn.vga")) > 0 THEN
	DEF SEG = VARSEG(mtn(1))
	BLOAD "mtn.vga", VARPTR(mtn(1))
	DEF SEG
ELSE
	COLOR 15: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'"
END IF
SCREEN 12
	DEF SEG = VARSEG(graphic(1))
	BLOAD "napicon.vga", VARPTR(graphic(1))
	DEF SEG

	PUT (100, 100), graphic, PSET
	GET (101, 101)-(117, 114), nat2
	GET (101, 115)-(117, 128), nat5
	GET (101, 129)-(117, 142), nat3
	GET (101, 143)-(117, 156), fren
	GET (123, 101)-(139, 114), nat5
	GET (123, 115)-(139, 128), nat4
	GET (123, 129)-(139, 142), nap
	GET (123, 143)-(139, 156), nat6
RESTORE
iron:
IF player < 1 OR player > 2 THEN player = 1
IF player = 2 OR side = 0 THEN side = 1
IF side = 1 THEN randbal = 7
IF side = 2 THEN randbal = 3
	IF turbo! < 1 THEN turbo! = 2
	IF side = 1 AND difficult < 3 THEN cash(2) = cash(2) + 600 - 100 * difficult
	IF side = 2 AND difficult > 3 THEN cash(1) = cash(1) + 100 * difficult
CLS
CALL filer(-1)
CALL clrbot
RANDOMIZE TIMER
CALL TICK(.3)
wtype = 2: hilite = 15
GOSUB tricolor
FOR k = 1 TO 10: attitude(k) = 0: NEXT k
startmenu:
mtx$(0) = "WARS OF NAPOLEON"
mtx$(1) = "Resume Saved Game"
mtx$(2) = "Start NEW Game"
mtx$(3) = "Quit to DOS"
tlx = 32: tly = 15: colour = 5: size = 3: choose = 23
CALL menu(0)
IF player = 2 THEN GOSUB blanken
IF choose = 1 THEN CLS : replay = 1: GOTO loader
IF choose = 3 THEN
	IF LEN(DIR$("rrs.exe")) > 0 THEN SHELL "rrs.exe"
	CLS : END
END IF
GOSUB history
SCREEN 12
city$(0) = "NONE"
usadv = 75 * difficult: IF player = 2 THEN usadv = 10 * difficult
vptotal = usadv + 200
CALL init
IF LEN(scenario$) = 0 GOTO startmenu
CALL filer(1)
FOR i = 1 TO 2: income(i) = cash(i): NEXT i
FOR i = 1 TO cities
	IF cityp(i) > 0 THEN
		x = cityp(i): IF x > 1 THEN x = 2
		IF x = 1 OR attitude(cityo(i)) > 50 THEN control(x) = control(x) + 1
		cash(cityp(i)) = cash(cityp(i)) + cityv(i)
	END IF
NEXT i
CALL europe
goon: CALL calendar
obj$ = "The " + force$(side) + " objective is " + city$(capcity(3 - side))
CALL image2(obj$, 4)
GOTO menu0
newmonth:
IF side > 2 THEN side = 1
a$ = "--------> EVENTS FOR " + month$(month) + " " + STR$(year) + " --------"
CALL scribe(a$, 0)
CALL clrbot
CALL filer(9)
CALL tupdate
control(1) = 0: control(2) = 0
LINE (525, 90)-(630, 305), 2, BF

FOR i = 1 TO 2
income(i) = 0
IF cash(i) > 19999 THEN cash(i) = 19999
IF cash(i) < 0 THEN cash(i) = 0
NEXT i
IF player = 1 AND side = 1 THEN income(2) = income(2) + usadv

FOR i = 1 TO cities
	IF cityp(i) > 0 THEN
		x = cityp(i): IF x > 1 THEN x = 2
		control(x) = control(x) + 1
		income(x) = income(x) + cityv(i)
	END IF
NEXT i
FOR i = 1 TO 50: armymove(i) = 0: NEXT i

FOR i = 1 TO 2: navymove(i) = 0: IF capcity(i) > 0 THEN income(i) = income(i) + 100
cash(i) = cash(i) + income(i)
IF commerce > 0 AND i <> commerce THEN cash(i) = cash(i) - raider
NEXT i

chosit = 22
IF player = 2 THEN GOSUB blanken: CALL europe: CALL calendar
CALL victor
ON ERROR GOTO 0
IF pcode > 0 THEN
	FOR k = 1 TO 50: armyloc(k) = 0: NEXT k
	GOTO newgame
END IF

'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
'                              Main Menu
'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
menu0:
IF player = 2 AND side = 0 THEN side = 1
IF cash(side) < 100 AND navyloc(side) = 0 THEN nflag = 1

hilite = 11
colour = 4
tlx = 67: tly = 13
LINE (8 * tlx, 16 * (tly - 3) - 2)-(8 * tlx + 80, 16 * (tly - 1)), 0, BF
LINE (8 * tlx, 16 * (tly - 3) - 2)-(8 * tlx + 80, 16 * (tly - 1)), 10, B
c = 9: IF side = 2 THEN c = 4
COLOR 14: LOCATE tly - 1, tlx + 2: PRINT "VP:"; LTRIM$(STR$(victory(side)))
COLOR c: LOCATE tly - 2, tlx + 2: PRINT force$(side)
mtx$(0) = "Main"
mtx$(1) = "Recruit": IF rflag < 0 OR cash(side) < 100 THEN mtx$(1) = "-": chosit = 23
mtx$(2) = "Moves": IF mflag > 0 THEN mtx$(2) = "-": IF chosit = 23 THEN chosit = 24
mtx$(3) = "Ships": IF nflag > 0 THEN mtx$(3) = "-": IF chosit = 24 THEN chosit = 25
mtx$(4) = "END TURN"
mtx$(5) = "Inform"
mtx$(6) = "COMMANDS"
mtx$(7) = "UTILITY"
mtx$(8) = "Files"

size = 8
choose = chosit
CALL menu(0): CALL clrrite
'==========================================================================
'                            Main Menu
'==========================================================================
SELECT CASE choose
	CASE 1
	IF cash(side) < 100 OR rflag < 0 THEN rflag = -1: GOTO menu0
	CALL recruit((side))
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 2
	CALL armies
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 3
	IF nflag = 0 THEN CALL navy((side), 0)
	chosit = 25
'==========================================================================
	CASE 4
	tlx = 67: tly = 15
	hilite = 15: colour = 3: choose = 23
	mtx$(0) = "End Turn"
	mtx$(1) = "Yes"
	mtx$(2) = "NOT YET"
	size = 2: CALL menu(0): CALL clrrite: IF choose <> 1 THEN chosit = 24: GOTO menu0
endrnd:
	rflag = 0: mflag = 0: nflag = 0
	IF player = 2 THEN side = side + 1: IF side = 2 THEN GOSUB blanken: CALL europe: CALL calendar: GOTO menu0
	GOTO newmonth
'==========================================================================
	CASE 5
	CALL report((side), 0): chosit = 26
	CALL starfin(star, fin, side)
	FOR i = star TO fin
	IF armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
	NEXT i
'==========================================================================
'                            Commands
'==========================================================================
	CASE 6
optmen:
	tlx = 67: tly = 13
	COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
	hilite = 15: colour = 3
	mtx$(0) = "Commands"
	mtx$(1) = "Cancel"
	mtx$(2) = "Fortify": IF cash(side) < 200 THEN mtx$(2) = "-"
	mtx$(3) = "Join"
	mtx$(4) = "Supply"
	mtx$(5) = "Detach"
	mtx$(6) = "Army Drill"
	mtx$(7) = "Relieve"
	mtx$(8) = "MAIN MENU"
	size = 8
	CALL menu(0): CALL clrrite
	chosit = 27
     SELECT CASE choose
'---------------------------------------------------------------------------
'                               Cancel
'---------------------------------------------------------------------------
		CASE 1
	CALL cancel(side): mflag = 0
	choose = 22
'---------------------------------------------------------------------------
'                               Fortify
'---------------------------------------------------------------------------
		CASE 2
	IF cash(side) < 200 THEN COLOR 11: CALL clrbot: PRINT "Not enough money for fort"; : GOTO menu0
	CALL fortify(target)
	IF cash(side) < 200 GOTO menu0
	choose = 23
	GOTO optmen
'---------------------------------------------------------------------------
'                               Combine
'---------------------------------------------------------------------------
		CASE 3
	x = side
	CALL combine(x)
	IF x < 0 THEN
		CALL clrbot
		COLOR 11
		PRINT "No eligible armies in same city to combine";
		CALL stax(side)
		GOTO menu0
	END IF
	choose = 24
	GOTO optmen
'---------------------------------------------------------------------------
'                               Supply
'---------------------------------------------------------------------------
		CASE 4
		CALL starfin(star, fin, (side))
		mtx$(0) = "Supply"
		tlx = 67: tly = 5: colour = 5
		size = 0
		FOR i = star TO fin
		IF armyloc(i) = 0 OR supply(i) > 0 GOTO alone
		CALL cutoff(side, armyloc(i), a)
			IF a < 1 THEN CALL clrbot: COLOR 15: PRINT force$(side); " army in "; city$(armyloc(i)); " is CUT OFF !"; : TICK turbo!: GOTO alone
		size = size + 1
		max = 11: IF LEN(armyname$(i)) < 11 THEN max = LEN(armyname$(i))
		mtx$(size) = LEFT$(armyname$(i), max)
		array(size) = i
alone:
		NEXT i
		IF size = 0 THEN COLOR 11: CALL clrbot: PRINT "All eligible "; force$(side); " armies have supplies"; : GOTO menu0
		CALL menu(6): CALL clrrite
		IF choose < 0 GOTO menu0
		index = array(choose)
		IF supply(index) < 2 THEN
		CALL resupply(index)
		CALL placearmy(index)
		END IF
		choose = 25
		GOTO optmen
'-------------------------------------------------------------------------
'                               Detach
'-------------------------------------------------------------------------
		CASE 5
	COLOR 14: CALL clrbot: PRINT "DETACH UNIT";
	CALL movefrom(index, target): IF target < 1 OR index < 1 GOTO menu0
	IF armysize(index) < 65 THEN CALL clrbot: PRINT "Too small to detach"; : CALL TICK(turbo!): GOTO menu0
	CALL commander(side, empty): IF empty = 0 GOTO menu0
	supply(empty) = .3 * supply(index): supply(index) = supply(index) - supply(empty): IF supply(index) < 0 THEN supply(index) = 0
	armysize(empty) = .3 * armysize(index): armysize(index) = armysize(index) - armysize(empty)
	armyloc(empty) = target: armyexper(empty) = armyexper(index): armymove(empty) = 0
	armylead(empty) = rating(empty)
	armyname$(empty) = lname$(empty): lname$(empty) = ""
	armyexper(empty) = armyexper(index)
	armynat(empty) = armynat(index)
	COLOR 11: CALL clrbot: PRINT force$(side); " Unit #"; empty; " with "; : CALL strong(empty): PRINT " men detached under "; armyname$(empty); : CALL TICK(turbo!): IF noise > 0 THEN SOUND 2222, 1
	CALL stax(side)
	choose = 27
	GOTO optmen
'-------------------------------------------------------------------------
'                               Drill
'-------------------------------------------------------------------------
		CASE 6
	COLOR 14: CALL clrbot: PRINT "DRILL ARMY"
	CALL movefrom(index, target)
	IF target < 1 OR index < 1 THEN COLOR 11: CALL clrbot: PRINT "No armies remain eligible for drills in "; month$(month); : GOTO menu0
	IF armyexper(index) > 5 OR armyexper(index) >= armylead(index) THEN COLOR 12: CALL clrbot: PRINT armyname$(index); ": Army has reached maximum improvement through drilling"; : GOTO optmen
	armyexper(index) = armyexper(index) + 1
	CALL clrbot: PRINT armyname$(index); " has drilled to reach experience level "; armyexper(index); : IF noise > 0 THEN SOUND 2222, 1
	CALL TICK(turbo!): clrbot
	armymove(index) = -1
	choose = 28
	GOTO optmen
'-------------------------------------------------------------------------
'                               Relieve
'-------------------------------------------------------------------------
		CASE 7
		CALL relieve(side)
		choose = 29
		GOTO optmen
'-------------------------------------------------------------------------
		CASE ELSE
		chosit = 27
		GOTO menu0
      END SELECT
	choose = 21 + chosit: GOTO optmen
'==========================================================================
'                               Utility Menu
'==========================================================================
	CASE 7
utile:
	chosit = 28
	mtx$(0) = "Utility"
	mtx$(1) = force$(side)
	mtx$(2) = "1 Player": IF player = 2 THEN mtx$(2) = "2 Player"
	mtx$(3) = "Noise": IF noise > 0 THEN mtx$(3) = mtx$(3) + STRING$(noise, "*")
	mtx$(4) = "NO Tactical": IF tactical > 0 THEN mtx$(4) = "Tactical û"
	mtx$(5) = "Display" + STR$(turbo!)
	a$ = STR$(difficult): IF side = 1 THEN a$ = STR$(6 - difficult)
	mtx$(6) = "Balance" + a$
	mtx$(7) = "End Cond"
	a$ = "û": IF randbal = 0 THEN a$ = ""
	mtx$(8) = "Rndom Evt " + a$
	mtx$(9) = "Vary Start"
	a$ = "û": IF history = 0 THEN a$ = ""
	mtx$(10) = "History " + a$
	size = 10: tlx = 66: tly = 11
	COLOR 11: LOCATE tly - 2, 67: PRINT "esc=Main Menu"
	IF player = 1 THEN size = 11: mtx$(11) = "Aggress" + STR$(bold)
	size = size + 1: mtx$(size) = "Save CFG"
	CALL menu(-1): CALL clrrite
	    SELECT CASE choose
'-------------------------------------------------------------------------
'                               Swap Sides
'-------------------------------------------------------------------------
	    CASE 1
		IF player = 2 GOTO menu0
		side = 3 - side: COLOR 9: IF side = 2 THEN COLOR 7
		CALL clrbot: PRINT "Now playing "; force$(side); " side"; : IF noise > 0 THEN SOUND 999, 1
		IF side = 1 THEN randbal = 7
		IF side = 2 THEN randbal = 3
		choose = 22: GOTO utile
'-------------------------------------------------------------------------
'                               Solo or 2 Player
'-------------------------------------------------------------------------
	    CASE 2
		player = 3 - player: CALL clrbot: COLOR 12
		IF noise > 0 THEN SOUND 999, 1
		a$ = "Solo": IF player = 2 THEN a$ = "2 Player"
		PRINT a$; " Game";
		choose = 23: GOTO utile
	    CASE 3
		CALL clrrite: choose = noise + 22
		mtx$(0) = "SOUNDS"
		mtx$(1) = "Quiet"
		mtx$(2) = "Sound"
		mtx$(3) = " & Sound"
		size = 3: tlx = 67: tly = 12
		CALL menu(0): CALL clrrite
		IF choose < 1 GOTO menu0
		COLOR 11: CALL clrbot: PRINT "Sound Option : "; mtx$(choose);
		noise = choose - 1
		IF noise > 0 THEN SOUND 999, .5
		choose = 24: GOTO utile
'-------------------------------------------------------------------------
'                               Display Speed
'-------------------------------------------------------------------------
	    CASE 4
		tactical = 1 - tactical
		IF LEN(DIR$("rrs.exe")) > 0 THEN tactical = 0: m$ = "Linked tactical game in Registered Game Only": CALL image2(m$, 4)
		IF noise > 0 THEN SOUND 1999, .5
		choose = 25: GOTO utile
'-------------------------------------------------------------------------
'                               Display Speed
'-------------------------------------------------------------------------
	    CASE 5
		choose = turbo! + 21
		mtx$(0) = "Display"
		mtx$(1) = "Fast"
		mtx$(2) = "Normal"
		mtx$(3) = "Slow"
		mtx$(4) = "Very Slow"
		tlx = 67: tly = 15: size = 4
		CALL menu(0): CALL clrrite
		SELECT CASE choose
			CASE IS < 1
			CASE IS < 5
				turbo! = choose
				IF turbo! = 4 THEN turbo! = 8
				CALL clrbot: COLOR 11
				PRINT "Display Speed : "; mtx$(choose);
		END SELECT
		choose = 26: GOTO utile
'-------------------------------------------------------------------------
'                               Play Balance
'-------------------------------------------------------------------------
	   CASE 6
		choose = difficult + 21
		mtx$(0) = "Balance"
		mtx$(1) = "Allied ++"
		mtx$(2) = "Allied +"
		mtx$(3) = "Balanced"
		mtx$(4) = "French +"
		mtx$(5) = "French ++"
		tlx = 67: tly = 15: size = 5
		CALL menu(8): CALL clrrite
		IF choose < 1 GOTO menu0
		CALL clrbot
		COLOR 11: CALL clrbot: PRINT "Play Balance : "; mtx$(choose);
		difficult = choose
		usadv = 75 * difficult: IF player = 2 THEN usadv = 10 * difficult
		choose = 27: GOTO utile
'-------------------------------------------------------------------------
'                               Ending Conditions
'-------------------------------------------------------------------------
	   CASE 7
		CALL endit
		choose = 28: GOTO utile
'-------------------------------------------------------------------------
'                           Random Events Options
'-------------------------------------------------------------------------
	   CASE 8
		 mtx$(0) = "Random Events"
		 size = 4: tlx = 30: tly = 8
		 mtx$(1) = "OFF"
		 mtx$(2) = "Favor Allies": IF randbal = 3 THEN mtx$(2) = mtx$(2) + " "
		 mtx$(3) = "Neutral     ": IF randbal = 5 THEN mtx$(3) = mtx$(3) + " "
		 mtx$(4) = "Favor French": IF randbal = 7 THEN mtx$(4) = mtx$(4) + " "
		 colour = 5
		 CALL menu(0)
		 colour = 4

		 SELECT CASE choose
		 CASE 1
		 randbal = 0: t$ = ""
		 CASE 2
		 randbal = 3
		 CASE 3
		 randbal = 5
		 CASE 4
		 randbal = 7
		 CASE ELSE
		 END SELECT
		 IF choose > 1 AND choose < 5 THEN t$ = mtx$(choose)
		 CALL clrbot
		 a$ = "": IF randbal = 0 THEN a$ = "OFF"
		 COLOR 11: PRINT "Random Events : "; a$; " "; t$;
		 COLOR 14: PRINT "			press a key";
		 DO WHILE INKEY$ = "": LOOP
		 CLS
		 CALL europe
		 choose = 29
		 GOTO utile
'-------------------------------------------------------------------------
'                              Vary Start Conditions
'-------------------------------------------------------------------------
	   CASE 9
		CALL filer(1)
		cash(1) = cash(1) - 100 + 200 * RND
		cash(2) = cash(2) + 100 + 200 * RND
		bold = 5 * RND
		FOR k = 1 TO 6
			IF RND > .6 THEN
			armyloc(k) = 0: armysize(k) = 0: armylead(k) = 0
			armyexper(k) = 0: armymove(k) = 0: supply(k) = 0
			END IF
		NEXT k
		FOR k = 21 TO 6
			IF RND > .6 THEN
			armyloc(k) = 0: armysize(k) = 0: armylead(k) = 0
			armyexper(k) = 0: armymove(k) = 0: supply(k) = 0
			END IF
		NEXT k
		FOR k = 1 TO 40: CALL occupy(k): NEXT k
		navysize(1) = 10 * RND: IF navysize(1) = 0 THEN navyloc(1) = 0
		navysize(2) = 10 * RND: IF navysize(2) > 0 THEN navyloc(2) = 27
		IF RND > .7 THEN capcity(2) = 25

		FOR k = 1 TO 40
		IF RND > .8 THEN rating(k) = rating(k) - 3 + 6 * RND: IF rating(k) > 9 THEN rating(k) = 9
		IF rating(k) < 1 THEN rating(k) = 1
		NEXT k
		CLS
		CALL europe
		choose = 30: GOTO utile
'-------------------------------------------------------------------------
'                               History
'-------------------------------------------------------------------------
	   CASE 10
		history = 1 - history
		a$ = "OFF": IF history = 1 THEN a$ = "ON": GOSUB history: CALL europe
		CALL clrbot: PRINT "History is now "; a$;
		choose = 31: GOTO utile
'-------------------------------------------------------------------------
'                               Aggression
'-------------------------------------------------------------------------
	   CASE 11
		bold = bold + 1: IF bold > 5 THEN bold = 0
		SELECT CASE bold
		CASE 0: a$ = "PASSIVE"
		CASE 1: a$ = "TIMID"
		CASE 2: a$ = "CAUTIOUS"
		CASE 3: a$ = "NORMAL"
		CASE 4: a$ = "BOLD"
		CASE 5: a$ = "RECKLESS"
		END SELECT
		CALL clrbot
		COLOR 11
		PRINT "Enemy Aggression : "; a$; " ("; bold; ")";
		choose = 32: GOTO utile
		CASE size
		GOSUB savecfg: GOTO utile
		CASE ELSE
	   END SELECT
'==========================================================================
'                               Files
'==========================================================================
	CASE 8
	IF LEN(DIR$("*.sav")) = 0 THEN filel = 0
filex:
	choose = 23: chosit = 29: IF year = 1861 THEN choose = 22
	mtx$(0) = "Options"
	mtx$(1) = "Load": IF filel = 0 THEN mtx$(1) = "-": choose = 23
	mtx$(2) = "Save"
	mtx$(3) = "New Game"
	mtx$(4) = "Quit to DOS"
	size = 4: tlx = 66: tly = 15
	CALL menu(0): CALL clrrite
	SELECT CASE choose
		CASE IS < 1: GOTO menu0
		CASE 1, 2
loader:
			IF choose = 1 AND filel = 0 GOTO filex
			CALL filer(choose + 1)
			IF choose = 1 THEN rflag = 0: mflag = 0: nflag = 0
			IF replay = 0 THEN GOTO menu0 ELSE replay = 0: GOTO goon
		CASE 3
			GOSUB savecfg
			CLS
			GOTO newgame
		CASE 4: GOTO rusure
	END SELECT
'==========================================================================
	CASE 99
	GOTO endrnd
CASE ELSE
	chosit = 22
	GOTO menu0
END SELECT
GOTO menu0
'............................................................................
'                               Subs
'............................................................................
topbar:
LOCATE 1, 1: PRINT SPACE$(80);
COLOR 11
LOCATE 1, 10: PRINT "Input your decisions now for "; force$(side); " side "; : COLOR 14: PRINT month$(month); ","; year; "  "
RETURN
'............................................................................
rusure:
choose = 23
mtx$(0) = "Quit"
mtx$(1) = "Yes"
mtx$(2) = "No"
size = 2: colour = 5
tlx = 67: tly = 15
CALL menu(0): CALL clrrite
IF choose = 1 THEN
	IF LEN(DIR$("rrs.exe")) > 0 THEN SHELL "rrs.exe"
	END
ELSE
	GOTO menu0
END IF
RETURN
'............................................................................
blanken:        c = 1: IF side = 2 THEN c = 4
		CLS : LINE (100, 200)-(500, 300), c, BF
		LINE (100, 200)-(500, 300), 8 - c, B
		COLOR 7: LOCATE 14, 31: PRINT " "; month$(month); year
		COLOR 11: LOCATE 17, 30: PRINT force$(side); " PLAYER TURN"
		DO WHILE INKEY$ = "": LOOP
		RETURN
'............................................................................
tricolor:
LINE (0, 0)-(213, 480), 1, BF
LINE (214, 0)-(427, 480), 15, BF
LINE (428, 0)-(639, 480), 4, BF
RETURN
'............................................................................
history:
IF history = 1 THEN
	CLS
	IF LEN(DIR$("nws.his")) > 0 THEN SHELL "copy nws.his oldhist.ory"
	OPEN "O", 2, "nws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
	CLOSE #2
END IF
RETURN
'............................................................................
savecfg:
OPEN "O", 1, "nws.cfg"
WRITE #1, side, noise, difficult, bold, player, turbo!, randbal, history, tactical
CLOSE #1
CALL clrbot
COLOR 14: PRINT "NWS.CFG updated";
TICK 1
RETURN
'............................................................................

' $INCLUDE: 'won1.bm'
' $INCLUDE: 'won2.bm'
' $INCLUDE: 'wonmenu.bm'
' $INCLUDE: 'qb64.bm'
