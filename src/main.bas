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
    IF InitializeGraphics%() = 0 THEN
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
        CALL ShowStatusError("No save files found")
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
        CALL ShowStatusError("PBM mode not enabled")
        EXIT SUB
    END IF
    
    CALL LoadPBMFile
    CALL GameLoop
END SUB

SUB UtilityMenu
    ' Utility menu
    ' Options: Configuration, Realism, Mouse, PBM, etc.
    
    DIM choice AS INTEGER
    
    DO
        mtx$(0) = "Utility Menu"
        mtx$(1) = "Configuration"
        mtx$(2) = "Realism Toggle"
        mtx$(3) = "Mouse Support"
        mtx$(4) = "PBM Support"
        mtx$(5) = "Back to Main Menu"
        size = 5
        tlx = 67
        tly = 13
        colour = 4
        hilite = 11
        
        CALL ShowMenu(0)
        choice = choose
        
        SELECT CASE choice
            CASE 1
                CALL ConfigurationMenu
            CASE 2
                CALL ToggleRealism
            CASE 3
                CALL ToggleMouse
            CASE 4
                CALL TogglePBM
            CASE 5
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
    
    DO
        ' Show decision menu
        mtx$(0) = "Decision Phase - " + GetCurrentMonth$
        mtx$(1) = "Recruit"
        mtx$(2) = "Move Orders"
        mtx$(3) = "Ships"
        mtx$(4) = "Commands"
        mtx$(5) = "Inform (Reports)"
        mtx$(6) = "END TURN"
        size = 6
        tlx = 67
        tly = 13
        colour = 4
        hilite = 11
        
        CALL ShowMenu(0)
        choice = choose
        
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
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" AND cities(i).owner = side THEN
            ' Check if can recruit (not at peace, etc.)
            IF CanRecruitInCity(i) = 1 THEN
                count = count + 1
                citiesToRecruit(count) = i
                cityNames$(count) = cities(i).name + " (Cost: " + LTRIM$(STR$(RECRUITMENT_COST)) + ")"
            END IF
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
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armiesToMove(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES)
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    count = 0
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 AND armies(i).move <> -1 THEN
            count = count + 1
            armiesToMove(count) = i
            DIM locationName AS STRING
            IF armies(i).loc > 0 THEN
                locationName = cities(armies(i).loc).name
            ELSE
                locationName = "Unknown"
            END IF
            armyNames$(count) = armies(i).name + " (" + locationName + ")"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No armies available to move")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Move Orders", armyNames$, count)
    
    IF selected > 0 THEN
        ' Show destination cities
        DIM currentCity AS INTEGER
        currentCity = armies(armiesToMove(selected)).loc
        
        IF currentCity > 0 THEN
            DIM destCount AS INTEGER
            DIM destinations(1 TO 7) AS INTEGER
            DIM destNames$(1 TO 7)
            
            destCount = 0
            FOR i = 1 TO 7
                DIM connectedCity AS INTEGER
                connectedCity = cityMatrix(currentCity, i)
                IF connectedCity > 0 THEN
                    destCount = destCount + 1
                    destinations(destCount) = connectedCity
                    destNames$(destCount) = cities(connectedCity).name
                END IF
            NEXT i
            
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
    
    DO
        mtx$(0) = "Naval Operations"
        mtx$(1) = "Build Ship"
        mtx$(2) = "Move Fleet"
        mtx$(3) = "Bombard City"
        mtx$(4) = "Blockade Port"
        mtx$(5) = "Raid Commerce"
        mtx$(6) = "Marine Invasion"
        mtx$(7) = "Back"
        size = 7
        tlx = 67
        tly = 13
        colour = 4
        hilite = 11
        
        CALL ShowMenu(0)
        choice = choose
        
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
            CASE 7
                EXIT DO
        END SELECT
    LOOP
END SUB

SUB BuildShipMenu (side AS INTEGER)
    ' Build ship menu - select port city
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM ports(1 TO MAX_CITIES) AS INTEGER
    DIM portNames$(1 TO MAX_CITIES)
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check if port city using cityMatrix(cityIndex, 7)
        IF cities(i).name <> "" AND cities(i).owner = side AND cityMatrix(i, 7) = 1 THEN
            count = count + 1
            ports(count) = i
            portNames$(count) = cities(i).name + " (Cost: " + LTRIM$(STR$(RECRUITMENT_COST)) + ")"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No port cities available")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Build Ship", portNames$, count)
    
    IF selected > 0 THEN
        CALL BuildShip(side, ports(selected))
    END IF
END SUB

