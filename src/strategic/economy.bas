'============================================================================
' Economic System
'============================================================================
' Ported from CWS - harvest months (July, September free)
' Handles income, supply, unit costs

' Note: game_types.bas is included in main.bas
' Note: Supply cost constants are in declarations.bas
' Note: campaign.bas, army.bas are included in main.bas

SUB UpdateIncome
    ' Update income for both sides based on city control
    ' Called at start of each turn
    
    DIM i AS INTEGER
    DIM income1 AS LONG
    DIM income2 AS LONG
    
    income1 = 0
    income2 = 0
    
    FOR i = 1 TO MAX_CITIES
        IF cities(i).owner = CITY_FRENCH THEN
            income1 = income1 + cities(i).value
        ELSEIF cities(i).owner = CITY_ALLIED THEN
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
    IF GetGameStateCash&(1) > 19999 THEN CALL SetGameStateCash(1, 19999)
    IF GetGameStateCash&(2) > 19999 THEN CALL SetGameStateCash(2, 19999)
END SUB

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
            IF armies(i).size > 0 THEN
                armies(i).supply = armies(i).supply + 1
                IF armies(i).supply > 10 THEN armies(i).supply = 10
            END IF
        NEXT i
        EXIT SUB
    END IF
    
    ' Calculate supply costs
    FOR side = 1 TO 2
        totalCost = 0
        FOR i = 1 TO MAX_ARMIES
            IF armies(i).size > 0 THEN
                ' Determine side
                IF i >= FRENCH_START AND i < ALLIED_START THEN
                    IF side = 1 THEN
                        cost = (armies(i).size / 1000) * SUPPLY_AUTO_COST
                        totalCost = totalCost + cost
                    END IF
                ELSEIF i >= ALLIED_START THEN
                    IF side = 2 THEN
                        cost = (armies(i).size / 1000) * SUPPLY_AUTO_COST
                        totalCost = totalCost + cost
                    END IF
                END IF
            END IF
        NEXT i
        
        ' Apply supply
        IF GetGameStateCash&(side) >= totalCost THEN
            CALL SetGameStateCash(side, GetGameStateCash&(side) - totalCost)
            FOR i = 1 TO MAX_ARMIES
                IF armies(i).size > 0 THEN
                    ' Determine side and supply
                    IF (side = 1 AND i >= FRENCH_START AND i < ALLIED_START) OR _
                       (side = 2 AND i >= ALLIED_START) THEN
                        armies(i).supply = armies(i).supply + 1
                        IF armies(i).supply > 10 THEN armies(i).supply = 10
                    END IF
                END IF
            NEXT i
        END IF
    NEXT side
END SUB

SUB ManualSupply (armyIndex AS INTEGER)
    ' Manual supply for specific army
    ' Cost: 0.001 money units per 1,000 men (cheaper than auto)
    
    DIM side AS INTEGER
    DIM cost AS SINGLE
    
    IF armies(armyIndex).size = 0 THEN EXIT SUB
    
    ' Determine side
    IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START THEN
        side = 1
    ELSE
        side = 2
    END IF
    
    cost = (armies(armyIndex).size / 1000) * SUPPLY_MANUAL_COST
    
    IF GetGameStateCash&(side) < cost THEN
        COLOR 11: CALL clrbot: PRINT "Insufficient funds for supply"
        EXIT SUB
    END IF
    
    CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
    armies(armyIndex).supply = armies(armyIndex).supply + 1
    IF armies(armyIndex).supply > 10 THEN armies(armyIndex).supply = 10
    
    COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " supplied manually"
END SUB

SUB ConsumeSupply
    ' Consume supply for all armies
    ' Units use 1 supply per turn (except harvest months)
    ' Out of supply (0) = 50% combat effectiveness
    
    DIM i AS INTEGER
    
    ' Harvest months provide free supply, so no consumption
    IF IsHarvestMonth% THEN EXIT SUB
    
    FOR i = 1 TO MAX_ARMIES
        IF armies(i).size > 0 THEN
            armies(i).supply = armies(i).supply - 1
            IF armies(i).supply < 0 THEN armies(i).supply = 0
        END IF
    NEXT i
END SUB

FUNCTION GetRecruitmentCost% ()
    ' Get cost to recruit new army
    GetRecruitmentCost% = 100
END FUNCTION

FUNCTION GetFortificationCost% ()
    ' Get cost per fortification level
    GetFortificationCost% = 200
END FUNCTION

FUNCTION GetShipCost% ()
    ' Get cost to build ship
    GetShipCost% = 100
END FUNCTION

FUNCTION IsOutOfSupply% (armyIndex AS INTEGER)
    ' Check if army is out of supply
    IsOutOfSupply% = 0
    IF armies(armyIndex).supply = 0 THEN
        IsOutOfSupply% = 1
    END IF
END FUNCTION

