'============================================================================
' Tactical AI Module
'============================================================================
' AI decision-making functions for tactical battle
' Handles unit AI behavior, engagement decisions, and location evaluation

' $INCLUDE: 'core.bas'

'============================================================================
' General AI - Main AI decision function for units
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index to process
' Description:
'   Main AI function that determines unit behavior based on unit state,
'   objectives, and battlefield conditions. Handles weak units, dug-in units,
'   and objective movement.
'============================================================================
SUB general (index)
' Check if unit is dead
IF strength(index) < 1 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Check if unit is weak (low strength or morale)
IF strength(index) < 50 OR morale(index) < 2 THEN
	CALL flee(index)
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Check if unit is dug in
IF uorder(index) < 0 AND INSTR("AHB", LEFTY$(index)) > 0 THEN EXIT SUB
IF uorder(index) < 0 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Check if unit is delayed
IF uorder(index) = 99 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

s = 1: IF index > m1 THEN s = 2
IF possess <> s AND RND > .2 AND LEFTY$(index) <> "R" THEN
	uorder(index) = 100 * objy + objx
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Check if unit should mine (search for better position)
DIM shouldMine AS INTEGER
shouldMine = 0
IF uorder(index) > 0 AND RND < .15 * bold THEN
	shouldMine = 1
ELSE
	t$ = LEFTY$(index)
	IF t$ = "A" AND RND > .03 + .01 * bold THEN shouldMine = 1
	IF t$ = "G" AND RND > .03 * bold THEN shouldMine = 1
	IF shouldMine = 0 THEN
		d = ABS(unity(index) - objy) + ABS(unitx(index) - objx)
		CALL ranger(index, vantage)
		IF d > vantage AND RND < .1 * bold THEN shouldMine = 1
	END IF
END IF

IF shouldMine = 0 THEN
	' Unit should move to objective
	uorder(index) = 100 * objy + objx
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Unit should mine (search for better position)
CALL see(index)
IF uorder(index) > 0 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

a = terrain(index)
IF a = 239 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

IF (a = 94 OR a = 35) AND RND < .99 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

IF a = 42 AND RND < .95 THEN
	toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
	EXIT SUB
END IF

' Search for better position to improve
IF NOT EvaluateAllLocations%(index) THEN
	' If no better location found, move toward friendly unit
	DIM a AS INTEGER
	a = 1 + INT(m1 * RND): IF side = 2 THEN a = a + m1
	IF (strength(a) > 0 AND uorder(a) <> 99) AND LEFTY$(index) <> "R" THEN
		uorder(index) = 100 * unity(a) + unitx(a)
	END IF
END IF

' Set time of action
toa(index) = timex + 1: IF leader(index) < 3 THEN toa(index) = timex + 2
END SUB

'============================================================================
' Evaluate Location - Check if location should trigger improve action
'============================================================================
' Parameters:
'   x, y (INTEGER) - Location coordinates
'   z (INTEGER) - Terrain code (output)
'   index (INTEGER) - Unit index
' Returns:
'   INTEGER - 1 if location should trigger improve, 0 otherwise
' Description:
'   Evaluates a location to determine if it's suitable for unit improvement.
'   Checks terrain type and validates coordinates.
'============================================================================
FUNCTION EvaluateLocation% (x AS INTEGER, y AS INTEGER, z AS INTEGER, index AS INTEGER)
	IF x < 1 THEN x = 1
	IF x > 59 THEN x = 59
	IF y < 1 THEN y = 1
	IF y > 22 THEN y = 22
	z = SCREEN(y + 1, x)
	IF z = 35 OR z = 42 XOR z = 94 XOR z = 239 THEN
		EvaluateLocation% = 1
	ELSE
		EvaluateLocation% = 0
	END IF
END FUNCTION

'============================================================================
' Evaluate All Locations - Find better position for unit
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
' Returns:
'   INTEGER - 1 if better location found and order set, 0 otherwise
' Description:
'   Evaluates all adjacent locations to find a better position for the unit.
'   Checks northwest, northeast, southwest, southeast, west, and east.
'============================================================================
FUNCTION EvaluateAllLocations% (index AS INTEGER)
	DIM z AS INTEGER
	DIM y AS INTEGER
	DIM x AS INTEGER
	
	' Check northwest
	IF unity(index) > 1 THEN
		y = unity(index) - 1: x = unitx(index) - 1
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	' Check northeast
	IF unity(index) > 1 THEN
		y = unity(index) - 1: x = unitx(index) + 1
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	' Check southwest
	IF unity(index) < 22 THEN
		y = unity(index) + 1: x = unitx(index) - 1
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	' Check southeast
	IF unity(index) < 22 THEN
		y = unity(index) + 1: x = unitx(index) + 1
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	' Check west
	IF unitx(index) > 1 THEN
		x = unitx(index) - 2: y = unity(index)
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	' Check east
	IF unitx(index) < 59 THEN
		x = unitx(index) + 2: y = unity(index)
		IF EvaluateLocation%(x, y, z, index) THEN
			uorder(index) = 100 * y + x
			EvaluateAllLocations% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	EvaluateAllLocations% = 0
