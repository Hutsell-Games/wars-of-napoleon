'============================================================================
' City Management Tests
'============================================================================
' Priority 1 tests for city.bas
' Tests: InitializeCities, CaptureCity, FortifyCity, GetCityIncome, GetCityVictoryPoints, GetCityNationality

' Note: All common and strategic files are included in test_runner_all.bas

' Mock functions

'============================================================================
' Test Suite: City Initialization
'============================================================================

SUB TestInitializeCitiesClearsAllCities
    StartTest "CityTests", "test_initialize_cities_clears_all_cities"
    
    ' Set some city data first
    cities(1).name = "Paris"
    cities(1).value = 100
    cities(5).value = 50
    
    CALL InitializeCities
    
    AssertStringEqual cities(1).name, "", "City 1 name should be cleared"
    AssertEqual cities(1).value, 0, "City 1 value should be cleared"
    AssertEqual cities(5).value, 0, "City 5 value should be cleared"
    
    ExecuteTest "CityTests", "test_initialize_cities_clears_all_cities"
END SUB

SUB TestInitializeCitiesClearsCityMatrix
    StartTest "CityTests", "test_initialize_cities_clears_city_matrix"
    
    cityMatrix(1, 1) = 5
    cityMatrix(1, 7) = 1
    
    CALL InitializeCities
    
    AssertEqual cityMatrix(1, 1), 0, "City matrix should be cleared"
    AssertEqual cityMatrix(1, 7), 0, "Port flag should be cleared"
    
    ExecuteTest "CityTests", "test_initialize_cities_clears_city_matrix"
END SUB

'============================================================================
' Test Suite: City Capture
'============================================================================

SUB TestCaptureCityChangesOwner
    StartTest "CityTests", "test_capture_city_changes_owner"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    
    CALL CaptureCity(1, CITY_ALLIED)
    
    AssertEqual cities(1).owner, CITY_ALLIED, "Owner should change to Allied"
    
    ExecuteTest "CityTests", "test_capture_city_changes_owner"
END SUB

SUB TestCaptureCityUpdatesOldOwnerStats
    StartTest "CityTests", "test_capture_city_updates_old_owner_stats"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    CALL SetGameStateControl(1, 5)
    CALL SetGameStateIncome(1, 500)
    
    CALL CaptureCity(1, CITY_ALLIED)
    
    AssertEqual GetGameStateControl%(1), 4, "French should lose 1 city"
    AssertEqual GetGameStateIncome&(1), 400, "French should lose 100 income"
    
    ExecuteTest "CityTests", "test_capture_city_updates_old_owner_stats"
END SUB

SUB TestCaptureCityUpdatesNewOwnerStats
    StartTest "CityTests", "test_capture_city_updates_new_owner_stats"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    CALL SetGameStateControl(2, 3)
    CALL SetGameStateIncome(2, 300)
    
    CALL CaptureCity(1, CITY_ALLIED)
    
    AssertEqual GetGameStateControl%(2), 4, "Allies should gain 1 city"
    AssertEqual GetGameStateIncome&(2), 400, "Allies should gain 100 income"
    
    ExecuteTest "CityTests", "test_capture_city_updates_new_owner_stats"
END SUB

SUB TestCaptureCityAwardsVictoryPoints
    StartTest "CityTests", "test_capture_city_awards_victory_points"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).owner = CITY_NEUTRAL
    cities(1).value = 100
    CALL SetGameStateVictory(1, 0)
    
    CALL CaptureCity(1, CITY_FRENCH)
    
    AssertEqual GetGameStateVictory&(1), 100, "Should award 100 victory points"
    
    ExecuteTest "CityTests", "test_capture_city_awards_victory_points"
END SUB

SUB TestCaptureCityObjectiveBonus
    StartTest "CityTests", "test_capture_city_objective_bonus"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).owner = CITY_NEUTRAL
    cities(1).value = 100
    cities(1).objective = 1
    CALL SetGameStateVictory(1, 0)
    
    CALL CaptureCity(1, CITY_FRENCH)
    
    AssertEqual GetGameStateVictory&(1), 200, "Should award 100 + 100 bonus = 200 VP"
    
    ExecuteTest "CityTests", "test_capture_city_objective_bonus"
