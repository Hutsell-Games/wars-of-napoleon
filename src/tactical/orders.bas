'============================================================================
' Tactical Orders Module
'============================================================================
' Order processing and command handling functions
' Includes: main order processing loop, unit update, command processing,
' cursor commands, and order helpers
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Main Order Processing
'============================================================================

'============================================================================
' Order - Main order processing loop
'============================================================================
' Description:
'   Main order processing function that handles unit turns, command input,
'   and unit updates. Processes units in order of time of action, handles
'   both human and AI-controlled units, and manages the battle flow.
'============================================================================
SUB order
	flag = 0
	CALL BuffClear
'============================================================================
'                       Find Time of Next Action
'============================================================================
	told = timex
	CALL lowtime
	IF bold < 4 AND timex = .5 * timelimit AND possess <> 3 - side THEN bold = 4
	IF timex > .8 * timelimit AND possess <> 3 - side THEN bold = 5
	
	' Check if time expired
	IF timelimit - timex <= 0 THEN
		CALL clrbot: COLOR 14: PRINT "Time expired - battle of "; SCENARIO$; " is over "; : TICK 99: CALL expire: file$ = CHR$(219): EXIT SUB
	END IF
	
	FOR k = 1 TO 2: CALL brittle(k): NEXT k

	CALL scrcol(2)

	FOR active = 1 TO bigg(2)
		CALL BuffClear
		t$ = LEFTY$(active)
	SELECT CASE t$
		CASE "A"
			movesleft = 1
		CASE "I", "G", "L"
			movesleft = 2
		CASE CHR$(219)
			movesleft = 3
		CASE "C"
			movesleft = 4
		CASE "R"
			' Handle routed units
			movesleft = 4
			CALL routed(active, 0)
			IF LEFTY$(active) = "R" THEN
				IF uorder(active) = 0 THEN CALL flee(active)
				CALL cupdate(active)
				IF uorder(active) = 0 THEN movesleft = 0
				' Continue to unit update section (asleep label)
			END IF
		CASE "S"
			uorder(active) = 0
		CASE ELSE
			movesleft = 2
	END SELECT

	' Check if unit can act
	IF strength(active) < 1 OR toa(active) > timex THEN
		movesleft = 0
		' Skip to end of unit processing (snore label)
	ELSEIF uorder(active) = 99 THEN
		CALL CanPlaceUnit(active)
		IF uorder(active) = 99 THEN
			movesleft = 0
			' Skip to unit update section (sleep2 label)
		ELSE
			flag = 1
			' Continue processing
		END IF
	ELSEIF t$ = "w" THEN
		CALL rest(active): uorder(active) = 0
		' Skip to unit update section (sleep2 label)
	ELSE
		flag = 1
		' Continue processing unit
	END IF
	
	' Process unit if it can act
	IF movesleft > 0 AND strength(active) > 0 AND toa(active) <= timex AND uorder(active) <> 99 AND t$ <> "w" THEN
		CALL YouorMe(active, F)
		IF F = 0 THEN
			' Enemy unit - process via enemy AI function
			movesleft = ProcessEnemyUnit%(active, t$, movesleft)
			' Update unit after enemy processing
			DIM shouldContinueEnemy AS INTEGER
			shouldContinueEnemy = UpdateUnitAfterAction%(active, t$, movesleft)
			' Continue to next unit in FOR loop
		ELSE
			' Human-controlled unit - continue to human processing below
		END IF
	ELSE
		' Unit cannot act - skip to update section (asleep)
		' Fall through to asleep section
	END IF
	
	' If unit cannot act, skip human processing and go to update
	IF NOT (movesleft > 0 AND strength(active) > 0 AND toa(active) <= timex AND uorder(active) <> 99 AND t$ <> "w") THEN
		' Unit cannot act - update and continue to next unit
		DIM shouldContinue AS INTEGER
		shouldContinue = UpdateUnitAfterAction%(active, t$, movesleft)
		IF shouldContinue = 0 THEN
			' Continue to next unit in FOR loop
		ELSE
			' Unit has more moves - loop back (handled by FOR loop structure)
			' Note: In original code, GOTO stillgoing would loop back
			' Since we're in a FOR loop, we need to handle this differently
			' For now, we'll let the loop continue and check movesleft at start of next iteration
		END IF
	ELSEIF F = 0 THEN
		' Enemy unit - already processed via otherside, update and continue
		DIM shouldContinue2 AS INTEGER
		shouldContinue2 = UpdateUnitAfterAction%(active, t$, movesleft)
		IF shouldContinue2 = 0 THEN
			' Continue to next unit
		ELSE
			' Unit has more moves - will be processed again in loop
		END IF
	ELSE
