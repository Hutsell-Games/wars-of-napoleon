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

'============================================================================
' GetUnitType - Get unit type constant from unit index
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to check
' Returns:
'   INTEGER - Unit type constant (UNIT_INFANTRY, UNIT_HOLLOW_SQUARE, UNIT_CAVALRY, UNIT_ARTILLERY, UNIT_GENERAL)
' Description:
'   Determines the unit type by examining the unit's character code (LEFTY$).
'   Returns the corresponding unit type constant. Returns UNIT_INFANTRY as
'   default for unknown unit types.
'============================================================================
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

'============================================================================
' CanInfantryCharge - Check if infantry unit can charge
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to check
' Returns:
'   INTEGER - 1 if infantry can charge, 0 otherwise
' Description:
'   Checks if an infantry unit can perform a charge. Infantry can only charge
'   on open ground (clear terrain = 232 or road = 233). Returns 0 if the unit
'   is not infantry or is not on open ground.
'============================================================================
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

'============================================================================
' CanHollowSquareMove - Check if hollow square unit can move
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to check
' Returns:
'   INTEGER - 1 if unit can move, 0 if hollow square (cannot move)
' Description:
'   Checks if a unit can move. Hollow squares are defensive formations that
'   cannot move. All other unit types can move. Returns 0 for hollow squares,
'   1 for all other unit types.
'============================================================================
FUNCTION CanHollowSquareMove% (unitIndex AS INTEGER)
    ' Check if hollow square can move
    ' Hollow squares cannot move (defensive formation)
    
    IF GetUnitType%(unitIndex) = UNIT_HOLLOW_SQUARE THEN
        CanHollowSquareMove% = 0
    ELSE
        CanHollowSquareMove% = 1
    END IF
END FUNCTION

'============================================================================
' GetCavalryChargeBonus - Get cavalry charge effectiveness bonus
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of cavalry unit
' Returns:
'   SINGLE - Effectiveness multiplier (1.5 on clear/road, 1.0 otherwise)
' Description:
'   Returns the charge bonus multiplier for a cavalry unit. Cavalry receives
'   a 50% effectiveness bonus (1.5x) when charging on clear or road terrain.
'   Returns 1.0 (no bonus) for non-cavalry units or cavalry on other terrain.
'============================================================================
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

'============================================================================
' CanArtilleryMove - Check if artillery unit can move
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to check
' Returns:
'   INTEGER - 1 if artillery can move, 0 if cannot move
' Description:
'   Checks if an artillery unit can move. If limber mode is disabled (limber = 0),
'   artillery can always move. If limber mode is enabled, artillery must be
'   limbered (unit$ starts with "L") to move. Returns 1 for non-artillery units.
'============================================================================
FUNCTION CanArtilleryMove% (unitIndex AS INTEGER)
    ' Check if artillery can move
    ' Artillery must limber before moving (if limber mode is enabled)
    
    IF GetUnitType%(unitIndex) <> UNIT_ARTILLERY THEN
        CanArtilleryMove% = 1
        EXIT FUNCTION
    END IF
    
    ' If limber mode is disabled, artillery can always move
    IF limber = 0 THEN
        CanArtilleryMove% = 1
        EXIT FUNCTION
    END IF
    
    ' Check if artillery is limbered (unit$ starts with "L")
    ' Limbered artillery can move, unlimbered cannot
    IF LEFTY$(unitIndex) = "L" THEN
        CanArtilleryMove% = 1 ' Limbered - can move
    ELSE
        CanArtilleryMove% = 0 ' Not limbered - cannot move
    END IF
END FUNCTION

'============================================================================
' GetGeneralBonus - Get general's combat effectiveness bonus to adjacent units
'============================================================================
' Parameters:
'   generalIndex (INTEGER) - Index of general unit
'   unitIndex (INTEGER) - Index of unit to check bonus for
' Returns:
'   SINGLE - Effectiveness multiplier (1.0 + 0.05 per leadership point if adjacent, 1.0 otherwise)
' Description:
'   Calculates the combat effectiveness bonus a general provides to adjacent units.
'   The bonus is 5% per leadership point of the general. Units are considered
'   adjacent if they are within 1 hex in both X and Y coordinates. Returns 1.0
'   (no bonus) if the generalIndex is not a general or if the unit is not adjacent.
'============================================================================
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

