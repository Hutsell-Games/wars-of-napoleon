'============================================================================
' Tactical Unit Management System
'============================================================================
' Handles unit placement, movement, status updates, and display
' Includes: placeunit, CombineUnits, SHOWUNIT, cupdate, limbo, rest, squares, valid
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Unit Placement and Movement
'============================================================================

SUB placeunit (xloc, yloc, index)
t$ = LEFTY$(index)
IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB

CALL YouorMe(index, flag)
IF flag > 0 THEN
	' Friendly unit - continue to movement processing
ELSEIF unity(index) = objy AND unitx(index) = objx THEN
	' Unit reached objective
	uorder(index) = 0: xloc = unitx(index): yloc = unity(index)
	' Continue to movement processing
ELSEIF possess <> 3 - side AND uorder(index) = 100 * objy + objx THEN
	' Unit has order to move to objective
	' Continue to movement processing
ELSE
	' Enemy unit - check for combat
	IF uorder(index) > -1 AND morale(index) < 4 THEN
		IF 15 * RND > morale(index) + leader(index) THEN
			uorder(index) = 0: CALL rest(index): EXIT SUB
		END IF
	END IF
	
	'============================================================================
	'                    Enemy Checks for Proximity of Our Units
	'============================================================================
	DIM shouldContinue AS INTEGER
	shouldContinue = CheckEnemyEngagement%(index, t$, xloc, yloc)
	IF shouldContinue = 0 THEN EXIT SUB

'============================================================================
'                    Continue with Move Orders
'============================================================================
told = terrain(index)
IF xloc > 55 THEN xloc = 55: movesleft = 0: EXIT SUB
IF xloc < 2 THEN xloc = 2: movesleft = 0: EXIT SUB
IF yloc > 20 THEN yloc = 20: movesleft = 0: EXIT SUB
IF yloc < 1 THEN yloc = 1: movesleft = 0: EXIT SUB
z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
'============================================================================
'                    Check for presence of Invisible Units
'============================================================================
CALL whois(xloc, yloc, Enemy, index)

' Check if enemy unit is present at target location
IF Enemy > 0 THEN
	' Enemy unit found - check if same side
	IF (index < m2 AND Enemy < m2) OR (index > m1 AND Enemy > m1) THEN
		' Same side - special handling (unit stacking/combining)
		uorder(index) = 1
		'---------------------------------------------------------------------------
		' Combine Units
		'---------------------------------------------------------------------------
		CALL YouorMe(Enemy, F)
		IF Enemy = 0 THEN EXIT SUB
		IF LEFTY$(Enemy) = "w" THEN unit$(Enemy) = RIGHT$(unit$(Enemy), LEN(unit$(Enemy)) - 1): CALL SHOWUNIT(Enemy)
		IF LEFTY$(index) = "R" OR LEFTY$(Enemy) = "R" THEN movesleft = 0: EXIT SUB
		IF strength(index) + strength(Enemy) > (unitsize& / 3) * (stakk - 1) THEN
			IF F > 0 THEN
				CALL clrbot
				COLOR 11
				IF uorder(index) = 0 THEN PRINT "Units are TOO BIG to stack ( Limit ="; 500 * stakk; ")";
				uorder(index) = 1: movesleft = 0
				TICK .2 * mdly!
				EXIT SUB
			ELSE
				movesleft = 0
				EXIT SUB
			END IF
		END IF
		'...........................................................................
		IF LEFTY$(Enemy) = "L" THEN unit$(Enemy) = RIGHT$(unit$(Enemy), LEN(unit$(Enemy)) - 1): CALL SHOWUNIT(Enemy)
		a$ = LEFTY$(index): t$ = LEFTY$(Enemy)
		IF F = 0 AND (a$ <> t$) THEN EXIT SUB

		IF F > 0 THEN
			LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 13
			LITEUP 8 * unitx(index), 14 * unity(index), 14
		END IF

		IF uorder(index) > 1 THEN EXIT SUB
		uorder(index) = 0
		IF quiet > 0 THEN SOUND 300, .3

		CALL kleer
		COLOR 14: LOCATE 12, 58: PRINT "Unit "; index;
		LOCATE 13, 58: PRINT name$(index)
		LOCATE 14, 58: PRINT unit$(index)
		COLOR 15: LOCATE 15, 63: PRINT CHR$(18)
		COLOR 11: LOCATE 16, 58: PRINT "Unit "; Enemy;
		LOCATE 17, 58: PRINT name$(Enemy)
		LOCATE 18, 58: PRINT unit$(Enemy)
		
		IF F = 0 THEN
			' Enemy unit - cannot combine, block movement
			uorder(index) = 1
			movesleft = 0
			EXIT SUB
		ELSE
			' Friendly unit - combine units
			CALL CombineUnits(index, Enemy, F)
			EXIT SUB
		END IF
	ELSE
		' Enemy side - engage in combat
		CALL SHOWUNIT(Enemy)
		
		'============================================================================
		'                            Engage if enemy is present
		'============================================================================
		COLOR 14
		IF side = 1 AND index > m1 THEN COLOR 15
		IF side = 2 AND index < m2 THEN COLOR 14
		'============================================================================
		'                              Engage in Combat
		'============================================================================
		IF flag > 0 THEN CALL inspect(index)
		CALL combat(index, Enemy)
		IF uorder(index) = 0 THEN movesleft = 0
		IF flag > 0 THEN CALL inspect(index)
		'============================================================================
		CALL SHOWUNIT(index)

		IF toa(index) < timex + 2 THEN toa(index) = timex + 2
		IF difficult < 5 THEN EXIT SUB
		IF flag = 0 THEN toa(index) = toa(index) - 2
		IF toa(index) <= timex THEN toa(index) = timex + 1
		EXIT SUB
	END IF
