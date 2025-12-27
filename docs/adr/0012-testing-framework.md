# ADR-0012: Testing Framework

**Status:** Accepted  
**Date:** 2025-12-26  
**Deciders:** Dave Mackey  
**Git Commit:** f9cf5ae963d2a85436559ccc7d105aada50e5cd4

## Context

The original codebase had no testing infrastructure:
- No unit tests
- No integration tests
- No test framework
- Manual testing only
- Difficult to verify correctness after changes

This made it difficult to:
- Verify code correctness
- Catch regressions
- Test edge cases
- Refactor safely
- Document expected behavior

## Decision

We decided to implement a testing framework for QB64:

### Testing Framework Structure

```
src/test/
├── test_framework_simple.bas  # Core testing framework
├── test_runner.bas             # Test execution helpers
├── test_runner_all.bas         # Run all tests
├── test_init.bas               # Test initialization
├── declarations_test.bas       # Tests for declarations module
├── test_army.bas               # Tests for army module
├── test_campaign.bas           # Tests for campaign module
├── test_city.bas               # Tests for city module
├── test_combat.bas              # Tests for combat module
├── test_economy.bas             # Tests for economy module
├── test_integration.bas         # Integration tests
├── test_tactical_integration.bas # Tactical integration tests
├── test_victory.bas             # Victory condition tests
└── README.md                    # Testing documentation
```

### Testing Framework Features

1. **Test Assertions**:
   - `ASSERT(condition, message$)` - Assert condition is true
   - `ASSERT_EQUAL(expected, actual, message$)` - Assert values equal
   - `ASSERT_NOT_EQUAL(expected, actual, message$)` - Assert values not equal

2. **Test Organization**:
   - Tests organized by module
   - Test functions prefixed with `Test_`
   - Test runners for individual modules and full suite

3. **Test Execution**:
   - Run individual test files
   - Run all tests
   - Test results displayed
   - Test failures reported

### Usage Pattern

```qb64
SUB Test_ArmyRecruitment
    ' Test army recruitment functionality
    DIM armyIndex AS INTEGER
    armyIndex = RecruitArmy%(cityIndex, side)
    
    CALL ASSERT(armyIndex > 0, "Army recruitment should succeed")
    CALL ASSERT_EQUAL(GetArmyStrength%(armyIndex), expectedStrength, "Army strength should match")
END SUB
```

## Consequences

### Positive
- **Code quality**: Tests verify correctness
- **Regression prevention**: Tests catch breaking changes
- **Documentation**: Tests document expected behavior
- **Refactoring safety**: Tests enable safe refactoring
- **Confidence**: Tests provide confidence in changes

### Negative
- **Development time**: Writing tests takes time
- **Maintenance**: Tests must be maintained with code
- **Coverage**: Not all code may be tested
- **Framework complexity**: Testing framework adds complexity

### Neutral
- Game functionality unchanged
- Performance impact only during testing
- User experience unchanged

## Implementation Notes

- Testing framework implemented in QB64
- Tests organized by module
- Test runners for easy execution
- Documentation in `src/test/README.md`
- Tests can be run individually or as full suite

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0007: Structured Programming