'============================================================================
' Human-controlled unit processing
'============================================================================
	' Human unit processing
	y0 = 14 * unity(active): x0 = 8 * unitx(active)
	IF rely = 1 OR INSTR("A", t$) > 0 THEN IF uorder(active) > 99 THEN uorder(active) = 0

		clrbot
		IF uorder(active) > 0 THEN
			CALL cupdate(active)
			IF uorder(active) = 1 THEN movesleft = 0
			' Unit has orders, update and continue
			DIM shouldContinue3 AS INTEGER
			shouldContinue3 = UpdateUnitAfterAction%(active, t$, movesleft)
			IF shouldContinue3 = 0 THEN
				' Continue to next unit
			ELSE
				' Unit has more moves - will be processed again
			END IF
		ELSE
			CALL inspect(active)
			IF flag > 0 THEN
				FOR k = 1 TO 2: ATTENTION active, 14: NEXT k
				IF quiet > 0 THEN SOUND 1200, .1
			END IF
			flag = 0

			CALL ranger(active, vantage)
			
			' Command input loop
			DO
				' Check if unit became routed
				IF LEFTY$(active) = "R" THEN
					' Handle routed unit
					movesleft = 4
					CALL routed(active, 0)
					IF LEFTY$(active) = "R" THEN
						IF uorder(active) = 0 THEN CALL flee(active)
						CALL cupdate(active)
						IF uorder(active) = 0 THEN movesleft = 0
						EXIT DO ' Exit command loop, go to unit update
					END IF
				END IF
		
		LITEUP x0, y0, 14
		CALL DrawCommandLine(active, t$, limber)
		
		' Get keyboard command
		DO
			commnd$ = INKEY$
		LOOP WHILE commnd$ = ""
		
		' Process command
		a = LEN(commnd$): commnd$ = RIGHT$(commnd$, 1)
		z = ASC(UCASE$(commnd$))
		
		' Process command based on key
		DIM commandProcessed AS INTEGER
		commandProcessed = 0
		
		SELECT CASE z
		CASE 19: recon = 1 - recon
			SOUND 1999, .5
			FOR k = 1 TO bigg(2)
				IF strength(k) > 0 AND recon = 0 AND Visible(k) = 0 THEN CALL Tara(unitx(k), unity(k) + 1, terrain(k))
				CALL SHOWUNIT(k)
			NEXT k

		CASE 27: ' Escape - cancel and return to command input
			CALL PlayNoise1
			' Continue loop to get new command
		CASE 32: ' Space - rest
			CALL BUTTON(27, 25, 4, "rest", 1)
			CALL rest(active)
			commandProcessed = 1
			EXIT DO ' Exit command loop, go to unit update
		CASE 59  'F1 - Help
			CALL help
			' Continue loop to get new command
		CASE 61  'F3
			CALL mainmap: CALL refresh: CALL inspect(active)
		CASE 64: ' X key
			IF t$ = "G" THEN
				dx = 5
				CALL BUTTON(58, 25, 4, "(X)ancel", 0)
				' Process cursor-controlled movement (fodder)
				commandProcessed = 0 ' Will be set when command completes
				' Continue to fodder processing below
			ELSE
				' Not a general, invalid command
				clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
				' Continue loop
			END IF
		CASE 67:
			 IF a = 2 THEN
				PCOPY 0, 1
				SCREEN 9, , 1, 1
				CALL BUTTON(70, 21, 1, "F9:RETREAT", 1)
				LINE (110, 110)-(360, 210), 0, BF
				LINE (100, 100)-(350, 200), 5, BF
				LINE (110, 110)-(340, 190), 15, B
				COLOR 15: LOCATE 10, 20: PRINT "STRATEGIC RETREAT ?"
				LOCATE 12, 22: PRINT "(20% PENALTY!)"
				TICK 3
				a$ = "RETREAT?"
				CALL YesNo(a$)
				IF a$ = "Y" THEN
					score&(side) = score&(side) + .2 * strength(side)
					CALL over(side)
				END IF
				SCREEN 9, , 0, 0
			 END IF
				IF t$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN
					unit$(active) = "Infantry": toa(active) = timex + 1: CALL BUTTON(58, 25, 4, "Charge", 1): : CALL PlayNoise1
					commandProcessed = 1
					EXIT DO ' Exit command loop, go to unit update
				END IF
			CASE 70: ' F key
				IF INSTR("A", t$) > 0 THEN
					dx = 1
					' Process cursor-controlled cannon (fodder)
					commandProcessed = 0 ' Will be set when command completes
					' Continue to fodder processing below
				ELSE
					' Not artillery, invalid command
					clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
					' Continue loop
				END IF
			CASE 71: ' Arrow keys (with a=2 check)
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				ELSE
					CALL RefreshAhead(active)
				END IF
			CASE 72: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				END IF
			CASE 73: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				ELSE
					CALL BUTTON(33, 25, 4, "Intell", 1)
					dx = 3
					' Process cursor-controlled intelligence (fodder)
					commandProcessed = 0 ' Will be set when command completes
					' Continue to fodder processing below
				END IF
			CASE 75: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				END IF
			CASE 76: ' L key - Limber
				IF INSTR("AL", t$) > 0 THEN
					CALL BUTTON(58, 25, 4, "Limber", 1)
					CALL limbo(active, -1)
					commandProcessed = 1
					EXIT DO ' Exit command loop, go to unit update
				END IF
			CASE 77: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				ELSE
					dx = 2
					' Process cursor-controlled move (fodder)
					commandProcessed = 0 ' Will be set when command completes
					' Continue to fodder processing below
				END IF
			CASE 78: ' N key
				IF t$ = "G" THEN
					CALL BUTTON(67, 25, 4, "i(N)spire", 1)
					dx = 4
					' Process cursor-controlled inspire (fodder)
					commandProcessed = 0 ' Will be set when command completes
					' Continue to fodder processing below
				ELSE
					' Not a general, invalid command
					clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
					' Continue loop
				END IF
			CASE 79: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				ELSE
					CALL report: CALL inspect(active)
					' Continue loop to get new command
				END IF
			CASE 80: ' Arrow keys
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				END IF
			CASE 81: ' Q key - Toggle quiet
				IF a = 2 THEN
					IF ProcessMovementCommand%(active, commnd$, t$, limber) = 1 THEN
						commandProcessed = 1
						EXIT DO
					END IF
				ELSE
					quiet = 1 - quiet: CALL scrcol(12)
					IF quiet > 0 THEN SOUND 1700, .3
					' Continue loop to get new command
				END IF
			CASE 82: ' R key - Rest
				CALL BUTTON(27, 25, 4, "rest", 1)
				CALL rest(active)
				commandProcessed = 1
				EXIT DO ' Exit command loop, go to unit update
			CASE 83: ' S key - Squares
				IF LEFTY$(active) = "S" THEN
					CALL squares(active, 1)
					commandProcessed = 1
					EXIT DO ' Exit command loop, go to unit update
				END IF
				IF LEFTY$(active) = "I" THEN
					CALL squares(active, 2)
					toa(active) = timex + 2
					commandProcessed = 1
					EXIT DO ' Exit command loop, go to unit update
				END IF
		CASE 84
			CALL UpdateAllTerrain
			CALL clrbot: PRINT "Terrain"; TAB(60); "(press a key)...";
			TICK 5
			CALL refresh
		CASE 86
			PCOPY 0, 1
			SCREEN 9, , 1, 1
			CALL vistarg(active, 1)
			CALL ranger(active, vantage)
			FOR k = 2 TO 21
				s = 2: IF INT(.5 * k) * 2 = k THEN s = 3
				FOR j = s TO 54 STEP 2
					unitx(0) = j: unity(0) = k - 1
					terrain(0) = ASC(MID$(sdtext$(unity(0) + 1), unitx(0)))
					d = 2 * ABS(unity(active) - unity(0)) + ABS(unitx(active) - unitx(0))
					IF d <= vantage THEN
						CALL los(active, 0, F, 0)
						IF F <> 0 THEN PUT (8 * j, 14 * (k - 1)), Xhair, XOR
					END IF
				NEXT j
			NEXT k
			CALL clrbot: PRINT "Visible Enemy Units and Terrain"; TAB(60); "(press a key)...";
			TICK 99
			SCREEN 9, , 0, 0
			CASE 87: ' W key - Wait
				CALL BUTTON(41, 25, 4, "Wait", 1): CALL WaitUnit(active)
				commandProcessed = 1
				EXIT DO ' Exit command loop, go to unit update
			CASE 88: ' H key
				IF t$ = "G" THEN
					CALL CancelOrders(active, side, x, y)
					IF y > 0 THEN
						commandProcessed = 1
						EXIT DO ' Exit command loop, go to unit update
					END IF
					' Otherwise continue loop to get new command
				END IF
			CASE ELSEIF a < 2 THEN
				clrbot: COLOR 11: PRINT "Cannot execute that command"; : CALL TICK(mdly!): clrbot: BuffClear
				' Continue loop to get new command
			END SELECT
			
			' If command was processed (unit action taken), exit command loop
			IF commandProcessed = 1 THEN EXIT DO
			
			' Check if we need to process cursor-controlled command (fodder)
			IF dx > 0 AND dx <= 5 THEN
				' Process cursor-controlled command
				DIM fodderResult AS INTEGER
				fodderResult = ProcessCursorCommand%(active, dx, t$, limber, commandProcessed)
				IF fodderResult = 1 THEN
					' Command was processed, exit command loop
					EXIT DO
				END IF
				' Reset dx to continue command loop
				dx = 0
			END IF
		LOOP ' End of command input loop
