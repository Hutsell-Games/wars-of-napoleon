'============================================================================
' Unit Types and Behaviors
'============================================================================
' Tactical battle unit types: Infantry, Hollow Squares, Cavalry, Artillery, Generals
' Refactored from NAPOLEON.BAS

' Unit type constants (matching NAPOLEON.BAS)
CONST UNIT_INFANTRY = 1
CONST UNIT_HOLLOW_SQUARE = 2
CONST UNIT_CAVALRY = 3
CONST UNIT_ARTILLERY = 4
CONST UNIT_GENERAL = 5

' Unit type characters (from NAPOLEON.BAS)
CONST UNIT_CHAR_INFANTRY = "I"
CONST UNIT_CHAR_SQUARE = "S"
CONST UNIT_CHAR_CAVALRY = "C"
CONST UNIT_CHAR_ARTILLERY = "A"
CONST UNIT_CHAR_GENERAL = "G"

FUNCTION GetUnitType% (unitIndex AS INTEGER)
    ' Get unit type from unit index
    ' Determines based on unit character code
    
    DIM unitChar AS STRING
    unitChar = LEFTY$(unitIndex) ' Get unit type character
    
    SELECT CASE unitChar
        CASE "I"
            GetUnitType% = UNIT_INFANTRY
        CASE "S"
            GetUnitType% = UNIT_HOLLOW_SQUARE
        CASE "C"
            GetUnitType% = UNIT_CAVALRY
        CASE "A"
            GetUnitType% = UNIT_ARTILLERY
        CASE "G"
            GetUnitType% = UNIT_GENERAL
        CASE ELSE
            GetUnitType% = UNIT_INFANTRY ' Default
    END SELECT
END FUNCTION

FUNCTION CanInfantryCharge% (unitIndex AS INTEGER)
    ' Check if infantry can charge
    ' Infantry can charge on open ground
    
    IF GetUnitType%(unitIndex) <> UNIT_INFANTRY THEN
        CanInfantryCharge% = 0
        EXIT FUNCTION
    END IF
    
    DIM terrainType AS INTEGER
    terrainType = terrain(unitIndex)
    
    ' Check if open ground (clear or road)
    IF terrainType = 232 OR terrainType = 233 THEN ' Clear or road
        CanInfantryCharge% = 1
    ELSE
        CanInfantryCharge% = 0
    END IF
END FUNCTION

FUNCTION CanHollowSquareMove% (unitIndex AS INTEGER)
    ' Check if hollow square can move
    ' Hollow squares cannot move (defensive formation)
    
    IF GetUnitType%(unitIndex) = UNIT_HOLLOW_SQUARE THEN
        CanHollowSquareMove% = 0
    ELSE
        CanHollowSquareMove% = 1
    END IF
END FUNCTION

FUNCTION GetCavalryChargeBonus! (unitIndex AS INTEGER)
    ' Get cavalry charge bonus
    ' Automatic bonus on clear/road terrain
    
    IF GetUnitType%(unitIndex) <> UNIT_CAVALRY THEN
        GetCavalryChargeBonus! = 1.0
        EXIT FUNCTION
    END IF
    
    DIM terrainType AS INTEGER
    terrainType = terrain(unitIndex)
    
    ' Bonus on clear/road terrain
    IF terrainType = 232 OR terrainType = 233 THEN
        GetCavalryChargeBonus! = 1.5 ' 50% bonus
    ELSE
        GetCavalryChargeBonus! = 1.0 ' No bonus
    END IF
END FUNCTION

FUNCTION CanArtilleryMove% (unitIndex AS INTEGER)
    ' Check if artillery can move
    ' Artillery must limber before moving
    
    IF GetUnitType%(unitIndex) <> UNIT_ARTILLERY THEN
        CanArtilleryMove% = 1
        EXIT FUNCTION
    END IF
    
    ' Check if limbered (placeholder - will check limber status)
    ' Artillery must use L key to limber before moving
    CanArtilleryMove% = 1 ' Placeholder
END FUNCTION

FUNCTION GetGeneralBonus! (generalIndex AS INTEGER, unitIndex AS INTEGER)
    ' Get general's bonus to adjacent units
    ' Generals boost adjacent units
    
    IF GetUnitType%(generalIndex) <> UNIT_GENERAL THEN
        GetGeneralBonus! = 1.0
        EXIT FUNCTION
    END IF
    
    ' Check if general is adjacent to unit
    DIM dx AS INTEGER
    DIM dy AS INTEGER
    dx = ABS(unitx(generalIndex) - unitx(unitIndex))
    dy = ABS(unity(generalIndex) - unity(unitIndex))
    
    IF dx <= 1 AND dy <= 1 THEN
        ' Adjacent - apply bonus based on general's leadership
        GetGeneralBonus! = 1.0 + (leader(generalIndex) * 0.05) ' 5% per leadership point
    ELSE
        GetGeneralBonus! = 1.0
    END IF
