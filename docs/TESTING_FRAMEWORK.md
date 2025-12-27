# Generic Unit Testing Framework for QB64

A reusable unit testing framework designed for QB64 projects. This framework provides assertions, test suites, test cases, and detailed reporting that can be used across multiple QB64 applications.

## Features

- **Comprehensive Assertions**: Support for integers, floats, strings, booleans, and comparisons
- **Test Organization**: Organize tests into suites and cases
- **Detailed Reporting**: Color-coded output with pass/fail status and timing
- **Easy Integration**: Simple include-based setup
- **Generic Design**: Works with any QB64 project

## Quick Start

### 1. Include the Framework

Add the test framework to your test file:

```qb64
'$INCLUDE: '../../qb64-test-framework/test_framework.bas'
```

Note: The framework is now located in its own directory outside the project. Adjust the path based on your project structure.

### 2. Write a Test

Create a test SUB that uses assertions:

```qb64
SUB TestMyFunction
    StartTest "MySuite", "test_my_function"
    
    DIM result AS LONG
    result = MyFunction(5)
    
    AssertEqual result, 10, "MyFunction(5) should return 10"
    AssertTrue result > 0, "Result should be positive"
    
    ExecuteTest "MySuite", "test_my_function"
END SUB
```

### 3. Run Tests

Call your test SUBs and then print results:

```qb64
CALL InitializeTestFramework
CALL TestMyFunction
CALL PrintTestResults
```

## Available Assertions

### Integer Assertions

- `AssertEqual(actual, expected, message)` - Assert two integers are equal
- `AssertNotEqual(actual, expected, message)` - Assert two integers are not equal
- `AssertGreaterThan(actual, expected, message)` - Assert actual > expected
- `AssertLessThan(actual, expected, message)` - Assert actual < expected
- `AssertGreaterThanOrEqual(actual, expected, message)` - Assert actual >= expected
- `AssertLessThanOrEqual(actual, expected, message)` - Assert actual <= expected

### Float Assertions

- `AssertEqualFloat(actual, expected, tolerance, message)` - Assert two floats are equal within tolerance

### String Assertions

- `AssertStringEqual(actual, expected, message)` - Assert two strings are equal
- `AssertStringNotEqual(actual, expected, message)` - Assert two strings are not equal

### Boolean Assertions

- `AssertTrue(condition, message)` - Assert condition is true (non-zero)
- `AssertFalse(condition, message)` - Assert condition is false (zero)

### Null Assertions

- `AssertNotNull(value, message)` - Assert value is not null (not zero)
- `AssertNull(value, message)` - Assert value is null (zero)

## Test Structure

### Basic Test Pattern

```qb64
SUB TestSomething
    StartTest "SuiteName", "test_name"
    
    ' Your test code here
    ' Use assertions to verify behavior
    
    ExecuteTest "SuiteName", "test_name"
END SUB
```

### Test Registration (Optional)

You can register tests for organization, though QB64 requires direct SUB calls:

```qb64
SUB RegisterMyTests
    RegisterTest "SuiteName", "test_name", "TestSomething"
END SUB
```

## Example: Testing a Utility Function

```qb64
'$INCLUDE: '../common/test_framework.bas'

' Function to test
FUNCTION AddNumbers% (a AS LONG, b AS LONG)
    AddNumbers% = a + b
END FUNCTION

' Test the function
SUB TestAddNumbers
    StartTest "MathTests", "test_add_numbers"
    
    DIM result AS LONG
    
    ' Test case 1: Positive numbers
    result = AddNumbers%(5, 3)
    AssertEqual result, 8, "5 + 3 should equal 8"
    
    ' Test case 2: Negative numbers
    result = AddNumbers%(-5, -3)
    AssertEqual result, -8, "-5 + -3 should equal -8"
    
    ' Test case 3: Mixed signs
    result = AddNumbers%(5, -3)
    AssertEqual result, 2, "5 + -3 should equal 2"
    
    ExecuteTest "MathTests", "test_add_numbers"
END SUB

' Run the test
CALL InitializeTestFramework
CALL TestAddNumbers
CALL PrintTestResults
```

