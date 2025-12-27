'============================================================================
' Economic System
'============================================================================
' Ported from CWS - harvest months (July, September free)
' Handles income, supply, unit costs

' Note: game_types.bas is included in main.bas
' Note: Supply cost constants are in declarations.bas
' Note: campaign.bas, army.bas are included in main.bas

'============================================================================
' UpdateIncome - Update income for both sides based on city control
'============================================================================
' Description:
'   Calculates and updates income for both sides based on cities they
'   control. Each city's value contributes to the controlling side's income.
'   Income is added to cash reserves, which are capped at 19,999.
'   Called at the start of each turn.
' Side Effects:
'   - Updates gameState income for both sides
'   - Adds income to cash reserves
'   - Caps cash at maximum value (19,999)
'============================================================================
SUB UpdateIncome
    ' Update income for both sides based on city control
    ' Called at start of each turn
    
    DIM i AS INTEGER
    DIM income1 AS LONG
    DIM income2 AS LONG
    
    income1 = 0
    income2 = 0
    
    FOR i = 1 TO MAX_CITIES
        IF IsCityOwnedBy%(i, 1) = 1 THEN
            income1 = income1 + cities(i).value
        ELSEIF IsCityOwnedBy%(i, 2) = 1 THEN
            income2 = income2 + cities(i).value
        END IF
    NEXT i
    
    ' Set income
    CALL SetGameStateIncome(1, income1)
    CALL SetGameStateIncome(2, income2)
    
    ' Add income to cash
    CALL SetGameStateCash(1, GetGameStateCash&(1) + income1)
    CALL SetGameStateCash(2, GetGameStateCash&(2) + income2)
    
    ' Cap cash at maximum
    IF GetGameStateCash&(1) > MAX_CASH THEN CALL SetGameStateCash(1, MAX_CASH)
    IF GetGameStateCash&(2) > MAX_CASH THEN CALL SetGameStateCash(2, MAX_CASH)
END SUB

'============================================================================
' AutoSupply - Automatic supply distribution for all armies
'============================================================================
' Description:
'   Automatically supplies all armies for both sides. Cost is 0.002 money
'   units per 1,000 men. Supply is free during harvest months (July and
'   September). Each army receives +1 supply up to a maximum of 10.
'   Supply is only applied if the side has sufficient funds.
' Side Effects:
'   - Increases supply for all armies (if funds available)
'   - Deducts supply costs from cash reserves
'============================================================================
SUB AutoSupply
    ' Automatic supply distribution
    ' Cost: 0.002 money units per 1,000 men
    ' Free in harvest months (July, September)
    
    DIM i AS INTEGER
    DIM side AS INTEGER
    DIM cost AS SINGLE
    DIM totalCost AS SINGLE
    
    ' Check if harvest month
    IF IsHarvestMonth% THEN
        ' Free supply
        FOR i = 1 TO MAX_ARMIES
            IF IsArmyActive%(i) = 1 THEN
                armies(i).supply = armies(i).supply + 1
                IF armies(i).supply > MAX_SUPPLY THEN armies(i).supply = MAX_SUPPLY
                ' Supply changed - invalidate combat strength cache
                CALL InvalidateCombatStrengthCache(i)
            END IF
        NEXT i
        EXIT SUB
    END IF
    
    ' Calculate supply costs
    FOR side = 1 TO 2
        totalCost = 0
        FOR i = 1 TO MAX_ARMIES
            IF IsArmyActive%(i) = 1 THEN
                ' Determine side
                currentArmySide = GetArmySide%(i)
                IF currentArmySide = side THEN
                    cost = (armies(i).size / SUPPLY_CALCULATION_DIVISOR) * SUPPLY_AUTO_COST
                    totalCost = totalCost + cost
                END IF
            END IF
        NEXT i
        
        ' Apply supply
        IF GetGameStateCash&(side) >= totalCost THEN
            CALL SetGameStateCash(side, GetGameStateCash&(side) - totalCost)
        FOR i = 1 TO MAX_ARMIES
            IF IsArmyActive%(i) = 1 THEN
                ' Determine side and supply
                currentArmySide = GetArmySide%(i)
                IF currentArmySide = side THEN
                    armies(i).supply = armies(i).supply + 1
                    armies(i).supply = ClampValue%(armies(i).supply, 0, MAX_SUPPLY)
                    ' Supply changed - invalidate combat strength cache
                    CALL InvalidateCombatStrengthCache(i)
                END IF
            END IF
        NEXT i
        END IF
    NEXT side
END SUB

