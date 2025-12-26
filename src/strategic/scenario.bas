'============================================================================
' Scenario System
'============================================================================
' Handles 7 scenarios: 1796, 1805, 1807, 1808, 1812, 1813, 1815
' Loads scenario data files: NWSxxxx.INI, LEADxxxx.DAT, EUROxxxx.MAP

' Note: game_types.bas is included in main.bas
' Note: campaign.bas, army.bas, city.bas, cohesion.bas, victory.bas are included in main.bas

' Note: scenarioYears is declared and initialized in declarations.bas

FUNCTION SelectScenario% ()
    ' Display scenario selection menu
    ' Returns selected scenario year (0 = cancelled)
    ' Uses menu system for consistent UI
    
    DIM i AS INTEGER
    DIM selected AS INTEGER
    DIM scenarioNames$(1 TO 7)
    
    ' Format scenario names for menu display
    FOR i = 1 TO 7
        scenarioNames$(i) = LTRIM$(STR$(scenarioYears(i))) + " Campaign"
    NEXT i
    
    ' Show menu using menu system
    ' Note: Pass array by reference - QB64 syntax
    DIM tempNames$(1 TO 7)
    FOR i = 1 TO 7
        tempNames$(i) = scenarioNames$(i)
    NEXT i
    selected = ShowListMenu%("Select Scenario", tempNames$(), 7)
    
    ' Map menu selection to scenario year
    IF selected >= 1 AND selected <= 7 THEN
        SelectScenario% = scenarioYears(selected)
    ELSE
        SelectScenario% = 0 ' Cancelled
    END IF
END FUNCTION

'============================================================================
' LoadScenario - Load scenario data from file
'============================================================================
' Parameters:
'   scenarioYear (INTEGER) - Year of scenario (determines which files to load)
' Description:
'   Loads scenario data from NWS<year>.INI file. Sets up starting conditions:
'   starting month/year, war conditions, objective cities, army data, etc.
' Side Effects:
'   - Updates gameState with starting month/year
'   - Loads war conditions and objectives
'   - Initializes armies from scenario data
'   - May exit early if file not found
'============================================================================
SUB LoadScenario (scenarioYear AS INTEGER)
    ' Load scenario data files
    ' Files: NWSxxxx.INI, LEADxxxx.DAT, EUROxxxx.MAP
    ' Order: Commanders first (needed for army assignment), then cities, then scenario data
    
    DIM yearStr AS STRING
    yearStr = LTRIM$(STR$(scenarioYear))
    
    CALL ShowStatusMessage("Loading scenario " + LTRIM$(STR$(scenarioYear)), 11)
    
    ' Initialize game structures
    CALL InitializeArmies
    CALL InitializeCities
    CALL InitializeCohesion
    CALL InitializeVictoryConditions
    
    ' Load commander data first (needed for army assignment)
    LoadCommanderData scenarioYear
    
    ' Load city/map data (needed for city references in scenario)
    LoadCityData scenarioYear
    
    ' Load scenario initialization file (uses commanders and cities)
    LoadScenarioINI scenarioYear
    
    CALL ShowStatusMessage("Scenario loaded", 11)
END SUB

