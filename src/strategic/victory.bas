'============================================================================
' Victory Conditions System
'============================================================================
' Ported from CWS - 5 end game conditions
' Handles victory point tracking and end game conditions

' Note: game_types.bas is included in main.bas
' Note: End game condition constants are in declarations.bas
' Note: campaign.bas, army.bas, city.bas are included in main.bas

' Note: endGameFlags, endGameTriggered, endGameWinner are declared in declarations.bas

'============================================================================
' InitializeVictoryConditions - Initialize victory condition tracking
'============================================================================
' Description:
'   Initializes all end game condition flags to zero. Called at game start.
'   Victory conditions are loaded from scenario data (NWSxxxx.INI files).
' Side Effects:
'   Resets endGameFlags array and endGameTriggered/endGameWinner variables
'============================================================================
SUB InitializeVictoryConditions
    DIM i AS INTEGER
    FOR i = 1 TO 5
        endGameFlags(i) = 0
    NEXT i
    endGameTriggered = 0
    endGameWinner = 0
END SUB

'============================================================================
' CheckEndGameConditions - Check if any end game condition is met
'============================================================================
' Returns:
'   INTEGER - Side that triggered condition (1=French, 2=Allies, 0=none)
' Description:
'   Checks all victory conditions (control, casualties, objectives, etc.)
'   Returns the side that has met an end game condition, or 0 if none met.
'============================================================================
FUNCTION CheckEndGameConditions% ()
    
    DIM i AS INTEGER
    DIM side AS INTEGER
    DIM totalCities AS INTEGER
    DIM totalIncome AS LONG
    DIM totalArmyStrength(1 TO 2) AS LONG
    DIM ratio AS SINGLE
    
    CheckEndGameConditions% = 0
    
    ' Condition 1: Time (Month & Year)
    IF endGameFlags(END_TIME) > 0 THEN
        IF gameState.year >= endGameFlags(END_TIME) THEN
            ' Check which side has more victory points
            IF GetGameStateVictory&(1) > GetGameStateVictory&(2) THEN
                CheckEndGameConditions% = 1
            ELSE
                CheckEndGameConditions% = 2
            END IF
            endGameTriggered = 1
            endGameWinner = CheckEndGameConditions%
            EXIT FUNCTION
        END IF
    END IF
    
    ' Condition 2: % Cities Controlled
    IF endGameFlags(END_CITIES) > 0 THEN
        totalCities = GetGameStateControl%(1) + GetGameStateControl%(2)
        IF totalCities > 0 THEN
            FOR side = 1 TO 2
                ratio = (GetGameStateControl%(side) / totalCities) * PERCENTAGE_MULTIPLIER
                IF ratio >= endGameFlags(END_CITIES) THEN
                    CheckEndGameConditions% = side
                    endGameTriggered = 1
                    endGameWinner = side
                    EXIT FUNCTION
                END IF
            NEXT side
        END IF
    END IF
    
    ' Condition 3: % Income
    IF endGameFlags(END_INCOME) > 0 THEN
        totalIncome = GetGameStateIncome&(1) + GetGameStateIncome&(2)
        IF totalIncome > 0 THEN
            FOR side = 1 TO 2
                ratio = (GetGameStateIncome&(side) / totalIncome) * PERCENTAGE_MULTIPLIER
                IF ratio >= endGameFlags(END_INCOME) THEN
                    CheckEndGameConditions% = side
                    endGameTriggered = 1
                    endGameWinner = side
                    EXIT FUNCTION
                END IF
            NEXT side
        END IF
    END IF
    
    ' Condition 4: Objective Capture
    IF endGameFlags(END_OBJECTIVE) > 0 THEN
        ' Check if all objectives captured by one side
        ' This will be implemented based on objective city tracking
        ' Placeholder for now
    END IF
    
    ' Condition 5: Total Army Strength Ratio
    IF endGameFlags(END_ARMY_RATIO) > 0 THEN
        totalArmyStrength(1) = GetArmyStrength&(1)
        totalArmyStrength(2) = GetArmyStrength&(2)
        
        IF totalArmyStrength(1) + totalArmyStrength(2) > 0 THEN
            FOR side = 1 TO 2
                ratio = (totalArmyStrength(side) / (totalArmyStrength(1) + totalArmyStrength(2))) * PERCENTAGE_MULTIPLIER
                IF ratio >= endGameFlags(END_ARMY_RATIO) THEN
                    CheckEndGameConditions% = side
                    endGameTriggered = 1
                    endGameWinner = side
                    EXIT FUNCTION
                END IF
            NEXT side
        END IF
    END IF
END FUNCTION

'============================================================================
' AwardVictoryPoints - Award victory points to a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to award points to (1=French, 2=Allies)
'   amount (LONG) - Number of victory points to award
' Description:
'   Adds victory points to the specified side's total. Used for various
'   game events (battles, city captures, etc.).
'============================================================================
SUB AwardVictoryPoints (side AS INTEGER, amount AS LONG)
    ' Award victory points to side
    
    ' Validate input
    IF ValidateArmySide%(side, "AwardVictoryPoints") = 0 THEN
        EXIT SUB
    END IF
    
    CALL SetGameStateVictory(side, GetGameStateVictory&(side) + amount)
END SUB

