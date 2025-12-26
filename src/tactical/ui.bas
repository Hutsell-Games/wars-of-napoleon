'============================================================================
' Tactical UI Module
'============================================================================
' User interface functions for tactical battle
' Includes: help, icon loading, unit inspection, menus, reports, refresh,
' map display, buttons, and display utilities
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Global Type Declarations
'============================================================================
' DEFINT A-Z: All variables default to INTEGER type unless explicitly declared
' This applies to this file and all files included after it
DEFINT A-Z

'============================================================================
' Help System
'============================================================================

'============================================================================
' Help - Display help screen
'============================================================================
' Description:
'   Displays a comprehensive help screen showing unit icons, terrain types,
'   movement costs, defense bonuses, and hot keys.
'============================================================================
SUB help
SCREEN 9, , 1, 1
CLS
LINE (1, 321)-(639, 336), 3, BF
COLOR 11: LOCATE 24, 35: PRINT " press any key ";
COLOR 15: LOCATE 1, 1
PRINT "ICON  Unit Type"
a$ = "I" + CHR$(219) + "CGALSwR": unitx(0) = 1: strength(0) = 1
FOR k = 1 TO 9
unity(0) = k: Visible(0) = 1
unit$(0) = MID$(a$, k, 1): CALL SHOWUNIT(0)
COLOR 3: LOCATE k + 1, 6
	SELECT CASE k
	CASE 1
	PRINT "Infantry"
	CASE 2
	PRINT "Charging Infantry"
	CASE 3
	PRINT "Cavalry"
	CASE 4
	PRINT "General"
	CASE 5
	PRINT "Smooth Bore Cannon"
	CASE 6
	PRINT "Limbered Artillery"
	CASE 7
	PRINT "Hollow Square"
	CASE 8
	PRINT "WAITING Unit"
	CASE 9
	PRINT "ROUTED Unit"
	CASE ELSE
	END SELECT
NEXT k
LOCATE 1, 40: COLOR 15: PRINT "ICON Terrain ";
COLOR 4: PRINT "Move Turns ";
COLOR 2: PRINT "Defend Bonus"
x = 320
PUT (x, 14), Tterr, PSET
PUT (x, 28), Fterr, PSET
PUT (x, 42), Rterr, PSET
PUT (x, 56), Cterr, PSET
PUT (x, 70), Sterr, PSET
PUT (x, 84), Bridge, PSET
PUT (x, 98), Hterr, PSET
PUT (x, 112), Wterr, PSET
PUT (x, 126), Oterr, PSET
PUT (x, 140), Mterr, PSET
PUT (x, 154), Vterr, PSET
COLOR 3
a$ = "Trees Fort Road Clear Swamp Bridge Hill Water OBJCTV Mtn Village "

FOR k = 1 TO 11
x = INSTR(a$, " ")
t$ = LEFT$(a$, x - 1)
a$ = MID$(a$, x + 1)
LOCATE k + 1, 45: PRINT t$
NEXT k
COLOR 14
LOCATE 2, 57: PRINT "3 	  +5%" '*
LOCATE 3, 57: PRINT "2 	  +10%"'#
LOCATE 4, 57: PRINT "1 	   0"  '+
LOCATE 5, 57: PRINT "2 	   0"  '.
LOCATE 6, 57: PRINT "6 	  -5%" '=
LOCATE 7, 57: PRINT "1 	   0"  '[
LOCATE 8, 57: PRINT "4 	  +6%" '^
LOCATE 9, 56: PRINT "10 	 -15%"
LOCATE 10, 57: PRINT "2 	   0"
LOCATE 11, 57: PRINT "8 	  +9%"
LOCATE 12, 57: PRINT "2 	  +3%"
COLOR 4: LOCATE 4, 70: PRINT "*": LOCATE 5, 70: PRINT "*"
LOCATE 13, 45: PRINT "* Defend is -15% vs. Attack Cav"
LINE (420, 14)-(480, 168), 4, B
LINE (510, 14)-(580, 168), 2, B
COLOR 15: LOCATE 14, 2: PRINT "HOT KEYS": COLOR 3
LINE (1, 180)-(639, 195), 4, B
PRINT "  ire (ARTILLERY)"
PRINT "  imber/Unlimber (ARTILLERY)"
PRINT " i spire unit (GENERAL)"
PRINT "   cancel unit orders (GENERAL)"
PRINT "  harge (INFANTRY)"
PRINT "  quare Form/Unform (INFANTRY)"
PRINT "  ntelligence"
PRINT "  ove to destination"

