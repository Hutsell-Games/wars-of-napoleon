'============================================================================
' Cohesion System
'============================================================================
' UNIQUE TO WON - Nationality-based combat penalties
' Handles nationality assignment, cohesion checks, allied country system

' Note: game_types.bas is included in main.bas
' Note: Nationality constants are in declarations.bas
' Note: army.bas, city.bas are included in main.bas

' Note: alliedAtWar is declared in declarations.bas
' 1=French, 2=Austrian, 3=English, 4=Russian, 5=Prussian, 6=Spanish

'============================================================================
' InitializeCohesion - Initialize cohesion system and allied country status
'============================================================================
' Description:
'   Initializes the cohesion system by setting the war status for each
'   nationality. French and English typically start at war, while other
'   countries (Austrian, Russian, Prussian, Spanish) may start at peace
'   and activate when invaded. This affects recruitment and income.
' Side Effects:
'   - Initializes alliedAtWar array with default war/peace status
'============================================================================
SUB InitializeCohesion
    ' Initialize cohesion system
    DIM i AS INTEGER
    
    ' Initialize allied country status
    ' French start at war, others may start at peace
    alliedAtWar(NAT_FRENCH) = 1 ' French always at war
    alliedAtWar(NAT_AUSTRIAN) = 0 ' May start at peace
    alliedAtWar(NAT_ENGLISH) = 1 ' Usually at war
    alliedAtWar(NAT_RUSSIAN) = 0 ' May start at peace
    alliedAtWar(NAT_PRUSSIAN) = 0 ' May start at peace
    alliedAtWar(NAT_SPANISH) = 0 ' May start at peace
END SUB

'============================================================================
' AssignCityNationality - Assign nationality to a city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city
'   nationality (INTEGER) - Nationality code to assign
' Description:
'   Assigns a nationality to a city. This is typically set when loading
'   scenario data from EUROxxxx.MAP files. City nationality affects
'   recruitment restrictions and cohesion calculations.
' Side Effects:
'   - Sets cities(cityIndex).nationality
'============================================================================
SUB AssignCityNationality (cityIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to city (read from EUROxxxx.MAP)
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "AssignCityNationality") = 0 THEN
        EXIT SUB
    END IF
    
    cities(cityIndex).nationality = nationality
END SUB

'============================================================================
' AssignArmyNationality - Assign nationality to an army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
'   nationality (INTEGER) - Nationality code to assign
' Description:
'   Assigns a nationality to an army based on the city where it was
'   recruited. Army nationality is used for cohesion checks - armies
'   with commanders of different nationalities suffer combat penalties.
' Side Effects:
'   - Sets armies(armyIndex).nationality
'============================================================================
SUB AssignArmyNationality (armyIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to army (based on recruitment city)
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "AssignArmyNationality") = 0 THEN
        EXIT SUB
    END IF
    
    armies(armyIndex).nationality = nationality
END SUB

'============================================================================
' AssignCommanderNationality - Assign nationality to a commander
'============================================================================
' Parameters:
'   commanderIndex (INTEGER) - Index of commander
'   nationality (INTEGER) - Nationality code to assign
' Description:
'   Assigns a nationality to a commander. This is typically set when
'   loading commander data from LEADxxxx.DAT files. Commander nationality
'   is compared with army nationality to determine cohesion penalties.
' Side Effects:
'   - Sets commanders(commanderIndex).nationality
'============================================================================
SUB AssignCommanderNationality (commanderIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to commander (read from LEADxxxx.DAT)
    ' Commander nationality is set when loading commander data
    IF ValidateCommanderIndex%(commanderIndex, "AssignCommanderNationality") = 1 THEN
        commanders(commanderIndex).nationality = nationality
    END IF
END SUB

'============================================================================
' CheckCohesion - Check if army has cohesion penalty
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to check
' Returns:
'   INTEGER - 1 if cohesion penalty applies, 0 if no penalty
' Description:
'   Checks if an army has a cohesion penalty by comparing the commander's
'   nationality with the army's nationality. A penalty applies when they
'   don't match, representing command and communication difficulties.
'   Returns 0 if no penalty (nationalities match or army inactive).
'============================================================================
FUNCTION CheckCohesion% (armyIndex AS INTEGER)
    ' Check if army has cohesion penalty
    ' Returns 1 if penalty applies (commander nationality <> army nationality)
    ' Returns 0 if no penalty
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "CheckCohesion") = 0 THEN
        CheckCohesion% = 0
        EXIT FUNCTION
    END IF
    
    DIM commanderNationality AS INTEGER
    DIM armyNationality AS INTEGER
    
    IF IsArmyActive%(armyIndex) = 0 THEN
        CheckCohesion% = 0
        EXIT FUNCTION
    END IF
    
    armyNationality = armies(armyIndex).nationality
    
    ' Get commander nationality from commander array
    commanderNationality = GetCommanderNationality%(armyIndex)
    
    IF commanderNationality <> armyNationality THEN
        CheckCohesion% = 1 ' Penalty applies
    ELSE
        CheckCohesion% = 0 ' No penalty
    END IF
