'============================================================================
' Test Runner - Executes all registered tests
'============================================================================
' This file provides a test runner that executes all registered tests
' and displays results.
'
' Usage:
'   1. Include test_framework.bas
'   2. Include your test files
'   3. Call RunAllTests to execute all registered tests
'
'============================================================================

'$INCLUDE: '../../qb64-test-framework/test_framework.bas'

'============================================================================
' Test Execution
'============================================================================

SUB RunAllTests
    ' Run all registered tests and display results
    
    DIM i AS INTEGER
    DIM suiteName AS STRING
    DIM testName AS STRING
    DIM testSub AS STRING
    DIM errorMessage AS STRING
    DIM testPassed AS INTEGER
    
    CALL InitializeTestFramework
    
    PRINT "Running "; registeredTestCount; " test(s)..."
    PRINT
    
    ' Run each registered test
    FOR i = 1 TO registeredTestCount
        suiteName = registeredTests(i).suiteName
        testName = registeredTests(i).testName
        testSub = registeredTests(i).testSub
        
        StartTest suiteName, testName
        
        ' Execute the test by calling the SUB
        ' Note: QB64 doesn't support dynamic SUB calls, so we need to
        ' use a dispatcher pattern. The actual test execution should
        ' be handled in the test file itself using a SELECT CASE or
        ' by directly calling the test SUBs.
        
        ' For now, we'll just record that we attempted to run it
        ' The actual test execution should be done in the test file
        ' by calling the test SUBs directly and then calling
        ' EndTest with the results
        
    NEXT i
    
    ' Print results
    CALL PrintTestResults
END SUB

SUB RunTestSuite (suiteName AS STRING)
    ' Run all tests in a specific suite
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    
    CALL InitializeTestFramework
    
    count = 0
    FOR i = 1 TO registeredTestCount
        IF registeredTests(i).suiteName = suiteName THEN
            count = count + 1
        END IF
    NEXT i
    
    IF count = 0 THEN
        PRINT "No tests found in suite: "; suiteName
        EXIT SUB
    END IF
    
    PRINT "Running "; count; " test(s) in suite: "; suiteName
    PRINT
    
    ' Run tests in the suite
    FOR i = 1 TO registeredTestCount
        IF registeredTests(i).suiteName = suiteName THEN
            ' Test execution should be handled by the test file
            ' This is just a placeholder
        END IF
    NEXT i
    
    ' Print results
    CALL PrintTestResults
END SUB

'============================================================================
' Test Execution Helper
'============================================================================

SUB ExecuteTest (suiteName AS STRING, testName AS STRING)
    ' Execute a single test
    ' This should be called from within a test SUB after all assertions
    
    DIM testPassed AS INTEGER
    DIM errorMessage AS STRING
    
    ' Check if test passed (no failed assertions)
    testPassed = (failedAssertions = 0)
    IF NOT testPassed THEN
        errorMessage = STR$(failedAssertions) + " assertion(s) failed"
    END IF
    
    EndTest testPassed, errorMessage
END SUB

