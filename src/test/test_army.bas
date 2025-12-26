'============================================================================
' Army Management Tests
'============================================================================
' Priority 1 tests for army.bas
' Tests: InitializeArmies, RecruitArmy, MoveArmy, CombineArmies, RelieveCommander, GetArmyStrength, PlaceArmy, OccupyCity

' Note: All common and strategic files are included in test_runner_all.bas

' Mock functions


' LoadCommanderData is defined in scenario.bas (included in test_runner_all.bas)

'============================================================================
' Test Suite: Army Initialization
'============================================================================

SUB TestInitializeArmiesClearsAllArmies
    StartTest "ArmyTests", "test_initialize_armies_clears_all_armies"
    
    ' Set some army data first
    armies(1).name = "Test"
    armies(1).size = 10000
    armies(5).size = 5000
    
    CALL InitializeArmies
    
    AssertEqual armies(1).size, 0, "Army 1 should be cleared"
    AssertEqual armies(5).size, 0, "Army 5 should be cleared"
    AssertStringEqual armies(1).name, "", "Army 1 name should be cleared"
    
    ExecuteTest "ArmyTests", "test_initialize_armies_clears_all_armies"
END SUB

SUB TestInitializeArmiesClearsOccupation
    StartTest "ArmyTests", "test_initialize_armies_clears_occupation"
    
    occupied(1) = 5
    occupied(10) = 15
    
    CALL InitializeArmies
    
    AssertEqual occupied(1), 0, "Occupation should be cleared"
    AssertEqual occupied(10), 0, "Occupation should be cleared"
    
    ExecuteTest "ArmyTests", "test_initialize_armies_clears_occupation"
END SUB

'============================================================================
' Test Suite: Army Recruitment
'============================================================================

SUB TestRecruitArmyFrenchSide
    StartTest "ArmyTests", "test_recruit_army_french_side"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    ' Set up a test city
    cities(1).name = "Paris"
    cities(1).nationality = NAT_FRENCH
    
    CALL RecruitArmy(1, 1, "Napoleon", 10)
    
    AssertEqual armies(1).size, 10000, "Army should have default size"
    AssertStringEqual armies(1).name, "Napoleon", "Commander name should be set"
    AssertEqual armies(1).lead, 10, "Leadership should be set"
    AssertEqual armies(1).loc, 1, "Location should be set"
    AssertEqual armies(1).move, -1, "Move should be restricted (-1)"
    AssertEqual armies(1).supply, 5, "Initial supply should be 5"
    
    ExecuteTest "ArmyTests", "test_recruit_army_french_side"
END SUB

SUB TestRecruitArmyAlliedSide
    StartTest "ArmyTests", "test_recruit_army_allied_side"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(2).name = "London"
    cities(2).nationality = NAT_ENGLISH
    
    CALL RecruitArmy(2, 2, "Wellington", 9)
    
    AssertEqual armies(21).size, 10000, "Allied army should be in slot 21"
    AssertStringEqual armies(21).name, "Wellington", "Commander name should be set"
    AssertEqual armies(21).loc, 2, "Location should be set"
    
    ExecuteTest "ArmyTests", "test_recruit_army_allied_side"
END SUB

SUB TestRecruitArmySetsNationality
    StartTest "ArmyTests", "test_recruit_army_sets_nationality"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).nationality = NAT_FRENCH
    CALL RecruitArmy(1, 1, "Napoleon", 10)
    
    AssertEqual armies(1).nationality, NAT_FRENCH, "Nationality should match city"
    
    ExecuteTest "ArmyTests", "test_recruit_army_sets_nationality"
END SUB

SUB TestRecruitArmyOccupiesCity
    StartTest "ArmyTests", "test_recruit_army_occupies_city"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    CALL RecruitArmy(1, 1, "Napoleon", 10)
    
    AssertEqual occupied(1), 1, "City should be occupied by army 1"
    
    ExecuteTest "ArmyTests", "test_recruit_army_occupies_city"
END SUB

'============================================================================
' Test Suite: Army Movement
'============================================================================

SUB TestMoveArmySetsDestination
    StartTest "ArmyTests", "test_move_army_sets_destination"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).move = 0
    
    CALL MoveArmy(1, 5)
    
    AssertEqual armies(1).move, 5, "Move destination should be set"
    
    ExecuteTest "ArmyTests", "test_move_army_sets_destination"
END SUB