## Test Output

The framework provides color-coded output:

- **Green** - Passed tests
- **Red** - Failed tests
- **Yellow** - Error messages

Example output:

```
================================================================================
TEST RESULTS
================================================================================

Suite: MathTests
--------------------------------------------------------------------------------
  [PASS] test_add_numbers
         Duration: 0.0001s
  [PASS] test_subtract_numbers
         Duration: 0.0001s

Suite: StringTests
--------------------------------------------------------------------------------
  [FAIL] test_concatenation
         2 assertion(s) failed
         Duration: 0.0002s

================================================================================
SUMMARY
================================================================================
Total Tests: 3
Passed: 2
Failed: 1

SOME TESTS FAILED!

Total Assertions: 5
Failed Assertions: 2
================================================================================
```

## Integration with Projects

### For Wars of Napoleon

1. Create test files in `src/test/`
2. Include the framework: `'$INCLUDE: '../../qb64-test-framework/test_framework.bas'`
3. Write tests for strategic, tactical, or common modules
4. Run tests by compiling and executing your test file

### For Other Projects

1. Reference `qb64-test-framework/test_framework.bas` from your project
2. Adjust include paths based on your project structure
3. Create test files that include the framework
4. Write and run tests

## Best Practices

1. **Organize by Module**: Create one test file per module (e.g., `test_army.bas`, `test_city.bas`)
2. **Use Descriptive Names**: Test names should clearly describe what they test
3. **One Assertion Per Concept**: Each assertion should test one specific behavior
4. **Test Edge Cases**: Include tests for boundary conditions and error cases
5. **Keep Tests Independent**: Tests should not depend on each other
6. **Use Meaningful Messages**: Provide clear messages in assertions for easier debugging

## Advanced Usage

### Testing with Setup/Teardown

While the framework doesn't provide built-in setup/teardown, you can implement it:

```qb64
SUB SetupTest
    ' Initialize test data
    ' Set up test environment
END SUB

SUB TeardownTest
    ' Clean up test data
    ' Reset test environment
END SUB

SUB TestWithSetup
    StartTest "MySuite", "test_with_setup"
    
    CALL SetupTest
    
    ' Your test code here
    
    CALL TeardownTest
    
    ExecuteTest "MySuite", "test_with_setup"
END SUB
```

### Testing Error Conditions

```qb64
SUB TestErrorHandling
    StartTest "ErrorTests", "test_invalid_input"
    
    DIM result AS LONG
    result = MyFunction(-1)  ' Invalid input
    
    ' Check that error is handled correctly
    AssertEqual result, -1, "Should return error code for invalid input"
    ' Or check that error flag is set
    AssertTrue errorFlag = 1, "Error flag should be set"
    
    ExecuteTest "ErrorTests", "test_invalid_input"
END SUB
```

## Limitations

- **No Dynamic SUB Calls**: QB64 doesn't support calling SUBs by name, so you must call test SUBs directly
- **No Test Discovery**: Tests must be explicitly called; there's no automatic discovery
- **Limited to QB64 Types**: Framework works with QB64's type system (LONG, SINGLE, STRING, INTEGER)

## File Structure

The testing framework is located in its own directory:

```
qb64-test-framework/
├── test_framework.bas         # Core testing framework
├── test_runner.bas           # Test execution helpers
├── examples/                  # Example tests
│   ├── example_tests.bas     # Example test implementations
│   └── test_main.bas         # Example test runner
└── README.md                  # Framework documentation

wars-of-napoleon/
└── src/
    └── test/                  # Project-specific tests
        ├── test_main.bas      # Test runner entry point
        └── (your test files)  # Your test implementations
```

## Contributing

When adding new assertion types or features:

1. Add the assertion function to `test_framework.bas`
2. Update this documentation
3. Add example usage to `example_tests.bas`
4. Test your changes

## License

This testing framework is part of the Wars of Napoleon project and follows the same license terms.