LOCATE 21, 41: PRINT "iew Line of Sight"
LOCATE 22, 41: PRINT "ait Unit";

LOCATE 15, 41: PRINT "AME SCORE"
LOCATE 16, 41: PRINT "RDER OF BATTLE"
LOCATE 17, 41: PRINT "UIET SOUND TOGGLE"
COLOR 14
LOCATE 15, 1: PRINT " F": PRINT " L": LOCATE 17, 3: PRINT "N"
PRINT " X": PRINT " C": PRINT " S": PRINT " I": PRINT " M"
LOCATE 21, 40: PRINT "V": LOCATE 22, 40: PRINT "W"
COLOR 10: LOCATE 15, 40: PRINT "G": LOCATE 16, 40: PRINT "O"
LOCATE 17, 40: PRINT "Q"
LINE (0, 280)-(500, 310), 14, B, &H101
COLOR 14: LOCATE 22, 65: PRINT "(all units)"

TICK 99: strength(0) = 0: Visible(0) = 0
SCREEN 9, , 0, 0
TICK .5
END SUB

'============================================================================
' Icon Loading
'============================================================================

'============================================================================
' Iconload - Load unit and terrain icons
'============================================================================
' Description:
'   Loads all unit icons (infantry, cavalry, artillery, generals) and terrain
'   icons (trees, hills, water, etc.) from EGA files. Extracts sprites from
'   loaded images.
'============================================================================
SUB iconload
SCREEN 9
LOCATE 1, 1: COLOR 11: PRINT "Loading Icons"
'----------------------------------------------------------------------------
'                            UNIT Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "stdicon.ega", Image(1)

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), IAlly
	GET (101, 115)-(116, 128), CAlly
	GET (101, 129)-(116, 142), AAlly
	GET (101, 143)-(116, 156), GAlly
       
	GET (117, 101)-(132, 114), IFrench
	GET (117, 115)-(132, 128), CFrench
	GET (117, 129)-(132, 142), AFrench
	GET (117, 143)-(132, 156), GFrench
'----------------------------------------------------------------------------
'                            UNIT Icons..... ALTICON
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "alticon.ega", Image(1)

	PUT (100, 100), Image, PSET
	GET (101, 101)-(116, 114), LAAlly
	GET (101, 115)-(116, 128), HSFrench
	GET (101, 129)-(116, 142), WFrench
	GET (101, 143)-(116, 156), RAlly

	GET (117, 101)-(132, 114), LAFrench
	GET (117, 115)-(132, 128), HSAlly
	GET (117, 129)-(132, 142), Wally
	GET (117, 143)-(132, 156), RFrench
'----------------------------------------------------------------------------
'                            Terrain Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "terrain.ega", Image(1)
	PUT (200, 100), Image, PSET
	GET (200, 101)-(215, 114), Cterr
	GET (200, 115)-(215, 128), Hterr
	GET (200, 129)-(215, 142), Sterr
	GET (200, 143)-(215, 156), Fterr
	GET (217, 101)-(232, 114), Tterr
	GET (217, 115)-(232, 128), Mterr
	GET (217, 129)-(232, 142), Oterr
	GET (217, 143)-(232, 156), Rterr
'----------------------------------------------------------------------------
'                         Miscellaneous Icons
'----------------------------------------------------------------------------
	' QB64-compatible BLOAD - works directly with arrays
	BLOAD "misc.ega", Image(1)
	PUT (300, 100), Image, PSET
	GET (300, 101)-(315, 114), Wterr
	GET (300, 115)-(315, 128), Vterr
	GET (300, 129)-(315, 142), Explo
	GET (300, 143)-(315, 156), Bridge
	GET (317, 101)-(332, 114), Xhair
	GET (317, 115)-(332, 128), Death
	GET (317, 129)-(332, 142), Boat
