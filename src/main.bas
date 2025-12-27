'============================================================================
' Wars of Napoleon - Main Game SUBs and FUNCTIONs
'============================================================================
' This file contains the main game SUBs and FUNCTIONs
' It is included by WON.BAS after all other modules are included
' Do NOT include this file directly - use WON.BAS as the entry point

SUB Main
    ' Entry point: initialize, run menu loop, cleanup
    
    CALL InitializeGame
    
    DO
        DIM menuChoice AS INTEGER
        menuChoice = ShowMainMenu%
        
        SELECT CASE menuChoice
            CASE MENU_NEW_GAME
                CALL StartNewGame
            CASE MENU_LOAD_GAME
                CALL LoadGameMenu
            CASE MENU_CONTINUE_PBM
                CALL ContinuePBMGame
            CASE MENU_UTILITY
                CALL UtilityMenu
            CASE MENU_QUIT
                EXIT DO
        END SELECT
    LOOP
    
    CALL CleanupGame
END SUB

SUB InitializeGame
    ' Initialize all game systems
    ' Initializes all subsystems in the correct order
    ' Graphics must be initialized early as other systems may depend on it
    
    ' Load configuration first (needed by other initialization functions)
    CALL LoadConfig
    
    ' Initialize subsystems
    CALL InitializeMenus
    ' Initialize graphics early (sets SCREEN 12, validates graphics files)
    IF InitializeGraphics% = 0 THEN
        ' Graphics initialization failed - display error but continue
        ' Game can still run with limited graphics
        COLOR 12 ' Red for error
        LOCATE 1, 1
        PRINT "Graphics initialization completed with warnings."
        PRINT "Game will continue but some features may not work correctly."
        PRINT "Press any key to continue..."
        DO WHILE INKEY$ = "": LOOP
        CLS
    END IF
    
    ' Initialize game data structures
    CALL InitializeArmies
    CALL InitializeCities
    CALL InitializeNaval
    CALL InitializeCohesion
    CALL InitializeReports
    CALL InitializeVictoryConditions
    CALL InitializeCapitals
    CALL InitializeRealism
    CALL InitializePBM
    CALL InitializeMouse
    CALL InitializePerformanceCache
    
    ' Clear screen after all initialization
    CLS
END SUB

FUNCTION ShowMainMenu% ()
    ' Display main menu and get user choice
    ' Returns menu option selected
    
    DIM choice AS INTEGER
    
    CLS
    COLOR 15: PRINT "WARS OF NAPOLEON"
    PRINT STRING$(80, "-")
    PRINT "1. New Game"
    PRINT "2. Load Game"
    PRINT "3. Continue PBM Game"
    PRINT "4. Utility"
    PRINT "5. Quit"
    PRINT
    INPUT "Select option (1-5): ", choice
    
    IF choice >= 1 AND choice <= 5 THEN
        ShowMainMenu% = choice
    ELSE
        ShowMainMenu% = 0
    END IF
END FUNCTION

SUB StartNewGame
    ' Start new game
    ' Select scenario and initialize
    
    DIM scenarioYear AS INTEGER
        scenarioYear = SelectScenario%
    
    IF scenarioYear = 0 THEN
        EXIT SUB ' Cancelled
    END IF
    
    ' Initialize scenario
    CALL InitializeScenario(scenarioYear)
    
    ' Start game loop
    CALL GameLoop
END SUB

SUB LoadGameMenu
    ' Show load game menu
    
    DIM slot AS INTEGER
    DIM count AS INTEGER
    DIM filename AS STRING
    
    filename = GetSaveFileList$(count)
    
    IF count = 0 THEN
        CALL HandleValidationError("No save files found")
        EXIT SUB
    END IF
    
    ' Show save file list (simplified)
    CLS
    PRINT "Load Game"
    PRINT STRING$(80, "-")
    PRINT "Enter slot number (1-9, 9=autosave): "
    INPUT slot
    
    IF slot >= 1 AND slot <= 9 THEN
        CALL LoadGame(slot)
        CALL GameLoop
    END IF
END SUB

SUB ContinuePBMGame
    ' Continue PBM game
    
    IF pbmEnabled = 0 THEN
        CALL HandleValidationError("PBM mode not enabled")
        EXIT SUB
    END IF
    
    CALL LoadPBMFile
    CALL GameLoop
END SUB

