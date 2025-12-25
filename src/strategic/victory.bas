'============================================================================
' Victory Conditions System
'============================================================================
' Ported from CWS - 5 end game conditions
' Handles victory point tracking and end game conditions

' Note: game_types.bas is included in main.bas
' Note: End game condition constants are in declarations.bas
' Note: campaign.bas, army.bas, city.bas are included in main.bas

' Note: endGameFlags, endGameTriggered, endGameWinner are declared in declarations.bas

SUB InitializeVictoryConditions
    ' Initialize end game conditions from scenario data
    ' Format from NWSxxxx.INI will set these values
    DIM i AS INTEGER
    FOR i = 1 TO 5
        endGameFlags(i) = 0
    NEXT i
    endGameTriggered = 0
    endGameWinner = 0
END SUB

FUNCTION CheckEndGameConditions% ()
    ' Check all end game conditions
    ' Returns side that triggered condition (0 = none)
    
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
                ratio = (GetGameStateControl%(side) / totalCities) * 100
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
                ratio = (GetGameStateIncome&(side) / totalIncome) * 100
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
                ratio = (totalArmyStrength(side) / (totalArmyStrength(1) + totalArmyStrength(2))) * 100
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

SUB AwardVictoryPoints (side AS INTEGER, amount AS LONG)
    ' Award victory points to side
    CALL SetGameStateVictory(side, GetGameStateVictory&(side) + amount)
END SUB

SUB AwardBattleVictory (side AS INTEGER)
    ' Award victory points for winning battle
    ' +1 per battle won
    AwardVictoryPoints side, 1
END SUB

SUB AwardArmyCapture (side AS INTEGER)
    ' Award victory points for capturing army
    ' +25 bonus
    AwardVictoryPoints side, 25
END SUB

SUB AwardEndGameBonus (side AS INTEGER)
    ' Award end game bonus for triggering end condition
    ' +100 VP bonus
    AwardVictoryPoints side, 100
END SUB

FUNCTION GetVictoryPoints& (side AS INTEGER)
    ' Get total victory points for side
    GetVictoryPoints& = GetGameStateVictory&(side)
END FUNCTION

SUB SaveHighScore (side AS INTEGER, score AS LONG)
    ' Save high score to HISCORE.NWS
    ' Top 5 scores recorded
    
    DIM filename AS STRING
    DIM scores(1 TO 5) AS LONG
    DIM names$(1 TO 5)
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM tempScore AS LONG
    DIM tempName AS STRING
    
    filename = "HISCORE.NWS"
    
    ' Load existing scores
    IF FileExists%(filename) <> 0 THEN
        OPEN "I", 1, filename
        FOR i = 1 TO 5
            INPUT #1, names$(i), scores(i)
        NEXT i
        CLOSE #1
    ELSE
        ' Initialize empty scores
        FOR i = 1 TO 5
            names$(i) = "---"
            scores(i) = 0
        NEXT i
    END IF
    
    ' Insert new score
    FOR i = 1 TO 5
        IF score > scores(i) THEN
            ' Shift scores down
            FOR j = 5 TO i + 1 STEP -1
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
    OPEN "O", 1, filename
    FOR i = 1 TO 5
        WRITE #1, names$(i), scores(i)
    NEXT i
    CLOSE #1
END SUB

