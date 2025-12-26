'============================================================================
' Test Main - Entry point for running tests
'============================================================================
' This is the main entry point for running all tests.
' Compile and run this file to execute the test suite.
'
' Usage:
'   1. Include your test files
'   2. Call RegisterExampleTests (or your test registration)
'   3. Call RunExampleTests (or your test runner)
'
'============================================================================

'$INCLUDE: 'example_tests.bas'

'============================================================================
' Main Entry Point
'============================================================================

PRINT STRING$(80, "=")
PRINT "UNIT TEST FRAMEWORK - EXAMPLE TESTS"
PRINT STRING$(80, "=")
PRINT

' Run example tests
CALL RunExampleTests

PRINT
PRINT "Press any key to exit..."
DO WHILE INKEY$ = "": LOOP

END

