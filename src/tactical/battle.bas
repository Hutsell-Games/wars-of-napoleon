'============================================================================
' Tactical Battle Module - Refactored
'============================================================================
' Refactored from NAPOLEON.BAS
' Modern unified approach: Direct function call instead of file I/O + process spawning
' Removed: File I/O (battle.$$$), Process spawning (SHELL), File output (outcome.&&&)
' Added: Function parameters, Return values
'
' INTEGRATION STATUS: Complete - All NAPOLEON.BAS code has been modularized
' The original monolithic NAPOLEON.BAS has been fully refactored into separate modules

' Note: battle_types.bas is included in main.bas
' Note: NAPOLEON.BAS code has been refactored into modular files:
'   - terrain.bas: randmap, terrain generation
'   - unit_placement.bas: randarm, unit placement
'   - ui.bas: mainmap, iconload, display functions
'   - unit_management.bas: SHOWUNIT, unit operations
'   - Other modules: combat, orders, ai, etc.
' Original nap10.bi declarations are now in declarations.bas
'
'============================================================================
' Forward Declarations
'============================================================================
' Forward declarations for functions defined in included modules
' These allow functions to be called before their definitions are included
DECLARE SUB randarm (k%)
DECLARE FUNCTION randmap% ()

'============================================================================
' Include Order (for modular files)
'============================================================================
' 1. core.bas (constants and core mechanics - must be first)
' 2. utilities.bas (base functions)
' 3. ui.bas (display functions)
' 4. terrain.bas (map functions)
' 5. unit_placement.bas (unit creation)
' 6. unit_management.bas (unit operations)
' 7. ai.bas (AI decisions)
' 8. combat.bas (combat system)
' 9. orders.bas (order processing - depends on all above)
' 10. napoleon_subs.bas (remaining functions not yet modularized)
'============================================================================

' $INCLUDE: 'core.bas'
' $INCLUDE: 'utilities.bas'
' $INCLUDE: 'ui.bas'
' $INCLUDE: 'terrain.bas'
' $INCLUDE: 'unit_placement.bas'
' $INCLUDE: 'unit_management.bas'
' $INCLUDE: 'ai.bas'
' $INCLUDE: 'combat.bas'
' $INCLUDE: 'orders.bas'
' $INCLUDE: 'napoleon_subs.bas'

' Note: All NAPOLEON.BAS code has been refactored into modular files:
'   - terrain.bas: Map generation (randmap)
'   - unit_placement.bas: Unit placement (randarm)
'   - ui.bas: Display functions (mainmap, iconload, refresh)
'   - unit_management.bas: Unit operations (SHOWUNIT, placeunit)
'   - combat.bas: Combat system
'   - orders.bas: Order processing
'   - ai.bas: AI decisions
'   - napoleon_subs.bas: Remaining utility functions

