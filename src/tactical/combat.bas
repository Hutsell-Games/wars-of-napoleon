'============================================================================
' Tactical Combat System
'============================================================================
' Handles all combat-related functions: cannon, musket, combat, retreat, pursue
' Includes damage calculations, fire effectiveness, retreat logic, and pursuit
'
' Note: game_types.bas is included in main.bas
' Note: All tactical arrays and variables are declared in nap10.bi or battle_types.bas

'============================================================================
' Cannon Combat
'============================================================================

SUB cannon (attack, defend)
	IF defend = 0 THEN uorder(attack) = 0: EXIT SUB
	IF Visible(defend) = 0 OR uorder(defend) = 99 THEN EXIT SUB
	CALL los(attack, defend, F, 0)

	SELECT CASE F
	CASE IS < 0
		EXIT SUB
	CASE 0
		IF (attack < m2 AND side = 1) OR (attack > m1 AND side = 2) THEN
			CALL clrbot: COLOR 14: PRINT "NOT IN LINE OF SIGHT !"; : TICK mdly!: CALL clrbot: EXIT SUB
		END IF
	CASE ELSE
	END SELECT

	CALL ranger(attack, vantage)
	PLAY "MF"
	d = 2 * ABS(unity(attack) - unity(defend)) + ABS(unitx(attack) - unitx(defend))
	IF d > vantage THEN EXIT SUB

	bonus = 2 * difficult - 4: IF difficult > 3 AND attack > m1 THEN bonus = bonus + 2
	CALL YouorMe(attack, F): IF F > 0 THEN bonus = 0
	CALL YouorMe(defend, F): IF F > 0 THEN CALL inspect(defend)

	u$ = LEFTY$(attack)
	movesleft = 0
	COLOR 4: IF attack > m1 THEN COLOR 9
	clrbot
	PRINT name$(attack);
	COLOR 11: PRINT " cannons fired at "; name$(defend);
	c = POS(0)
	y = 14 * unity(attack): x = 8 * unitx(attack)
	CIRCLE (x + 6, y + 6), 4, 14
	PAINT (x + 6, y + 6), 12, 14

	CALL los(attack, defend, F, 1)

	IF uorder(attack) > -1 THEN uorder(attack) = 0

	' Calculate cannon damage
	CALL CalculateCannonDamage(attack, defend, d, vantage, bonus, killed)
	
	' Display firing effects
	LOCATE 23, c: PRINT "... killing "; killed; : TICK mdly!
	Visible(attack) = 1
	CALL SHOWUNIT(defend)
	CALL SHOWUNIT(attack)

	CALL despair(defend)

	dx = .05 * strength(defend)
	IF terrain(defend) = 35 THEN dx = .1 * strength(defend)
	IF 15 * RND < leader(defend) + morale(defend) THEN dx = dx + .02 * strength(defend)
	strength(defend) = strength(defend) - killed
	IF strength(defend) < 1 THEN CALL wipeout(defend): IF defend = 0 THEN EXIT SUB
	IF killed > dx THEN
		IF RND > .1 * morale(defend) THEN CALL retreat(defend, attack)
	END IF
	i = 1: IF defend > m1 THEN i = 2
	score&(i) = score&(i) + killed
	
	' Update time of action for both units
	toa(attack) = timex + 1 + 4 * RND
	IF morale(attack) < 3 THEN toa(attack) = toa(attack) + 1: IF morale(attack) < 2 THEN toa(attack) = toa(attack) + 3
	IF leader(attack) < 3 THEN toa(attack) = toa(attack) + 2
	toa(defend) = timex + 2 + 6 * RND: IF RND > .7 THEN toa(defend) = toa(defend) + 3
	CALL scrcol(2)
	
	' Check if cannon should explode early (objective reached or friendly fire)
	IF CheckCannonExplosion%(attack, defend, F) THEN
		' Cannon exploded - exit early
		EXIT SUB
	END IF
	
	' Handle defender fleeing if not exploding
	IF uorder(defend) = 0 AND rely > 1 AND RND > .4 + .1 * bold AND morale(defend) > 3 THEN
		IF LEFTY$(defend) <> "A" THEN
			uorder(defend) = 100 * unity(attack) + unitx(attack)
			CALL flee(defend)
		END IF
	END IF
	
	' Check for cannon explosion (always checked at end)
	IF CheckCannonExplosion%(attack, defend, F) THEN
		' Cannon exploded - exit
		EXIT SUB
	END IF
END SUB

' Calculates cannon damage based on range, terrain, and unit types
SUB CalculateCannonDamage (attack AS INTEGER, defend AS INTEGER, d AS INTEGER, vantage AS INTEGER, bonus AS INTEGER, killed AS INTEGER)
	DIM flag AS INTEGER
	DIM dx AS INTEGER
	DIM killed2 AS INTEGER
	DIM a AS INTEGER
	DIM i AS INTEGER
	DIM u$ AS STRING
	
	' Calculate base flag value
	flag = 1 + bonus: IF RND > .8 THEN flag = flag + 1
	
	' Apply range modifiers
	IF d > .5 * vantage THEN flag = .7 * flag: IF d > .7 * vantage THEN flag = .3 * flag
	IF RND > .9 THEN flag = flag + 3
	IF d < 3.5 + plus THEN flag = flag * 1.5 + 10 * RND + 6
	
	' Apply unit type modifiers
	u$ = LEFTY$(defend)
	IF u$ = CHR$(219) THEN
		unit$(defend) = "Infantry"
		flag = flag + 2
	END IF
	flag = flag + 5 * RND
	IF u$ = "L" THEN flag = flag + 2
	IF u$ = "w" THEN
		unit$(defend) = RIGHT$(unit$(defend), LEN(unit$(defend)) - 1)
		CALL SHOWUNIT(defend)
	END IF
	
	' Display firing animation
	FOR i = 1 TO 5
		IF quiet > 0 THEN SOUND 250 * RND + 37, .05
		CALL SHOWUNIT(defend): TICK .01
		PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET: TICK .02
	NEXT i
	
	' Calculate casualties
	dx = .01 * flag * strength(attack): killed = dx
	killed2 = .01 * flag * strength(defend)
	a = terrain(defend)
	
	' Apply terrain modifiers to defender casualties
	IF a = 42 OR a = 254 THEN killed2 = .5 * killed2
	IF a = 46 OR a = 61 THEN killed2 = 2 * killed2
	IF a = 35 THEN killed2 = .3 * killed2
	
	' Use minimum of attacker and defender calculations
	IF killed2 < killed THEN killed = killed2
	IF killed < 1 THEN killed = 1 + 10 * RND
	IF killed > strength(defend) THEN killed = strength(defend)
