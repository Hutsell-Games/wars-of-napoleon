'============================================================================
' Realism Toggle
'============================================================================
' Ported from CWS (adapted for Napoleonic era)
' Comprehensive realism toggle affecting multiple systems

' Note: game_types.bas is included in main.bas
' Note: Config is included in declarations.bas
' Note: army.bas, city.bas are included in main.bas

' Note: realismMode is declared in declarations.bas

'============================================================================
' InitializeRealism - Initialize realism mode from configuration
'============================================================================
' Description:
'   Initializes realism mode to default off (0). Realism mode affects
'   recruitment, combat, and other game mechanics to provide more historical
'   accuracy. The mode can be enabled/disabled via SetRealismMode.
' Side Effects:
'   - Sets realismMode to 0 (disabled)
'============================================================================
SUB InitializeRealism
    ' Initialize realism mode from config
    ' Will be added to config.bas
    realismMode = 0 ' Default off
END SUB

'============================================================================
' SetRealismMode - Enable or disable realism mode
'============================================================================
' Parameters:
'   enabled (INTEGER) - 1 to enable realism mode, 0 to disable
' Description:
'   Sets the realism mode flag which affects multiple game systems including
'   recruitment restrictions, combat bonuses, and city isolation effects.
'   When enabled, provides more historically accurate gameplay mechanics.
' Side Effects:
'   - Sets global realismMode variable
'   - Displays status message indicating mode change
'============================================================================
SUB SetRealismMode (enabled AS INTEGER)
    ' Set realism mode
    realismMode = enabled
    IF enabled = 1 THEN
        CALL ShowStatusMessage("Realism mode enabled", 11)
    ELSE
        CALL ShowStatusMessage("Realism mode disabled", 11)
    END IF
END SUB

'============================================================================
' GetRecruitmentSize - Get recruitment size based on city and realism mode
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city where recruitment occurs
'   cities() (CityType) - Cities array (passed as parameter)
'   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
' Returns:
'   LONG - Recruitment size in men
' Description:
'   Calculates the recruitment size for a new army. In normal mode, returns
'   a fixed default size. In realism mode, recruitment size is based on the
'   city's value (income), scaled appropriately with minimum and maximum limits.
'   Accepts arrays as parameters to allow testing with mock data.
'============================================================================
FUNCTION GetRecruitmentSize& (cityIndex AS INTEGER, cities() AS CityType, realismModeEnabled AS INTEGER)
    ' Get recruitment size based on city size
    ' Realism mode: City size affects recruit numbers
    ' Normal mode: Fixed recruitment
    ' 
    ' Parameters:
    '   cityIndex (INTEGER) - Index of city
    '   cities() (CityType) - Cities array (passed as parameter)
    '   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
    ' Returns:
    '   LONG - Recruitment size in men
    ' Description:
    '   Accepts cities array and realism mode as parameters instead of using
    '   global state. This makes dependencies explicit and allows testing with
    '   mock data.
    
    ' Validate input
    IF cityIndex < 1 OR cityIndex > UBOUND(cities) THEN
        GetRecruitmentSize& = DEFAULT_ARMY_SIZE
        EXIT FUNCTION
    END IF
    
    DIM baseSize AS LONG
    baseSize = DEFAULT_ARMY_SIZE ' Default recruitment size
    
    IF realismModeEnabled = 1 THEN
        ' City size affects recruitment
        baseSize = cities(cityIndex).value * 100 ' Scale by city value
        IF baseSize < 5000 THEN baseSize = 5000 ' Minimum
        IF baseSize > 20000 THEN baseSize = 20000 ' Maximum
    END IF
    
    GetRecruitmentSize& = baseSize
END FUNCTION