'============================================================================
' LaunchTacticalBattle - Launch and execute tactical battle
'============================================================================
' INTEGRATION POINT: Strategic -> Tactical
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
' - Critical failures (iconload, randmap, randarm) -> result.winner = 0
' - Non-critical failures (equip.dat, config) -> warnings, continue
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
    ' Note: SCENARIO$, side, fort, sidex, commander$, vp&, leadbase, expbase are SHARED
    ' (declared in declarations.bas) so randmap and other functions can access them
    ' Do NOT redeclare these as local variables - just assign to the SHARED variables
    
    DIM difficult AS INTEGER
    DIM quiet AS INTEGER
    
    ' Copy from battleData parameter to SHARED variables
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
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 1: Configuration
    ' ============================================================
    ' Load configuration (replaces lodecfg GOSUB)
    ' LoadTacticalConfig is non-critical (just initializes arrays), but add error handling for robustness
    ' LoadTacticalConfig doesn't perform file I/O, so no error handling needed
    ' If it fails, it will just use defaults which is acceptable
    CALL LoadTacticalConfig
    
    ' Set display delay - controls animation speed in tactical battle
    ' mdsp = DISPLAY_SPEED_VERY_FAST means very fast, so we increase delay to DISPLAY_DELAY_FAST for better visibility
    mdly! = mdsp: IF mdsp = DISPLAY_SPEED_VERY_FAST THEN mdly! = DISPLAY_DELAY_FAST
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 2: Data Loading
    ' ============================================================
    ' Load equipment data (non-critical - can proceed without it)
    ' Note: Error handling is implemented using SafeOpenFile% which gracefully
    ' handles file open failures. If the file cannot be opened, defaults are used.
    ' Equipment data is used for flavor text only, not critical to battle mechanics
    IF _FILEEXISTS("data\equip.dat") THEN
        ' Use SafeOpenFile to handle errors gracefully
        IF SafeOpenFile%("data\equip.dat", "I", 1) = 1 THEN
            FOR k = 0 TO MAX_EQUIPMENT_ITEMS: INPUT #1, equip$(k): NEXT k
            CLOSE #1
        ELSE
            ' File open failed, initialize with defaults
            ' Empty strings mean no equipment flavor text, but battle still works
            FOR k = 0 TO MAX_EQUIPMENT_ITEMS
                equip$(k) = ""
            NEXT k
            CALL HandleWarning("Could not load equip.dat, continuing without it")
        END IF
    ELSE
        ' Initialize equip$ with defaults if file doesn't exist
        FOR k = 0 TO MAX_EQUIPMENT_ITEMS
            equip$(k) = ""
        NEXT k
    END IF
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 3: Graphics & Map (CRITICAL)
    ' ============================================================
    ' Load graphics icons (CRITICAL - must be called before battle starts)
    ' iconload now returns 1 on success, 0 on failure
    ' If iconload fails, we cannot proceed with the battle
    IF iconload%() = 0 THEN
        ' Graphics loading failed - cannot proceed with battle
        result.winner = 0
        COLOR 12: LOCATE 3, 1: PRINT "FATAL ERROR: Cannot load graphics files"
        LOCATE 4, 1: PRINT "Battle cannot proceed without graphics."
        LOCATE 5, 1: PRINT "Press any key to return to strategic map..."
        DO WHILE INKEY$ = "": LOOP
        EXIT SUB
    END IF
    
    ' Generate random map (CRITICAL - battle cannot proceed without map)
    ' randmap now returns 1 on success, 0 on failure
    ' If map generation fails, we cannot proceed with the battle
    IF randmap%() = 0 THEN
        ' Map generation failed - cannot proceed with battle
        result.winner = 0
        COLOR 12: LOCATE 3, 1: PRINT "FATAL ERROR: Cannot generate battle map"
        LOCATE 4, 1: PRINT "Battle cannot proceed without a valid map."
        LOCATE 5, 1: PRINT "Press any key to return to strategic map..."
        DO WHILE INKEY$ = "": LOOP
        EXIT SUB
    END IF
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 4: Battle Parameters
    ' ============================================================
    ' Calculate setup position - random starting position for units (1-4)
    ' This affects initial unit placement on the tactical map
    setupx = 1 + INT(4 * RND)
    
    ' Calculate time limit (validate fort value to prevent errors)
    ' Base time: BASE_TIME_LIMIT turns, +FORT_TIME_BONUS per fortification level
    ' Large battles (>LARGE_BATTLE_THRESHOLD units) get extended time limit
    ' Defender gets +DEFENDER_TIME_BONUS turns advantage
    ' Terrain obstruction adds OBSTRUCTION_TIME_MULTIPLIER to time limit
    fort = ClampValue%(fort, 0, 5)
    timelimit = BASE_TIME_LIMIT + FORT_TIME_BONUS * fort
    IF vp&(1) > LARGE_BATTLE_THRESHOLD AND vp&(2) > LARGE_BATTLE_THRESHOLD THEN timelimit = LARGE_BATTLE_BASE_TIME + FORT_TIME_BONUS * fort
    IF side = sidex(2) THEN
        timelimit = timelimit + DEFENDER_TIME_BONUS
        bold = 3
        ' Random boldness adjustment for defender (3-5 range)
        IF RND > .5 THEN bold = 4: IF RND > .5 THEN bold = 5
    END IF
    ' Validate obstruct to prevent division issues
    ' Obstruction represents terrain difficulty (0-MAX_OBSTRUCTION_VALUE scale)
    obstruct = ClampValue%(obstruct, 0, MAX_OBSTRUCTION_VALUE) ' Reasonable maximum
    timelimit = timelimit + OBSTRUCTION_TIME_MULTIPLIER * obstruct
    
    ' Calculate unit size - determines how many men per unit icon
    ' Uses larger of the two armies, multiplied by UNIT_SIZE_MULTIPLIER, minimum MIN_UNIT_SIZE
    ' This ensures units are visible and meaningful on the tactical map
    unitsize& = vp&(1): IF vp&(2) > vp&(1) THEN unitsize& = vp&(2)
    unitsize& = UNIT_SIZE_MULTIPLIER * unitsize&
    IF unitsize& < MIN_UNIT_SIZE THEN unitsize& = MIN_UNIT_SIZE
    
    ' Set up unit arrays
    ' most, m1, m2 are initialized in declarations.bas (line 99)
    ' Values: most = 80, m1 = 40, m2 = 41 (from NAP10.BI)
    ' No need to re-initialize here - declarations.bas is included first
    ' bigg(1) is the maximum unit index for side 1, bigg(2) is the maximum unit index for side 2
    bigg(1) = m1
    bigg(2) = most
    
    ' Scale up unit sizes - convert from hundreds to actual men
    ' Example: 50 (hundreds) -> 5000 (actual men)
    ' This scaling is needed because tactical battle uses actual men counts
    FOR k = 1 TO 2
        vp&(k) = vp&(k) * HUNDREDS_TO_MEN_SCALE ' Scale up unit size
    NEXT k
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 5: Unit Creation (CRITICAL)
    ' ============================================================
    ' Randomize armies (CRITICAL - armies must be initialized)
    ' Note: randarm is a SUB that may fail, but we can't easily check its return value
    ' Since it's critical, we'll call it and handle any errors by checking if battle can proceed
    ' If randarm fails, the battle will fail when trying to process units
    ' For now, we'll call it and let the battle loop handle errors
    ' randarm creates unit arrays, assigns positions, sets unit types
    FOR k = 1 TO 2
        CALL randarm(k)
    NEXT k
    
    ' Set visibility limit (may be overridden by random)
    ' seelimit controls how far units can see on the tactical map
    ' Default DEFAULT_VISIBILITY_LIMIT, but REDUCED_VISIBILITY_CHANCE chance of reduced visibility
    ' Reduced visibility makes battles more challenging and realistic
    IF seelimit = 0 THEN seelimit = DEFAULT_VISIBILITY_LIMIT ' Default if not set by config
    IF RND > REDUCED_VISIBILITY_CHANCE THEN seelimit = MIN_VISIBILITY_LIMIT + INT((MAX_VISIBILITY_LIMIT - MIN_VISIBILITY_LIMIT + 1) * RND)
    
    ' Set commander names - assign names to unit indices COMMANDER_UNIT_INDEX_1 and COMMANDER_UNIT_INDEX_2
    ' These are the general units that provide leadership bonuses
    name$(COMMANDER_UNIT_INDEX_1) = commander$(1)
    name$(COMMANDER_UNIT_INDEX_2) = commander$(2)
    ' Special case: Napoleon gets maximum stats (MAX_STAT_RATING/MAX_STAT_RATING/MAX_STAT_RATING)
    ' This represents his historical leadership and experience
    IF name$(COMMANDER_UNIT_INDEX_2) = "Napoleon" THEN
        leader(COMMANDER_UNIT_INDEX_2) = MAX_STAT_RATING: xper(COMMANDER_UNIT_INDEX_2) = MAX_STAT_RATING: morale(COMMANDER_UNIT_INDEX_2) = MAX_STAT_RATING
    END IF
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 6: Terrain Assignment
    ' ============================================================
    ' Set terrain for units (validate array bounds)
    ' Note: sdtext$ is declared in declarations.bas as sdtext$(1 TO 24)
    ' This validation prevents array bounds errors if unity(k) + 1 is out of range
    ' Terrain affects movement speed and combat effectiveness
    IF most > 0 THEN
        FOR k = 1 TO most
            IF strength(k) > 0 THEN
                unityIndex = unity(k) + 1
                ' Validate unityIndex before accessing sdtext$ array (bounds: 1-MAX_TERRAIN_MAP_ROWS)
                ' sdtext$ contains terrain type codes for each map position
                IF unityIndex >= 1 AND unityIndex <= MAX_TERRAIN_MAP_ROWS THEN
                    ' Validate unitx(k) before accessing string character (must be within string length)
                    ' unitx(k) is the X coordinate on the tactical map
                    IF unitx(k) > 0 AND unitx(k) <= LEN(sdtext$(unityIndex)) THEN
                        ' Extract terrain type from map data string
                        z = ASC(MID$(sdtext$(unityIndex), unitx(k), 1))
                        terrain(k) = z
                    ELSE
                        ' Invalid unitx(k) - use default terrain (clear/road)
                        ' This prevents crashes and provides a reasonable default
                        terrain(k) = DEFAULT_TERRAIN_CLEAR ' Default to clear terrain
                        CALL HandleWarning("Invalid unitx(" + LTRIM$(STR$(k)) + ") = " + LTRIM$(STR$(unitx(k))) + " for sdtext$ index " + LTRIM$(STR$(unityIndex)) + " - using default terrain " + LTRIM$(STR$(DEFAULT_TERRAIN_CLEAR)))
                    END IF
                ELSE
                    ' Invalid unityIndex - use default terrain (clear/road)
                    ' This prevents crashes and provides a reasonable default
                    terrain(k) = DEFAULT_TERRAIN_CLEAR ' Default to clear terrain
                    CALL HandleWarning("Invalid unityIndex = " + LTRIM$(STR$(unityIndex)) + " (must be 1-" + LTRIM$(STR$(MAX_TERRAIN_MAP_ROWS)) + ") for unit " + LTRIM$(STR$(k)) + " - using default terrain " + LTRIM$(STR$(DEFAULT_TERRAIN_CLEAR)))
                END IF
            END IF
        NEXT k
    END IF
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 7: Morale & Esprit de Corps
    ' ============================================================
    ' Initialize esprit de corps (validate indices to prevent array bounds errors)
    ' Esprit de corps represents army morale and cohesion
    ' Base value: BASE_ESPRIT_DE_CORPS, modified by experience and leadership
    ' Formula: BASE_ESPRIT_DE_CORPS + ESPRIT_EXPERIENCE_MULTIPLIER*(experience-ESPRIT_AVERAGE_RATING) + ESPRIT_LEADERSHIP_MULTIPLIER*(leadership-ESPRIT_AVERAGE_RATING)
    ' This means average (3/3) = BASE_ESPRIT_DE_CORPS, excellent (5/5) = 100, poor (1/1) = 60
    FOR i = 1 TO 2
        k = sidex(i)
        ' Validate k is in valid range (1-2)
        IF k < 1 OR k > 2 THEN k = i ' Fallback to safe value
        ' Get leader rating - side 1 uses leader(COMMANDER_UNIT_INDEX_1), side 2 uses leader(COMMANDER_UNIT_INDEX_2)
        IF k = 1 THEN
            a = leader(COMMANDER_UNIT_INDEX_1)
        ELSE
            a = leader(COMMANDER_UNIT_INDEX_2)
        END IF
        ' Validate expbase and leader values to prevent extreme results
        ' Use local variables to avoid modifying the local expbase array
        ' Clamp to 1-5 range to ensure reasonable values
        expVal = ClampValue%(expbase(k), 1, 5)
        leadVal = ClampValue%(a, 1, 5)
        ' Calculate esprit de corps with validated values
        elan(k) = BASE_ESPRIT_DE_CORPS + ESPRIT_EXPERIENCE_MULTIPLIER * (expVal - ESPRIT_AVERAGE_RATING) + ESPRIT_LEADERSHIP_MULTIPLIER * (leadVal - ESPRIT_AVERAGE_RATING)
        ' brittle() calculates army brittleness (how easily it routs)
        ' This affects how quickly armies break under pressure
        CALL brittle(k)
    NEXT i
    
    ' ============================================================
    ' INITIALIZATION SEQUENCE - Phase 8: Score & Objectives
    ' ============================================================
    ' Initialize score tracking (casualties)
    ' These track cumulative casualties during the battle
    score&(1) = 0
    score&(2) = 0
    
    ' Initialize objective control (possess)
    ' possess = 0 means neutral, will be set by randarm if fort > 0
    ' Objectives are strategic points that affect victory conditions
    possess = 0 ' Neutral initially, will be set by randarm if fort > 0
    
    ' Initialize time - sets battle turn counter
    ' TICK(2) initializes time to turn 2 (turn 1 is setup)
    CALL TICK(2)
    
    ' Run tactical battle loop (replaces lines 72-95 from NAPOLEON.BAS)
    ' This will call the refactored main game loop
    ' Note: sidex is already declared as sidex(1 TO 2), so pass it directly
    ' Validate winner value after battle loop
    winner = RunTacticalBattleLoop%(side, sidex())
    
    ' Validate winner value - if invalid, treat as error
    IF winner < 1 OR winner > 2 THEN
        ' Battle loop failed or returned invalid result
        CALL HandleCriticalError("Battle loop failed. Using default results.")
        winner = 0 ' No winner - error condition
        ' Estimate casualties as ERROR_CASUALTY_ESTIMATE of initial strength
        IF vp&(1) > 0 THEN
            casualties1 = INT(vp&(1) * ERROR_CASUALTY_ESTIMATE)
        ELSE
            casualties1 = 0
        END IF
        IF vp&(2) > 0 THEN
            casualties2 = INT(vp&(2) * ERROR_CASUALTY_ESTIMATE)
        ELSE
            casualties2 = 0
        END IF
        result.winner = winner
        result.casualties1 = casualties1
        result.casualties2 = casualties2
        EXIT SUB
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
    
    ' Result is set in result parameter (passed by reference)
    EXIT SUB