END IF

' No enemy or same side - continue with movement
' Update terrain and process movement
terrain(index) = z
IF LEFTY$(index) = "R" AND z = 233 THEN uorder(index) = 0: EXIT SUB
IF recon = 1 THEN Visible(index) = 1
IF Visible(index) > 0 THEN CALL SHOWUNIT(index)

' Calculate movement penalties and update time of action
CALL CalculateMovementPenalty(index, Pnlty, plus, movesleft)

IF unitx(index) = xloc AND unity(index) = yloc THEN EXIT SUB

IF strength(index) > 0 THEN CALL Tara(unitx(index), unity(index) + 1, 0)

unitx(index) = xloc: unity(index) = yloc
CALL SHOWUNIT(index)
IF quiet > 0 THEN SOUND 900, .1: TICK .05
IF terrain(index) = 233 THEN CALL victory(index)
EXIT SUB
END SUB

' Combines two friendly units into one
SUB CombineUnits (index AS INTEGER, Enemy AS INTEGER, F AS INTEGER)
	DIM u$ AS STRING
	DIM a$ AS STRING
	DIM t$ AS STRING
	DIM x AS INTEGER
	DIM r! AS SINGLE
	DIM k AS INTEGER
	
	' Ask for confirmation if human-controlled
	IF F > 0 THEN
		u$ = "Stack Units"
		CALL YesNo(u$)
		CALL scrcol(1)
		IF u$ <> "Y" THEN
			CALL SHOWUNIT(Enemy)
			EXIT SUB
		END IF
	END IF
	
	' Display stacking message
	IF Visible(index) > 0 THEN
		CALL clrbot
		COLOR 11: PRINT name$(index); " stacking with "; name$(Enemy);
		IF quiet > 0 THEN SOUND 3000, 2
	END IF
	
	' Determine which unit to keep (use stronger one, or general if present)
	a$ = LEFTY$(index): t$ = LEFTY$(Enemy)
	x = index
	IF t$ = "G" AND a$ <> "G" THEN
		x = Enemy
	ELSEIF strength(Enemy) > strength(index) THEN
		x = Enemy
	END IF
	
	' Combine unit attributes (weighted average)
	r! = strength(index) / (strength(index) + strength(Enemy))
	morale(index) = r! * morale(index) + (1 - r!) * morale(Enemy)
	leader(index) = r! * leader(index) + (1 - r!) * leader(Enemy)
	xper(index) = r! * xper(index) + (1 - r!) * xper(Enemy)
	toa(index) = timex + 3: IF leader(index) = 5 THEN toa(index) = timex + 1
	strength(index) = strength(index) + strength(Enemy)
	
	' Move combined unit to enemy's location
	CALL Tara(unitx(index), unity(index) + 1, 0)
	unitx(index) = unitx(Enemy): unity(index) = unity(Enemy)
	terrain(index) = terrain(Enemy): name$(index) = name$(x)
	
	' Determine combined unit type
	IF a$ = t$ THEN
		' Same type - keep current type
	ELSEIF INSTR("AL", a$) > 0 AND INSTR("AL", t$) > 0 THEN
		' Both artillery types - combine to Artillery
		unit$(index) = "Artillery"
	ELSEIF a$ = "G" OR t$ = "G" THEN
		' One is general - combine to General
		unit$(index) = "General"
	ELSE
		' Different types - default to Infantry
		unit$(index) = "Infantry"
		IF leader(index) < 3 AND morale(index) > 2 THEN morale(index) = morale(index) - 1
	END IF
	
	' Clean up merged unit
	strength(Enemy) = 0: leader(Enemy) = 0: unit$(Enemy) = "": toa(Enemy) = 0
	
	' Display result
	IF F = 0 AND Visible(index) > 0 THEN
		FOR k = 1 TO mdly!
			CALL ATTENTION(index, 13)
		NEXT k
		TICK mdly!
		EXIT SUB
	END IF
	
	IF Visible(index) > 0 THEN
		COLOR 14: CALL ATTENTION(index, 14)
	END IF
	
	CALL YouorMe(index, F)
	CALL clrbot
	IF F = 1 THEN
		PRINT "STACKED UNIT is "; unit$(index); " Unit"; index; " named "; name$(index); " with strength "; strength(index);
	ELSE
		PRINT sname$(3 - side); " units are stacking";
	END IF
	TICK mdly!