'============================================================================
' CanRecruitInCityRealism - Check if recruitment allowed in city (realism mode)
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to check
'   cities() (CityType) - Cities array (passed as parameter)
'   side (INTEGER) - Side attempting to recruit (1=French, 2=Allies)
'   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
' Returns:
'   INTEGER - 1 if recruitment allowed, 0 otherwise
' Description:
'   Checks if recruitment is allowed in a city. In normal mode, recruitment
'   is always allowed. In realism mode, recruitment is restricted to cities
'   that were originally owned by the recruiting side (or neutral). This
'   prevents recruiting in recently captured enemy cities, providing more
'   historical accuracy. The function checks the city's originalOwner field
'   which is set when the city is first loaded from scenario data.
'   Accepts arrays as parameters to allow testing with mock data.
' Side Effects:
'   None
'============================================================================
FUNCTION CanRecruitInCityRealism% (cityIndex AS INTEGER, cities() AS CityType, side AS INTEGER, realismModeEnabled AS INTEGER)
    ' Check if recruitment allowed in city (realism mode)
    ' Realism: Only in originally friendly/neutral cities
    '
    ' Parameters:
    '   cityIndex (INTEGER) - Index of city
    '   cities() (CityType) - Cities array (passed as parameter)
    '   side (INTEGER) - Side attempting to recruit (1=French, 2=Allies)
    '   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
    ' Returns:
    '   INTEGER - 1 if recruitment allowed, 0 otherwise
    
    ' Validate input
    IF cityIndex < 1 OR cityIndex > UBOUND(cities) THEN
        CanRecruitInCityRealism% = 0
        EXIT FUNCTION
    END IF
    
    IF side < 1 OR side > 2 THEN
        CanRecruitInCityRealism% = 0
        EXIT FUNCTION
    END IF
    
    CanRecruitInCityRealism% = 1 ' Default allowed
    
    IF realismModeEnabled = 1 THEN
        ' Check if city was originally friendly/neutral
        ' In realism mode, recruitment is restricted to cities that were
        ' originally owned by the recruiting side (or neutral)
        DIM originalOwner AS INTEGER
        originalOwner = cities(cityIndex).originalOwner
        
        ' Allow recruitment if city was originally neutral or owned by the recruiting side
        ' Check if recruiting side matches original owner
        IF originalOwner = CITY_NEUTRAL THEN
            ' Neutral cities can be recruited in by either side (if they currently own it)
            CanRecruitInCityRealism% = 1
        ELSEIF originalOwner = CITY_FRENCH THEN
            ' Originally French - only French (side 1) can recruit
            IF side = 1 THEN
                CanRecruitInCityRealism% = 1
            ELSE
                CanRecruitInCityRealism% = 0
            END IF
        ELSEIF originalOwner = CITY_ALLIED THEN
            ' Originally Allied - only Allies (side 2) can recruit
            IF side = 2 THEN
                CanRecruitInCityRealism% = 1
            ELSE
                CanRecruitInCityRealism% = 0
            END IF
        ELSE
            ' Unknown original owner - disallow recruitment
            CanRecruitInCityRealism% = 0
        END IF
    END IF
END FUNCTION

'============================================================================
' GetIsolatedCityRecruitment - Get recruitment size for isolated city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to check
'   cities() (CityType) - Cities array (passed as parameter)
'   cityMatrix() (INTEGER) - City connection matrix (passed as parameter)
'   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
' Returns:
'   LONG - Recruitment size in men (reduced if isolated in realism mode)
' Description:
'   Calculates recruitment size for a city, with special handling for isolated
'   cities in realism mode. An isolated city has no connection to other
'   friendly cities. In realism mode, isolated cities can only recruit at
'   1/3 of normal size, representing supply difficulties. In normal mode,
'   isolation has no effect. Accepts arrays as parameters to allow testing.
'============================================================================
FUNCTION GetIsolatedCityRecruitment& (cityIndex AS INTEGER, cities() AS CityType, cityMatrix() AS INTEGER, realismModeEnabled AS INTEGER)
    ' Get recruitment for isolated city
    ' Realism: Reduced recruitment (1/3 normal)
    '
    ' Parameters:
    '   cityIndex (INTEGER) - Index of city
    '   cities() (CityType) - Cities array (passed as parameter)
    '   cityMatrix() (INTEGER) - City connection matrix (passed as parameter)
    '   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
    ' Returns:
    '   LONG - Recruitment size in men
    
    ' Validate input
    IF cityIndex < 1 OR cityIndex > UBOUND(cities) THEN
        GetIsolatedCityRecruitment& = DEFAULT_ARMY_SIZE
        EXIT FUNCTION
    END IF
    
    DIM normalSize AS LONG
    normalSize = GetRecruitmentSize&(cityIndex, cities(), realismModeEnabled)
    
    IF realismModeEnabled = 1 THEN
        ' Check if city is isolated (no friendly cities adjacent)
        IF IsCityIsolated%(cityIndex, cities(), cityMatrix()) = 1 THEN
            GetIsolatedCityRecruitment& = normalSize \ 3 ' 1/3 normal
        ELSE
            GetIsolatedCityRecruitment& = normalSize
        END IF
    ELSE
        GetIsolatedCityRecruitment& = normalSize
    END IF
