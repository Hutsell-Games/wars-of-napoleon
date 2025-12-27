'============================================================================
' Tactical Battle Core Mechanics
'============================================================================
' Battle map, unit types, combat mechanics, visibility, victory conditions
' Refactored from NAPOLEON.BAS

' Battle map: 27x20 hex grid
CONST MAP_WIDTH = 27
CONST MAP_HEIGHT = 20

' Unit type constants
CONST UNIT_INFANTRY = 1
CONST UNIT_HOLLOW_SQUARE = 2
CONST UNIT_CAVALRY = 3
CONST UNIT_ARTILLERY = 4
CONST UNIT_GENERAL = 5

' Combat intensity levels
CONST INTENSITY_LIGHT = 1
CONST INTENSITY_MEDIUM = 2
CONST INTENSITY_HEAVY = 3
CONST INTENSITY_ASSAULT = 8

' Victory conditions
CONST VICTORY_OBJECTIVE = 1
CONST VICTORY_ROUT = 2

' Battle time limit constants
CONST BASE_TIME_LIMIT = 25
CONST FORT_TIME_BONUS = 5
CONST LARGE_BATTLE_THRESHOLD = 200
CONST LARGE_BATTLE_BASE_TIME = 40
CONST DEFENDER_TIME_BONUS = 10
CONST OBSTRUCTION_TIME_MULTIPLIER = 0.1

' Unit size and scaling constants
CONST UNIT_SIZE_MULTIPLIER = 3
CONST MIN_UNIT_SIZE = 500
CONST HUNDREDS_TO_MEN_SCALE = 100

' Visibility constants
CONST DEFAULT_VISIBILITY_LIMIT = 18
CONST MIN_VISIBILITY_LIMIT = 10
CONST MAX_VISIBILITY_LIMIT = 18
CONST REDUCED_VISIBILITY_CHANCE = 0.8

' Esprit de corps constants
CONST BASE_ESPRIT_DE_CORPS = 80
CONST ESPRIT_EXPERIENCE_MULTIPLIER = 5
CONST ESPRIT_LEADERSHIP_MULTIPLIER = 5
CONST ESPRIT_AVERAGE_RATING = 3

' Combat effectiveness multipliers
CONST LEADERSHIP_EFFECTIVENESS_MULTIPLIER = 0.1
CONST EXPERIENCE_EFFECTIVENESS_MULTIPLIER = 0.1
CONST MORALE_EFFECTIVENESS_MULTIPLIER = 0.1

' Terrain type constants (for combat modifiers)
CONST TERRAIN_RIVER = 35
CONST TERRAIN_FOREST = 42
CONST TERRAIN_SWAMP = 61
CONST TERRAIN_HILLS = 94
CONST TERRAIN_MOUNTAINS = 239
CONST TERRAIN_CLEAR = 232
CONST TERRAIN_ROAD = 233
CONST TERRAIN_DEFENSIVE = 254
CONST TERRAIN_WATER = 176

' Terrain combat modifiers (attacker effectiveness)
CONST TERRAIN_RIVER_ATTACKER_MULT = 0.5
CONST TERRAIN_FOREST_ATTACKER_MULT = 0.8
CONST TERRAIN_SWAMP_ATTACKER_MULT = 1.2
CONST TERRAIN_HILLS_ATTACKER_MULT = 0.6
CONST TERRAIN_MOUNTAINS_ATTACKER_MULT = 0.4
CONST TERRAIN_DEFENSIVE_ATTACKER_MULT = 0.8

' Terrain combat modifiers (defender effectiveness)
CONST TERRAIN_RIVER_DEFENDER_MULT = 1.5
CONST TERRAIN_FOREST_DEFENDER_MULT = 1.2
CONST TERRAIN_SWAMP_DEFENDER_MULT = 1.1
CONST TERRAIN_HILLS_DEFENDER_MULT = 1.3
CONST TERRAIN_MOUNTAINS_DEFENDER_MULT = 1.6
CONST TERRAIN_DEFENSIVE_DEFENDER_MULT = 1.2

' Unit type combat modifiers
CONST CAVALRY_OPEN_TERRAIN_BONUS = 1.2
CONST CAVALRY_DIFFICULT_TERRAIN_PENALTY = 0.8
CONST ARTILLERY_CANISTER_MULTIPLIER = 2.0
CONST ARTILLERY_LONG_RANGE_MULTIPLIER = 0.5
CONST CAVALRY_CHARGE_BONUS = 1.5