SUB UtilityMenu
    ' Utility menu
    ' Options: Configuration, Realism, Mouse, PBM, etc.
    
    DIM choice AS INTEGER
    DIM menuItems$(1 TO 4) AS STRING
    
    DO
        menuItems$(1) = "Configuration"
        menuItems$(2) = "Realism Toggle"
        menuItems$(3) = "Mouse Support"
        menuItems$(4) = "PBM Support"
        
        choice = ShowMenuWithBack%("Utility Menu", menuItems$, 4, 67, 13, 4, 11)
        
        SELECT CASE choice
            CASE 1
                CALL ConfigurationMenu
            CASE 2
                CALL ToggleRealism
            CASE 3
                CALL ToggleMouse
            CASE 4
                CALL TogglePBM
            CASE 0
                EXIT DO
        END SELECT
    LOOP
END SUB

SUB ConfigurationMenu
    ' Configuration menu
    ' Allows changing game settings
    ' Display settings, sound, game balance, etc.
    
    DIM choice AS INTEGER
    DIM newValue AS INTEGER
    DIM prompt AS STRING
    
    DO
        CLS
        COLOR 15: PRINT "CONFIGURATION MENU"
        PRINT STRING$(80, "-")
        PRINT "Current Settings:"
        PRINT
        PRINT "1. Side: "; 
        IF config_side = 1 THEN PRINT "French" ELSE PRINT "Allies"
        PRINT "2. Sound: ";
        IF config_sound = 0 THEN PRINT "None"
        IF config_sound = 1 THEN PRINT "Sounds Only"
        IF config_sound = 2 THEN PRINT "Sounds + Music"
        PRINT "3. Play Balance: "; config_balance; " (1=Allies++, 3=Balanced, 5=French++)"
        PRINT "4. Computer Aggression: "; config_aggression; " (1=Low, 5=High)"
        PRINT "5. Number of Players: "; config_players
        PRINT "6. Display Speed: "; config_display; " (1=Very Fast, 2=Normal, 4=Very Slow)"
        PRINT "7. Random Events: "; config_randevent; " (0=Off, 3=Favor Allies, 5=Neutral, 7=Favor French)"
        PRINT "8. History: ";
        IF config_history = 0 THEN PRINT "Off" ELSE PRINT "On"
        PRINT "9. Tactical Battles: ";
        IF config_tactical = 0 THEN PRINT "Off" ELSE PRINT "On"
        PRINT
        PRINT "0. Save and Exit"
        PRINT
        INPUT "Select option to change (0-9): ", choice
        
        SELECT CASE choice
            CASE 1 ' Side
                PRINT "Select side (1=French, 2=Allies): "
                INPUT newValue
                IF newValue >= 1 AND newValue <= 2 THEN
                    config_side = newValue
                    CALL ShowInfo("Side changed")
                ELSE
                    CALL ShowError("Invalid value (1-2)")
                END IF
            CASE 2 ' Sound
                PRINT "Sound setting (0=None, 1=Sounds Only, 2=Sounds+Music): "
                INPUT newValue
                IF newValue >= 0 AND newValue <= 2 THEN
                    config_sound = newValue
                    CALL ShowInfo("Sound setting changed")
                ELSE
                    CALL ShowError("Invalid value (0-2)")
                END IF
            CASE 3 ' Play Balance
                PRINT "Play Balance (1=Allies++, 3=Balanced, 5=French++): "
                INPUT newValue
                IF newValue >= 1 AND newValue <= 5 THEN
                    config_balance = newValue
                    CALL ShowInfo("Play balance changed")
                ELSE
                    CALL ShowError("Invalid value (1-5)")
                END IF
            CASE 4 ' Aggression
                PRINT "Computer Aggression (1=Low, 5=High): "
                INPUT newValue
                IF newValue >= 1 AND newValue <= 5 THEN
                    config_aggression = newValue
                    CALL ShowInfo("Aggression level changed")
                ELSE
                    CALL ShowError("Invalid value (1-5)")
                END IF
            CASE 5 ' Players
                PRINT "Number of Players (1-2): "
                INPUT newValue
                IF newValue >= 1 AND newValue <= 2 THEN
                    config_players = newValue
                    CALL ShowInfo("Number of players changed")
                ELSE
                    CALL ShowError("Invalid value (1-2)")
                END IF
            CASE 6 ' Display Speed
                PRINT "Display Speed (1=Very Fast, 2=Normal, 4=Very Slow): "
                INPUT newValue
                IF newValue = 1 OR newValue = 2 OR newValue = 4 THEN
                    config_display = newValue
                    CALL ShowInfo("Display speed changed")
                ELSE
                    CALL ShowError("Invalid value (1, 2, or 4)")
                END IF
            CASE 7 ' Random Events
                PRINT "Random Events (0=Off, 3=Favor Allies, 5=Neutral, 7=Favor French): "
                INPUT newValue
                IF newValue >= 0 AND newValue <= 7 THEN
                    config_randevent = newValue
                    CALL ShowInfo("Random events setting changed")
                ELSE
                    CALL ShowError("Invalid value (0-7)")
                END IF
            CASE 8 ' History
                PRINT "History (0=Off, 1=On): "
                INPUT newValue
                IF newValue >= 0 AND newValue <= 1 THEN
                    config_history = newValue
                    CALL ShowInfo("History setting changed")
                ELSE
                    CALL ShowError("Invalid value (0-1)")
                END IF
            CASE 9 ' Tactical Battles
                PRINT "Tactical Battles (0=Off, 1=On): "
                INPUT newValue
                IF newValue >= 0 AND newValue <= 1 THEN
                    config_tactical = newValue
                    CALL ShowInfo("Tactical battles setting changed")
                ELSE
                    CALL ShowError("Invalid value (0-1)")
                END IF
            CASE 0 ' Save and Exit
                CALL SaveConfig
                CALL ShowInfo("Configuration saved")
                EXIT DO
        END SELECT
    LOOP
