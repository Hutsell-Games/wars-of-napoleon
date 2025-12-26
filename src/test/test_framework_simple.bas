'============================================================================
' Simple Test Framework for QB64
'============================================================================
' A lightweight test framework for unit testing
' Provides basic assertions and test reporting

DIM SHARED testPassCount AS INTEGER
DIM SHARED testFailCount AS INTEGER
DIM SHARED assertionCount AS INTEGER
DIM SHARED failedAssertionCount AS INTEGER
DIM SHARED currentTestSuite$
DIM SHARED currentTestName$
DIM SHARED testOutput$(1 TO 1000)
DIM SHARED testOutputCount AS INTEGER

SUB InitializeTestFramework
    testPassCount = 0
    testFailCount = 0
    assertionCount = 0
    failedAssertionCount = 0
    testOutputCount = 0
    currentTestSuite$ = ""
    currentTestName$ = ""
END SUB

SUB StartTest (suiteName AS STRING, testName AS STRING)
    currentTestSuite$ = suiteName
    currentTestName$ = testName
    failedAssertionCount = 0
END SUB

SUB AssertEqual (actual AS LONG, expected AS LONG, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual <> expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected " + LTRIM$(STR$(expected)) + ", got " + LTRIM$(STR$(actual)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertNotEqual (actual AS LONG, expected AS LONG, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual = expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected not " + LTRIM$(STR$(expected)) + ", but got " + LTRIM$(STR$(actual)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertTrue (condition AS INTEGER, message AS STRING)
    assertionCount = assertionCount + 1
    IF condition = 0 THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected true, got false)"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertFalse (condition AS INTEGER, message AS STRING)
    assertionCount = assertionCount + 1
    IF condition <> 0 THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected false, got true)"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertStringEqual (actual AS STRING, expected AS STRING, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual <> expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected '" + expected + "', got '" + actual + "')"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertEqualFloat (actual AS SINGLE, expected AS SINGLE, tolerance AS SINGLE, message AS STRING)
    assertionCount = assertionCount + 1
    DIM diff AS SINGLE
    diff = ABS(actual - expected)
    IF diff > tolerance THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected " + LTRIM$(STR$(expected)) + ", got " + LTRIM$(STR$(actual)) + ", diff " + LTRIM$(STR$(diff)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertGreaterThan (actual AS LONG, expected AS LONG, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual <= expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected > " + LTRIM$(STR$(expected)) + ", got " + LTRIM$(STR$(actual)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertLessThan (actual AS LONG, expected AS LONG, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual >= expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected < " + LTRIM$(STR$(expected)) + ", got " + LTRIM$(STR$(actual)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB AssertGreaterThanOrEqual (actual AS LONG, expected AS LONG, message AS STRING)
    assertionCount = assertionCount + 1
    IF actual < expected THEN
        failedAssertionCount = failedAssertionCount + 1
        DIM msg AS STRING
        msg = "  FAIL: " + message + " (expected >= " + LTRIM$(STR$(expected)) + ", got " + LTRIM$(STR$(actual)) + ")"
        testOutputCount = testOutputCount + 1
        testOutput$(testOutputCount) = msg
        PRINT msg
    END IF
END SUB

SUB ExecuteTest (suiteName AS STRING, testName AS STRING)
    ' Execute a test and record results
    ' This should be called at the end of each test SUB
    
    IF failedAssertionCount = 0 THEN
        testPassCount = testPassCount + 1
        PRINT "  PASS: "; suiteName; "."; testName
    ELSE
        testFailCount = testFailCount + 1
        PRINT "  FAIL: "; suiteName; "."; testName; " ("; LTRIM$(STR$(failedAssertionCount)); " assertion(s) failed)"
    END IF
END SUB

SUB PrintTestResults
    PRINT
    PRINT STRING$(80, "=")
    PRINT "TEST RESULTS"
    PRINT STRING$(80, "=")
    PRINT
    PRINT "Total Tests: "; testPassCount + testFailCount
    PRINT "Passed: "; testPassCount
    PRINT "Failed: "; testFailCount
    PRINT
    PRINT "Total Assertions: "; assertionCount
    PRINT "Failed Assertions: "; failedAssertionCount
    PRINT STRING$(80, "=")
    
    IF testFailCount > 0 THEN
        PRINT "SOME TESTS FAILED!"
    ELSE
        PRINT "ALL TESTS PASSED!"
    END IF
    PRINT STRING$(80, "=")
END SUB

SUB MockShowInfo (message AS STRING)
    ' Mock function for tests - doesn't need to display
    ' Renamed from ShowInfo to avoid conflict with menus.bas
END SUB

