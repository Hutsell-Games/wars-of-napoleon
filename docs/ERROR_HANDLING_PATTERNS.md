# Error Handling Patterns Guide

**Date:** 2025-12-26  
**Purpose:** Document error handling patterns and best practices for contributors  
**Status:** Active Documentation

---

## Overview

This document describes the standardized error handling patterns used throughout the Wars of Napoleon codebase. Following these patterns ensures consistent error handling, better user experience, and easier debugging.

---

## Error Handling System

The error handling system is centralized in `src/common/error_handling.bas` and provides:

1. **Standardized Error Display Functions** - Consistent error messages
2. **Validation Helper Functions** - Reusable validation checks
3. **Clear Error Handling Patterns** - When to use each pattern

---

## Error Handling Standards

### 1. CRITICAL ERRORS
**Use:** `HandleCriticalError` + `EXIT`  
**When:** Operation cannot continue due to critical failure  
**Example:** Data corruption, system failure, impossible state

```qb64
IF criticalCondition THEN
    CALL HandleCriticalError("Critical error: " + errorDescription)
    EXIT SUB
END IF
```

### 2. VALIDATION ERRORS
**Use:** `HandleValidationError` + `EXIT`  
**When:** Invalid input parameters or invalid game state  
**Example:** Invalid army index, out-of-bounds access, invalid side

```qb64
IF NOT ValidateArmyIndex%(armyIndex, "FunctionName") THEN
    EXIT SUB
END IF
```

### 3. FILE NOT FOUND
**Use:** `HandleFileNotFound` + `EXIT`  
**When:** Required file is missing (expected in some scenarios)  
**Example:** Save file not found, scenario file missing

```qb64
IF NOT fileExists THEN
    CALL HandleFileNotFound(filename)
    EXIT SUB
END IF
```

### 4. WARNINGS
**Use:** `HandleWarning` (no EXIT)  
**When:** Non-critical issue where operation can continue with defaults  
**Example:** Missing optional data, using default values

```qb64
IF optionalDataMissing THEN
    CALL HandleWarning("Optional data missing, using defaults")
    ' Continue with default values
END IF
```

### 5. SILENT EXIT
**Use:** Direct `EXIT` (no error message)  
**When:** Early return in valid code path (not an error)  
**Example:** No items to process, empty list, user cancellation

```qb64
IF count = 0 THEN
    EXIT SUB ' No items to process - not an error
END IF
```

---

## Validation Helper Functions

### Index Validation

#### ValidateArmyIndex%
Validates army index is within valid range (1-40).

