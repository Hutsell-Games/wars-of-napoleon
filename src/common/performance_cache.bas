'============================================================================
' Performance Cache Management
'============================================================================
' Provides caching for expensive calculations to improve performance:
'   - Combat strength calculations
'   - City isolation lookups
'   - Army location index for fast lookups
'
' Note: game_types.bas is included in main.bas
' Note: declarations.bas contains cache array declarations

'============================================================================
' InitializePerformanceCache - Initialize all performance caches
'============================================================================
' Description:
'   Initializes all performance cache structures to empty/invalid state.
'   Should be called at game start and when loading saved games.
' Side Effects:
'   - Clears all cache arrays
'   - Marks all cache entries as invalid
'============================================================================
SUB InitializePerformanceCache
    DIM i AS INTEGER
    DIM j AS INTEGER
    
    ' Initialize combat strength cache
    FOR i = 1 TO MAX_ARMIES
        combatStrengthCache(i) = 0
        combatStrengthCacheValid(i) = 0
    NEXT i
    
    ' Initialize city isolation cache
    FOR i = 1 TO MAX_CITIES
        cityIsolationCache(i) = 0
        cityIsolationCacheValid(i) = 0
    NEXT i
    
    ' Initialize army location index
    FOR i = 1 TO MAX_CITIES
        armyLocationIndexCount(i) = 0
        FOR j = 1 TO MAX_ARMIES
            armyLocationIndex(i, j) = 0
        NEXT j
    NEXT i
    armyLocationIndexValid = 0
END SUB

'============================================================================
' InvalidateCombatStrengthCache - Invalidate combat strength cache for army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army whose cache to invalidate (0 = all)
' Description:
'   Marks the combat strength cache entry for the specified army as invalid.
'   If armyIndex is 0, invalidates all combat strength cache entries.
'   Should be called whenever army attributes that affect combat strength change
'   (size, leadership, experience, supply, cohesion).
' Side Effects:
'   - Marks cache entry(ies) as invalid
'============================================================================
SUB InvalidateCombatStrengthCache (armyIndex AS INTEGER)
    DIM i AS INTEGER
    
    IF armyIndex = 0 THEN
        ' Invalidate all
        FOR i = 1 TO MAX_ARMIES
            combatStrengthCacheValid(i) = 0
        NEXT i
    ELSE
        ' Invalidate specific army
        IF armyIndex >= 1 AND armyIndex <= MAX_ARMIES THEN
            combatStrengthCacheValid(armyIndex) = 0
        END IF
    END IF
END SUB

'============================================================================
' GetCachedCombatStrength - Get cached combat strength or calculate if needed
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
'   calculateFunc AS LONG - Function pointer to calculate function (not used in QB64)
' Returns:
'   LONG - Cached or calculated combat strength
' Description:
'   Returns cached combat strength if valid, otherwise calculates and caches it.
'   This function should be called from CalculateCombatStrength& after calculation.
'   Note: QB64 doesn't support function pointers, so this is a helper that
'   should be called after the actual calculation.
'============================================================================
FUNCTION GetCachedCombatStrength& (armyIndex AS INTEGER)
    ' Check if cache is valid
    IF armyIndex >= 1 AND armyIndex <= MAX_ARMIES THEN
        IF combatStrengthCacheValid(armyIndex) = 1 THEN
            GetCachedCombatStrength& = combatStrengthCache(armyIndex)
            EXIT FUNCTION
        END IF
    END IF
    
    ' Cache invalid - return 0 (caller should calculate)
    GetCachedCombatStrength& = 0
END FUNCTION

'============================================================================
' SetCachedCombatStrength - Store calculated combat strength in cache
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
'   strength (LONG) - Calculated combat strength
' Description:
'   Stores the calculated combat strength in the cache and marks it as valid.
'   Should be called after calculating combat strength.
' Side Effects:
'   - Updates cache entry
'   - Marks cache entry as valid
'============================================================================
SUB SetCachedCombatStrength (armyIndex AS INTEGER, strength AS LONG)
    IF armyIndex >= 1 AND armyIndex <= MAX_ARMIES THEN
        combatStrengthCache(armyIndex) = strength
        combatStrengthCacheValid(armyIndex) = 1
    END IF
END SUB

'============================================================================
' InvalidateCityIsolationCache - Invalidate city isolation cache
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city (0 = all cities)
' Description:
'   Marks the city isolation cache entry for the specified city as invalid.
'   If cityIndex is 0, invalidates all city isolation cache entries.
'   Should be called whenever city ownership changes, as this affects isolation.
' Side Effects:
'   - Marks cache entry(ies) as invalid
'============================================================================
SUB InvalidateCityIsolationCache (cityIndex AS INTEGER)
    DIM i AS INTEGER
    
    IF cityIndex = 0 THEN
        ' Invalidate all
        FOR i = 1 TO MAX_CITIES
            cityIsolationCacheValid(i) = 0
        NEXT i
    ELSE
        ' Invalidate specific city
        IF cityIndex >= 1 AND cityIndex <= MAX_CITIES THEN
            cityIsolationCacheValid(cityIndex) = 0
        END IF
    END IF
END SUB

