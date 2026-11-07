DEFINT A-Z
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB normal (xbar%, vary%, result%)
DECLARE SUB relieve (who%)
DECLARE SUB retreat (active%, x%)
DECLARE SUB stax (who%)
DIM SHARED graphic(1 TO 2000), fren(1 TO 90), nat2(1 TO 90), nat3(1 TO 90), nat4(1 TO 90), nat5(1 TO 90), nat6(1 TO 90), nap(1 TO 90)
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

SUB armies
CALL movefrom(index, target): IF target > 0 AND index > 0 GOTO tent
	IF index = -1 THEN mflag = 1
	GOTO dudd
tent:
tlx = 67: tly = 12

COLOR 11: LOCATE 11, 68: PRINT city$(target)
size = 0
mtx$(0) = "To"
FOR i = 1 TO 6
	IF matrix(target, i) > 0 THEN
		x = matrix(target, i)
		IF matrix(target, 7) < 90 THEN
addto:
			size = size + 1: mtx$(size) = city$(matrix(target, i)): array(size) = matrix(target, i)
		ELSE
			IF matrix(x, 7) < 90 GOTO addto
			IF navyloc(side) = target AND navyloc(3 - side) <> x GOTO addto
			FOR k = 1 TO 4
				IF island(k) = target OR island(k) = x GOTO nextone
			NEXT k
			GOTO addto
		END IF
	END IF
nextone:
NEXT i
IF size < 1 THEN CALL clrbot: PRINT "No legal moves for "; armyname$(index); : CALL TICK(9): EXIT SUB
CALL bubble(size)

hilite = 10: colour = 3: CALL menu(2): CALL clrrite
IF choose < 0 GOTO dudd
IF (month > 10 OR month < 4) AND supply(index) = 0 AND cityp(array(choose)) <> side THEN COLOR 11: CALL clrbot: PRINT "OUT OF SUPPLY ... cannot move"; : CALL TICK(9): CALL clrbot: GOTO dudd

CALL clrbot: PRINT "Army "; index; " "; armyname$(index); " is moving from "; city$(target); " to "; city$(array(choose));
IF noise > 0 THEN SOUND 2200, .5: SOUND 2900, .7
CALL icon(target, array(choose), 1)
armymove(index) = array(choose): CALL TICK(turbo!): CALL clrbot
CALL clrrite
dudd:
END SUB

SUB battle (attack, defend, win, lose)
IF armysize(defend) < 1 THEN armysize(defend) = 1
IF armysize(attack) < 1 THEN armysize(attack) = 1

CALL icon(armyloc(defend), 0, 9)
LINE (528, 60)-(638, 435), 0, BF
y = 68: COLOR 11
c = 9: IF attack > 25 THEN c = 4
a$ = armyname$(attack): IF LEN(a$) > 11 THEN a$ = LEFT$(a$, 11)
COLOR c: LOCATE 5, y: PRINT a$
LOCATE 6, y: CALL strong(attack)
x = .01 * armysize(attack): IF x > TCR THEN x = TCR
LOCATE 7, y: PRINT "Base    "; x
IF armysize(attack) / armysize(defend) > .2 THEN x = x + .3 * armylead(attack) + .3 * armyexper(attack): IF x > TCR THEN x = TCR
IF armyexper(attack) > 8 THEN x = x + 1: IF x > TCR THEN x = TCR
IF attack = 1 THEN x = 2 * x
LOCATE 8, y: PRINT "Ldr/Exp "; x
IF armysize(attack) < 15 THEN x = .5 * x: IF x > TCR THEN x = TCR
IF armysize(attack) / armysize(defend) <= .5 THEN x = x - 2: IF x < 1 THEN x = 1
IF armysize(attack) / armysize(defend) > 3 THEN x = x + 2: IF x > TCR THEN x = TCR
IF armysize(attack) / armysize(defend) > 10 THEN x = TCR
IF armysize(attack) / armysize(defend) <= .2 THEN x = 1
LOCATE 9, y: PRINT "Outman  "; x
IF supply(attack) < 1 THEN x = .5 * x: COLOR 13
LOCATE 10, y: PRINT "Supply  "; x: COLOR c
IF x < 1 THEN x = 1
'                       Adjust attack advantage
IF attack < 26 AND side = 2 AND difficult > 3 THEN x = x + 2 * difficult - 6
IF attack > 25 AND side = 1 AND difficult < 3 THEN x = x + 6 - 2 * difficult
COLOR c
IF armynat(attack) <> homenat(attack) THEN x = .7 * x: COLOR 13
LOCATE 11, y: PRINT "Cohesion"; x
LOCATE 12, y: PRINT "Difclt  "; x
IF x > TCR THEN x = TCR
COLOR 11: LOCATE 13, y: PRINT "Attack  "; x
LINE (530, 191)-(635, 207), 11, B

x1 = .013 * armysize(defend) + 1
a$ = armyname$(defend): IF LEN(a$) > 11 THEN a$ = LEFT$(a$, 11)
COLOR 13 - c: LOCATE 15, y: PRINT a$
LOCATE 16, y: CALL strong(defend)
LOCATE 17, y: PRINT "Base    "; INT(.01 * armysize(defend))
LOCATE 18, y: PRINT "Defense "; x1
IF armysize(defend) / armysize(attack) > .2 THEN x1 = x1 + .3 * armylead(defend) + .3 * armyexper(defend): IF x1 > TCR THEN x1 = TCR
IF armyexper(defend) > 8 THEN x1 = x1 + 1: IF x1 > TCR THEN x1 = TCR
IF defend = 1 THEN x1 = 2 * x1
LOCATE 19, y: PRINT "Ldr/Exp "; x1
IF armysize(defend) < 15 THEN x1 = .5 * x1

R! = armysize(defend) / armysize(attack)
SELECT CASE R!
	CASE IS > 10
		x1 = TCR
	CASE IS > 1.5
		x1 = x1 + 2
	CASE IS < .5
		x1 = .8 * x1
	CASE IS < .2
		x1 = .5 * x1
END SELECT
	IF x1 < 1 THEN x1 = 1
	IF x1 > TCR THEN x1 = TCR

LOCATE 20, y: PRINT "Outman  "; x1
IF supply(defend) < 1 THEN x1 = .5 * x1: COLOR 13
LOCATE 21, y: PRINT "Supply  "; x1: COLOR 13 - c
IF armynat(defend) <> homenat(defend) THEN x1 = .7 * x1: COLOR 13
LOCATE 22, y: PRINT "Cohesion"; x1
IF x1 < 1 THEN x1 = 1
'                       Adjust defend advantage
IF defend < 26 AND side = 2 AND difficult > 3 THEN x1 = x1 + 2 * difficult - 6
IF defend > 25 AND side = 1 AND difficult < 3 THEN x1 = x1 + 6 - 2 * difficult
LOCATE 23, y: PRINT "Difclt  "; x1