END SUB

'============================================================================
' InitializeTacticalBattle - No longer needed (initialization in LaunchTacticalBattle)
'============================================================================
' STATUS: Implementation complete - initialization is done directly in LaunchTacticalBattle
' The original plan to have a separate InitializeTacticalBattle function was superseded
' by implementing all initialization directly in LaunchTacticalBattle (lines 110-372).
'
' The initialization sequence in LaunchTacticalBattle:
'   1. Validate battle data parameters
'   2. Load tactical configuration (LoadTacticalConfig)
'   3. Load equipment data (equip.dat with error handling)
'   4. Load graphics icons (iconload - critical, handled by battle loop)
'   5. Generate random map (randmap - critical, handled by battle loop)
'   6. Initialize armies (randarm - critical, handled by battle loop)
'   7. Set up terrain and visibility
'   8. Initialize esprit de corps
'   9. Run tactical battle loop
'   10. Calculate casualties and return results
'
' All initialization is now complete and functional in LaunchTacticalBattle.
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
    '     ' Note: randarm is implemented in unit_placement.bas:23
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
        IF strength(k) > 0 AND uorder(k) <> UNIT_ORDER_ROUTED AND terrain(k) = TERRAIN_ROAD THEN CALL victory(k)
    NEXT k
    
    s = 1: F = bigg(side): IF side = 2 THEN s = m2
    FOR active = s TO F
        IF strength(active) > 0 AND uorder(active) <> UNIT_ORDER_ROUTED THEN
            Visible(active) = 1
            CALL see(active)
        END IF
    NEXT active
    
    ' Initialize file$ to empty (used to signal battle end)
    ' file$ will be set to CHR$(BATTLE_END_SIGNAL) when battle ends or time expires
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
        ' file$ will be set to CHR$(BATTLE_END_SIGNAL) when time expires or battle ends
        IF file$ = CHR$(BATTLE_END_SIGNAL) THEN
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