END SUB

' Checks for cannon explosion and handles explosion effects
FUNCTION CheckCannonExplosion% (attack AS INTEGER, defend AS INTEGER, F AS INTEGER)
	DIM shouldExplode AS INTEGER
	DIM pct! AS SINGLE
	DIM x AS INTEGER
	DIM i AS INTEGER
	DIM k AS INTEGER
	
	' Check if cannon should explode early (objective reached or friendly fire)
	shouldExplode = 0
	IF unity(attack) = objy AND unitx(attack) = objx THEN
		shouldExplode = 1
	ELSE
		CALL YouorMe(attack, F)
		IF F > 0 AND LEFTY$(defend) <> "R" THEN
			uorder(defend) = 0
			shouldExplode = 1
		END IF
	END IF
	
	IF shouldExplode = 1 THEN
		' Force explosion
	ELSE
		' Check for random explosion
		pct! = 0: IF LEFTY$(attack) = "A" THEN pct! = .01
		IF RND >= 1 - .003 * difficult - pct! THEN
			CheckCannonExplosion% = 0
			EXIT FUNCTION
		END IF
	END IF
	
	' Cannon exploded - handle explosion effects
	COLOR 4: IF attack > m1 THEN COLOR 9
	
	x = .01 * strength(attack) + .05 * RND * strength(attack)
	IF x > 100 THEN x = 90 + 10 * RND
	
	IF quiet > 0 THEN
		FOR k = 1 TO 5
			SOUND 40, 1
			CALL ATTENTION(attack, 12)
			SOUND 50, .7
		NEXT k
	END IF
	
	PUT (8 * unitx(attack), 14 * unity(attack)), Explo, PSET
	CALL clrbot
	COLOR 12: PRINT "CANNON EXPLODED !"; x; " of "; name$(attack); "'s men killed";
	
	i = 1: IF defend > m1 THEN i = 2
	toa(attack) = toa(attack) + 3
	score&(3 - i) = score&(3 - i) + x
	CALL scrcol(2)
	strength(attack) = strength(attack) - x
	CALL despair(attack)
	TICK mdly!
	CALL SHOWUNIT(attack)
	
	CheckCannonExplosion% = 1
END FUNCTION

SUB flash (index)
	IF strength(index) < 1 OR uorder(index) = 99 THEN EXIT SUB
	y = 14 * unity(index): x = 8 * unitx(index)
	LINE (x, y)-(x + 12, y + 12), 12, B
	PUT (x, y), Explo, PSET: TICK .03
	CALL Tara(unitx(index), unity(index) + 1, 0)
	IF quiet > 0 THEN SOUND 300, .15
	CALL SHOWUNIT(index): TICK .01
END SUB

'============================================================================
' Musket Combat
'============================================================================

SUB musket (attack, defend, z)
'============================================================================
'                                Attacker fires first
'============================================================================
DIM t$ AS STRING
DIM flag AS INTEGER

CALL YouorMe(attack, F)
PUT (8 * unitx(defend), 14 * unity(defend)), Explo, PSET
t$ = LEFTY$(defend)
IF t$ = "w" THEN unit$(defend) = MID$(unit$(defend), 2): CALL SHOWUNIT(defend)

' Calculate attacker fire effectiveness and casualties
CALL CalculateFireEffectiveness(attack, defend, z, F, 1, killed, bonus, flag)
' Apply fire effects and update scores
CALL ApplyFireEffects(attack, defend, killed, 1)

'============================================================================
'                                Defender returns fire
'============================================================================
DIM killed2 AS INTEGER
DIM bonus2 AS INTEGER

CALL YouorMe(defend, F)
' Calculate defender fire effectiveness and casualties
CALL CalculateFireEffectiveness(defend, attack, z, F, 2, killed2, bonus2, 0)

' Apply minimum bonus based on attacker casualties
IF bonus2 < .05 * killed THEN bonus2 = .05 * killed
killed2 = killed2 + bonus2
IF killed2 < 1 THEN killed2 = 1
IF killed2 > strength(attack) THEN killed2 = strength(attack)

' Apply fire effects and update scores
CALL ApplyFireEffects(defend, attack, killed2, 2)

	toa(attack) = timex + z: IF leader(attack) < 3 THEN toa(attack) = toa(attack) + 1
	clrbot
	COLOR 12: PRINT " CASUALTIES ";
	a$ = sname$(1): COLOR 7: IF attack > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 20: PRINT " "; a$; killed2;
	a$ = sname$(1): COLOR 7: IF defend > m1 THEN COLOR 9: a$ = sname$(2)
	LOCATE 23, 50: PRINT " "; a$; killed;
	TICK mdly!

	pra! = killed2 / (strength(attack) + 1) - .01 * (morale(attack) + leader(attack))
	prd! = killed / (strength(defend) + 1) - .01 * (morale(defend) + leader(defend))
	xold = unitx(attack): yold = unity(attack): x2 = unitx(defend): y2 = unity(defend)
       
	strength(attack) = strength(attack) - killed2
	CALL wipeout(attack): IF attack = 0 THEN morale(defend) = morale(defend) + 1

	strength(defend) = strength(defend) - killed: CALL wipeout(defend): IF defend = 0 THEN morale(attack) = morale(attack) + 1

	x0 = 0
	DIM u$ AS STRING
	u$ = LEFTY$(attack)
	
	' Handle pursuit if defender was eliminated
	IF INSTR("AL", t$) > 0 AND INSTR("AL", u$) = 0 AND artcap > 0 THEN
		x0 = INT(killed / 20)
		IF strength(defend) < 1 THEN
			IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0)
		END IF
	END IF
	IF strength(defend) < 1 THEN
		IF strength(attack) > 0 THEN CALL pursue(attack, x2, y2, x0)
	END IF
	