```qb64
IF NOT ValidateArmyIndex%(armyIndex, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Always validate army indices before accessing `armies()` array
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

#### ValidateCityIndex%
Validates city index is within valid range (1-MAX_CITIES).

```qb64
IF NOT ValidateCityIndex%(cityIndex, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Always validate city indices before accessing `cities()` array
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

#### ValidateCommanderIndex%
Validates commander index is within valid range (1-50).

```qb64
IF NOT ValidateCommanderIndex%(commanderIndex, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Always validate commander indices before accessing `commanders()` array
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

### Side Validation

#### ValidateArmySide%
Validates side is 1 (French) or 2 (Allied).

```qb64
IF NOT ValidateArmySide%(side, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Validate side parameter before using it
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

### Matrix Access Validation

#### ValidateCityMatrixColumn%
Validates both city index and column index for cityMatrix access.

```qb64
IF NOT ValidateCityMatrixColumn%(cityIndex, column, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Validate before accessing `cityMatrix(cityIndex, column)`
- Validates both indices are within bounds
- Returns 0 if invalid (shows error), 1 if valid

### Tactical Unit Validation

#### ValidateUnitIndex%
Validates tactical unit index is within valid range (1-100).

```qb64
IF NOT ValidateUnitIndex%(unitIndex, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Always validate unit indices before accessing tactical unit arrays
- Validates indices for: `unit$()`, `unitx()`, `unity()`, `strength()`, `leader()`, `xper()`, `morale()`, `terrain()`, `name$()`, etc.
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

### Map Coordinate Validation

#### ValidateMapCoordinates%
Validates tactical map coordinates are within valid bounds.

```qb64
IF NOT ValidateMapCoordinates%(x, y, "FunctionName") THEN
    EXIT SUB
END IF
```

**Usage Pattern:**
- Validate X/Y coordinates before using them for map operations
- Map bounds: X = 1-27, Y = 1-20
- Provide context string describing where validation occurs
- Returns 0 if invalid (shows error), 1 if valid

---

## State Check Helper Functions

These functions check entity state but do NOT validate bounds. Use validation functions first if needed.

### IsArmyActive%
Checks if army exists and is active (has size > 0).

```qb64
IF ValidateArmyIndex%(armyIndex, "FunctionName") THEN
    IF IsArmyActive%(armyIndex) THEN
        ' Army is active
    END IF
END IF
```

**Usage Pattern:**
- Use after validating index bounds
- Returns 1 if army exists and has size > 0, 0 otherwise
- Does NOT validate index bounds - use `ValidateArmyIndex%` first

### IsCityActive%
Checks if city exists and is active (has name).

```qb64
IF ValidateCityIndex%(cityIndex, "FunctionName") THEN
    IF IsCityActive%(cityIndex) THEN
        ' City is active
    END IF
END IF
```

**Usage Pattern:**
- Use after validating index bounds
- Returns 1 if city exists and has name, 0 otherwise
- Does NOT validate index bounds - use `ValidateCityIndex%` first

### IsFleetActive%
Checks if fleet exists and is active (has size > 0).

```qb64
IF ValidateArmySide%(side, "FunctionName") THEN
    IF IsFleetActive%(side) THEN
        ' Fleet is active
    END IF
END IF
```

**Usage Pattern:**
- Use after validating side
- Returns 1 if fleet has size > 0, 0 otherwise
- Does NOT validate side - use `ValidateArmySide%` first

### IsPortCity%
Checks if city is a port city.

```qb64
IF ValidateCityIndex%(cityIndex, "FunctionName") THEN
    IF IsPortCity%(cityIndex) THEN
        ' City is a port
    END IF
END IF
```

**Usage Pattern:**
- Use after validating city index
- Returns 1 if city is a port, 0 otherwise
- Does NOT validate index bounds - use `ValidateCityIndex%` first

### IsCityOwnedBy%
Checks if city is owned by specified side.

```qb64
IF ValidateCityIndex%(cityIndex, "FunctionName") AND ValidateArmySide%(side, "FunctionName") THEN
    IF IsCityOwnedBy%(cityIndex, side) THEN
        ' City is owned by side
    END IF
END IF
```

**Usage Pattern:**
- Use after validating both city index and side
- Returns 1 if city is owned by side, 0 otherwise
- Does NOT validate bounds - use validation functions first

---

## Common Patterns

### Pattern 1: Validate Before Access
Always validate indices before accessing arrays.

```qb64
SUB ProcessArmy (armyIndex AS INTEGER)
    ' Validate index first
    IF NOT ValidateArmyIndex%(armyIndex, "ProcessArmy") THEN
        EXIT SUB
    END IF
    
    ' Now safe to access armies() array
    IF IsArmyActive%(armyIndex) THEN
        ' Process active army
        PRINT armies(armyIndex).name
    END IF
END SUB
```

### Pattern 2: Validate Multiple Parameters
Validate all parameters before processing.

```qb64
SUB MoveArmyToCity (armyIndex AS INTEGER, cityIndex AS INTEGER)
    ' Validate all parameters
    IF NOT ValidateArmyIndex%(armyIndex, "MoveArmyToCity") THEN
        EXIT SUB
    END IF
    IF NOT ValidateCityIndex%(cityIndex, "MoveArmyToCity") THEN
        EXIT SUB
    END IF
    
    ' Now safe to process
    armies(armyIndex).loc = cityIndex
END SUB
```

### Pattern 3: Validate and Check State
Combine validation with state checks.

```qb64
FUNCTION CanArmyMove% (armyIndex AS INTEGER)
    ' Validate index
    IF NOT ValidateArmyIndex%(armyIndex, "CanArmyMove") THEN
        CanArmyMove% = 0
        EXIT FUNCTION
    END IF
    
    ' Check if army is active
    IF NOT IsArmyActive%(armyIndex) THEN
        CanArmyMove% = 0
        EXIT FUNCTION
    END IF
    
    ' Additional checks...
    CanArmyMove% = 1
END FUNCTION
```

### Pattern 4: Critical Error Handling
Use for errors that prevent operation from continuing.

```qb64
SUB LoadGameData (filename AS STRING)
    ' Attempt to load file
    OPEN filename FOR INPUT AS #1
    
    IF ERR THEN
        CALL HandleCriticalError("Failed to load game data: " + filename)
        EXIT SUB
    END IF
    
    ' Continue loading...
END SUB
```

### Pattern 5: Warning for Non-Critical Issues
Use warnings when operation can continue with defaults.

```qb64
SUB LoadOptionalData (filename AS STRING)
    ' Attempt to load optional file
    IF NOT fileExists(filename) THEN
        CALL HandleWarning("Optional data file not found, using defaults")
        ' Continue with default values
    ELSE
        ' Load from file
    END IF
END SUB
```

---

## Edge Cases to Consider

### 1. Array Bounds
Always validate array indices before access:
- `armies()` - indices 1-40
- `cities()` - indices 1-MAX_CITIES
- `commanders()` - indices 1-50
- `cityMatrix()` - validate both row and column

### 2. Side Values
Always validate side values:
- Must be 1 (French) or 2 (Allied)
- Use `ValidateArmySide%` before accessing side-specific data

### 3. Active State Checks
Check if entities are active before processing:
- Use `IsArmyActive%` before processing armies
- Use `IsCityActive%` before processing cities
- Use `IsFleetActive%` before processing fleets

### 4. Matrix Access
Validate both dimensions when accessing matrices:
- Use `ValidateCityMatrixColumn%` for `cityMatrix` access
- Consider similar validation for other matrices

### 5. File Operations
Handle file errors appropriately:
- Use `HandleCriticalError` for required files
- Use `HandleFileNotFound` for expected missing files
- Use `HandleWarning` for optional files

---

## When Adding New Functions

### Checklist for New Functions

1. **Validate All Parameters**
   - [ ] Validate all index parameters using validation helpers
   - [ ] Validate side parameters using `ValidateArmySide%`
   - [ ] Validate matrix access using appropriate helpers

2. **Check Entity State**
   - [ ] Use state check helpers (`IsArmyActive%`, etc.) when needed
   - [ ] Verify entities exist before processing

3. **Handle Errors Appropriately**
   - [ ] Use `HandleCriticalError` for critical failures
   - [ ] Use `HandleValidationError` for invalid input
   - [ ] Use `HandleWarning` for non-critical issues
   - [ ] Use silent `EXIT` for valid early returns

4. **Provide Context**
   - [ ] Include function name in validation context strings
   - [ ] Include descriptive error messages

5. **Document Error Handling**
   - [ ] Document error conditions in function documentation
   - [ ] Document side effects of error handling

### Example: Well-Designed Function

```qb64
'============================================================================
' MoveArmyToCity - Move army to specified city
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to move
'   cityIndex (INTEGER) - Index of destination city
' Description:
'   Moves the specified army to the specified city.
'   Validates both indices and checks that army is active.
' Side Effects:
'   - Modifies armies(armyIndex).loc
'   - Shows error message if validation fails
'============================================================================
SUB MoveArmyToCity (armyIndex AS INTEGER, cityIndex AS INTEGER)
    ' Validate parameters
    IF NOT ValidateArmyIndex%(armyIndex, "MoveArmyToCity") THEN
        EXIT SUB
    END IF
    IF NOT ValidateCityIndex%(cityIndex, "MoveArmyToCity") THEN
        EXIT SUB
    END IF
    
    ' Check if army is active
    IF NOT IsArmyActive%(armyIndex) THEN
        CALL HandleValidationError("Cannot move inactive army " + LTRIM$(STR$(armyIndex)))
        EXIT SUB
    END IF
    
    ' Perform move
    armies(armyIndex).loc = cityIndex
    CALL ShowStatusMessage("Army moved to " + cities(cityIndex).name)
END SUB
```

---

## Reviewing Existing Functions

When reviewing functions for error handling:

1. **Check for Direct Array Access**
   - Look for `armies(i)`, `cities(i)`, `commanders(i)` without validation
   - Ensure validation occurs before access

2. **Check for Side Values**
   - Look for side parameters used without validation
   - Ensure `ValidateArmySide%` is used

3. **Check for Matrix Access**
   - Look for `cityMatrix(i, j)` without validation
   - Ensure `ValidateCityMatrixColumn%` is used

4. **Check for Error Handling**
   - Look for error conditions without handling
   - Ensure appropriate error handling functions are used

5. **Check for State Checks**
   - Look for direct state checks that could use helpers
   - Consider using `IsArmyActive%`, `IsCityActive%`, etc.

---

## Additional Validation Helpers Needed

Consider adding validation helpers for:

1. ✅ **Tactical Unit Indices** - **COMPLETED**
   - `ValidateUnitIndex%` - Validate tactical unit index (1-100)
   - Added to `src/common/error_handling.bas`

2. ✅ **Coordinate Validation** - **COMPLETED**
   - `ValidateMapCoordinates%` - Validate map coordinates (X: 1-27, Y: 1-20)
   - Added to `src/common/error_handling.bas`

3. **Terrain Validation**
   - `ValidateTerrainType%` - Validate terrain type values
   - Check terrain values are valid (if common pattern emerges)

4. **Combat Validation**
   - `ValidateCombatIntensity%` - Validate combat intensity levels
   - Check intensity values are valid (if common pattern emerges)

---

## Related Documentation

- `src/common/error_handling.bas` - Error handling implementation
- `docs/CODE_IMPROVEMENT_OPPORTUNITIES.md` - Improvement tracking
- `docs/NAMING_CONVENTIONS.md` - Code style guide

---

## Questions or Issues?

If you encounter error handling patterns not covered here, or have suggestions for additional validation helpers, please:

1. Review existing patterns in `src/common/error_handling.bas`
2. Check similar functions for examples
3. Document new patterns in this guide
4. Consider adding new validation helpers if pattern is common

---

**Last Updated:** 2025-12-26

## Recent Updates (2025-12-26)

- ✅ Added `ValidateUnitIndex%` for tactical unit validation (1-100)
- ✅ Added `ValidateMapCoordinates%` for map coordinate validation (X: 1-27, Y: 1-20)
- ✅ Comprehensive error handling patterns documentation created