END FUNCTION

SUB ProcessInfantryCharge (unitIndex AS INTEGER, targetX AS INTEGER, targetY AS INTEGER)
    ' Process infantry charge order
    ' Double speed on open/road terrain
    
    DIM terrainType AS INTEGER
    terrainType = terrain(unitIndex)
    
    IF terrainType = 232 OR terrainType = 233 THEN
        ' Open/road terrain - double speed
        ' Move unit at double speed
        CALL ProcessUnitMovement(unitIndex, targetX, targetY)
        ' Apply charge bonus in combat
    END IF
END SUB

SUB ProcessArtilleryLimber (unitIndex AS INTEGER)
    ' Process artillery limbering
    ' Artillery must limber before moving
    
    IF GetUnitType%(unitIndex) = UNIT_ARTILLERY THEN
        ' Set limbered flag (placeholder)
        COLOR 11: CALL clrbot: PRINT name$(unitIndex); " limbered - ready to move"
    END IF
END SUB

SUB ProcessGeneralInspire (generalIndex AS INTEGER)
    ' Process general inspire order
    ' Generals can inspire/cancel orders for adjacent units
    
    DIM i AS INTEGER
    DIM dx AS INTEGER
    DIM dy AS INTEGER
    
    ' Find adjacent units and inspire them
    FOR i = 1 TO bigg(2)
        IF strength(i) > 0 AND i <> generalIndex THEN
            dx = ABS(unitx(generalIndex) - unitx(i))
            dy = ABS(unity(generalIndex) - unity(i))
            
            IF dx <= 1 AND dy <= 1 THEN
                ' Adjacent unit - boost morale
                IF morale(i) < 5 THEN
                    morale(i) = morale(i) + 1
                END IF
            END IF
        END IF
    NEXT i
    
    COLOR 11: CALL clrbot: PRINT name$(generalIndex); " inspires nearby units"
END SUB

FUNCTION GetUnitCombatEffectiveness! (unitIndex AS INTEGER)
    ' Get unit combat effectiveness
    ' Factors: unit type, strength, leadership, experience, morale, terrain
    
    DIM effectiveness AS SINGLE
    
    ' Base effectiveness
    effectiveness = 1.0
    
    ' Leadership bonus
    effectiveness = effectiveness * (1.0 + leader(unitIndex) * 0.1)
    
    ' Experience bonus
    effectiveness = effectiveness * (1.0 + xper(unitIndex) * 0.1)
    
    ' Morale bonus
    effectiveness = effectiveness * (1.0 + morale(unitIndex) * 0.1)
    
    ' Unit type modifiers
    SELECT CASE GetUnitType%(unitIndex)
        CASE UNIT_CAVALRY
            ' Cavalry bonus on open terrain
            IF terrain(unitIndex) = 232 OR terrain(unitIndex) = 233 THEN
                effectiveness = effectiveness * 1.2
            END IF
        CASE UNIT_HOLLOW_SQUARE
            ' Defensive bonus
            effectiveness = effectiveness * 1.3
        CASE UNIT_ARTILLERY
            ' Artillery poor in melee
            effectiveness = effectiveness * 0.5
        CASE UNIT_GENERAL
            ' Generals poor in melee
            effectiveness = effectiveness * 0.3
    END SELECT
    
    GetUnitCombatEffectiveness! = effectiveness
END FUNCTION

SUB ApplyUnitCasualties (unitIndex AS INTEGER, casualties AS INTEGER)
    ' Apply casualties to unit
    ' Updates strength, may cause rout
    
    strength(unitIndex) = strength(unitIndex) - casualties
    IF strength(unitIndex) < 0 THEN strength(unitIndex) = 0
    
    ' Check for rout
    IF strength(unitIndex) = 0 THEN
        CALL wipeout(unitIndex)
    ELSEIF strength(unitIndex) < strength(unitIndex) * 0.5 THEN
        ' Heavy casualties - chance of rout
        IF RND < 0.3 THEN
            uorder(unitIndex) = 99 ' Routed
            morale(unitIndex) = morale(unitIndex) - 1
            IF morale(unitIndex) < 0 THEN morale(unitIndex) = 0
        END IF
    END IF
END SUB

