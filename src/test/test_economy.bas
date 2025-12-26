'============================================================================
' Economy System Tests
'============================================================================
' Priority 1 tests for economy.bas
' Tests: UpdateIncome, AutoSupply, ManualSupply, ConsumeSupply, Cost queries, IsOutOfSupply

' Note: All common and strategic files are included in test_runner_all.bas

' Mock functions


' LoadCommanderData is defined in scenario.bas (included in test_runner_all.bas)

'============================================================================
' Test Suite: Income Updates
'============================================================================

SUB TestUpdateIncomeCalculatesFromCities
    StartTest "EconomyTests", "test_update_income_calculates_from_cities"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    cities(1).owner = CITY_FRENCH
    cities(1).value = 100
    cities(2).owner = CITY_FRENCH
    cities(2).value = 150
    
    CALL UpdateIncome
    
    AssertEqual GetGameStateIncome&(1), 250, "French income should be 250"
    AssertEqual GetGameStateCash&(1), 250, "Cash should be increased by income"
    
    ExecuteTest "EconomyTests", "test_update_income_calculates_from_cities"
END SUB

SUB TestUpdateIncomeCapsAtMaximum
    StartTest "EconomyTests", "test_update_income_caps_at_maximum"
    
    CALL InitializeCities
    CALL InitializeCampaign(1796)
    CALL SetGameStateCash(1, 19900)
    cities(1).owner = CITY_FRENCH
    cities(1).value = 200
    
    CALL UpdateIncome
    
    AssertEqual GetGameStateCash&(1), 19999, "Cash should be capped at 19999"
    
    ExecuteTest "EconomyTests", "test_update_income_caps_at_maximum"
END SUB

'============================================================================
' Test Suite: Automatic Supply
'============================================================================

SUB TestAutoSupplyHarvestMonthFree
    StartTest "EconomyTests", "test_auto_supply_harvest_month_free"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    gameState.month = 7
    armies(1).size = 10000
    armies(1).supply = 5
    
    CALL AutoSupply
    
    AssertEqual armies(1).supply, 6, "Supply should increase in harvest month"
    
    ExecuteTest "EconomyTests", "test_auto_supply_harvest_month_free"
END SUB

SUB TestAutoSupplyCapsAt10
    StartTest "EconomyTests", "test_auto_supply_caps_at_10"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    gameState.month = 7
    armies(1).size = 10000
    armies(1).supply = 10
    
    CALL AutoSupply
    
    AssertEqual armies(1).supply, 10, "Supply should not exceed 10"
    
    ExecuteTest "EconomyTests", "test_auto_supply_caps_at_10"
END SUB

'============================================================================
' Test Suite: Manual Supply
'============================================================================

SUB TestManualSupplyIncreasesSupply
    StartTest "EconomyTests", "test_manual_supply_increases_supply"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    armies(1).size = 10000
    armies(1).supply = 5
    gameState.side = 1
    CALL SetGameStateCash(1, 1000)
    
    CALL ManualSupply(1)
    
    AssertEqual armies(1).supply, 6, "Supply should increase"
    AssertLessThan GetGameStateCash&(1), 1000, "Cash should be reduced"
    
    ExecuteTest "EconomyTests", "test_manual_supply_increases_supply"
END SUB

SUB TestManualSupplyCapsAt10
    StartTest "EconomyTests", "test_manual_supply_caps_at_10"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    armies(1).size = 10000
    armies(1).supply = 10
    gameState.side = 1
    CALL SetGameStateCash(1, 1000)
    
    CALL ManualSupply(1)
    
    AssertEqual armies(1).supply, 10, "Supply should not exceed 10"
    
    ExecuteTest "EconomyTests", "test_manual_supply_caps_at_10"
END SUB

'============================================================================
' Test Suite: Supply Consumption
'============================================================================

SUB TestConsumeSupplyReducesByOne
    StartTest "EconomyTests", "test_consume_supply_reduces_by_one"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    gameState.month = 6
    armies(1).size = 10000
    armies(1).supply = 5
    
    CALL ConsumeSupply
    
    AssertEqual armies(1).supply, 4, "Supply should be reduced by 1"
    
    ExecuteTest "EconomyTests", "test_consume_supply_reduces_by_one"