'============================================================================
' orders:   <0=dug in   0=none   1=blocked  99=hidden  >99=moveto destination
'============================================================================
'                     Move Unit & Check for Sighting
'============================================================================
		' Update unit after command processing
		DIM shouldContinue4 AS INTEGER
		shouldContinue4 = UpdateUnitAfterAction%(active, t$, movesleft)
		IF shouldContinue4 = 0 THEN
			' Continue to next unit
		ELSE
			' Unit has more moves - will be processed again
		END IF
	END IF
	NEXT active
	
	' Check for army wavering
	FOR s = 1 TO 2
	IF elan(s) < 30 AND waver(s) = 0 THEN
		waver(s) = 1
		PCOPY 0, 1
		SCREEN 9, , 1, 1
		LINE (90, 110)-(410, 200), 0, BF
		LINE (80, 100)-(400, 190), 4, BF
		LINE (85, 105)-(395, 185), 154, B
		LOCATE 11, 17: PRINT sname$(s); " army beginning to waver!"
		'1812 Finale
		IF quiet > 0 THEN PLAY "T220o1g8g16g16o2c8d8e8d8c8d8e8P8c8P8c2"
		TICK 99
		SCREEN 9, , 0, 0
	END IF
	NEXT s
EXIT SUB
END SUB

'============================================================================
' Unit Update
'============================================================================

'============================================================================
' Cupdate - Update unit position based on orders
'============================================================================
' Parameters:
'   index (INTEGER) - Unit index
' Description:
'   Updates unit position based on movement orders. Calculates movement
'   direction toward destination and calls placeunit to execute movement.
'============================================================================
SUB cupdate (index)
	IF strength(index) < 1 OR uorder(index) = 99 OR uorder(index) = 0 THEN movesleft = 0: EXIT SUB
	t$ = LEFTY$(index)
	IF limber > 0 AND t$ = "A" THEN uorder(index) = 0: EXIT SUB
	
	y = INT(uorder(index) / 100): x = uorder(index) - 100 * y
	ynew = unity(index): xnew = unitx(index)
	dx = ABS(x - unitx(index)): dy = ABS(y - unity(index))
	
	IF dx + dy = 0 THEN
		' Reached destination
		CALL YouorMe(index, F): IF F > 0 THEN CALL flash(index): uorder(index) = 0
		uorder(index) = 0
		' Continue to placeunit (slide section)
	ELSE
		' Calculate movement direction
		dxs = SGN(x - unitx(index)): dys = SGN(y - unity(index))
		
		' Try to move toward destination
		IF dy > 0 THEN
			ynew = unity(index) + dys: xnew = unitx(index) + dxs
			z = SCREEN(ynew + 1, xnew)
			IF z = 43 OR z = 46 OR z = 233 OR z = 254 THEN
				' Valid move found
			ELSE
				ynew = unity(index): xnew = unitx(index)
			END IF
		ELSEIF dy = 0 THEN
			xnew = unitx(index) + 2 * dxs
			z = SCREEN(ynew + 1, xnew)
			IF z = 35 OR z = 43 OR z = 46 OR z = 233 OR z = 254 THEN
				' Valid move found
			ELSE
				ynew = unity(index): xnew = unitx(index)
			END IF
		ELSE
			ynew = unity(index): xnew = unitx(index)
		END IF
		
		' If no valid move found yet, try alternatives
		IF ynew = unity(index) AND xnew = unitx(index) THEN
			IF RND > .4 AND dx > dy THEN
				xnew = unitx(index) + 2 * dxs
			ELSEIF dy > 0 AND dx > 0 THEN
				ynew = unity(index) + dys: xnew = unitx(index) + dxs
			ELSEIF dx > 1 THEN
				xnew = unitx(index) + 2 * dxs
			ELSEIF dy > 0 THEN
				ynew = unity(index) + dys: xnew = unitx(index) - 1
				IF xnew < 2 THEN xnew = xnew + 2
			END IF
		END IF
	END IF
	
	' Execute movement (slide section)
	COLOR 4: IF index > 10 THEN COLOR 9
	CALL placeunit(xnew, ynew, index)