END FUNCTION

'============================================================================
' IsCityIsolated - Check if city is isolated from friendly cities
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to check
'   cities() (CityType) - Cities array (passed as parameter)
'   cityMatrix() (INTEGER) - City connection matrix (passed as parameter)
' Returns:
'   INTEGER - 1 if city is isolated, 0 if connected to friendly cities
' Description:
'   Determines if a city is isolated by checking if there is a path through
'   the city connection matrix to any other friendly city. Uses breadth-first
'   search to find connections. A city is considered isolated if no path
'   exists to any city owned by the same side. Neutral cities are never
'   considered isolated. Accepts arrays as parameters to allow testing.
'============================================================================
FUNCTION IsCityIsolated% (cityIndex AS INTEGER, cities() AS CityType, cityMatrix() AS INTEGER)
    ' Check if city is isolated (no connection to friendly cities)
    ' Uses breadth-first search to find path to any friendly city
    ' Uses cache to avoid recalculating when city ownership hasn't changed
    ' 
    ' Parameters:
    '   cityIndex (INTEGER) - Index of city to check
    '   cities() (CityType) - Cities array (passed as parameter)
    '   cityMatrix() (INTEGER) - City connection matrix (passed as parameter)
    ' Returns:
    '   INTEGER - 1 if isolated, 0 if connected
    ' Description:
    '   Accepts cities and cityMatrix arrays as parameters instead of using
    '   global state. This makes dependencies explicit and allows testing with
    '   mock data. Uses cache for performance optimization.
    
    ' Validate city index
    IF cityIndex < 1 OR cityIndex > UBOUND(cities) THEN
        IsCityIsolated% = 0 ' Invalid city, consider not isolated
        EXIT FUNCTION
    END IF
    
    ' Check cache first (only if using global arrays)
    ' Note: Cache check is skipped when using parameter arrays for testing
    ' In production, we use global arrays so cache is valid
    DIM cachedIsolation AS INTEGER
    cachedIsolation = GetCachedCityIsolation%(cityIndex)
    IF cachedIsolation >= 0 THEN
        IsCityIsolated% = cachedIsolation
        EXIT FUNCTION
    END IF
    
    DIM cityOwner AS INTEGER
    DIM visited(1 TO MAX_CITIES) AS INTEGER
    DIM queue(1 TO MAX_CITIES) AS INTEGER
    DIM queueFront AS INTEGER
    DIM queueBack AS INTEGER
    DIM currentCity AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM connectedCity AS INTEGER
    
    ' Get city owner (1=French, 2=Allied)
    IF IsCityOwnedBy%(cityIndex, 1) = 1 THEN
        cityOwner = 1
    ELSEIF IsCityOwnedBy%(cityIndex, 2) = 1 THEN
        cityOwner = 2
    ELSE
        ' Neutral cities are not considered isolated
        IsCityIsolated% = 0
        EXIT FUNCTION
    END IF
    
    ' Initialize visited array
    FOR i = 1 TO MAX_CITIES
        visited(i) = 0
    NEXT i
    
    ' Initialize queue for BFS
    queueFront = 1
    queueBack = 1
    queue(1) = cityIndex
    visited(cityIndex) = 1
    
    ' Breadth-first search for friendly cities
    DO WHILE queueFront <= queueBack
        currentCity = queue(queueFront)
        queueFront = queueFront + 1
        
        ' Validate currentCity before accessing cityMatrix
        IF currentCity < 1 OR currentCity > UBOUND(cities) THEN
            ' Invalid city in queue - skip
        ELSE
            ' Check all connected cities (up to 6 connections)
            FOR j = 1 TO 6
                ' Validate cityMatrix bounds
                IF currentCity > UBOUND(cityMatrix, 1) OR j > UBOUND(cityMatrix, 2) THEN
                    EXIT FOR
                END IF
                
                connectedCity = cityMatrix(currentCity, j)
                
                ' Skip if no connection or invalid city
                IF connectedCity <= 0 OR connectedCity > UBOUND(cities) THEN
                    ' No connection in this slot
                ELSEIF visited(connectedCity) = 1 THEN
                    ' Already visited
                ELSE
                    ' Check if this city is friendly
                    IF IsCityOwnedBy%(connectedCity, cityOwner) = 1 THEN
                        ' Found a friendly city - not isolated
                        IsCityIsolated% = 0
                        EXIT FUNCTION
                    END IF
                    
                    ' Add to queue for further search
                    queueBack = queueBack + 1
                    queue(queueBack) = connectedCity
                    visited(connectedCity) = 1
                END IF
            NEXT j
        END IF
    LOOP
    
    ' No friendly cities found - city is isolated
    DIM result AS INTEGER
    result = 1
    
    ' Cache the result
    CALL SetCachedCityIsolation(cityIndex, result)
    
    IsCityIsolated% = result