'============================================================================
' GetCachedCityIsolation - Get cached city isolation status
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city
' Returns:
'   INTEGER - Cached isolation status (-1 = not cached, 0 = not isolated, 1 = isolated)
' Description:
'   Returns cached isolation status if valid, otherwise returns -1 to indicate
'   cache miss. Caller should calculate and cache if -1 is returned.
'============================================================================
FUNCTION GetCachedCityIsolation% (cityIndex AS INTEGER)
    IF cityIndex >= 1 AND cityIndex <= MAX_CITIES THEN
        IF cityIsolationCacheValid(cityIndex) = 1 THEN
            GetCachedCityIsolation% = cityIsolationCache(cityIndex)
            EXIT FUNCTION
        END IF
    END IF
    
    ' Cache invalid
    GetCachedCityIsolation% = -1
END FUNCTION

'============================================================================
' SetCachedCityIsolation - Store calculated city isolation status in cache
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city
'   isolated (INTEGER) - Isolation status (0 = not isolated, 1 = isolated)
' Description:
'   Stores the calculated isolation status in the cache and marks it as valid.
'   Should be called after calculating city isolation.
' Side Effects:
'   - Updates cache entry
'   - Marks cache entry as valid
'============================================================================
SUB SetCachedCityIsolation (cityIndex AS INTEGER, isolated AS INTEGER)
    IF cityIndex >= 1 AND cityIndex <= MAX_CITIES THEN
        cityIsolationCache(cityIndex) = isolated
        cityIsolationCacheValid(cityIndex) = 1
    END IF
END SUB

'============================================================================
' RebuildArmyLocationIndex - Rebuild army location index
'============================================================================
' Description:
'   Rebuilds the army location index by scanning all armies and building
'   a lookup table that maps city indices to arrays of army indices at that location.
'   This allows O(1) lookup of armies at a location instead of O(n) scan.
' Side Effects:
'   - Rebuilds armyLocationIndex array
'   - Updates armyLocationIndexCount array
'   - Marks index as valid
'============================================================================
SUB RebuildArmyLocationIndex
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM cityLoc AS INTEGER
    
    ' Clear index
    FOR i = 1 TO MAX_CITIES
        armyLocationIndexCount(i) = 0
    NEXT i
    
    ' Build index by scanning all armies
    FOR i = 1 TO MAX_ARMIES
        IF IsArmyActive%(i) = 1 THEN
            cityLoc = armies(i).loc
            IF cityLoc >= 1 AND cityLoc <= MAX_CITIES THEN
                ' Add army to index for this city
                j = armyLocationIndexCount(cityLoc) + 1
                IF j <= MAX_ARMIES THEN
                    armyLocationIndex(cityLoc, j) = i
                    armyLocationIndexCount(cityLoc) = j
                END IF
            END IF
        END IF
    NEXT i
    
    ' Mark index as valid
    armyLocationIndexValid = 1
END SUB

'============================================================================
' InvalidateArmyLocationIndex - Invalidate army location index
'============================================================================
' Description:
'   Marks the army location index as invalid. Should be called whenever
'   an army's location changes (movement, recruitment, destruction, etc.).
'   The index will be rebuilt on next access.
' Side Effects:
'   - Marks index as invalid
'============================================================================
SUB InvalidateArmyLocationIndex
    armyLocationIndexValid = 0
END SUB

'============================================================================
' GetArmiesAtLocation - Get array of army indices at a city location
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to search
'   armyIndices() (INTEGER) - Output array of army indices
' Returns:
'   INTEGER - Number of armies found at location
' Description:
'   Returns an array of army indices located at the specified city.
'   Uses the army location index for fast lookup. Rebuilds index if invalid.
'   Returns 0 if no armies found or invalid city index.
'============================================================================
FUNCTION GetArmiesAtLocation% (cityIndex AS INTEGER, armyIndices() AS INTEGER)
    DIM i AS INTEGER
    DIM count AS INTEGER
    
    ' Validate city index
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        GetArmiesAtLocation% = 0
        EXIT FUNCTION
    END IF
    
    ' Rebuild index if invalid
    IF armyLocationIndexValid = 0 THEN
        CALL RebuildArmyLocationIndex
    END IF
    
    ' Copy army indices from index
    count = armyLocationIndexCount(cityIndex)
    FOR i = 1 TO count
        IF i <= UBOUND(armyIndices) THEN
            armyIndices(i) = armyLocationIndex(cityIndex, i)
        END IF
    NEXT i
    
    GetArmiesAtLocation% = count
END FUNCTION

'============================================================================
' GetFirstArmyAtLocation - Get first active army at a city location
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city to search
' Returns:
'   INTEGER - Index of first active army at location, or 0 if none found
' Description:
'   Returns the index of the first active army at the specified city.
'   Uses the army location index for fast lookup. This is a convenience
'   function for the common case of finding a single army at a location.
'============================================================================
FUNCTION GetFirstArmyAtLocation% (cityIndex AS INTEGER)
    DIM armyIndices(1 TO MAX_ARMIES) AS INTEGER
    DIM count AS INTEGER
    
    count = GetArmiesAtLocation%(cityIndex, armyIndices())
    
    IF count > 0 THEN
        GetFirstArmyAtLocation% = armyIndices(1)
    ELSE
        GetFirstArmyAtLocation% = 0
    END IF
END FUNCTION