END SUB

'============================================================================
' Unit Inspection and Display
'============================================================================

'============================================================================
' Inspect - Display unit information
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
' Description:
'   Displays detailed unit information including name, type, strength,
'   morale, leadership, experience, terrain, and remaining moves.
'============================================================================
SUB inspect (index)
	IF index < 1 THEN EXIT SUB
	CALL kleer
	c = 4: IF index > 40 THEN c = 9
	COLOR c
	CALL YouorMe(index, F)
	IF F = 0 THEN LOCATE 12, 67: COLOR 11: PRINT sname$(3 - side)
	IF recon = 1 THEN F = 1
	LOCATE 12, 58: PRINT "Unit "; index;
	COLOR c: LOCATE 13, 58: PRINT name$(index)
	LOCATE 14, 58: PRINT unit$(index)

	CALL valid(index)
	x = strength(index): IF F = 0 THEN x = INT(strength(index) / 100 - 2 + 4 * RND) * 100: IF x < 10 THEN x = 50
	COLOR c: IF F = 1 AND strength(index) < 200 THEN COLOR 5: IF strength(index) < 100 THEN COLOR 12
	LOCATE 15, 58: PRINT "Strength:" + STR$(x)
	COLOR c
	IF morale(index) < 2 THEN COLOR 6: IF morale(index) = 1 THEN COLOR 13
	IF F > 0 THEN LOCATE 16, 58: PRINT "Morale : "; morlev$(morale(index))
	COLOR c
	IF leader(index) < 2 THEN COLOR 6: IF leader(index) = 1 THEN COLOR 13
	IF F > 0 THEN LOCATE 17, 58: PRINT "Leader : "; ledlev$(leader(index))
	COLOR c
	IF xper(index) < 2 THEN COLOR 6: IF xper(index) = 1 THEN COLOR 13
	LOCATE 18, 58: PRINT "Exper  : "; xplev$(xper(index))

	LOCATE 19, 58: PRINT "Terr: ": CALL Tara(62, 19, terrain(index))
	LOCATE 19, 67: PRINT "Moves :"; RTRIM$(STR$(movesleft))
	LINE (453, 152)-(631, 267), 4, B
END SUB

'============================================================================
' Show Unit Stats - Display unit stats for report
'============================================================================
' Parameters:
'   id (INTEGER) - Unit index
'   dx (INTEGER) - Display mode flag
' Description:
'   Displays unit statistics. Shows target if unit has movement orders.
'============================================================================
SUB ShowUnitStats (id AS INTEGER, dx AS INTEGER)
	DIM F AS INTEGER
	CALL inspect(id)
	CALL YouorMe(id, F): IF F > 0 THEN IF uorder(id) > 99 AND dx <> 4 THEN CALL target(id): CALL ShowIntelligenceLine
END SUB

'============================================================================
' Display Utilities
'============================================================================

'============================================================================
' Kleer - Clear unit info panel
'============================================================================
' Description:
'   Clears the unit information display panel.
'============================================================================
SUB kleer
LINE (454, 153)-(630, 266), 0, BF
END SUB

'============================================================================
' LITEUP - Highlight unit location
'============================================================================
' Parameters:
'   x0, y0 (INTEGER) - Screen coordinates
'   c (INTEGER) - Color
' Description:
'   Draws a highlight box around a unit location.
'============================================================================
SUB LITEUP (x0, y0, c)
LINE (x0, y0)-(x0 + 14, y0 + 13), c, B
LINE (x0 + 1, y0 + 1)-(x0 + 13, y0 + 12), c, B
END SUB

