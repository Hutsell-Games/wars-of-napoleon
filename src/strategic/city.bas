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
        
        FOR j = 1 TO 7
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
    
    IF FileExists%(filename) = 0 THEN
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
    
    ' Try to open file as text
    OPEN "I", 1, filename
    
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
            
            ' Set nationality (owner value represents nationality)
            cities(cityNum).nationality = owner
            
            ' Store connections in cityMatrix
            FOR j = 1 TO 6
                IF connections(j) > 0 AND connections(j) <= MAX_CITIES THEN
                    cityMatrix(cityNum, j) = connections(j)
                ELSE
                    cityMatrix(cityNum, j) = 0
                END IF
            NEXT j
            
            ' Port indicator (>90 = port city)
            ' Store in cityMatrix(7) as port flag
            IF portIndicator > 90 THEN
                cityMatrix(cityNum, 7) = 1 ' Port city
            ELSE
                cityMatrix(cityNum, 7) = 0 ' Not a port
            END IF
            
            ' Update game state counters
            IF cities(cityNum).owner = CITY_FRENCH THEN
                CALL SetGameStateControl(1, GetGameStateControl%(1) + 1)
                CALL SetGameStateIncome(1, GetGameStateIncome&(1) + income)
            ELSEIF cities(cityNum).owner = CITY_ALLIED THEN
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

SUB CaptureCity (cityIndex AS INTEGER, newOwner AS INTEGER)
    ' Capture city for new owner
    ' Updates ownership, income, victory points
    
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
                CALL SetGameStateVictory(newOwner, GetGameStateVictory&(newOwner) + 100)
            END IF
        END IF
    
    ' Reduce fortification by 1 level when captured
    IF cities(cityIndex).fort > FORT_NONE THEN
        cities(cityIndex).fort = cities(cityIndex).fort - 1
    END IF
END SUB

SUB FortifyCity (cityIndex AS INTEGER)
    ' Increase fortification level
    ' Cost: 200 money units per level
    ' Maximum: FORT_PLUS_PLUS (level 2)
    
    IF cities(cityIndex).fort >= FORT_PLUS_PLUS THEN
        CALL ShowStatusMessage(cities(cityIndex).name + " already at maximum fortification", 11)
        EXIT SUB ' Not an error - valid state check
    END IF
    
    DIM cost AS INTEGER
    cost = 200
    
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
    DIM i AS INTEGER
    DIM total AS LONG
    
    total = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).owner = side THEN
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
    DIM i AS INTEGER
    DIM total AS LONG
    
    total = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).owner = side THEN
            total = total + cities(i).value
            IF cities(i).objective = 1 THEN
                total = total + 100 ' Objective city bonus
            END IF
        END IF
    NEXT i
    
    GetCityVictoryPoints& = total
END FUNCTION

FUNCTION GetCityNationality% (cityIndex AS INTEGER)
    ' Get nationality of city
    ' Returns nationality code from city data
    GetCityNationality% = cities(cityIndex).nationality
END FUNCTION