'============================================================================
' AwardBattleVictory - Award victory points for winning a battle
'============================================================================
' Parameters:
'   side (INTEGER) - Side that won the battle (1=French, 2=Allies)
' Description:
'   Awards +1 victory point for winning a battle.
'============================================================================
SUB AwardBattleVictory (side AS INTEGER)
    ' Award victory points for winning battle
    ' +1 per battle won
    
    ' Validate input (AwardVictoryPoints will also validate, but validate here for consistency)
    IF ValidateArmySide%(side, "AwardBattleVictory") = 0 THEN
        EXIT SUB
    END IF
    
    AwardVictoryPoints side, 1
END SUB

'============================================================================
' AwardArmyCapture - Award victory points for capturing an army
'============================================================================
' Parameters:
'   side (INTEGER) - Side that captured the army (1=French, 2=Allies)
' Description:
'   Awards +25 victory points for capturing/destroying an enemy army.
'============================================================================
SUB AwardArmyCapture (side AS INTEGER)
    ' Award victory points for capturing army
    ' VICTORY_POINTS_ARMY_CAPTURE bonus
    
    ' Validate input (AwardVictoryPoints will also validate, but validate here for consistency)
    IF ValidateArmySide%(side, "AwardArmyCapture") = 0 THEN
        EXIT SUB
    END IF
    
    AwardVictoryPoints side, VICTORY_POINTS_ARMY_CAPTURE
END SUB

'============================================================================
' AwardEndGameBonus - Award end game bonus for triggering victory condition
'============================================================================
' Parameters:
'   side (INTEGER) - Side that triggered end condition (1=French, 2=Allies)
' Description:
'   Awards +100 victory points bonus when a side triggers an end game
'   condition (control, casualties, objectives, etc.).
'============================================================================
SUB AwardEndGameBonus (side AS INTEGER)
    ' Award end game bonus for triggering end condition
    ' +100 VP bonus
    
    ' Validate input (AwardVictoryPoints will also validate, but validate here for consistency)
    IF ValidateArmySide%(side, "AwardEndGameBonus") = 0 THEN
        EXIT SUB
    END IF
    
    AwardVictoryPoints side, END_GAME_BONUS
END SUB

'============================================================================
' GetVictoryPoints - Get total victory points for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to get points for (1=French, 2=Allies)
' Returns:
'   LONG - Total victory points for the side
'============================================================================
FUNCTION GetVictoryPoints& (side AS INTEGER)
    ' Get total victory points for side
    
    ' Validate input
    IF ValidateArmySide%(side, "GetVictoryPoints") = 0 THEN
        GetVictoryPoints& = 0
        EXIT FUNCTION
    END IF
    
    GetVictoryPoints& = GetGameStateVictory&(side)
END FUNCTION

'============================================================================
' SaveHighScore - Save high score to file
'============================================================================
' Parameters:
'   side (INTEGER) - Side that achieved the score (1=French, 2=Allies)
'   score (LONG) - Victory point score to save
' Description:
'   Saves a high score to the HISCORE.NWS file. Maintains a top 5 list of
'   highest scores. If the new score qualifies, it is inserted into the
'   appropriate position and lower scores are shifted down. Scores are saved
'   with the side name (French or Allies) for identification.
' Side Effects:
'   - Reads existing high scores from data\HISCORE.NWS
'   - Inserts new score if it qualifies for top 5
'   - Writes updated high score list to file
'   - Creates file if it doesn't exist
'============================================================================
SUB SaveHighScore (side AS INTEGER, score AS LONG)
    ' Save high score to HISCORE.NWS
    ' Top 5 scores recorded
    
    ' Validate input
    IF ValidateArmySide%(side, "SaveHighScore") = 0 THEN
        EXIT SUB
    END IF
    
    DIM filename AS STRING
    DIM scores(1 TO HIGH_SCORE_TOP_COUNT) AS LONG
    DIM names$(1 TO HIGH_SCORE_TOP_COUNT)
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM tempScore AS LONG
    DIM tempName AS STRING
    
    filename = "data\HISCORE.NWS"
    
    ' Load existing scores
    ' QB64-compatible file existence check
    IF _FILEEXISTS(filename) THEN
        ' Use SafeOpenFile% for error handling
        IF SafeOpenFile%(filename, "I", 1) = 1 THEN
            FOR i = 1 TO HIGH_SCORE_TOP_COUNT
                INPUT #1, names$(i), scores(i)
            NEXT i
            CLOSE #1
        ELSE
            ' File open failed - initialize empty scores
            FOR i = 1 TO HIGH_SCORE_TOP_COUNT
                names$(i) = "---"
                scores(i) = 0
            NEXT i
        END IF
    ELSE
        ' Initialize empty scores
        FOR i = 1 TO HIGH_SCORE_TOP_COUNT
            names$(i) = "---"
            scores(i) = 0
        NEXT i
    END IF
    
    ' Insert new score
    FOR i = 1 TO HIGH_SCORE_TOP_COUNT
        IF score > scores(i) THEN
            ' Shift scores down
            FOR j = HIGH_SCORE_TOP_COUNT TO i + 1 STEP -1
                scores(j) = scores(j - 1)
                names$(j) = names$(j - 1)
            NEXT j
            ' Insert new score
            scores(i) = score
            IF side = 1 THEN
                names$(i) = "French"
            ELSE
                names$(i) = "Allies"
            END IF
            EXIT FOR
        END IF
    NEXT i
    
    ' Save scores
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%(filename, "O", 1) = 1 THEN
        FOR i = 1 TO HIGH_SCORE_TOP_COUNT
            WRITE #1, names$(i), scores(i)
        NEXT i
        CLOSE #1
    ELSE
        ' File open failed - error already displayed by SafeOpenFile%
        ' High score not saved, but continue execution
    END IF
END SUB

