# ADR-0011: Utility Function Standardization

**Status:** Accepted  
**Date:** 2025-12-26  
**Deciders:** Dave Mackey  
**Git Commit:** f9cf5ae963d2a85436559ccc7d105aada50e5cd4

## Context

The codebase had significant code duplication:
- **Message display**: Repeated `COLOR X: CALL clrbot: PRINT` patterns
- **Side determination**: Repeated `IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START` checks
- **Value clamping**: Repeated min/max validation code
- **File existence**: Duplicate checks using both `FileExists%()` and `_FILEEXISTS()`

This duplication led to:
- **Maintenance burden**: Changes must be made in multiple places
- **Inconsistency**: Different implementations may behave differently
- **Code bloat**: Unnecessary code repetition
- **Error risk**: Bugs can be introduced in one location but not others

## Decision

We decided to extract common patterns into standardized utility functions in `src/common/utilities.bas`:

### Standardized Functions

1. **Message Display**:
   - `ShowStatusMessage(message$)` - Standard status message
   - `ShowStatusError(message$)` - Error message (red)
   - `ShowStatusWarning(message$)` - Warning message (yellow)

2. **Side Determination**:
   - `GetArmySide%(armyIndex)` - Returns FRENCH_SIDE or ALLIED_SIDE

3. **Value Clamping**:
   - `ClampValue%(value, min, max)` - Clamps integer value
   - `ClampValueLong&(value, min, max)` - Clamps long integer value

4. **File Operations**:
   - Standardized on `_FILEEXISTS()` (QB64 native)
   - Removed duplicate `FileExists%()` function

### Usage Pattern

**Before**:
```qb64
COLOR 15
CALL clrbot
PRINT "Processing..."
```

**After**:
```qb64
CALL ShowStatusMessage("Processing...")
```

**Before**:
```qb64
IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START THEN
    side = FRENCH_SIDE
ELSE
    side = ALLIED_SIDE
END IF
```

**After**:
```qb64
side = GetArmySide%(armyIndex)
```

**Before**:
```qb64
IF value < min THEN value = min
IF value > max THEN value = max
```

**After**:
```qb64
value = ClampValue%(value, min, max)
```

## Consequences

### Positive
- **Code reduction**: Eliminated 100+ lines of duplicate code
- **Consistency**: All code uses same implementations
- **Maintainability**: Changes in one place affect all usage
- **Readability**: Code more readable with named functions
- **Testing**: Utility functions can be unit tested

### Negative
- **Refactoring effort**: All duplicate code must be updated
- **Function call overhead**: Small performance cost (negligible)
- **Dependency**: Code depends on utility functions

### Neutral
- Game functionality unchanged
- Performance impact minimal
- User experience unchanged

## Implementation Notes

- All duplicate patterns identified and extracted
- Functions added to `src/common/utilities.bas`
- All call sites updated throughout codebase
- Functions documented with usage examples
- No breaking changes to existing functionality

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0010: Error Handling Standardization

