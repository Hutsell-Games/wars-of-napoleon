'============================================================================
' City/Territory Control System
'============================================================================
' Handles city types, fortification, income, victory points
' Ported from CWS/WW2

' Note: game_types.bas is included in main.bas
' Note: MAX_CITIES is in declarations.bas
' Note: cities array declared in declarations.bas
' Note: cityMatrix array declared in declarations.bas
' Note: City type and fortification constants are in declarations.bas

'============================================================================
' InitializeCities - Initialize all cities to empty state
'============================================================================
' Description:
'   Resets all city data structures to default empty values.
'   Called at game start before loading scenario data.
' Side Effects:
'   Clears all cities array and cityMatrix
'============================================================================
SUB InitializeCities
    DIM i AS INTEGER
    DIM j AS INTEGER
    
    FOR i = 1 TO MAX_CITIES
        cities(i).name = ""
        cities(i).x = 0
        cities(i).y = 0
        cities(i).value = 0
        cities(i).owner = CITY_NEUTRAL
        cities(i).fort = FORT_NONE
        cities(i).nationality = 0
        cities(i).objective = 0
        cities(i).originalOwner = CITY_NEUTRAL
        
        FOR j = 1 TO CITY_MATRIX_COLUMNS
            cityMatrix(i, j) = 0
        NEXT j
    NEXT i
END SUB

'============================================================================
' LoadCityData - Load city data from scenario map file
'============================================================================
' Parameters:
'   scenarioYear (INTEGER) - Year of scenario (determines which map file to load)
' Description:
'   Loads city data from EUROxxxx.MAP file based on scenario year.
'   Format per WON.TXT: City #, x, y, name, owner, income value, etc.
' Side Effects:
'   Updates cities array and cityMatrix with loaded data
'   May exit early if file not found (with error message)
'============================================================================
SUB LoadCityData (scenarioYear AS INTEGER)
    ' connection city 1, connection city 2, connection city 3, connection city 4,
    ' connection city 5, connection city 6, port indicator, fortification level
    ' Cities MUST be in alphabetical order
    ' There must be exactly 67 cities (but we support up to MAX_CITIES = 60)
    
    DIM filename AS STRING
    filename = "data/scenarios/EURO" + LTRIM$(STR$(scenarioYear)) + ".MAP"
    
    IF NOT _FILEEXISTS(filename) THEN
        CALL HandleFileNotFound(filename)
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM cityNum AS INTEGER
    DIM xCoord AS INTEGER
    DIM yCoord AS INTEGER
    DIM cityName AS STRING
    DIM owner AS INTEGER
    DIM income AS INTEGER
    DIM connections(1 TO 6) AS INTEGER
    DIM portIndicator AS INTEGER
    DIM fortLevel AS INTEGER
    DIM lineCount AS INTEGER
    
    ' Initialize cities first
    CALL InitializeCities
    
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%(filename, "I", 1) = 0 THEN
        ' File open failed - error already displayed by SafeOpenFile%
        EXIT SUB
    END IF
    
    lineCount = 0
    i = 1
    
    ' Read cities (up to MAX_CITIES)
    DO WHILE NOT EOF(1) AND i <= MAX_CITIES
        ' Read city data line
        ' Format: cityNum, xCoord, yCoord, cityName, owner, income,
        '         conn1, conn2, conn3, conn4, conn5, conn6, portIndicator, fortLevel
        INPUT #1, cityNum, xCoord, yCoord, cityName, owner, income, _
                  connections(1), connections(2), connections(3), connections(4), _
                  connections(5), connections(6), portIndicator, fortLevel
        
        ' Validate city number
        IF cityNum >= 1 AND cityNum <= MAX_CITIES THEN
            cities(cityNum).name = cityName
            cities(cityNum).x = xCoord
            cities(cityNum).y = yCoord
            cities(cityNum).value = income
            cities(cityNum).fort = fortLevel
            
            ' Set owner (0=neutral, 1=French, 2=Austrian, 3=English, etc.)
            ' Convert to our system: 1=French, 2=Allied (Austrian/English/etc.)
            IF owner = 1 THEN
                cities(cityNum).owner = CITY_FRENCH
            ELSEIF owner >= 2 THEN
                cities(cityNum).owner = CITY_ALLIED
            ELSE
                cities(cityNum).owner = CITY_NEUTRAL
            END IF
            
            ' Store original owner for realism mode tracking
            cities(cityNum).originalOwner = cities(cityNum).owner
            
            ' Set nationality (owner value represents nationality)
            cities(cityNum).nationality = owner
            
            ' Store connections in cityMatrix
            FOR j = 1 TO MAX_CITY_CONNECTIONS
                IF connections(j) > 0 AND connections(j) <= MAX_CITIES THEN
                    cityMatrix(cityNum, j) = connections(j)
                ELSE
                    cityMatrix(cityNum, j) = 0
                END IF
            NEXT j
            
            ' Port indicator (>PORT_INDICATOR_THRESHOLD = port city)
            ' Store in cityMatrix(CITY_MATRIX_COLUMNS) as port flag
            IF portIndicator > PORT_INDICATOR_THRESHOLD THEN
                cityMatrix(cityNum, CITY_MATRIX_COLUMNS) = 1 ' Port city
            ELSE
                cityMatrix(cityNum, CITY_MATRIX_COLUMNS) = 0 ' Not a port
            END IF
            
            ' Update game state counters
            IF IsCityOwnedBy%(cityNum, 1) = 1 THEN
                CALL SetGameStateControl(1, GetGameStateControl%(1) + 1)
                CALL SetGameStateIncome(1, GetGameStateIncome&(1) + income)
            ELSEIF IsCityOwnedBy%(cityNum, 2) = 1 THEN
                CALL SetGameStateControl(2, GetGameStateControl%(2) + 1)
                CALL SetGameStateIncome(2, GetGameStateIncome&(2) + income)
            END IF
            
            lineCount = lineCount + 1
        END IF
        
        i = i + 1
    LOOP
    
    CLOSE #1
    
    CALL ShowStatusMessage("Loaded " + LTRIM$(STR$(lineCount)) + " cities from " + filename, 11)