a$ = "Fort": IF armymove(defend) = 0 THEN x1 = x1 * (1 + .5 * fort(armyloc(defend)))
IF x1 > TCR THEN x1 = TCR
IF fort(armyloc(defend)) > 0 AND armymove(defend) = 0 THEN
	COLOR 13: a$ = "Fort+"
	IF fort(armyloc(defend)) = 2 THEN a$ = "Fort++"
END IF
LOCATE 24, y: PRINT a$; TAB(76); x1
IF x1 > TCR THEN x1 = TCR
COLOR 11: LOCATE 25, y: PRINT "Defend  "; x1
LINE (530, 383)-(635, 400), 11, B

spin = 0
scale = x: IF x1 > scale THEN scale = x1
scale = scale + 1

odds! = x / (x + x1): a = INT(100 * odds!): IF a < 1 THEN a = 1
a$ = LTRIM$(RTRIM$(STR$(a))) + "%"
COLOR 14: LOCATE 27, y: PRINT "Odds:  "; a$;
LINE (530, 412)-(635, 435), 14, B
LINE (528, 410)-(637, 437), 14, B
CALL TICK(9)
FOR i = 1 TO 2: IF supply(i) > 0 THEN supply(i) = supply(i) - 1
NEXT i
IF tactical <= 0 GOTO grapple
IF LEN(DIR$("rrs.exe")) <> 0 GOTO grapple
IF armysize(attack) / armysize(defend) > 3 XOR armysize(defend) / armysize(attack) > 3 GOTO grapple
'                       Fight the battle in the tactical game
	x = armysize(attack): x1 = armysize(defend)
	t$ = " OUT OF SUPPLY : FIGHTS AT « STRENGTH"
	IF supply(attack) < 1 THEN x = x \ 2: CALL image2(armyname$(attack) + t$, 4)
	IF supply(defend) < 1 THEN x1 = x1 \ 2: CALL image2(armyname$(defend) + t$, 4)
	t$ = " : LOW COHESION = 30% PENALTY"
	IF armynat(attack) <> homenat(attack) THEN x = .7 * x: CALL image2(armyname$(attack) + t$, 4)
	IF armynat(defend) <> homenat(defend) THEN x1 = .7 * x1: CALL image2(armyname$(defend) + t$, 4)
	OPEN "O", 1, "battle.$$$"
	a = 1: y = 2: IF attack < 25 THEN a = 2: y = 1
	WRITE #1, city$(armyloc(defend)), 3 - side, a, y, armyname$(attack), x, armylead(attack), armyexper(attack), armyname$(defend), x1, armylead(attack), armyexper(defend), difficult, fort(armyloc(defend)), noise
	CLOSE #1
	SHELL "napoleon.exe"
	OPEN "I", 1, "outcome.&&&"
	INPUT #1, w, killa, killd
	CLOSE #1
	SELECT CASE w
		CASE 1
			win = attack: lose = defend
		CASE ELSE
			win = defend: lose = attack
	END SELECT
	CALL europe
	w = 1: IF win > 25 THEN w = 4
	CALL image2(armyname$(win) + " is VICTORIOUS in " + city$(armyloc(defend)), w)
	CALL calendar
	CALL disband
	GOTO tally
'---------------------------------------------------------------------------
grapple:
	hit = 0: hit1 = 0
	star = scale * RND: fin = scale * RND
	IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	IF star <= x THEN hit = 1
	IF fin <= x1 THEN hit1 = 1

	IF hit = 0 AND hit1 = 0 GOTO grapple
	IF hit = 1 AND hit1 = 1 GOTO grapple
	win = defend: lose = attack: IF hit = 1 THEN win = attack: lose = defend
'---------------------------------------------------------------------------
	a$ = "French": IF win > 25 THEN a$ = "Allies"
	a = 1: IF win > 25 THEN a = 2
	CALL image2(a$ + " VICTORY in " + city$(armyloc(defend)) + " : " + armyname$(win) + " beats " + armyname$(lose), 4)
'===========================================================================
	pct! = .01 * DEFAC - .03 * fort(armyloc(defend)): IF win = attack THEN pct! = 1.3 * pct!
	SELECT CASE armysize(defend)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armysize(attack) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killd)
'...........................................................................
	pct! = .01 * ATKFAC + .02 * fort(armyloc(defend)): IF win = defend THEN pct! = 1.5 * pct!
	SELECT CASE armysize(attack)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armysize(defend) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killa)
'===========================================================================

	killa = .8 * killa + .2 * killd: IF killa < 1 THEN killa = 1
	killd = .8 * killd + .2 * killa: IF killd < 1 THEN killd = 1
	IF killa > 9 * killd THEN killa = 9 * killd
	IF killd > 5 * killa THEN killd = 5 * killa

tally:
IF killa >= armysize(attack) THEN killa = armysize(attack) - 1
IF killd >= armysize(defend) THEN killd = armysize(defend) - 1
'---------------------------------------------------------------------------
x = INT(100 * odds!): IF x < 1 THEN x = 1
a$ = LTRIM$(RTRIM$(STR$(x))) + "%"

COLOR c
CALL clrbot: PRINT "Attack Loss: ";
PRINT LTRIM$(RTRIM$(STR$(killa)) + "00"); "/";
CALL strong(attack)
PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / armysize(attack)))))); "%) ²";
COLOR 13 - c: PRINT "² Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
CALL strong(defend)
PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killd / armysize(defend)))))); "%)";
'---------------------------------------------------------------------------
mtx$(1) = " (" + LTRIM$(RTRIM$(STR$(killa) + "00")) + "/" + LTRIM$(STR$(armysize(attack)) + "00") + ") "
t$ = " (" + LTRIM$(RTRIM$(STR$(killd) + "00")) + "/" + LTRIM$(STR$(armysize(defend)) + "00") + ")"
mtx$(2) = t$
IF win = defend THEN mtx$(2) = mtx$(1): mtx$(1) = t$
mtx$(3) = "*" + armyname$(win): mtx$(4) = armyname$(lose)
IF win = defend THEN mtx$(3) = armyname$(win): mtx$(4) = "*" + armyname$(lose)
a$ = city$(armyloc(defend)) + ": " + mtx$(3) + mtx$(1) + " defeats " + mtx$(4) + mtx$(2)
CALL scribe(a$, 0)