END SUB

SUB TestCaptureCityReducesFortification
    StartTest "CityTests", "test_capture_city_reduces_fortification"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).fort = FORT_PLUS_PLUS
    
    CALL CaptureCity(1, CITY_FRENCH)
    
    AssertEqual cities(1).fort, FORT_PLUS, "Fortification should be reduced by 1"
    
    ExecuteTest "CityTests", "test_capture_city_reduces_fortification"
END SUB

SUB TestCaptureCityMinimumFortification
    StartTest "CityTests", "test_capture_city_minimum_fortification"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).fort = FORT_NONE
    
    CALL CaptureCity(1, CITY_FRENCH)
    
    AssertEqual cities(1).fort, FORT_NONE, "Fortification should not go below FORT_NONE"
    
    ExecuteTest "CityTests", "test_capture_city_minimum_fortification"
END SUB

'============================================================================
' Test Suite: City Fortification
'============================================================================

SUB TestFortifyCityIncreasesLevel
    StartTest "CityTests", "test_fortify_city_increases_level"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).fort = FORT_NONE
    gameState.side = 1
    CALL SetGameStateCash(1, 500)
    
    CALL FortifyCity(1)
    
    AssertEqual cities(1).fort, FORT_PLUS, "Fortification should increase to FORT_PLUS"
    AssertEqual GetGameStateCash&(1), 300, "Cash should be reduced by 200"
    
    ExecuteTest "CityTests", "test_fortify_city_increases_level"
END SUB

SUB TestFortifyCityMaximumLevel
    StartTest "CityTests", "test_fortify_city_maximum_level"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).fort = FORT_PLUS_PLUS
    gameState.side = 1
    CALL SetGameStateCash(1, 500)
    
    CALL FortifyCity(1)
    
    AssertEqual cities(1).fort, FORT_PLUS_PLUS, "Fortification should remain at maximum"
    AssertEqual GetGameStateCash&(1), 500, "Cash should not be reduced"
    
    ExecuteTest "CityTests", "test_fortify_city_maximum_level"
END SUB

SUB TestFortifyCityInsufficientFunds
    StartTest "CityTests", "test_fortify_city_insufficient_funds"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).name = "Paris"
    cities(1).fort = FORT_NONE
    gameState.side = 1
    CALL SetGameStateCash(1, 100)
    
    CALL FortifyCity(1)
    
    AssertEqual cities(1).fort, FORT_NONE, "Fortification should not increase"
    AssertEqual GetGameStateCash&(1), 100, "Cash should not be reduced"
    
    ExecuteTest "CityTests", "test_fortify_city_insufficient_funds"
END SUB

'============================================================================
' Test Suite: City Income
'============================================================================

SUB TestGetCityIncomeFrenchSide
    StartTest "CityTests", "test_get_city_income_french_side"
    
    CALL InitializeCities
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    cities(2).owner = CITY_FRENCH
    cities(2).value = 150
    
    DIM income AS LONG
    income = GetCityIncome&(1)
    
    AssertEqual income, 250, "French income should be sum of cities (100 + 150)"
    
    ExecuteTest "CityTests", "test_get_city_income_french_side"
END SUB

SUB TestGetCityIncomeAlliedSide
    StartTest "CityTests", "test_get_city_income_allied_side"
    
    CALL InitializeCities
    cities(1).owner = CITY_ALLIED
    cities(1).value = 200
    cities(3).owner = CITY_ALLIED
    cities(3).value = 75
    
    DIM income AS LONG
    income = GetCityIncome&(2)
    
    AssertEqual income, 275, "Allied income should be sum of cities (200 + 75)"
    
    ExecuteTest "CityTests", "test_get_city_income_allied_side"
END SUB