END FUNCTION

'============================================================================
' GetDefenderAdvantage - Get defender advantage multiplier for city combat
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city where combat occurs
'   cities() (CityType) - Cities array (passed as parameter)
'   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
' Returns:
'   SINGLE - Defender advantage multiplier (>1.0 = bonus)
' Description:
'   Calculates the defensive advantage multiplier for city combat. In realism
'   mode, defenders receive a 25% base bonus. Additional bonuses are applied
'   based on fortification level (0.5x per fort level). In normal mode, only
'   fortification bonuses apply. Accepts arrays as parameters to allow testing.
'============================================================================
FUNCTION GetDefenderAdvantage! (cityIndex AS INTEGER, cities() AS CityType, realismModeEnabled AS INTEGER)
    ' Get defender advantage multiplier
    ' Realism: Increased defender advantage
    '
    ' Parameters:
    '   cityIndex (INTEGER) - Index of city
    '   cities() (CityType) - Cities array (passed as parameter)
    '   realismModeEnabled (INTEGER) - Realism mode flag (0=off, 1=on)
    ' Returns:
    '   SINGLE - Defender advantage multiplier
    ' Description:
    '   Accepts cities array and realism mode as parameters instead of using
    '   global state. This makes dependencies explicit and allows testing with
    '   mock data.
    
    ' Validate input
    IF cityIndex < 1 OR cityIndex > UBOUND(cities) THEN
        GetDefenderAdvantage! = 1.0
        EXIT FUNCTION
    END IF
    
    DIM advantage AS SINGLE
    advantage = 1.0 ' Base advantage
    
    IF realismModeEnabled = 1 THEN
        advantage = 1.25 ' 25% bonus in realism mode
    END IF
    
    ' Add fortification bonus
    IF cities(cityIndex).fort > FORT_NONE THEN
        advantage = advantage * (1.0 + cities(cityIndex).fort * 0.5)
    END IF
    
    GetDefenderAdvantage! = advantage
END FUNCTION

