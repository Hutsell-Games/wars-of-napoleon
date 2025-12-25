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
    ' TODO: Implement randmap SUB from NAPOLEON.BAS
    ' CALL randmap ' From NAPOLEON.BAS
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
    CALL los(artilleryIndex, targetIndex, F, 0)
    IF F < 0 THEN EXIT SUB ' No line of sight
    
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

FUNCTION CheckVictoryConditions% ()
    ' Check tactical victory conditions
    ' Returns winner (1 or 2) or 0 if battle continues
    
    DIM winner AS INTEGER
    winner = 0
    
    ' Condition 1: Objective Control
    ' Check if objective is controlled by one side
    DIM objControlled AS INTEGER
    objControlled = 0
    ' This will check objective hex control (placeholder)
    
    ' Condition 2: Esprit de Corps
    ' Check if one side's esprit de corps is too low (army routs)
    IF elan(1) < 20 THEN
        winner = 2 ' Side 2 wins (side 1 routed)
    ELSEIF elan(2) < 20 THEN
        winner = 1 ' Side 1 wins (side 2 routed)
    END IF
    
    CheckVictoryConditions% = winner
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