SUB LoadScenarioINI (scenarioYear AS INTEGER)
    ' Load NWSxxxx.INI file
    ' Format per WON.TXT:
    ' Line 1: month, year (e.g., 3,1796)
    ' Line 2: end game conditions (month, year, % cities, % income, objective flag, army ratio)
    ' Line 3: battles won by French, battles won by Allies, French casualties, Allied casualties
    ' Line 4: war conditions (France, Austria, England, Russia, Prussia, Spain)
    ' Line 5: number of French armies
    ' Lines 6+: French armies (side, city, strength in 100's, experience, supply)
    ' Next line: number of Allied armies
    ' Lines after: Allied armies (nationality, city, strength in 100's, experience, supply)
    ' Next line: starting cash (French, Allied)
    ' Next line: French navy (ships, location)
    ' Next line: Allied navy (ships, location)
    ' Last line: objective cities (French objective, Allied objective)
    
    DIM filename AS STRING
    DIM yearStr AS STRING
    yearStr = LTRIM$(STR$(scenarioYear))
    filename = "data/scenarios/NWS" + yearStr + ".INI"
    
    IF FileExists%(filename) = 0 THEN
        CALL HandleFileNotFound(filename)
        EXIT SUB
    END IF
    
    DIM startMonth AS INTEGER
    DIM startYear AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM numArmies AS INTEGER
    DIM side AS INTEGER
    DIM nationality AS INTEGER
    DIM cityIndex AS INTEGER
    DIM armySize AS LONG
    DIM experience AS INTEGER
    DIM supply AS INTEGER
    DIM endMonth AS INTEGER
    DIM endYear AS INTEGER
    DIM endCities AS INTEGER
    DIM endIncome AS INTEGER
    DIM endObjective AS INTEGER
    DIM endRatio AS INTEGER
    DIM battlesWon(1 TO 2) AS INTEGER
    DIM totalCasualties(1 TO 2) AS LONG
    DIM warConditions(1 TO 6) AS INTEGER
    DIM objectiveCities(1 TO 2) AS INTEGER
    DIM armyIndex AS INTEGER
    
    OPEN "I", 1, filename
    
    ' Read starting month and year
    INPUT #1, startMonth, startYear
    gameState.month = startMonth
    gameState.year = startYear
    
    ' Read end game conditions (month, year, % cities, % income, objective flag, army ratio)
    INPUT #1, endMonth, endYear, endCities, endIncome, endObjective, endRatio
    endGameFlags(END_TIME) = endYear ' Store year for time check
    endGameFlags(END_CITIES) = endCities
    endGameFlags(END_INCOME) = endIncome
    endGameFlags(END_OBJECTIVE) = endObjective
    endGameFlags(END_ARMY_RATIO) = endRatio
    
    ' Read battle statistics
    INPUT #1, battlesWon(1), battlesWon(2), totalCasualties(1), totalCasualties(2)
    battleWon(1) = battlesWon(1)
    battleWon(2) = battlesWon(2)
    casualties(1) = totalCasualties(1)
    casualties(2) = totalCasualties(2)
    
    ' Read war conditions (France, Austria, England, Russia, Prussia, Spain)
    INPUT #1, warConditions(1), warConditions(2), warConditions(3), warConditions(4), warConditions(5), warConditions(6)
    ' Set allied at war status (>50 = at war)
    FOR i = 1 TO 6
        IF warConditions(i) > 50 THEN
            alliedAtWar(i) = 1
        ELSE
            alliedAtWar(i) = 0
        END IF
    NEXT i
    
    ' Initialize commander assignment index
    ' French armies get commanders 1-25, Allied armies get commanders 26-50
    commanderIndex = 1
    
    ' Read French starting armies
    INPUT #1, numArmies
    FOR i = 1 TO numArmies
        INPUT #1, side, cityIndex, armySize, experience, supply
        ' Find available French army slot
        armyIndex = FRENCH_START + i - 1
        IF armyIndex <= FRENCH_START + 19 THEN
            ' Assign commander (in order from commander array, indices 1-25)
            IF commanderIndex <= 25 THEN
                armies(armyIndex).name = commanders(commanderIndex).name
                armies(armyIndex).lead = commanders(commanderIndex).rating
                armies(armyIndex).nationality = NAT_FRENCH
                commanderIndex = commanderIndex + 1
            END IF
            
            ' Set army attributes
            armies(armyIndex).size = armySize * 100 ' Convert from 100's to actual men
            armies(armyIndex).exper = experience
            armies(armyIndex).supply = supply
            armies(armyIndex).loc = cityIndex
            armies(armyIndex).move = 0
            
            ' Mark city as occupied (validate cityIndex first)
            IF cityIndex >= 1 AND cityIndex <= MAX_CITIES THEN
                occupied(cityIndex) = armyIndex
            END IF
        END IF
    NEXT i
    
    ' Read Allied starting armies
    ' Reset commander index to 26 for Allied commanders
    commanderIndex = 26
    INPUT #1, numArmies
    FOR i = 1 TO numArmies
        INPUT #1, nationality, cityIndex, armySize, experience, supply
        ' Find available Allied army slot
        armyIndex = ALLIED_START + i - 1
        IF armyIndex <= ALLIED_START + 19 THEN
            ' Assign commander (in order from commander array, starting at index 26)
            IF commanderIndex <= 50 THEN
                armies(armyIndex).name = commanders(commanderIndex).name
                armies(armyIndex).lead = commanders(commanderIndex).rating
                armies(armyIndex).nationality = nationality
                commanderIndex = commanderIndex + 1
            END IF
            
            ' Set army attributes
            armies(armyIndex).size = armySize * 100 ' Convert from 100's to actual men
            armies(armyIndex).exper = experience
            armies(armyIndex).supply = supply
            armies(armyIndex).loc = cityIndex
            armies(armyIndex).move = 0
            
            ' Mark city as occupied (validate cityIndex first)
            IF cityIndex >= 1 AND cityIndex <= MAX_CITIES THEN
                occupied(cityIndex) = armyIndex
            END IF
        END IF
    NEXT i
    
    ' Read starting cash
    DIM cash1 AS LONG
    DIM cash2 AS LONG
    INPUT #1, cash1, cash2
    CALL SetGameStateCash(1, cash1)
    CALL SetGameStateCash(2, cash2)
    
    ' Read French navy
    INPUT #1, fleets(1).size, fleets(1).loc
    fleets(1).move = 0
    
    ' Read Allied navy
    INPUT #1, fleets(2).size, fleets(2).loc
    fleets(2).move = 0
    
    ' Read objective cities
    INPUT #1, objectiveCities(1), objectiveCities(2)
    ' Mark objective cities (will be set when cities are loaded)
    ' Store in temporary variable for later use
    
    CLOSE #1
    
    ' Set objective cities after cities are loaded
    IF objectiveCities(1) > 0 AND objectiveCities(1) <= MAX_CITIES THEN
        cities(objectiveCities(1)).objective = 1
    END IF
    IF objectiveCities(2) > 0 AND objectiveCities(2) <= MAX_CITIES THEN
        cities(objectiveCities(2)).objective = 1
    END IF
