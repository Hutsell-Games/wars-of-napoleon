'============================================================================
' Tactical Terrain Module
'============================================================================
' Map generation and terrain management functions
' Includes: random map generation, terrain placement, terrain rendering,
' terrain updates, and terrain helper functions
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Random Map Generation
'============================================================================

'============================================================================
' Randmap - Generate random battle map
'============================================================================
' Description:
'   Generates a random battle map with terrain features including water,
'   roads, trees, hills, and other terrain. Displays loading screen and
'   places terrain features based on random selection and fortification level.
'============================================================================
SUB randmap
SCREEN 9, , 1, 1
CLS : COLOR 14
LINE (0, 0)-(213, 460), 1, BF: LINE (214, 0)-(426, 460), 15, BF
LINE (427, 0)-(639, 460), 4, BF
CIRCLE (320, 165), 300, 14, , , .1
PAINT (320, 172), 0, 14
a$ = "Setting Up Battle of " + SCENARIO$: LOCATE 11, 40 - .5 * LEN(a$): PRINT a$
a$ = commander$(sidex(1)) + " is attacking " + commander$(sidex(2)): LOCATE 13, 40 - .5 * LEN(a$): PRINT a$
' QB64-compatible file existence check
IF _FILEEXISTS("data\quotes.dat") THEN
	OPEN "I", 1, "data\quotes.dat"
	INPUT #1, n
	a = 1 + INT(RND * n)
	FOR k = 1 TO a
	INPUT #1, a$
	NEXT k
	CLOSE #1
	LOCATE 18, 40 - .5 * LEN(a$): PRINT CHR$(34); a$; CHR$(34)
END IF
SCREEN 9, , 0, 1
choose = 1
IF RND > .5 THEN
	choose = 2: IF RND > .5 THEN choose = 3
END IF
r! = 0: IF choose = 2 THEN r! = .5
IF choose = 3 THEN r! = .99
CALL startmap
CALL mainmap
FOR k = 1 TO most: strength(k) = 0: NEXT k
'============================================================================
'                            Place Terrain Features
'============================================================================
	' Place water features if random check passes
	IF RND <= r! THEN
		IF PlaceWaterFeatures(r!) THEN
			' Water placed, continue to roads
			IF RND <= .6 THEN
				IF PlaceRoads(r!) THEN
					' Roads placed, done
					EXIT SUB
				END IF
			END IF
		END IF
	END IF
	
	' Place trees
	IF RND > .4 THEN
		IF PlaceTrees(r!) THEN
			' Too much obstruction
			EXIT SUB
		END IF
	END IF
	
	' Place hills
	IF obstruct <= 80 AND RND <= .4 THEN
		IF PlaceHills(r!) THEN
			' Too much obstruction
			EXIT SUB
		END IF
	END IF
	
	' Place other terrain features
	IF obstruct <= 80 THEN
		PlaceOtherTerrain(r!)
	END IF
END SUB

'============================================================================
' Terrain Placement Helper Functions
'============================================================================

' GOSUB rloc converted to SUB
SUB RandomLocation (xloc AS INTEGER, yloc AS INTEGER)
	xloc = 2 + 53 * RND: yloc = 1 + 19 * RND
	IF xloc + yloc <> INT((xloc + yloc) / 2) * 2 THEN CALL AdjustHexX(xloc, yloc)
END SUB

' GOSUB nearhere converted to SUB
SUB MoveNearHere (x AS INTEGER, xloc AS INTEGER, yloc AS INTEGER, r! AS SINGLE)
	SELECT CASE x
		CASE 1
		xloc = xloc - 1: yloc = yloc - 1
		CASE 2
		yloc = yloc - 1
		CASE 3
		xloc = xloc - 1: yloc = yloc - 1
		CASE 4
		xloc = xloc - 2
		CASE 5
		xloc = xloc + 2
		CASE 6
		xloc = xloc - 1: yloc = yloc + 1
		CASE 7
		yloc = yloc + 1
		CASE 8
		xloc = xloc - 1: yloc = yloc + 1
		CASE ELSE
		xloc = 54
		IF RND < r! THEN CALL RandomLocation(xloc, yloc)
	END SELECT
	IF xloc < 1 THEN xloc = 1
	IF yloc > 21 THEN yloc = 21
	IF xloc > 55 THEN xloc = 55
	IF yloc < 1 THEN yloc = 1
END SUB