IF player = 1 AND (side = 1 AND attack > 25) OR (side = 2 AND attack < 26) THEN
CALL TICK(9)
END IF

armysize(attack) = armysize(attack) - killa
armysize(defend) = armysize(defend) - killd
CALL TICK(2)
'---------------------------------------------------------------------------
s = 1: IF attack > 2 THEN s = 2
casualty&(s) = casualty&(s) + killa
casualty&(3 - s) = casualty&(3 - s) + killd
'---------------------------------------------------------------------------
s = 1: IF win > 25 THEN s = 2
IF armysize(defend) < 1 THEN armysize(defend) = 1
batwon(s) = batwon(s) + 1
victory(s) = victory(s) + 1
IF s = 1 THEN x = 5 ELSE x = -2
CALL enter(x)
IF s = 1 THEN
	IF armynat(attack) = 1 THEN x = defend ELSE x = attack
	attitude(armynat(x)) = attitude(armynat(x)) + 10
END IF
CALL icon(armyloc(defend), 0, 8)
LINE (528, 60)-(638, 435), 2, BF
END SUB

SUB combine (who)
	colour = 3: target = 0: hilite = 3
	tlx = 67: tly = 6
	CALL starfin(star, fin, who)
	size = 0
	FOR i = 1 TO cities
		IF cityp(i) = who AND occupied(i) > 0 THEN
			FOR j = star TO fin
			IF armyloc(j) = i AND occupied(i) <> j AND armymove(j) = 0 THEN size = size + 1: mtx$(size) = city$(i): array(size) = i: EXIT FOR
			NEXT j
		END IF
	NEXT i
	
	IF size = 0 THEN who = -1: EXIT SUB

	IF who <> side THEN choose = 1 + INT(size * RND): GOTO join
	mtx$(0) = "Join"
		choose = 31: hilite = 11
		CALL menu(0)
join:
		IF choose < 1 GOTO nocity2
		target = array(choose)
		CALL clrbot: PRINT "Combining "; force$(who); " armies in "; city$(target); :  CALL TICK(turbo!)

		armysize(0) = 0: armylead(0) = 0: armyexper(0) = 0: armyloc(0) = target
		armyname$(0) = "": supply(0) = 0: armymove(0) = 0
'...........................................................................
		best = 0: x = 0: spin = 0
		FOR j = star TO fin
		IF armymove(j) <> 0 OR armyloc(j) <> target OR armysize(j) = 0 GOTO dork1
		IF armysize(0) + armysize(j) > 4000 THEN CALL clrbot: PRINT "Cannot combine "; armyname$(j); "... TOO LARGE"; : CALL TICK(turbo!): GOTO dork1

		IF armylead(j) > x THEN
			x = armylead(j)
			armyname$(0) = armyname$(j)
			armylead(0) = armylead(j)
			best = j
		END IF

		armysize(0) = armysize(0) + armysize(j)
		IF armysize(0) < 1 GOTO dork1
		pct! = (armysize(j) / armysize(0))
		spin = spin + 1
		armyexper(0) = (1 - pct!) * armyexper(0) + pct! * armyexper(j)
		CALL clrbot: PRINT armyname$(j); " is combining his "; : CALL strong(j): PRINT " forces"; : CALL TICK(turbo!)
		supply(0) = supply(0) + supply(j)
		IF supply(0) > 10 THEN supply(0) = 10
		armysize(j) = 0: armyloc(j) = 0: armyexper(j) = 0: armymove(j) = 0
		lname$(j) = armyname$(j)
		armylead(j) = 0: supply(j) = 0: armyname$(j) = ""
dork1:
		NEXT j

		CALL clrbot
		IF who <> side AND spin = 0 THEN EXIT SUB
		IF spin = 0 THEN
				PRINT "No valid armies to combine at this time in "; city$(target);
				TICK turbo!
				EXIT SUB
		END IF
		armysize(best) = armysize(0): armylead(best) = armylead(0)
		armyexper(best) = armyexper(0): supply(best) = supply(0)
		armyloc(best) = target
		armyname$(best) = armyname$(0)
		lname$(best) = ""
		IF spin > 1 THEN
		PRINT "New army "; best; " of "; : CALL strong(best): PRINT " is commanded by "; armyname$(best);
		armymove(best) = -1
		ELSE
		PRINT "Only 1 eligible army -- cannot combine at this time";
		END IF
		IF who = side THEN CALL TICK(turbo!)
		IF noise > 0 THEN SOUND 4000, .7
	       
		CALL showcities
		CALL placearmy(best)
		CALL icon(target, 0, 6)
		occupied(target) = best
		CALL stax(who)
nocity2:
END SUB

SUB filer (switch)
SELECT CASE switch
	CASE -1
	OPEN "I", 1, "gamedata.ini"
	FOR i = 0 TO 2: INPUT #1, force$(i): NEXT i
	FOR i = 1 TO 12: INPUT #1, nation$(i): NEXT i
	FOR i = 1 TO 12: INPUT #1, month$(i): NEXT i
	INPUT #1, ATKFAC, DEFAC, TCR
	FOR i = 1 TO 19: INPUT #1, mtnx(i), mtny(i): NEXT i
	FOR k = 1 TO 36: INPUT #1, font$(k): NEXT k
	FOR k = 1 TO 4: INPUT #1, island(k): NEXT k
	CLOSE #1
	OPEN "I", 1, "nws.cfg"
	INPUT #1, side, noise, difficult, bold, player, turbo!, randbal, history, tactical
	CLOSE #1
	EXIT SUB

	CASE 1
	GOSUB lead
	f$ = "nws" + scenario$ + ".ini"
	OPEN "I", 1, f$
	INPUT #1, month, year
'               set end game conditions
	FOR i = 1 TO 6: INPUT #1, vicflag(i): NEXT i
	vicflag(3) = .67 * vicflag(3)
	INPUT #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: INPUT #1, attitude(k): NEXT k
	INPUT #1, a             ' number of French armies
FOR i = 1 TO a
	INPUT #1, armynat(i), armyloc(i), armysize(i), armyexper(i), supply(i): occupied(armyloc(i)) = i: armyname$(i) = lname$(i): armylead(i) = rating(i): lname$(i) = ""
NEXT i
	INPUT #1, a             ' number of Allied armies
FOR i = 26 TO 25 + a
	INPUT #1, armynat(i), armyloc(i), armysize(i), armyexper(i), supply(i)
	occupied(armyloc(i)) = i: armyname$(i) = lname$(i): lname$(i) = "": armylead(i) = rating(i): lname$(i) = ""