SUB TestMoveArmyEmptyArmy
    StartTest "ArmyTests", "test_move_army_empty_army"
    
    CALL InitializeArmies
    armies(1).size = 0
    
    CALL MoveArmy(1, 5)
    
    AssertEqual armies(1).move, 0, "Move should not be set for empty army"
    
    ExecuteTest "ArmyTests", "test_move_army_empty_army"
END SUB

SUB TestMoveArmyRestrictedTurn
    StartTest "ArmyTests", "test_move_army_restricted_turn"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).move = -1
    
    CALL MoveArmy(1, 5)
    
    AssertEqual armies(1).move, -1, "Move should remain restricted"
    
    ExecuteTest "ArmyTests", "test_move_army_restricted_turn"
END SUB

'============================================================================
' Test Suite: Army Combining
'============================================================================

SUB TestCombineArmiesMinimumTwo
    StartTest "ArmyTests", "test_combine_armies_minimum_two"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 10000
    armies(1).loc = 1
    armies(1).lead = 5
    
    ' Try to combine with only one army
    CALL CombineArmies(1)
    
    AssertEqual armies(1).size, 10000, "Army should not be combined (only one)"
    
    ExecuteTest "ArmyTests", "test_combine_armies_minimum_two"
END SUB

SUB TestCombineArmiesSumsSizes
    StartTest "ArmyTests", "test_combine_armies_sums_sizes"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 10000
    armies(1).loc = 1
    armies(1).lead = 5
    armies(1).name = "Army1"
    
    armies(2).size = 15000
    armies(2).loc = 1
    armies(2).lead = 7
    armies(2).name = "Army2"
    
    CALL CombineArmies(1)
    
    AssertEqual armies(1).size, 25000, "Combined size should be sum (10000 + 15000)"
    AssertEqual armies(2).size, 0, "Second army should be cleared"
    
    ExecuteTest "ArmyTests", "test_combine_armies_sums_sizes"
END SUB

SUB TestCombineArmiesAveragesAttributes
    StartTest "ArmyTests", "test_combine_armies_averages_attributes"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 10000
    armies(1).loc = 1
    armies(1).lead = 5
    armies(1).exper = 2
    armies(1).supply = 3
    armies(1).name = "Army1"
    
    armies(2).size = 10000
    armies(2).loc = 1
    armies(2).lead = 7
    armies(2).exper = 4
    armies(2).supply = 5
    armies(2).name = "Army2"
    
    CALL CombineArmies(1)
    
    AssertEqual armies(1).lead, 6, "Leadership should be averaged (5+7)/2 = 6"
    AssertEqual armies(1).exper, 3, "Experience should be averaged (2+4)/2 = 3"
    AssertEqual armies(1).supply, 4, "Supply should be averaged (3+5)/2 = 4"
    
    ExecuteTest "ArmyTests", "test_combine_armies_averages_attributes"
END SUB

SUB TestCombineArmiesBestCommander
    StartTest "ArmyTests", "test_combine_armies_best_commander"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 10000
    armies(1).loc = 1
    armies(1).lead = 5
    armies(1).name = "Commander1"
    
    armies(2).size = 10000
    armies(2).loc = 1
    armies(2).lead = 8
    armies(2).name = "Commander2"
    
    CALL CombineArmies(1)
    
    AssertStringEqual armies(1).name, "Commander2", "Best commander should take leadership"
    
    ExecuteTest "ArmyTests", "test_combine_armies_best_commander"
END SUB

SUB TestCombineArmiesMaxSizeLimit
    StartTest "ArmyTests", "test_combine_armies_max_size_limit"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 200000
    armies(1).loc = 1
    armies(1).name = "Army1"
    
    armies(2).size = 250000
    armies(2).loc = 1
    armies(2).name = "Army2"
    
    CALL CombineArmies(1)
    
    ' Should not combine if exceeds 400,000
    AssertEqual armies(1).size, 200000, "Army should not be combined (exceeds limit)"
    
    ExecuteTest "ArmyTests", "test_combine_armies_max_size_limit"
END SUB

'============================================================================
' Test Suite: Commander Relief
'============================================================================

SUB TestRelieveCommanderAssignsNewCommander
    StartTest "ArmyTests", "test_relieve_commander_assigns_new_commander"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).name = "OldCommander"
    armies(1).lead = 5
    
    CALL RelieveCommander(1, "NewCommander", 7)
    
    AssertStringEqual armies(1).name, "NewCommander", "New commander should be assigned"
    AssertEqual armies(1).lead, 7, "New leadership rating should be set"
    
    ExecuteTest "ArmyTests", "test_relieve_commander_assigns_new_commander"
END SUB

