'============================================================================
' Play-by-Mail (PBM) Support
'============================================================================
' Ported from WW2
' Automated file exchange system for remote multiplayer

' Note: game_types.bas is included in main.bas
' Note: campaign.bas is included in main.bas

' Note: pbmEnabled is declared in declarations.bas

'============================================================================
' InitializePBM - Initialize play-by-mail system
'============================================================================
' Description:
'   Initializes the play-by-mail (PBM) system by setting pbmEnabled to 0
'   (disabled by default). PBM mode allows players to exchange game files
'   for remote multiplayer games. Must be explicitly enabled via EnablePBM.
' Side Effects:
'   - Sets pbmEnabled to 0 (disabled)
'============================================================================
SUB InitializePBM
    ' Initialize PBM system
    pbmEnabled = 0 ' Default disabled
END SUB

'============================================================================
' CreatePBMFile - Save game state for play-by-mail exchange
'============================================================================
' Description:
'   Saves complete game state to PBM file for file exchange between players.
'   Only saves if PBM mode is enabled. File contains all game data needed
'   for the other player to continue the game.
' Side Effects:
'   Creates or overwrites PBM file
'============================================================================
SUB CreatePBMFile
    
    IF pbmEnabled = 0 THEN EXIT SUB
    
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%("PBM", "O", 1) = 0 THEN
        ' File open failed - error already displayed by SafeOpenFile%
        EXIT SUB
    END IF
    
    ' Write game state
    WRITE #1, gameState.month, gameState.year, gameState.side, gameState.turn
    WRITE #1, GetGameStateCash&(1), GetGameStateCash&(2)
    WRITE #1, GetGameStateIncome&(1), GetGameStateIncome&(2)
    WRITE #1, GetGameStateVictory&(1), GetGameStateVictory&(2)
    WRITE #1, scenario$
    
    ' Write army data
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        WRITE #1, armies(i).name, armies(i).size, armies(i).lead, armies(i).exper
        WRITE #1, armies(i).supply, armies(i).loc, armies(i).move, armies(i).nationality
    NEXT i
    
    ' Write city data
    FOR i = 1 TO MAX_CITIES
        WRITE #1, cities(i).name, cities(i).owner, cities(i).fort, cities(i).value
        WRITE #1, cities(i).nationality, cities(i).objective, cities(i).originalOwner
    NEXT i
    
    ' Write fleet data
    FOR i = 1 TO 2
        WRITE #1, fleets(i).size, fleets(i).loc, fleets(i).move
    NEXT i
    
    CLOSE #1
    
    CALL ShowStatusMessage("PBM file created", 11)
END SUB

'============================================================================
' LoadPBM - Load game state from play-by-mail file
'============================================================================
' Description:
'   Loads game state from PBM file received from other player. Restores all
'   game data and continues the game from the loaded state.
' Side Effects:
'   - Restores complete game state from file
'   - Displays load progress message
'   - Exits early if PBM mode disabled or file not found
'============================================================================
'============================================================================
' LoadPBMFile - Load game state from play-by-mail file
'============================================================================
' Description:
'   Loads game state from PBM file received from other player. Restores all
'   game data and continues the game from the loaded state.
' Side Effects:
'   - Restores complete game state from file
'   - Displays load progress message
'   - Exits early if PBM mode disabled or file not found
'============================================================================
SUB LoadPBMFile
    
    IF NOT _FILEEXISTS("PBM") THEN
        CALL HandleFileNotFound("PBM")
        EXIT SUB
    END IF
    
    CALL ShowStatusMessage("Loading PBM file", 11)
    
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%("PBM", "I", 1) = 0 THEN
        ' File open failed - error already displayed by SafeOpenFile%
        EXIT SUB
    END IF
    
    ' Read game state
    DIM cash1 AS LONG, cash2 AS LONG
    DIM income1 AS LONG, income2 AS LONG
    DIM victory1 AS LONG, victory2 AS LONG
    INPUT #1, gameState.month, gameState.year, gameState.side, gameState.turn
    INPUT #1, cash1, cash2
    INPUT #1, income1, income2
    INPUT #1, victory1, victory2
    INPUT #1, scenario$
    CALL SetGameStateCash(1, cash1)
    CALL SetGameStateCash(2, cash2)
    CALL SetGameStateIncome(1, income1)
    CALL SetGameStateIncome(2, income2)
    CALL SetGameStateVictory(1, victory1)
    CALL SetGameStateVictory(2, victory2)
    
    ' Read army data
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        INPUT #1, armies(i).name, armies(i).size, armies(i).lead, armies(i).exper
        INPUT #1, armies(i).supply, armies(i).loc, armies(i).move, armies(i).nationality
    NEXT i
    
    ' Read city data
    FOR i = 1 TO MAX_CITIES
        INPUT #1, cities(i).name, cities(i).owner, cities(i).fort, cities(i).value
        INPUT #1, cities(i).nationality, cities(i).objective, cities(i).originalOwner
    NEXT i
    
    ' Read fleet data
    FOR i = 1 TO 2
        INPUT #1, fleets(i).size, fleets(i).loc, fleets(i).move
    NEXT i
    
    CLOSE #1
    
    CALL ShowStatusMessage("PBM file loaded", 11)
END SUB

'============================================================================
' EnablePBM - Enable play-by-mail mode
'============================================================================
' Description:
'   Enables play-by-mail mode, allowing the game to create and load PBM
'   files for remote multiplayer games. When enabled, CreatePBMFile will
'   save game state to the PBM file for exchange with other players.
' Side Effects:
'   - Sets pbmEnabled to 1 (enabled)
'   - Displays status message
'============================================================================
SUB EnablePBM
    ' Enable PBM mode
    pbmEnabled = 1
    CALL ShowStatusMessage("PBM mode enabled", 11)
END SUB

'============================================================================
' DisablePBM - Disable play-by-mail mode
'============================================================================
' Description:
'   Disables play-by-mail mode. When disabled, CreatePBMFile will not
'   create PBM files. This is the default state after initialization.
' Side Effects:
'   - Sets pbmEnabled to 0 (disabled)
'   - Displays status message
'============================================================================
SUB DisablePBM
    ' Disable PBM mode
    pbmEnabled = 0
    CALL ShowStatusMessage("PBM mode disabled", 11)
END SUB