'============================================================================
' BUTTON - Draw button
'============================================================================
' Parameters:
'   x, y (INTEGER) - Button position
'   c (INTEGER) - Button color
'   a$ (STRING) - Button text
'   z (INTEGER) - Button state (0=normal, 1=depressed)
' Description:
'   Draws a button at the specified location with text. Can be in normal
'   or depressed state.
'============================================================================
SUB BUTTON (x, y, c, a$, z)
	DIM flag AS INTEGER
	IF z < 0 THEN flag = 1: z = ABS(z)
	
	' Draw button (depress label logic)
	DO
		a$ = UCASE$(a$)
		xc = 8 * (x - 1) - 4: yc = 14 * (y - 1) - 2
		a = LEN(a$) * 8
		LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), 0, BF
		LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), c, B
		COLOR c: LOCATE y, x: PRINT a$;
		IF z = 0 THEN EXIT DO
		' Depressed button - shift position
		xc = xc + 1: yc = yc + 1
		LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), 0, BF
		LINE (xc + 1, yc + 1)-(xc + a + 6, yc + 16), c, B
		COLOR c: LOCATE y, x: PRINT a$;
		IF flag = 1 THEN z = 0
		EXIT DO
	LOOP
END SUB

'============================================================================
' Clrbot - Clear bottom message area
'============================================================================
' Description:
'   Clears the bottom message/status line area.
'============================================================================
SUB clrbot
LINE (4, 334)-(639, 349), 0, BF
END SUB

'============================================================================
' Map Display
'============================================================================

'============================================================================
' Mainmap - Display main battle map
'============================================================================
' Description:
'   Displays the main tactical battle map with terrain, objectives, and
'   interface elements. Initializes map display and draws borders.
'============================================================================
SUB mainmap
COLOR 2, 0: SCREEN 9: CLS
count = 0
LINE (10, 0)-(639, 300), 8, BF
x = INSTR(SCENARIO$, "|"): IF x > 0 THEN SCENARIO$ = LEFT$(SCENARIO$, x - 1)
IF LEN(SCENARIO$) > 55 THEN SCENARIO$ = LEFT$(SCENARIO$, 55)
COLOR 15: x = 55 - LEN(SCENARIO$): x = .5 * x + 1: LOCATE 1, x: PRINT SCENARIO$
FOR k = 2 TO 21
	s = 2: IF INT(.5 * k) * 2 = k THEN s = 1
	FOR j = s TO 54 STEP 2
	CALL Tara(j, k, 0)
	NEXT j
	x = INSTR(sdtext$(k), CHR$(219)): IF x > 0 THEN objx = x: objy = k - 1: count = count + 1
NEXT k
	CALL scrcol(0)
	' Draw border (dork2 section)
	IF count = 1 THEN
		' Single objective found
	ELSE
		' Multiple objectives or none
	END IF
	LINE (10, 0)-(639, 300), 4, B
	CALL BUTTON(58, 1, 4, "F1:HELP", 0)
	CALL BUTTON(71, 1, 4, "F3:REDRAW", 0)
END SUB

'============================================================================
' Refresh - Refresh unit display
'============================================================================
' Description:
'   Refreshes the display of all units on the map. Shows friendly units
'   always, enemy units only if visible. Handles recon mode.
'============================================================================
SUB refresh
	FOR k = 1 TO bigg(2)
		IF uorder(k) = 99 THEN
			' Hidden unit, skip
		ELSEIF recon = 1 THEN
			' Recon mode - show all
			IF strength(k) > 0 THEN CALL SHOWUNIT(k)
		ELSE
			CALL YouorMe(k, F)
			IF F > 0 THEN
				' Friendly unit - always visible
				Visible(k) = 1
				IF strength(k) > 0 THEN CALL SHOWUNIT(k)
			ELSEIF Visible(k) > 0 THEN
				' Enemy unit that was visible
				IF strength(k) > 0 THEN CALL SHOWUNIT(k)
			ELSE
				' Enemy unit not visible - show terrain
				IF strength(k) > 0 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
			END IF
		END IF
	NEXT k
END SUB

'============================================================================
' Reports and Status
'============================================================================