END SUB

SUB ToggleRealism
    ' Toggle realism mode
    
    IF realismMode = 0 THEN
        CALL SetRealismMode(1)
    ELSE
        CALL SetRealismMode(0)
    END IF
END SUB

SUB ToggleMouse
    ' Toggle mouse support
    
    IF mouseEnabled = 0 THEN
        CALL EnableMouse
    ELSE
        CALL DisableMouse
    END IF
END SUB

SUB TogglePBM
    ' Toggle PBM support
    
    IF pbmEnabled = 0 THEN
        CALL EnablePBM
    ELSE
        CALL DisablePBM
    END IF
END SUB

SUB GameLoop
    ' Main game loop
    ' Strategic -> Tactical -> Strategic integration
    
    DO
        ' Decision Phase
        IF currentPhase = PHASE_DECISION THEN
            CALL DecisionPhase
        END IF
        
        ' Move & Combat Phase
        IF currentPhase = PHASE_MOVE_COMBAT THEN
            CALL MoveCombatPhase
        END IF
        
        ' Update Phase
        IF currentPhase = PHASE_UPDATE THEN
            CALL UpdatePhase
        END IF
        
        ' Advance turn
        CALL AdvanceTurn
        
        ' Check end game conditions
        DIM winner AS INTEGER
        winner = CheckEndGameConditions%
        IF winner > 0 THEN
            CALL EndGame(winner)
            EXIT DO
        END IF
        
        ' Create PBM file if enabled
        IF pbmEnabled = 1 THEN
            CALL CreatePBMFile
        END IF
        
    LOOP
END SUB

SUB DecisionPhase
    ' Decision phase - player makes decisions
    ' Recruitment, naval actions, move orders, etc.
    
    DIM choice AS INTEGER
    
    DIM menuItems$(1 TO 6) AS STRING
    
    DO
        ' Show decision menu
        menuItems$(1) = "Recruit"
        menuItems$(2) = "Move Orders"
        menuItems$(3) = "Ships"
        menuItems$(4) = "Commands"
        menuItems$(5) = "Inform (Reports)"
        menuItems$(6) = "END TURN"
        
        choice = ShowSimpleMenu%("Decision Phase - " + GetCurrentMonth$, menuItems$, 6, 67, 13, 4, 11)
        
        SELECT CASE choice
            CASE 1 ' Recruit
                CALL RecruitMenu(gameState.side)
            CASE 2 ' Move Orders
                CALL MoveOrdersMenu(gameState.side)
            CASE 3 ' Ships
                CALL NavalMenu(gameState.side)
            CASE 4 ' Commands
                CALL ShowCommandsMenu(gameState.side)
            CASE 5 ' Inform
                CALL ReportsMenu(gameState.side)
            CASE 6 ' END TURN
                ' Confirm before ending turn
                IF ShowYesNoMenu("End Turn?") = 1 THEN
                    EXIT DO
                END IF
        END SELECT
    LOOP
END SUB