' Strategic retreat constant
CONST STRATEGIC_RETREAT_LOSS_MULTIPLIER = 0.8

' Terrain movement cost multipliers
CONST TERRAIN_RIVER_MOVEMENT_COST = 2.0 ' Double movement cost
CONST TERRAIN_FOREST_MOVEMENT_COST = 1.5 ' 50% slower
CONST TERRAIN_SWAMP_MOVEMENT_COST = 2.5 ' 150% slower
CONST TERRAIN_HILLS_MOVEMENT_COST = 1.2 ' 20% slower
CONST TERRAIN_MOUNTAINS_MOVEMENT_COST = 2.0 ' Double movement cost
CONST TERRAIN_CLEAR_MOVEMENT_COST = 0.8 ' 20% faster
CONST TERRAIN_DEFENSIVE_MOVEMENT_COST = 1.1 ' 10% slower
CONST TERRAIN_NORMAL_MOVEMENT_COST = 1.0 ' Normal movement

' Commander array size
CONST MAX_COMMANDERS = 50 ' Maximum number of commanders

' Display and animation constants
CONST DISPLAY_SPEED_VERY_FAST = 5 ' Display speed threshold for very fast
CONST DISPLAY_DELAY_FAST = 10 ' Display delay when speed is very fast

' Equipment array size
CONST MAX_EQUIPMENT_ITEMS = 5 ' Maximum equipment array index (0-5 = 6 items)

' Tactical unit constants
CONST COMMANDER_UNIT_INDEX_1 = 1 ' Unit index for side 1 commander
CONST COMMANDER_UNIT_INDEX_2 = 41 ' Unit index for side 2 commander
CONST UNIT_ORDER_ENCODING_MULTIPLIER = 100 ' Multiplier for encoding unit orders (100 * unity + unitx)
CONST ANNIHILATION_BONUS = 250 ' Victory points bonus when enemy forces are annihilated
CONST UNIT_ORDER_ROUTED = 99 ' Unit order value indicating unit is routed/disabled

' Esprit de corps adjustment constants
CONST ESPRIT_UNIT_ELIMINATED_PENALTY = -3 ' Esprit de corps penalty when unit is eliminated
CONST ESPRIT_OBJECTIVE_CAPTURED_BONUS = 10 ' Esprit de corps bonus when objective is captured
CONST ESPRIT_GENERAL_ELIMINATED_PENALTY = -10 ' Esprit de corps penalty when general is eliminated
CONST ESPRIT_UNIT_ELIMINATED_BONUS = 5 ' Esprit de corps bonus when enemy unit is eliminated

' Cannon explosion constants
CONST CANNON_EXPLOSION_BASE_DAMAGE_MULT = 0.01 ' Base damage multiplier for cannon explosion
CONST CANNON_EXPLOSION_RANDOM_DAMAGE_MULT = 0.05 ' Random damage multiplier for cannon explosion
CONST CANNON_EXPLOSION_MAX_DAMAGE = 100 ' Maximum damage from cannon explosion
CONST CANNON_EXPLOSION_MIN_DAMAGE = 90 ' Minimum damage when at max (90-100 range)

' Cannon damage terrain modifiers
CONST CANNON_DAMAGE_FOREST_REDUCTION = 0.5 ' Forest/defensive terrain reduces cannon damage by 50%
CONST CANNON_DAMAGE_SWAMP_MULTIPLIER = 2.0 ' Swamp/open terrain doubles cannon damage
CONST CANNON_DAMAGE_RIVER_REDUCTION = 0.3 ' River reduces cannon damage by 70%

' Time of action constants
CONST TOA_BASE_ATTACKER = 1 ' Base time of action for attacker
CONST TOA_RANDOM_ATTACKER = 4 ' Random time of action range for attacker
CONST TOA_BASE_DEFENDER = 2 ' Base time of action for defender
CONST TOA_RANDOM_DEFENDER = 6 ' Random time of action range for defender
CONST TOA_MORALE_LOW_PENALTY = 1 ' Additional time when morale < 3
CONST TOA_MORALE_VERY_LOW_PENALTY = 3 ' Additional time when morale < 2
CONST TOA_LEADER_LOW_PENALTY = 2 ' Additional time when leader < 3
CONST TOA_DEFENDER_RANDOM_BONUS = 3 ' Random bonus time for defender (70% chance)