END SUB

' Calculates time of action penalty based on unit type, terrain, and unit stats
SUB CalculateMovementPenalty (index AS INTEGER, Pnlty AS INTEGER, plus AS INTEGER, movesleft AS INTEGER)
	DIM u$ AS STRING
	DIM dx AS INTEGER
	DIM a AS INTEGER
	DIM F AS INTEGER
	
	' Calculate time of action penalty from unit type
	u$ = LEFTY$(index)
	SELECT CASE u$
		CASE "I"
			plus = 2
		CASE CHR$(219)
			plus = 0
		CASE "C"
			plus = 0
		CASE "A", "L"
			plus = 1 + limber
		CASE "G"
			plus = 1
		CASE ELSE
			plus = 1
	END SELECT
	
	' Calculate time of action penalty from terrain and formation
	dx = 0: IF INSTR("AL", u$) THEN dx = 4
	
	SELECT CASE terrain(index)
		CASE 35  'fort
			Pnlty = 2
		CASE 42  'forest
			Pnlty = 3
			IF u$ = "L" THEN Pnlty = 4 + dx: movesleft = 0
			IF u$ = "C" THEN movesleft = 0
		CASE 43, 91 'road or bridge
			Pnlty = 1
		CASE 46  'clear
			Pnlty = 2: IF u$ = "C" THEN Pnlty = 1
		CASE 94  'hill
			Pnlty = 4
			IF u$ = "L" THEN Pnlty = 5 + dx: movesleft = 0
			IF u$ = "C" THEN movesleft = 0
		CASE 61 'swamp
			Pnlty = 6
			IF INSTR("CL", u$) > 0 THEN Pnlty = 8 + dx
			movesleft = 0
		CASE 176 'water
			Pnlty = 10: movesleft = 0
		CASE 233 'objective
			Pnlty = 2
		CASE 239 'mountain
			Pnlty = 8: movesleft = 0
		CASE 254 'village
			Pnlty = 2
			IF u$ = "I" OR u$ = "G" THEN Pnlty = 1
			IF u$ = "C" THEN movesleft = movesleft - 1
		CASE ELSE
			Pnlty = 2
	END SELECT
	
	' Modify time of action penalty based on unit morale & leader
	IF morale(index) < 3 THEN Pnlty = Pnlty + 1
	IF leader(index) < 3 THEN Pnlty = Pnlty + 1: IF leader(index) = 1 THEN Pnlty = Pnlty + 1
	
	' Update Time of Action
	a = Pnlty / 2: IF a < 1 THEN a = 1
	movesleft = movesleft - a
	toa(index) = timex + Pnlty + plus
	
	' Handle charging infantry
	IF LEFTY$(index) = CHR$(219) AND (RND > .97 OR (terrain(index) <> 43 AND terrain(index) <> 46)) THEN
		unit$(index) = "Infantry"
		toa(index) = timex + 2 + 2 * RND
	END IF
	
	' AI difficulty adjustment
	CALL YouorMe(index, F)
	IF F = 0 THEN
		IF toa(index) > timex + 1 AND difficult > 2 THEN
			IF RND < .05 * (difficult - 2) THEN toa(index) = timex + 1
		END IF
	END IF
END SUB

'============================================================================
' NOTE: cupdate moved to orders.bas (duplicate removed)
'============================================================================

