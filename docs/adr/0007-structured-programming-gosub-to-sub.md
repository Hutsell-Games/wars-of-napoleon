# ADR-0007: Structured Programming - GOSUB to SUB Conversion

**Status:** Accepted  
**Date:** 2025-12-26  
**Deciders:** Dave Mackey  
**Git Commit:** f9cf5ae963d2a85436559ccc7d105aada50e5cd4

## Context

The original `NAPOLEON.BAS` tactical battle code used unstructured programming patterns:
- **GOSUB/RETURN**: Subroutines called via line numbers
- **GOTO**: Unconditional jumps to labels
- **Line number labels**: Code organized by line numbers
- **Global variables**: All variables global, no parameter passing
- **Spaghetti code**: Difficult to follow control flow

Examples of problematic patterns:
```qb64
GOSUB xxyy        ' Calculate hex coordinates
GOSUB odd         ' Check if hex is odd
GOSUB rloc        ' Get random location
GOTO improve      ' Jump to different subroutine
```

This structure had problems:
- **Hard to understand**: Control flow difficult to follow
- **Hard to debug**: Can't set breakpoints on subroutines
- **Hard to test**: Can't test individual subroutines
- **Hard to maintain**: Changes affect multiple locations
- **Error prone**: Easy to introduce bugs with GOTO

## Decision

We decided to convert all GOSUB/GOTO patterns to structured SUB/FUNCTION procedures:

### Conversion Patterns

1. **GOSUB → SUB**: Convert subroutines to named SUB procedures
   - `GOSUB xxyy` → `CALL CalculateXY(x, y)`
   - `GOSUB odd` → `CALL CheckOddHex(hexX, hexY)`
   - `GOSUB rloc` → `CALL RandomLocation(x, y)`

2. **GOTO → FUNCTION**: Convert conditional jumps to functions that return values
   - `GOTO improve` → `IF EvaluateLocation%() = 1 THEN ...`

3. **Global Variables → Parameters**: Pass data as parameters
   - `SUB AwakenUnit(id AS INTEGER, xloc AS INTEGER, yloc AS INTEGER)`

4. **Recursion → Iteration**: Convert recursive patterns to loops
   - `WaitForKeypress` converted from recursion to DO...LOOP

### Key Conversions

- `xxyy` → `CalculateXY()` SUB
- `odd` → `CheckOddHex()` SUB
- `rloc` → `RandomLocation()` SUB
- `nearhere` → `MoveNearHere()` SUB
- `adjx` → `AdjustHexX()` SUB
- `lim1` → `CheckLimits()` SUB
- `eval` → `EvaluateLocation%()` FUNCTION
- `hold8` → `WaitForKey()` SUB
- `fog` → `FormatUnitStats()` SUB
- `run1` → `CheckRunLocation()` SUB
- `tim1` → `UpdateTimeDisplay()` SUB
- `franks` → `PlayFranksSound()` SUB
- `yanks` → `PlayYanksSound()` SUB
- `crsr` → `GetMenuKey()` SUB
- `limits` → `LimitRow()` SUB
- `mxw` → `CalculateMenuWidth()` SUB
- `noadjust` → `AdjustMenuPosition()` SUB

## Consequences

### Positive
- **Readability**: Code much easier to read and understand
- **Maintainability**: Changes isolated to specific functions
- **Testability**: Individual functions can be unit tested
- **Debugging**: Can set breakpoints on function entry/exit
- **Type safety**: Parameters enforce type checking
- **Documentation**: Functions can be documented individually

### Negative
- **Refactoring effort**: Significant code restructuring required
- **Parameter passing**: Need to identify all data dependencies
- **Function signatures**: Must design good function interfaces
- **Learning curve**: Team needs to understand structured patterns

### Neutral
- Game functionality unchanged
- Performance characteristics similar (may be slightly better)
- User experience unchanged

## Implementation Notes

- All GOSUB routines converted to SUB/FUNCTION
- All GOTO patterns eliminated
- All functions properly documented
- Parameter lists carefully designed
- Error handling added to functions
- Code organized into logical modules

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0008: Tactical Module Refactoring