' Morale and leader thresholds
CONST MORALE_THRESHOLD_LOW = 3 ' Morale threshold for low morale penalties
CONST MORALE_THRESHOLD_VERY_LOW = 2 ' Morale threshold for very low morale penalties
CONST LEADER_THRESHOLD_LOW = 3 ' Leader threshold for low leader penalties
CONST MORALE_THRESHOLD_HIGH = 3 ' Morale threshold for high morale bonuses

' Battle end signal
CONST BATTLE_END_SIGNAL = 219 ' Character code for battle end signal (CHR$(219))

' Default tactical configuration values
CONST DEFAULT_BOLD = 3 ' Default boldness setting
CONST DEFAULT_SEELIMIT = 18 ' Default visibility limit
CONST DEFAULT_MDSP = 3 ' Default display speed
CONST DEFAULT_LIMBER = 1 ' Default limber setting
CONST DEFAULT_RELY = 4 ' Default reliability setting
CONST DEFAULT_STAKK = 3 ' Default stack setting
CONST DEFAULT_LINEOFSIGHT = 1 ' Default line of sight setting
CONST DEFAULT_ARTCAP = 1 ' Default artillery capture setting

'============================================================================
' InitializeBattleMap - Initialize tactical battle map
'============================================================================
' Returns:
'   INTEGER - 1 on success, 0 on failure
' Description:
'   Initializes the 27x20 hex grid battle map with random terrain generation.
'   Delegates to randmap% function from terrain.bas to generate the map.
'   This must succeed before a tactical battle can proceed.
'============================================================================
FUNCTION InitializeBattleMap% ()
    ' Initialize 27x20 hex grid battle map
    ' Random terrain generation
    ' This uses the randmap FUNCTION from terrain.bas
    ' Returns 1 on success, 0 on failure
    InitializeBattleMap% = randmap%
END FUNCTION