'...........................................................................
'                       check for attacker retreat
'...........................................................................
	DIM rflag AS INTEGER
	rflag = 0
	IF attack > 0 THEN
		rflag = CheckRetreatConditions%(attack, defend, pra!, prd!, flag, t$, xold, yold)
	END IF
	
'...........................................................................
'                       check for defender retreat
'...........................................................................
	IF defend = 0 THEN
		toa(attack) = timex + 1
	ELSE
		IF CheckDefenderRetreat%(defend, attack, prd!, pra!, flag, u$, x2, y2, rflag) THEN
			' Defender retreated or pursued
		END IF
	END IF
	
	' Update unit display
	IF LEFTY$(attack) = CHR$(219) THEN unit$(attack) = "Infantry"
	CALL SHOWUNIT(attack): CALL SHOWUNIT(defend)
END SUB

' Calculates fire effectiveness and casualties for a firing unit
SUB CalculateFireEffectiveness (firer AS INTEGER, target AS INTEGER, z AS INTEGER, F AS INTEGER, side AS INTEGER, killed AS INTEGER, bonus AS INTEGER, flag AS INTEGER)
	DIM roll! AS SINGLE
	DIM fbase AS SINGLE
	DIM u$ AS STRING
	DIM t$ AS STRING
	DIM x AS INTEGER
	DIM x1 AS INTEGER
	
	' Initialize
	flag = 0
	bonus = 0
	
	' Calculate base roll based on difficulty/human control
	IF F = 0 THEN
		IF side = 1 THEN
			roll! = .05 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
		ELSE
			roll! = .053 * difficult: IF difficult > 3 THEN roll! = roll! + .02 * difficult
		END IF
	ELSE
		IF side = 1 THEN
			roll! = .15
		ELSE
			roll! = .16
		END IF
	END IF
	
	' Get unit types
	u$ = LEFTY$(firer)
	t$ = LEFTY$(target)
	
	' Calculate base fire value
	fbase = .2 * z * strength(firer)
	
	' Apply terrain modifiers (target's terrain)
	IF side = 1 THEN
		SELECT CASE terrain(target)
			CASE 94: roll! = .09
			CASE 239: roll! = .06
			CASE 61: roll! = .2
			CASE 42: roll! = .1
			CASE 58, 254: roll! = .12
			CASE 35: roll! = .05
			CASE 176: roll! = 2 * roll!
			CASE ELSE
		END SELECT
	ELSE
		SELECT CASE terrain(firer)
			CASE 94: roll! = .1
			CASE 239: roll! = .07
			CASE 61: roll! = .21
			CASE 42: roll! = .11
			CASE 58, 254: roll! = .13
			CASE 35: roll! = .06
			CASE 176: roll! = 2 * roll!
			CASE ELSE
		END SELECT
	END IF
	
	' Apply morale and leader modifiers
	IF side = 1 THEN
		IF morale(firer) > 3 THEN roll! = roll! + .05: IF morale(firer) = 5 THEN roll! = roll! + .05
		IF leader(firer) > 3 THEN roll! = roll! + .05: IF leader(firer) = 5 THEN roll! = roll! + .05
		IF morale(firer) < 2 THEN roll! = roll! - .1
		IF leader(firer) < 2 THEN roll! = roll! - .1
	ELSE
		IF morale(firer) > 4 THEN roll! = roll! + .05: IF morale(firer) = 5 THEN roll! = roll! + .05
		IF leader(firer) > 4 THEN roll! = roll! + .05: IF leader(firer) = 5 THEN roll! = roll! + .05
		IF morale(firer) < 2 THEN roll! = roll! - .1
		IF leader(firer) < 2 THEN roll! = roll! - .1
	END IF
	
	' Apply unit type modifiers
	IF side = 1 THEN
		IF u$ = "G" THEN roll! = roll! - .2  'General Unit
		IF u$ = "L" THEN roll! = .2 * roll!   'Limbered
		IF u$ = CHR$(219) THEN roll! = roll! + .02: bonus = bonus + .05 * leader(firer)
		IF t$ = "R" THEN roll! = roll! * 2
	ELSE
		SELECT CASE t$
			CASE "G"
				roll! = roll! - .1
			CASE "L"
				roll! = .05
			CASE "R"
				roll! = .02
			CASE "S"
				IF u$ <> "C" THEN roll! = roll! / 4
		END SELECT
		IF u$ = "L" THEN roll! = 5 * roll!: IF roll! > 1 THEN roll! = 1
	END IF
	
	' Apply proximity bonus
	CALL proximity(firer, bonus)
	
	' Scale down light attacks
	IF pct# < .8 THEN roll! = .5 * roll!
	
	' Apply minimum/maximum constraints
	IF side = 1 THEN
		IF roll! < .01 THEN roll! = .01
	ELSE
		IF roll! < .02 THEN roll! = .02
	END IF
	
	' Handle cavalry charge (only for attacker)
	IF side = 1 AND (terrain(target) = 43 OR terrain(target) = 46) AND u$ = "C" THEN
		IF t$ = "C" THEN
			' Cavalry vs Cavalry - reroll until different result
			DO
				x = 0: x1 = 0
				IF RND < .15 * morale(firer) THEN x = 1
				IF RND < .15 * morale(target) THEN x1 = 1
			LOOP WHILE x = x1
			
			IF x = 0 THEN
				CALL routed(firer, 3)
			ELSE
				CALL routed(target, 3)
			END IF
		END IF
		
		' Apply smash bonus for cavalry charge
		IF t$ = "I" OR t$ = "G" OR t$ = CHR$(219) OR t$ = "R" THEN
			roll! = roll! + .1
			bonus = bonus + .1 * leader(firer)
			flag = 1
			IF RND > .5 THEN CALL routed(target, 3)
			CALL SHOWUNIT(target): toa(target) = timex + z
		ELSEIF t$ = "S" AND RND < .18 * morale(target) THEN
			roll! = .5 * roll!
			IF RND > .18 * morale(firer) THEN
				CALL routed(firer, 3)
			END IF
			' Apply smash bonus even for hollow square
			roll! = roll! + .1
			bonus = bonus + .1 * leader(firer)
			flag = 1
		END IF
	END IF
	
	' Calculate casualties using normal distribution
	CALL normal(fbase * roll!, fbase * roll! * (1 - roll!), killed)
	killed = killed + bonus
	IF killed < 1 THEN killed = 1
	IF killed > strength(target) THEN killed = strength(target)