END FUNCTION

'============================================================================
' See - Unit sighting and engagement detection
'============================================================================
' Parameters:
'   attack (INTEGER) - Unit index that is looking
' Description:
'   Handles unit sighting of enemy units, line of sight calculations,
'   and automatic engagement decisions. Updates visibility and sets orders.
'============================================================================
SUB see (attack)
	IF strength(attack) < 1 OR uorder(attack) = 99 OR LEFTY$(attack) = "R" THEN EXIT SUB
	
	CALL YouorMe(attack, flag)
	u$ = LEFTY$(attack)

	' Check for enemy units (seehim section)
	CALL ranger(attack, vantage)
	s = m2: F = bigg(2): IF attack > m1 THEN s = 1: F = bigg(1)
	FOR defend = s TO F
		' Skip invalid or friendly units
		IF strength(defend) < 1 OR uorder(defend) = 99 THEN
			' Skip this unit
		ELSEIF defend = attack THEN
			' Skip self
		ELSEIF attack < m2 AND defend < m2 THEN
			' Both friendly, skip
		ELSEIF attack > m1 AND defend > m1 THEN
			' Both friendly, skip
		ELSE
			d = 2 * ABS(unity(attack) - unity(defend)) + ABS((unitx(attack) - unitx(defend)))
			
			' Check if close enough to see
			IF d < 4 THEN
				' Very close - always see (suresee section)
				CALL SHOWUNIT(defend): CALL SHOWUNIT(attack)
				IF terrain(defend) = 42 AND d > 4 THEN
					' Too far through fort, skip
				ELSE
					Visible(attack) = 1: Visible(defend) = 1
					IF INSTR("AG", u$) > 0 THEN
						' Artillery or General, skip engagement
					ELSEIF RND <= .05 * bold THEN
						' Check for engagement using extracted function
						IF ShouldEngageEnemy%(attack, defend, d, flag, u$) THEN
							IF ProcessEngagementOrders%(attack, defend, flag) THEN
								EXIT SUB
							END IF
						END IF
					END IF
				END IF
			ELSEIF d <= vantage THEN
				' Check line of sight
				IF lineofsight > 0 THEN
					CALL los(attack, defend, F, 0)
					IF F > 0 THEN
						' Reveal unit (suresee section)
						CALL SHOWUNIT(defend): CALL SHOWUNIT(attack)
						IF terrain(defend) = 42 AND d > 4 THEN
							' Too far through fort, skip
						ELSE
							Visible(attack) = 1: Visible(defend) = 1
							IF INSTR("AG", u$) = 0 AND RND <= .05 * bold THEN
								' Check for engagement using extracted function
								IF ShouldEngageEnemy%(attack, defend, d, flag, u$) THEN
									IF ProcessEngagementOrders%(attack, defend, flag) THEN
										EXIT SUB
									END IF
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	NEXT defend
	IF unity(attack) = objy AND unitx(attack) = objx THEN uorder(attack) = 0
END SUB