SUB RecruitMenu (side AS INTEGER)
    ' Recruitment menu
    ' Shows cities where recruitment is possible
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM citiesToRecruit(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES)
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of owned active cities
    tempCount = BuildCityList%(tempCities(), tempNames$, side, 0, 1, 1, "")
    
    ' Filter for cities where recruitment is possible
    count = 0
    FOR i = 1 TO tempCount
        IF CanRecruitInCity(tempCities(i), side) = 1 THEN
            count = count + 1
            citiesToRecruit(count) = tempCities(i)
            cityNames$(count) = cities(tempCities(i)).name + " (Cost: " + LTRIM$(STR$(RECRUITMENT_COST)) + ")"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No cities available for recruitment")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Recruit Army", cityNames$, count)
    
    IF selected > 0 THEN
        ' Check if have enough money
        IF GetGameStateCash&(side) < RECRUITMENT_COST THEN
            CALL ShowError("Insufficient funds (need " + LTRIM$(STR$(RECRUITMENT_COST)) + ")")
            EXIT SUB
        END IF
        
        ' Show commander selection menu
        DIM commanderIndex AS INTEGER
        DIM commanderName AS STRING
        DIM commanderRating AS INTEGER
        
        ' Select commander (filter by city nationality for cohesion)
        commanderIndex = SelectCommander%(side, citiesToRecruit(selected))
        
        IF commanderIndex = 0 THEN
            ' User cancelled commander selection
            EXIT SUB
        END IF
        
        ' Validate commander index before accessing commanders array
        IF ValidateCommanderIndex%(commanderIndex, "RecruitArmyMenu") = 0 THEN
            EXIT SUB
        END IF
        
        ' Get commander details
        commanderName = commanders(commanderIndex).name
        commanderRating = commanders(commanderIndex).rating
        
        ' Mark commander as unavailable (assigned to army)
        commanders(commanderIndex).available = 0
        
        CALL RecruitArmy(side, citiesToRecruit(selected), commanderName, commanderRating)
        CALL SetGameStateCash(side, GetGameStateCash&(side) - RECRUITMENT_COST)
    END IF
END SUB

SUB MoveOrdersMenu (side AS INTEGER)
    ' Move orders menu
    ' Shows armies that can move
    
    DIM armiesToMove(1 TO MAX_ARMIES) AS INTEGER
    DIM selected AS INTEGER
    
    ' Build list of active armies that can move and show menu
    selected = ShowArmySelectionMenu%("Move Orders", armiesToMove(), side, 1, 1, "%s (%l)", "No armies available to move")
    
    IF selected > 0 THEN
        ' Show destination cities
        DIM currentCity AS INTEGER
        DIM i AS INTEGER
        currentCity = armies(armiesToMove(selected)).loc
        
        ' Validate currentCity before accessing cityMatrix
        ' cityMatrix bounds: 1 TO 60 (declared in declarations.bas)
        IF ValidateCityIndex%(currentCity, "ShowMovementMenu - currentCity") = 1 THEN
            DIM destCount AS INTEGER
            DIM destinations(1 TO 7) AS INTEGER
            DIM destNames$(1 TO 7)
            
            destCount = 0
            FOR i = 1 TO 7
                ' Validate cityMatrix column access
                IF ValidateCityMatrixColumn%(currentCity, i, "ShowMovementMenu") = 0 THEN
                    EXIT FOR
                END IF
                
                DIM connectedCity AS INTEGER
                connectedCity = cityMatrix(currentCity, i)
                IF connectedCity > 0 THEN
                    ' Validate connected city before accessing cities array
                    IF ValidateCityIndex%(connectedCity, "ShowMovementMenu - connected city") = 1 THEN
                        destCount = destCount + 1
                        destinations(destCount) = connectedCity
                        destNames$(destCount) = cities(connectedCity).name
                    END IF
                END IF
            NEXT i
        ELSE
            ' Invalid currentCity - log warning
            CALL HandleWarning("Invalid currentCity = " + LTRIM$(STR$(currentCity)) + " (must be 1-" + LTRIM$(STR$(MAX_CITIES)) + ")")
        END IF
            
            IF destCount > 0 THEN
                DIM destSelected AS INTEGER
                destSelected = ShowListMenu%("Select Destination", destNames$, destCount)
                
                IF destSelected > 0 THEN
                    CALL MoveArmy(armiesToMove(selected), destinations(destSelected))
                END IF
            ELSE
                CALL ShowInfo("No connected cities")
            END IF
        END IF
    END IF
END SUB

