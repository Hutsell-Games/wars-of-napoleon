'============================================================================
' Tactical Battle Module - Refactored
'============================================================================
' Refactored from NAPOLEON.BAS
' Modern unified approach: Direct function call instead of file I/O + process spawning
' Removed: File I/O (battle.$$$), Process spawning (SHELL), File output (outcome.&&&)
' Added: Function parameters, Return values

' Note: battle_types.bas is included in main.bas
' TODO: Include nap10.bi when NAPOLEON.BAS is integrated
' Removed: $INCLUDE: 'nap10.bi' ' Original include file from NAPOLEON.BAS (not yet available)

' Note: This is a wrapper function that will call the refactored NAPOLEON.BAS code
' The actual tactical battle implementation will be integrated from NAPOLEON.BAS
' For now, this provides the interface and placeholder implementation

'============================================================================
' LaunchTacticalBattle - Launch and execute tactical battle
'============================================================================
' INTEGRATION POINT: Strategic → Tactical
' This is the main entry point from strategic layer to tactical battle system
'
' DATA CONVERSION:
' - Receives BattleData structure from strategic layer
' - Converts to internal tactical format (sidex, vp&, commander$, etc.)
' - Army strengths are in hundreds (e.g., 50 = 5000 men)
' - Returns BattleResult structure with winner and casualties
'
' INITIALIZATION SEQUENCE:
' 1. Validate battle data parameters
' 2. Load tactical configuration (arrays, defaults)
' 3. Load equipment data (non-critical, can fail gracefully)
' 4. Load graphics icons (CRITICAL - must succeed)
' 5. Generate random battle map (CRITICAL - must succeed)
' 6. Initialize armies and units
' 7. Run tactical battle loop
' 8. Calculate casualties and return results
'
' ERROR HANDLING:
' - Critical failures (iconload, randmap, randarm) → result.winner = 0
' - Non-critical failures (equip.dat, config) → warnings, continue
' - All errors use standardized error handling functions
'
' Parameters:
'   battleData (BattleData) - Input battle data containing:
'     - scenario (STRING): Scenario name
'     - side (INTEGER): Current side (1=French, 2=Allies)
'     - sideID1, sideID2 (INTEGER): Side identifiers
'     - commander1, commander2 (STRING): Commander names
'     - strength1, strength2 (LONG): Army strengths
'     - leader1, leader2 (INTEGER): Leader ratings
'     - experience1, experience2 (INTEGER): Experience levels
'     - difficulty (INTEGER): Battle difficulty
'     - fortifications (INTEGER): Fortification level
'     - quiet (INTEGER): Sound setting (0=off, 1=on)
'   result (BattleResult) - Output battle result (passed by reference):
'     - winner (INTEGER): Winner side (1 or 2)
'     - casualties1, casualties2 (LONG): Casualties for each side
' Description:
'   Main tactical battle function. Replaces file-based interface with direct
'   function call. Launches tactical battle interface and returns results.
' Side Effects:
'   - Displays tactical battle screen
'   - Updates result parameter with battle outcome
'   - May modify global game state
'============================================================================
SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)
    
    DIM winner AS INTEGER
    DIM casualties1 AS LONG
    DIM casualties2 AS LONG
    DIM k AS INTEGER
    DIM i AS INTEGER
    DIM a AS INTEGER
    DIM z AS INTEGER
    DIM unityIndex AS INTEGER
    DIM expVal AS INTEGER
    DIM leadVal AS INTEGER
    
    ' Validate battle data parameters
    IF battleData.side < 1 OR battleData.side > 2 THEN
        CALL HandleValidationError("Invalid side in battle data")
        result.winner = 0 ' No winner - error condition
        EXIT SUB
    END IF
    
    IF battleData.vp1 <= 0 OR battleData.vp2 <= 0 THEN
        CALL HandleValidationError("Invalid army strength in battle data")
        result.winner = 0 ' No winner - error condition
        EXIT SUB
    END IF
    
    IF battleData.sideID1 < 1 OR battleData.sideID1 > 2 OR battleData.sideID2 < 1 OR battleData.sideID2 > 2 THEN
        CALL HandleValidationError("Invalid side IDs in battle data")
        result.winner = 0 ' No winner - error condition
        EXIT SUB
    END IF
    
    ' Convert BattleData to internal format (replacing file read)
    ' This replaces the OPEN "I", 1, "battle.$$$" section from NAPOLEON.BAS
    
    DIM SCENARIO$
    DIM side AS INTEGER
    DIM sidex(1 TO 2) AS INTEGER
    DIM commander$(1 TO 2)
    DIM vp&(1 TO 2)
    DIM leadbase(1 TO 2) AS INTEGER
    DIM expbase(1 TO 2) AS INTEGER
    DIM difficult AS INTEGER
    DIM fort AS INTEGER
    DIM quiet AS INTEGER
    
    ' Copy from battleData parameter
    SCENARIO$ = battleData.scenario
    side = battleData.side
    sidex(1) = battleData.sideID1
    sidex(2) = battleData.sideID2
    commander$(1) = battleData.commander1
    commander$(2) = battleData.commander2
    vp&(1) = battleData.vp1
    vp&(2) = battleData.vp2
    leadbase(1) = battleData.leadbase1
    leadbase(2) = battleData.leadbase2
    expbase(1) = battleData.expbase1
    expbase(2) = battleData.expbase2
    difficult = battleData.difficult
    fort = battleData.fort
    quiet = battleData.quiet
    
    ' Initialize tactical battle (replaces lines 29-67 from NAPOLEON.BAS)
    ' Load configuration (replaces lodecfg GOSUB)
    ' LoadTacticalConfig is non-critical (just initializes arrays), but add error handling for robustness
    ON ERROR GOTO configError
    CALL LoadTacticalConfig
    ON ERROR GOTO 0
    
    ' Set display delay
    mdly! = mdsp: IF mdsp = 5 THEN mdly! = 10
    
    ' Load equipment data (non-critical - can proceed without it)
    IF _FILEEXISTS("data\equip.dat") THEN
        ON ERROR GOTO equipError
        OPEN "I", 1, "data\equip.dat"
        FOR k = 0 TO 5: INPUT #1, equip$(k): NEXT k
        CLOSE #1
        ON ERROR GOTO 0
    ELSE
        ' Initialize equip$ with defaults if file doesn't exist
        FOR k = 0 TO 5
            equip$(k) = ""
        NEXT k
    END IF
    
    ' Load graphics icons (CRITICAL - must be called before battle starts)
    ON ERROR GOTO iconError
    CALL iconload
    ON ERROR GOTO 0
    
    ' Generate random map (CRITICAL - battle cannot proceed without map)
    ON ERROR GOTO mapError
    CALL randmap
    ON ERROR GOTO 0
    
    ' Calculate setup position
    setupx = 1 + INT(4 * RND)
    
    ' Calculate time limit (validate fort value to prevent errors)
    fort = ClampValue%(fort, 0, 5)
    timelimit = 25 + 5 * fort
    IF vp&(1) > 200 AND vp&(2) > 200 THEN timelimit = 40 + 5 * fort
    IF side = sidex(2) THEN
        timelimit = timelimit + 10
        bold = 3
        IF RND > .5 THEN bold = 4: IF RND > .5 THEN bold = 5
    END IF
    ' Validate obstruct to prevent division issues
    obstruct = ClampValue%(obstruct, 0, 1000) ' Reasonable maximum
    timelimit = timelimit + .1 * obstruct
    
    ' Calculate unit size
    unitsize& = vp&(1): IF vp&(2) > vp&(1) THEN unitsize& = vp&(2)
    unitsize& = 3 * unitsize&
    IF unitsize& < 500 THEN unitsize& = 500
    
    ' Set up unit arrays
    ' most, m1, m2 are initialized in declarations.bas (line 99)
    ' Values: most = 80, m1 = 40, m2 = 41 (from NAP10.BI)
    ' No need to re-initialize here - declarations.bas is included first
    bigg(2) = most
    
    ' Scale up unit sizes
    FOR k = 1 TO 2
        vp&(k) = vp&(k) * 100 ' Scale up unit size
    NEXT k
    
    ' Randomize armies (CRITICAL - armies must be initialized)
    ON ERROR GOTO armyError
    FOR k = 1 TO 2
        CALL randarm(k)
    NEXT k
    ON ERROR GOTO 0
    
    ' Set visibility limit (may be overridden by random)
    IF seelimit = 0 THEN seelimit = 18 ' Default if not set by config
    IF RND > .8 THEN seelimit = 10 + INT(9 * RND)
    
    ' Set commander names
    name$(1) = commander$(1)
    name$(41) = commander$(2)
    IF name$(41) = "Napoleon" THEN
        leader(41) = 5: xper(41) = 5: morale(41) = 5
    END IF
    
    ' Set terrain for units (validate array bounds)
    ' sdtext$ is declared as DIM SHARED sdtext$(1 TO 24) in declarations.bas
    IF most > 0 THEN
        FOR k = 1 TO most
            IF strength(k) > 0 THEN
                unityIndex = unity(k) + 1
                ' Validate unityIndex and unitx(k) before accessing sdtext$
                ' sdtext$ is 1 TO 24, so unityIndex must be 1-24
                IF unityIndex >= 1 AND unityIndex <= 24 THEN
                    IF unitx(k) > 0 AND unitx(k) <= LEN(sdtext$(unityIndex)) THEN
                        z = ASC(MID$(sdtext$(unityIndex), unitx(k), 1))
                        terrain(k) = z
                    END IF
                END IF
            END IF
        NEXT k
    END IF
    
    ' Initialize esprit de corps (validate indices to prevent array bounds errors)
    FOR i = 1 TO 2
        k = sidex(i)
        ' Validate k is in valid range (1-2)
        IF k < 1 OR k > 2 THEN k = i ' Fallback to safe value
        a = leader(1): IF k = 1 THEN a = leader(41)
        ' Validate expbase and leader values to prevent extreme results
        ' Use local variables to avoid modifying the local expbase array
        expVal = ClampValue%(expbase(k), 1, 5)
        leadVal = ClampValue%(a, 1, 5)
        elan(k) = 80 + 5 * (expVal - 3) + 5 * (leadVal - 3)
        CALL brittle(k)
    NEXT i
    
    ' Initialize score tracking (casualties)
    score&(1) = 0
    score&(2) = 0
    
    ' Initialize objective control (possess)
    possess = 0 ' Neutral initially, will be set by randarm if fort > 0
    
    ' Initialize time
    CALL TICK(2)
    
    ' Set error handling for battle loop
    ON ERROR GOTO battleLoopError
    
    ' Run tactical battle loop (replaces lines 72-95 from NAPOLEON.BAS)
    ' This will call the refactored main game loop
    ' Note: sidex is already declared as sidex(1 TO 2), so pass it directly
    winner = RunTacticalBattleLoop%(side, sidex)
    
    ' Validate winner value
    IF winner < 1 OR winner > 2 THEN
        winner = 0 ' Invalid winner - error condition
    END IF
    
    ' Calculate final casualties from remaining strength
    ' Note: vp&(1) and vp&(2) are scaled up by 100 (line 167), and GetRemainingStrength
    ' returns strength values in the same scaled units, so the calculation is correct.
    DIM remaining1 AS LONG
    DIM remaining2 AS LONG
    remaining1 = GetRemainingStrength(1)
    remaining2 = GetRemainingStrength(2)
    
    ' Validate remaining strength values
    remaining1 = ClampValueLong&(remaining1, 0, vp&(1))
    remaining2 = ClampValueLong&(remaining2, 0, vp&(2))
    
    casualties1 = vp&(1) - remaining1
    casualties2 = vp&(2) - remaining2
    
    ' Ensure non-negative casualties (but don't clamp to max - casualties can exceed initial strength in extreme cases)
    IF casualties1 < 0 THEN casualties1 = 0
    IF casualties2 < 0 THEN casualties2 = 0
    
    ' Set result (casualties already calculated above)
    result.winner = winner
    result.casualties1 = casualties1
    result.casualties2 = casualties2
    
    ' Reset error handling
    ON ERROR GOTO 0
    
    ' Result is set in result parameter (passed by reference)
    EXIT SUB
    
    ' Error handlers
