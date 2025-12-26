'============================================================================
' Combat Resolution Tests
'============================================================================
' Priority 1 tests for combat.bas
' Tests: CalculateCombatStrength, CalculateDefenderBonus, ApplyCombatCasualties, DetermineCombatWinner

' Note: All common and strategic files are included in test_runner_all.bas

' Mock functions


' LoadCommanderData is defined in scenario.bas (included in test_runner_all.bas)

' InitializeCohesion is defined in cohesion.bas (included in test_runner_all.bas)
' InitializeVictoryConditions is defined in victory.bas (included in test_runner_all.bas)

SUB MockUpdateBattleStats (winner AS INTEGER, attackerCas AS LONG, defenderCas AS LONG)
    ' Mock - update battle statistics
    ' Renamed from UpdateBattleStats to avoid conflict with reports.bas
END SUB

SUB MockProcessRetreat (armyIndex AS INTEGER, cityIndex AS INTEGER)
    ' Mock - process retreat
    ' Renamed from ProcessRetreat to avoid conflict with tactical_integration.bas
END SUB

' AwardArmyCapture is defined in victory.bas (included in test_runner_all.bas)

' AwardBattleVictory is defined in victory.bas (included in test_runner_all.bas)
' RecordBattleHistory is defined in victory.bas (included in test_runner_all.bas)
' GetDefenderAdvantage is defined in realism.bas (included in test_runner_all.bas)

'============================================================================
' Test Suite: Combat Strength Calculation
'============================================================================

SUB TestCalculateCombatStrengthBaseSize
    StartTest "CombatTests", "test_calculate_combat_strength_base_size"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).lead = 5
    armies(1).exper = 0
    armies(1).supply = 5
    
    DIM strength AS LONG
    strength = CalculateCombatStrength&(1)
    
    ' Base strength with leadership 5 (no modifier) and experience 0 (no modifier)
    ' Should be approximately 10000
    AssertGreaterThan strength, 9000, "Strength should be close to base size"
    AssertLessThan strength, 11000, "Strength should be close to base size"
    
    ExecuteTest "CombatTests", "test_calculate_combat_strength_base_size"
END SUB

SUB TestCalcCombatStrengthLeadershipMod
    StartTest "CombatTests", "test_calculate_combat_strength_leadership_modifier"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).lead = 10
    armies(1).exper = 0
    armies(1).supply = 5
    
    DIM strength AS LONG
    strength = CalculateCombatStrength&(1)
    
    ' Leadership 10: effectiveness = 1.0 + (10-5)*0.1 = 1.5
    ' Should be approximately 15000
    AssertGreaterThan strength, 14000, "High leadership should increase strength"
    
    ExecuteTest "CombatTests", "test_calculate_combat_strength_leadership_modifier"
END SUB

SUB TestCalcCombatStrengthSupplyPenalty
    StartTest "CombatTests", "test_calculate_combat_strength_supply_penalty"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(1).lead = 5
    armies(1).exper = 0
    armies(1).supply = 0
    
    DIM strength AS LONG
    strength = CalculateCombatStrength&(1)
    
    ' Out of supply: 50% penalty
    ' Should be approximately 5000
    AssertLessThan strength, 6000, "Out of supply should reduce strength significantly"
    
    ExecuteTest "CombatTests", "test_calculate_combat_strength_supply_penalty"
END SUB

'============================================================================
' Test Suite: Defender Bonus
'============================================================================

SUB TestCalcDefenderBonusNoFortification
    StartTest "CombatTests", "test_calculate_defender_bonus_no_fortification"
    
    CALL InitializeCities
    cities(1).fort = FORT_NONE
    realismMode = 0
    
    DIM bonus AS SINGLE
    bonus = CalculateDefenderBonus!(1)
    
    AssertEqualFloat bonus, 1.0, 0.01, "No fortification should give no bonus"
    
    ExecuteTest "CombatTests", "test_calculate_defender_bonus_no_fortification"
