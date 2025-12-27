'============================================================================
' City Tests Runner
'============================================================================
' Test city.bas functionality

DECLARE SUB RunCityTestSuite ()
CALL RunCityTestSuite
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
'$INCLUDE: 'test_init.bas'
'$INCLUDE: 'test_city.bas'

SUB RunCityTestSuite
    CALL InitializeTestVariables
    
    PRINT STRING$(80, "=")
    PRINT "CITY TESTS"
    PRINT STRING$(80, "=")
    PRINT
    
    CALL RunCityTests
    
    PRINT
    PRINT "Press any key to exit..."
    DO WHILE INKEY$ = "": LOOP
END SUB