SUB MoveFleetMenu (side AS INTEGER)
    ' Move fleet menu - select destination port
    
    IF fleets(side).size = 0 THEN
        CALL ShowInfo("No fleet to move")
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM ports(1 TO MAX_CITIES) AS INTEGER
    DIM portNames$(1 TO MAX_CITIES)
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check if port city using cityMatrix(cityIndex, 7)
        IF cities(i).name <> "" AND cityMatrix(i, 7) = 1 THEN
            count = count + 1
            ports(count) = i
            portNames$(count) = cities(i).name
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No ports available")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Move Fleet To", portNames$, count)
    
    IF selected > 0 THEN
        CALL MoveFleet(side, ports(selected))
    END IF
END SUB

SUB BombardMenu (side AS INTEGER)
    ' Bombard city menu
    ' Shows list of port cities where fleet can bombard
    
    IF fleets(side).size = 0 THEN
        CALL ShowInfo("No fleet available")
        EXIT SUB
    END IF
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM targetCities(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES)
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check if port city and fleet is at that location
        IF cities(i).name <> "" AND cityMatrix(i, 7) = 1 THEN
            IF fleets(side).loc = i THEN
                count = count + 1
                targetCities(count) = i
                cityNames$(count) = cities(i).name
            END IF
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
    
    IF fleets(side).size = 0 THEN
        CALL ShowInfo("No fleet available")
        EXIT SUB
    END IF
    
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM targetPorts(1 TO MAX_CITIES) AS INTEGER
    DIM portNames$(1 TO MAX_CITIES)
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check if enemy port and fleet is at that location
        IF cities(i).name <> "" AND cityMatrix(i, 7) = 1 THEN
            IF cities(i).owner = enemySide AND fleets(side).loc = i THEN
                count = count + 1
                targetPorts(count) = i
                portNames$(count) = cities(i).name
            END IF
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
    DIM cityNames$(1 TO MAX_CITIES)
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check if neutral port city and fleet is at that location
        IF cities(i).name <> "" AND cityMatrix(i, 7) = 1 THEN
            IF cities(i).owner = CITY_NEUTRAL AND fleets(side).loc = i THEN
                count = count + 1
                targetCities(count) = i
                cityNames$(count) = cities(i).name
            END IF
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
    
    DO
        mtx$(0) = "Reports"
        mtx$(1) = "Friendly Army"
        mtx$(2) = "Enemy Army"
        mtx$(3) = "City"
        mtx$(4) = "Force Summary"
        mtx$(5) = "Intelligence"
        mtx$(6) = "Battle Summary"
        mtx$(7) = "Recap/History"
        mtx$(8) = "Back"
        size = 8
        tlx = 67
        tly = 13
        colour = 4
        hilite = 11
        
        CALL ShowMenu(0)
        choice = choose
        
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
            CASE 8
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
    ' Execute army movement
    ' TODO: Implement full movement logic:
    '   - Check movement costs
    '   - Handle terrain effects
    '   - Check for enemy armies in path
    '   - Handle supply during movement
    
    DIM destination AS INTEGER
    destination = armies(armyIndex).move
    
    IF destination > 0 THEN
        ' Check for combat
        IF occupied(destination) > 0 THEN
            ' Combat occurs
            DIM defenderIndex AS INTEGER
            defenderIndex = occupied(destination)
            DIM winner AS INTEGER
            winner = ResolveCombat%(armyIndex, defenderIndex, destination)
        ELSE
            ' Move to city
            armies(armyIndex).loc = destination
            CALL PlaceArmy(armyIndex)
        END IF
        
        armies(armyIndex).move = -2 ' Moved
    END IF
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
            
            ' Find all armies in city
            FOR j = 1 TO MAX_ARMIES
                IF armies(j).loc = i AND armies(j).size > 0 THEN
                    count = count + 1
                    armiesInCity(count) = j
                    
                    ' Determine sides
                    IF j >= FRENCH_START AND j < ALLIED_START THEN
                        IF side1 = 0 THEN side1 = j
                    ELSEIF side2 = 0 THEN side2 = j
                    END IF
                END IF
            NEXT j
            
            ' If both sides present, resolve combat
            IF side1 > 0 AND side2 > 0 THEN
                ' Determine attacker (army with move order)
                IF armies(side1).move = i THEN
                    attackerIndex = side1
                    defenderIndex = side2
                ELSEIF armies(side2).move = i THEN
                    attackerIndex = side2
                    defenderIndex = side1
                ELSE
                    ' No clear attacker - use first mover
                    attackerIndex = side1
                    defenderIndex = side2
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