SUB NavalMenu (side AS INTEGER)
    ' Naval operations menu
    
    DIM choice AS INTEGER
    DIM menuItems$(1 TO 6) AS STRING
    
    DO
        menuItems$(1) = "Build Ship"
        menuItems$(2) = "Move Fleet"
        menuItems$(3) = "Bombard City"
        menuItems$(4) = "Blockade Port"
        menuItems$(5) = "Raid Commerce"
        menuItems$(6) = "Marine Invasion"
        
        choice = ShowMenuWithBack%("Naval Operations", menuItems$, 6, 67, 13, 4, 11)
        
        SELECT CASE choice
            CASE 1
                CALL BuildShipMenu(side)
            CASE 2
                CALL MoveFleetMenu(side)
            CASE 3
                CALL BombardMenu(side)
            CASE 4
                CALL BlockadeMenu(side)
            CASE 5
                CALL RaidCommerceMenu(side)
            CASE 6
                CALL InvasionMenu(side)
            CASE 0
                EXIT DO
        END SELECT
    LOOP
END SUB

SUB BuildShipMenu (side AS INTEGER)
    ' Build ship menu - select port city
    
    DIM ports(1 TO MAX_CITIES) AS INTEGER
    DIM selected AS INTEGER
    DIM nameFormatter$ AS STRING
    
    ' Format string for city names with cost
    nameFormatter$ = "%s (Cost: " + LTRIM$(STR$(RECRUITMENT_COST)) + ")"
    
    ' Build list and show menu
    selected = ShowCitySelectionMenu%("Build Ship", ports(), side, 1, 1, 1, nameFormatter$, "No port cities available")
    
    IF selected > 0 THEN
        CALL BuildShip(side, ports(selected))
    END IF
END SUB

SUB MoveFleetMenu (side AS INTEGER)
    ' Move fleet menu - select destination port
    
    IF IsFleetActive%(side) = 0 THEN
        CALL ShowInfo("No fleet to move")
        EXIT SUB
    END IF
    
    DIM ports(1 TO MAX_CITIES) AS INTEGER
    DIM selected AS INTEGER
    
    ' Build list of all port cities (any ownership) and show menu
    selected = ShowCitySelectionMenu%("Move Fleet To", ports(), 0, 1, 0, 1, "", "No ports available")
    
    IF selected > 0 THEN
        CALL MoveFleet(side, ports(selected))
    END IF
END SUB

