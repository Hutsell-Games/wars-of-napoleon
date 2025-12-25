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
        COLOR 11: CALL clrbot: PRINT "Realism mode enabled"
    ELSE
        COLOR 11: CALL clrbot: PRINT "Realism mode disabled"
    END IF
END SUB

FUNCTION GetRecruitmentSize& (cityIndex AS INTEGER)
    ' Get recruitment size based on city size
    ' Realism mode: City size affects recruit numbers
    ' Normal mode: Fixed recruitment
    
    DIM baseSize AS LONG
    baseSize = 10000 ' Default recruitment size
    
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
        ' This requires tracking original ownership (to be implemented)
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
    ' Check if city is isolated (no friendly adjacent cities)
    ' Placeholder - will check city matrix connections
    
    IsCityIsolated% = 0 ' Default not isolated
    ' TODO: Implement isolation check
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
