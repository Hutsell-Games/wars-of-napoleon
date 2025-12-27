'============================================================================
' Tactical Utilities Module
'============================================================================
' Helper functions used throughout the tactical battle system
' Includes: line of sight, range calculations, proximity, cursor movement,
' unit identification, timing, and other utility functions
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Line of Sight and Range Calculations
'============================================================================

SUB los (index, Enemy, F, flag)
'  F=-1 : friendly  F=0 : no LOS    F=1 : Enemy in LOS
' flag=cursor flag   0=invisible  1=visible
	IF lineofsight = 0 THEN F = 1: EXIT SUB
	F = 0
	IF index = Enemy THEN F = -1: EXIT SUB

	plus = 1
	SELECT CASE terrain(index)
		CASE 94
		plus = 2
		CASE 176
		plus = 5
		CASE 239
		plus = 3
	END SELECT

	xnew = unitx(index): ynew = unity(index)
	spin = 0
DO
	spin = spin + 1: IF spin > 99 THEN F = 0: EXIT SUB
	dxs = SGN(unitx(Enemy) - xnew)
	dys = SGN(unity(Enemy) - ynew)
	dx = ABS(unitx(Enemy) - xnew)
	dy = ABS(unity(Enemy) - ynew)
	IF dx > 4 * dy THEN
		xnew = xnew + 2 * dxs
	ELSEIF dxs = 0 THEN dxs = 1: IF xnew > 28 THEN dxs = -1
		xnew = xnew + dxs: ynew = ynew + dys
	END IF
	
	z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
	IF (z = 42 OR z = 254) THEN plus = plus - 1
	IF z = 94 THEN plus = plus - 2
	IF z = 239 THEN plus = plus - 5
	IF xnew = unitx(Enemy) AND ynew = unity(Enemy) THEN F = 1: EXIT SUB
	IF plus < 1 THEN F = 0: EXIT SUB
	IF flag > 0 THEN PUT (8 * xnew, 14 * ynew), Xhair, XOR: TICK .03: PUT (8 * xnew, 14 * ynew), Xhair, XOR
LOOP
END SUB

SUB ranger (attack, vantage)
vantage = seelimit: IF terrain(attack) = 94 THEN vantage = seelimit + 2
IF terrain(attack) = 239 THEN vantage = seelimit + 4
IF terrain(attack) = 42 THEN vantage = seelimit - 2
IF terrain(attack) = 61 THEN vantage = seelimit - 4
END SUB

SUB proximity (index, bonus)
	s = 1: F = bigg(1): IF index > m1 THEN s = m2: F = bigg(2)
	bonus = 0
	FOR k = s TO F
		' Skip self or hidden units
		IF index = k OR uorder(k) = 99 THEN
			' Too far or invalid, skip
		ELSEIF 2 * ABS(unity(index) - unity(k)) + ABS(unitx(index) - unitx(k)) > 3 THEN
			' Too far, skip
		ELSE
			' Unit is nearby, calculate bonus
			IF morale(k) + leader(k) > 7 THEN bonus = bonus + 2: IF leader(k) = 4 THEN bonus = bonus + 2
			a$ = LEFTY$(k)
			SELECT CASE a$
				CASE "G"
					bonus = bonus + .15 * leader(k)
					IF leader(k) = 5 THEN bonus = bonus + leader(k)
				CASE "R"
					bonus = -10
			END SELECT
		END IF
	NEXT k
END SUB

'============================================================================
' Mathematical and Statistical Functions
'============================================================================

SUB normal (xbar, vary, result)
' NOTE : vary is VARIANCE
pct! = 0
FOR k = 1 TO 12: pct! = pct! + RND: NEXT k
pct! = pct! - 5.5
result = xbar + pct! * SQR(vary)
END SUB

'============================================================================
' Cursor and Movement Utilities
'============================================================================