'============================================================================
' Unit Status and Actions
'============================================================================

SUB limbo (index, flag)
IF limber = 0 THEN EXIT SUB
t$ = LEFTY$(index)

' If flag < 1, skip confirmation and go directly to limber/unlimber
IF flag < 1 THEN
	' Direct limber/unlimber without confirmation
	IF INSTR("AH", t$) > 0 THEN
		unit$(index) = "L" + unit$(index)
		a$ = "Limbered"
	ELSEIF t$ = "L" THEN
		unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		a$ = "UNLIMBERED"
	ELSE
		EXIT SUB
	END IF
ELSE
	' Show confirmation menu
	IF t$ = "L" THEN
		' Unit is limbered, ask to unlimber
		COLOR 11: clrbot: PRINT "Artillery units must be UNIMBERED to fire";
		mtx$(0) = "UNLIMBER ?"
	ELSE
		' Unit is not limbered, ask to limber
		COLOR 11: clrbot: PRINT "Artillery units must be LIMBERED to move";
		mtx$(0) = "Limber ?"
	END IF
	
	mtx$(1) = "Yes"
	mtx$(2) = "No"
	tly = 2: colour = 5
	tlx = 58: size = 2
	CALL menu
	
	IF choose = 1 THEN
		' User confirmed, do the limber/unlimber
		IF INSTR("AH", t$) > 0 THEN
			unit$(index) = "L" + unit$(index)
			a$ = "Limbered"
		ELSEIF t$ = "L" THEN
			unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
			a$ = "UNLIMBERED"
		ELSE
			EXIT SUB
		END IF
	ELSE
		' User cancelled
		EXIT SUB
	END IF
END IF

' Show result message and update unit state
movesleft = 0
toa(index) = toa(index) + 2 + 2 * RND
IF leader(index) < 3 THEN toa(index) = toa(index) + 1
CALL YouorMe(index, F)
IF F = 0 THEN
	IF t$ = "L" THEN
		uorder(index) = 100 * objy + objx
		IF Visible(index) > 0 THEN CALL SHOWUNIT(index): EXIT SUB
	END IF
	EXIT SUB
END IF
IF quiet > 0 THEN SOUND 1600, .3: TICK .05: SOUND 1700, .3
CALL ATTENTION(index, 13)
CALL inspect(index)
COLOR 11: CALL clrbot: PRINT "Artillery Unit "; name$(index); " is "; a$; : TICK .1 * mdly!
END SUB

SUB rest (k)
	IF morale(k) < leader(k) THEN morale(k) = morale(k) + 1
	IF morale(k) < 3 THEN morale(k) = morale(k) + 1
	IF RND < .2 * leader(k) AND morale(k) < 3 THEN morale(k) = morale(k) + 1
	toa(k) = timex + 1
	movesleft = 0
	CALL SHOWUNIT(k)
	CALL YouorMe(k, F): IF F = 0 THEN EXIT SUB
	IF LEFTY$(k) <> "w" THEN
		COLOR 15
		clrbot
		PRINT name$(k); " is resting for 1 turn";
		CALL TICK(.1 * mdly!)
	END IF
END SUB

SUB squares (index, flag)
SELECT CASE flag
	CASE 1                                  'to infantry
		unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		CALL SHOWUNIT(index)
		IF quiet > 0 THEN SOUND 1700, .3
		uorder(index) = 0: movesleft = 0
		toa(index) = timex + 1 + 2 * RND
	CASE 2                                  'to square
		IF RND > .1 * (morale(index) + leader(index) + xper(index)) THEN
			movesleft = 0
			CALL YouorMe(index, F): IF F = 0 THEN EXIT SUB
			CALL clrbot
			PRINT name$(index); " could not form a hollow square"; : TICK 1
			IF quiet > 0 THEN SOUND 200, 1
			EXIT SUB
		END IF
		unit$(index) = "S" + unit$(index)
		CALL SHOWUNIT(index)
		IF quiet > 0 THEN SOUND 1800, .3
		uorder(index) = 0: movesleft = 0
		toa(index) = timex + 1 + 2 * RND
END SELECT
END SUB

SUB valid (index)
IF morale(index) < 1 THEN morale(index) = 1
IF leader(index) < 1 THEN leader(index) = 1
IF morale(index) > 5 THEN morale(index) = 5
IF leader(index) > 5 THEN leader(index) = 5
IF xper(index) < 1 THEN xper(index) = 1
IF xper(index) > 5 THEN xper(index) = 5
IF LEFTY$(index) <> "R" THEN
	IF xper(index) > 3 AND morale(index) < 2 THEN morale(index) = 2
	IF xper(index) = 5 AND morale(index) < 3 THEN morale(index) = 3