'============================================================================
' Report - Display order of battle report
'============================================================================
' Description:
'   Displays a comprehensive order of battle report showing all units,
'   their strengths, types, morale, leadership, and experience. Handles
'   visibility and pagination.
'============================================================================
SUB report
COLOR 11: CLS : flag = 0
total& = 0
COLOR 4
PRINT sname$(1); " Forces"
mtx$(0) = "Unit #   Name        Strength  Type        Morale    Leadership Experience"
mtx$(1) = "Units    " + sname$(1) + " Forces:"
PRINT mtx$(0)
COLOR 11
total& = 0: FOR k = 1 TO bigg(1): total& = total& + strength(k): NEXT k
t = 0
FOR k = 1 TO bigg(1)
	DIM a$ AS STRING
	DIM B$ AS STRING
	DIM c$ AS STRING
	CALL FormatUnitStats(k, a$, B$, c$)
	IF side = 2 AND Visible(k) = 0 THEN
		' Hidden from side 2, skip
	ELSEIF uorder(k) = 99 THEN
		' Hidden unit, skip
	ELSE
	t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
		IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
		IF t >= 20 AND flag = 0 THEN
			COLOR 4
			PRINT bigg(1); mtx$(1); total&
			CALL WaitForKey: CLS
			flag = 1
			COLOR 11
		END IF
	END IF
	NEXT k
COLOR 4
PRINT bigg(1); mtx$(1); total&: CALL WaitForKey: CLS

total& = 0: FOR k = m2 TO bigg(2): total& = total& + strength(k): NEXT k
COLOR 9: PRINT sname$(2); " Forces"
PRINT mtx$(0)
mtx$(1) = "Units    " + sname$(2) + " Forces:"
t = 0
COLOR 11
FOR k = m2 TO bigg(2)
	DIM a$ AS STRING
	DIM B$ AS STRING
	DIM c$ AS STRING
	CALL FormatUnitStats(k, a$, B$, c$)
		IF side = 1 AND Visible(k) = 0 THEN
			' Hidden from side 1, skip
		ELSEIF uorder(k) = 99 THEN
			' Hidden unit, skip
		ELSE
			t$ = unit$(k): IF LEN(unit$(k)) > 9 THEN t$ = LEFT$(unit$(k), 9)
			IF strength(k) > 0 THEN PRINT k; TAB(9); name$(k); TAB(24); a; TAB(32); t$; TAB(44); a$; TAB(54); B$; TAB(65); c$: t = t + 1
			IF t >= 20 AND flag = 0 THEN
				COLOR 9
				PRINT bigg(2) - m1; mtx$(1); total&: CALL WaitForKey: CLS
				PRINT sname$(2); " Forces"
				PRINT mtx$(0)
				flag = 1
				COLOR 11
			END IF
		END IF
	NEXT k
	COLOR 9
	PRINT bigg(2) - m1; mtx$(1); total&: CALL WaitForKey
	
	' Return to main map (runner section)
	CLS
	CALL mainmap
	CALL refresh
END SUB

'============================================================================
' Format Unit Stats - Format unit stats for report
'============================================================================
' Parameters:
'   k (INTEGER) - Unit index
'   a$, B$, c$ (STRING) - Output formatted strings (modified by reference)
' Description:
'   Formats unit statistics for display in reports. Shows actual stats for
'   friendly units, estimated stats for enemy units.
'============================================================================
SUB FormatUnitStats (k AS INTEGER, a$ AS STRING, B$ AS STRING, c$ AS STRING)
	CALL valid(k)
	CALL YouorMe(k, F)
	IF F = 1 THEN
		' Friendly unit - show actual stats
		a = strength(k)
		a$ = morlev$(morale(k))
		B$ = ledlev$(leader(k))
		c$ = xplev$(xper(k))
	ELSE
		' Enemy unit - show estimated stats
		a = .7 * strength(k) + .6 * RND * strength(k)
		IF RND > .7 THEN a$ = "?": IF RND > .5 THEN a$ = "Fearless"
		IF RND > .7 THEN B$ = "?": IF RND > .5 THEN B$ = "Brilliant"
		IF RND > .7 THEN c$ = "?": IF RND > .5 THEN c$ = "Elite"
	END IF
END SUB

'============================================================================
' Wait For Key - Wait for keypress
'============================================================================
' Description:
'   Waits for user to press a key before continuing.
'============================================================================
SUB WaitForKey
	LOCATE 24, 1: PRINT "hit a key";
	DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