'============================================================================
' Check Enemy Engagement - Check if unit should engage nearby enemy
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
'   t$ (STRING) - Unit type string
'   xloc, yloc (INTEGER) - Location coordinates (modified by reference)
' Returns:
'   INTEGER - 1 if unit should continue movement, 0 if engagement occurred
' Description:
'   Handles enemy proximity checks and engagement decisions for AI units.
'   Determines if unit should engage, retreat, or continue movement.
'============================================================================
FUNCTION CheckEnemyEngagement% (index AS INTEGER, t$ AS STRING, xloc AS INTEGER, yloc AS INTEGER)
	DIM s AS INTEGER
	DIM F AS INTEGER
	DIM Enemy AS INTEGER
	DIM near AS INTEGER
	DIM pct! AS SINGLE
	DIM dxs AS INTEGER
	DIM dys AS INTEGER
	DIM enemyType$ AS STRING
	
	' Find nearby enemy
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL Near2(index, Enemy, near)
	
	IF Enemy = 0 THEN
		' No enemy nearby - continue movement
		CheckEnemyEngagement% = 1
		EXIT FUNCTION
	END IF
	
	' Enemy unit nearby - check if should engage
	IF INSTR("A", t$) > 0 THEN
		' Artillery unit - fire cannon
		CALL cannon(index, Enemy)
		CheckEnemyEngagement% = 0
		EXIT FUNCTION
	END IF
	
	' Not artillery - check if should engage in melee
	IF INSTR("GL", t$) > 0 THEN
		' General or Limbered - continue to movement
		CheckEnemyEngagement% = 1
		EXIT FUNCTION
	END IF
	
	IF uorder(index) > 0 AND RND > .1 * bold THEN
		' Has orders and random check - continue to movement
		CheckEnemyEngagement% = 1
		EXIT FUNCTION
	END IF
	
	' Calculate engagement probability
	pct! = strength(index) / strength(Enemy)
	pct! = pct! * .002 * RND * leader(index) * morale(index)
	enemyType$ = LEFTY$(Enemy)
	IF INSTR("AGL", enemyType$) > 0 THEN pct! = pct! + 1
	
	IF Visible(Enemy) > 0 AND near > 3 AND pct! > 1.8 - .2 * bold THEN
		' Engage enemy at range
		uorder(index) = 100 * unity(Enemy) + unitx(Enemy)
		IF LEFTY$(index) = "I" AND morale(index) > 2 AND (terrain(index) = 43 OR terrain(index) = 46) THEN
			unit$(index) = "Infantry": toa(index) = timex + 1
			CheckEnemyEngagement% = 0
			EXIT FUNCTION
		END IF
		IF morale(index) < 4 THEN CALL rest(index)
		' Continue to movement processing
		CheckEnemyEngagement% = 1
		EXIT FUNCTION
	ELSEIF near > 3 THEN
		' Too far - continue to movement
		IF LEFTY$(index) = "I" AND morale(index) > 2 AND (terrain(index) = 43 OR terrain(index) = 46) THEN
			unit$(index) = "Infantry": toa(index) = timex + 1
			CheckEnemyEngagement% = 0
			EXIT FUNCTION
		END IF
		IF morale(index) < 4 THEN CALL rest(index)
		' Continue to movement processing
		CheckEnemyEngagement% = 1
		EXIT FUNCTION
	ELSE
		' Close combat
		uorder(index) = 0
		xloc = unitx(Enemy): yloc = unity(Enemy)
		
		IF pct! > 2 + .1 * bold THEN
			' Fire at enemy - engage in combat
			IF LEFTY$(Enemy) = CHR$(219) THEN unit$(Enemy) = "Infantry"
			' Continue to combat processing (will be handled by caller)
			CheckEnemyEngagement% = 1
			EXIT FUNCTION
		ELSEIF pct! > .5 + .1 * bold THEN
			' Continue to movement processing
			CheckEnemyEngagement% = 1
			EXIT FUNCTION
		ELSE
			' Retreat from enemy
			uorder(index) = 0
			dxs = SGN(unitx(index) - unitx(Enemy))
			dys = SGN(unity(index) - unity(Enemy))
			xloc = unitx(index) + 2 * dxs
			yloc = unity(index) + 2 * dys
			' Continue to movement processing
			CheckEnemyEngagement% = 1
			EXIT FUNCTION
		END IF
	END IF
END FUNCTION

'============================================================================
' Should Engage Enemy - Determine if unit should engage enemy
'============================================================================
' Parameters:
'   attack (INTEGER) - Attacking unit index
'   defend (INTEGER) - Defending unit index
'   d (INTEGER) - Distance between units
'   flag (INTEGER) - Friendly flag (1=friendly, 0=enemy)
'   u$ (STRING) - Unit type string
' Returns:
'   INTEGER - 1 if should engage, 0 if should not
' Description:
'   Determines if a unit should engage an enemy based on combat calculations,
'   unit orders, and battlefield conditions.
'============================================================================
FUNCTION ShouldEngageEnemy% (attack AS INTEGER, defend AS INTEGER, d AS INTEGER, flag AS INTEGER, u$ AS STRING)
	DIM pct! AS SINGLE
	
	' Calculate engagement probability
	pct! = strength(attack) / strength(defend)
	pct! = pct! * .3 * leader(attack) * morale(attack) / d
	
	' Check if probability meets threshold
	IF pct! < 1.2 - .1 * bold THEN
		ShouldEngageEnemy% = 0
		EXIT FUNCTION
	END IF
	
	' Check if unit has conflicting orders
	IF uorder(attack) <> 0 AND RND > .15 * bold THEN
		ShouldEngageEnemy% = 0
		EXIT FUNCTION
	END IF
	
	' Check if unit is moving to objective
	IF uorder(attack) = 100 * objy + objx AND RND < .95 THEN
		ShouldEngageEnemy% = 0
		EXIT FUNCTION
	END IF
	
	' AI-controlled unit decision
	IF flag = 0 THEN
		IF RND <= 1 - .1 * bold THEN
			uorder(attack) = 100 * objy + objx
			ShouldEngageEnemy% = 0 ' Will exit SUB in caller
			EXIT FUNCTION
		ELSE
			ShouldEngageEnemy% = 0
			EXIT FUNCTION
		END IF
	END IF
	
	' Human-controlled unit decision
	IF LEFTY$(attack) = "C" THEN
		IF RND <= .5 AND LEFTY$(defend) <> "S" THEN
			ShouldEngageEnemy% = 1
		ELSE
			uorder(attack) = 0
			ShouldEngageEnemy% = 0
		END IF
	ELSEIF morale(attack) + leader(attack) + xper(attack) <= 8 THEN
		ShouldEngageEnemy% = 1
	ELSE
		uorder(attack) = 0
		ShouldEngageEnemy% = 0
	END IF