END SUB

SUB LoadCommanderData (scenarioYear AS INTEGER)
    ' Load LEADxxxx.DAT file
    ' Format per WON.TXT:
    ' Lines 1-25: French commanders (nameVal, rating)
    ' Lines 26-50: Allied commanders (nationality, nameVal, rating)
    ' Must have exactly 50 commanders total
    
    DIM filename AS STRING
    DIM yearStr AS STRING
    yearStr = LTRIM$(STR$(scenarioYear))
    filename = "data/scenarios/LEAD" + yearStr + ".DAT"
    
    IF FileExists%(filename) = 0 THEN
        CALL HandleFileNotFound(filename)
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM nameVal AS STRING
    DIM rating AS INTEGER
    DIM nationality AS INTEGER
    
    ' Initialize commander array
    FOR i = 1 TO 50
        commanders(i).name = ""
        commanders(i).rating = 0
        commanders(i).nationality = 0
        commanders(i).available = 1
    NEXT i
    
    OPEN "I", 1, filename
    
    ' Load French commanders (first 25)
    FOR i = 1 TO 25
        INPUT #1, nameVal, rating
        commanders(i).name = nameVal
        commanders(i).rating = rating
        commanders(i).nationality = NAT_FRENCH
        commanders(i).available = 1
    NEXT i
    
    ' Load Allied commanders (next 25, prefixed with nationality)
    FOR i = 26 TO 50
        INPUT #1, nationality, nameVal, rating
        commanders(i).name = nameVal
        commanders(i).rating = rating
        commanders(i).nationality = nationality
        commanders(i).available = 1
    NEXT i
    
    CLOSE #1
END SUB

SUB InitializeScenario (scenarioYear AS INTEGER)
    ' Initialize game for selected scenario
    InitializeCampaign scenarioYear
    LoadScenario scenarioYear
END SUB

SUB GetCommanderByIndex (index AS INTEGER, result AS CommanderType)
    ' Get commander by index (1-50)
    ' Returns commander data structure via result parameter
    IF index >= 1 AND index <= 50 THEN
        result = commanders(index)
    ELSE
        ' Return empty commander
        result.name = ""
        result.rating = 0
        result.nationality = 0
        result.available = 0
    END IF
END SUB

FUNCTION GetCommanderByName% (commanderName AS STRING)
    ' Find commander by nameVal
    ' Returns index (1-50) or 0 if not found
    DIM i AS INTEGER
    
    GetCommanderByName% = 0
    FOR i = 1 TO 50
        IF UCASE$(commanders(i).name) = UCASE$(commanderName) THEN
            GetCommanderByName% = i
            EXIT FUNCTION
        END IF
    NEXT i
END FUNCTION

FUNCTION GetCommanderNationalityByName% (commanderName AS STRING)
    ' Get nationality of commander by nameVal
    ' Returns nationality code or 0 if not found
    DIM index AS INTEGER
    
    index = GetCommanderByName%(commanderName)
    IF index > 0 THEN
        GetCommanderNationalityByName% = commanders(index).nationality
    ELSE
        GetCommanderNationalityByName% = 0
    END IF
END FUNCTION