SUB curser (a$, xloc, yloc)
SELECT CASE a$
	CASE "G"
		' Move northwest
		IF yloc > 1 THEN
			xloc = xloc - 1
			yloc = yloc - 1
		END IF
	CASE "H"
		' Random northwest or northeast
		IF RND > .5 THEN
			IF yloc > 1 THEN
				xloc = xloc - 1
				yloc = yloc - 1
			END IF
		ELSE
			IF yloc > 1 THEN
				xloc = xloc + 1
				yloc = yloc - 1
			END IF
		END IF
	CASE "I"
		' Move northeast
		IF yloc > 1 THEN
			xloc = xloc + 1
			yloc = yloc - 1
		END IF
	CASE "K"
	xloc = xloc - 2
	yloc = yloc
	CASE "M"
	xloc = xloc + 2
	yloc = yloc
	CASE "O"
		' Move southwest
		IF yloc < 20 THEN
			xloc = xloc - 1
			yloc = yloc + 1
		END IF
	CASE "P"
		' Random southwest or southeast
		IF RND > .5 THEN
			IF yloc < 20 THEN
				xloc = xloc - 1
				yloc = yloc + 1
			END IF
		ELSE
			IF yloc < 20 THEN
				xloc = xloc + 1
				yloc = yloc + 1
			END IF
		END IF
	CASE "Q"
		' Move southeast
		IF yloc < 20 THEN
			xloc = xloc + 1
			yloc = yloc + 1
		END IF
	xloc = xloc + 1

	CASE "1"
	yloc = 20: xloc = 2
	CASE "2"
	yloc = 20
	CASE "3"
	yloc = 20: xloc = 54
	CASE "4"
	xloc = 2
	CASE "5"
	yloc = 10: xloc = 28
	CASE "6"
	xloc = 54
	CASE "7"
	yloc = 1: xloc = 1
	CASE "8"
	yloc = 1
	CASE "9"
	yloc = 1: xloc = 55
	CASE ELSE
END SELECT
IF xloc > 53 THEN xloc = 54
IF xloc < 2 THEN xloc = 2
IF yloc < 1 THEN yloc = 1
IF yloc > 20 THEN yloc = 20
z = INT(.5 * (xloc + yloc)) * 2 - xloc - yloc
IF z <> 0 AND xloc < 27 THEN xloc = xloc + 1
IF z <> 0 AND xloc > 26 THEN xloc = xloc - 1
END SUB

'============================================================================
' Unit Identification and String Utilities
'============================================================================

FUNCTION LEFTY$ (index)
LEFTY$ = LEFT$(unit$(index), 1)
END FUNCTION

SUB whois (x, y, Enemy, index)
	Enemy = 0
	FOR k = 1 TO bigg(2)
		' Skip invalid units or self
		IF strength(k) < 1 OR uorder(k) = 99 OR index = k THEN
			' Skip this unit
		ELSEIF unitx(k) = x AND unity(k) = y THEN
			Enemy = k
			EXIT SUB
		END IF
	NEXT k
END SUB

SUB YouorMe (index, F)
F = 0: IF side = 1 AND index < m2 THEN F = 1
IF side = 2 AND index > m1 THEN F = 1
END SUB

SUB namer (file$, s, F, a$)
	a$ = ""
	spin = 0
	
	' Retry loop for name generation (redoz section)
	DO
		spin = spin + 1
		' QB64-compatible file existence check
		IF NOT _FILEEXISTS(file$) THEN
			a$ = "Unknown"
			EXIT SUB
		END IF
		' Use SafeOpenFile% for error handling
		IF SafeOpenFile%(file$, "I", 1) = 1 THEN
			INPUT #1, a
			x = 1 + INT(a * RND)
			FOR j = 1 TO x
				INPUT #1, a$
			NEXT j
			CLOSE #1
		ELSE
			' File open failed - use default name
			a$ = "Unknown"
			EXIT SUB
		END IF
		
		' Check for duplicate names
		DIM nameCollision AS INTEGER
		nameCollision = 0
		FOR k = s TO F
			IF strength(k) > 0 THEN
				IF name$(k) = a$ THEN
					nameCollision = 1
					EXIT FOR
				END IF
			END IF
		NEXT k
		
		' If no collision or too many retries, exit loop
		IF nameCollision = 0 OR spin >= 50 THEN EXIT DO
	LOOP
	
	IF a$ = "" THEN a$ = "Elmo"
END SUB

'============================================================================
' Time and Game State Utilities
'============================================================================

SUB lowtime
	timex = 32767
	FOR k = 1 TO bigg(2)
	IF strength(k) > 0 AND toa(k) < timex THEN timex = toa(k)
	NEXT k
END SUB

SUB TICK (sec!)
start! = TIMER
sec! = ABS(sec!)
IF sec! < 1 THEN
	DO WHILE TIMER - start! < sec!: LOOP: EXIT SUB
END IF
DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP: EXIT SUB
END SUB