END SUB

SUB TestConsumeSupplyHarvestMonthSkip
    StartTest "EconomyTests", "test_consume_supply_harvest_month_skip"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    gameState.month = 7
    armies(1).size = 10000
    armies(1).supply = 5
    
    CALL ConsumeSupply
    
    AssertEqual armies(1).supply, 5, "Supply should not be consumed in harvest month"
    
    ExecuteTest "EconomyTests", "test_consume_supply_harvest_month_skip"
END SUB

SUB TestConsumeSupplyNonNegative
    StartTest "EconomyTests", "test_consume_supply_non_negative"
    
    CALL InitializeArmies
    CALL InitializeCampaign(1796)
    gameState.month = 6
    armies(1).size = 10000
    armies(1).supply = 0
    
    CALL ConsumeSupply
    
    AssertEqual armies(1).supply, 0, "Supply should not go below 0"
    
    ExecuteTest "EconomyTests", "test_consume_supply_non_negative"
END SUB

'============================================================================
' Test Suite: Cost Queries
'============================================================================

SUB TestGetRecruitmentCost
    StartTest "EconomyTests", "test_get_recruitment_cost"
    
    DIM cost AS INTEGER
    cost = GetRecruitmentCost%
    
    AssertEqual cost, 100, "Recruitment cost should be 100"
    
    ExecuteTest "EconomyTests", "test_get_recruitment_cost"
END SUB

SUB TestGetFortificationCost
    StartTest "EconomyTests", "test_get_fortification_cost"
    
    DIM cost AS INTEGER
    cost = GetFortificationCost%
    
    AssertEqual cost, 200, "Fortification cost should be 200"
    
    ExecuteTest "EconomyTests", "test_get_fortification_cost"
END SUB

SUB TestGetShipCost
    StartTest "EconomyTests", "test_get_ship_cost"
    
    DIM cost AS INTEGER
    cost = GetShipCost%
    
    AssertEqual cost, 100, "Ship cost should be 100"
    
    ExecuteTest "EconomyTests", "test_get_ship_cost"
END SUB

'============================================================================
' Test Suite: Supply Status
'============================================================================

SUB TestIsOutOfSupplyZeroSupply
    StartTest "EconomyTests", "test_is_out_of_supply_zero_supply"
    
    CALL InitializeArmies
    armies(1).supply = 0
    
    AssertTrue IsOutOfSupply%(1), "Should be out of supply when supply = 0"
    
    ExecuteTest "EconomyTests", "test_is_out_of_supply_zero_supply"
END SUB

SUB TestIsOutOfSupplyHasSupply
    StartTest "EconomyTests", "test_is_out_of_supply_has_supply"
    
    CALL InitializeArmies
    armies(1).supply = 5
    
    AssertFalse IsOutOfSupply%(1), "Should not be out of supply when supply > 0"
    
    ExecuteTest "EconomyTests", "test_is_out_of_supply_has_supply"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunEconomyTests
    CALL InitializeTestFramework
    
    PRINT "Running Economy System Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Income Tests
    CALL TestUpdateIncomeCalculatesFromCities
    CALL TestUpdateIncomeCapsAtMaximum
    
    ' Auto Supply Tests
    CALL TestAutoSupplyHarvestMonthFree
    CALL TestAutoSupplyCapsAt10
    
    ' Manual Supply Tests
    CALL TestManualSupplyIncreasesSupply
    CALL TestManualSupplyCapsAt10
    
    ' Supply Consumption Tests
    CALL TestConsumeSupplyReducesByOne
    CALL TestConsumeSupplyHarvestMonthSkip
    CALL TestConsumeSupplyNonNegative
    
    ' Cost Query Tests
    CALL TestGetRecruitmentCost
    CALL TestGetFortificationCost
    CALL TestGetShipCost
    
    ' Supply Status Tests
    CALL TestIsOutOfSupplyZeroSupply
    CALL TestIsOutOfSupplyHasSupply
    
    CALL PrintTestResults
END SUB