END SUB

'============================================================================
' Command Processing Functions
'============================================================================

'============================================================================
' Process Movement Command - Process arrow key movement
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   commnd$ (STRING) - Command string
'   t$ (STRING) - Unit type string
'   limber (INTEGER) - Limber flag
' Returns:
'   INTEGER - 1 if command processed, 0 to continue command loop
' Description:
'   Processes arrow key movement commands. Handles unit movement, checks
'   for blocking, and updates unit position.
'============================================================================
FUNCTION ProcessMovementCommand% (active AS INTEGER, commandStr AS STRING, unitTypeStr AS STRING, limber AS INTEGER)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	
	IF LEFTY$(active) = "S" THEN
		CALL clrbot: COLOR 14: PRINT "Hollow squares may not move"; : CALL PlayNoise1
		' Return to command input loop
		ProcessMovementCommand% = 0
		EXIT FUNCTION
	END IF
	
	' Check if artillery needs to be limbered
	IF limber > 0 AND INSTR("A", unitTypeStr) > 0 THEN
		IF LEFTY$(active) <> "L" THEN
			CALL limbo(active, 2)
			IF LEFTY$(active) = "L" THEN
				' Unit is now limbered, continue to movement
			ELSE
				' Limbering cancelled, return to command input
				ProcessMovementCommand% = 1
				EXIT FUNCTION
			END IF
		END IF
	END IF
	
	' Get movement target from cursor
	xloc = unitx(active): yloc = unity(active)
	CALL curser(commandStr, xloc, yloc)
	
	IF yloc = unity(active) AND xloc = unitx(active) THEN
		' No movement - return to command input
		CALL PlayNoise1
		ProcessMovementCommand% = 0
		EXIT FUNCTION
	END IF
	
	' Attempt to move unit
	CALL placeunit(xloc, yloc, active)
	IF uorder(active) = 1 THEN
		' Movement blocked
		COLOR 14: clrbot: PRINT "Cannot move in that direction "; : CALL PlayNoise2: CALL TICK(1): uorder(active) = 0
		' Return to command input loop
		ProcessMovementCommand% = 0
		EXIT FUNCTION
	ELSE
		' Movement successful
		CALL inspect(active)
		' Command processed, exit command loop
		ProcessMovementCommand% = 1
		EXIT FUNCTION
	END IF
END FUNCTION

'============================================================================
' Process Enemy Unit AI - Process enemy unit turn
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   t$ (STRING) - Unit type string
'   movesleft (INTEGER) - Remaining moves
' Returns:
'   INTEGER - Updated movesleft value
' Description:
'   Processes AI-controlled enemy unit turn. Handles unit behavior including
'   hollow squares, infantry terrain bonuses, artillery firing, and movement.
'============================================================================
FUNCTION ProcessEnemyUnit% (active AS INTEGER, unitTypeStr AS STRING, movesleft AS INTEGER)
	DIM a$ AS STRING
	DIM Enemy AS INTEGER
	DIM d AS INTEGER
	DIM x AS SINGLE
	DIM flag AS INTEGER
	
	IF flag = 0 THEN CALL kleer: flag = 1
	COLOR 11: CALL clrbot: LOCATE 23, 50: PRINT name$(active); "'s TURN";
	
	IF strength(active) < 1 THEN
		ProcessEnemyUnit% = 0
		EXIT FUNCTION
	END IF
	
	'............................................................................
	a$ = LEFTY$(active)
	
	' Handle hollow square units
	IF a$ = "S" THEN
		CALL Near1(active, Enemy, d)
		IF timex > .8 * timelimit AND possess <> 3 - side AND bold > 3 THEN
			CALL squares(active, 1)
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		ELSEIF Enemy > 0 AND LEFTY$(Enemy) = "C" AND d < 9 THEN
			ProcessEnemyUnit% = 0
			EXIT FUNCTION
		ELSE
			CALL squares(active, 1)
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		END IF
	END IF
	
	' Handle infantry in specific terrain
	IF a$ = "I" OR (a$ = CHR$(219) AND (terrain(active) = 43 OR terrain(active) = 46)) THEN
		CALL Near1(active, Enemy, d)
		IF Enemy > 0 AND LEFTY$(Enemy) = "C" AND d < 9 THEN
			x = 1.5: IF possess = 3 - side THEN x = 2
			IF bold > 3 THEN x = x * 3 / bold
			IF strength(active) < x * strength(Enemy) THEN
				IF unitx(Enemy) <> objx AND unity(Enemy) <> objy THEN
					CALL squares(active, 2)
					ProcessEnemyUnit% = movesleft
					EXIT FUNCTION
				END IF
			END IF
		END IF
		IF a$ = "I" AND morale(active) > 2 AND (terrain(active) = 43 OR terrain(active) = 46) THEN
			unit$(active) = "Infantry"
			CALL SHOWUNIT(active)
			toa(active) = timex + 1
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		END IF
	END IF
	
	'............................................................................
	' Handle artillery and limbered units
	IF INSTR("AL", a$) THEN
		CALL Near2(active, Enemy, d)
		IF INSTR("A", a$) > 0 AND Enemy > 0 THEN
			CALL cannon(active, Enemy)
			CALL refresh
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		END IF
		IF INSTR("A", a$) > 0 AND Enemy = 0 THEN
			CALL limbo(active, 0)
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		END IF
		IF Enemy > 0 AND a$ = "L" THEN
			CALL limbo(active, 0)
			ProcessEnemyUnit% = movesleft
			EXIT FUNCTION
		END IF
	END IF
	
	'............................................................................
	' Move toward objective if close
	d = 2 * ABS(unity(active) - objy) + ABS(unitx(active) - objx)
	IF d < 8 AND possess <> 3 - side AND a$ <> "R" THEN
		uorder(active) = 100 * objy + objx
	END IF
			
	IF uorder(active) > 0 THEN
		CALL cupdate(active)
		IF uorder(active) = 1 THEN movesleft = 0
		ProcessEnemyUnit% = movesleft
		EXIT FUNCTION
	END IF
	
	' Rest if morale is low
	IF morale(active) < 3 THEN
		CALL rest(active)
		ProcessEnemyUnit% = movesleft
		EXIT FUNCTION
	END IF
	
	' Use general AI
	CALL general(active)
	CALL valid(active)
	
	' Execute movement orders
	DO
		IF uorder(active) > 0 THEN CALL cupdate(active)
		CALL see(active)
		IF uorder(active) = 0 OR movesleft = 0 THEN EXIT DO
	LOOP
	ProcessEnemyUnit% = 0