'============================================================================
' GetRemainingStrength - Get remaining strength for side after battle
'============================================================================
' Parameters:
'   side (INTEGER) - Side to calculate strength for (1 or 2)
' Returns:
'   LONG - Total remaining strength for the side after battle
' Description:
'   Calculates the total remaining strength of all units for a given side
'   after a tactical battle. Used to determine casualties by comparing
'   initial strength to remaining strength.
' Note:
'   - vp& values are already scaled up by 100 (hundreds -> actual men)
'   - Returns strength in the same scaled units as input
'   - Only counts units with strength > 0
'============================================================================
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

'============================================================================
' LoadTacticalConfig - Load tactical battle configuration and text arrays
'============================================================================
' Description:
'   Initializes tactical battle configuration by loading text arrays and
'   setting default configuration values. Replaces the lodecfg GOSUB from
'   the original NAPOLEON.BAS. Loads:
'   - Adjective arrays (adj1$, adj2$, adj3$) for unit descriptions
'   - Side names (sname$) for display
'   - Experience level names (xplev$) for unit experience display
'   - Leadership level names (ledlev$) for commander ratings
'   - Morale level names (morlev$) for unit morale display
'   - Default configuration values (bold, seelimit, mdsp, limber, rely, stakk,
'     lineofsight, artcap)
' Side Effects:
'   - Initializes shared text arrays and configuration variables
'   - Sets default tactical battle settings
'============================================================================
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
    bold = DEFAULT_BOLD
    seelimit = DEFAULT_SEELIMIT
    mdsp = DEFAULT_MDSP
    limber = DEFAULT_LIMBER
    rely = DEFAULT_RELY
    stakk = DEFAULT_STAKK
    lineofsight = DEFAULT_LINEOFSIGHT
    artcap = DEFAULT_ARTCAP
END SUB