configError:
    ON ERROR GOTO 0
    ' LoadTacticalConfig failure is non-critical (just initializes arrays)
    ' Continue with default values - the SUB will have set defaults anyway
    CALL HandleWarning("Could not load tactical configuration, using defaults")
    RESUME NEXT
    
equipError:
    ' Close file if it was opened (may fail if already closed, ignore errors)
    ON ERROR GOTO skipClose
    CLOSE #1
skipClose:
    ON ERROR GOTO 0
    ' Initialize equip$ with defaults
    FOR k = 0 TO 5
        equip$(k) = ""
    NEXT k
    ' Equipment data is non-critical, continue without it
    CALL HandleWarning("Could not load equip.dat, continuing without it")
    RESUME NEXT
    
iconError:
    ON ERROR GOTO 0
    CALL HandleCriticalError("Failed to load graphics icons. Battle cannot proceed.")
    result.winner = 0 ' No winner - error condition
    result.casualties1 = 0
    result.casualties2 = 0
    EXIT SUB
    
mapError:
    ON ERROR GOTO 0
    CALL HandleCriticalError("Failed to generate battle map. Battle cannot proceed.")
    result.winner = 0 ' No winner - error condition
    result.casualties1 = 0
    result.casualties2 = 0
    EXIT SUB
    