'============================================================================
' ResolveMeleeCombat - Resolve melee combat between two units
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking unit
'   defenderIndex (INTEGER) - Index of defending unit
'   intensity (INTEGER) - Combat intensity level (1=light, 2=medium, 3=heavy, 8=assault)
' Returns:
'   INTEGER - Damage dealt to defender
' Description:
'   Resolves melee combat between two units. Calculates damage based on:
'   - Unit strengths
'   - Leadership, experience, and morale ratings
'   - Combat intensity multiplier
'   - Terrain modifiers (defender's terrain affects both attacker and defender effectiveness)
'   - Unit type bonuses (cavalry in open terrain, etc.)
'   - Random factor for variability
'   Returns the damage amount that should be applied to the defender.
'============================================================================
FUNCTION ResolveMeleeCombat% (attackerIndex AS INTEGER, defenderIndex AS INTEGER, intensity AS INTEGER)
    ' Resolve melee combat
    ' Factors: intensity, strength, leadership, morale, experience, terrain, unit type, adjacent generals, luck
    ' Returns damage dealt
    
    DIM attackerStrength AS INTEGER
    DIM defenderStrength AS INTEGER
    DIM attackerEffectiveness AS SINGLE
    DIM defenderEffectiveness AS SINGLE
    DIM damage AS INTEGER
    
    attackerStrength = strength(attackerIndex)
    defenderStrength = strength(defenderIndex)
    
    ' Base effectiveness from leadership, experience, morale
    attackerEffectiveness = leader(attackerIndex) * LEADERSHIP_EFFECTIVENESS_MULTIPLIER + xper(attackerIndex) * EXPERIENCE_EFFECTIVENESS_MULTIPLIER + morale(attackerIndex) * MORALE_EFFECTIVENESS_MULTIPLIER
    defenderEffectiveness = leader(defenderIndex) * LEADERSHIP_EFFECTIVENESS_MULTIPLIER + xper(defenderIndex) * EXPERIENCE_EFFECTIVENESS_MULTIPLIER + morale(defenderIndex) * MORALE_EFFECTIVENESS_MULTIPLIER
    
    ' Apply intensity multiplier
    attackerEffectiveness = attackerEffectiveness * intensity
    defenderEffectiveness = defenderEffectiveness * intensity
    
    ' ============================================================
    ' TERRAIN EFFECTS - Combat Effectiveness Modifiers
    ' ============================================================
    ' Terrain affects both attacker and defender effectiveness
    ' Based on terrain type values used throughout the codebase:
    '   35 = River: +2 defense (0.5x attacker effectiveness)
    '   42 = Forest: +1 defense (0.8x attacker effectiveness)
    '   61 = Swamp: +1 defense (1.2x attacker effectiveness - difficult terrain)
    '   94 = Hills: +1 defense (0.6x attacker effectiveness)
    '   239 = Mountains: +2 defense (0.4x attacker effectiveness)
    '   232/233 = Clear/Road: No modifier (1.0x)
    '   254 = Defensive terrain: +1 defense (0.8x attacker effectiveness)
    ' ============================================================
    DIM attackerTerrain AS INTEGER
    DIM defenderTerrain AS INTEGER
    attackerTerrain = terrain(attackerIndex)
    defenderTerrain = terrain(defenderIndex)
    
    ' Apply terrain modifiers to attacker effectiveness (based on defender's terrain)
    SELECT CASE defenderTerrain
        CASE TERRAIN_RIVER ' River - very defensive
            attackerEffectiveness = attackerEffectiveness * TERRAIN_RIVER_ATTACKER_MULT
        CASE TERRAIN_FOREST ' Forest - defensive
            attackerEffectiveness = attackerEffectiveness * TERRAIN_FOREST_ATTACKER_MULT
        CASE TERRAIN_SWAMP ' Swamp - difficult terrain
            attackerEffectiveness = attackerEffectiveness * TERRAIN_SWAMP_ATTACKER_MULT ' Attacker has harder time
        CASE TERRAIN_HILLS ' Hills - defensive
            attackerEffectiveness = attackerEffectiveness * TERRAIN_HILLS_ATTACKER_MULT
        CASE TERRAIN_MOUNTAINS ' Mountains - very defensive
            attackerEffectiveness = attackerEffectiveness * TERRAIN_MOUNTAINS_ATTACKER_MULT
        CASE TERRAIN_DEFENSIVE ' Defensive terrain
            attackerEffectiveness = attackerEffectiveness * TERRAIN_DEFENSIVE_ATTACKER_MULT
        CASE TERRAIN_CLEAR, TERRAIN_ROAD ' Clear/Road - no modifier
            ' No change to attacker effectiveness
        CASE ELSE
            ' Unknown terrain - no modifier
    END SELECT
    
    ' Apply terrain modifiers to defender effectiveness (based on defender's terrain)
    ' Defenders get bonuses when on defensive terrain
    SELECT CASE defenderTerrain
        CASE TERRAIN_RIVER ' River - very defensive
            defenderEffectiveness = defenderEffectiveness * TERRAIN_RIVER_DEFENDER_MULT
        CASE TERRAIN_FOREST ' Forest - defensive
            defenderEffectiveness = defenderEffectiveness * TERRAIN_FOREST_DEFENDER_MULT
        CASE TERRAIN_SWAMP ' Swamp - difficult terrain
            defenderEffectiveness = defenderEffectiveness * TERRAIN_SWAMP_DEFENDER_MULT
        CASE TERRAIN_HILLS ' Hills - defensive
            defenderEffectiveness = defenderEffectiveness * TERRAIN_HILLS_DEFENDER_MULT
        CASE TERRAIN_MOUNTAINS ' Mountains - very defensive
            defenderEffectiveness = defenderEffectiveness * TERRAIN_MOUNTAINS_DEFENDER_MULT
        CASE TERRAIN_DEFENSIVE ' Defensive terrain
            defenderEffectiveness = defenderEffectiveness * TERRAIN_DEFENSIVE_DEFENDER_MULT
        CASE TERRAIN_CLEAR, TERRAIN_ROAD ' Clear/Road - no modifier
            ' No change to defender effectiveness
        CASE ELSE
            ' Unknown terrain - no modifier
    END SELECT
    
    ' ============================================================
    ' UNIT TYPE EFFECTS - Based on terrain
    ' ============================================================
    ' Cavalry gets bonus in open terrain (clear/road)
    ' Artillery gets bonus at range (handled in ResolveArtilleryBombardment)
    DIM attackerUnitType AS STRING
    attackerUnitType = LEFTY$(attackerIndex)
    
    IF attackerUnitType = "C" THEN ' Cavalry
        IF defenderTerrain = TERRAIN_CLEAR OR defenderTerrain = TERRAIN_ROAD THEN ' Clear/Road
            attackerEffectiveness = attackerEffectiveness * CAVALRY_OPEN_TERRAIN_BONUS ' 20% bonus in open terrain
        ELSEIF defenderTerrain = TERRAIN_FOREST OR defenderTerrain = TERRAIN_SWAMP THEN ' Forest/Swamp
            attackerEffectiveness = attackerEffectiveness * CAVALRY_DIFFICULT_TERRAIN_PENALTY ' Penalty in difficult terrain
        END IF
    END IF
    
    ' Calculate damage
    damage = INT(attackerStrength * attackerEffectiveness * RND)
    
    ResolveMeleeCombat% = damage
