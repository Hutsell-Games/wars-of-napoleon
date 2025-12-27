'============================================================================
' Move Capital Feature
'============================================================================
' Ported from CWS
' Allows moving capital/objective to different city

' Note: game_types.bas is included in main.bas
' Note: campaign.bas, city.bas, victory.bas are included in main.bas
' Note: capitalCity is declared in declarations.bas

'============================================================================
' InitializeCapitals - Initialize capital cities for both sides
'============================================================================
' Description:
'   Initializes capital city tracking for both sides. Capital cities are
'   typically set from scenario data and represent important objective cities.
'   Moving the capital allows players to prevent objective capture from
'   ending the game prematurely.
' Side Effects:
'   - Sets capitalCity(1) and capitalCity(2) to 0 (no capital initially)
'============================================================================
SUB InitializeCapitals
    ' Initialize capital cities
    ' Will be set from scenario data
    capitalCity(1) = 0 ' French capital
    capitalCity(2) = 0 ' Allied capital
END SUB

'============================================================================
' MoveCapital - Move capital city to a different city
'============================================================================
' Parameters:
'   side (INTEGER) - Side moving capital (1=French, 2=Allies)
'   newCityIndex (INTEGER) - Index of city to become new capital
' Description:
'   Moves the capital city to a different location. This costs 500 money
'   units and awards the enemy 50 victory points. The new city becomes
'   an objective city, and the old capital loses objective status. This
'   prevents objective capture from ending the game prematurely.
' Side Effects:
'   - Updates capitalCity(side) to new city index
'   - Sets new city as objective (cities(newCityIndex).objective = 1)
'   - Removes objective from old capital
'   - Deducts 500 money units from side's cash
'   - Awards 50 victory points to enemy side
'============================================================================
SUB MoveCapital (side AS INTEGER, newCityIndex AS INTEGER)
    ' Move capital to different city
    ' Cost: 500 money units
    ' Awards enemy 50 victory points
    ' Prevents objective capture ending game
    
    ' Validate inputs
    IF ValidateArmySide%(side, "MoveCapital") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateCityIndex%(newCityIndex, "MoveCapital") = 0 THEN
        EXIT SUB
    END IF
    
    DIM cost AS INTEGER
    cost = 500
    
    IF GetGameStateCash&(side) < cost THEN
        CALL HandleValidationError("Move capital costs " + LTRIM$(STR$(cost)) + " money units")
        EXIT SUB
    END IF
    
    ' Check if city is owned by side
    IF IsCityOwnedBy%(newCityIndex, side) = 0 THEN
        CALL HandleValidationError("Capital must be moved to owned city")
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

'============================================================================
' IsCapitalCity - Check if a city is a capital
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to check
' Returns:
'   INTEGER - 1 if city is a capital for either side, 0 otherwise
' Description:
'   Checks if the specified city is currently designated as a capital for
'   either the French or Allied side. Capital cities are important objective
'   cities that can trigger end game conditions if captured.
'============================================================================
FUNCTION IsCapitalCity% (cityIndex AS INTEGER)
    ' Check if city is capital
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "IsCapitalCity") = 0 THEN
        IsCapitalCity% = 0
        EXIT FUNCTION
    END IF
    
    IsCapitalCity% = 0
    IF cityIndex = capitalCity(1) OR cityIndex = capitalCity(2) THEN
        IsCapitalCity% = 1
    END IF
END FUNCTION