armyError:
    ON ERROR GOTO 0
    CALL HandleCriticalError("Failed to initialize armies. Battle cannot proceed.")
    result.winner = 0 ' No winner - error condition
    result.casualties1 = 0
    result.casualties2 = 0
    EXIT SUB
    
battleLoopError:
    ON ERROR GOTO 0
    CALL HandleCriticalError("Battle loop failed. Using default results.")
    ' Set default result (no winner, estimate casualties)
    result.winner = 0 ' No winner - error condition
    ' Use scaled vp& values (already scaled by 100)
    IF vp&(1) > 0 THEN
        result.casualties1 = vp&(1) \ 2 ' Estimate 50% casualties
    ELSE
        result.casualties1 = 0
    END IF
    IF vp&(2) > 0 THEN
        result.casualties2 = vp&(2) \ 2 ' Estimate 50% casualties
    ELSE
        result.casualties2 = 0
    END IF
    EXIT SUB
END SUB

' TODO: Implement InitializeTacticalBattle when NAPOLEON.BAS is integrated
' QB64 doesn't support array parameters like sidex() AS INTEGER - need to use fixed-size arrays or different approach
' SUB InitializeTacticalBattle (SCENARIO$ AS STRING, side AS INTEGER, sidex() AS INTEGER, commander$ AS STRING, _
'                                vp& AS LONG, leadbase() AS INTEGER, expbase() AS INTEGER, _
'                                difficult AS INTEGER, fort AS INTEGER, quiet AS INTEGER)
'     ' Initialize tactical battle
'     ' Refactored from NAPOLEON.BAS lines 29-67
'     
'     ' Load equipment data (if needed)
'     ' OPEN "I", 1, "data\equip.dat"
'     ' FOR k = 0 TO 5: INPUT #1, equip$(k): NEXT k
'     ' CLOSE #1
'     
'     ' Generate random map
'     ' randmap
'     
'     ' Calculate time limit
'     ' DIM timelimit AS INTEGER
'     ' timelimit = 25 + 5 * fort
'     ' IF vp&(1) > 200 AND vp&(2) > 200 THEN timelimit = 40 + 5 * fort
'     ' IF side = sidex(2) THEN
'     '     timelimit = timelimit + 10
'     ' END IF
'     
'     ' Calculate unit size
'     ' DIM unitsize& AS LONG
'     ' unitsize& = vp&(1): IF vp&(2) > vp&(1) THEN unitsize& = vp&(2)
'     ' unitsize& = 3 * unitsize&
'     ' IF unitsize& < 500 THEN unitsize& = 500
'     
'     ' Scale up unit sizes
'     ' FOR k = 1 TO 2
'     '     vp&(k) = vp&(k) * 100 ' Scale up unit size
'     ' NEXT k
'     
'     ' Randomize armies
'     ' TODO: Implement randarm SUB from NAPOLEON.BAS
'     ' FOR k = 1 TO 2
'     '     CALL randarm(k)
'     ' NEXT k
'     
'     ' Set commander names
'     ' name$(1) = commander$(1)
'     ' name$(41) = commander$(2)
'     ' IF name$(41) = "Napoleon" THEN
'     '     leader(41) = 5: xper(41) = 5: morale(41) = 5
'     ' END IF
'     
'     ' Initialize esprit de corps
'     ' DIM i AS INTEGER
'     ' DIM k AS INTEGER
'     ' DIM a AS INTEGER
'     ' FOR i = 1 TO 2
'     '     k = sidex(i)
'     '     a = leader(1): IF k = 1 THEN a = leader(41)
'     '     elan(k) = 80 + 5 * (expbase(k) - 3) + 5 * (a - 3)
'     '     CALL brittle(k)
'     ' NEXT i
' ' END SUB

