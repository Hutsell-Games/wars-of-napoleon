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

SUB InitializeBattleMap
    ' Initialize 27x20 hex grid battle map
    ' Random terrain generation
    ' This uses the randmap SUB from NAPOLEON.BAS
    CALL randmap
END SUB

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
    attackerEffectiveness = leader(attackerIndex) * 0.1 + xper(attackerIndex) * 0.1 + morale(attackerIndex) * 0.1
    defenderEffectiveness = leader(defenderIndex) * 0.1 + xper(defenderIndex) * 0.1 + morale(defenderIndex) * 0.1
    
    ' Apply intensity multiplier
    attackerEffectiveness = attackerEffectiveness * intensity
    defenderEffectiveness = defenderEffectiveness * intensity
    
    ' Terrain effects (placeholder - will implement terrain bonuses)
    
    ' Unit type effects (placeholder - will implement unit type bonuses)
    
    ' Calculate damage
    damage = INT(attackerStrength * attackerEffectiveness * RND)
    
    ResolveMeleeCombat% = damage
END FUNCTION

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
        damage = strength(artilleryIndex) * 2
    ELSE
        ' Long range bombardment
        damage = strength(artilleryIndex) * 0.5
    END IF
    
    ' Apply damage
    strength(targetIndex) = strength(targetIndex) - damage
    IF strength(targetIndex) < 0 THEN strength(targetIndex) = 0
END SUB

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
    bonus = 1.5 ' 50% bonus on clear/road terrain
    
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
' Helper Function: CheckObjectiveControl
'============================================================================
' Checks if a side controls the objective (terrain = 233)
' Parameters:
'   sideNum (INTEGER) - Side number (1 or 2)
' Returns:
'   INTEGER - 1 if side controls objective, 0 otherwise
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
        IF strength(k) > 0 AND uorder(k) <> 99 AND terrain(k) = 233 THEN
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

SUB UpdateEspritDeCorps (side AS INTEGER, change AS INTEGER)
    ' Update esprit de corps for side
    ' Rises when: taking objective, eliminating enemy unit, pursuing retreating unit
    ' Falls when: unit routed/eliminated (especially generals)
    
    elan(side) = elan(side) + change
    IF elan(side) < 0 THEN elan(side) = 0
    IF elan(side) > 100 THEN elan(side) = 100
    
    CALL brittle(side) ' Update brittleness
END SUB

FUNCTION CheckLineOfSight% (fromIndex AS INTEGER, toIndex AS INTEGER)
    ' Check line of sight between units
    ' Affected by terrain: mountains/hills = increased, forests/swamps = decreased
    ' Returns: -1 = friendly, 0 = no LOS, 1 = enemy in LOS
    
    DIM result AS INTEGER
    CALL los(fromIndex, toIndex, result, 0)
    CheckLineOfSight% = result
END FUNCTION

SUB ProcessUnitMovement (unitIndex AS INTEGER, targetX AS INTEGER, targetY AS INTEGER)
    ' Process unit movement
    ' Terrain affects movement speed
    ' Units can rest (spacebar) or wait (W key)
    
    ' Move unit to target hex
    unitx(unitIndex) = targetX
    unity(unitIndex) = targetY
    
    ' Update visibility
    CALL see(unitIndex)
END SUB

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
    
    ' Apply 20% additional losses
    FOR k = startIndex TO endIndex
        IF strength(k) > 0 THEN
            strength(k) = INT(strength(k) * 0.8) ' 20% loss
        END IF
    NEXT k
    
    ' Side loses objective
    ' (Objective control will be reset)
END SUB

