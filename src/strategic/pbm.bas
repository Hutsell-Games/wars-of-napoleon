'============================================================================
' Play-by-Mail (PBM) Support
'============================================================================
' Ported from WW2
' Automated file exchange system for remote multiplayer

' Note: game_types.bas is included in main.bas
' Note: campaign.bas is included in main.bas

' Note: pbmEnabled is declared in declarations.bas

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
    
    OPEN "O", 1, "PBM"
    
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
        WRITE #1, cities(i).nationality, cities(i).objective
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
    
    IF FileExists%("PBM") = 0 THEN
        CALL HandleFileNotFound("PBM")
        EXIT SUB
    END IF
    
    CALL ShowStatusMessage("Loading PBM file", 11)
    
    OPEN "I", 1, "PBM"
    
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
        INPUT #1, cities(i).nationality, cities(i).objective
    NEXT i
    
    ' Read fleet data
    FOR i = 1 TO 2
        INPUT #1, fleets(i).size, fleets(i).loc, fleets(i).move
    NEXT i
    
    CLOSE #1
    
    CALL ShowStatusMessage("PBM file loaded", 11)
END SUB

SUB EnablePBM
    ' Enable PBM mode
    pbmEnabled = 1
    CALL ShowStatusMessage("PBM mode enabled", 11)
END SUB

SUB DisablePBM
    ' Disable PBM mode
    pbmEnabled = 0
    CALL ShowStatusMessage("PBM mode disabled", 11)
END SUB