' GOSUB adjx converted to SUB
SUB AdjustHexX (xloc AS INTEGER, yloc AS INTEGER)
	IF xloc + yloc = INT((xloc + yloc) / 2) * 2 THEN EXIT SUB
	IF xloc > 2 THEN xloc = xloc - 1: EXIT SUB
	IF xloc < 54 THEN xloc = xloc + 1: EXIT SUB
END SUB

' GOSUB lim1 converted to SUB
SUB CheckLimits (xloc AS INTEGER, yloc AS INTEGER, flag AS INTEGER, spin AS INTEGER)
	flag = 0
	IF xloc > 54 OR xloc < 2 THEN flag = 1
	IF yloc > 20 OR yloc < 1 THEN flag = 1
	spin = spin + 1
END SUB

' Places water features on the map
' Returns: 1 if should exit randmap, 0 otherwise
FUNCTION PlaceWaterFeatures% (r! AS SINGLE)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x1 AS INTEGER
	DIM y1 AS INTEGER
	DIM x AS INTEGER
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	
	xloc = 4 + 50 * RND: yloc = 4 + 16 * RND
	x1 = xloc: y1 = yloc
	r! = .2 + .3 * RND: x = 8 * RND
	
	' Place water if fort present and not defender side
	IF fort > 0 AND side <> sidex(2) THEN
		DO
			IF RND > .9 THEN x = 8 * RND
			CALL MoveNearHere(x, xloc, yloc, r!)
			CALL AdjustHexX(xloc, yloc)
			CALL CheckLimits(xloc, yloc, flag, spin)
			IF flag = 1 THEN EXIT DO
			CALL replace(yloc, xloc, 176)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		LOOP
		
		' Check for second water feature
		IF x1 > 0 THEN
			xloc = x1: yloc = y1: x1 = 0
			DO
				IF RND > .9 THEN x = 8 * RND
				CALL MoveNearHere(x, xloc, yloc, r!)
				CALL AdjustHexX(xloc, yloc)
				CALL CheckLimits(xloc, yloc, flag, spin)
				IF flag = 1 THEN EXIT DO
				CALL replace(yloc, xloc, 176)
				PUT (8 * xloc, 14 * yloc), Xhair, XOR
			LOOP
		END IF
	END IF
	
	PlaceWaterFeatures% = 0
END FUNCTION

' Places roads on the map
' Returns: 1 if should exit randmap, 0 otherwise
FUNCTION PlaceRoads% (r! AS SINGLE)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x AS INTEGER
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	
	CALL RandomLocation(xloc, yloc)
	IF RND < .5 THEN
		yloc = 0
		CALL AdjustHexX(xloc, yloc)
		x = 6
		IF RND > .5 THEN x = 8
	ELSE
		yloc = 21
		CALL AdjustHexX(xloc, yloc)
		x = 1
		IF RND > .5 THEN x = 3
	END IF
	
	spin = 0
	DO
		CALL MoveNearHere(x, xloc, yloc, r!)
		CALL CheckLimits(xloc, yloc, flag, spin)
		IF flag = 1 OR spin > 99 THEN EXIT DO
		CALL replace(yloc, xloc, 43)
		PUT (8 * xloc, 14 * yloc), Xhair, XOR
	LOOP
	
	IF RND <= .8 THEN
		PlaceRoads% = 0
	ELSE
		PlaceRoads% = 1
	END IF
END FUNCTION

' Places trees on the map
' Returns: 1 if too much obstruction (should exit), 0 otherwise
FUNCTION PlaceTrees% (r! AS SINGLE)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x AS INTEGER
	DIM z AS INTEGER
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	
	CALL RandomLocation(xloc, yloc)
	DO
		x = 8 * RND
		CALL MoveNearHere(x, xloc, yloc, r!)
		CALL CheckLimits(xloc, yloc, flag, spin)
		IF flag = 1 THEN EXIT DO
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
		IF z <> 46 THEN
			CALL replace(yloc, xloc, 42)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		END IF
	LOOP WHILE z <> 46
	
	IF obstruct <= 80 AND RND <= .4 THEN
		PlaceTrees% = 0
	ELSE
		IF obstruct > 80 THEN
			PlaceTrees% = 1
		ELSE
			PlaceTrees% = 0
		END IF
	END IF
END FUNCTION

