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

SUB CreatePBMFile
    ' Create PBM file after each turn
    ' Contains complete game state for file exchange
    
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
    
    COLOR 11: CALL clrbot: PRINT "PBM file created"
END SUB

SUB LoadPBMFile
    ' Load PBM file to continue game
    ' Reads complete game state from file exchange
    
    IF FileExists%("PBM") = 0 THEN
        COLOR 11: CALL clrbot: PRINT "PBM file not found"
        EXIT SUB
    END IF
    
    COLOR 11: CALL clrbot: PRINT "Loading PBM file"
    
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
    
    COLOR 11: CALL clrbot: PRINT "PBM file loaded"
END SUB

SUB EnablePBM
    ' Enable PBM mode
    pbmEnabled = 1
    COLOR 11: CALL clrbot: PRINT "PBM mode enabled"
END SUB

SUB DisablePBM
    ' Disable PBM mode
    pbmEnabled = 0
    COLOR 11: CALL clrbot: PRINT "PBM mode disabled"
END SUB