END FUNCTION

'============================================================================
' Update Unit After Action - Update unit after action
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   t$ (STRING) - Unit type string
'   movesleft (INTEGER) - Remaining moves
' Returns:
'   INTEGER - 1 if unit should continue processing, 0 otherwise
' Description:
'   Updates unit display and visibility after an action. Clears blocked
'   orders and updates time of action if turn is complete.
'============================================================================
FUNCTION UpdateUnitAfterAction% (active AS INTEGER, unitTypeStr AS STRING, movesleft AS INTEGER)
	CALL SHOWUNIT(active)
	IF INSTR("AL", unitTypeStr) > 0 THEN CALL refresh
	
	' Update unit visibility and orders
	IF strength(active) > 0 AND uorder(active) <> 99 THEN CALL see(active)
	
	' Clear blocked orders
	IF uorder(active) = 1 THEN uorder(active) = 0
	
	' Check if unit has more moves left
	IF movesleft > 0 THEN
		' Unit can continue acting - return to processing
		UpdateUnitAfterAction% = 1
	ELSE
		' Unit's turn is complete - update time of action
		IF toa(active) <= timex THEN toa(active) = timex + 1
		CALL valid(active)
		UpdateUnitAfterAction% = 0
	END IF
END FUNCTION

'============================================================================
' Cursor Command Processing
'============================================================================

'============================================================================
' Process Cursor Command - Process cursor-controlled commands
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   dx (INTEGER) - Command type (1=cannon, 2=move, 3=intelligence, 4=inspire, 5=group move)
'   t$ (STRING) - Unit type string
'   limber (INTEGER) - Limber flag
'   commandProcessed (INTEGER) - Command processed flag (modified by reference)
' Returns:
'   INTEGER - 1 if command processed, 0 to continue command loop
' Description:
'   Processes cursor-controlled commands. Handles cannon targeting, movement
'   orders, intelligence gathering, and unit inspiration/rally.
'============================================================================
FUNCTION ProcessCursorCommand% (active AS INTEGER, dx AS INTEGER, unitTypeStr AS STRING, limber AS INTEGER, commandProcessed AS INTEGER)
	DIM xloc AS INTEGER
	DIM yloc AS INTEGER
	DIM x AS INTEGER
	DIM y AS INTEGER
	DIM z AS INTEGER
	DIM id AS INTEGER
	DIM d AS INTEGER
	DIM Enemy AS INTEGER
	DIM F AS INTEGER
	DIM a$ AS STRING
	DIM commnd$ AS STRING
	DIM dxs AS INTEGER
	DIM dys AS INTEGER
	DIM k AS INTEGER
	
	' Initialize based on command type
	SELECT CASE dx
	CASE 1  'cannon
		IF limber = 1 AND LEFTY$(active) = "L" THEN
			CALL limbo(active, 2)
			IF LEFTY$(active) = "L" THEN
				commandProcessed = 1
				ProcessCursorCommand% = 1
				EXIT FUNCTION
			END IF
		END IF
		CALL vistarg(active, 0)
		COLOR 11: clrbot: PRINT "CANNONADE > RANGE:"; vantage; TAB(25); "DISTANCE:"; TAB(60); "TERRAIN:";
		
	CASE 2, 5 'move
		IF rely = 1 THEN
			COLOR 12: CALL clrbot: PRINT "MAXIMUM RELIABILITY : Move Orders Not Allowed": TICK 2
			' Return to command input
			commandProcessed = 0
			ProcessCursorCommand% = 0
			EXIT FUNCTION
		END IF
		COLOR 11: clrbot
		IF dx = 2 THEN PRINT "Hit ENTER to order unit to move to cursor position";
		IF dx = 5 THEN PRINT "GROUP MOVE ORDERS : Hit ENTER to order group to move to cursor position";
		
	CASE 3  'intelligence
		CALL ShowIntelligenceLine

	CASE 4  'inspire
		IF LEFTY$(active) <> "G" THEN
			' Not a general - return to command input
			commandProcessed = 0
			ProcessCursorCommand% = 0
			EXIT FUNCTION
		END IF
		COLOR 11: clrbot: PRINT "INSPIRE : move cursor over friendly unit and press ENTER";
		COLOR 13: PRINT " Range ";
	CASE ELSE
	END SELECT