'============================================================================
' ManualSupply - Manually supply a specific army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to supply
' Description:
'   Manually supplies a specific army. Cost is 0.001 money units per 1,000
'   men, which is cheaper than automatic supply. The army receives +1
'   supply up to a maximum of 10. Only applies if sufficient funds available.
' Side Effects:
'   - Increases army supply by 1 (up to max 10)
'   - Deducts supply cost from cash reserves
'   - Displays error if insufficient funds
'============================================================================
SUB ManualSupply (armyIndex AS INTEGER)
    ' Manual supply for specific army
    ' Cost: 0.001 money units per 1,000 men (cheaper than auto)
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "ManualSupply") = 0 THEN
        EXIT SUB
    END IF
    
    DIM side AS INTEGER
    DIM cost AS SINGLE
    
    IF IsArmyActive%(armyIndex) = 0 THEN EXIT SUB ' Not an error - empty army
    
    ' Determine side
    side = GetArmySide%(armyIndex)
    IF side = 0 THEN
        CALL HandleValidationError("Invalid army index " + LTRIM$(STR$(armyIndex)) + " in ManualSupply")
        EXIT SUB
    END IF
    
    cost = (armies(armyIndex).size / SUPPLY_CALCULATION_DIVISOR) * SUPPLY_MANUAL_COST
    
    IF GetGameStateCash&(side) < cost THEN
        CALL ShowStatusMessage("Insufficient funds for supply", 11)
        EXIT SUB ' Not an error - insufficient funds is expected
    END IF
    
    CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
    armies(armyIndex).supply = armies(armyIndex).supply + 1
    IF armies(armyIndex).supply > MAX_SUPPLY THEN armies(armyIndex).supply = MAX_SUPPLY
    
    CALL ShowStatusMessage(armies(armyIndex).name + " supplied manually", 11)
END SUB

'============================================================================
' ConsumeSupply - Consume supply for all armies
'============================================================================
' Description:
'   Reduces supply by 1 for all active armies each turn. Supply is not
'   consumed during harvest months (July, September) when free supply
'   is available. Armies with 0 supply fight at 50% combat effectiveness.
'   Called at the end of each turn.
' Side Effects:
'   - Reduces supply by 1 for all armies (minimum 0)
'============================================================================
SUB ConsumeSupply
    ' Consume supply for all armies
    ' Units use 1 supply per turn (except harvest months)
    ' Out of supply (0) = 50% combat effectiveness
    
    DIM i AS INTEGER
    
    ' Harvest months provide free supply, so no consumption
    IF IsHarvestMonth% THEN EXIT SUB
    
    FOR i = 1 TO MAX_ARMIES
        IF IsArmyActive%(i) = 1 THEN
            armies(i).supply = armies(i).supply - 1
            IF armies(i).supply < 0 THEN armies(i).supply = 0
        END IF
    NEXT i
END SUB

'============================================================================
' GetRecruitmentCost - Get cost to recruit a new army
'============================================================================
' Returns:
'   INTEGER - Cost in money units to recruit a new army
'============================================================================
FUNCTION GetRecruitmentCost% ()
    ' Get cost to recruit new army
    GetRecruitmentCost% = RECRUITMENT_COST
END FUNCTION

'============================================================================
' GetFortificationCost - Get cost per fortification level
'============================================================================
' Returns:
'   INTEGER - Cost in money units per fortification level
'============================================================================
FUNCTION GetFortificationCost% ()
    ' Get cost per fortification level
    GetFortificationCost% = FORTIFICATION_COST
END FUNCTION

'============================================================================
' GetShipCost - Get cost to build a ship
'============================================================================
' Returns:
'   INTEGER - Cost in money units to build one ship
'============================================================================
FUNCTION GetShipCost% ()
    ' Get cost to build ship
    GetShipCost% = SHIP_COST
END FUNCTION

'============================================================================
' IsOutOfSupply - Check if army is out of supply
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to check
' Returns:
'   INTEGER - 1 if army has 0 supply, 0 otherwise
' Description:
'   Checks if an army is out of supply (supply = 0). Out-of-supply armies
'   fight at 50% combat effectiveness.
'============================================================================
FUNCTION IsOutOfSupply% (armyIndex AS INTEGER)
    ' Check if army is out of supply
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "IsOutOfSupply") = 0 THEN
        IsOutOfSupply% = 0
        EXIT FUNCTION
    END IF
    
    IsOutOfSupply% = 0
    IF armies(armyIndex).supply = 0 THEN
        IsOutOfSupply% = 1
    END IF
END FUNCTION