NEXT i
FOR i = 1 TO 2: INPUT #1, cash(i): NEXT i
	INPUT #1, navysize(1), navyloc(1)
	INPUT #1, navysize(2), navyloc(2)
	INPUT #1, capcity(1), capcity(2)
	CLOSE #1

	CASE 2
	IF LEN(DIR$("*.sav")) = 0 THEN choose = -1: EXIT SUB
	mtx$(0) = "Load"
	size = 0
	FOR k = 1 TO 9
		t$ = "nws" + LTRIM$(STR$(k)) + ".sav"
		IF LEN(DIR$(t$)) > 0 THEN
			size = size + 1: mtx$(size) = t$: array(size) = k
		END IF
	NEXT k
	tlx = 67: tly = 14 - .5 * size
	CALL menu(0)
	IF choose < 1 THEN EXIT SUB
	z = 0
reopen:
	OPEN "I", 1, "nws" + LTRIM$(STR$(array(choose))) + ".sav"
	COLOR 11: CALL clrbot: PRINT "Loading";
	INPUT #1, scenario$, month, year, usadv, a
	IF z = 0 THEN CLOSE #1: GOSUB lead: z = 1: GOTO reopen
	FOR i = 1 TO 6: INPUT #1, vicflag(i): NEXT i
	INPUT #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: INPUT #1, attitude(k): NEXT k
	FOR i = 1 TO 50: INPUT #1, armyname$(i), armynat(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	IF armyloc(i) > 0 THEN
		IF armyname$(i) = lname$(i) THEN
			lname$(i) = ""
		ELSE
			who = 1: IF i > 25 THEN who = 2
			CALL starfin(star, fin, who)
			FOR k = star TO fin
			IF armyname$(i) = lname$(k) THEN lname$(k) = "": EXIT FOR
			NEXT k
		END IF
	END IF
	NEXT i
	FOR i = 1 TO cities: INPUT #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: INPUT #1, cash(i), control(i), income(i), victory(i), capcity(i)
	INPUT #1, navysize(i), navyloc(i), navymove(i), commerce
	NEXT i

	CLOSE #1
	rescue = 0: IF player = 1 AND side = 2 AND armyloc(1) = 16 THEN rescue = armyloc(1)
	IF switch = 9 THEN EXIT SUB
	OPEN "I", 1, "nws.cfg"
	INPUT #1, myside, noise, difficult, bold, player, turbo!, randbal, history, tactical
	CLOSE #1
	IF player = 1 AND side = 2 AND armyloc(1) = 16 THEN rescue = armyloc(1)
	SCREEN 12: CLS
	CLOSE #1: CALL europe: CALL clrbot
	side = a
	CALL calendar

	CASE 3
	mtx$(0) = "Save Game"
	FOR k = 1 TO 8
	mtx$(k) = "nws" + LTRIM$(STR$(k)) + ".sav"
	IF LEN(DIR$(mtx$(k))) > 0 THEN mtx$(k) = mtx$(k) + " û"
	NEXT k
	tlx = 67: size = 8
	CALL menu(0)
	IF choose < 1 THEN EXIT SUB
	COLOR 11: CALL clrbot: PRINT "Saving";
savit:
	OPEN "O", 1, "nws" + LTRIM$(STR$(choose)) + ".sav"
	WRITE #1, scenario$, month, year, usadv, side
	FOR i = 1 TO 6: WRITE #1, vicflag(i): NEXT i
	WRITE #1, batwon(1), batwon(2), casualty&(1), casualty&(2)
	FOR k = 1 TO 7: WRITE #1, attitude(k): NEXT k
	FOR i = 1 TO 50: WRITE #1, armyname$(i), armynat(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	NEXT i
	FOR i = 1 TO cities: WRITE #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: WRITE #1, cash(i), control(i), income(i), victory(i), capcity(i)
	WRITE #1, navysize(i), navyloc(i), navymove(i), commerce
	NEXT i
	CLOSE #1

	myside = side
	IF myside < 1 OR myside > 2 THEN myside = 1
	OPEN "O", 1, "nws.cfg"
	WRITE #1, myside, noise, difficult, bold, player, turbo!, randbal, history, tactical, bold
	CLOSE #1
	CLS : CALL europe

	CASE 9
	choose = 9: GOTO savit
END SELECT
EXIT SUB

lead:
	OPEN "I", 1, "lead" + scenario$ + ".dat"
	FOR i = 1 TO 25: INPUT #1, lname$(i), rating(i): homenat(i) = 1: NEXT i
	FOR i = 26 TO 50: INPUT #1, homenat(i), lname$(i), rating(i): NEXT i
	CLOSE #1
	OPEN "I", 1, "euro" + scenario$ + ".map"
	FOR i = 1 TO cities
		INPUT #1, a, city$(i), cityx(i), cityy(i), cityo(i), cityv(i)
		vptotal = vptotal + cityv(i)
		a = cityo(i): IF cityo(i) > 1 THEN a = 2
		cityp(i) = a
		CALL occupy(i)
		IF occupied(i) > 0 THEN IF occupied(i) < 25 THEN cityp(i) = 1 ELSE cityp(i) = 2
		FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j
		INPUT #1, fort(i)
	NEXT i
	CLOSE #1
	RETURN
END SUB

SUB flashcity (which)
FOR c = 1 TO 15 STEP 2
CIRCLE (cityx(which), cityy(which)), 4, 0
CIRCLE (cityx(which), cityy(which)), 3, c
PAINT (cityx(which), cityy(which)), c, c
CALL TICK(.1)
NEXT c
CALL cityicon(which)
END SUB

SUB fortify (target)
	target = 0: hilite = 11
	tlx = 67: tly = 2
	who = side
	CALL starfin(star, fin, who)
	size = 0
	FOR i = star TO fin
	IF armyloc(i) > 0 AND fort(armyloc(i)) < 2 THEN
		size = size + 1
		mtx$(size) = city$(armyloc(i))
		array(size) = armyloc(i)
	END IF
	NEXT i
	IF size = 0 THEN CALL clrbot: COLOR 11: PRINT "No cities eligible to fortify"; : EXIT SUB
	mtx$(0) = "Fortify"
		choose = 31
		CALL menu(0)
		IF choose < 0 GOTO nocity
		target = array(choose): CALL occupy(target): x = occupied(target): IF x < 0 GOTO nocity
		IF fort(target) > 1 THEN CALL clrbot: PRINT city$(target); " at MAXIMUM fortification level of 2"; : CALL TICK(4): GOTO nocity
		cost = 200
		IF cash(side) < cost THEN CALL clrbot: PRINT "Fortifications for "; city$(target); " cost "; cost; " and you only have "; cash(side); : CALL TICK(4): GOTO nocity
		COLOR 3
		fort(target) = fort(target) + 1
		cash(side) = cash(side) - cost
		CALL clrbot: PRINT city$(target); " fortifications increased to "; fort(target);
		CALL icon(target, 0, 6)
		CALL showcities
		IF armymove(x) > 0 THEN CALL icon(armyloc(x), armymove(x), 5)
		armymove(x) = -1
		CALL placearmy(x)
		CALL stax(who)