END IF
END SUB

'============================================================================
' NOTE: AwakenUnit moved to orders.bas (duplicate removed)
'============================================================================

SUB WaitUnit (active AS INTEGER)
	COLOR 15: unit$(active) = "w" + unit$(active): clrbot: PRINT name$(active); " is WAITING until alerted"; : TICK .1 * mdly!: CALL rest(active)
END SUB

'============================================================================
' Unit Display
'============================================================================

SUB SHOWUNIT (index)
	IF recon = 0 AND Visible(index) = 0 THEN EXIT SUB
	IF strength(index) < 1 AND unit$(index) <> "X" THEN EXIT SUB
	IF uorder(index) = 99 THEN EXIT SUB
		y = 14 * unity(index): x = 8 * unitx(index)

		a = ASC(LEFTY$(index))
	       
		SELECT CASE a
		CASE 65   'Artillery
		IF index > 40 THEN PUT (x, y), AAlly, PSET ELSE PUT (x, y), AFrench, PSET
		CASE 67   'Cavalry
		IF index > 40 THEN PUT (x, y), CAlly, PSET ELSE PUT (x, y), CFrench, PSET
		CASE 71   'General
		IF index > 40 THEN PUT (x, y), GAlly, PSET ELSE PUT (x, y), GFrench, PSET
		CASE 73   'Infantry
		IF index > 40 THEN PUT (x, y), IAlly, PSET ELSE PUT (x, y), IFrench, PSET
		CASE 76 'Limbered Artillery
		IF index > 40 THEN PUT (x, y), LAAlly, PSET ELSE PUT (x, y), LAFrench, PSET
		CASE 82 'Routed Unit
		IF index > 40 THEN PUT (x, y), RAlly, PSET ELSE PUT (x, y), RFrench, PSET
		EXIT SUB
		CASE 83 'Hollow square
		IF index < 41 THEN PUT (x, y), HSAlly, PSET ELSE PUT (x, y), HSFrench, PSET
		CASE 88   'Death
		PUT (x, y), Death, PSET: unit$(index) = "DEAD"
		CASE 119  'wait
		IF index < 41 THEN PUT (x, y), Wally, PSET ELSE PUT (x, y), WFrench, PSET
		uorder(index) = 0: movesleft = 0
		CASE 232   'Charge Infantry
		IF index > 40 THEN
			PUT (x, y), IAlly, PSET: c = 15
		ELSE
			PUT (x, y), IFrench, PSET: c = 4
		END IF
		CIRCLE (x + 6, y + 6), 4, c
		CASE 238
		PUT (x, y), Death, PSET
		CASE ELSE
		END SELECT
IF (side = 1 AND index > m1) OR (side = 2 AND index < m2) THEN EXIT SUB
dx = 7: IF side = 2 THEN dx = 1
IF uorder(index) > 0 THEN LINE (x, y)-(x + 12, y + 12), dx, B
END SUB

'============================================================================
' Unit Array Management
'============================================================================

SUB Compact (flag)
	s = 1: F = m1: IF flag = 2 THEN s = m2: F = most
	FOR k = s TO F - 1
		IF strength(k) > 0 THEN
			' Slot occupied, continue to next
		ELSE
			' Find next non-empty slot to move here
			FOR j = k + 1 TO F
				IF strength(j) = 0 THEN
					' Empty slot, continue searching
				ELSE
					' Move unit from j to k
					name$(k) = name$(j)
					unit$(k) = unit$(j)
					morale(k) = morale(j)
					leader(k) = leader(j)
					strength(k) = strength(j)
					unitx(k) = unitx(j)
					unity(k) = unity(j)
					terrain(k) = terrain(j)
					toa(k) = toa(j)
					uorder(k) = uorder(j)
					xper(k) = xper(j)
					strength(j) = 0
					' Found replacement, exit inner loop
					EXIT FOR
				END IF
			NEXT j
		END IF
	NEXT k
	FOR k = s TO F
		IF strength(k) = 0 THEN
			bigg(flag) = k - 1
			EXIT SUB
		END IF
	NEXT k
	bigg(flag) = F
END SUB

'============================================================================
' NOTE: align function was declared in napoleon_subs.bas but never implemented
' If needed, implement here or in appropriate module
'============================================================================

