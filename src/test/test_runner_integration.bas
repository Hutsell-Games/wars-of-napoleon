'============================================================================
' Integration Tests Runner
'============================================================================
' Test integration functionality

DECLARE SUB RunIntegrationTestSuite ()
CALL RunIntegrationTestSuite
END

'$INCLUDE: '../common/battle_types.bas'
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
'$INCLUDE: 'test_declarations.bas'
'$INCLUDE: '../common/config.bas'
'$INCLUDE: '../common/utilities.bas'
'$INCLUDE: '../common/error_handling.bas'
'$INCLUDE: '../common/game_state_helpers.bas'
'$INCLUDE: 'test_framework_simple.bas'
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
'$INCLUDE: 'test_integration.bas'

SUB RunIntegrationTestSuite
    CALL InitializeTestVariables
    
    PRINT STRING$(80, "=")
    PRINT "INTEGRATION TESTS"
    PRINT STRING$(80, "=")
    PRINT
    
    CALL RunIntegrationTests
    
    PRINT
    PRINT "Press any key to exit..."
    DO WHILE INKEY$ = "": LOOP
END SUB