END FUNCTION

'============================================================================
' Check Manual Combat Order - Check if manual combat order should be cancelled
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
' Description:
'   Checks if a manual combat order should be cancelled based on proximity
'   and unit type. Used for human-controlled units.
'============================================================================
SUB CheckManualCombatOrder (index AS INTEGER)
	DIM bonus AS INTEGER
	DIM t$ AS STRING
	
	IF RND < .1 * leader(index) - .1 * rely THEN
		uorder(index) = 0
		EXIT SUB
	END IF
	
	IF rely = 1 THEN
		uorder(index) = 0
		EXIT SUB
	END IF
	
	CALL proximity(index, bonus)
	IF bonus > 10 THEN
		uorder(index) = 0
		EXIT SUB
	END IF
	
	t$ = LEFTY$(index)
	IF INSTR("GA", t$) > 0 THEN
		uorder(index) = 0
	END IF
END SUB

'============================================================================
' Process Engagement Orders - Process engagement between two units
'============================================================================
' Parameters:
'   attack (INTEGER) - Attacking unit index
'   defend (INTEGER) - Defending unit index
'   flag (INTEGER) - Friendly flag for attacker
' Returns:
'   INTEGER - 1 if should exit SUB (objective order set), 0 otherwise
' Description:
'   Processes engagement orders between two units. Sets attack orders,
'   checks for defender fleeing, and handles manual combat order checks.
'============================================================================
FUNCTION ProcessEngagementOrders% (attack AS INTEGER, defend AS INTEGER, flag AS INTEGER)
	DIM a$ AS STRING
	DIM defendFlag AS INTEGER
	
	' Set attack order
	uorder(attack) = 100 * unity(defend) + unitx(defend)
	
	' Check if defender should flee
	IF strength(defend) < 50 OR morale(defend) < 2 THEN CALL flee(defend)
	
	a$ = LEFTY$(defend)
	IF INSTR("AG", a$) > 0 OR a$ = "R" THEN
		' Artillery, General, or Routed - no counter-order
		ProcessEngagementOrders% = 0
		EXIT FUNCTION
	END IF
	
	' Set defend order to counter-attack
	uorder(defend) = 100 * unity(attack) + unitx(attack)
	
	' Check for manual combat on either side
	CALL YouorMe(attack, flag)
	IF flag > 0 THEN
		CALL CheckManualCombatOrder(attack)
	ELSE
		CALL YouorMe(defend, defendFlag)
		IF defendFlag > 0 THEN
			CALL CheckManualCombatOrder(defend)
		END IF
	END IF
	
	ProcessEngagementOrders% = 0
END FUNCTION

'============================================================================
' Target - Display unit movement target
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
' Description:
'   Displays the movement target for a unit. Shows a line from unit position
'   to target location with a circle at the destination.
'============================================================================
SUB target (index)
PCOPY 0, 1
SCREEN 9, , 1, 1
y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
IF x > 54 THEN uorder(index) = 0: EXIT SUB
clrbot
COLOR 11: PRINT name$(index); " is moving to location at "; x; ","; y;
LINE (8 * unitx(index) + 8, 14 * unity(index) + 6)-(8 * x + 8, 14 * y + 6), 15
CIRCLE (8 * x + 8, 14 * y + 6), 3, 15
IF quiet > 0 THEN SOUND 3000, .2
TICK .2 * mdly!
SCREEN 9, , 0, 0
END SUB