' Places hills on the map
' Returns: 1 if too much obstruction (should exit), 0 otherwise
FUNCTION PlaceHills% (r! AS SINGLE)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x AS INTEGER
	DIM z AS INTEGER
	DIM a AS INTEGER
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	
	CALL RandomLocation(xloc, yloc)
	r! = .3 + .6 * RND
	DO
		x = 8 * RND
		CALL MoveNearHere(x, xloc, yloc, r!)
		CALL CheckLimits(xloc, yloc, flag, spin)
		IF flag = 1 THEN EXIT DO
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
		IF z <> 46 THEN
			a = 239: IF RND < .8 THEN a = 94
			CALL replace(yloc, xloc, a)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
		END IF
	LOOP WHILE z <> 46
	
	IF obstruct > 80 THEN
		PlaceHills% = 1
	ELSEIF RND <= .4 THEN
		PlaceHills% = 0
	ELSE
		PlaceHills% = 0
	END IF
END FUNCTION

' Places other terrain features (forts, villages, swamps)
SUB PlaceOtherTerrain (r! AS SINGLE)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x AS INTEGER
	DIM z AS INTEGER
	DIM flag AS INTEGER
	DIM spin AS INTEGER
	
	CALL RandomLocation(xloc, yloc)
	r! = .1
	DO
		CALL CheckLimits(xloc, yloc, flag, spin)
		IF flag = 1 THEN EXIT DO
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
		IF z <> 46 THEN
			' Not clear terrain - try another location
			' Continue loop
		ELSE
			' Clear terrain - place feature
			z = 35
			IF RND > .2 + .2 * fort THEN z = 254
			IF RND > .4 + .1 * fort THEN z = 61
			CALL replace(yloc, xloc, z)
			PUT (8 * xloc, 14 * yloc), Xhair, XOR
			
			' Continue placing nearby features
			IF RND > .5 - .1 * fort THEN
				CALL MoveNearHere(x, xloc, yloc, r!)
				' Continue loop to place more
			ELSE
				' Done with this feature group
				EXIT DO
			END IF
		END IF
		
		IF obstruct > 80 THEN EXIT DO
		IF RND <= .1 THEN EXIT DO
	LOOP
END SUB

'============================================================================
' Terrain Replacement and Rendering
'============================================================================

'============================================================================
' Replace - Replace terrain at location
'============================================================================
' Parameters:
'   y, x (INTEGER) - Location coordinates
'   z (INTEGER) - New terrain code
' Description:
'   Replaces terrain at specified location, updates obstruction counter,
'   and updates terrain display. Also updates terrain for units at location.
'============================================================================
SUB replace (y, x, z)
IF y < 1 OR y > 20 THEN EXIT SUB
IF x < 2 OR x > 56 OR x = 55 THEN EXIT SUB
SELECT CASE z
	CASE 43
		obstruct = obstruct + 1
	CASE 61, 94
		obstruct = obstruct + 3
	CASE 176, 239
		obstruct = obstruct + 5
END SELECT
CALL Tara(x, y + 1, z)
PUT (8 * x, 14 * y), Xhair, XOR
t$ = MID$(sdtext$(y + 1), x, 1): IF t$ = CHR$(219) THEN nobj = nobj - 1
a1$ = LEFT$(sdtext$(y + 1), x - 1)
a2$ = RIGHT$(sdtext$(y + 1), LEN(sdtext$(y + 1)) - x)
sdtext$(y + 1) = a1$ + CHR$(z) + a2$
IF z = 233 THEN nobj = nobj + 1
CALL Terra(z, a$)
IF repeat > 0 AND repeat <> z THEN repeat = z: COLOR 12: LOCATE 8, 62: PRINT "DUPLICATE ": CALL Tara(72, 8, z): SOUND 3100, .5
CALL whois(x, y, Enemy, 0): IF Enemy > 0 THEN terrain(Enemy) = z
END SUB

'============================================================================
' Tara - Render terrain tile
'============================================================================
' Parameters:
'   x, y (INTEGER) - Location coordinates
'   a (INTEGER) - Terrain code (0 to read from map)
' Description:
'   Renders a terrain tile at the specified location. If a=0, reads terrain
'   code from map. Displays appropriate terrain sprite based on terrain code.
'============================================================================
SUB Tara (x, y, a)
IF a = 0 THEN t$ = MID$(sdtext$(y), x, 1): a = ASC(t$)
z = 8 * x: c = 14 * (y - 1)
	SELECT CASE a
	CASE 35
	PUT (z, c), Fterr, PSET
	CASE 42
	PUT (z, c), Tterr, PSET
	CASE 43
	PUT (z, c), Rterr, PSET
	CASE 46
	PUT (z, c), Cterr, PSET
	CASE 61
	PUT (z, c), Sterr, PSET
	CASE 91
	PUT (z, c), Bridge, PSET
	CASE 94
	PUT (z, c), Hterr, PSET
	CASE 176
	PUT (z, c), Wterr, PSET
	CASE 233
	PUT (z, c), Oterr, PSET
	SELECT CASE possess
	CASE 1
	PAINT (z + 6, c + 4), 4, 15
	CASE 2
	PAINT (z + 6, c + 4), 1, 15
	END SELECT
	CASE 239
	PUT (z, c), Mterr, PSET
	CASE 254
	PUT (z, c), Vterr, PSET
	CASE ELSE
	END SELECT