' Status Display
'============================================================================

'============================================================================
' Scrcol - Update status column display
'============================================================================
' Parameters:
'   flag (INTEGER) - Display mode (0=full draw, 1=menu clear, 2+=update info only)
' Description:
'   Updates the status column on the right side of the screen showing
'   side information, losses, objective control, and time remaining.
'============================================================================
SUB scrcol (flag)            '0=full draw  1=menu clear   2 or more =update info only
IF flag = 1 THEN LINE (454, 30)-(631, 152), 8, BF
IF flag < 2 THEN
	LINE (453, 153)-(630, 266), 4, B
	LINE (449, 2)-(449, 299), 4, B
	LINE (453, 13)-(631, 28), 4, B
	LINE (454, 14)-(630, 27), 0, BF
	LINE (454, 40)-(631, 86), 9, B
	LINE (455, 41)-(630, 85), 0, BF

	COLOR 9: LOCATE 4, 65: PRINT " "; UCASE$(sname$(2)): IF side = 2 THEN LOCATE 4, 60: PRINT CHR$(16)
	LOCATE 5, 59: PRINT "LOSSES     :"; score&(2)
	COLOR 14: LOCATE 6, 62: IF possess = 2 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 9
     
	LINE (454, 95)-(631, 141), 7, B
	LINE (455, 96)-(630, 140), 0, BF
	COLOR 4: LOCATE 8, 65: PRINT " "; UCASE$(sname$(1)): IF side = 1 THEN LOCATE 8, 60: PRINT CHR$(16)
	LOCATE 9, 59: PRINT "LOSSES     :"; score&(1)
	COLOR 14: LOCATE 10, 62: IF possess = 1 THEN PRINT "HOLDS OBJECTIVE" ELSE PRINT SPACE$(17)
	COLOR 4: LOCATE 2, 59: PRINT "Time Left :";
	CALL UpdateTimeDisplay(flag)
ELSEIF flag > 10 THEN CALL UpdateTimeDisplay(flag): EXIT SUB
	COLOR 9
	IF side = 2 THEN LOCATE 4, 60: PRINT CHR$(16)
	LOCATE 5, 71: PRINT score&(2)
	COLOR 4
	IF side = 1 THEN LOCATE 8, 60: PRINT CHR$(16)
	LOCATE 9, 71: PRINT score&(1)
	COLOR 14
	CALL UpdateTimeDisplay(flag)
END IF
END SUB

'============================================================================
' Update Time Display - Update time remaining display
'============================================================================
' Parameters:
'   flag (INTEGER) - Display mode
' Description:
'   Updates the time remaining display. Changes color if time is running low.
'============================================================================
SUB UpdateTimeDisplay (flag AS INTEGER)
	IF flag = 0 OR flag = 12 THEN CALL BUTTON(58, 21, 4, "QUIET", 1 - quiet)
	IF timex = 32767 THEN EXIT SUB
	COLOR 15: IF timelimit - timex < 21 THEN COLOR 12: IF bold < 4 THEN bold = 4
	LOCATE 2, 70: PRINT timelimit - timex
END SUB

'============================================================================
' Show Intelligence Line - Display intelligence mode message
'============================================================================
' Description:
'   Displays message for intelligence mode, prompting user to move cursor
'   over units to see information.
'============================================================================
SUB ShowIntelligenceLine
	COLOR 11: clrbot: PRINT "INTELLIGENCE: move cursor over units"; : COLOR 15: PRINT "  (ESC when done) ";
	LOCATE 23, 61: COLOR 11: PRINT "Range :";
END SUB

'============================================================================
' Menu System
'============================================================================