END FUNCTION

'============================================================================
' ResolveArtilleryBombardment - Resolve artillery bombardment attack
'============================================================================
' Parameters:
'   artilleryIndex (INTEGER) - Index of artillery unit performing bombardment
'   targetIndex (INTEGER) - Index of target unit
' Description:
'   Resolves an artillery bombardment attack. Checks line of sight between
'   artillery and target. Calculates damage based on range: canister fire
'   (range <= 2) is devastating (2x multiplier), while long range bombardment
'   (range > 2) is less effective (0.5x multiplier). Applies damage directly
'   to target unit strength.
' Side Effects:
'   - Reduces strength(targetIndex) by calculated damage
'   - Exits early if no line of sight
'============================================================================
SUB ResolveArtilleryBombardment (artilleryIndex AS INTEGER, targetIndex AS INTEGER)
    ' Resolve artillery bombardment
    ' Can bombard visible enemies at distance
    ' Line of sight restrictions
    ' Canister fire at close range
    
    DIM range AS INTEGER
    DIM damage AS INTEGER
    
    ' Check line of sight
    DIM F AS INTEGER
    CALL los(artilleryIndex, targetIndex, F, 0)
    IF F < 0 OR F = 0 THEN EXIT SUB ' No line of sight
    
    ' Calculate range
    CALL ranger(artilleryIndex, range)
    
    ' Calculate damage based on range and type
    IF range <= 2 THEN
        ' Canister fire - devastating
        damage = strength(artilleryIndex) * ARTILLERY_CANISTER_MULTIPLIER
    ELSE
        ' Long range bombardment
        damage = strength(artilleryIndex) * ARTILLERY_LONG_RANGE_MULTIPLIER
    END IF
    
    ' Apply damage
    strength(targetIndex) = strength(targetIndex) - damage
    IF strength(targetIndex) < 0 THEN strength(targetIndex) = 0
END SUB

'============================================================================
' ResolveCavalryCharge - Resolve cavalry charge attack
'============================================================================
' Parameters:
'   cavalryIndex (INTEGER) - Index of cavalry unit performing charge
'   targetIndex (INTEGER) - Index of target unit
' Description:
'   Resolves a cavalry charge attack. Charges cannot be performed from bridge
'   hexes (terrain = 234). Cavalry charges receive a 50% effectiveness bonus
'   on clear/road terrain. If the target is also cavalry, there is a 30%
'   chance of a "test of nerves" where one unit may rout (50% chance attacker
'   routs, 50% chance defender routs).
' Side Effects:
'   - Reduces strength(targetIndex) by calculated damage
'   - May set uorder to 99 (routed) for either unit in cavalry vs cavalry combat
'   - Exits early if charge not possible (on bridge)
'============================================================================
SUB ResolveCavalryCharge (cavalryIndex AS INTEGER, targetIndex AS INTEGER)
    ' Resolve cavalry charge
    ' Automatic bonus on clear/road terrain
    ' Cavalry vs cavalry = test of nerves
    ' Bridge hexes prevent charges
    
    DIM terrainType AS INTEGER
    terrainType = terrain(cavalryIndex)
    
    ' Check if charge possible (not on bridge)
    IF terrainType = 234 THEN EXIT SUB ' Bridge prevents charge
    
    DIM bonus AS SINGLE
    bonus = CAVALRY_CHARGE_BONUS ' 50% bonus on clear/road terrain
    
    ' Resolve charge combat
    DIM damage AS INTEGER
    damage = INT(strength(cavalryIndex) * bonus * RND)
    
    strength(targetIndex) = strength(targetIndex) - damage
    IF strength(targetIndex) < 0 THEN strength(targetIndex) = 0
    
    ' Cavalry vs cavalry test of nerves
    IF LEFTY$(targetIndex) = "C" THEN ' Target is also cavalry
        IF RND < 0.3 THEN
            ' Both may rout
            IF RND < 0.5 THEN
                ' Attacker routs
                uorder(cavalryIndex) = 99 ' Routed
            ELSE
                ' Defender routs
                uorder(targetIndex) = 99 ' Routed
            END IF
        END IF
    END IF