END FUNCTION

'============================================================================
' GetCommanderNationality - Get nationality of commander for an army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
' Returns:
'   INTEGER - Nationality code of the commander, or army nationality if not found
' Description:
'   Looks up the commander's nationality from the commanders array by
'   matching the army's commander name. If the commander is not found,
'   returns the army's nationality (no penalty). Used for cohesion checks.
'============================================================================
FUNCTION GetCommanderNationality% (armyIndex AS INTEGER)
    ' Get nationality of commander for army
    ' Looks up commander nationality from commander array based on army name
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "GetCommanderNationality") = 0 THEN
        GetCommanderNationality% = 0
        EXIT FUNCTION
    END IF
    
    DIM commanderName AS STRING
    DIM commanderIndex AS INTEGER
    DIM i AS INTEGER
    
    IF IsArmyActive%(armyIndex) = 0 THEN
        GetCommanderNationality% = 0
        EXIT FUNCTION
    END IF
    
    commanderName = armies(armyIndex).name
    
    ' Find commander in array by name
    commanderIndex = 0
    FOR i = 1 TO MAX_COMMANDERS
        ' Validate commander index before accessing commanders array
        IF ValidateCommanderIndex%(i, "GetCommanderNationality - search") = 1 THEN
            IF UCASE$(commanders(i).name) = UCASE$(commanderName) THEN
                commanderIndex = i
                EXIT FOR
            END IF
        END IF
    NEXT i
    
    IF ValidateCommanderIndex%(commanderIndex, "GetCommanderNationality - result") = 1 THEN
        GetCommanderNationality% = commanders(commanderIndex).nationality
    ELSE
        ' Commander not found, return army nationality (no penalty)
        GetCommanderNationality% = armies(armyIndex).nationality
    END IF
END FUNCTION

'============================================================================
' ApplyCohesionPenalty - Apply cohesion penalty to combat effectiveness
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
'   baseEffectiveness (SINGLE) - Base combat effectiveness before penalty
' Returns:
'   SINGLE - Modified effectiveness after applying cohesion penalty
' Description:
'   Applies a cohesion penalty to combat effectiveness if the army's
'   commander nationality doesn't match the army's nationality. The penalty
'   reduces effectiveness by 25% (COHESION_PENALTY_MULTIPLIER). Returns
'   base effectiveness unchanged if no penalty applies.
'============================================================================
FUNCTION ApplyCohesionPenalty! (armyIndex AS INTEGER, baseEffectiveness AS SINGLE)
    ' Apply cohesion penalty to combat effectiveness
    ' Out of cohesion = reduced effectiveness
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "ApplyCohesionPenalty") = 0 THEN
        ApplyCohesionPenalty! = baseEffectiveness
        EXIT FUNCTION
    END IF
    
    DIM penalty AS SINGLE
    
    IF CheckCohesion%(armyIndex) = 1 THEN
        penalty = COHESION_PENALTY_MULTIPLIER ' 25% reduction in effectiveness
        ApplyCohesionPenalty! = baseEffectiveness * penalty
    ELSE
        ApplyCohesionPenalty! = baseEffectiveness
    END IF
END FUNCTION

'============================================================================
' DisplayCohesionStatus - Display cohesion status in combat statistics
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to display status for
' Description:
'   Displays the cohesion status of an army in combat reports. If a
'   cohesion penalty applies (commander and army nationalities don't match),
'   displays a warning message in red to highlight the penalty.
' Side Effects:
'   - Displays text to screen if cohesion penalty exists
'============================================================================
SUB DisplayCohesionStatus (armyIndex AS INTEGER)
    ' Display cohesion status in combat statistics
    ' Show penalty in contrasting color if cohesion issue
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "DisplayCohesionStatus") = 0 THEN
        EXIT SUB
    END IF
    
    IF CheckCohesion%(armyIndex) = 1 THEN
        COLOR 12 ' Red for penalty
        PRINT armies(armyIndex).name; " - COHESION PENALTY"
        COLOR 7 ' Reset to normal
    END IF
