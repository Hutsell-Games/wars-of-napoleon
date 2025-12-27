'============================================================================
' Comprehensive Test Runner
'============================================================================
' Runs all Priority 1 unit tests
' Compile and run this file to execute all tests
'
' Pattern: Include all files with CONST/type definitions FIRST,
' then DECLARE entry SUB, then include test files, then main code
' This prevents "executable code between SUB/FUNCTIONs" errors

' CRITICAL: Include files with CONST/type definitions FIRST
' These must come before any SUB/FUNCTION declarations

' Include common files with type definitions only (no SUB/FUNCTION)
'$INCLUDE: '../common/battle_types.bas'

' Include test declarations CONSTANTS FIRST (before any SUB/FUNCTION declarations)
'$INCLUDE: 'declarations_test.bas'

' Include tactical core files (they have CONST declarations)
' These must come before any SUB/FUNCTION declarations
'$INCLUDE: '../tactical/core.bas'
'$INCLUDE: '../tactical/utilities.bas'
'$INCLUDE: '../tactical/ui.bas'
'$INCLUDE: '../tactical/terrain.bas'
'$INCLUDE: '../tactical/unit_placement.bas'
'$INCLUDE: '../tactical/unit_management.bas'
'$INCLUDE: '../tactical/ai.bas'
'$INCLUDE: '../tactical/combat.bas'
'$INCLUDE: '../tactical/orders.bas'
'$INCLUDE: '../tactical/napoleon_subs.bas'

' Include test declarations (DECLARE statements only, CONST already included above)
' NOTE: battle.bas is NOT included here to avoid QB64 preprocessor issues.
' Tests use MockLaunchTacticalBattle from test_tactical_integration.bas instead.
'$INCLUDE: 'test_declarations.bas'

' Include common files with SUB/FUNCTION definitions
'$INCLUDE: '../common/config.bas'
'$INCLUDE: '../common/utilities.bas'
'$INCLUDE: '../common/error_handling.bas'
'$INCLUDE: '../common/game_state_helpers.bas'

' Include test framework (has SUB declarations)
'$INCLUDE: 'test_framework_simple.bas'

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
'$INCLUDE: '../strategic/reports.bas'
'$INCLUDE: '../strategic/realism.bas'

' Now declare the entry point SUB (after all CONST/type definitions)
DECLARE SUB RunAllTests ()

' Include test files (these contain SUB definitions)
'$INCLUDE: 'test_init.bas'
'$INCLUDE: 'test_campaign.bas'
'$INCLUDE: 'test_army.bas'
'$INCLUDE: 'test_city.bas'
'$INCLUDE: 'test_combat.bas'
'$INCLUDE: 'test_economy.bas'
'$INCLUDE: 'test_tactical_integration.bas'
'$INCLUDE: 'test_victory.bas'
'$INCLUDE: 'test_integration.bas'

' Main entry point
CALL RunAllTests
END

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
    CALL RunTacticalIntegrationTests
    PRINT
    CALL RunVictoryTests
    PRINT
    CALL RunIntegrationTests
    
    PRINT
    PRINT "Press any key to exit..."
    DO WHILE INKEY$ = "": LOOP
END SUB