'============================================================================
' ProcessInfantryCharge - Process infantry charge order
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of infantry unit
'   targetX (INTEGER) - Target X coordinate for charge
'   targetY (INTEGER) - Target Y coordinate for charge
' Description:
'   Processes an infantry charge order. Infantry charges can only be performed
'   on open/road terrain (232 or 233). Moves the unit to the target location
'   at double speed and applies charge bonuses in combat. Does nothing if
'   the unit is not on open/road terrain.
' Side Effects:
'   - Calls ProcessUnitMovement to move unit to target
'   - Charge bonus is applied during combat resolution
'============================================================================
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

'============================================================================
' ProcessArtilleryLimber - Process artillery limbering order
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of artillery unit
' Description:
'   Processes an artillery limbering order. Artillery must be limbered before
'   it can move (if limber mode is enabled). Calls limbo() to add the "L" prefix
'   to the unit$ string, indicating the artillery is limbered. Displays a
'   message confirming the limbering if successful.
' Side Effects:
'   - Calls limbo() to limber the artillery
'   - Modifies unit$(unitIndex) to add "L" prefix
'   - Displays confirmation message if limbering successful
'============================================================================
SUB ProcessArtilleryLimber (unitIndex AS INTEGER)
    ' Process artillery limbering
    ' Artillery must limber before moving
    ' Calls limbo function to handle limbering (adds "L" prefix to unit$)
    
    IF GetUnitType%(unitIndex) = UNIT_ARTILLERY THEN
        ' Call limbo to limber the artillery (flag=0 means direct limber without confirmation)
        CALL limbo(unitIndex, 0)
        IF LEFTY$(unitIndex) = "L" THEN
            COLOR 11: CALL clrbot: PRINT name$(unitIndex); " limbered - ready to move"
        END IF
    END IF
END SUB

'============================================================================
' ProcessGeneralInspire - Process general inspire order
'============================================================================
' Parameters:
'   generalIndex (INTEGER) - Index of general unit
' Description:
'   Processes a general inspire order. Generals can inspire adjacent units,
'   boosting their morale. Finds all units within 1 hex of the general and
'   increases their morale by 1 (up to maximum of 5). Displays a message
'   confirming the inspiration.
' Side Effects:
'   - Increases morale of adjacent units by 1 (max 5)
'   - Displays inspiration message
'============================================================================
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

'============================================================================
' GetUnitCombatEffectiveness - Calculate unit combat effectiveness multiplier
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to calculate effectiveness for
' Returns:
'   SINGLE - Combat effectiveness multiplier
' Description:
'   Calculates the overall combat effectiveness multiplier for a unit based on:
'   - Leadership rating (10% per point)
'   - Experience rating (10% per point)
'   - Morale rating (10% per point)
'   - Unit type modifiers (cavalry bonus on open terrain, hollow square defensive
'     bonus, artillery/general penalties in melee)
'   - Terrain effects (cavalry bonus on clear/road terrain)
'   Returns a multiplier that can be applied to base combat calculations.
'============================================================================
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

'============================================================================
' ApplyUnitCasualties - Apply casualties to a unit
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Index of unit to apply casualties to
'   casualties (INTEGER) - Number of casualties to apply
' Description:
'   Applies casualties to a unit by reducing its strength. If strength drops
'   to 0, the unit is eliminated (calls wipeout). If strength drops below 50%
'   of original, there is a 30% chance the unit will rout. Routed units have
'   their morale reduced by 1.
' Side Effects:
'   - Reduces strength(unitIndex) by casualties amount
'   - May call wipeout() if unit eliminated
'   - May set uorder(unitIndex) = 99 (routed) if heavy casualties
'   - May reduce morale(unitIndex) if unit routs
'============================================================================
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