END SUB

'============================================================================
' ActivateAlliedCountry - Activate allied country when invaded by France
'============================================================================
' Parameters:
'   nationality (INTEGER) - Nationality to activate
' Description:
'   Activates an allied country when it is invaded by France, changing its
'   status from at-peace to at-war. This allows the country to recruit
'   armies and generate income. Also updates city ownership for the
'   activated nationality. French nationality cannot be activated.
' Side Effects:
'   - Sets alliedAtWar(nationality) = 1
'   - Updates city ownership for activated nationality
'   - Displays activation message
'============================================================================
SUB ActivateAlliedCountry (nationality AS INTEGER)
    ' Activate allied country when invaded by France
    ' Changes status from at-peace to at-war
    
    IF nationality = NAT_FRENCH THEN EXIT SUB ' French don't activate
    
    IF alliedAtWar(nationality) = 0 THEN
        alliedAtWar(nationality) = 1
        COLOR 11: CALL clrbot: PRINT GetNationalityName$(nationality); " enters the war!"
        
        ' Update city ownership for activated country
        ' Cities change from at-peace (green) to allied (red)
        UpdateCityOwnershipForNationality nationality
    END IF
END SUB

'============================================================================
' UpdateCityOwnershipForNationality - Update city ownership when country activates
'============================================================================
' Parameters:
'   nationality (INTEGER) - Nationality of country being activated
' Description:
'   Updates city ownership when a country activates (changes from at-peace
'   to at-war). Cities belonging to the activated nationality change from
'   CITY_AT_PEACE (green) to CITY_ALLIED (red) status, making them active
'   in the game.
' Side Effects:
'   - Updates cities(i).owner for cities of the specified nationality
'============================================================================
SUB UpdateCityOwnershipForNationality (nationality AS INTEGER)
    ' Update city ownership when country activates
    ' Changes cities from at-peace to allied control
    
    DIM i AS INTEGER
    FOR i = 1 TO MAX_CITIES
        IF cities(i).nationality = nationality AND cities(i).owner = CITY_AT_PEACE THEN
            cities(i).owner = CITY_ALLIED
        END IF
    NEXT i
END SUB

'============================================================================
' IsAtPeace - Check if a country is at peace
'============================================================================
' Parameters:
'   nationality (INTEGER) - Nationality code to check
' Returns:
'   INTEGER - 1 if country is at peace, 0 if at war
' Description:
'   Checks if a country is currently at peace (not activated). At-peace
'   countries cannot recruit armies and generate no income. Countries
'   activate when invaded by France.
'============================================================================
FUNCTION IsAtPeace% (nationality AS INTEGER)
    ' Check if country is at peace
    IsAtPeace% = 0
    IF alliedAtWar(nationality) = 0 THEN
        IsAtPeace% = 1
    END IF
END FUNCTION

'============================================================================
' CanRecruitInCity - Check if recruitment allowed in city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to check
'   side (INTEGER) - Side attempting to recruit (1=French, 2=Allies)
' Returns:
'   INTEGER - 1 if recruitment allowed, 0 if not allowed
' Description:
'   Checks if recruitment is allowed in a city. At-peace countries cannot
'   recruit armies, so recruitment is blocked in cities belonging to
'   nationalities that are currently at peace. In realism mode, also checks
'   if the city was originally owned by the recruiting side. Returns 0 if
'   city index is invalid.
' Side Effects:
'   None
'============================================================================
FUNCTION CanRecruitInCity% (cityIndex AS INTEGER, side AS INTEGER)
    ' Check if recruitment allowed in city
    ' At-peace countries cannot recruit
    ' Realism mode: Only originally friendly/neutral cities
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "CanRecruitInCity") = 0 THEN
        CanRecruitInCity% = 0
        EXIT FUNCTION
    END IF
    
    IF side < 1 OR side > 2 THEN
        CanRecruitInCity% = 0
        EXIT FUNCTION
    END IF
    
    DIM nationality AS INTEGER
    nationality = cities(cityIndex).nationality
    
    IF IsAtPeace%(nationality) = 1 THEN
        CanRecruitInCity% = 0 ' Cannot recruit
        EXIT FUNCTION
    END IF
    
    ' Check realism mode restrictions
    IF realismMode = 1 THEN
        IF CanRecruitInCityRealism%(cityIndex, cities(), side, realismMode) = 0 THEN
            CanRecruitInCity% = 0
            EXIT FUNCTION
        END IF
    END IF
    
    CanRecruitInCity% = 1 ' Can recruit
