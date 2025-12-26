# Test Directory

This directory contains unit tests for the Wars of Napoleon project using the generic unit testing framework.

## Files

- `test_main.bas` - Main entry point for running tests
- `example_tests.bas` - Example tests demonstrating framework usage
- `test_runner.bas` - Test execution helpers

## Running Tests

### Option 1: Run Example Tests

1. Open `test_main.bas` in QB64
2. Compile and run (F5)

### Option 2: Create Your Own Tests

1. Create a new `.bas` file in this directory
2. Include the framework: `'$INCLUDE: '../../qb64-test-framework/test_framework.bas'`
3. Write your test SUBs
4. Call your tests and then `PrintTestResults`

Example:

```qb64
'$INCLUDE: '../../qb64-test-framework/test_framework.bas'

SUB TestMyFeature
    StartTest "MySuite", "test_my_feature"
    
    ' Your test code here
    AssertEqual 2 + 2, 4, "Math should work"
    
    ExecuteTest "MySuite", "test_my_feature"
END SUB

CALL InitializeTestFramework
CALL TestMyFeature
CALL PrintTestResults
```

## Framework Documentation

See `docs/TESTING_FRAMEWORK.md` for complete documentation on using the testing framework.

## Adding Tests for Game Modules

To test game modules:

1. Create a test file (e.g., `test_army.bas`, `test_city.bas`)
2. Include the framework and the module you're testing
3. Write test SUBs that exercise the module's functionality
4. Add your test file to `test_main.bas` or create a separate runner

Example for testing army module:

```qb64
'$INCLUDE: '../../qb64-test-framework/test_framework.bas'
'$INCLUDE: '../strategic/army.bas'

SUB TestArmyCreation
    StartTest "ArmyTests", "test_army_creation"
    
    ' Test army creation logic
    ' Use assertions to verify behavior
    
    ExecuteTest "ArmyTests", "test_army_creation"
END SUB
```

