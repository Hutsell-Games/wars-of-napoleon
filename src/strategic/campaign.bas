'============================================================================
' Campaign Management System
'============================================================================
' Ported from CWS with 2-month turn structure
' Handles turn sequence, month/year tracking, save/load, configuration

' Note: game_types.bas is included in main.bas
' Config is included in declarations.bas

' Note: Turn sequence phase constants are in declarations.bas
' Note: month$ is declared in declarations.bas

' Note: gameState and currentPhase are declared in declarations.bas

SUB InitializeCampaign (scenarioYear AS INTEGER)
    ' Initialize campaign for given scenario year
    scenario$ = LTRIM$(STR$(scenarioYear))
    
    ' Initialize month names (moved from declarations.bas to avoid module-level executable code)
    month$(1) = "January": month$(2) = "February": month$(3) = "March"
    month$(4) = "April": month$(5) = "May": month$(6) = "June"
    month$(7) = "July": month$(8) = "August": month$(9) = "September"
    month$(10) = "October": month$(11) = "November": month$(12) = "December"
    
    ' Initialize game state
    gameState.month = 3 ' Start in March (typical for Napoleonic campaigns)
    gameState.year = scenarioYear
    gameState.side = config_side
    gameState.turn = 1
    gameState.cashFrench = 0
    gameState.cashAllied = 0
    gameState.incomeFrench = 0
    gameState.incomeAllied = 0
    gameState.victoryFrench = 0
    gameState.victoryAllied = 0
    gameState.controlFrench = 0
    gameState.controlAllied = 0
    
    currentPhase = PHASE_DECISION
    
    ' Load scenario data will be handled by scenario.bas
END SUB

SUB AdvanceTurn
    ' Advance to next turn (2 months)
    ' Sequence: Decision -> Move/Combat -> Update
    
    ' Complete current phase
    IF currentPhase = PHASE_DECISION THEN
        ' Autosave at end of decision phase
        SaveGame (9)
        currentPhase = PHASE_MOVE_COMBAT
    ELSEIF currentPhase = PHASE_MOVE_COMBAT THEN
        currentPhase = PHASE_UPDATE
    ELSEIF currentPhase = PHASE_UPDATE THEN
        ' Advance time by 2 months
        gameState.month = gameState.month + 2
        IF gameState.month > 12 THEN
            gameState.month = gameState.month - 12
            gameState.year = gameState.year + 1
        END IF
        
        gameState.turn = gameState.turn + 1
        currentPhase = PHASE_DECISION
        
        ' Switch sides for 2-player games
        IF config_players = 2 THEN
            gameState.side = 3 - gameState.side
        END IF
    END IF
END SUB

FUNCTION GetCurrentMonth$ ()
    ' Return current month name
    GetCurrentMonth$ = month$(gameState.month) + " " + LTRIM$(STR$(gameState.year))
END FUNCTION

FUNCTION IsHarvestMonth% ()
    ' Check if current month is harvest month (July or September)
    ' Harvest months provide free supply
    IsHarvestMonth% = 0
    IF gameState.month = 7 OR gameState.month = 9 THEN
        IsHarvestMonth% = 1
    END IF
END FUNCTION

'============================================================================
' SaveGame - Save current game state to file
'============================================================================
' Parameters:
'   slot (INTEGER) - Save slot number (1-9, 0=quick save)
' Description:
'   Saves complete game state to NWS<slot>.SAV file. Includes all game data:
'   month, year, side, turn, cash, income, armies, cities, etc.
' Side Effects:
'   Creates or overwrites save file
'   Displays save progress message
'============================================================================
SUB SaveGame (slot AS INTEGER)
    ' Save game to NWSx.SAV (x = 1-8) or NWS9.SAV (autosave)
    ' Format based on CWS save system, adapted for WON
    
    DIM filename AS STRING
    IF slot = 9 THEN
        filename = "saved\NWS9.SAV"
    ELSE
        filename = "saved\NWS" + LTRIM$(STR$(slot)) + ".SAV"
    END IF
    
    CALL ShowStatusMessage("Saving", 11)
    
    OPEN "O", 1, filename
    ' Write game state
    WRITE #1, gameState.month, gameState.year, gameState.side, gameState.turn
    WRITE #1, gameState.cashFrench, gameState.cashAllied
    WRITE #1, gameState.incomeFrench, gameState.incomeAllied
    WRITE #1, gameState.victoryFrench, gameState.victoryAllied
    WRITE #1, gameState.controlFrench, gameState.controlAllied
    WRITE #1, scenario$
    WRITE #1, currentPhase
    
    ' Save army data
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        WRITE #1, armies(i).name, armies(i).size, armies(i).lead, armies(i).exper
        WRITE #1, armies(i).supply, armies(i).loc, armies(i).move, armies(i).nationality
    NEXT i
    
    ' Save city data
    FOR i = 1 TO MAX_CITIES
        WRITE #1, cities(i).name, cities(i).x, cities(i).y, cities(i).value
        WRITE #1, cities(i).owner, cities(i).fort, cities(i).nationality, cities(i).objective
        DIM j AS INTEGER
        FOR j = 1 TO 7
            WRITE #1, cityMatrix(i, j)
        NEXT j
    NEXT i
    
    ' Save fleet data
    FOR i = 1 TO 2
        WRITE #1, fleets(i).size, fleets(i).loc, fleets(i).move
    NEXT i
    
    ' Save occupation data
    FOR i = 1 TO 60
        WRITE #1, occupied(i)
    NEXT i
    
    ' Save capital cities
    WRITE #1, capitalCity(1), capitalCity(2)
    
    ' Save battle statistics
    WRITE #1, battleWon(1), battleWon(2), casualties(1), casualties(2)
    
    CLOSE #1
    
    ' Save configuration when saving game
    SaveConfig
    
    PRINT "."
