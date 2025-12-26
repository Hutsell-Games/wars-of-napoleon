'============================================================================
' Move Capital Feature
'============================================================================
' Ported from CWS
' Allows moving capital/objective to different city

' Note: game_types.bas is included in main.bas
' Note: campaign.bas, city.bas, victory.bas are included in main.bas
' Note: capitalCity is declared in declarations.bas

SUB InitializeCapitals
    ' Initialize capital cities
    ' Will be set from scenario data
    capitalCity(1) = 0 ' French capital
    capitalCity(2) = 0 ' Allied capital
END SUB

SUB MoveCapital (side AS INTEGER, newCityIndex AS INTEGER)
    ' Move capital to different city
    ' Cost: 500 money units
    ' Awards enemy 50 victory points
    ' Prevents objective capture ending game
    
    DIM cost AS INTEGER
    cost = 500
    
    IF GetGameStateCash&(side) < cost THEN
        CALL ShowStatusError("Move capital costs " + LTRIM$(STR$(cost)) + " money units")
        EXIT SUB
    END IF
    
    ' Check if city is owned by side
    IF cities(newCityIndex).owner <> side THEN
        CALL ShowStatusError("Capital must be moved to owned city")
        EXIT SUB
    END IF
    
    ' Pay cost
    CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
    
    ' Award enemy victory points
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    AwardVictoryPoints enemySide, 50
    
    ' Move capital
    capitalCity(side) = newCityIndex
    
    ' Update objective status
    IF cities(newCityIndex).objective = 0 THEN
        cities(newCityIndex).objective = 1 ' Make new capital an objective
    END IF
    
    ' Remove objective from old capital
    IF capitalCity(side) > 0 THEN
        cities(capitalCity(side)).objective = 0
    END IF
    
    CALL ShowStatusMessage("Capital moved to " + cities(newCityIndex).name, 11)
END SUB

FUNCTION IsCapitalCity% (cityIndex AS INTEGER)
    ' Check if city is capital
    IsCapitalCity% = 0
    IF cityIndex = capitalCity(1) OR cityIndex = capitalCity(2) THEN
        IsCapitalCity% = 1
    END IF
END FUNCTION