' Initialize cursor position
yloc = unity(active): xloc = unitx(active): y = yloc: x = xloc
z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))
PUT (8 * x, 14 * y), Xhair, XOR

' Cursor movement loop
DO
	' Update display based on cursor position
	y = yloc: x = xloc: id = 0
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
	
	SELECT CASE dx
		CASE 1  'cannon
			COLOR 11: LOCATE 23, 40: PRINT SPACE$(19);
			CALL whois(xloc, yloc, id, 0)
			COLOR 14: IF d > vantage THEN COLOR 12
			LOCATE 23, 35: PRINT d; " ";
			CALL Tara(69, 23, z)

			IF d <= vantage AND id > 0 AND Visible(id) > 0 THEN
				LOCATE 23, 40: COLOR 11: PRINT name$(id);
			END IF

		CASE 2, 5  'move
			' Display move command info
		CASE 3, 4 'intelligence & inspire
			CALL whois(xloc, yloc, id, 0): IF id > 0 THEN CALL ShowUnitStats(id, dx)
			CALL AwakenUnit(id, xloc, yloc)
			COLOR 13: LOCATE 23, 68: PRINT d;
		CASE ELSE
	END SELECT
	
	' Wait for keypress
	CALL WaitForKeypress(commnd$, dxs, dys)
	
	' Handle ENTER key (execute command)
	IF ASC(commnd$) = 13 THEN
		' Execute command based on dx
		IF dx = 2 OR dx = 5 THEN
			' Move command
			CALL HandleHere(xloc, yloc, active, dx, limber)
			commandProcessed = 1
			ProcessCursorCommand% = 1
			EXIT FUNCTION
		ELSEIF dx = 3 THEN
			' Intelligence - done, return to command input
			CALL FlashCursor(xloc, yloc)
			commandProcessed = 0
			ProcessCursorCommand% = 0
			EXIT FUNCTION
		ELSEIF dx = 4 THEN
			' Rally/Inspire command
			CALL FlashCursor(xloc, yloc)
			' Process rally command
			CALL HandleRAlly(xloc, yloc, id, active)
			commandProcessed = 1
			ProcessCursorCommand% = 1
			EXIT FUNCTION
		ELSEIF dx = 1 THEN
			' Cannon command
			CALL whois(xloc, yloc, Enemy, active)
			IF Enemy = 0 OR Visible(Enemy) = 0 THEN
				CALL FlashCursor(xloc, yloc)
				CALL PlayNoise3
				CALL clrbot
				PRINT "NO ENEMY AT THAT LOCATION !"
				TICK mdly!
				CALL refresh
				' Restart cursor loop
			ELSEIF t$ = "L" AND Enemy <> 0 THEN
					CALL limbo(active, 2)
					commandProcessed = 1
					ProcessCursorCommand% = 1
					EXIT FUNCTION
				END IF

				IF d < 4 AND (active < m2 AND Enemy < m2) OR (active > m1 AND Enemy > m1) THEN
					' Too close to friendly unit - treat as move
					dx = 2
					' Continue to move processing
				ELSE
					' Check line of sight and range
					CALL los(active, Enemy, F, 0)
					IF Visible(Enemy) = 0 THEN Visible(Enemy) = 1

					a$ = ""
					IF d > vantage THEN a$ = "ENEMY IS OUT OF RANGE !"
					IF F < 1 THEN a$ = "NOT IN LINE OF SIGHT !"
					IF a$ <> "" THEN
						CALL FlashCursor(xloc, yloc)
						CALL PlayNoise3
						CALL clrbot
						PRINT a$
						TICK .2 * mdly!
						' Restart cursor loop
					ELSE
						' Fire cannon
						IF quiet >= 1 THEN
							FOR k = 1 TO 6: SOUND 37 + 40 * RND, 1: NEXT k
							FOR k = 4000 TO 2800 STEP -100: SOUND k, .8: NEXT k
						END IF
						CALL cannon(active, Enemy)
						commandProcessed = 1
						ProcessCursorCommand% = 1
						EXIT FUNCTION
					END IF
				END IF
			END IF
		END IF
	ELSE
		' Handle other keys
		CALL curser(commnd$, xloc, yloc)
		CALL FlashCursor(xloc, yloc)
		PUT (8 * x, 14 * y), Xhair, XOR
		z = ASC(MID$(sdtext$(yloc + 1), xloc, 1))

		SELECT CASE dxs
			CASE 27
				' ESC - cancel, return to command input
				CALL FlashCursor(xloc, yloc): CALL refresh
				commandProcessed = 0
				ProcessCursorCommand% = 0
				EXIT FUNCTION
			CASE 32
				' Space - rest unit
				CALL FlashCursor(xloc, yloc): CALL rest(active)
				commandProcessed = 1
				ProcessCursorCommand% = 1
				EXIT FUNCTION
			CASE 76
				' L - limber/unlimber
				CALL FlashCursor(xloc, yloc): CALL limbo(active, 1)
				commandProcessed = 1
				ProcessCursorCommand% = 1
				EXIT FUNCTION
			CASE 87
				' W - wait
				CALL WaitUnit(active)
				commandProcessed = 1
				ProcessCursorCommand% = 1
				EXIT FUNCTION
			CASE ELSE
				' Continue cursor loop
		END SELECT
	END IF
	LOOP
	
	' Return 0 to continue command loop (shouldn't reach here normally)
	ProcessCursorCommand% = 0
END FUNCTION

'============================================================================
' Order Helper Functions
'============================================================================

