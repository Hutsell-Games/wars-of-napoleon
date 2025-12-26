'============================================================================
' Tactical Unit Placement Module
'============================================================================
' Unit initialization and placement functions
' Includes: random army generation, unit placement, unit attribute initialization
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Random Army Generation
'============================================================================

'============================================================================
' Randarm - Generate random army for side
'============================================================================
' Parameters:
'   s (INTEGER) - Side number (1 or 2)
' Description:
'   Generates a random army for the specified side. Places units on the map,
'   initializes unit attributes, and sets up objectives if needed.
'============================================================================
SUB randarm (s)
who = sidex(s)
dx = 41: file$ = "data\french.dat": IF who = 1 THEN file$ = "data\allies.dat": dx = 1

COLOR 4: LOCATE 23, 1: PRINT "Placing armies ... "
CALL arrange(who, xloc, yloc)

LINE (455, 110)-(622, 140), 4, B
allarm = vp&(who) / unitsize&

FOR i = 1 TO allarm
	index = 40 * (who - 1) + i
	
	' Find valid placement for unit
	IF NOT FindValidUnitPlacement%(index, who, xloc, yloc) THEN
		' Could not find placement - skip this unit
		GOTO SkipUnitInit
	END IF
	
	' Initialize unit attributes
	CALL InitializeUnitAttributes(index, i, allarm, who, s, file$, dx)
	
	' Display and validate unit
	CALL SHOWUNIT(index)
	vp&(who) = vp&(who) - strength(index)
	
	' Check if we've used up all available strength
	IF vp&(who) < 0 THEN
		' Adjust last unit's strength to fit remaining points
		IF vp&(who) < strength(allarm) AND strength(allarm) > vp&(who) THEN
			strength(allarm) = strength(allarm) + vp&(who)
		END IF
		' Exit loop - no more units can be created
		EXIT FOR
	END IF
	
	CALL valid(index)
SkipUnitInit:
NEXT i

' Cleanup after unit creation loop
IF vp&(who) < strength(allarm) AND strength(allarm) > vp&(who) THEN strength(allarm) = strength(allarm) + vp&(who)

IF s = 2 THEN
	x = m2: x1 = 1: IF who = 1 THEN x1 = m2: x = 1
	SELECT CASE fort
		CASE 0
			xloc = .8 * unitx(x) + .2 * unitx(x1)
			yloc = .8 * unity(x) + .2 * unity(x1)
			IF INT(xloc + yloc) MOD 2 <> 0 THEN
				IF xloc < 54 THEN xloc = xloc + 1 ELSE xloc = xloc - 1
			END IF
		CASE 1, 2
			xloc = unitx(x)
			yloc = unity(x)
			possess = sidex(2)
	END SELECT
	IF (xloc + yloc) <> INT(.5 * (xloc + yloc)) * 2 THEN xloc = xloc + 1
	CALL replace(yloc, xloc, 233)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
	objx = xloc: objy = yloc
END IF
EXIT SUB
END SUB

'============================================================================
' Unit Placement Helper Functions
'============================================================================

' GOSUB xxyy converted to SUB
SUB CalculateXY (xx AS INTEGER, yy AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)
	xx = xloc: yy = yloc
	IF xx = 99 THEN xx = 1 + INT(54 * RND)
	IF yy = 99 THEN yy = 1 + INT(24 * RND)
END SUB

' GOSUB odd converted to SUB
SUB CheckOddHex (index AS INTEGER, flag AS INTEGER)
	flag = 0
	IF (unitx(index) + unity(index)) <> INT(.5 * (unitx(index) + unity(index))) * 2 THEN flag = 1
END SUB

'============================================================================
' Find Valid Unit Placement - Find placement location for unit
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
'   who (INTEGER) - Side (1 or 2)
'   xloc, yloc (INTEGER) - Base location coordinates (modified by reference)
' Returns:
'   INTEGER - 1 if valid location found, 0 if failed
' Description:
'   Finds a valid placement location for a unit near the base location.
'   Validates hex coordinates, checks for water/obstacles, and ensures no
'   enemy units are present.
'============================================================================
FUNCTION FindValidUnitPlacement% (index AS INTEGER, who AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)
	DIM spin AS INTEGER
	DIM xx AS INTEGER
	DIM yy AS INTEGER
	DIM flag AS INTEGER
	DIM z AS INTEGER
	DIM Enemy AS INTEGER
	
	spin = 0
	DO
		spin = spin + 1
		IF spin > 99 THEN
			' Too many retries - place unit at default location
			unitx(index) = 27: unity(index) = 11
			IF who = 2 THEN unitx(index) = 28: unity(index) = 12
			FindValidUnitPlacement% = 1
			EXIT FUNCTION
		END IF
		
		CALL CalculateXY(xx, yy, xloc, yloc)
		
		unitx(index) = xx - 10 + 20 * RND
		unity(index) = yy - 5 + 10 * RND
		IF unitx(index) < 2 THEN unitx(index) = 2
		IF unitx(index) > 54 THEN unitx(index) = 54
		IF unity(index) < 2 THEN unity(index) = 1
		IF unity(index) > 20 THEN unity(index) = 20
		
		' Adjust position to valid hex
		CALL CheckOddHex(index, flag)
		IF flag <> 0 THEN
			IF unitx(index) < 54 THEN
				unitx(index) = unitx(index) + 1
			ELSEIF unitx(index) > 2 THEN
				unitx(index) = unitx(index) - 1
			ELSEIF unity(index) < 20 THEN
				unity(index) = unity(index) + 1
			ELSEIF unity(index) > 1 THEN
				unity(index) = unity(index) - 1
			END IF
		END IF
		
		' Check if position is valid (not water/obstacle, no enemy unit)
		z = ASC(MID$(sdtext$((unity(index) + 1)), unitx(index), 1))
		IF z = 32 OR z = 176 THEN
			' Water or obstacle - retry
		ELSE
			CALL whois(unitx(index), unity(index), Enemy, index)
			IF Enemy > 0 THEN
				' Enemy unit present - retry
			ELSE
				' Valid position found
				FindValidUnitPlacement% = 1
				EXIT FUNCTION
			END IF
		END IF
	LOOP
	
	FindValidUnitPlacement% = 0
