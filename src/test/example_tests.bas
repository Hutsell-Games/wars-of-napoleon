'============================================================================
' Example Test File - Demonstrates how to use the testing framework
'============================================================================
' This file shows how to write tests using the unit testing framework.
'
' To use this framework:
'   1. Include test_framework.bas
'   2. Create test SUBs that use assertions
'   3. Register tests with RegisterTest
'   4. Call ExecuteTest at the end of each test SUB
'   5. Call RunAllTests to run all tests
'
'============================================================================

'$INCLUDE: '../../qb64-test-framework/test_framework.bas'

'============================================================================
' Example Test Suite: Math Functions
'============================================================================

SUB TestMathAddition
    ' Test basic addition
    StartTest "MathTests", "test_addition"
    
    DIM result AS LONG
    result = 2 + 2
    
    AssertEqual result, 4, "2 + 2 should equal 4"
    AssertEqual result + 1, 5, "3 + 2 should equal 5"
    
    ExecuteTest "MathTests", "test_addition"
END SUB

SUB TestMathSubtraction
    ' Test basic subtraction
    StartTest "MathTests", "test_subtraction"
    
    DIM result AS LONG
    result = 10 - 3
    
    AssertEqual result, 7, "10 - 3 should equal 7"
    AssertNotEqual result, 8, "Result should not be 8"
    
    ExecuteTest "MathTests", "test_subtraction"
END SUB

SUB TestMathMultiplication
    ' Test basic multiplication
    StartTest "MathTests", "test_multiplication"
    
    DIM result AS LONG
    result = 5 * 4
    
    AssertEqual result, 20, "5 * 4 should equal 20"
    AssertGreaterThan result, 15, "Result should be greater than 15"
    
    ExecuteTest "MathTests", "test_multiplication"
END SUB

SUB TestMathDivision
    ' Test basic division
    StartTest "MathTests", "test_division"
    
    DIM result AS SINGLE
    result = 15 / 3
    
    AssertEqualFloat result, 5.0, 0.001, "15 / 3 should equal 5.0"
    
    ExecuteTest "MathTests", "test_division"
END SUB

'============================================================================
' Example Test Suite: String Functions
'============================================================================

SUB TestStringConcatenation
    ' Test string concatenation
    StartTest "StringTests", "test_concatenation"
    
    DIM str1 AS STRING
    DIM str2 AS STRING
    DIM result AS STRING
    
    str1 = "Hello"
    str2 = "World"
    result = str1 + " " + str2
    
    AssertStringEqual result, "Hello World", "String concatenation should work"
    
    ExecuteTest "StringTests", "test_concatenation"
END SUB

SUB TestStringLength
    ' Test string length
    StartTest "StringTests", "test_length"
    
    DIM testStr AS STRING
    testStr = "Test"
    
    AssertEqual LEN(testStr), 4, "String length should be 4"
    AssertGreaterThan LEN(testStr), 0, "String length should be greater than 0"
    
    ExecuteTest "StringTests", "test_length"
END SUB

'============================================================================
' Example Test Suite: Boolean Logic
'============================================================================

SUB TestBooleanTrue
    ' Test boolean true assertions
    StartTest "BooleanTests", "test_true"
    
    DIM condition AS INTEGER
    condition = 1
    
    AssertTrue condition, "Condition should be true"
    AssertFalse NOT condition, "NOT condition should be false"
    
    ExecuteTest "BooleanTests", "test_true"
END SUB

SUB TestBooleanFalse
    ' Test boolean false assertions
    StartTest "BooleanTests", "test_false"
    
    DIM condition AS INTEGER
    condition = 0
    
    AssertFalse condition, "Condition should be false"
    AssertTrue NOT condition, "NOT condition should be true"
    
    ExecuteTest "BooleanTests", "test_false"
END SUB

'============================================================================
' Example Test Suite: Comparison Operators
'============================================================================

SUB TestComparisonGreaterThan
    ' Test greater than comparisons
    StartTest "ComparisonTests", "test_greater_than"
    
    AssertGreaterThan 10, 5, "10 should be greater than 5"
    AssertGreaterThanOrEqual 10, 10, "10 should be greater than or equal to 10"
    
    ExecuteTest "ComparisonTests", "test_greater_than"
END SUB

SUB TestComparisonLessThan
    ' Test less than comparisons
    StartTest "ComparisonTests", "test_less_than"
    
    AssertLessThan 5, 10, "5 should be less than 10"
    AssertLessThanOrEqual 5, 5, "5 should be less than or equal to 5"
    
    ExecuteTest "ComparisonTests", "test_less_than"
END SUB

'============================================================================
' Test Registration and Execution
'============================================================================

SUB RegisterExampleTests
    ' Register all example tests
    
    ' Math tests
    RegisterTest "MathTests", "test_addition", "TestMathAddition"
    RegisterTest "MathTests", "test_subtraction", "TestMathSubtraction"
    RegisterTest "MathTests", "test_multiplication", "TestMathMultiplication"
    RegisterTest "MathTests", "test_division", "TestMathDivision"
    
    ' String tests
    RegisterTest "StringTests", "test_concatenation", "TestStringConcatenation"
    RegisterTest "StringTests", "test_length", "TestStringLength"
    
    ' Boolean tests
    RegisterTest "BooleanTests", "test_true", "TestBooleanTrue"
    RegisterTest "BooleanTests", "test_false", "TestBooleanFalse"
    
    ' Comparison tests
    RegisterTest "ComparisonTests", "test_greater_than", "TestComparisonGreaterThan"
    RegisterTest "ComparisonTests", "test_less_than", "TestComparisonLessThan"
END SUB

SUB RunExampleTests
    ' Run all example tests
    
    CALL InitializeTestFramework
    CALL RegisterExampleTests
    
    ' Execute all registered tests
    ' Since QB64 doesn't support dynamic SUB calls, we call them directly
    CALL TestMathAddition
    CALL TestMathSubtraction
    CALL TestMathMultiplication
    CALL TestMathDivision
    CALL TestStringConcatenation
    CALL TestStringLength
    CALL TestBooleanTrue
    CALL TestBooleanFalse
    CALL TestComparisonGreaterThan
    CALL TestComparisonLessThan
    
    ' Print results
    CALL PrintTestResults
END SUB