END SUB

'============================================================================
' LoadGame - Load game state from file
'============================================================================
' Parameters:
'   slot (INTEGER) - Save slot number (1-9, 0=quick save)
' Description:
'   Loads complete game state from NWS<slot>.SAV file. Restores all game data.
' Side Effects:
'   Restores game state from file
'   Displays load progress message
'   Exits early if file not found
'============================================================================
SUB LoadGame (slot AS INTEGER)
    ' Load game from NWSx.SAV (x = 1-8) or NWS9.SAV (autosave)
    
    DIM filename AS STRING
    IF slot = 9 THEN
        filename = "saved\NWS9.SAV"
    ELSE
        filename = "saved\NWS" + LTRIM$(STR$(slot)) + ".SAV"
    END IF
    
    IF FileExists%(filename) = 0 THEN
        CALL HandleFileNotFound(filename)
        EXIT SUB
    END IF
    
    CALL ShowStatusMessage("Loading", 11)
    
    OPEN "I", 1, filename
    ' Read game state
    INPUT #1, gameState.month, gameState.year, gameState.side, gameState.turn
    INPUT #1, gameState.cashFrench, gameState.cashAllied
    INPUT #1, gameState.incomeFrench, gameState.incomeAllied
    INPUT #1, gameState.victoryFrench, gameState.victoryAllied
    INPUT #1, gameState.controlFrench, gameState.controlAllied
    INPUT #1, scenario$
    INPUT #1, currentPhase
    
    ' Load army data
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        INPUT #1, armies(i).name, armies(i).size, armies(i).lead, armies(i).exper
        INPUT #1, armies(i).supply, armies(i).loc, armies(i).move, armies(i).nationality
        IF armies(i).loc > 0 THEN
            CALL PlaceArmy(i)
        END IF
    NEXT i
    
    ' Load city data
    FOR i = 1 TO MAX_CITIES
        INPUT #1, cities(i).name, cities(i).x, cities(i).y, cities(i).value
        INPUT #1, cities(i).owner, cities(i).fort, cities(i).nationality, cities(i).objective
        DIM j AS INTEGER
        FOR j = 1 TO 7
            INPUT #1, cityMatrix(i, j)
        NEXT j
    NEXT i
    
    ' Load fleet data
    FOR i = 1 TO 2
        INPUT #1, fleets(i).size, fleets(i).loc, fleets(i).move
    NEXT i
    
    ' Load occupation data
    FOR i = 1 TO 60
        INPUT #1, occupied(i)
    NEXT i
    
    ' Load capital cities
    INPUT #1, capitalCity(1), capitalCity(2)
    
    ' Load battle statistics
    INPUT #1, battleWon(1), battleWon(2), casualties(1), casualties(2)
    
    CLOSE #1
    
    ' Reload configuration
    LoadConfig
    
    ' Redraw map
    CALL DrawStrategicMap
    
    PRINT "."
END SUB

FUNCTION GetSaveFileList$ (count AS INTEGER)
    ' Get list of available save files
    ' Returns count of available files
    DIM i AS INTEGER
    DIM filename AS STRING
    DIM files$(1 TO 9)
    
    count = 0
    FOR i = 1 TO 9
        IF i = 9 THEN
            filename = "saved\NWS9.SAV"
        ELSE
            filename = "saved\NWS" + LTRIM$(STR$(i)) + ".SAV"
        END IF
        
        IF FileExists%(filename) <> 0 THEN
            count = count + 1
            files$(count) = filename
        END IF
    NEXT i
    
    ' Return first filename as function result (for compatibility)
    IF count > 0 THEN
        GetSaveFileList$ = files$(1)
    ELSE
        GetSaveFileList$ = ""
    END IF
END FUNCTION