END SUB

' Applies fire effects, updates scores, and displays visual effects
SUB ApplyFireEffects (firer AS INTEGER, target AS INTEGER, killed AS INTEGER, side AS INTEGER)
	DIM index AS INTEGER
	DIM dx AS INTEGER
	DIM k AS INTEGER
	
	' Determine score index
	index = 2: IF firer > m1 THEN index = 1
	IF side = 2 THEN index = 3 - index
	
	' Apply visual effects and update score
	dx = killed
	CALL flash(target)
	FOR k = 1 TO .02 * killed
		IF killed > 49 THEN
			score&(index) = score&(index) + 50
			CALL scrcol(2)
			dx = dx - 50
		END IF
		CALL flash(target)
	NEXT k
	score&(index) = score&(index) + dx
	CALL scrcol(2)
	CALL SHOWUNIT(target)
END SUB

' Checks if attacker should retreat after combat
FUNCTION CheckRetreatConditions% (attack AS INTEGER, defend AS INTEGER, pra! AS SINGLE, prd! AS SINGLE, flag AS INTEGER, t$ AS STRING, xold AS INTEGER, yold AS INTEGER)
	DIM bonus AS INTEGER
	DIM r! AS SINGLE
	DIM pct# AS DOUBLE
	
	CALL proximity(attack, bonus)
	r! = .02: IF bonus < 10 THEN r! = .01
	IF pra! >= r! THEN uorder(attack) = 0
	
	pct# = .02 * difficult: IF bonus > 9 THEN pct# = pct# + .03
	IF LEFTY$(attack) = "C" AND flag = 0 THEN pct# = pct# - .01
	
	IF pra! >= pct# THEN
		CALL retreat(attack, defend)
		CheckRetreatConditions% = 1
		EXIT FUNCTION
	END IF
	
	IF prd! < pct# AND INSTR("AL", t$) = 0 THEN CALL pursue(defend, xold, yold, 0)
	CheckRetreatConditions% = 0
END FUNCTION

' Checks if defender should retreat after combat
FUNCTION CheckDefenderRetreat% (defend AS INTEGER, attack AS INTEGER, prd! AS SINGLE, pra! AS SINGLE, flag AS INTEGER, u$ AS STRING, x2 AS INTEGER, y2 AS INTEGER, rflag AS INTEGER)
	DIM bonus AS INTEGER
	DIM r! AS SINGLE
	DIM pct# AS DOUBLE
	
	CALL proximity(defend, bonus)
	r! = .02: IF bonus < 10 THEN r! = .01
	IF prd! >= r! AND uorder(defend) > -1 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0
	
	pct# = .05: IF bonus > 9 THEN pct# = pct# + .03
	
	IF morale(defend) > 4 THEN pct# = pct# + .02
	IF flag = 1 AND LEFTY$(defend) <> "R" THEN pct# = pct# - .05  'cavalry charge
	IF LEFTY$(attack) = CHR$(219) THEN pct# = pct# - .02
	
	IF prd! >= .07 AND LEFTY$(defend) <> "R" THEN uorder(defend) = 0
	IF terrain(defend) = 35 THEN pct# = pct# + .03
	
	IF prd! >= pct# THEN
		CALL retreat(defend, attack)
		CheckDefenderRetreat% = 1
		EXIT FUNCTION
	END IF
	
	IF rflag = 0 AND pra! < pct# - .01 AND INSTR("AL", u$) = 0 THEN
		CALL pursue(attack, x2, y2, 0)
		CheckDefenderRetreat% = 1
		EXIT FUNCTION
	END IF
	
	CheckDefenderRetreat% = 0
END FUNCTION

'============================================================================
' Combat Menu and AI Combat Choice
'============================================================================

FUNCTION CalculateAICombatChoice% (index AS INTEGER, Enemy AS INTEGER, a$ AS STRING)
	DIM pct# AS DOUBLE
	DIM d AS INTEGER
	DIM bonus AS INTEGER
	DIM dxs AS INTEGER
	DIM dys AS INTEGER
	
	' Calculate base combat probability
	roll! = mdly!
	pct# = strength(index) / strength(Enemy) + .1 * bold - .3
	
	' Apply terrain modifiers
	IF terrain(Enemy) = 94 THEN pct# = .6 * pct#
	IF terrain(Enemy) = 239 THEN pct# = .4 * pct#
	IF terrain(Enemy) = 61 THEN pct# = 1.2 * pct#
	IF terrain(Enemy) = 42 THEN pct# = .8 * pct#
	IF terrain(Enemy) = 254 THEN pct# = .8 * pct#
	IF terrain(Enemy) = 35 OR terrain(index) = 35 THEN pct# = .5 * pct#
	IF terrain(Enemy) = 233 THEN pct# = 2 * pct#
	
	CALL valid(Enemy)
	pct# = pct# * (morale(index) / morale(Enemy)) * (leader(index) / leader(Enemy))
	
	' Apply objective proximity bonus
	d = 2 * ABS(unity(index) - objy) + ABS(unitx(index) - objx)
	IF possess <> 3 - side AND d < seelimit THEN IF pct# < 1 THEN pct# = pct# + .3
	
	' Apply proximity bonus
	CALL proximity(index, bonus): IF bonus > 5 THEN pct# = pct# + .1
	IF bold > 3 THEN pct# = pct# + .5
	
	' Determine base combat choice
	SELECT CASE pct#
		CASE IS > 2
			choose = 4
		CASE IS > 1.5
			choose = 3
		CASE IS > 1
			choose = 2
		CASE IS > .4
			choose = 1
		CASE ELSE
			' Retreat instead of combat
			dxs = SGN(unitx(index) - unitx(Enemy)): dys = SGN(unity(index) - unity(Enemy))
			uorder(index) = 100 * (unity(index) + dys) + unitx(index) + dxs
			CalculateAICombatChoice% = 0
			EXIT FUNCTION
	END SELECT

	' Apply modifiers
	IF terrain(Enemy) = 233 THEN choose = choose + 1: IF timelimit - timex < 10 THEN choose = 4
	IF leader(index) < 3 THEN choose = 3 - INT(2 * RND)
	IF morale(index) < 3 THEN choose = choose - 1
	IF RND > .9 THEN choose = choose - 1: IF RND < .5 THEN choose = choose + 2
	IF bold > 3 AND RND > .7 THEN choose = choose + 1: IF bold = 5 AND RND > .5 THEN choose = 4
	IF bold < 3 AND RND > .5 THEN choose = choose - 1: IF bold = 1 AND RND > .5 THEN choose = 1
	
	' Apply unit type modifiers
	SELECT CASE a$
		CASE "G"
			choose = choose - 2
		CASE "C"
			IF LEFTY$(Enemy) = "S" THEN choose = choose - 1
	END SELECT
	
	' Apply situational modifiers
	IF d < .3 * seelimit THEN choose = choose + 1
	IF timelimit - timex < 20 AND possess <> 3 - side THEN choose = choose + 1
	IF LEFTY$(Enemy) = "R" THEN choose = choose + 2

	' Clamp choice to valid range
	IF choose > 4 THEN choose = 4
	IF choose < 1 THEN
		CalculateAICombatChoice% = 0
		EXIT FUNCTION
	END IF
	
	CalculateAICombatChoice% = choose