'============================================================================
' Menu - Display menu and get selection
'============================================================================
' Description:
'   Displays a menu with options and allows user to select one using arrow
'   keys or first letter. Returns selection in choose variable.
'============================================================================
SUB menu
	PCOPY 0, 1
	SCREEN 9, , 1, 1
	IF colour = 0 THEN colour = 7
	LOCATE 1, 1, 0
	IF mtx$(0) = "" THEN mtx$(0) = "M E N U"

	IF wide = 0 THEN CALL CalculateMenuWidth(wide, ndx, size)
	IF tlx = 0 THEN CALL AdjustMenuPosition(tlx, wide)
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

	' Menu selection loop (sel1 section)
	DO
		COLOR hilite
		LOCATE tly + 2 + row, tlx + 2: PRINT mtx$(row)
		CALL GetMenuKey(a$, row, row1, size, choose)
		IF ASC(a$) = 13 THEN
			' Enter pressed - selection made (called section)
			EXIT DO
		END IF
		COLOR colour
		LOCATE tly + 2 + row1, tlx + 2: PRINT mtx$(row1)
		choose = row
	LOOP

	SCREEN 9, , 0, 0
END SUB

'============================================================================
' Get Menu Key - Process menu key input
'============================================================================
' Parameters:
'   a$ (STRING) - Input key (modified by reference)
'   row, row1 (INTEGER) - Current and previous row (modified by reference)
'   size (INTEGER) - Number of menu items
'   choose (INTEGER) - Selected item (modified by reference)
' Description:
'   Processes keyboard input for menu navigation. Handles arrow keys,
'   letter keys, Enter, Escape, and Space.
'============================================================================
SUB GetMenuKey (a$ AS STRING, row AS INTEGER, row1 AS INTEGER, size AS INTEGER, choose AS INTEGER)
	DIM k AS INTEGER
	DIM c1$ AS STRING
	DIM c2$ AS STRING
	
	DO: a$ = INKEY$: LOOP WHILE a$ = ""
	IF ASC(a$) = 32 THEN choose = 99: EXIT SUB
	IF ASC(a$) = 13 THEN EXIT SUB
	IF LEN(a$) = 2 THEN
		' Arrow key handling (arrows section)
		c1$ = MID$(a$, 2, 1)
		IF ASC(c1$) = 72 THEN
			' Up arrow
			row = row - 1: IF row < 1 THEN row = size
		ELSEIF ASC(c1$) = 80 THEN
			' Down arrow
			row = row + 1: IF row > size THEN row = 1
		END IF
		choose = row
		EXIT SUB
	END IF
	IF ASC(a$) = 27 THEN choose = -1: EXIT SUB
		row1 = row
		FOR k = 1 TO size
		c1$ = UCASE$(a$)
		c2$ = UCASE$(LEFT$(mtx$(k), 1))
		IF c1$ = c2$ THEN row = k: choose = row: CALL LimitRow(row, size): EXIT SUB
		NEXT k
	CALL GetMenuKey(a$, row, row1, size, choose)
	EXIT SUB
END SUB

'============================================================================
' Limit Row - Limit row to valid range
'============================================================================
' Parameters:
'   row (INTEGER) - Row number (modified by reference)
'   size (INTEGER) - Maximum row number
' Description:
'   Ensures row is within valid range for menu.
'============================================================================
SUB LimitRow (row AS INTEGER, size AS INTEGER)
	IF row > size THEN row = 1
	IF row < 1 THEN row = size
END SUB

'============================================================================
' Calculate Menu Width - Calculate menu width
'============================================================================
' Parameters:
'   wide (INTEGER) - Menu width (modified by reference)
'   ndx (INTEGER) - Index of widest item (modified by reference)
'   size (INTEGER) - Number of menu items
' Description:
'   Calculates the width needed for the menu based on item text lengths.
'============================================================================
SUB CalculateMenuWidth (wide AS INTEGER, ndx AS INTEGER, size AS INTEGER)
	DIM i AS INTEGER
	DIM l AS INTEGER
	
	wide = LEN(mtx$(0)) + 3
     
	ndx = 0
	FOR i = 1 TO size
	l = LEN(mtx$(i))
	IF l > wide THEN wide = l: ndx = i
	NEXT i
END SUB

