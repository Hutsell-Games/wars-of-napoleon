'============================================================================
' Realism Toggle
'============================================================================
' Ported from CWS (adapted for Napoleonic era)
' Comprehensive realism toggle affecting multiple systems

' Note: game_types.bas is included in main.bas
' Note: Config is included in declarations.bas
' Note: army.bas, city.bas are included in main.bas

' Note: realismMode is declared in declarations.bas

SUB InitializeRealism
    ' Initialize realism mode from config
    ' Will be added to config.bas
    realismMode = 0 ' Default off
END SUB

SUB SetRealismMode (enabled AS INTEGER)
    ' Set realism mode
    realismMode = enabled
    IF enabled = 1 THEN
        CALL ShowStatusMessage("Realism mode enabled", 11)
    ELSE
        CALL ShowStatusMessage("Realism mode disabled", 11)
    END IF
END SUB

FUNCTION GetRecruitmentSize& (cityIndex AS INTEGER)
    ' Get recruitment size based on city size
    ' Realism mode: City size affects recruit numbers
    ' Normal mode: Fixed recruitment
    
    DIM baseSize AS LONG
    baseSize = DEFAULT_ARMY_SIZE ' Default recruitment size
    
    IF realismMode = 1 THEN
        ' City size affects recruitment
        baseSize = cities(cityIndex).value * 100 ' Scale by city value
        IF baseSize < 5000 THEN baseSize = 5000 ' Minimum
        IF baseSize > 20000 THEN baseSize = 20000 ' Maximum
    END IF
    
    GetRecruitmentSize& = baseSize
END FUNCTION

FUNCTION CanRecruitInCityRealism% (cityIndex AS INTEGER)
    ' Check if recruitment allowed in city (realism mode)
    ' Realism: Only in originally friendly/neutral cities
    
    CanRecruitInCityRealism% = 1 ' Default allowed
    
    IF realismMode = 1 THEN
        ' Check if city was originally friendly/neutral
        ' TODO: Track original ownership for realism mode:
        '   - Store original owner when city is captured
        '   - Check if city returns to original owner when isolated
        ' For now, allow if currently owned
        IF cities(cityIndex).owner = CITY_FRENCH OR cities(cityIndex).owner = CITY_ALLIED THEN
            CanRecruitInCityRealism% = 1
        ELSE
            CanRecruitInCityRealism% = 0
        END IF
    END IF
END FUNCTION

FUNCTION GetIsolatedCityRecruitment& (cityIndex AS INTEGER)
    ' Get recruitment for isolated city
    ' Realism: Reduced recruitment (1/3 normal)
    
    DIM normalSize AS LONG
    normalSize = GetRecruitmentSize&(cityIndex)
    
    IF realismMode = 1 THEN
        ' Check if city is isolated (no friendly cities adjacent)
        IF IsCityIsolated%(cityIndex) = 1 THEN
            GetIsolatedCityRecruitment& = normalSize \ 3 ' 1/3 normal
        ELSE
            GetIsolatedCityRecruitment& = normalSize
        END IF
    ELSE
        GetIsolatedCityRecruitment& = normalSize
    END IF
END FUNCTION

FUNCTION IsCityIsolated% (cityIndex AS INTEGER)
    ' Check if city is isolated (no connection to friendly cities)
    ' Uses breadth-first search to find path to any friendly city
    ' Returns 1 if isolated, 0 if connected
    
    DIM cityOwner AS INTEGER
    DIM visited(1 TO MAX_CITIES) AS INTEGER
    DIM queue(1 TO MAX_CITIES) AS INTEGER
    DIM queueFront AS INTEGER
    DIM queueBack AS INTEGER
    DIM currentCity AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM connectedCity AS INTEGER
    
    ' Validate city index
    IF ValidateCityIndex%(cityIndex, "IsCityIsolated") = 0 THEN
        IsCityIsolated% = 0 ' Invalid city, consider not isolated
        EXIT FUNCTION
    END IF
    
    ' Get city owner (1=French, 2=Allied)
    IF cities(cityIndex).owner = CITY_FRENCH THEN
        cityOwner = 1
    ELSEIF cities(cityIndex).owner = CITY_ALLIED THEN
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
        
        ' Check all connected cities (up to 6 connections)
        FOR j = 1 TO 6
            connectedCity = cityMatrix(currentCity, j)
            
            ' Skip if no connection or invalid city
            IF connectedCity <= 0 OR connectedCity > MAX_CITIES THEN
                ' No connection in this slot
            ELSEIF visited(connectedCity) = 1 THEN
                ' Already visited
            ELSE
                ' Check if this city is friendly
                IF cities(connectedCity).owner = cityOwner THEN
                    ' Found a friendly city - not isolated
                    IsCityIsolated% = 0
                    EXIT FUNCTION
                END IF
                
                ' Mark as visited and add to queue
                visited(connectedCity) = 1
                queueBack = queueBack + 1
                IF queueBack <= MAX_CITIES THEN
                    queue(queueBack) = connectedCity
                END IF
            END IF
        NEXT j
    LOOP
    
    ' No friendly cities found - city is isolated
    IsCityIsolated% = 1
END FUNCTION

FUNCTION GetDefenderAdvantage! (cityIndex AS INTEGER)
    ' Get defender advantage multiplier
    ' Realism: Increased defender advantage
    
    DIM advantage AS SINGLE
    advantage = 1.0 ' Base advantage
    
    IF realismMode = 1 THEN
        advantage = 1.25 ' 25% bonus in realism mode
    END IF
    
    ' Add fortification bonus
    IF cities(cityIndex).fort > FORT_NONE THEN
        advantage = advantage * (1.0 + cities(cityIndex).fort * 0.5)
    END IF
    
    GetDefenderAdvantage! = advantage
END FUNCTION