'============================================================================
' RunTacticalBattleLoop - Execute main tactical battle loop
'============================================================================
' Parameters:
'   side (INTEGER) - Current side (1=French, 2=Allies)
'   sidex(1 TO 2) (INTEGER) - Side identifiers for both sides
' Returns:
'   INTEGER - Winner side (1 or 2)
' Description:
'   Runs the main tactical battle loop. Handles unit movement, combat,
'   and victory conditions. Refactored from NAPOLEON.BAS.
' Note:
'   Fixed-size array parameter required for QB64 compatibility
'============================================================================
FUNCTION RunTacticalBattleLoop% (side AS INTEGER, sidex(1 TO 2) AS INTEGER)
    
    DIM winner AS INTEGER
    winner = 0
    
    ' Initialize display
    SCREEN 9, , 0, 0
    CALL mainmap
    
    ' Initialize units
    CALL clrbot: COLOR 4: PRINT "Initializing"
    DIM i AS INTEGER
    FOR i = 1 TO 2
        CALL Compact(i)
    NEXT i
    CALL lowtime
    
    ' Set up visibility
    DIM k AS INTEGER
    DIM s AS INTEGER
    DIM F AS INTEGER
    DIM active AS INTEGER
    FOR k = 1 TO bigg(2)
        Visible(k) = 0
        IF strength(k) > 0 AND uorder(k) <> 99 AND terrain(k) = 233 THEN CALL victory(k)
    NEXT k
    
    s = 1: F = bigg(side): IF side = 2 THEN s = m2
    FOR active = s TO F
        IF strength(active) > 0 AND uorder(active) <> 99 THEN
            Visible(active) = 1
            CALL see(active)
        END IF
    NEXT active
    
    ' Initialize file$ to empty (used to signal battle end)
    ' file$ will be set to CHR$(219) when battle ends or time expires
    file$ = ""
    
    ' Main battle loop
    startit! = TIMER
    
    ' Battle proceeds until winner determined
    ' The original code has: nother: CALL order: IF LEN(file$) > 1 GOTO nother
    ' We refactor this to check for battle end conditions
    DO
        ' Process orders for next unit
        CALL order
        
        ' Check for battle end conditions
        ' file$ will be set to CHR$(219) when time expires or battle ends
        IF file$ = CHR$(219) THEN
            ' Time expired or battle ended
            EXIT DO
        END IF
        
        ' Check victory conditions
        winner = CheckVictoryConditions()
        IF winner > 0 THEN EXIT DO
        
        ' Check esprit de corps (army routs)
        IF elan(1) <= 0 THEN
            winner = sidex(2) ' Side 2 wins (side 1 routed)
            EXIT DO
        END IF
        IF elan(2) <= 0 THEN
            winner = sidex(1) ' Side 1 wins (side 2 routed)
            EXIT DO
        END IF
        
        ' Refresh display
        CALL refresh
    LOOP
    
    ' If no winner determined yet, use remaining strength
    IF winner = 0 THEN
        DIM strength1 AS LONG
        DIM strength2 AS LONG
        strength1 = 0
        strength2 = 0
        
        ' Calculate remaining strengths
        FOR k = 1 TO bigg(1)
            IF strength(k) > 0 THEN strength1 = strength1 + strength(k)
        NEXT k
        
        FOR k = m2 TO bigg(2)
            IF strength(k) > 0 THEN strength2 = strength2 + strength(k)
        NEXT k
        
        ' Determine winner
        IF strength1 > strength2 THEN
            winner = sidex(1) ' Side 1 wins
        ELSE
            winner = sidex(2) ' Side 2 wins
        END IF
    END IF
    
    RunTacticalBattleLoop = winner