END SUB

SUB TestCalculateDefenderBonusFortPlus
    StartTest "CombatTests", "test_calculate_defender_bonus_fort_plus"
    
    CALL InitializeCities
    cities(1).fort = FORT_PLUS
    realismMode = 0
    
    DIM bonus AS SINGLE
    bonus = CalculateDefenderBonus!(1)
    
    AssertEqualFloat bonus, 1.5, 0.01, "FORT_PLUS should give 50% bonus"
    
    ExecuteTest "CombatTests", "test_calculate_defender_bonus_fort_plus"
END SUB

SUB TestCalculateDefenderBonusFortPlusPlus
    StartTest "CombatTests", "test_calculate_defender_bonus_fort_plus_plus"
    
    CALL InitializeCities
    cities(1).fort = FORT_PLUS_PLUS
    realismMode = 0
    
    DIM bonus AS SINGLE
    bonus = CalculateDefenderBonus!(1)
    
    AssertEqualFloat bonus, 2.0, 0.01, "FORT_PLUS_PLUS should give 100% bonus"
    
    ExecuteTest "CombatTests", "test_calculate_defender_bonus_fort_plus_plus"
END SUB

'============================================================================
' Test Suite: Combat Casualties
'============================================================================

SUB TestApplyCombatCasualtiesAttackerWins
    StartTest "CombatTests", "test_apply_combat_casualties_attacker_wins"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(2).size = 10000
    
    CALL ApplyCombatCasualties(1, 2, 1)
    
    ' Attacker wins: 10% attacker, 15% defender
    AssertEqual armies(1).size, 9000, "Attacker should lose 10% (1000)"
    AssertEqual armies(2).size, 8500, "Defender should lose 15% (1500)"
    
    ExecuteTest "CombatTests", "test_apply_combat_casualties_attacker_wins"
END SUB

SUB TestApplyCombatCasualtiesDefenderWins
    StartTest "CombatTests", "test_apply_combat_casualties_defender_wins"
    
    CALL InitializeArmies
    armies(1).size = 10000
    armies(2).size = 10000
    
    CALL ApplyCombatCasualties(1, 2, 2)
    
    ' Defender wins: 15% attacker, 10% defender
    AssertEqual armies(1).size, 8500, "Attacker should lose 15% (1500)"
    AssertEqual armies(2).size, 9000, "Defender should lose 10% (1000)"
    
    ExecuteTest "CombatTests", "test_apply_combat_casualties_defender_wins"
END SUB

SUB TestApplyCombatCasualtiesNonNegative
    StartTest "CombatTests", "test_apply_combat_casualties_non_negative"
    
    CALL InitializeArmies
    armies(1).size = 100
    armies(2).size = 50
    
    CALL ApplyCombatCasualties(1, 2, 1)
    
    AssertGreaterThanOrEqual armies(1).size, 0, "Size should not go negative"
    AssertGreaterThanOrEqual armies(2).size, 0, "Size should not go negative"
    
    ExecuteTest "CombatTests", "test_apply_combat_casualties_non_negative"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunCombatTests
    CALL InitializeTestFramework
    CALL InitializeCohesion
    CALL InitializeVictoryConditions
    realismMode = 0
    
    PRINT "Running Combat Resolution Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Combat Strength Tests
    CALL TestCalculateCombatStrengthBaseSize
    CALL TestCalcCombatStrengthLeadershipMod
    CALL TestCalcCombatStrengthSupplyPenalty
    
    ' Defender Bonus Tests
    CALL TestCalcDefenderBonusNoFortification
    CALL TestCalculateDefenderBonusFortPlus
    CALL TestCalculateDefenderBonusFortPlusPlus
    
    ' Casualties Tests
    CALL TestApplyCombatCasualtiesAttackerWins
    CALL TestApplyCombatCasualtiesDefenderWins
    CALL TestApplyCombatCasualtiesNonNegative
    
    CALL PrintTestResults
END SUB