END SUB

'============================================================================
' CaptureCity - Capture city for new owner
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city being captured
'   newOwner (INTEGER) - New owner side (1=French, 2=Allies)
' Description:
'   Transfers city ownership from old owner to new owner. Updates income
'   and victory point tracking for both sides. Reduces fortification level
'   by 1 when captured. Awards objective city bonus if applicable.
' Side Effects:
'   - Updates city ownership
'   - Adjusts income for both sides
'   - Awards victory points to new owner
'   - Reduces fortification by 1 level
'============================================================================
SUB CaptureCity (cityIndex AS INTEGER, newOwner AS INTEGER)
    ' Capture city for new owner
    ' Updates ownership, income, victory points
    
    ' Validate inputs
    IF ValidateCityIndex%(cityIndex, "CaptureCity") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateArmySide%(newOwner, "CaptureCity") = 0 THEN
        EXIT SUB
    END IF
    
    DIM oldOwner AS INTEGER
    oldOwner = cities(cityIndex).owner
    
        IF oldOwner > 0 AND oldOwner <= 2 THEN
            ' Remove from old owner's control
            CALL SetGameStateControl(oldOwner, GetGameStateControl%(oldOwner) - 1)
            CALL SetGameStateIncome(oldOwner, GetGameStateIncome&(oldOwner) - cities(cityIndex).value)
        END IF
        
        ' Assign to new owner
        cities(cityIndex).owner = newOwner
        IF newOwner > 0 AND newOwner <= 2 THEN
            CALL SetGameStateControl(newOwner, GetGameStateControl%(newOwner) + 1)
            CALL SetGameStateIncome(newOwner, GetGameStateIncome&(newOwner) + cities(cityIndex).value)
            
            ' Add victory points
            CALL SetGameStateVictory(newOwner, GetGameStateVictory&(newOwner) + cities(cityIndex).value)
            
            ' Objective city bonus
            IF cities(cityIndex).objective = 1 THEN
                CALL SetGameStateVictory(newOwner, GetGameStateVictory&(newOwner) + OBJECTIVE_BONUS)
            END IF
        END IF
    
    ' Reduce fortification by 1 level when captured
    IF cities(cityIndex).fort > FORT_NONE THEN
        cities(cityIndex).fort = cities(cityIndex).fort - 1
    END IF
    
    ' City ownership changed - invalidate isolation cache
    CALL InvalidateCityIsolationCache(0) ' Invalidate all cities (ownership change affects connections)
END SUB