nocity:
END SUB

SUB icon (from, dest, kind)
IF from < 1 OR from > cities GOTO noshow
IF dest < 0 GOTO noshow
IF from = 999 GOTO noshow
x = cityx(from) - 12: y = cityy(from) - 11
x1 = cityx(dest): y1 = cityy(dest)
SELECT CASE kind
	CASE 1
	LINE (x, y)-(x1, y1), 15, , &HF0F0
       
	CASE 2
	FOR i = 6 TO 8
	LINE (x - i + 1, y - i + 1)-(x + i, y + i - 3), 14, B
	NEXT i
	CALL TICK(.1)
       
	CASE 3
	x = cityx(from): y = cityy(from)
flash:
	CALL snapshot(x, y, 0)
	CIRCLE (x, y), 10, 8
	PAINT (x, y), 0, 8
	CALL TICK(.05)
	FOR j = 1 TO 3
	FOR i = 4 TO 10 STEP 1
	CIRCLE (x, y), i, 4
	PAINT (x, y), 14, 4
	IF kind <> 12 THEN IF noise > 0 THEN SOUND 37 + 50 * RND, .03
	NEXT i
	IF kind <> 12 THEN CALL TICK(.1)
	CALL snapshot(x, y, 1)
	NEXT j
       
	CASE 4
	IF occupied(from) = 0 THEN
		c = POINT(x - 1, y - 9): IF c <> 1 THEN c = 2
		LINE (x - 8, y - 6)-(x + 10, y + 8), c, BF
	END IF
	IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
	CASE 5
	IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0

	CASE 6
	x = cityx(from): y = cityy(from)
	CALL snapshot(x, y, 0)
	LINE (x - 9, y - 9)-(x + 9, y + 9), 15, B
	LINE (x - 10, y - 10)-(x + 10, y + 10), 15, B
	IF noise > 0 THEN SOUND 3999, .3
	CALL TICK(turbo! - .5)
	CALL snapshot(x, y, 1)
	CASE 7          ' draw white box
	x = cityx(from) - 12: y = cityy(from) - 11
	GET (x - 8, y - 8)-(x + 8, y + 8), image
	LINE (x - 7, y - 7)-(x + 7, y + 6), 14, B
	LINE (x - 6, y - 6)-(x + 8, y + 5), 14, B
	     CASE 8     ' replace old image
	x = cityx(from) - 12: y = cityy(from) - 11
	IF x > 0 THEN PUT (x - 8, y - 8), image, PSET
       
	CASE 9          ' draw arrow pointer
	x = cityx(from) - 12: y = cityy(from) - 11
	GET (x - 8, y - 8)-(x + 10, y + 7), image
	x = x + 7: y = y + 5
	LINE (x + 2, y)-(x + 2, y - 8), 12
	LINE -(x, y - 6), 12
	LINE -(x - 5, y - 11), 12
	LINE -(x - 10, y - 6), 12
	LINE -(x - 6, y - 2), 12
	LINE -(x - 10, y), 12
	LINE -(x + 1, y), 12
	PAINT (x - 2, y - 1), 15, 12

	CASE 11
	LINE (x + 12, y + 11)-(x1, y1), 0, , &H1111

	CASE 12
	x = 260 + 25 * INT(6 * RND): y = 404
	GOTO flash

	CASE ELSE
END SELECT
noshow:
END SUB

SUB movefrom (index, target)
	colour = 3: index = 0: size = 0: target = 0
	who = side: CALL starfin(star, fin, who)
	FOR i = star TO fin
	IF armyloc(i) > 0 AND armymove(i) = 0 AND occupied(armyloc(i)) = i THEN size = size + 1: mtx$(size) = city$(armyloc(i)): array(size) = armyloc(i)
	NEXT i
	IF size = 0 THEN index = -1: GOTO notarg
	mtx$(0) = "From"
	CALL bubble(size)
movopt:
	tlx = 67: tly = 25 - size: IF tly < 0 THEN tly = 1: size = 25 - tly
		hilite = 15: CALL menu(1): CALL clrrite
		IF choose < 0 THEN target = 0: GOTO notarg
		target = array(choose)

		size = 0
		FOR i = star TO fin
		IF armyloc(i) = target AND armymove(i) = 0 THEN index = i: size = size + 1: mtx$(size) = "Army" + STR$(i): array(size) = i: IF occupied(target) = i THEN mtx$(size) = mtx$(size) + "*"
		NEXT i
		IF size = 1 GOTO notarg
		mtx$(0) = "Which"
		CALL bubble(size)
		tlx = 67: tly = 8: CALL menu(4): CALL clrrite
		IF choose < 0 THEN index = 0: GOTO notarg
		index = array(choose)
notarg:
END SUB

SUB newarmy (who, empty, target, nat)
	supply(empty) = 3 + 5 * RND: IF who = 1 THEN supply(empty) = supply(empty) + 2
	armyexper(empty) = 1: IF who = 2 THEN armyexper(empty) = 2
	armylead(empty) = rating(empty)
	armyname$(empty) = lname$(empty): lname$(empty) = ""
	COLOR 12: CALL clrbot: PRINT "Placing NEW army "; empty; armyname$(empty); " in "; city$(target);
	IF nat = 0 THEN armynat(empty) = cityo(target) ELSE armynat(empty) = nat
	x = 3 * cityv(target) + 25
	CALL cutoff(who, target, a): IF a < 1 THEN x = x \ 3
	occupied(target) = empty: armysize(empty) = x
	PRINT " Size = "; : CALL strong(empty)
	cash(who) = cash(who) - 100
	armyloc(empty) = target: CALL placearmy(empty)
	CALL icon(target, 0, 7)
	IF noise > 0 THEN SOUND 2222, .7 ELSE CALL TICK(.7)
	CALL placearmy(empty)
	CALL TICK(1)
	armymove(empty) = -1
END SUB

SUB newcity (index)
		mtx$(1) = "  "
		mtx$(3) = "  "
		size = 3: a$ = city$(index)
