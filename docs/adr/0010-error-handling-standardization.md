# ADR-0010: Error Handling Standardization

**Status:** Accepted  
**Date:** 2025-12-25  
**Deciders:** Dave Mackey  
**Git Commit:** 4db1ff7ddd13de41cc159cbef438519d41e695d7

## Context

The original codebase had inconsistent error handling:
- Some functions returned error codes
- Some functions used GOTO for error handling
- Some errors were silently ignored
- Error messages inconsistent across modules
- No centralized error handling system

This led to:
- Difficult debugging (errors hard to trace)
- Inconsistent user experience (different error messages)
- Silent failures (errors not reported)
- Code duplication (error handling repeated)

## Decision

We decided to implement a standardized error handling system in `src/common/error_handling.bas`:

### Error Handling Functions

1. **Critical Errors**: `HandleCriticalError(message$)`
   - For errors that prevent operation
   - Displays error message
   - Exits function/subroutine
   - Example: Missing required data file

2. **Validation Errors**: `HandleValidationError(message$)`
   - For invalid input/state validation
   - Displays error message
   - Exits function/subroutine
   - Example: Invalid army index

3. **File Not Found**: `HandleFileNotFound(filename$)`
   - For missing required files
   - Displays error message with filename
   - Exits function/subroutine
   - Example: Missing scenario file

4. **Warnings**: `HandleWarning(message$)`
   - For non-critical warnings
   - Displays warning message
   - Continues execution
   - Example: Optional file missing

### Validation Helpers

- `ValidateArmyIndex%(armyIndex)` - Validates army index
- `ValidateCityIndex%(cityIndex)` - Validates city index
- `ValidateArmySide%(armyIndex)` - Validates army side

### Usage Pattern

```qb64
IF NOT ValidateArmyIndex%(armyIndex) THEN
    CALL HandleValidationError("Invalid army index: " + STR$(armyIndex))
    EXIT SUB
END IF

IF NOT _FILEEXISTS(filename$) THEN
    CALL HandleFileNotFound(filename$)
    EXIT SUB
END IF
```

## Consequences

### Positive
- **Consistency**: All errors handled the same way
- **User experience**: Consistent error messages
- **Debugging**: Errors easier to trace
- **Maintainability**: Error handling in one place
- **Documentation**: Error handling patterns documented

### Negative
- **Refactoring effort**: All error handling must be updated
- **Learning curve**: Team must learn new patterns
- **Code changes**: Existing code must be modified

### Neutral
- Game functionality unchanged
- Performance impact minimal
- User experience improved

## Implementation Notes

- All modules updated to use standardized error handling
- Error messages standardized across modules
- Validation helpers reduce code duplication
- Error handling patterns documented
- Fallback behavior for critical errors (e.g., tactical battle → strategic resolution)

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0011: Utility Function Standardization

