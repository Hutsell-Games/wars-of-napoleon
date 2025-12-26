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

SUB AssignCityNationality (cityIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to city (read from EUROxxxx.MAP)
    cities(cityIndex).nationality = nationality
END SUB

SUB AssignArmyNationality (armyIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to army (based on recruitment city)
    armies(armyIndex).nationality = nationality
END SUB

SUB AssignCommanderNationality (commanderIndex AS INTEGER, nationality AS INTEGER)
    ' Assign nationality to commander (read from LEADxxxx.DAT)
    ' Commander nationality is set when loading commander data
    IF commanderIndex >= 1 AND commanderIndex <= 50 THEN
        commanders(commanderIndex).nationality = nationality
    END IF
END SUB

FUNCTION CheckCohesion% (armyIndex AS INTEGER)
    ' Check if army has cohesion penalty
    ' Returns 1 if penalty applies (commander nationality <> army nationality)
    ' Returns 0 if no penalty
    
    DIM commanderNationality AS INTEGER
    DIM armyNationality AS INTEGER
    
    IF armies(armyIndex).size = 0 THEN
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

FUNCTION GetCommanderNationality% (armyIndex AS INTEGER)
    ' Get nationality of commander for army
    ' Looks up commander nationality from commander array based on army name
    
    DIM commanderName AS STRING
    DIM commanderIndex AS INTEGER
    DIM i AS INTEGER
    
    IF armies(armyIndex).size = 0 THEN
        GetCommanderNationality% = 0
        EXIT FUNCTION
    END IF
    
    commanderName = armies(armyIndex).name
    
    ' Find commander in array by name
    commanderIndex = 0
    FOR i = 1 TO 50
        IF UCASE$(commanders(i).name) = UCASE$(commanderName) THEN
            commanderIndex = i
            EXIT FOR
        END IF
    NEXT i
    
    IF commanderIndex > 0 THEN
        GetCommanderNationality% = commanders(commanderIndex).nationality
    ELSE
        ' Commander not found, return army nationality (no penalty)
        GetCommanderNationality% = armies(armyIndex).nationality
    END IF
END FUNCTION

FUNCTION ApplyCohesionPenalty! (armyIndex AS INTEGER, baseEffectiveness AS SINGLE)
    ' Apply cohesion penalty to combat effectiveness
    ' Out of cohesion = reduced effectiveness
    
    DIM penalty AS SINGLE
    
    IF CheckCohesion%(armyIndex) = 1 THEN
        penalty = 0.75 ' 25% reduction in effectiveness
        ApplyCohesionPenalty! = baseEffectiveness * penalty
    ELSE
        ApplyCohesionPenalty! = baseEffectiveness
    END IF
END FUNCTION

SUB DisplayCohesionStatus (armyIndex AS INTEGER)
    ' Display cohesion status in combat statistics
    ' Show penalty in contrasting color if cohesion issue
    
    IF CheckCohesion%(armyIndex) = 1 THEN
        COLOR 12 ' Red for penalty
        PRINT armies(armyIndex).name; " - COHESION PENALTY"
        COLOR 7 ' Reset to normal
    END IF
END SUB

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

FUNCTION IsAtPeace% (nationality AS INTEGER)
    ' Check if country is at peace
    IsAtPeace% = 0
    IF alliedAtWar(nationality) = 0 THEN
        IsAtPeace% = 1
    END IF
END FUNCTION

FUNCTION CanRecruitInCity% (cityIndex AS INTEGER)
    ' Check if recruitment allowed in city
    ' At-peace countries cannot recruit
    
    DIM nationality AS INTEGER
    nationality = cities(cityIndex).nationality
    
    IF IsAtPeace%(nationality) = 1 THEN
        CanRecruitInCity% = 0 ' Cannot recruit
    ELSE
        CanRecruitInCity% = 1 ' Can recruit
    END IF
END FUNCTION

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

SUB FixCohesionWithRelieve (armyIndex AS INTEGER, newCommanderName AS STRING, newCommanderNationality AS INTEGER, newCommanderRating AS INTEGER)
    ' Fix cohesion by using RELIEVE command
    ' Swaps commander to match army nationality
    
    ' Check if new commander matches army nationality
    IF newCommanderNationality = armies(armyIndex).nationality THEN
        ' Use RELIEVE command
        RelieveCommander armyIndex, newCommanderName, newCommanderRating
        CALL ShowStatusMessage("Cohesion fixed - commander nationality now matches army", 11)
    ELSE
        CALL ShowStatusWarning("New commander nationality does not match army")
    END IF
END SUB