END SUB

'============================================================================
' CheckObjectiveControl - Check if a side controls the objective
'============================================================================
' Parameters:
'   sideNum (INTEGER) - Side number (1 or 2)
' Returns:
'   INTEGER - 1 if side controls objective, 0 otherwise
' Description:
'   Checks if any unit from the specified side is currently on the objective
'   hex. The objective hex is identified by terrain = 233 (TERRAIN_ROAD).
'   Only counts units with strength > 0 and not routed (uorder <> 99).
'   Used for victory condition checking.
'============================================================================
FUNCTION CheckObjectiveControl% (sideNum AS INTEGER)
    DIM k AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    
    ' Determine unit range for this side
    IF sideNum = 1 THEN
        startIndex = 1
        endIndex = bigg(1)
    ELSE
        startIndex = m2
        endIndex = bigg(2)
    END IF
    
    ' Check if any unit from this side is on the objective
    FOR k = startIndex TO endIndex
        IF strength(k) > 0 AND uorder(k) <> UNIT_ORDER_ROUTED AND terrain(k) = TERRAIN_ROAD THEN
            CheckObjectiveControl% = 1
            EXIT FUNCTION
        END IF
    NEXT k
    
    CheckObjectiveControl% = 0
END FUNCTION

'============================================================================
' CheckVictoryConditions - Check tactical battle victory conditions
'============================================================================
' Returns winner (1 or 2) or 0 if battle continues
' Uses early returns for clarity and performance
'
' VICTORY CONDITIONS (checked in order):
' --------------------------------------
' 1. Objective Control:
'    - If one side previously controlled objective (possess = 1 or 2)
'    - And that side loses control (no units on objective hex)
'    - And the other side gains control (has units on objective hex)
'    - Then the other side wins immediately
'    - Objective hex is identified by terrain = 233
'
' 2. Army Rout (Esprit de Corps):
'    - If one side's elan (esprit de corps) drops to 0 or below
'    - That side is considered routed
'    - The other side wins immediately
'    - Note: brittle() subroutine also checks this and calls over() if needed
'    - This check provides redundancy for safety
'
' If no condition is met, battle continues (returns 0)
'============================================================================
FUNCTION CheckVictoryConditions% ()
    
    ' ============================================================
    ' CONDITION 1: OBJECTIVE CONTROL
    ' ============================================================
    ' Check if objective control has changed hands
    ' possess variable tracks who last controlled objective (set by victory() SUB)
    ' If possess = 0, no one has controlled objective yet (battle just started)
    
    IF possess = 1 THEN
        ' Side 1 previously controlled objective - check if they still do
        IF CheckObjectiveControl%(1) = 0 THEN
            ' Side 1 lost control - check if side 2 now controls it
            IF CheckObjectiveControl%(2) = 1 THEN
                ' Side 2 captured objective - they win
                CheckVictoryConditions% = sidex(2)
                EXIT FUNCTION
            END IF
            ' If neither side controls it now, battle continues
        END IF
        ' If side 1 still controls it, battle continues
    ELSEIF possess = 2 THEN
        ' Side 2 previously controlled objective - check if they still do
        IF CheckObjectiveControl%(2) = 0 THEN
            ' Side 2 lost control - check if side 1 now controls it
            IF CheckObjectiveControl%(1) = 1 THEN
                ' Side 1 captured objective - they win
                CheckVictoryConditions% = sidex(1)
                EXIT FUNCTION
            END IF
            ' If neither side controls it now, battle continues
        END IF
        ' If side 2 still controls it, battle continues
    END IF
    ' If possess = 0, no one has controlled objective yet, battle continues
    
    ' ============================================================
    ' CONDITION 2: ARMY ROUT (ESPRIT DE CORPS)
    ' ============================================================
    ' Check if one side's morale/cohesion has completely collapsed
    ' elan[] array tracks esprit de corps for each side (1-2)
    ' When elan drops to 0 or below, that side routs
    ' brittle() subroutine also monitors this and calls over() if needed
    ' This check provides redundancy for safety
    
    IF elan(1) <= 0 THEN
        ' Side 1 routed - side 2 wins
        CheckVictoryConditions% = sidex(2)
        EXIT FUNCTION
    END IF
    
    IF elan(2) <= 0 THEN
        ' Side 2 routed - side 1 wins
        CheckVictoryConditions% = sidex(1)
        EXIT FUNCTION
    END IF
    
    ' ============================================================
    ' NO VICTORY CONDITION MET
    ' ============================================================
    ' Battle continues - return 0
    CheckVictoryConditions% = 0