morecap:
		tlx = 68: tly = 15: colour = 3: choose = 23
		mtx$(2) = city$(index)
		CALL menu(3): CALL clrrite
	       SELECT CASE choose
		CASE IS = -27
		index = 0: EXIT SUB
		CASE IS < 1
		a$ = CHR$(ABS(choose))
		x = 0
		FOR k = 1 TO 40
		IF LEFT$(city$(k), 1) = a$ THEN
			y = index: index = k
spin2:
			IF cityp(index) = side GOTO morecap
				index = index + 1
				IF index > 40 THEN index = 1
				x = x + 1: IF x < 39 GOTO spin2
				index = y: GOTO morecap
		END IF
		NEXT k
		GOTO morecap
		CASE 1
minus1:
		index = index - 1: IF index < 1 THEN index = 40
		IF cityp(index) <> side GOTO minus1 ELSE GOTO morecap
		CASE 2
		GOTO fnew
		CASE 3
plus1:
		index = index + 1: IF index > 40 THEN index = 1
		IF cityp(index) <> side GOTO plus1 ELSE GOTO morecap
		CASE ELSE
		index = 0
		END SELECT
fnew:
END SUB

SUB placearmy (which)
x = cityx(armyloc(which)) - 19
y = cityy(armyloc(which)) - 18
SELECT CASE which
	CASE IS < 26
		IF which = 1 THEN PUT (x, y), nap, PSET ELSE PUT (x, y), fren, PSET
	CASE ELSE
		SELECT CASE armynat(which)
			CASE 2
				PUT (x, y), nat2, PSET
			CASE 3
				PUT (x, y), nat3, PSET
			CASE 4
				PUT (x, y), nat4, PSET
			CASE 5
				PUT (x, y), nat5, PSET
			CASE 6
				PUT (x, y), nat6, PSET
			CASE ELSE
				PUT (x, y), nat2, PSET
		END SELECT
END SELECT
IF supply(which) < 1 THEN
	x = x + 2: y = y + 8
	PSET (x, y), 13: DRAW "C11S8"
	DRAW font$(19)
	DRAW "S4"
END IF
END SUB

SUB recruit (who)
	IF cash(who) < 100 THEN EXIT SUB
	size = 0: COLOR 12
	mtx$(0) = "Recruit"
	IF who = side AND rflag > 0 THEN FOR i = 1 TO rflag: x = rcity(i): mtx$(i) = city$(x): array(i) = x: NEXT i: size = rflag: GOTO alldone
	max = 11: IF RND > .8 THEN max = max - 1
	IF difficult < 3 THEN max = max + 1

	FOR i = 1 TO cities
	IF control(who) > 0 THEN pct! = max / control(who) ELSE pct! = .5
	IF size = 0 AND i > 30 THEN pct! = .5
	IF size < 2 AND i > 50 THEN pct! = .5
	array(i) = 0
	IF occupied(i) > 0 AND cityp(i) = who THEN pct! = .6: IF armysize(occupied(i)) > 4000 THEN pct! = 0
	IF attitude(cityo(i)) <= 50 THEN pct! = 0
	IF who = 1 THEN
		IF RND < pct! AND cityp(i) = who AND (cityo(i) = who OR cityo(i) > 6) THEN GOSUB addcity: IF size > max - 1 GOTO alldone
	ELSE
		IF RND < pct! AND cityp(i) = who AND cityo(i) > 1 THEN GOSUB addcity: IF size > max - 1 GOTO alldone
	END IF
	NEXT i
	GOTO alldone
addcity:
	size = size + 1
	mtx$(size) = city$(i)
	array(size) = i
	RETURN
alldone:
	IF size = 0 GOTO menu1
	IF who = side AND rflag = 0 THEN FOR i = 1 TO size: rcity(i) = array(i): NEXT i: rflag = size
	CALL bubble(size)
'............................................................................
levy:
	IF cash(who) < 100 GOTO menu1
	IF (who = side) OR (player = 2) THEN CALL clrbot: PRINT force$(who); " funds available "; cash(who);
	tlx = 67: tly = 8: colour = 3
	IF who <> side THEN GOSUB randsel: GOTO auto1

	IF choose > 0 THEN choose = 21 + choose
	hilite = 14: CALL menu(2): CALL clrrite
	IF choose < 1 GOTO menu1
auto1:
	empty = 0
	index = array(choose)
	CALL occupy(index)
	IF occupied(index) > 0 THEN i = occupied(index): GOTO add2
	CALL commander((who), empty)

	IF who <> side AND empty = 0 GOTO menu1
	IF empty = 0 GOTO levy
	armyloc(empty) = index
	GOSUB playb
	CALL newarmy(who, empty, index, 0)
	GOTO levy
'............................................................................
add2:
	target = array(choose)
	a$ = ""
	x = 2 * cityv(armyloc(i))
	CALL cutoff(who, target, a)
	IF a < 1 THEN x = x \ 3: a$ = " ISOLATED !"
	armysize(i) = armysize(i) + 4 * cityv(target)
	IF armyloc(1) = target THEN armysize(i) = armysize(i) + 4 * cityv(target)

	GOSUB playb
	cash(who) = cash(who) - 100
	from = armyloc(i): x = cityx(from) - 12: y = cityy(from) - 11
	CALL icon(armyloc(i), 0, 2)
	IF noise > 0 THEN SOUND 2222, 1
	COLOR 11: CALL clrbot: PRINT "Army "; i; armyname$(i); " in "; city$(armyloc(i)); " strength increased to "; : CALL strong(i)
	IF a$ <> "" THEN PRINT a$;
	CALL placearmy(i)
	CALL TICK(turbo! - .5)
	GOTO levy
randsel:
		choose = 0: x = 0
		FOR i = 1 TO size
		target = array(i)
		LOCATE 14 + i, 69
		x = occupied(target)
		IF x = 0 XOR armysize(x) < 155 THEN choose = i
		IF x = 1 THEN choose = i: RETURN
		NEXT i

	IF choose = 0 THEN choose = 1 + INT(RND * size)
		x = 0
		FOR i = 1 TO size
		target = array(i)
		IF occupied(target) = 0 THEN
			y = 3 * cityv(target) + 33
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		ELSE
			y = 2 * cityv(target) + 20
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		END IF
		IF y > x AND RND > .5 THEN x = y: choose = i
		NEXT i
	IF cash(who) < 100 THEN choose = size
	RETURN
