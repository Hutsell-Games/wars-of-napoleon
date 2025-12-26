'============================================================================
' Reports System
'============================================================================
' Ported from CWS - 7 reports including History/Recap
' Handles all game reports and information displays

' Note: game_types.bas is included in main.bas
' Note: Report constants are in declarations.bas
' Note: campaign.bas, army.bas, city.bas are included in main.bas

' Note: battleWon, casualties, and historyFile are declared in declarations.bas

SUB InitializeReports
    ' Initialize report tracking
    DIM i AS INTEGER
    FOR i = 1 TO 2
        battleWon(i) = 0
        casualties(i) = 0
    NEXT i
    
    ' Initialize history file if enabled
    IF config_history = 1 THEN
        ' QB64-compatible file existence check
        IF _FILEEXISTS("NWS.HIS") THEN
            ' Backup old history
            SHELL "copy NWS.HIS oldhist.ory"
        END IF
        OPEN "O", 2, "NWS.HIS"
        PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
        CLOSE #2
    END IF
END SUB

'============================================================================
' ShowFriendlyArmyReport - Display friendly army status report
'============================================================================
' Parameters:
'   side (INTEGER) - Side to show report for (1=French, 2=Allies)
' Description:
'   Displays detailed report of friendly army units, including strength,
'   location, and status. Pauses for user input.
'============================================================================
SUB ShowFriendlyArmyReport (side AS INTEGER)
    ' Report 1: Friendly Army report
    ' Shows status of all friendly armies and game statistics
    
    CLS
    COLOR 15: PRINT "FRIENDLY ARMY REPORT - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM totalStrength AS LONG
    DIM totalSupply AS INTEGER
    DIM count AS INTEGER
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    totalStrength = 0
    totalSupply = 0
    count = 0
    
    PRINT "Army Name", "Strength", "Leader", "Exp", "Supply", "Location"
    PRINT STRING$(80, "-")
    
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 THEN
            count = count + 1
            totalStrength = totalStrength + armies(i).size
            totalSupply = totalSupply + armies(i).supply
            PRINT armies(i).name, armies(i).size, armies(i).lead, armies(i).exper, armies(i).supply, cities(armies(i).loc).name
        END IF
    NEXT i
    
    PRINT STRING$(80, "-")
    PRINT "Total Armies:"; count
    PRINT "Total Strength:"; totalStrength
    PRINT "Average Supply:"; totalSupply \ count
    PRINT
    PRINT "Cash:"; GetGameStateCash&(side)
    PRINT "Income:"; GetGameStateIncome&(side)
    PRINT "Victory Points:"; GetGameStateVictory&(side)
    PRINT "Cities Controlled:"; GetGameStateControl%(side)
    PRINT "Battles Won:"; battleWon(side)
    
    ' Show enemy strength if available
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    PRINT "Enemy Total Strength:"; GetArmyStrength(enemySide)
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowEnemyArmyReport (side AS INTEGER)
    ' Report 2: Enemy Army report
    ' Shows less complete information on enemy forces
    
    CLS
    COLOR 15: PRINT "ENEMY ARMY REPORT - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT
    
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    
    PRINT "Enemy Total Strength:"; GetArmyStrength(enemySide)
    PRINT "Enemy Cash:"; GetGameStateCash&(enemySide)
    PRINT "Enemy Income:"; GetGameStateIncome&(enemySide)
    PRINT "Enemy Victory Points:"; GetGameStateVictory&(enemySide)
    PRINT "Enemy Cities Controlled:"; GetGameStateControl%(enemySide)
    PRINT "Enemy Battles Won:"; battleWon(enemySide)
    PRINT "Enemy Fleet Size:"; fleets(enemySide).size
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowCityReport
    ' Report 3: City report
    ' Provides information on cities, their worth, status
    
    CLS
    COLOR 15: PRINT "CITY REPORT - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT
    
    PRINT "City Name", "Value", "Owner", "Fort", "Objective"
    PRINT STRING$(80, "-")
    
    DIM i AS INTEGER
    DIM ownerName AS STRING
    
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" THEN
            SELECT CASE cities(i).owner
                CASE CITY_FRENCH: ownerName = "French"
                CASE CITY_ALLIED: ownerName = "Allied"
                CASE CITY_NEUTRAL: ownerName = "Neutral"
                CASE CITY_AT_PEACE: ownerName = "At Peace"
                CASE ELSE: ownerName = "Unknown"
            END SELECT
            
            PRINT cities(i).name, cities(i).value, ownerName, cities(i).fort
            IF cities(i).objective = 1 THEN PRINT " *OBJECTIVE*"
        END IF
    NEXT i
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowForceSummary
    ' Report 4: Force summary
    ' Shows on map the strength of all armies (in 100's of men)
    ' Hot key F4 to access directly
    
    ' Draw strategic map with army strengths displayed
    CALL DrawStrategicMap
    
    ' Display title and legend
    COLOR 15 ' White
    LOCATE 1, 1
    PRINT "FORCE SUMMARY - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT "Army strengths shown in hundreds of men"
    PRINT "Blue = French, Red = Allied"
    PRINT "Press any key to continue..."
    
    ' Wait for user input
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowIntelligenceReport (side AS INTEGER)
    ' Report 5: Intelligence report
    ' Provides on-map summary of attributes of all FRIENDLY armies
    
    CLS
    COLOR 15: PRINT "INTELLIGENCE REPORT - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    PRINT "Army", "Strength", "Leadership", "Experience", "Supply", "Location"
    PRINT STRING$(80, "-")
    
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 THEN
            PRINT armies(i).name, armies(i).size, armies(i).lead, armies(i).exper, armies(i).supply, cities(armies(i).loc).name
        END IF
    NEXT i
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowBattleSummary
    ' Report 6: Battle Summary report
    ' Shows number of battles won and casualties incurred for each side
    
    CLS
    COLOR 15: PRINT "BATTLE SUMMARY - "; GetCurrentMonth$
    PRINT STRING$(80, "-")
    PRINT
    
    PRINT "Side", "Battles Won", "Total Casualties"
    PRINT STRING$(80, "-")
    PRINT "French", battleWon(1), casualties(1)
    PRINT "Allies", battleWon(2), casualties(2)
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
' ShowRecapReport - Display game history/recap report
'============================================================================
' Description:
'   Displays the game history file (NWS.HIS) containing all battle summaries
'   and major events. Allows user to scroll through history.
' Side Effects:
'   Reads from NWS.HIS file (checks for existence first)
'============================================================================
SUB ShowRecapReport
    ' Report 7: Recap report (History)
    ' Available only if HISTORY option is ON
    ' Scrolls through chronicle of game history
    
    IF config_history = 0 THEN
        CALL ShowStatusMessage("History option is disabled", 11)
        EXIT SUB ' Not an error - feature disabled
    END IF
    
    IF FileExists%("NWS.HIS") = 0 THEN
        CALL HandleFileNotFound("NWS.HIS")
        EXIT SUB
    END IF
    
    CLS
    COLOR 15: PRINT "RECAP/HISTORY REPORT"
    PRINT STRING$(80, "-")
    PRINT
    
    DIM lineText AS STRING
    
    OPEN "I", 1, "NWS.HIS"
    DO WHILE NOT EOF(1)
        LINE INPUT #1, lineText
        PRINT lineText
        IF INKEY$ <> "" THEN EXIT DO ' Allow early exit
    LOOP
    CLOSE #1
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
' RecordBattleHistory - Record battle result to history file
'============================================================================
' Parameters:
'   attackerName (STRING) - Name of attacking army/commander
'   attackerStrength (LONG) - Total strength of attacker
'   attackerCasualties (LONG) - Casualties suffered by attacker
'   defenderName (STRING) - Name of defending army/commander
'   defenderStrength (LONG) - Total strength of defender
'   defenderCasualties (LONG) - Casualties suffered by defender
'   cityName (STRING) - Name of city where battle occurred (empty if no city)
' Description:
'   Records battle summary to history file (NWS.HIS) and battle summary file (BATTSUMM).
'   Only records if history is enabled in configuration.
' Side Effects:
'   Appends to NWS.HIS and BATTSUMM files
'============================================================================
SUB RecordBattleHistory (attackerName AS STRING, attackerStrength AS LONG, attackerCasualties AS LONG, _
                         defenderName AS STRING, defenderStrength AS LONG, defenderCasualties AS LONG, _
                         winnerName AS STRING, cityName AS STRING)
    ' Record battle in history file
    ' Format: City *Attacker (casualties/total) defeats Defender (casualties/total)
    
    IF config_history = 0 THEN EXIT SUB
    
    DIM entry AS STRING
    entry = cityName + " *" + attackerName + " (" + LTRIM$(STR$(attackerCasualties)) + "/" + LTRIM$(STR$(attackerStrength)) + _
            ") defeats " + defenderName + " (" + LTRIM$(STR$(defenderCasualties)) + "/" + LTRIM$(STR$(defenderStrength)) + ")"
    
    OPEN "A", 2, "NWS.HIS"
    PRINT #2, entry
    CLOSE #2
    
    ' Also update BATTSUMM file
    OPEN "A", 3, "data\BATTSUMM"
    PRINT #3, entry
    CLOSE #3
END SUB

SUB UpdateBattleStats (winnerSide AS INTEGER, casualties1 AS LONG, casualties2 AS LONG)
    ' Update battle statistics
    battleWon(winnerSide) = battleWon(winnerSide) + 1
    casualties(1) = casualties(1) + casualties1
    casualties(2) = casualties(2) + casualties2
END SUB