'============================================================================
' Draw Command Line - Draw command interface
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
'   t$ (STRING) - Unit type string
'   limber (INTEGER) - Limber flag
' Description:
'   Draws the command interface at the bottom of the screen showing
'   available commands for the current unit.
'============================================================================
SUB DrawCommandLine (active AS INTEGER, unitTypeStr AS STRING, limber AS INTEGER)
	COLOR 14: CALL clrbot
	PRINT "UNIT"; active; name$(active);
	LINE (4, 334)-(639, 349), 8, BF
	COLOR 8
	CALL BUTTON(27, 25, 4, "rest", 0)
	CALL BUTTON(33, 25, 4, "Intell", 0)
	CALL BUTTON(41, 25, 4, "Wait", 0)
	CALL BUTTON(70, 21, 1, "F9:RETREAT", 0)
	SELECT CASE t$
		CASE "A", "L"
			IF limber > 0 THEN
			CALL BUTTON(58, 25, 4, "Limber", 0)
			END IF
		CASE "I"
		IF morale(active) > 2 AND (terrain(active) = 46 OR terrain(active) = 43) THEN
			CALL BUTTON(58, 25, 4, "Charge", 0)
		END IF
		CASE "G"
			CALL BUTTON(58, 25, 4, "(X)ancel", 0)
			CALL BUTTON(67, 25, 4, "i(N)spire", 0)
		CASE ELSE
	END SELECT
	COLOR 11
END SUB

'============================================================================
' Wait For Keypress - Wait for keypress with special handling
'============================================================================
' Parameters:
'   commnd$ (STRING) - Input key (modified by reference)
'   dxs, dys (INTEGER) - Key codes (modified by reference)
' Description:
'   Waits for keypress and processes special keys like F1 (help) and
'   arrow keys. Handles extended key codes.
'============================================================================
SUB WaitForKeypress (commandStr AS STRING, dxs AS INTEGER, dys AS INTEGER)
	DIM a AS INTEGER
	DO
		commandStr = INKEY$
		IF commandStr <> "" THEN
			dxs = ASC(UCASE$(commnd$)): dys = LEN(commnd$)
			IF dxs = 27 OR dxs = 32 OR dxs = 76 OR dxs = 88 THEN EXIT DO
			IF dxs = 13 THEN EXIT DO
			IF dys = 1 AND ASC(commnd$) > 48 AND ASC(commnd$) < 58 THEN EXIT DO
			IF dys >= 2 THEN
				a = LEN(commnd$)
				commnd$ = RIGHT$(commnd$, 1)
				SELECT CASE ASC(commnd$)
				CASE 59
					CALL help
				CASE 68
					IF a = 2 THEN CLS : file$ = CHR$(219): EXIT DO
				CASE ELSE
					EXIT DO
				END SELECT
			END IF
		END IF
	LOOP
END SUB

'============================================================================
' Can Place Unit - Check if late-arriving unit can be placed
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
' Description:
'   Checks if a late-arriving unit (uorder=99) can be placed on the map.
'   Handles unit visibility and initial orders.
'============================================================================
SUB CanPlaceUnit (active AS INTEGER)
	DIM id AS INTEGER
	DIM s AS INTEGER
	DIM a$ AS STRING
	DIM F AS INTEGER
	DIM Enemy AS INTEGER
	DIM d AS INTEGER
	DIM k AS INTEGER
	DIM x AS INTEGER
	DIM y AS INTEGER
	DIM t$ AS STRING
	
	CALL whois(unitx(active), unity(active), id, active)
	IF id > 0 THEN EXIT SUB
	s = 1: IF active > m1 THEN s = 2
	uorder(active) = 0: a$ = unit$(active)
	CALL YouorMe(active, F): IF F > 0 THEN Visible(active) = 1: a$ = name$(active)
	clrbot
	COLOR 15: PRINT sname$(s); " "; a$; " is joining the battle";
	CALL see(active)
	t$ = LEFTY$(active)
	IF limber > 0 AND INSTR("A", t$) > 0 THEN unit$(active) = "L" + unit$(active): t$ = LEFTY$(active)
	y = 14 * unity(active): x = 8 * unitx(active)

	IF Visible(active) > 0 THEN
		FOR k = 1 TO 5
		ATTENTION active, 15: IF quiet > 0 THEN CALL PlayNoise1
		NEXT k
	END IF

	CALL YouorMe(active, F)
	IF F > 0 AND t$ = "G" THEN EXIT SUB
	CALL Near2(active, Enemy, d)
	TICK .5 * mdly!
	IF Enemy = 0 OR RND > .5 THEN uorder(active) = 100 * objy + objx: EXIT SUB
	IF t$ = "A" THEN CALL cannon(active, Enemy): EXIT SUB
	uorder(active) = 100 * unity(Enemy) + unitx(Enemy)
	IF F > 0 THEN TICK .2 * mdly!
END SUB

'============================================================================
' Cancel Orders - Cancel orders for units under general's command
'============================================================================
' Parameters:
'   active (INTEGER) - General unit index
'   side (INTEGER) - Side number
'   x, y (INTEGER) - Output counts (modified by reference)
' Description:
'   Allows a general to cancel orders for units under their command.
'   Units may or may not obey based on leadership.
'============================================================================
SUB CancelOrders (active AS INTEGER, side AS INTEGER, x AS INTEGER, y AS INTEGER)
	DIM s AS INTEGER
	DIM F AS INTEGER
	DIM i AS INTEGER
	
	CALL clrbot: PRINT " General "; name$(active); " cancelling orders : ";
	x = 0: y = 0: s = 1: F = bigg(side): IF side = 2 THEN s = m2
	FOR i = s TO F
		' Skip invalid units
		IF strength(i) = 0 OR uorder(i) < 1 OR uorder(i) = 99 THEN
			' Skip this unit
		ELSEIF LEFTY$(i) = "R" THEN
			' Routed unit - skip
		ELSE
			y = y + 1
			IF RND < .2 * leader(active) THEN
				uorder(i) = 0
				CALL ATTENTION(i, 13)
				IF quiet > 0 THEN SOUND 2900, .1: TICK .02
				' Unit order cancelled
			ELSE
				x = x + 1
			END IF
		END IF
	NEXT i
	IF y = 0 THEN PRINT "NO UNITS UNDER ORDERS"; : TICK .2 * mdly!: CALL clrbot: EXIT SUB
	movesleft = movesleft - 1
	PRINT y - x; " of "; y; " units obeyed"; : TICK .2 * mdly!: CALL clrbot