END SUB

'============================================================================
' Terra - Get terrain name
'============================================================================
' Parameters:
'   k (INTEGER) - Terrain code
'   a$ (STRING) - Output terrain name (modified by reference)
' Description:
'   Returns the name of a terrain type based on its code.
'============================================================================
SUB Terra (k, a$)
		SELECT CASE k
		CASE 35
		a$ = "Fort"
		CASE 42
		a$ = "Trees"
		CASE 43, 47, 92
		a$ = "Road "
		CASE 46
		a$ = "Clear"
		CASE 61
		a$ = "Swamp"
		CASE 91
		a$ = "Bridge"
		CASE 94
		a$ = "Hill"
		CASE 123, 125, 126
		a$ = "River"
		CASE 176
		a$ = "Water"
		CASE 233
		a$ = "OBJCTV"
		CASE 239
		a$ = "Mtn"
		CASE 254
		a$ = "Village"
		CASE ELSE
		a$ = "Unknown"
		END SELECT
END SUB

'============================================================================
' Update All Terrain - Update terrain display for all units
'============================================================================
' Description:
'   Updates terrain display for all active units on the map.
'   Called when terrain changes affect unit positions.
'============================================================================
SUB UpdateAllTerrain
	DIM k AS INTEGER
	FOR k = 1 TO bigg(2)
	IF strength(k) > 0 AND uorder(k) <> 99 THEN CALL Tara(unitx(k), unity(k) + 1, 0)
	NEXT k
END SUB

'============================================================================
' Start Map - Initialize map text array
'============================================================================
' Description:
'   Initializes the map text array (sdtext$) with default terrain.
'   Sets up border and clear terrain for the battle map.
'============================================================================
SUB startmap
	sdtext$(1) = CHR$(219) + STRING$(53, CHR$(219)) + CHR$(219)
	sdtext$(2) = CHR$(219) + " . . . . . . . . . . . . . . . . . . . . . . . . . . " + CHR$(219)
	sdtext$(3) = CHR$(219) + ". . . . . . . . . . . . . . . . . . . . . . . . . . ." + CHR$(219)
	sdtext$(22) = CHR$(219) + STRING$(53, CHR$(219)) + CHR$(219)
	sdtext$(23) = ""
	sdtext$(24) = ""
	FOR k = 4 TO 20 STEP 2
	sdtext$(k) = sdtext$(2)
	sdtext$(k + 1) = sdtext$(3)
	NEXT k
END SUB

'============================================================================
' Vistarg - Update visibility for visible units
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   flag (INTEGER) - Display flag (1=show cursor, 0=hide)
' Description:
'   Updates visibility for all visible units based on range and line of sight.
'   Hides units that are out of range or not in line of sight.
'============================================================================
SUB vistarg (active, flag)
CALL ranger(active, vantage)
s = 1: a = bigg(1): IF side = 1 THEN s = m2: a = bigg(2): c = 0
FOR k = s TO a
	IF Visible(k) > 0 THEN
		d = 2 * ABS(unity(active) - unity(k)) + ABS(unitx(active) - unitx(k))
		IF d > vantage THEN
			IF unitx(k) > 1 AND unitx(k) < 55 AND unity(k) > 0 AND unity(k) < 21 THEN c = 1
		ELSE
			c = 0: F = 0
			IF lineofsight > 0 THEN CALL los(active, k, F, 0)
			IF flag > 0 AND F > 0 THEN PUT (8 * unitx(k), 14 * unity(k)), Xhair, XOR
		END IF
		IF F < 1 OR c > 0 THEN
			IF unitx(k) > 0 AND unity(k) > 0 THEN
				CALL Tara(unitx(k), unity(k) + 1, terrain(k))
			END IF
		END IF
	END IF
NEXT k
END SUB