END FUNCTION

SUB combat (index, Enemy)
	' Validate combat parameters
	IF Enemy = 0 OR uorder(index) = 99 OR index = Enemy THEN EXIT SUB
	a$ = LEFTY$(index)
	IF a$ = "R" THEN movesleft = 0: EXIT SUB
	
	tlx = 60: tly = 3: colour = 12: size = 4
	mtx$(0) = "COMBAT MENU"
	mtx$(1) = "Light Skirmish"
	mtx$(2) = "Medium Fight"
	mtx$(3) = "Heavy Attack"
	mtx$(4) = "All-out Assault"

	IF Visible(index) < 1 THEN Visible(index) = 1: SHOWUNIT (index)
	
	' Check if human-controlled unit
	CALL YouorMe(index, flag)
	IF flag > 0 THEN
		' Human-controlled - manual combat selection
		LITEUP 8 * unitx(index), 14 * unity(index), 14
		LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

		roll! = .1

		x = INT(strength(Enemy) / 100) - 1 + 2 * RND
		x = x * 100: IF x < 100 THEN x = 50
		R! = strength(index) / x
		COLOR 11: CALL clrbot: PRINT name$(index); " vs."; name$(Enemy); "  Str:"; x;
		COLOR 10: IF R! < 1 THEN COLOR 12
		SELECT CASE R!
			CASE IS < .67: x = 1: y = 1 / R!
			CASE IS < .8: x = 2: y = 3
			CASE IS < .9: x = 4: y = 5
			CASE IS < 1.3: x = 1: y = 1
			CASE IS < 1.6: x = 3: y = 2
			CASE ELSE: x = R!: y = 1
		END SELECT
		PRINT "  Ratio ="; x; ":"; y; " ";
		COLOR 11: PRINT "  Terrain ="; : x = POS(0)
		CALL Tara(x, 23, terrain(Enemy))
		IF LEFTY$(index) = "C" AND (terrain(index) = 46 OR terrain(index) = 43) AND (terrain(Enemy) = 46 OR terrain(Enemy) = 43) THEN
			CALL BUTTON(10, 25, 14, "CAVALRY CHARGE", 1)
		END IF
		CALL menu
		CALL scrcol(1)
		CALL inspect(index)
	ELSE
		' AI-controlled - calculate combat choice using extracted function
		SELECT CASE a$
			CASE "A"
				CALL cannon(index, Enemy): EXIT SUB
			CASE "L"
				choose = CalculateAICombatChoice%(index, Enemy, a$)
				IF choose < 4 THEN CALL limbo(index, 0): EXIT SUB
			CASE ELSE
				choose = CalculateAICombatChoice%(index, Enemy, a$)
		END SELECT
		
		IF choose = 0 THEN EXIT SUB
		CALL inspect(Enemy)
	END IF
	
	' Execute combat (tally section)
	IF choose = -1 XOR choose = 99 THEN movesleft = 0: uorder(index) = 0: EXIT SUB
LITEUP 8 * unitx(index), 14 * unity(index), 14
LITEUP 8 * unitx(Enemy), 14 * unity(Enemy), 12

s = 1: IF index > m1 THEN s = 2

CALL clrbot: COLOR 12
IF LEFTY$(index) = "C" AND (terrain(index) = 46 OR terrain(index) = 43) AND (terrain(Enemy) = 46 OR terrain(Enemy) = 43) THEN
	COLOR 14
	PRINT sname$(s); " "; name$(index); " CALVARY CHARGE vs. "; name$(Enemy)
	IF quiet > 0 THEN PLAY "MBMST170o3c16.c16c16.c16c16.c16g16.e16g16.e16g16.e16c1MN"
ELSE
  PRINT sname$(s); " Unit : "; name$(index); " => "; RTRIM$(mtx$(choose)); " vs. "; name$(Enemy);
END IF
IF quiet < 1 THEN TICK mdly!

	IF LEFTY$(Enemy) = CHR$(219) THEN unit$(Enemy) = "Infantry"
	CALL musket(index, Enemy, choose): movesleft = 0
	
	' Cleanup (cancel2 section)
	CALL SHOWUNIT(Enemy)
	IF LEFTY$(index) <> "R" AND RND > .05 + .15 * difficult THEN uorder(index) = 0
END SUB

'============================================================================
' Retreat and Pursuit
'============================================================================

SUB retreat (index, defend)
IF LEFTY$(index) = "A" THEN
	IF RND > .15 * morale(index) THEN
		unit$(index) = "LArtillery"
		CALL routed(index, 1)
	END IF
EXIT SUB
END IF

IF LEFTY$(index) = "S" THEN CALL routed(index, 1)
IF uorder(index) = 99 THEN EXIT SUB
rflag = 0
id = 1: IF index > m1 THEN id = 2
IF strength(index) < 1 THEN EXIT SUB

