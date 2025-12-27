'============================================================================
' Reports System
'============================================================================
' Ported from CWS - 7 reports including History/Recap
' Handles all game reports and information displays

' Note: game_types.bas is included in main.bas
' Note: Report constants are in declarations.bas
' Note: campaign.bas, army.bas, city.bas are included in main.bas

' Note: battleWon, casualties, and historyFile are declared in declarations.bas

'============================================================================
' InitializeReports - Initialize report tracking and history file
'============================================================================
' Description:
'   Initializes the reports system by resetting battle statistics (battles
'   won and casualties) for both sides. If history tracking is enabled in
'   configuration, creates or backs up the history file (NWS.HIS) and
'   writes a header with the game start date.
' Side Effects:
'   - Resets battleWon and casualties arrays
'   - Creates or backs up NWS.HIS file if history enabled
'============================================================================
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
        ' Use SafeOpenFile% for error handling
        IF SafeOpenFile%("NWS.HIS", "O", 2) = 1 THEN
            PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
            CLOSE #2
        ELSE
            ' File open failed - error already displayed by SafeOpenFile%
            ' Continue without history file
        END IF
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
        IF IsArmyActive%(i) = 1 THEN
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

'============================================================================
' ShowEnemyArmyReport - Display enemy army status report
'============================================================================
' Parameters:
'   side (INTEGER) - Side requesting report (1=French, 2=Allies)
' Description:
'   Displays summary information about enemy forces. Shows less detailed
'   information than friendly reports, including total strength, cash,
'   income, victory points, cities controlled, battles won, and fleet size.
'   Pauses for user input.
'============================================================================
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

'============================================================================
' ShowCityReport - Display city status report
'============================================================================
' Description:
'   Displays information about all cities, including name, value (income),
'   owner (French/Allied/Neutral/At Peace), fortification level, and
'   objective status. Provides an overview of territorial control and
'   economic resources. Pauses for user input.
'============================================================================
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
        IF IsCityActive%(i) = 1 THEN
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

'============================================================================
' ShowForceSummary - Display force summary on strategic map
'============================================================================
' Description:
'   Displays the strategic map with army strengths shown in hundreds of men.
'   Provides a visual overview of force distribution across the map. Army
'   strengths are color-coded (Blue = French, Red = Allied). Accessible
'   via hot key F4. Pauses for user input.
' Side Effects:
'   - Draws strategic map with army strength overlays
'============================================================================
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

'============================================================================
' ShowIntelligenceReport - Display detailed intelligence report for friendly armies
'============================================================================
' Parameters:
'   side (INTEGER) - Side to show report for (1=French, 2=Allies)
' Description:
'   Displays detailed attributes of all friendly armies including strength,
'   leadership rating, experience level, supply status, and current location.
'   Provides comprehensive intelligence for strategic planning. Pauses for
'   user input.
'============================================================================
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
        IF IsArmyActive%(i) = 1 THEN
            PRINT armies(i).name, armies(i).size, armies(i).lead, armies(i).exper, armies(i).supply, cities(armies(i).loc).name
        END IF
    NEXT i
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
' ShowBattleSummary - Display battle summary statistics
'============================================================================
' Description:
'   Displays summary statistics of battles fought, showing the number of
'   battles won and total casualties incurred for each side (French and
'   Allies). Provides an overview of military performance throughout
'   the game. Pauses for user input.
'============================================================================
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
    
    IF NOT _FILEEXISTS("NWS.HIS") THEN
        CALL HandleFileNotFound("NWS.HIS")
        EXIT SUB
    END IF
    
    CLS
    COLOR 15: PRINT "RECAP/HISTORY REPORT"
    PRINT STRING$(80, "-")
    PRINT
    
    DIM lineText AS STRING
    
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%("NWS.HIS", "I", 1) = 1 THEN
        DO WHILE NOT EOF(1)
            LINE INPUT #1, lineText
            PRINT lineText
            IF INKEY$ <> "" THEN EXIT DO ' Allow early exit
        LOOP
        CLOSE #1
    ELSE
        ' File open failed - error already displayed by SafeOpenFile%
        CALL ShowStatusMessage("Could not read history file", 12)
    END IF
    
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
    
    ' Use SafeOpenFile% for error handling
    IF SafeOpenFile%("NWS.HIS", "A", 2) = 1 THEN
        PRINT #2, entry
        CLOSE #2
    ELSE
        ' File open failed - error already displayed by SafeOpenFile%
        ' Continue without recording to history
    END IF
    
    ' Also update BATTSUMM file
    IF SafeOpenFile%("data\BATTSUMM", "A", 3) = 1 THEN
        PRINT #3, entry
        CLOSE #3
    ELSE
        ' File open failed - error already displayed by SafeOpenFile%
        ' Continue without recording to battle summary
    END IF
END SUB

'============================================================================
' UpdateBattleStats - Update battle statistics after combat
'============================================================================
' Parameters:
'   winnerSide (INTEGER) - Side that won the battle (1=French, 2=Allies)
'   casualties1 (LONG) - Casualties for side 1
'   casualties2 (LONG) - Casualties for side 2
' Description:
'   Updates battle statistics after a combat resolution. Increments the
'   battle win count for the winning side and adds casualties to the
'   cumulative totals for both sides. Used for tracking military
'   performance throughout the game.
' Side Effects:
'   - Increments battleWon(winnerSide)
'   - Adds casualties to casualties(1) and casualties(2)
'============================================================================
SUB UpdateBattleStats (winnerSide AS INTEGER, casualties1 AS LONG, casualties2 AS LONG)
    ' Update battle statistics
    battleWon(winnerSide) = battleWon(winnerSide) + 1
    casualties(1) = casualties(1) + casualties1
    casualties(2) = casualties(2) + casualties2
END SUB

