'============================================================================
' Victory Points Tests
'============================================================================
' Priority 1 tests for victory.bas
' Tests: AwardVictoryPoints, AwardBattleVictory, AwardArmyCapture, GetVictoryPoints
'
' Note: All common and strategic files are included in test_runner_all.bas

'============================================================================
' Test Suite: Victory Point Awards
'============================================================================

SUB TestAwardVictoryPointsAddsToTotal
    StartTest "VictoryTests", "test_award_victory_points_adds_to_total"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Initial victory points should be 0
    AssertEqual GetVictoryPoints&(1), 0, "Initial French VP should be 0"
    
    ' Award 10 victory points
    CALL AwardVictoryPoints(1, 10)
    
    AssertEqual GetVictoryPoints&(1), 10, "French VP should be 10 after award"
    
    ' Award more points
    CALL AwardVictoryPoints(1, 5)
    
    AssertEqual GetVictoryPoints&(1), 15, "French VP should be 15 after second award"
    
    ExecuteTest "VictoryTests", "test_award_victory_points_adds_to_total"
END SUB

SUB TestAwardBattleVictoryPoints
    StartTest "VictoryTests", "test_award_battle_victory_points"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Initial victory points should be 0
    AssertEqual GetVictoryPoints&(1), 0, "Initial French VP should be 0"
    
    ' Award battle victory (+1 VP)
    CALL AwardBattleVictory(1)
    
    AssertEqual GetVictoryPoints&(1), 1, "French VP should be 1 after battle victory"
    
    ' Award another battle victory
    CALL AwardBattleVictory(1)
    
    AssertEqual GetVictoryPoints&(1), 2, "French VP should be 2 after second battle victory"
    
    ExecuteTest "VictoryTests", "test_award_battle_victory_points"
END SUB

SUB TestAwardArmyCapturePoints
    StartTest "VictoryTests", "test_award_army_capture_points"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Initial victory points should be 0
    AssertEqual GetVictoryPoints&(1), 0, "Initial French VP should be 0"
    
    ' Award army capture (+25 VP)
    CALL AwardArmyCapture(1)
    
    AssertEqual GetVictoryPoints&(1), 25, "French VP should be 25 after army capture"
    
    ' Award another army capture
    CALL AwardArmyCapture(1)
    
    AssertEqual GetVictoryPoints&(1), 50, "French VP should be 50 after second army capture"
    
    ExecuteTest "VictoryTests", "test_award_army_capture_points"
END SUB

SUB TestAwardEndGameBonusPoints
    StartTest "VictoryTests", "test_award_end_game_bonus_points"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Initial victory points should be 0
    AssertEqual GetVictoryPoints&(1), 0, "Initial French VP should be 0"
    
    ' Award end game bonus (+100 VP)
    CALL AwardEndGameBonus(1)
    
    AssertEqual GetVictoryPoints&(1), 100, "French VP should be 100 after end game bonus"
    
    ExecuteTest "VictoryTests", "test_award_end_game_bonus_points"
END SUB

SUB TestGetVictoryPointsReturnsTotal
    StartTest "VictoryTests", "test_get_victory_points_returns_total"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Award various victory points
    CALL AwardBattleVictory(1) ' +1
    CALL AwardBattleVictory(1) ' +1
    CALL AwardArmyCapture(1) ' +25
    CALL AwardVictoryPoints(1, 10) ' +10
    
    ' Total should be 37
    AssertEqual GetVictoryPoints&(1), 37, "French VP should be 37 (1+1+25+10)"
    
    ' Test Allied side
    CALL AwardBattleVictory(2) ' +1
    CALL AwardArmyCapture(2) ' +25
    
    AssertEqual GetVictoryPoints&(2), 26, "Allied VP should be 26 (1+25)"
    
    ExecuteTest "VictoryTests", "test_get_victory_points_returns_total"
END SUB

SUB TestAwardVictoryPointsInvalidSide
    StartTest "VictoryTests", "test_award_victory_points_invalid_side"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Try to award to invalid side (0)
    CALL AwardVictoryPoints(0, 10)
    
    ' Should not crash, but points shouldn't be awarded
    ' (Validation prevents award, so VP remains 0)
    AssertEqual GetVictoryPoints&(1), 0, "VP should remain 0 for invalid side"
    
    ExecuteTest "VictoryTests", "test_award_victory_points_invalid_side"
END SUB

SUB TestVictoryPointsBothSides
    StartTest "VictoryTests", "test_victory_points_both_sides"
    
    CALL InitializeCampaign(1796)
    CALL InitializeVictoryConditions
    
    ' Award points to both sides
    CALL AwardBattleVictory(1) ' French +1
    CALL AwardBattleVictory(2) ' Allied +1
    CALL AwardArmyCapture(1) ' French +25
    CALL AwardArmyCapture(2) ' Allied +25
    
    AssertEqual GetVictoryPoints&(1), 26, "French VP should be 26"
    AssertEqual GetVictoryPoints&(2), 26, "Allied VP should be 26"
    
    ' Award more to French
    CALL AwardBattleVictory(1) ' French +1
    
    AssertEqual GetVictoryPoints&(1), 27, "French VP should be 27"
    AssertEqual GetVictoryPoints&(2), 26, "Allied VP should remain 26"
    
    ExecuteTest "VictoryTests", "test_victory_points_both_sides"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunVictoryTests
    CALL InitializeTestFramework
    CALL InitializeVictoryConditions
    
    PRINT "Running Victory Points Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Victory Point Award Tests
    CALL TestAwardVictoryPointsAddsToTotal
    CALL TestAwardBattleVictoryPoints
    CALL TestAwardArmyCapturePoints
    CALL TestAwardEndGameBonusPoints
    CALL TestGetVictoryPointsReturnsTotal
    CALL TestAwardVictoryPointsInvalidSide
    CALL TestVictoryPointsBothSides
    
    CALL PrintTestResults
END SUB