END FUNCTION

'============================================================================
' GetCityIncomeForNationality - Get income for a nationality
'============================================================================
' Parameters:
'   nationality (INTEGER) - Nationality code to calculate income for
' Returns:
'   LONG - Total income from cities of this nationality, or 0 if at peace
' Description:
'   Calculates the total income generated by cities belonging to a specific
'   nationality. At-peace countries generate no income (returns 0).
'   Only counts cities that are not neutral (owned by some side).
'============================================================================
FUNCTION GetCityIncomeForNationality& (nationality AS INTEGER)
    ' Get income for nationality
    ' At-peace countries generate no income
    
    IF IsAtPeace%(nationality) = 1 THEN
        GetCityIncomeForNationality& = 0
        EXIT FUNCTION
    END IF
    
    DIM i AS INTEGER
    DIM total AS LONG
    
    total = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).nationality = nationality AND cities(i).owner <> CITY_NEUTRAL THEN
            total = total + cities(i).value
        END IF
    NEXT i
    
    GetCityIncomeForNationality& = total
END FUNCTION

'============================================================================
' GetNationalityName - Get name of nationality
'============================================================================
' Parameters:
'   nationality (INTEGER) - Nationality code
' Returns:
'   STRING - Name of nationality (e.g., "French", "Austrian", "English")
' Description:
'   Returns the human-readable name for a nationality code. Used for
'   display purposes in reports and messages. Returns "Unknown" for
'   invalid nationality codes.
'============================================================================
FUNCTION GetNationalityName$ (nationality AS INTEGER)
    ' Get name of nationality
    SELECT CASE nationality
        CASE NAT_FRENCH: GetNationalityName$ = "French"
        CASE NAT_AUSTRIAN: GetNationalityName$ = "Austrian"
        CASE NAT_ENGLISH: GetNationalityName$ = "English"
        CASE NAT_RUSSIAN: GetNationalityName$ = "Russian"
        CASE NAT_PRUSSIAN: GetNationalityName$ = "Prussian"
        CASE NAT_SPANISH: GetNationalityName$ = "Spanish"
        CASE ELSE: GetNationalityName$ = "Unknown"
    END SELECT
END FUNCTION

'============================================================================
' FixCohesionWithRelieve - Fix cohesion by using RELIEVE command
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to fix cohesion for
'   newCommanderName (STRING) - Name of new commander
'   newCommanderNationality (INTEGER) - Nationality of new commander
'   newCommanderRating (INTEGER) - Leadership rating of new commander
' Description:
'   Fixes cohesion issues by replacing the army's commander with one that
'   matches the army's nationality. Uses the RELIEVE command to swap
'   commanders, which applies a -1 penalty to experience and leadership.
'   Only proceeds if the new commander's nationality matches the army's.
' Side Effects:
'   - Calls RelieveCommander to swap commanders
'   - Displays status message indicating cohesion fixed
'============================================================================
SUB FixCohesionWithRelieve (armyIndex AS INTEGER, newCommanderName AS STRING, newCommanderNationality AS INTEGER, newCommanderRating AS INTEGER)
    ' Fix cohesion by using RELIEVE command
    ' Swaps commander to match army nationality
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "FixCohesionWithRelieve") = 0 THEN
        EXIT SUB
    END IF
    
    ' Check if new commander matches army nationality
    IF newCommanderNationality = armies(armyIndex).nationality THEN
        ' Use RELIEVE command
        RelieveCommander armyIndex, newCommanderName, newCommanderRating
        ' Cohesion changed - invalidate combat strength cache (cohesion affects combat strength)
        CALL InvalidateCombatStrengthCache(armyIndex)
        CALL ShowStatusMessage("Cohesion fixed - commander nationality now matches army", 11)
    ELSE
        CALL ShowStatusWarning("New commander nationality does not match army")
    END IF
END SUB