END FUNCTION

'============================================================================
' Initialize Unit Attributes - Initialize unit type, strength, and stats
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
'   i (INTEGER) - Unit number in army
'   allarm (INTEGER) - Total number of units in army
'   who (INTEGER) - Side (1 or 2)
'   s (INTEGER) - Side number for stats
'   file$ (STRING) - Unit name data file
'   dx (INTEGER) - Unit name offset
' Description:
'   Initializes unit attributes including type, strength, name, morale,
'   leadership, experience, and initial orders. Handles special cases like
'   reserves and late arrivals.
'============================================================================
SUB InitializeUnitAttributes (index AS INTEGER, i AS INTEGER, allarm AS INTEGER, who AS INTEGER, s AS INTEGER, file$ AS STRING, dx AS INTEGER)
	DIM armx AS INTEGER
	DIM a$ AS STRING
	
	' Determine unit type
	SELECT CASE i
		CASE 1: armx = 3
		CASE IS < .1 * allarm + (2 * RND): armx = 3
		CASE IS < .3 * allarm + (2 * RND): armx = 1
		CASE IS < .5 * allarm + (2 * RND): armx = 2: IF allarm < 11 AND RND > .5 THEN armx = 4
		CASE ELSE: armx = 4
	END SELECT
	
	unit$(index) = equip$(armx)
	
	' Set unit strength based on type
	SELECT CASE armx
		CASE IS < 2     'artillery
			strength(index) = unitsize& * (.5 + .2 * RND)
		CASE 2          'cavalry
			strength(index) = unitsize& * (.7 + .2 * RND)
		CASE 3          'general
			strength(index) = unitsize& * (.5 + .2 * RND)
		CASE 4, 5       'infantry
			strength(index) = unitsize& * (1.1 + .4 * RND)
		CASE ELSE
	END SELECT
	
	' Get unit name
	CALL namer(file$, dx, index - 1, a$)
	name$(index) = a$
	IF i = allarm THEN
		name$(index) = "RESERVES"
		morale(i) = 5: leader(i) = 5: xper(i) = 5: toa(i) = 5
	END IF
	
	' Set morale and leader stats
	morale(index) = 3 - 1 + 2 * RND
	leader(index) = .5 * leadbase(sidex(s)) - 1 + 2 * RND
	IF leader(index) > 3 AND morale(index) < 3 THEN morale(index) = morale(index) + 1
	IF index = 41 AND name$(index) = "Napoleon" THEN leader(index) = 5
	
	' Set experience
	xper(index) = expbase(who) + (-1 + 2 * RND)
	IF xper(index) > 3 AND leader(index) < 3 THEN leader(index) = 3
	IF leader(index) < 2 AND morale(index) > 2 THEN leader(index) = 2
	
	' Special unit type bonuses
	IF LEFTY$(index) = "C" AND leader(index) < 4 AND RND > .5 THEN leader(index) = 4
	IF LEFTY$(index) = "G" AND leader(index) < 4 AND RND > .5 THEN leader(index) = 4
	
	' Set initial orders and time of action
	uorder(index) = 0: toa(index) = 0
	IF RND > .9 THEN
		toa(index) = 25 * RND
		IF RND > .5 OR toa(index) > 15 THEN uorder(index) = 99
	END IF
	
	' Late arrival for defender
	IF side = sidex(2) AND who = side AND LEFTY$(index) <> "G" AND toa(index) = 0 AND RND > .5 THEN
		toa(index) = 1 + INT(3 * RND)
		IF fort > 0 THEN unit$(index) = "w" + unit$(index)
	END IF
	
	' Reserves arrive late
	IF i = allarm THEN
		uorder(i) = 99
		toa(i) = .5 * timelimit
	END IF
END SUB

'============================================================================
' Arrange - Calculate setup position for side
'============================================================================
' Parameters:
'   who (INTEGER) - Side (1 or 2)
'   xloc, yloc (INTEGER) - Output setup coordinates (modified by reference)
' Description:
'   Calculates the setup position for a side based on the setupx variable.
'   Returns coordinates for unit placement.
'============================================================================
SUB arrange (who, xloc, yloc)
SELECT CASE setupx
	CASE 1
		IF who = 1 THEN
			xloc = 13: yloc = 99
		ELSE
			xloc = 40: yloc = 99
		END IF
	CASE 2
		IF who = 1 THEN
			xloc = 99: yloc = 6
		ELSE
			xloc = 99: yloc = 18
		END IF
	CASE 3
		IF who = 1 THEN
			xloc = 40: yloc = 99
		ELSE
			xloc = 13: yloc = 99
		END IF
	CASE 4
		IF who = 1 THEN
			xloc = 27: yloc = 6
		ELSE
			xloc = 27: yloc = 18
		END IF
	CASE 5
		IF who = 1 THEN
			xloc = 99: yloc = 6
		ELSE
			xloc = 99: yloc = 18
		END IF
END SELECT
END SUB
