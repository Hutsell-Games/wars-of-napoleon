'============================================================================
' Comprehensive Test Runner
'============================================================================
' Runs all Priority 1 unit tests
' Compile and run this file to execute all tests
'
' Pattern: DECLARE entry SUB, CALL it, END, then include all files
' This prevents "executable code between SUB/FUNCTIONs" errors

DECLARE SUB RunAllTests ()
CALL RunAllTests
END

' CRITICAL: Include declarations FIRST and ONLY ONCE
' All test files reference these declarations but don't include them
'$INCLUDE: 'test_declarations.bas'
'$INCLUDE: 'test_framework_simple.bas'

' Include common files ONLY ONCE (all test files need these)
'$INCLUDE: '../common/battle_types.bas'
'$INCLUDE: '../common/utilities.bas'
'$INCLUDE: '../common/error_handling.bas'
'$INCLUDE: '../common/game_state_helpers.bas'
'$INCLUDE: '../common/config.bas'

' Include strategic files ONLY ONCE (all test files need these)
'$INCLUDE: '../ui/graphics.bas'
'$INCLUDE: '../strategic/scenario.bas'
'$INCLUDE: '../strategic/campaign.bas'
'$INCLUDE: '../strategic/army.bas'
'$INCLUDE: '../strategic/city.bas'
'$INCLUDE: '../strategic/economy.bas'
'$INCLUDE: '../strategic/cohesion.bas'
'$INCLUDE: '../strategic/victory.bas'
'$INCLUDE: '../strategic/combat.bas'
'$INCLUDE: '../strategic/tactical_integration.bas'
'$INCLUDE: '../tactical/battle.bas'
'$INCLUDE: '../strategic/reports.bas'
'$INCLUDE: '../strategic/realism.bas'

'$INCLUDE: 'test_init.bas'
'$INCLUDE: 'test_campaign.bas'
'$INCLUDE: 'test_army.bas'
'$INCLUDE: 'test_city.bas'
'$INCLUDE: 'test_combat.bas'
'$INCLUDE: 'test_economy.bas'

'============================================================================
' Main Entry Point
'============================================================================
SUB RunAllTests
    ' Initialize test variables (must be after all SUB/FUNCTION declarations)
    CALL InitializeTestVariables
    
    PRINT STRING$(80, "=")
    PRINT "WARS OF NAPOLEON - UNIT TEST SUITE"
    PRINT "Priority 1: Critical Path Tests"
    PRINT STRING$(80, "=")
    PRINT
    
    ' Run all test suites
    CALL RunCampaignTests
    PRINT
    CALL RunArmyTests
    PRINT
    CALL RunCityTests
    PRINT
    CALL RunCombatTests
    PRINT
    CALL RunEconomyTests
    
    PRINT
    PRINT "Press any key to exit..."
    DO WHILE INKEY$ = "": LOOP
END SUB