SUB brittle (who%)
IF elan(who%) > 100 THEN elan(who%) = 100
IF elan(who%) < 1 THEN
	elan(who%) = 0
	LINE (40, 110)-(420, 200), 0, BF
	c = 4: IF who% = 2 THEN c = 1
	LINE (40, 100)-(410, 190), c, BF
	LINE (50, 110)-(400, 180), 4, B
	COLOR 15: LOCATE 11, 10: PRINT "Entire " + sname$(who%) + " army has BROKEN IN PANIC !"
	IF quiet > 0 THEN PLAY "t180o3c4c8.c16g4.P8e4g8.e16c2"
	TICK 3
	CALL over(who%)
END IF
END SUB

SUB BuffClear
' QB64 doesn't need direct memory access for keyboard buffer
' Keyboard input is handled automatically by QB64
' Removed DEF SEG and POKE operations for QB64 compatibility
END SUB

'============================================================================
' Game State Management
'============================================================================

' Handles game over condition and writes outcome file
' Parameters:
'   flag - Side that won (1 or 2)
SUB over (flag)
	' Use SafeOpenFile% for error handling
	IF SafeOpenFile%("data\outcome.&&&", "O", 1) = 1 THEN
		WRITE #1, 3 - sidex(flag), .01 * score&(sidex(1)), .01 * score&(sidex(2))    'scale down unit size
		CLOSE #1
	ELSE
		' File open failed - error already displayed by SafeOpenFile%
		' Continue to END anyway
	END IF
	END
END SUB

'============================================================================
' Sound Effects
'============================================================================

SUB PlayNoise1
	IF quiet > 0 THEN SOUND 1900, 1
END SUB

SUB PlayNoise2
	IF quiet > 0 THEN SOUND 400, .7
END SUB

SUB PlayNoise3
	IF quiet > 0 THEN SOUND 600, .5
END SUB

SUB PlayFranksSound
	IF quiet > 0 THEN PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
END SUB

SUB PlayYanksSound
	IF quiet > 0 THEN PLAY "T150O3L8C;FCFG;A4G"
END SUB

'============================================================================
' Unit Proximity Finding (for AI)
'============================================================================

SUB Near1 (index, Enemy, near)
	t$ = LEFTY$(index)
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL ranger(index, vantage)
	near = 32767: Enemy = 0
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2): flag = 0

	FOR i = s TO F
		' Skip invalid units
		IF strength(i) < 1 OR uorder(i) = 99 THEN
			' Skip this unit
		ELSE
			d = 2 * ABS(unity(index) - unity(i)) + ABS(unitx(index) - unitx(i))
			IF d <= vantage THEN
				IF d < near THEN near = d: Enemy = i
			END IF
		END IF
	NEXT i
END SUB

SUB Near2 (index, Enemy, near)
	t$ = LEFTY$(index)
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2)
	CALL ranger(index, vantage)
	near = 32767: Enemy = 0
	s = 1: F = bigg(1): IF index < m2 THEN s = m2: F = bigg(2): flag = 0

	FOR i = s TO F
		' Skip invalid units
		IF strength(i) < 1 OR uorder(i) = 99 THEN
			' Skip this unit
		ELSE
			d = 2 * ABS(unity(index) - unity(i)) + ABS(unitx(index) - unitx(i))
			IF d > vantage THEN
				' Too far, skip
			ELSE
				' Calculate priority score
				dx = 100 - d
				IF t$ = "R" THEN dx = dx + 150
				IF INSTR("AL", t$) = 0 THEN
					IF strength(i) > 1.2 * strength(index) THEN dx = dx - 20
					IF strength(index) > 1.2 * strength(i) THEN dx = dx + 20
					IF strength(index) > 2 * strength(i) THEN dx = dx + 50
				ELSE
					CALL los(index, i, F, 0)
					IF Visible(i) = 0 THEN Visible(i) = 1
					IF F = 1 THEN dx = 5 ELSE dx = -999
				END IF
				IF d < near THEN dx = dx + 20
				a$ = LEFTY$(i): IF a$ = "w" THEN a$ = MID$(unit$(i), 2, 1)
				IF INSTR("AEHL", a$) > 0 THEN dx = dx + 50 + 150 * RND
				IF d < 8 THEN dx = dx + 20
				IF d < 6 THEN dx = dx + 50
				IF d < 4 THEN dx = dx + 100: IF INSTR("AEHLB", t$) THEN dx = dx + 100 + 20 * RND
				IF terrain(i) = 233 THEN dx = dx + 150
				IF dx > flag THEN near = d: flag = dx: Enemy = i
			END IF
		END IF
	NEXT i
END SUB