END FUNCTION

'============================================================================
' UpdateEspritDeCorps - Update esprit de corps for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to update (1 or 2)
'   change (INTEGER) - Change amount (positive = increase, negative = decrease)
' Description:
'   Updates the esprit de corps (elan) for a side. Esprit de corps rises when
'   taking objectives, eliminating enemy units, or pursuing retreating units.
'   It falls when units are routed/eliminated, especially generals. The value
'   is clamped between 0 and 100. After updating, calls brittle() to update
'   the side's brittleness (rout threshold).
' Side Effects:
'   - Modifies elan(side) by change amount
'   - Clamps elan(side) to 0-100 range
'   - Calls brittle() to update brittleness
'============================================================================
SUB UpdateEspritDeCorps (side AS INTEGER, change AS INTEGER)
    ' Update esprit de corps for side
    ' Rises when: taking objective, eliminating enemy unit, pursuing retreating unit
    ' Falls when: unit routed/eliminated (especially generals)
    
    elan(side) = elan(side) + change
    IF elan(side) < 0 THEN elan(side) = 0
    IF elan(side) > 100 THEN elan(side) = 100
    
    CALL brittle(side) ' Update brittleness
END SUB

'============================================================================
' CheckLineOfSight - Check line of sight between two units
'============================================================================
' Parameters:
'   fromIndex (INTEGER) - Index of unit checking line of sight
'   toIndex (INTEGER) - Index of target unit
' Returns:
'   INTEGER - -1 if friendly unit, 0 if no line of sight, 1 if enemy in line of sight
' Description:
'   Checks if there is a clear line of sight between two units. Affected by
'   terrain: mountains/hills increase visibility, forests/swamps decrease it.
'   Uses the los() subroutine to perform the actual calculation. Returns -1
'   if checking line of sight to own unit (friendly).
'============================================================================
FUNCTION CheckLineOfSight% (fromIndex AS INTEGER, toIndex AS INTEGER)
    ' Check line of sight between units
    ' Affected by terrain: mountains/hills = increased, forests/swamps = decreased
    ' Returns: -1 = friendly, 0 = no LOS, 1 = enemy in LOS
    
    DIM result AS INTEGER
    CALL los(fromIndex, toIndex, result, 0)
    CheckLineOfSight% = result
END FUNCTION

'============================================================================
' ProcessUnitMovement - Process unit movement to target hex
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to move
'   targetX (INTEGER) - Target X coordinate (hex column)
'   targetY (INTEGER) - Target Y coordinate (hex row)
' Description:
'   Moves a unit to the specified target hex coordinates. Updates the unit's
'   position (unitx, unity) and triggers visibility updates. Terrain for the
'   new position is updated separately in unit_management.bas when movement
'   completes. This function handles the basic position update.
' Side Effects:
'   - Updates unitx(unitIndex) and unity(unitIndex)
'   - Calls see() to update visibility
'============================================================================
SUB ProcessUnitMovement (unitIndex AS INTEGER, targetX AS INTEGER, targetY AS INTEGER)
    ' Process unit movement
    ' Terrain affects movement speed
    ' Units can rest (spacebar) or wait (W key)
    
    ' Move unit to target hex
    unitx(unitIndex) = targetX
    unity(unitIndex) = targetY
    
    ' Update terrain for new position
    ' Note: Terrain is updated in unit_management.bas when movement completes
    ' This function is called before terrain update, so we don't modify it here
    
    ' Update visibility
    CALL see(unitIndex)
END SUB