'============================================================================
' Adjust Menu Position - Calculate menu position
'============================================================================
' Parameters:
'   tlx (INTEGER) - Menu X position (modified by reference)
'   wide (INTEGER) - Menu width
' Description:
'   Calculates the X position for centering the menu.
'============================================================================
SUB AdjustMenuPosition (tlx AS INTEGER, wide AS INTEGER)
	IF tlx = 0 THEN tlx = INT(39 - .5 * wide)
END SUB

'============================================================================
' Visual Effects and Dialogs
'============================================================================

' Highlights a unit with a colored box to draw attention
' Parameters:
'   index - Unit index to highlight
'   c - Color code for the highlight box
SUB ATTENTION (index, c)
	y = 14 * unity(index): x = 8 * unitx(index)
	LINE (x, y)-(x + 15, y + 13), c, BF: TICK .05
	CALL SHOWUNIT(index): TICK .05
END SUB

' Displays the game expiration screen showing scenario status
' Shows player info, difficulty, losses, and esprit de corps
SUB expire
	x = 0: IF possess = side THEN x = 10 * difficult
	'---------------------------------------------------------------------------
	COLOR 11
	CLS
	PRINT "Scenario :"; SCENARIO$
	PRINT "Player   :";
	COLOR 15: IF side = 2 THEN COLOR 9
	PRINT sname$(side)
	COLOR 15: PRINT "Attacker :";
	COLOR 4: IF sidex(1) = 2 THEN COLOR 9
	PRINT sname$(sidex(1)); TAB(20); "("; commander$(sidex(1)); ")"
	COLOR 15: PRINT "Defender :";
	COLOR 9: IF sidex(2) = 1 THEN COLOR 4
	PRINT sname$(sidex(2)); TAB(20); "("; commander$(sidex(2)); ")"
	COLOR 11
	PRINT "Difficulty :"; adj2$(difficult)
	PRINT "Visibility Range :"; seelimit
	PRINT "Enemy Aggressiveness :"; adj1$(bold)
	PRINT "Turns Left :"; timelimit - timex; "/"; timelimit
	LOCATE 10, 19: PRINT "Side"; TAB(31); "Losses"; TAB(40); "Esprit de Corps"
	COLOR 14: LOCATE 12, 40: PRINT STRING$(10, CHR$(219))
	COLOR 14: LOCATE 14, 40: PRINT STRING$(10, CHR$(219))
	FOR k = 1 TO 2
		IF elan(k) < 1 THEN elan(k) = 0
	NEXT k
	x = elan(sidex(2)) * .1
	a$ = STRING$(x, CHR$(219))
	COLOR 4: IF sidex(2) = 2 THEN COLOR 9
	LOCATE 14, 19: PRINT sname$(sidex(2)); TAB(30); score&(sidex(2)); TAB(40); a$
	IF elan(sidex(2)) < 30 THEN COLOR 15: LOCATE 14, 60: PRINT "BREAKING!"
	COLOR 4: IF sidex(1) = 2 THEN COLOR 9
	x = elan(sidex(1)) * .1
	a$ = STRING$(x, CHR$(219))
	LOCATE 12, 19: PRINT sname$(sidex(1)); TAB(30); score&(sidex(1)); TAB(40); a$
	IF elan(sidex(1)) < 30 THEN COLOR 15: LOCATE 12, 60: PRINT "BREAKING!"
	LINE (100, 150)-(450, 206), 3, B
	IF possess <> 0 THEN
		a$ = sname$(possess) + " SIDE IS WINNING!"
		COLOR 15: LOCATE 17, 33 - .5 * LEN(a$): PRINT a$
	END IF
	TICK 99
	IF timelimit - timex <= 0 THEN CALL over(3 - possess)
END SUB

' Displays a yes/no dialog and returns user's choice
' Parameters:
'   a$ - Prompt message (modified by reference, returns "Y" or "N")
SUB YesNo (a$)
	IF a$ <> "" THEN mtx$(0) = a$
	tly = 2: colour = 4
	tlx = 62 - .5 * LEN(mtx$(0))
	mtx$(1) = "No"
	mtx$(2) = "Yes"
	size = 2: CALL menu
	a$ = "N": IF choose = 2 THEN a$ = "Y"
END SUB

