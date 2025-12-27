'============================================================================
' Combat Tests Runner
'============================================================================
' Test combat.bas functionality

DECLARE SUB RunCombatTestSuite ()
CALL RunCombatTestSuite
END

'$INCLUDE: 'test_declarations.bas'
'$INCLUDE: 'test_framework_simple.bas'
'$INCLUDE: '../common/battle_types.bas'
'$INCLUDE: '../common/utilities.bas'
'$INCLUDE: '../common/error_handling.bas'
'$INCLUDE: '../common/game_state_helpers.bas'
'$INCLUDE: '../common/config.bas'
'$INCLUDE: '../ui/graphics.bas'
'$INCLUDE: '../strategic/scenario.bas'
'$INCLUDE: '../strategic/army.bas'
'$INCLUDE: '../strategic/city.bas'
'$INCLUDE: '../strategic/cohesion.bas'
'$INCLUDE: '../strategic/campaign.bas'
'$INCLUDE: '../strategic/combat.bas'
'$INCLUDE: 'test_init.bas'
'$INCLUDE: 'test_combat.bas'

SUB RunCombatTestSuite
    CALL InitializeTestVariables
    
    PRINT STRING$(80, "=")
    PRINT "COMBAT TESTS"
    PRINT STRING$(80, "=")
    PRINT
    
    CALL RunCombatTests
    
    PRINT
    PRINT "Press any key to exit..."
    DO WHILE INKEY$ = "": LOOP
END SUB