'============================================================================
' RestoreIsolatedCities - Restore original ownership for isolated cities
'============================================================================
' Description:
'   Checks all cities for isolation and restores original ownership when
'   a city becomes isolated and is currently owned by a different side than
'   its original owner. This represents the historical reality that isolated
'   cities would often revert to their original control or become neutral.
'   Only active in realism mode. Called during the Update phase.
' Side Effects:
'   - May restore city ownership to original owner
'   - Updates income and victory points for affected sides
'   - Displays message when city ownership is restored
'   - Invalidates city isolation cache when ownership changes
'============================================================================
SUB RestoreIsolatedCities
    ' Restore original ownership for isolated cities (realism mode only)
    ' When a city becomes isolated and is owned by a different side than
    ' its original owner, restore it to original owner
    
    ' Only active in realism mode
    IF realismMode = 0 THEN EXIT SUB
    
    DIM i AS INTEGER
    DIM currentOwner AS INTEGER
    DIM originalOwner AS INTEGER
    DIM isIsolated AS INTEGER
    DIM cityName AS STRING
    DIM oldOwner AS INTEGER
    
    ' Check all cities
    FOR i = 1 TO MAX_CITIES
        ' Validate city index and skip inactive cities
        IF ValidateCityIndex%(i, "RestoreIsolatedCities") = 0 THEN
            ' Skip invalid city
        ELSEIF IsCityActive%(i) = 0 THEN
            ' Skip inactive city
        ELSE
            currentOwner = cities(i).owner
            originalOwner = cities(i).originalOwner
            
            ' Only restore if:
            ' 1. City is currently owned by a side (not neutral)
            ' 2. Current owner differs from original owner
            ' 3. City is isolated
            IF currentOwner <> CITY_NEUTRAL AND currentOwner <> originalOwner THEN
                ' Check if city is isolated
                isIsolated = IsCityIsolated%(i, cities(), cityMatrix())
                
                IF isIsolated = 1 THEN
                    ' City is isolated and owned by different side - restore original owner
                    cityName = cities(i).name
                    oldOwner = currentOwner
                    
                    ' Update ownership directly (similar to CaptureCity but without fortification reduction)
                    ' Remove from old owner's control
                    ' oldOwner cannot be CITY_NEUTRAL (0) due to condition on line 457
                    ' oldOwner should be CITY_FRENCH (1) or CITY_ALLIED (2)
                    ' CITY_AT_PEACE (3) should not appear in oldOwner
                    IF oldOwner = CITY_FRENCH OR oldOwner = CITY_ALLIED THEN
                        CALL SetGameStateControl(oldOwner, GetGameStateControl%(oldOwner) - 1)
                        CALL SetGameStateIncome(oldOwner, GetGameStateIncome&(oldOwner) - cities(i).value)
                    END IF
                    
                    ' Assign to original owner
                    cities(i).owner = originalOwner
                    ' originalOwner should be CITY_NEUTRAL (0), CITY_FRENCH (1), or CITY_ALLIED (2)
                    ' CITY_AT_PEACE (3) should not appear in originalOwner
                    IF originalOwner = CITY_FRENCH OR originalOwner = CITY_ALLIED THEN
                        CALL SetGameStateControl(originalOwner, GetGameStateControl%(originalOwner) + 1)
                        CALL SetGameStateIncome(originalOwner, GetGameStateIncome&(originalOwner) + cities(i).value)
                        ' Note: We don't award victory points again for restoration
                    END IF
                    
                    ' Display message
                    IF originalOwner = CITY_NEUTRAL THEN
                        COLOR 11: CALL clrbot: PRINT cityName + " becomes neutral (isolated from supply lines)"
                    ELSEIF originalOwner = CITY_FRENCH THEN
                        COLOR 11: CALL clrbot: PRINT cityName + " reverts to French control (isolated from supply lines)"
                    ELSEIF originalOwner = CITY_ALLIED THEN
                        COLOR 11: CALL clrbot: PRINT cityName + " reverts to Allied control (isolated from supply lines)"
                    END IF
                    
                    ' Invalidate isolation cache (ownership changed)
                    CALL InvalidateCityIsolationCache(0)
                END IF
            END IF
        END IF
    NEXT i
END SUB