END SUB

'============================================================================
' Refresh Ahead - Refresh display and show expire screen
'============================================================================
' Parameters:
'   active (INTEGER) - Unit index
' Description:
'   Refreshes the display and shows the expire (battle status) screen.
'============================================================================
SUB RefreshAhead (active AS INTEGER)
	CALL expire
	CALL mainmap: CALL refresh: CALL inspect(active)
END SUB

'============================================================================
' Handle RAlly - Handle rally/inspire command
'============================================================================
' Parameters:
'   xloc, yloc (INTEGER) - Target location
'   index (INTEGER) - Target unit index (output)
'   active (INTEGER) - General unit index
' Description:
'   Handles rally/inspire command from a general to another unit.
'   Attempts to rally routed units or inspire friendly units.
'============================================================================
SUB HandleRAlly (xloc AS INTEGER, yloc AS INTEGER, index AS INTEGER, active AS INTEGER)
	CALL whois(xloc, yloc, index, active)
	IF index = 0 OR (side = 1 AND index > m1) OR (side = 2 AND index < m2) THEN EXIT SUB
	IF LEFTY$(index) = "w" THEN unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1): CALL SHOWUNIT(index): EXIT SUB
	CALL ranger(active, vantage)
	IF d > .8 * vantage THEN COLOR 12: clrbot: PRINT "Too far to communicate"; : TICK mdly!: EXIT SUB
	clrbot
	IF leader(active) + morale(active) + xper(active) + 2 * RND < leader(index) + morale(index) + xper(index) THEN
		COLOR 12: PRINT name$(active); " cannot rally "; unit$(index);
		leader(active) = leader(active) - 1
		' Continue to cleanup (payit section)
	ELSE
		COLOR 11: PRINT unit$(index); " is rallying...";
		FOR k = 1 TO 3: ATTENTION index, 14
		IF quiet > 0 THEN SOUND 900, 1: SOUND 999, .7
		NEXT k
		IF LEFTY$(index) <> "R" THEN
			toa(active) = toa(index): toa(index) = timex
			IF morale(index) < 4 THEN morale(index) = morale(index) + 1
		ELSE
			unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
			CALL SHOWUNIT(index)
		END IF
		
		uorder(index) = 0
	END IF
	
	' Cleanup (payit section)
	CALL despair(active)
	CALL SHOWUNIT(active)
	CALL valid(active)
	TICK 2
END SUB

'============================================================================
' Handle Here - Handle move order to location
'============================================================================
' Parameters:
'   xloc, yloc (INTEGER) - Target location
'   active (INTEGER) - Unit index
'   dx (INTEGER) - Command type (2=move, 5=group move)
'   limber (INTEGER) - Limber flag
' Description:
'   Handles move order to a specific location. Sets unit order and handles
'   artillery limbering if needed.
'============================================================================
SUB HandleHere (xloc AS INTEGER, yloc AS INTEGER, active AS INTEGER, dx AS INTEGER, limber AS INTEGER)
	COLOR 14: CALL clrbot
	IF toa(active) <= timex THEN toa(active) = timex + 1
	IF dx = 5 THEN
		PRINT unit$(active); " "; name$(active); " has given orders to move to ("; xloc; ","; yloc; ") and";
		' Note: Original code had array assignments here that were commented out
		PRINT "units obeyed";
		CALL FlashCursor(xloc, yloc)
	END IF

	IF dx <> 2 THEN EXIT SUB
	uorder(active) = 100 * yloc + xloc
	t$ = LEFTY$(active)
	IF limber > 0 AND INSTR("A", t$) > 0 THEN
		CALL limbo(active, 2)
		CALL FlashCursor(xloc, yloc)
		IF LEFTY$(active) = "L" THEN EXIT SUB
	END IF
	CALL ranger(active, vantage)
	d = 2 * ABS(unity(active) - yloc) + ABS(unitx(active) - xloc)
	IF d = 0 THEN EXIT SUB
	IF dx = 2 AND d < 4 THEN
		uorder(active) = 100 * yloc + xloc
		CALL cupdate(active)
		IF uorder(active) = 1 THEN uorder(active) = 0: CALL TICK(.5): CALL FlashCursor(xloc, yloc): EXIT SUB
		uorder(active) = 0
	ELSE
		CALL target(active)
		CALL FlashCursor(xloc, yloc)
		CALL clrbot
	END IF
END SUB

'============================================================================
' Awaken Unit - Awaken waited unit
'============================================================================
' Parameters:
'   id (INTEGER) - Unit index
'   xloc, yloc (INTEGER) - Location coordinates
' Description:
'   Awakens a unit that was in wait state (unit type starts with "w").
'============================================================================
SUB AwakenUnit (id AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)
	DIM F AS INTEGER
	IF LEFTY$(id) = "w" THEN
		CALL YouorMe(id, F)
		IF F > 0 THEN
			unit$(id) = RIGHT$(unit$(id), LEN(unit$(id)) - 1)
			CALL SHOWUNIT(id)
			CALL FlashCursor(xloc, yloc)
		END IF
	END IF
END SUB

'============================================================================
' Flash Cursor - Flash cursor at location
'============================================================================
' Parameters:
'   xloc, yloc (INTEGER) - Location coordinates
' Description:
'   Flashes the cursor (Xhair sprite) at the specified location using XOR.
'============================================================================
SUB FlashCursor (xloc AS INTEGER, yloc AS INTEGER)
	PUT (8 * xloc, 14 * yloc), Xhair, XOR
END SUB

