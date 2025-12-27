# QB64 Limitations Affecting Unit Testing

## Overview

QB64, while providing excellent compatibility with legacy QuickBASIC/QBASIC code, has several fundamental limitations that make unit testing significantly more challenging than in modern programming languages. This document explains these limitations and how they impact unit testing in the Wars of Napoleon project.

## Table of Contents

1. [Code Organization Constraints](#code-organization-constraints)
2. [Include System Limitations](#include-system-limitations)
3. [No Dynamic Function Calls](#no-dynamic-function-calls)
4. [Preprocessor Limitations](#preprocessor-limitations)
5. [Type System Constraints](#type-system-constraints)
6. [Initialization Challenges](#initialization-challenges)
7. [Test Isolation Problems](#test-isolation-problems)
8. [Workarounds and Solutions](#workarounds-and-solutions)

---

## Code Organization Constraints

### The Fundamental Rule

**QB64 requires strict code organization: executable code cannot appear between SUB/FUNCTION declarations, even across included files.**

### The Three-Phase Structure

QB64 enforces a three-phase structure for all code:

1. **Declaration Phase**: All `CONST`, `DIM`, `TYPE`, and `DECLARE` statements
2. **Definition Phase**: All `SUB` and `FUNCTION` definitions
3. **Execution Phase**: All executable statements (assignments, function calls, etc.)

### Why This Causes Problems

In a typical unit testing scenario, you might want to:

```qb64
' This is what we'd LIKE to do:
'$INCLUDE: 'declarations.bas'      ' Has: most = 80 (executable)
'$INCLUDE: 'test_framework.bas'    ' Has: SUB StartTest (definition)
'$INCLUDE: 'test_combat.bas'        ' Has: SUB TestCombat (definition)
```

**This fails** because QB64 sees:
- Executable statement (`most = 80`) from `declarations.bas`
- SUB definition (`StartTest`) from `test_framework.bas`
- SUB definition (`TestCombat`) from `test_combat.bas`

QB64 interprets the executable statement as being "between" the SUB definitions and throws:
```
Statement cannot be placed between SUB/FUNCTIONs
```

### Real-World Impact

This limitation forces us to:

1. **Comment out initialization code** in test declarations files
2. **Create separate initialization SUBs** that must be called after all includes
3. **Maintain strict include order** that differs between main program and tests
4. **Duplicate declaration files** (e.g., `declarations.bas` vs `declarations_test.bas`)

**Example from our codebase:**

```qb64
' declarations_test.bas
' TEST: Commented out to avoid "between SUB/FUNCTION" errors
' most = 80: m1 = 40: m2 = 41
' file$ = ""
' scenario$ = ""

' Then later in test_init.bas:
SUB InitializeTestVariables
    ' Initialize variables from declarations.bas that need initialization
    ' These executable statements are commented out in declarations_test.bas
    ' to avoid "Statement cannot be placed between SUB/FUNCTIONs" errors.
    most = 80: m1 = 40: m2 = 41
    file$ = ""
    scenario$ = ""
END SUB
```

---

## Include System Limitations

### No Conditional Includes

QB64's `$INCLUDE` directive is a simple text substitution. There is no:
- Conditional inclusion (`#ifdef`, `#if`)
- Include guards
- Dependency resolution
- Circular dependency detection

### Include Order Dependency

The order of `$INCLUDE` statements is **critical** and must be manually maintained:

```qb64
' CORRECT order:
'$INCLUDE: 'battle_types.bas'      ' TYPE definitions
'$INCLUDE: 'declarations.bas'       ' CONST declarations
'$INCLUDE: 'utilities.bas'          ' SUB/FUNCTION definitions
'$INCLUDE: 'test_combat.bas'         ' Test SUB definitions

' WRONG order (will fail):
'$INCLUDE: 'test_combat.bas'         ' Uses types not yet defined
'$INCLUDE: 'battle_types.bas'       ' Too late!
```

### Impact on Testing

1. **Test files must duplicate include order** from main program
2. **Include order must be documented** in comments
3. **Changes to dependencies** require updating include order in multiple places
4. **No automated dependency checking** - errors only appear at compile time

**Example from test_runner_all.bas:**

```qb64
' CRITICAL: Include files with CONST/type definitions FIRST
' These must come before any SUB/FUNCTION declarations

'$INCLUDE: '../common/battle_types.bas'
'$INCLUDE: 'declarations_test.bas'
'$INCLUDE: '../tactical/core.bas'
' ... 20+ more includes in specific order ...
```

---

## No Dynamic Function Calls

### The Limitation

QB64 does not support:
- Calling functions by name (string)
- Function pointers
- Reflection
- Runtime function discovery

### Impact on Test Discovery

Modern testing frameworks use reflection to automatically discover and run tests:

```python
# Python - automatic test discovery
pytest  # Finds all test_*.py files and test_* functions
```

```javascript
// JavaScript - automatic test discovery
describe('MySuite', () => {
  it('should test something', () => { ... });
});
```

**In QB64, we must manually call every test:**

```qb64
' No automatic discovery - must explicitly call each test
SUB RunAllTests
    CALL TestCalculateCombatStrengthBaseSize
    CALL TestCalcCombatStrengthLeadershipMod
    CALL TestCalcCombatStrengthSupplyPenalty
    ' ... manually list every test ...
END SUB
```

### Consequences

1. **Tests must be manually registered** in test runner
2. **Easy to forget tests** - no automatic discovery
3. **No test filtering** - can't run "just the failing tests"
4. **Maintenance burden** - adding a test requires updating test runner

---

## Preprocessor Limitations

### Simple Text Substitution

QB64's preprocessor is extremely limited:
- Only `$INCLUDE` directive
- No macros
- No conditional compilation
- No string manipulation
- No file path resolution

### What We Can't Do

```c
// C/C++ - conditional compilation
#ifdef TESTING
  #define ASSERT(x) test_assert(x)
#else
  #define ASSERT(x) // nothing
#endif
```

```qb64
' QB64 - no such feature
' We must use runtime checks or duplicate code
IF testingMode THEN
    CALL AssertEqual(result, expected, "message")
END IF
```

### Impact

1. **No test-only code paths** at compile time
2. **Must use runtime flags** for test vs production code
3. **Code duplication** for test stubs and mocks
4. **No compile-time optimization** for test builds

---

## Type System Constraints

### Type Suffix Requirements

QB64 requires type suffixes on function names, not return type declarations:

```qb64
' CORRECT:
FUNCTION GetValue% (x AS INTEGER)
    GetValue% = x * 2
END FUNCTION

' WRONG (doesn't compile):
FUNCTION GetValue (x AS INTEGER) AS INTEGER
    GetValue = x * 2
END FUNCTION
```

### Impact on Testing

1. **Function names must include type suffix** in assertions
2. **Easy to make mistakes** - forgetting suffix causes compile errors
3. **Less readable** - `GetValue%` vs `GetValue()`
4. **Inconsistent with modern languages** - learning curve for new developers

### No Generic Types

QB64 has no generics or templates:

```c++
// C++ - generic testing
template<typename T>
void test_add(T a, T b, T expected) { ... }
```

```qb64
' QB64 - must write separate tests for each type
SUB TestAddIntegers
    ' Test INTEGER addition
END SUB

SUB TestAddLongs
    ' Test LONG addition
END SUB
```

---

## Initialization Challenges

### Global State Initialization

QB64's strict code organization makes global state initialization problematic:

```qb64
' What we want:
DIM SHARED armies(1 TO MAX_ARMIES) AS ArmyType
' Initialize armies array
FOR i = 1 TO MAX_ARMIES
    armies(i).size = 0
NEXT i
```

**Problem**: This executable code (`FOR` loop) cannot appear in the declaration phase.

### Solutions We Must Use

1. **Lazy initialization** - initialize on first use
2. **Explicit initialization SUBs** - call after all includes
3. **Default values in TYPE definitions** - limited support
4. **Separate test initialization** - duplicate initialization code

**Example:**

```qb64
' declarations.bas - can't initialize here
DIM SHARED armies(1 TO MAX_ARMIES) AS ArmyType

' test_init.bas - must initialize here
SUB InitializeTestVariables
    FOR i = 1 TO MAX_ARMIES
        armies(i).size = 0
        armies(i).lead = 5
    NEXT i
END SUB
```

### Test Setup/Teardown

Modern testing frameworks provide setup/teardown hooks:

```python
def setUp(self):
    # Run before each test
    self.army = create_test_army()

def tearDown(self):
    # Run after each test
    cleanup_test_army()
```

**In QB64, we must manually call setup/teardown:**

```qb64
SUB TestCombat
    StartTest "CombatTests", "test_combat"
    
    ' Manual setup
    CALL InitializeArmies
    CALL InitializeCities
    
    ' Test code
    ' ...
    
    ' Manual teardown (if needed)
    ' ...
    
    ExecuteTest "CombatTests", "test_combat"
END SUB
```

---

## Test Isolation Problems

### Shared Global State

QB64's `DIM SHARED` creates truly global variables:

```qb64
DIM SHARED armies(1 TO MAX_ARMIES) AS ArmyType
DIM SHARED cities(1 TO MAX_CITIES) AS CityType
```

**Problem**: Tests share the same global state, leading to:
- **Test pollution** - one test affects another
- **Order-dependent tests** - tests fail when run in different order
- **Difficult parallelization** - can't run tests in parallel
- **Hard to isolate failures** - which test modified shared state?

### No Namespaces

Modern languages provide namespaces/modules:

```python
# Python - namespaced tests
class TestCombat:
    def test_strength(self):
        # Isolated test environment
        pass
```

**QB64 has no namespaces**, so all tests share the same global namespace.

### Workarounds

1. **Explicit reset between tests** - call initialization in each test
2. **Test-specific initialization** - reset all shared state
3. **Careful test ordering** - run tests in safe order
4. **Manual state management** - track and reset modified state

**Example:**

```qb64
SUB RunCombatTests
    CALL InitializeTestFramework
    
    ' Reset state before each test suite
    CALL InitializeArmies
    CALL InitializeCities
    CALL InitializeCohesion
    CALL InitializeVictoryConditions
    
    ' Run tests
    CALL TestCalculateCombatStrengthBaseSize
    ' ... more tests ...
END SUB
```

---

## Workarounds and Solutions

### 1. Separate Test Declaration Files

**Problem**: Main program and tests need different initialization.

**Solution**: Create test-specific declaration files that comment out executable statements.

```qb64
' declarations_test.bas
'$INCLUDE: '../common/declarations.bas'
' But comment out executable statements:
' most = 80: m1 = 40: m2 = 41  ' Commented for tests
```

### 2. Explicit Initialization SUBs

**Problem**: Can't initialize in declaration phase.

**Solution**: Create initialization SUBs called after all includes.

```qb64
SUB InitializeTestVariables
    most = 80: m1 = 40: m2 = 41
    file$ = ""
    scenario$ = ""
END SUB
```

### 3. Strict Include Order Documentation

**Problem**: Include order is critical but not enforced.

**Solution**: Document include order extensively in comments.

```qb64
' CRITICAL: Include files with CONST/type definitions FIRST
' These must come before any SUB/FUNCTION declarations
'$INCLUDE: '../common/battle_types.bas'
'$INCLUDE: 'declarations_test.bas'
' ... etc ...
```

### 4. Manual Test Registration

**Problem**: No automatic test discovery.

**Solution**: Maintain explicit test runner with all tests listed.

```qb64
SUB RunAllTests
    CALL RunCombatTests
    CALL RunArmyTests
    CALL RunCityTests
    ' ... etc ...
END SUB
```

### 5. Test State Reset

**Problem**: Tests share global state.

**Solution**: Explicitly reset state between test suites.

```qb64
SUB RunCombatTests
    CALL InitializeTestFramework
    CALL InitializeArmies      ' Reset state
    CALL InitializeCities       ' Reset state
    ' ... run tests ...
END SUB
```

### 6. Test Stubs and Mocks

**Problem**: Can't easily mock dependencies.

**Solution**: Create test-specific stub implementations.

```qb64
' test_init.bas
FUNCTION ShowListMenu% (title AS STRING, items$, itemCount AS INTEGER)
    ' Stub implementation for testing
    ShowListMenu% = 1  ' Return first item for testing
END FUNCTION
```

---

## Summary of Limitations

| Limitation | Impact on Testing | Severity |
|------------|------------------|----------|
| **No executable code between SUB/FUNCTIONs** | Requires separate test declarations, explicit initialization | **High** |
| **Strict include order** | Must manually maintain order, document extensively | **High** |
| **No dynamic function calls** | Must manually register all tests | **Medium** |
| **Limited preprocessor** | No conditional compilation, must use runtime flags | **Medium** |
| **Type suffix requirements** | Less readable, error-prone | **Low** |
| **No generics** | Must duplicate tests for different types | **Low** |
| **Global shared state** | Test pollution, order-dependent tests | **High** |
| **No namespaces** | All tests share same namespace | **Medium** |
| **Initialization challenges** | Must use explicit initialization SUBs | **Medium** |

---

## Comparison with Modern Languages

### What Modern Languages Provide

```python
# Python - pytest
def test_combat_strength():
    army = create_test_army(size=10000)
    strength = calculate_combat_strength(army)
    assert strength > 9000
```

**Features:**
- Automatic test discovery
- Isolated test environments
- Fixtures for setup/teardown
- Parameterized tests
- Test filtering
- Parallel execution

### What QB64 Requires

```qb64
' QB64 - manual everything
SUB TestCombatStrength
    StartTest "CombatTests", "test_combat_strength"
    
    ' Manual setup
    CALL InitializeArmies
    armies(1).size = 10000
    
    ' Test
    DIM strength AS LONG
    strength = CalculateCombatStrength&(1)
    AssertGreaterThan strength, 9000, "Strength should be > 9000"
    
    ExecuteTest "CombatTests", "test_combat_strength"
END SUB

' Must manually call in test runner
SUB RunCombatTests
    CALL TestCombatStrength
END SUB
```

**Missing features:**
- No automatic discovery
- Manual state management
- Manual test registration
- No fixtures
- No parameterization
- No parallel execution

---

## Recommendations

### For New Developers

1. **Read this document first** - understand QB64 limitations
2. **Study existing test files** - see how we work around limitations
3. **Follow include order patterns** - don't deviate from established patterns
4. **Always reset state** - call initialization SUBs in test suites
5. **Document test dependencies** - comment what each test needs

### For Test Maintenance

1. **Keep include order documented** - update comments when order changes
2. **Maintain test runner** - add new tests to runner immediately
3. **Reset state consistently** - use same initialization pattern
4. **Review test isolation** - ensure tests don't depend on each other
5. **Update this document** - document new limitations as discovered

### For Architecture Decisions

1. **Minimize global state** - use parameters instead of SHARED when possible
2. **Design for testability** - make functions easy to test in isolation
3. **Document dependencies** - clearly state what each module needs
4. **Consider test impact** - how will this affect testability?

---

## Related Documentation

- [ADR-0014: QB64 Syntax Constraints](../adr/0014-qb64-syntax-constraints.md) - General QB64 limitations
- [ADR-0015: Module Include Order](../adr/0015-module-include-order.md) - Include order requirements
- [QB64 Test Compilation Issue](./QB64_TEST_COMPILATION_ISSUE.md) - Specific compilation problems
- [Testing Framework](../TESTING_FRAMEWORK.md) - Our testing framework documentation

---

## Conclusion

QB64's limitations make unit testing significantly more challenging than in modern languages. However, by understanding these limitations and following established patterns, we can still create effective unit tests. The key is:

1. **Accept the constraints** - work within QB64's limitations
2. **Establish patterns** - create consistent workarounds
3. **Document extensively** - help future developers understand why
4. **Maintain discipline** - follow patterns even when inconvenient

The limitations are real, but they are manageable with proper understanding and discipline.