FOR k = 1 TO mdly!
ATTENTION index, 13
NEXT k

clrbot
s = 1: IF index > m1 THEN s = 2
COLOR 13: PRINT sname$(s); " unit "; name$(index); " must pull back ";
rout = 0: uorder(index) = 0

' Calculate retreat direction and find valid location
DIM xnew AS INTEGER
DIM ynew AS INTEGER
DIM blox AS INTEGER
CALL CalculateRetreatDirection(index, defend, a$)
blox = FindRetreatLocation%(index, a$, id, xnew, ynew)

' If we found a valid retreat location, apply extra damage
IF blox > 0 THEN
	CALL ApplyRetreatExtraDamage(index, defend, id, rout)
	CALL flee(index)
END IF

' Move unit to retreat location (woe section)
IF blox > 0 THEN
	' Invalid location, skip movement
ELSE
	DIM z AS INTEGER
	DIM F AS INTEGER
	DIM u$ AS STRING
	
	z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
	CALL Tara(unitx(index), unity(index) + 1, 0)

	COLOR 4: IF index > m1 THEN COLOR 9
	unitx(index) = xnew: unity(index) = ynew
	   
	FOR k = 1 TO mdly!
		CALL ATTENTION(index, 13)
	NEXT k
	   
	CALL YouorMe(defend, F)
	u$ = LEFTY$(defend)

	IF F = 0 THEN
		uorder(defend) = 100 * ynew + xnew
	ELSEIF rely > 2 AND INSTR("A", u$) = 0 THEN uorder(defend) = 100 * ynew + xnew
	END IF
	
	terrain(index) = z
	IF z = 233 THEN CALL TICK(mdly!): CALL victory(index)
END IF

' Apply retreat damage
CALL ApplyRetreatDamage(index, defend, id, rout)
	
	' Cleanup (rip section)
	CALL wipeout(index)
	CALL YouorMe(index, F): IF F > 0 THEN CALL inspect(index)
	CALL SHOWUNIT(index)
END SUB

' Calculates retreat direction string based on relative positions
SUB CalculateRetreatDirection (index AS INTEGER, defend AS INTEGER, a$ AS STRING)
	DIM dxs AS INTEGER
	DIM dys AS INTEGER
	DIM flag AS INTEGER
	
	dxs = SGN(unitx(defend) - unitx(index))
	dys = SGN(unity(defend) - unity(index))
	flag = 10 * dys + dxs
	
	SELECT CASE flag
		CASE -11
			a$ = "QOM"
		CASE -9
			a$ = "OKQ"
		CASE -1
			a$ = "MIQ"
		CASE 1
			a$ = "KOG"
		CASE 9
			a$ = "IGM"
		CASE 11
			a$ = "GKI"
		CASE -10
			a$ = "OQ"
		CASE 10
			a$ = "GI"
		CASE ELSE
			a$ = ""
	END SELECT
END SUB

' Finds a valid retreat location by trying directions in order
FUNCTION FindRetreatLocation% (index AS INTEGER, a$ AS STRING, id AS INTEGER, xnew AS INTEGER, ynew AS INTEGER)
	DIM dx AS INTEGER
	DIM k AS INTEGER
	DIM blox AS INTEGER
	
	dx = LEN(a$)
	FOR k = 1 TO dx
		xnew = unitx(index): ynew = unity(index)
		CALL curser(MID$(a$, k, 1), xnew, ynew)
		CALL CheckRunLocation(xnew, ynew, id, blox)
		IF blox = 0 THEN
			' Valid location found
			FindRetreatLocation% = 1
			EXIT FUNCTION
		END IF
	NEXT k
	
	' No valid location found
	FindRetreatLocation% = 0
END FUNCTION

' GOSUB run1 converted to SUB
SUB CheckRunLocation (xnew AS INTEGER, ynew AS INTEGER, id AS INTEGER, blox AS INTEGER)
	DIM z AS INTEGER
	DIM Enemy AS INTEGER
	
	blox = 0
	IF xnew < 1 XOR xnew > 55 THEN blox = 1: EXIT SUB
	IF ynew < 1 XOR ynew > 20 THEN blox = 1: EXIT SUB
	z = ASC(MID$(sdtext$(ynew + 1), xnew, 1))
	IF z = 233 THEN
		IF possess <> id THEN blox = 1
	END IF
	CALL whois(xnew, ynew, Enemy, 0): IF Enemy > 0 THEN blox = 1
END SUB

' Applies extra damage when retreat location is blocked
SUB ApplyRetreatExtraDamage (index AS INTEGER, defend AS INTEGER, id AS INTEGER, rout AS INTEGER)
	rout = 1 + .05 * strength(index): IF RND > .5 THEN rout = rout * 2
	score&(id) = score&(id) + rout
	CALL scrcol(2)
	CALL flash(index)
	COLOR 15: IF index > m1 THEN COLOR 9
	clrbot
	PRINT "EXTRA DAMAGE TAKEN :"; rout; " ";
	CALL SHOWUNIT(index)
	morale(index) = morale(index) - 1: morale(defend) = morale(defend) + 1
	leader(index) = leader(index) - 1: leader(defend) = leader(defend) + 1
END SUB

' Applies standard retreat damage and handles routing
SUB ApplyRetreatDamage (index AS INTEGER, defend AS INTEGER, id AS INTEGER, rout AS INTEGER)
	DIM killed AS INTEGER
	DIM F AS INTEGER
	
	' Apply base damage
	IF rout = 0 THEN TICK .2 * mdly!
	morale(index) = morale(index) - 1: IF morale(index) < 0 THEN morale(index) = 1
	killed = 1 + .02 * strength(index) + rout
	IF killed > strength(index) THEN killed = strength(index)
	
	score&(id) = score&(id) + killed
	strength(index) = strength(index) - killed
	CALL scrcol(2)
	
	' Apply leader damage
	IF RND > .2 THEN
		leader(index) = leader(index) - 2
		IF rout > 0 THEN leader(index) = leader(index) - INT(10 * RND)
	END IF
	
	' Check for routing
	IF rout = 0 THEN
		IF RND > .18 * morale(index) THEN CALL routed(index, 3)
	ELSE
		IF quiet > 0 THEN
			IF index > m1 THEN
				PLAY "T150O3L8C;FCFG;A4G"
			ELSE
				PLAY "MNMFt160o1g8.g16o2c4c4d4d4g4.e16c8."
			END IF
		END IF
		IF RND > .05 * xper(index) THEN CALL routed(index, 3)
		IF quiet < 1 THEN TICK mdly!
	END IF