'============================================================================
' FortifyCity - Increase city fortification level
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to fortify
' Description:
'   Increases the fortification level of a city. Cost is 200 money units
'   per level. Maximum fortification is FORT_PLUS_PLUS (level 2).
'   Fortifications provide defensive bonuses in combat.
' Side Effects:
'   - Increases cities(cityIndex).fort by 1
'   - Deducts cost from cash reserves
'   - Displays error if at maximum or insufficient funds
'============================================================================
SUB FortifyCity (cityIndex AS INTEGER)
    ' Increase fortification level
    ' Cost: 200 money units per level
    ' Maximum: FORT_PLUS_PLUS (level 2)
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "FortifyCity") = 0 THEN
        EXIT SUB
    END IF
    
    IF cities(cityIndex).fort >= FORT_PLUS_PLUS THEN
        CALL ShowStatusMessage(cities(cityIndex).name + " already at maximum fortification", 11)
        EXIT SUB ' Not an error - valid state check
    END IF
    
    DIM cost AS INTEGER
    cost = FORTIFICATION_COST
    
    IF GetGameStateCash&(gameState.side) < cost THEN
        CALL ShowStatusMessage("Fortification costs " + LTRIM$(STR$(cost)) + " money units", 11)
        EXIT SUB ' Not an error - insufficient funds is expected
    END IF
    
    cities(cityIndex).fort = cities(cityIndex).fort + 1
        CALL SetGameStateCash(gameState.side, GetGameStateCash&(gameState.side) - cost)
    
    CALL ShowStatusMessage(cities(cityIndex).name + " fortification increased to level " + LTRIM$(STR$(cities(cityIndex).fort)), 11)
END SUB

'============================================================================
' RazeFortifications - Destroy city fortifications
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city whose fortifications to destroy
' Description:
'   Destroys all fortifications at a city. Typically called when capturing
'   an unoccupied fortified city.
' Side Effects:
'   - Sets cities(cityIndex).fort to FORT_NONE
'   - Displays destruction message
'============================================================================
SUB RazeFortifications (cityIndex AS INTEGER)
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "RazeFortifications") = 0 THEN
        EXIT SUB
    END IF
    
    cities(cityIndex).fort = FORT_NONE
    CALL ShowStatusMessage("Fortifications at " + cities(cityIndex).name + " destroyed", 11)
END SUB

'============================================================================
' GetCityIncome - Calculate total income from cities for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to calculate income for (1=French, 2=Allies)
' Returns:
'   LONG - Total income from all cities owned by the side
'============================================================================
FUNCTION GetCityIncome& (side AS INTEGER)
    ' Calculate total income for side from controlled cities
    
    ' Validate input
    IF ValidateArmySide%(side, "GetCityIncome") = 0 THEN
        GetCityIncome& = 0
        EXIT FUNCTION
    END IF
    
    DIM i AS INTEGER
    DIM total AS LONG
    
    total = 0
    FOR i = 1 TO MAX_CITIES
        IF IsCityActive%(i) = 1 AND IsCityOwnedBy%(i, side) = 1 THEN
            total = total + cities(i).value
        END IF
    NEXT i
    
    GetCityIncome& = total
END FUNCTION

'============================================================================
' GetCityVictoryPoints - Calculate total victory points from cities for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to calculate victory points for (1=French, 2=Allies)
' Returns:
'   LONG - Total victory points from all cities owned by the side
'============================================================================
FUNCTION GetCityVictoryPoints& (side AS INTEGER)
    ' Calculate total victory points for side
    
    ' Validate input
    IF ValidateArmySide%(side, "GetCityVictoryPoints") = 0 THEN
        GetCityVictoryPoints& = 0
        EXIT FUNCTION
    END IF
    
    DIM i AS INTEGER
    DIM total AS LONG
    
    total = 0
    FOR i = 1 TO MAX_CITIES
        IF IsCityActive%(i) = 1 AND IsCityOwnedBy%(i, side) = 1 THEN
            total = total + cities(i).value
            IF cities(i).objective = 1 THEN
                total = total + OBJECTIVE_BONUS ' Objective city bonus
            END IF
        END IF
    NEXT i
    
    GetCityVictoryPoints& = total
END FUNCTION

'============================================================================
' GetCityNationality - Get nationality of city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city
' Returns:
'   INTEGER - Nationality code of the city (from scenario data)
' Description:
'   Returns the nationality code assigned to the city in scenario data.
'   Used for cohesion calculations and recruitment restrictions.
'============================================================================
FUNCTION GetCityNationality% (cityIndex AS INTEGER)
    ' Get nationality of city
    ' Returns nationality code from city data
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "GetCityNationality") = 0 THEN
        GetCityNationality% = 0
        EXIT FUNCTION
    END IF
    
    GetCityNationality% = cities(cityIndex).nationality
END FUNCTION