SUB BombardMenu (side AS INTEGER)
    ' Bombard city menu
    ' Shows list of port cities where fleet can bombard
    
    IF IsFleetActive%(side) = 0 THEN
        CALL ShowInfo("No fleet available")
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM targetCities(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of all port cities
    tempCount = BuildCityList%(tempCities(), tempNames$, 0, 1, 0, 1, "")
    
    ' Filter for cities where fleet is located
    count = 0
    FOR i = 1 TO tempCount
        IF fleets(side).loc = tempCities(i) THEN
            count = count + 1
            targetCities(count) = tempCities(i)
            cityNames$(count) = cities(tempCities(i)).name
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("Fleet must be at a port city to bombard")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Bombard City", cityNames$, count)
    
    IF selected > 0 THEN
        CALL BombardCity(side, targetCities(selected))
    END IF
END SUB

SUB BlockadeMenu (side AS INTEGER)
    ' Blockade port menu
    ' Shows list of enemy ports where fleet can blockade
    
    IF IsFleetActive%(side) = 0 THEN
        CALL ShowInfo("No fleet available")
        EXIT SUB
    END IF
    
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM targetPorts(1 TO MAX_CITIES) AS INTEGER
    DIM portNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of enemy port cities
    tempCount = BuildCityList%(tempCities(), tempNames$, enemySide, 1, 1, 1, "")
    
    ' Filter for cities where fleet is located
    count = 0
    FOR i = 1 TO tempCount
        IF fleets(side).loc = tempCities(i) THEN
            count = count + 1
            targetPorts(count) = tempCities(i)
            portNames$(count) = cities(tempCities(i)).name
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("Fleet must be at an enemy port to blockade")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Blockade Port", portNames$, count)
    
    IF selected > 0 THEN
        CALL BlockadePort(side, targetPorts(selected))
    END IF
END SUB

SUB RaidCommerceMenu (side AS INTEGER)
    ' Raid commerce menu
    
    IF fleets(side).size < 2 THEN
        CALL ShowInfo("Need at least 2 ships for commerce raiding")
        EXIT SUB
    END IF
    
    CALL RaidCommerce(side)
END SUB

SUB InvasionMenu (side AS INTEGER)
    ' Marine invasion menu
    ' Shows list of neutral coastal cities for invasion
    
    IF fleets(side).size < 2 THEN
        CALL ShowInfo("Need at least 2 ships for invasion")
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM targetCities(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of all port cities
    tempCount = BuildCityList%(tempCities(), tempNames$, 0, 1, 0, 1, "")
    
    ' Filter for neutral cities where fleet is located
    count = 0
    FOR i = 1 TO tempCount
        IF cities(tempCities(i)).owner = CITY_NEUTRAL AND fleets(side).loc = tempCities(i) THEN
            count = count + 1
            targetCities(count) = tempCities(i)
            cityNames$(count) = cities(tempCities(i)).name
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("Fleet must be at a neutral port city for invasion")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Marine Invasion", cityNames$, count)
    
    IF selected > 0 THEN
        CALL MarineInvasion(side, targetCities(selected))
    END IF
END SUB

SUB ReportsMenu (side AS INTEGER)
    ' Reports menu
    
    DIM choice AS INTEGER
    DIM menuItems$(1 TO 7) AS STRING
    
    DO
        menuItems$(1) = "Friendly Army"
        menuItems$(2) = "Enemy Army"
        menuItems$(3) = "City"
        menuItems$(4) = "Force Summary"
        menuItems$(5) = "Intelligence"
        menuItems$(6) = "Battle Summary"
        menuItems$(7) = "Recap/History"
        
        choice = ShowMenuWithBack%("Reports", menuItems$, 7, 67, 13, 4, 11)
        
        SELECT CASE choice
            CASE 1
                CALL ShowFriendlyArmyReport(side)
            CASE 2
                CALL ShowEnemyArmyReport(side)
            CASE 3
                CALL ShowCityReport
            CASE 4
                CALL ShowForceSummary
            CASE 5
                CALL ShowIntelligenceReport(side)
            CASE 6
                CALL ShowBattleSummary
            CASE 7
                CALL ShowRecapReport
            CASE 0
                EXIT DO
        END SELECT
    LOOP
END SUB


SUB MoveCombatPhase
    ' Move & Combat phase
    ' Execute move orders, resolve battles
    
    COLOR 11: CALL clrbot: PRINT "Move & Combat Phase - Executing orders"
    
    ' Execute movements
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        IF armies(i).move > 0 THEN
            ' Execute movement
            CALL ExecuteMovement(i)
        END IF
    NEXT i
    
    ' Execute fleet movements
    FOR i = 1 TO 2
        IF fleets(i).move > 0 THEN
            fleets(i).loc = fleets(i).move
            fleets(i).move = 0
        END IF
    NEXT i
    
    ' Resolve combats (may trigger tactical battles)
    ' This will be handled by tactical_integration.bas
    CALL ResolveAllCombats
    
    CALL DrawStrategicMap
END SUB

SUB ExecuteMovement (armyIndex AS INTEGER)
    ' Execute army movement with full validation
    ' Implements: movement costs, terrain effects, path validation, supply handling
    
    DIM destination AS INTEGER
    DIM currentLocation AS INTEGER
    DIM armySide AS INTEGER
    DIM destinationSide AS INTEGER
    DIM pathValid AS INTEGER
    DIM canMove AS INTEGER
    
    destination = armies(armyIndex).move
    
    ' Validate army has a movement order
    IF destination <= 0 THEN
        EXIT SUB ' No movement order
    END IF
    
    ' Validate army index
    IF ValidateArmyIndex%(armyIndex, "ExecuteMovement") = 0 THEN
        EXIT SUB
    END IF
    
    ' Validate army is active
    IF IsArmyActive%(armyIndex) = 0 THEN
        armies(armyIndex).move = 0 ' Clear invalid order
        EXIT SUB
    END IF
    
    ' Get current location
    currentLocation = armies(armyIndex).loc
    
    ' Validate current location
    IF currentLocation <= 0 OR currentLocation > MAX_CITIES THEN
        CALL HandleValidationError("Army " + LTRIM$(STR$(armyIndex)) + " has invalid location")
        armies(armyIndex).move = 0 ' Clear invalid order
        EXIT SUB
    END IF
    
    ' Validate destination
    IF ValidateCityIndex%(destination, "ExecuteMovement") = 0 THEN
        armies(armyIndex).move = 0 ' Clear invalid order
        EXIT SUB
    END IF
    
    ' ============================================================
    ' CHECK 1: Validate Movement Path
    ' ============================================================
    ' Check if destination is connected to current location via cityMatrix
    pathValid = 0
    DIM i AS INTEGER
    FOR i = 1 TO 7
        ' Validate cityMatrix column access
        IF ValidateCityMatrixColumn%(currentLocation, i, "ExecuteMovement - path check") = 0 THEN
            EXIT FOR
        END IF
        
        IF cityMatrix(currentLocation, i) = destination THEN
            pathValid = 1
            EXIT FOR
        END IF
    NEXT i
    
    IF pathValid = 0 THEN
        ' Destination not connected - invalid path
        CALL HandleValidationError(armies(armyIndex).name + " cannot reach " + cities(destination).name + " (not connected)")
        armies(armyIndex).move = 0 ' Clear invalid order
        EXIT SUB
    END IF
    
    ' ============================================================
    ' CHECK 2: Check for Enemy Armies Blocking Path
    ' ============================================================
    ' Check if any enemy armies are in cities along the path
    ' For point-to-point movement, we only check the destination
    ' (intermediate cities would require pathfinding, which is beyond current scope)
    ' However, we check if destination has an enemy army
    
    armySide = GetArmySide%(armyIndex)
    IF armySide = 0 THEN
        CALL HandleValidationError("Invalid army side in ExecuteMovement")
        armies(armyIndex).move = 0
        EXIT SUB
    END IF
    
    destinationSide = cities(destination).owner
    ' Check if destination is enemy-controlled (not neutral, not friendly, not at peace)
    IF destinationSide <> CITY_NEUTRAL AND destinationSide <> armySide AND destinationSide <> CITY_AT_PEACE THEN
        ' Enemy-controlled city - movement will trigger combat (handled below)
        ' This is valid - armies can move into enemy cities to attack
    END IF
    
    ' ============================================================
    ' CHECK 3: Supply Requirements
    ' ============================================================
    ' Armies need at least MOVEMENT_SUPPLY_COST supply to move
    ' Out of supply armies cannot move
    IF IsOutOfSupply%(armyIndex) = 1 THEN
        CALL HandleValidationError(armies(armyIndex).name + " cannot move (out of supply)")
        armies(armyIndex).move = 0 ' Clear order
        EXIT SUB
    END IF
    
    ' Check if army has enough supply for movement
    IF armies(armyIndex).supply < MOVEMENT_SUPPLY_COST THEN
        CALL HandleValidationError(armies(armyIndex).name + " cannot move (insufficient supply)")
        armies(armyIndex).move = 0 ' Clear order
        EXIT SUB
    END IF
    
    ' ============================================================
    ' CHECK 4: Terrain Effects
    ' ============================================================
    ' Strategic movement is point-to-point, so terrain effects are minimal
    ' However, fortified cities may affect movement (defender advantage)
    ' Port cities may have different movement characteristics
    ' For now, we note terrain but don't block movement
    ' (Terrain effects are more relevant in tactical battles)
    
    ' ============================================================
    ' EXECUTE MOVEMENT
    ' ============================================================
    ' Check for combat at destination
    IF occupied(destination) > 0 THEN
        ' Destination is occupied - check if it's an enemy army
        DIM defenderIndex AS INTEGER
        defenderIndex = occupied(destination)
        DIM defenderSide AS INTEGER
        
        defenderSide = GetArmySide%(defenderIndex)
        
        ' Only trigger combat if it's an enemy army
        IF defenderSide > 0 AND defenderSide <> armySide THEN
            ' Combat occurs
            DIM winner AS INTEGER
            winner = ResolveCombat%(armyIndex, defenderIndex, destination)
            
            ' If attacker wins, movement completes (handled in ResolveCombat)
            ' If defender wins, movement is cancelled (handled in ResolveCombat)
        ELSE
            ' Friendly army or invalid - move to city anyway (stacking allowed)
            armies(armyIndex).loc = destination
            CALL PlaceArmy(armyIndex)
            
            ' Consume supply for movement
             armies(armyIndex).supply = armies(armyIndex).supply - MOVEMENT_SUPPLY_COST
            IF armies(armyIndex).supply < 0 THEN armies(armyIndex).supply = 0
            
            ' Invalidate caches (location and supply changed)
            CALL InvalidateArmyLocationIndex
            CALL InvalidateCombatStrengthCache(armyIndex)
        END IF
    ELSE
        ' Destination is empty - move to city
        armies(armyIndex).loc = destination
        CALL PlaceArmy(armyIndex)
        
        ' Consume supply for movement
        armies(armyIndex).supply = armies(armyIndex).supply - MOVEMENT_SUPPLY_COST
        IF armies(armyIndex).supply < 0 THEN armies(armyIndex).supply = 0
        
        ' Invalidate caches (location and supply changed)
        CALL InvalidateArmyLocationIndex
        CALL InvalidateCombatStrengthCache(armyIndex)
        
        ' If moving into enemy city, capture it
        IF destinationSide <> CITY_NEUTRAL AND destinationSide <> armySide AND destinationSide <> CITY_AT_PEACE THEN
            CALL CaptureCity(destination, armySide)
        END IF
    END IF
    
    ' Mark movement as completed
    armies(armyIndex).move = -2 ' Moved
END SUB

SUB ResolveAllCombats
    ' Resolve all combats that occurred during movement
    
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM attackerIndex AS INTEGER
    DIM defenderIndex AS INTEGER
    DIM cityIndex AS INTEGER
    DIM winner AS INTEGER
    
    ' Check each city for combat
    FOR i = 1 TO MAX_CITIES
        IF occupied(i) > 0 THEN
            ' Check if multiple armies from different sides
            DIM armiesInCity(1 TO MAX_ARMIES) AS INTEGER
            DIM count AS INTEGER
            DIM side1 AS INTEGER
            DIM side2 AS INTEGER
            
            count = 0
            side1 = 0
            side2 = 0
            
            ' Find all armies in city using location index for performance
            DIM army1Index AS INTEGER
            DIM army2Index AS INTEGER
            army1Index = 0
            army2Index = 0
            
            ' Use location index instead of iterating all armies
            count = GetArmiesAtLocation%(i, armiesInCity())
            
            IF count > 0 THEN
                ' Process armies found at location
                FOR j = 1 TO count
                    IF IsArmyActive%(armiesInCity(j)) = 1 THEN
                        ' Determine sides using GetArmySide% to get actual side numbers (1 or 2)
                        DIM currentSide AS INTEGER
                        currentSide = GetArmySide%(armiesInCity(j))
                        IF currentSide = 1 THEN
                            IF side1 = 0 THEN
                                side1 = 1
                            END IF
                            army1Index = armiesInCity(j)
                        ELSEIF currentSide = 2 THEN
                            IF side2 = 0 THEN
                                side2 = 2
                            END IF
                            army2Index = armiesInCity(j)
                        END IF
                    END IF
                NEXT j
            END IF
            
            ' If both sides present, resolve combat
            IF side1 > 0 AND side2 > 0 THEN
                ' Determine attacker (army with move order)
                IF armies(army1Index).move = i THEN
                    attackerIndex = army1Index
                    defenderIndex = army2Index
                ELSEIF armies(army2Index).move = i THEN
                    attackerIndex = army2Index
                    defenderIndex = army1Index
                ELSE
                    ' No clear attacker - use first mover
                    attackerIndex = army1Index
                    defenderIndex = army2Index
                END IF
                
                ' Resolve combat (may trigger tactical battle)
                winner = ResolveCombat%(attackerIndex, defenderIndex, i)
                
                ' Process result
                CALL ProcessCombatResult(attackerIndex, defenderIndex, i, winner)
            END IF
        END IF
    NEXT i
END SUB

SUB UpdatePhase
    ' Update phase
    ' Income updated, supply distributed
    
    CALL UpdateIncome
    CALL AutoSupply
    CALL ConsumeSupply
    
    ' Realism mode: Restore isolated cities to original ownership
    IF realismMode = 1 THEN
        CALL RestoreIsolatedCities
    END IF
    
    COLOR 11: CALL clrbot: PRINT "Update Phase"
END SUB

SUB EndGame (winner AS INTEGER)
    ' End game - show results
    
    CLS
    COLOR 15: PRINT "GAME OVER"
    PRINT STRING$(80, "-")
    
    IF winner = 1 THEN
        PRINT "French Victory!"
    ELSE
        PRINT "Allied Victory!"
    END IF
    
    PRINT
    PRINT "French Victory Points:"; GetVictoryPoints&(1)
    PRINT "Allied Victory Points:"; GetVictoryPoints&(2)
    
    ' Award end game bonus
    CALL AwardEndGameBonus(winner)
    
    ' Save high score
    CALL SaveHighScore(winner, GetVictoryPoints&(winner))
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB CleanupGame
    ' Cleanup before exit
    ' Save configuration
    CALL SaveConfig
END SUB