END SUB

SUB pursue (index, x, y, flag)
	IF uorder(index) = 99 THEN EXIT SUB
	a$ = LEFTY$(index)
	SELECT CASE a$
		CASE "R", "S"
			EXIT SUB
	END SELECT
	z = ASC(MID$(sdtext$(y + 1), x, 1))
	CALL whois(x, y, Enemy, index): IF Enemy > 0 THEN EXIT SUB

	' Check if should pursue
	DIM shouldPursue AS INTEGER
	shouldPursue = 0
	
	CALL YouorMe(index, F)
	IF F = 0 OR rely = 5 THEN
		' AI-controlled or maximum reliability - pursue automatically
		shouldPursue = 1
	ELSE
		' Human-controlled - ask for confirmation
		BuffClear
		t$ = "Pursue ?"
		LITEUP 8 * unitx(index), 14 * unity(index), 14
		CALL YesNo(t$): CALL scrcol(1)
		IF t$ = "Y" THEN shouldPursue = 1
	END IF
	
	IF shouldPursue = 0 THEN EXIT SUB
	
	' Check if already at objective
	IF unity(index) = objy AND unitx(index) = objx THEN EXIT SUB

	' Check terrain conditions using extracted function
	IF NOT CanPursueToTerrain%(index, z) THEN EXIT SUB
	
	' Execute pursuit - try to capture artillery if flag > 0
	IF flag > 0 AND TryCaptureArtillery%(index, x, y, z, flag) THEN EXIT SUB
	
	' Move unit to new location (runn2 section)
	CALL Tara(unitx(index), unity(index) + 1, 0)
	unity(index) = y: unitx(index) = x: terrain(index) = z
	IF quiet > 0 THEN
		IF (side = 1 AND index < m2) OR (side = 2 AND index > m1) THEN CALL SHOWUNIT(index): PLAY "MST220o3g8g8g8o4c2MN"
	END IF
	IF morale(index) < 5 THEN morale(index) = morale(index) + 1 ELSEIF xper(index) < 4 THEN xper(index) = xper(index) + 1
	IF leader(index) < 5 AND morale(index) > 3 THEN leader(index) = leader(index) + 1
	IF z = 233 THEN SHOWUNIT (index): CALL victory(index)
	IF a$ = "R" THEN CALL routed(index, 0): EXIT SUB
END SUB

' Checks if unit can pursue to the specified terrain type
FUNCTION CanPursueToTerrain% (index AS INTEGER, z AS INTEGER)
	DIM u$ AS STRING
	
	' Water blocks all pursuit
	IF z = 176 THEN
		CanPursueToTerrain% = 0
		EXIT FUNCTION
	END IF
	
	' Check unit type restrictions
	u$ = LEFTY$(index)
	
	' Cavalry cannot pursue into certain terrain
	IF u$ = "C" THEN
		IF z = 42 OR z = 61 OR z = 239 THEN
			CanPursueToTerrain% = 0
			EXIT FUNCTION
		END IF
	END IF
	
	' Limbered artillery cannot pursue into difficult terrain
	IF u$ = "L" THEN
		IF z = 42 OR z = 61 OR z = 94 OR z = 239 THEN
			CanPursueToTerrain% = 0
			EXIT FUNCTION
		END IF
	END IF
	
	CanPursueToTerrain% = 1
END FUNCTION

' Attempts to capture artillery during pursuit
FUNCTION TryCaptureArtillery% (index AS INTEGER, x AS INTEGER, y AS INTEGER, z AS INTEGER, flag AS INTEGER)
	DIM Enemy AS INTEGER
	DIM a$ AS STRING
	
	' Check if there's an enemy unit at the location
	CALL whois(x, y, Enemy, index)
	IF Enemy = 0 THEN
		TryCaptureArtillery% = 0
		EXIT FUNCTION
	END IF
	
	' Check if enemy is artillery
	a$ = LEFTY$(Enemy)
	IF INSTR("AL", a$) = 0 THEN
		TryCaptureArtillery% = 0
		EXIT FUNCTION
	END IF
	
	' Check if artillery is limbered (can be captured)
	IF a$ <> "L" THEN
		TryCaptureArtillery% = 0
		EXIT FUNCTION
	END IF
	
	' Attempt capture based on flag (casualties inflicted)
	IF flag > 0 AND RND < .3 + .1 * flag THEN
		' Artillery captured
		CALL clrbot
		COLOR 14: PRINT name$(index); " has captured "; name$(Enemy); " artillery!";
		IF quiet > 0 THEN SOUND 2000, .5
		CALL wipeout(Enemy)
		IF Enemy = 0 THEN
			' Move to captured location
			CALL Tara(unitx(index), unity(index) + 1, 0)
			unitx(index) = x: unity(index) = y: terrain(index) = z
			CALL SHOWUNIT(index)
			TryCaptureArtillery% = 1
			EXIT FUNCTION
		END IF
	END IF
	
	TryCaptureArtillery% = 0
END FUNCTION

'============================================================================
' Unit State Management
'============================================================================