'============================================================================
' GetTerrainMovementCost - Get movement cost modifier for terrain
'============================================================================
' Parameters:
'   terrainType (INTEGER) - Terrain type value
' Returns:
'   SINGLE - Movement cost multiplier (1.0 = normal, >1.0 = slower, <1.0 = faster)
' Description:
'   Returns the movement cost multiplier for a given terrain type. Used to
'   calculate how terrain affects unit movement speed. Values > 1.0 slow
'   movement (e.g., 2.0 = double cost), values < 1.0 speed up movement
'   (e.g., 0.8 = 20% faster). Returns TERRAIN_NORMAL_MOVEMENT_COST (1.0) for
'   unknown terrain types.
'============================================================================
FUNCTION GetTerrainMovementCost! (terrainType AS INTEGER)
    SELECT CASE terrainType
        CASE TERRAIN_RIVER ' River - difficult to cross
            GetTerrainMovementCost! = TERRAIN_RIVER_MOVEMENT_COST ' Double movement cost
        CASE TERRAIN_FOREST ' Forest - slower movement
            GetTerrainMovementCost! = TERRAIN_FOREST_MOVEMENT_COST ' 50% slower
        CASE TERRAIN_SWAMP ' Swamp - very slow
            GetTerrainMovementCost! = TERRAIN_SWAMP_MOVEMENT_COST ' 150% slower
        CASE TERRAIN_HILLS ' Hills - slightly slower
            GetTerrainMovementCost! = TERRAIN_HILLS_MOVEMENT_COST ' 20% slower
        CASE TERRAIN_MOUNTAINS ' Mountains - very slow
            GetTerrainMovementCost! = TERRAIN_MOUNTAINS_MOVEMENT_COST ' Double movement cost
        CASE TERRAIN_CLEAR, TERRAIN_ROAD ' Clear/Road - faster movement
            GetTerrainMovementCost! = TERRAIN_CLEAR_MOVEMENT_COST ' 20% faster
        CASE TERRAIN_DEFENSIVE ' Defensive terrain - slightly slower
            GetTerrainMovementCost! = TERRAIN_DEFENSIVE_MOVEMENT_COST ' 10% slower
        CASE ELSE
            ' Unknown terrain - normal movement
            GetTerrainMovementCost! = TERRAIN_NORMAL_MOVEMENT_COST
    END SELECT
END FUNCTION

'============================================================================
' GetTerrainVisibilityModifier - Get visibility modifier for terrain
'============================================================================
' Parameters:
'   terrainType (INTEGER) - Terrain type value
' Returns:
'   INTEGER - Visibility modifier (+ = increased, - = decreased)
' Description:
'   Returns the visibility modifier for a given terrain type. Positive values
'   increase visibility (hills +2, mountains +4), negative values decrease
'   visibility (forest -2, swamp -4). Used for line of sight and range
'   calculations. Returns 0 for terrain types with no visibility modifier.
'============================================================================
FUNCTION GetTerrainVisibilityModifier% (terrainType AS INTEGER)
    SELECT CASE terrainType
        CASE 94 ' Hills - increased visibility
            GetTerrainVisibilityModifier% = 2
        CASE 239 ' Mountains - increased visibility
            GetTerrainVisibilityModifier% = 4
        CASE 42 ' Forest - decreased visibility
            GetTerrainVisibilityModifier% = -2
        CASE 61 ' Swamp - decreased visibility
            GetTerrainVisibilityModifier% = -4
        CASE ELSE
            ' No modifier
            GetTerrainVisibilityModifier% = 0
    END SELECT
END FUNCTION

'============================================================================
' ProcessStrategicRetreat - Process strategic retreat for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side performing strategic retreat (1 or 2)
' Description:
'   Processes a strategic retreat (triggered by F9 key). The retreating side
'   loses control of the objective and takes 20% additional losses to all units.
'   This is useful to avoid greater battlefield losses when defeat is inevitable.
'   Strategic retreats allow a side to preserve more forces than a complete rout.
' Side Effects:
'   - Reduces strength of all units on side by 20% (STRATEGIC_RETREAT_LOSS_MULTIPLIER)
'   - Side loses objective control (possess will be reset)
'============================================================================
SUB ProcessStrategicRetreat (side AS INTEGER)
    ' Process strategic retreat (F9 key)
    ' Loses objective, takes 20% additional losses
    ' Useful to avoid greater battlefield losses
    
    DIM k AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    
    IF side = 1 THEN
        startIndex = 1
        endIndex = bigg(1)
    ELSE
        startIndex = m2
        endIndex = bigg(2)
    END IF
    
    ' Apply strategic retreat losses
    FOR k = startIndex TO endIndex
        IF strength(k) > 0 THEN
            strength(k) = INT(strength(k) * STRATEGIC_RETREAT_LOSS_MULTIPLIER) ' 20% loss
        END IF
    NEXT k
    
    ' Side loses objective
    ' (Objective control will be reset)
END SUB