SUB TestRelieveCommanderAppliesPenalty
    StartTest "ArmyTests", "test_relieve_commander_applies_penalty"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).lead = 8
    armies(1).exper = 5
    
    CALL RelieveCommander(1, "NewCommander", 7)
    
    AssertEqual armies(1).lead, 7, "Leadership should be new rating (penalty already applied)"
    AssertEqual armies(1).exper, 4, "Experience should be reduced by 1"
    
    ExecuteTest "ArmyTests", "test_relieve_commander_applies_penalty"
END SUB

SUB TestRelieveCommanderMinimumValues
    StartTest "ArmyTests", "test_relieve_commander_minimum_values"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).lead = 1
    armies(1).exper = 0
    
    CALL RelieveCommander(1, "NewCommander", 5)
    
    AssertGreaterThanOrEqual armies(1).lead, 1, "Leadership should not go below 1"
    AssertGreaterThanOrEqual armies(1).exper, 0, "Experience should not go below 0"
    
    ExecuteTest "ArmyTests", "test_relieve_commander_minimum_values"
END SUB

'============================================================================
' Test Suite: Army Strength
'============================================================================

SUB TestGetArmyStrengthFrenchSide
    StartTest "ArmyTests", "test_get_army_strength_french_side"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(2).size = 15000
    armies(5).size = 20000
    
    DIM strength AS LONG
    strength = GetArmyStrength&(1)
    
    AssertEqual strength, 45000, "Total French strength should be sum"
    
    ExecuteTest "ArmyTests", "test_get_army_strength_french_side"
END SUB

SUB TestGetArmyStrengthAlliedSide
    StartTest "ArmyTests", "test_get_army_strength_allied_side"
    
    CALL InitializeArmies
    armies(21).size = 12000
    armies(22).size = 18000
    
    DIM strength AS LONG
    strength = GetArmyStrength&(2)
    
    AssertEqual strength, 30000, "Total Allied strength should be sum"
    
    ExecuteTest "ArmyTests", "test_get_army_strength_allied_side"
END SUB

'============================================================================
' Test Suite: Army Placement
'============================================================================

SUB TestPlaceArmyUpdatesOccupation
    StartTest "ArmyTests", "test_place_army_updates_occupation"
    
    CALL InitializeArmies
    armies(1).loc = 5
    
    CALL PlaceArmy(1)
    
    AssertEqual occupied(5), 1, "City should be occupied by army 1"
    
    ExecuteTest "ArmyTests", "test_place_army_updates_occupation"
END SUB

'============================================================================
' Test Suite: City Occupation
'============================================================================

SUB TestOccupyCityFindsBestArmy
    StartTest "ArmyTests", "test_occupy_city_finds_best_army"
    
    CALL InitializeArmies
    CALL InitializeCities
    
    cities(1).name = "Paris"
    armies(1).size = 10000
    armies(1).loc = 1
    
    armies(2).size = 20000
    armies(2).loc = 1
    
    CALL OccupyCity(1)
    
    AssertEqual occupied(1), 2, "Largest army should occupy city"
    
    ExecuteTest "ArmyTests", "test_occupy_city_finds_best_army"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunArmyTests
    CALL InitializeTestFramework
    
    PRINT "Running Army Management Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Initialization Tests
    CALL TestInitializeArmiesClearsAllArmies
    CALL TestInitializeArmiesClearsOccupation
    
    ' Recruitment Tests
    CALL TestRecruitArmyFrenchSide
    CALL TestRecruitArmyAlliedSide
    CALL TestRecruitArmySetsNationality
    CALL TestRecruitArmyOccupiesCity
    
    ' Movement Tests
    CALL TestMoveArmySetsDestination
    CALL TestMoveArmyEmptyArmy
    CALL TestMoveArmyRestrictedTurn
    
    ' Combining Tests
    CALL TestCombineArmiesMinimumTwo
    CALL TestCombineArmiesSumsSizes
    CALL TestCombineArmiesAveragesAttributes
    CALL TestCombineArmiesBestCommander
    CALL TestCombineArmiesMaxSizeLimit
    
    ' Commander Relief Tests
    CALL TestRelieveCommanderAssignsNewCommander
    CALL TestRelieveCommanderAppliesPenalty
    CALL TestRelieveCommanderMinimumValues
    
    ' Strength Tests
    CALL TestGetArmyStrengthFrenchSide
    CALL TestGetArmyStrengthAlliedSide
    
    ' Placement Tests
    CALL TestPlaceArmyUpdatesOccupation
    
    ' Occupation Tests
    CALL TestOccupyCityFindsBestArmy
    
    CALL PrintTestResults
END SUB