playb:
	IF side = 1 AND difficult < 3 THEN armysize(empty) = armysize(empty) - 5 * difficult + 15
	IF side = 2 AND difficult > 3 THEN armysize(empty) = armysize(empty) + 5 * difficult - 15
	RETURN
menu1:
END SUB

SUB showcities
FOR c = 1 TO cities
	CALL cityicon(c)
NEXT c
END SUB

SUB snapshot (x, y, flag)
IF flag = 0 THEN GET (x - 10, y - 10)-(x + 10, y + 10), image
IF flag = 1 THEN PUT (x - 10, y - 10), image, PSET
END SUB

SUB strong (index)
a$ = LTRIM$(RTRIM$(STR$(armysize(index)))) + "00"
PRINT a$;
END SUB

SUB tupdate
flag = 0
CALL bossarmy
IF player = 1 THEN CALL smarts: nflag = 0
FOR i = 1 TO 50
IF armyloc(i) > 0 AND armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
NEXT i
CALL clrbot: PRINT "press any key for "; month$(month); ","; year; " events";
CALL TICK(9)
GOSUB upbox
'==========================================================================
'                       Assign Time of Action
'==========================================================================
FOR i = 1 TO 50
brray(i) = 999
IF armymove(i) < 0 THEN armymove(i) = 0
IF armyloc(i) > 0 AND armymove(i) > 0 THEN brray(i) = INT(4 + 4 * RND) * 100 + i
IF supply(i) < 1 AND armymove(i) > 0 THEN brray(i) = 900 + i
SELECT CASE armysize(i)         'bigger armies move slower
	CASE IS > 400
		IF brray(i) < 900 THEN brray(i) = brray(i) + 100: x = 2
	CASE IS > 800
		IF brray(i) < 800 THEN brray(i) = brray(i) + 200: x = 3
	CASE IS > 1000
		IF brray(i) < 700 THEN brray(i) = brray(i) + 300: x = 4
	CASE ELSE
		x = 1
END SELECT
IF brray(i) <> 999 AND armylead(i) > 10 * RND THEN
		brray(i) = brray(i) - 100 * (armylead(i) \ 2)
		IF brray(i) < 100 THEN brray(i) = 100 + i
END IF
NEXT i

CALL bub2(50)
'==========================================================================
'                       Begin Main Loop
'==========================================================================
FOR j = 1 TO 50
flag = 0
IF brray(j) = 999 GOTO allthru
active = INT(brray(j) / 100): active = brray(j) - 100 * active: s = 1: IF active > 25 THEN s = 2
IF armymove(active) < 1 GOTO digin
COLOR 11: CALL clrbot: PRINT armyname$(active); " is moving to "; city$(armymove(active));

supply(active) = supply(active) - 1: IF supply(active) < 0 THEN supply(active) = 0: CALL TICK(turbo!): CALL clrbot: PRINT armyname$(active); " is out of supplies !";

CALL placearmy(active)
CALL icon(armyloc(active), armymove(active), 5)

CALL animate(active, 1)
'==========================================================================
target = armymove(active)
IF occupied(target) = 0 GOTO easy
IF (s = 1 AND occupied(target) < 26) OR (s = 2 AND occupied(target) > 25) GOTO friend ELSE GOTO enemy
'==========================================================================
'                         Join Forces
'==========================================================================
friend:
COLOR 11: CALL clrbot: PRINT armyname$(active); " and "; armyname$(occupied(target)); " meet in "; city$(target); : CALL TICK(turbo!)
CALL icon(armymove(active), 0, 6)
CALL clrbot
GOTO easy
'==========================================================================
'                       Attack
'==========================================================================
enemy:
CALL icon(target, 0, 3)
defend = occupied(target)

COLOR 11: CALL clrbot: PRINT armyname$(active); " attacks "; armyname$(defend); " in "; city$(armyloc(defend)); : CALL TICK(turbo! - 1)
IF armysize(defend) > 0 THEN CALL battle(active, defend, win, lose): flag = 1
IF armyexper(win) < 10 THEN armyexper(win) = armyexper(win) + 1

IF armysize(lose) < 2 THEN
	a$ = armyname$(lose) + "'s army is crushed in " + city$(armyloc(defend))
	CALL scribe(a$, 2)
	index = lose: GOTO crushed
END IF

'==========================================================================
'                       Attacker Loses
'==========================================================================
IF win = active GOTO kickbutt
armymove(active) = armyloc(active)
armyloc(active) = target
COLOR 11: CALL clrbot: PRINT armyname$(active); " withdraws to "; city$(armymove(active));

CALL animate(active, 1)

armyloc(active) = armymove(active)
CALL placearmy(active)
occupied(armyloc(active)) = active
armymove(active) = -2
	      
IF 11 * RND > armylead(defend) THEN CALL icon(armyloc(defend), armymove(defend), 4): IF armymove(defend) > 0 THEN armymove(defend) = -2

CALL TICK(turbo!): GOTO digin
'==========================================================================
'                       Defender Retreats
'==========================================================================
kickbutt:
	CALL icon(armyloc(active), target, 4)
	IF armymove(defend) > 0 THEN CALL icon(target, armymove(defend), 4)

	CALL retreat(defend, flee): IF flee > 0 THEN move2 = flee: GOTO outta

	best = 0: flee = 0
	FOR i = 1 TO 6
	x = matrix(target, i)
	IF x > 0 AND (cityp(x) = 3 - s) AND cityv(x) > best THEN
		IF best = 0 THEN
			flee = i: best = cityv(x)
		ELSE
			IF occupied(x) = 0 THEN flee = i: best = cityv(x)
		END IF
	END IF
	NEXT i
	IF flee = 0 GOTO deadmeat
	move2 = matrix(target, flee)
outta:
	CALL placearmy(defend)                  ' in old city

	armymove(defend) = move2
	CALL animate(defend, 0)                 ' animate retreat
       
	armyloc(defend) = move2
	occupied(move2) = defend
	CALL clrbot
	PRINT armyname$(defend) + " is withdrawing to " + city$(move2);

	CALL placearmy(defend)                  ' in new city
       
	CALL icon(target, 0, 6)
	armymove(defend) = -2
	GOTO holdon

deadmeat:
	index = defend
	z = 1: IF index > 25 THEN z = 2
	a$ = force$(z) + " " + armyname$(index) + " surrenders to " + armyname$(active) + " in " + city$(armyloc(index))
	CALL scribe(a$, 2)
crushed:
	IF noise > 1 AND s <> side THEN PLAY "MFMST220o3g8g8g8o4c2"
	IF armymove(index) > 0 THEN CALL icon(armyloc(index), armymove(index), 4)
	x = 15: IF s = side THEN x = -15
	CALL enter(s)
	victory(3 - s) = victory(3 - s) + 25
	IF index > 1 THEN