END FUNCTION

FUNCTION GetRemainingStrength& (side AS INTEGER)
    ' Get remaining strength for side after battle
    ' Used to calculate casualties
    ' Note: vp& values are already scaled up by 100, so we return the actual strength
    
    DIM total AS LONG
    DIM k AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    
    total = 0
    IF side = 1 THEN
        startIndex = 1
        endIndex = bigg(1)
    ELSE
        startIndex = m2
        endIndex = bigg(2)
    END IF
    
    FOR k = startIndex TO endIndex
        IF strength(k) > 0 THEN
            total = total + strength(k)
        END IF
    NEXT k
    
    GetRemainingStrength = total
END FUNCTION

'============================================================================
' Configuration Loading
'============================================================================
' Replaces lodecfg GOSUB from NAPOLEON.BAS
SUB LoadTacticalConfig
    ' Load text arrays and set default configuration values
    ' This replaces the lodecfg GOSUB (lines 99-111 from NAPOLEON.BAS)
    
    ' Load adjective arrays
    adj1$(1) = "Timid": adj1$(2) = "Cautious": adj1$(3) = "Normal": adj1$(4) = "Bold": adj1$(5) = "Reckless"
    adj2$(1) = "Very Easy": adj2$(2) = "Easy": adj2$(3) = "Normal": adj2$(4) = "Hard": adj2$(5) = "Very Hard"
    adj3$(1) = "VERY Fast": adj3$(2) = "Fast": adj3$(3) = "Normal": adj3$(4) = "Slow": adj3$(5) = "VERY Slow"
    
    ' Load side names
    sname$(1) = "Allies": sname$(2) = "French"
    
    ' Load experience level names
    xplev$(1) = "Green": xplev$(2) = "Raw": xplev$(3) = "Veteran": xplev$(4) = "Seasoned": xplev$(5) = "Hardened"
    
    ' Load leadership level names
    ledlev$(1) = "Inept": ledlev$(2) = "Weak": ledlev$(3) = "Good": ledlev$(4) = "Strong": ledlev$(5) = "Brilliant"
    
    ' Load morale level names
    morlev$(1) = "Beaten": morlev$(2) = "Low": morlev$(3) = "Good": morlev$(4) = "High": morlev$(5) = "Fearless"
    
    ' Set default configuration values
    bold = 3
    seelimit = 18
    mdsp = 3
    limber = 1
    rely = 4
    stakk = 3
    lineofsight = 1
    artcap = 1
END SUB