SUB TestGetCityIncomeExcludesOtherSide
    StartTest "CityTests", "test_get_city_income_excludes_other_side"
    
    CALL InitializeCities
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    cities(2).owner = CITY_ALLIED
    cities(2).value = 200
    
    DIM income AS LONG
    income = GetCityIncome&(1)
    
    AssertEqual income, 100, "Should only include French cities"
    
    ExecuteTest "CityTests", "test_get_city_income_excludes_other_side"
END SUB

'============================================================================
' Test Suite: City Victory Points
'============================================================================

SUB TestGetCityVictoryPointsFrenchSide
    StartTest "CityTests", "test_get_city_victory_points_french_side"
    
    CALL InitializeCities
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    cities(2).owner = CITY_FRENCH
    cities(2).value = 150
    
    DIM vp AS LONG
    vp = GetCityVictoryPoints&(1)
    
    AssertEqual vp, 250, "French VP should be sum of cities (100 + 150)"
    
    ExecuteTest "CityTests", "test_get_city_victory_points_french_side"
END SUB

SUB TestGetCityVPIncludesObjectiveBonus
    StartTest "CityTests", "test_get_city_victory_points_includes_objective_bonus"
    
    CALL InitializeCities
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    cities(1).objective = 1
    cities(2).owner = CITY_FRENCH
    cities(2).value = 150
    
    DIM vp AS LONG
    vp = GetCityVictoryPoints&(1)
    
    AssertEqual vp, 350, "VP should include objective bonus (100 + 100 + 150)"
    
    ExecuteTest "CityTests", "test_get_city_victory_points_includes_objective_bonus"
END SUB

'============================================================================
' Test Suite: City Nationality
'============================================================================

SUB TestGetCityNationalityReturnsValue
    StartTest "CityTests", "test_get_city_nationality_returns_value"
    
    CALL InitializeCities
    cities(1).nationality = NAT_FRENCH
    
    DIM nationality AS INTEGER
    nationality = GetCityNationality%(1)
    
    AssertEqual nationality, NAT_FRENCH, "Should return city nationality"
    
    ExecuteTest "CityTests", "test_get_city_nationality_returns_value"
END SUB

'============================================================================
' Test Suite: Fortification Destruction
'============================================================================

SUB TestRazeFortificationsSetsToNone
    StartTest "CityTests", "test_raze_fortifications_sets_to_none"
    
    CALL InitializeCities
    cities(1).name = "Paris"
    cities(1).fort = FORT_PLUS_PLUS
    
    CALL RazeFortifications(1)
    
    AssertEqual cities(1).fort, FORT_NONE, "Fortification should be set to FORT_NONE"
    
    ExecuteTest "CityTests", "test_raze_fortifications_sets_to_none"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunCityTests
    CALL InitializeTestFramework
    
    PRINT "Running City Management Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Initialization Tests
    CALL TestInitializeCitiesClearsAllCities
    CALL TestInitializeCitiesClearsCityMatrix
    
    ' Capture Tests
    CALL TestCaptureCityChangesOwner
    CALL TestCaptureCityUpdatesOldOwnerStats
    CALL TestCaptureCityUpdatesNewOwnerStats
    CALL TestCaptureCityAwardsVictoryPoints
    CALL TestCaptureCityObjectiveBonus
    CALL TestCaptureCityReducesFortification
    CALL TestCaptureCityMinimumFortification
    
    ' Fortification Tests
    CALL TestFortifyCityIncreasesLevel
    CALL TestFortifyCityMaximumLevel
    CALL TestFortifyCityInsufficientFunds
    
    ' Income Tests
    CALL TestGetCityIncomeFrenchSide
    CALL TestGetCityIncomeAlliedSide
    CALL TestGetCityIncomeExcludesOtherSide
    
    ' Victory Points Tests
    CALL TestGetCityVictoryPointsFrenchSide
    CALL TestGetCityVPIncludesObjectiveBonus
    
    ' Nationality Tests
    CALL TestGetCityNationalityReturnsValue
    
    ' Fortification Destruction Tests
    CALL TestRazeFortificationsSetsToNone
    
    CALL PrintTestResults
END SUB