surr:
		x = cityx(target) - 12: y = cityy(target) - 11
		CALL cityicon(target)
		FOR k = 0 TO 7
			LINE (x - 7, y - 7)-(x + 9, y + 4), 2, BF
			LINE (x + k - 7, y + k - 7)-(x - k + 8, y - k + 5), 5, BF
			CALL TICK(.15)
		NEXT k
		LINE (x - 7, y - 7)-(x + 9, y + 4), 2, BF
		LINE (x + 8, y - 2)-(x + 8, y + 5), 0
		CIRCLE (x + 1, y - 2), 8, 15, , , .4
		LINE (x - 7, y)-(x + 8, y + 5), 15, BF
		PAINT (x, y - 2), 15
		PSET (x - 6, y + 4), 15
		DRAW "c0S4" + font$(18) + "BR2" + font$(9) + "BR2" + font$(16)
		CALL TICK(1)
		armyloc(index) = 0: lname$(index) = "": armyname$(index) = ""
		armysize(index) = 0: armylead(index) = 0
		armyexper(index) = 0: armymove(index) = 0: supply(index) = 0
		supply(active) = supply(active) + supply(index): supply(index) = 0
		IF supply(active) > 10 THEN supply(active) = 10
	ELSE
		IF occupied(16) = 0 THEN
			n = 16: IF player = 1 AND side = 2 THEN rescue = n
		ELSE
			IF n = 0 THEN CALL image2("Napoleon banished to St. Helena", 1): GOTO surr
		END IF
		IF n = 0 THEN CALL image2("Napoleon banished to St. Helena", 1): GOTO surr
		armyloc(1) = n: armysize(1) = 10: cityp(n) = 1: occupied(n) = 1
		CALL image2("Napoleon removed to " + city$(n), 3)
		victory(1) = victory(1) / 2
		FOR k = 1 TO 25: armysize(k) = armysize(k) / 2: NEXT k
		CALL placearmy(1)
		CALL enter(-25)
		IF active = 1 GOTO digin
	END IF
	CALL TICK(9)
	IF armyloc(active) = 0 GOTO digin
'---------------------------------------------------------------------------
'                       check for more defenders !
'---------------------------------------------------------------------------
holdon:
	CALL occupy(target): IF occupied(target) = 0 GOTO easy
	CALL bossarmy
	COLOR 11: CALL clrbot: PRINT "There are still defenders in "; city$(target); : CALL TICK(99)
	GOTO enemy
'==========================================================================
'                       Move Into New City
'==========================================================================
easy:
armyloc(active) = target: armymove(active) = -2
CALL occupy(armyloc(active))
CALL placearmy(active)
'---------------------------------------------------------------------------
'                            City Capture
'---------------------------------------------------------------------------
	IF cityp(armyloc(active)) = s GOTO horde
	c = armyloc(active)
	IF player = 1 AND s = side AND fort(c) > 0 AND flag = 0 THEN
		tlx = 67: tly = 15
		hilite = 15: colour = 3
		mtx$(0) = "Raze ?"
		mtx$(1) = "No"
		mtx$(2) = "Yes"
		size = 2
		CALL menu(0)
		IF choose = 2 GOTO smoke
	END IF
	IF player = 1 AND s <> side AND fort(c) > 0 AND flag = 0 THEN
		IF cityy(c) > 150 THEN
smoke:
			fort(c) = 0
			x = cityx(c)
			y = cityy(c)
			LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
			CALL showcities
			CALL clrbot
			PRINT armyname$(active); " has destroyed the forts at "; city$(c);
			TICK 3
		END IF
	END IF
	CALL capture(active, c, s, flag)
horde:
IF supply(active) < 10 THEN supply(active) = supply(active) + 1: IF RND > .8 GOTO horde
digin:
NEXT j
GOTO allthru

upbox:
LINE (525, 90)-(630, 305), 2, BF
COLOR 14: LOCATE 12, 67: PRINT "ÉÍÍÍÍÍÍÍÍÍÍ»"
LOCATE 13, 67: PRINT "º  UPDATE  º"
LOCATE 14, 67: PRINT "ÈÍÍÍÍÍÍÍÍÍÍ¼"
RETURN

allthru:
CALL image2("Game will end in " + month$(vicflag(1)) + STR$(ABS(vicflag(2))), 5)
IF navysize(commerce) < 1 THEN commerce = 0
IF commerce > 0 THEN
	CALL clrbot
	IF RND < .8 + .02 * navysize(commerce) THEN
		raider = .05 * navysize(commerce) * (1 + RND) * (income(3 - commerce))
		IF raider < 1 THEN raider = 1
		IF raider / income(3 - commerce) > .4 THEN raider = (.3 + .1 * RND) * income(3 - commerce)
		COLOR 15: PRINT force$(commerce); " raiders have sunk $"; raider; " of "; force$(3 - commerce); " commerce";
		COLOR 14: LOCATE 26, 14: PRINT "$$"
		IF noise > 1 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
		IF commerce = side THEN grudge = 1
		TICK 9
		LINE (100, 400)-(120, 415), 3, BF
	ELSE
		raider = 0
		CALL barnacle(commerce)
		COLOR 15: PRINT force$(commerce); " raiders have lost a ship ("; navysize(commerce); " remain)";
		IF noise > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
		IF navyloc(commerce) > 0 THEN
			TICK 9
			GOTO allthru
		ELSE
			commerce = 0
			LINE (120, 400)-(160, 420), 3, BF
			FOR k = 1 TO 3: CIRCLE (140, 410), 3 * k, 11: NEXT k
			TICK 9
			LINE (120, 400)-(160, 420), 3, BF
			CALL ships
		END IF
	END IF
END IF

CALL ships: CALL iterate

CALL clrbot
CALL calendar
IF control(1) > 40 THEN victory(1) = victory(1) + 5: IF control(1) > 50 THEN victory(1) = victory(1) + 10
IF side = 2 AND control(1) < 11 THEN aggress! = aggress! + .7

IF victory(1) < 1 THEN victory(1) = 0
IF control(2) > 40 THEN victory(2) = victory(2) + 5: IF control(2) > 50 THEN victory(2) = victory(1) + 10
IF side = 1 AND control(2) < 11 THEN aggress! = aggress! + .7
FOR k = 1 TO 2: CALL stax(k): NEXT k
IF player = 2 THEN CALL clrbot: COLOR 14: PRINT "press a key"; : CALL TICK(9)
END SUB