SUB routed (index, flag)
	SELECT CASE flag
		CASE 0  'morale check
			x = morale(index): IF x < leader(index) THEN x = leader(index)
			IF RND < .05 * x THEN
				' Recover from rout (reform section)
				IF LEFTY$(index) <> "R" THEN EXIT SUB
				s = 1: IF index > m1 THEN s = 2
				IF RND > .01 * elan(s) THEN EXIT SUB
				unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
			ELSE
				EXIT SUB
			END IF
		CASE 1  'rout
			' Break unit (broken section)
			IF LEFTY$(index) = "S" THEN unit$(index) = "Infantry"
			IF LEFTY$(index) <> "R" THEN unit$(index) = "R" + unit$(index)
			morale(index) = 1
			CALL flee(index)
			s = 1: IF index > m1 THEN s = 2
			elan(s) = elan(s) - 3
		CASE 2  'recover
			' Recover from rout (reform section)
			IF LEFTY$(index) <> "R" THEN EXIT SUB
			s = 1: IF index > m1 THEN s = 2
			IF RND > .01 * elan(s) THEN EXIT SUB
			unit$(index) = RIGHT$(unit$(index), LEN(unit$(index)) - 1)
		FOR k = 1 TO 2: ATTENTION index, 14
		IF quiet > 0 THEN SOUND 1800, .3: TICK .1
		NEXT k
		CALL clrbot: COLOR 15: PRINT name$(index); " has rallied";
		IF quiet > 0 THEN SOUND 900, 1: SOUND 999, .7
		uorder(index) = 0: movesleft = movesleft - 1
		TICK mdly!
	EXIT SUB
	toa(index) = timex + 2: movesleft = 0
	CALL SHOWUNIT(index)
	IF quiet > 0 THEN SOUND 1600, .5: TICK .05: SOUND 1700, .5
	CALL ATTENTION(index, 13)
	CALL inspect(index)
		CASE 3
		IF RND < .1 * xper(index) THEN EXIT SUB
		IF leader(index) > 3 THEN IF RND < .1 * leader(index) THEN EXIT SUB
		' Break unit (broken section)
		IF LEFTY$(index) = "S" THEN unit$(index) = "Infantry"
		IF LEFTY$(index) <> "R" THEN unit$(index) = "R" + unit$(index)
		morale(index) = 1
		CALL flee(index)
		s = 1: IF index > m1 THEN s = 2
		elan(s) = elan(s) - 3
	END SELECT
END SUB

SUB despair (index)
IF xper(index) = 5 AND RND < .99 THEN EXIT SUB
IF xper(index) = 4 AND RND < .88 THEN EXIT SUB
IF leader(index) = 5 AND RND < .9 THEN EXIT SUB
IF leader(index) = 4 AND RND < .7 THEN EXIT SUB
pct! = .5
SELECT CASE leader(index)
	CASE 1
	pct! = .8
	CASE 2
	pct! = .6
END SELECT

IF xper(index) = 2 THEN pct! = pct! + .1
IF xper(index) = 1 THEN pct! = pct! + .2

IF RND > pct! THEN EXIT SUB
IF morale(index) > 1 THEN morale(index) = morale(index) - 1
END SUB

SUB flee (defend)
IF LEFTY$(defend) <> "R" AND strength(defend) > 50 AND morale(defend) > 1 THEN EXIT SUB
who = 1: IF defend > m1 THEN who = 2
CALL arrange(who, xloc, yloc)
SELECT CASE xloc
	CASE 13: xloc = 2: yloc = 11
	CASE 40: xloc = 52: yloc = 12
	CASE 27: IF yloc = 6 THEN yloc = 1 ELSE yloc = 18
	CASE 99:
	IF yloc = 6 THEN yloc = 1: xloc = 27
	IF yloc = 18 THEN yloc = 20: xloc = 28
	CASE ELSE
END SELECT
IF xloc > 0 AND yloc > 0 THEN uorder(defend) = 100 * yloc + xloc
END SUB

SUB victory (index)
IF index < 1 OR terrain(index) <> 233 THEN EXIT SUB
COLOR 4: IF index > 40 THEN COLOR 9
CALL clrbot: COLOR 15: PRINT name$(index); " has taken the objective !";
possess = 1
IF index < m2 AND possess <> 1 THEN possess = 1: CALL PlayYanksSound: s = m2: F = bigg(2)
IF index > m1 AND possess <> 2 THEN possess = 2: CALL PlayFranksSound: s = 1: F = bigg(1)
elan(possess) = elan(possess) + 10: CALL brittle(possess)
FOR k = s TO F
	IF INSTR("GRA", LEFTY$(k)) = 0 AND uorder(k) <> 99 THEN uorder(k) = 100 * objy + objx
NEXT k
	IF possess = 1 THEN
		s = 1: F = bigg(1)
	ELSE
		s = m2: F = bigg(2)
	END IF
FOR k = s TO F
IF uorder(k) > 0 AND uorder(k) <> 99 THEN uorder(k) = 0
NEXT k
CALL scrcol(1)
CALL TICK(.1 * mdly!)
END SUB

SUB wipeout (index)
IF index < 1 OR strength(index) > 0 OR unitx(index) = 1 THEN EXIT SUB
COLOR 9: a$ = sname$(2): x = 1
IF index < m2 THEN COLOR 4: a$ = sname$(1): x = 2
elan(x) = elan(x) + 5: elan(3 - x) = elan(3 - x) - 5
IF LEFTY$(index) = "G" THEN elan(x) = elan(x) - 10
FOR k = 1 TO 2: CALL brittle(k): NEXT k
CALL clrbot: LOCATE 23, 15: PRINT a$; " unit "; name$(index); " has been eliminated";
CALL scrcol(2)
uorder(index) = 0: strength(index) = 0
unit$(index) = "X"
CALL SHOWUNIT(index)
unit$(index) = ""
IF quiet > 0 THEN PLAY "MBt120l16o1mna4a8.aa2"
CALL TICK(.3): CALL TICK(.8 * mdly!)
CALL Tara(unitx(index), unity(index) + 1, 0)

s = 1: IF index > m1 THEN s = 2
CALL Compact(s): index = 0: IF strength(1) > 0 AND strength(41) > 0 THEN EXIT SUB

dx = 0: FOR k = 1 TO bigg(1): IF strength(k) > 0 THEN dx = 1: EXIT FOR
NEXT k
dy = 0: FOR k = m2 TO bigg(2): IF strength(k) > 0 THEN dy = 1: EXIT FOR
NEXT k

IF dx > 0 AND dy > 0 THEN EXIT SUB
s = 2: IF dx = 0 THEN s = 1
COLOR 14: CALL clrbot: PRINT sname$(s); " forces ANNIHILATED : Bonus = 250"; : vp&(3 - s) = vp&(3 - s) + 250
CALL TICK(99): CALL expire: CALL TICK(99): END

END SUB

