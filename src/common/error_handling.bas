'============================================================================
' Standardized Error Handling System
'============================================================================
' Provides consistent error handling patterns throughout the codebase
'
' Error Handling Standards:
' 1. CRITICAL ERRORS: ShowStatusError + EXIT (operation cannot continue)
' 2. VALIDATION ERRORS: ShowStatusError + EXIT (invalid input/state)
' 3. FILE NOT FOUND: ShowStatusMessage (info) + EXIT (expected in some cases)
' 4. WARNINGS: ShowStatusWarning + continue with defaults (non-critical)
' 5. SILENT EXIT: Only for early returns in valid code paths (not errors)
'
'============================================================================
' Error Handling Helper Functions
'============================================================================

DECLARE SUB HandleCriticalError (message AS STRING)
DECLARE SUB HandleValidationError (message AS STRING)
DECLARE SUB HandleFileNotFound (filename AS STRING)
DECLARE SUB HandleWarning (message AS STRING)
DECLARE FUNCTION ValidateArmyIndex% (armyIndex AS INTEGER, context AS STRING)
DECLARE FUNCTION ValidateCityIndex% (cityIndex AS INTEGER, context AS STRING)
DECLARE FUNCTION ValidateArmySide% (side AS INTEGER, context AS STRING)
DECLARE FUNCTION ValidateCommanderIndex% (commanderIndex AS INTEGER, context AS STRING)
DECLARE FUNCTION ValidateCityMatrixColumn% (cityIndex AS INTEGER, column AS INTEGER, context AS STRING)
DECLARE FUNCTION IsArmyActive% (armyIndex AS INTEGER)
DECLARE FUNCTION IsCityActive% (cityIndex AS INTEGER)
DECLARE FUNCTION IsFleetActive% (side AS INTEGER)
DECLARE FUNCTION IsPortCity% (cityIndex AS INTEGER)
DECLARE FUNCTION IsCityOwnedBy% (cityIndex AS INTEGER, side AS INTEGER)
DECLARE FUNCTION ValidateUnitIndex% (unitIndex AS INTEGER, context AS STRING)
DECLARE FUNCTION ValidateMapCoordinates% (x AS INTEGER, y AS INTEGER, context AS STRING)

'============================================================================
' HandleCriticalError - Handle critical errors that prevent operation
'============================================================================
' Parameters:
'   message (STRING) - Error message to display
' Description:
'   Displays error message. Caller must EXIT after calling this.
'   Use for errors that prevent the operation from continuing.
' Side Effects:
'   - Displays error message
'   - Caller must handle EXIT
'============================================================================
SUB HandleCriticalError (message AS STRING)
    CALL ShowStatusError(message)
    ' Note: Caller must EXIT SUB or EXIT FUNCTION after calling this
END SUB

'============================================================================
' HandleValidationError - Handle validation errors (invalid input/state)
'============================================================================
' Parameters:
'   message (STRING) - Error message to display
' Description:
'   Displays error message. Caller must EXIT after calling this.
'   Use for invalid input parameters or invalid game state.
' Side Effects:
'   - Displays error message
'   - Caller must handle EXIT
'============================================================================
SUB HandleValidationError (message AS STRING)
    CALL ShowStatusError(message)
    ' Note: Caller must EXIT SUB or EXIT FUNCTION after calling this
END SUB

'============================================================================
' HandleFileNotFound - Handle file not found errors
'============================================================================
' Parameters:
'   filename (STRING) - Name of file that was not found
' Description:
'   Displays informational message about missing file. Caller must EXIT after calling this.
'   Use when a required file is missing (expected in some scenarios).
' Side Effects:
'   - Displays informational message
'   - Caller must handle EXIT
'============================================================================
SUB HandleFileNotFound (filename AS STRING)
    CALL ShowStatusMessage("File not found: " + filename, 11)
    ' Note: Caller must EXIT SUB or EXIT FUNCTION after calling this
END SUB

'============================================================================
' HandleWarning - Handle non-critical warnings
'============================================================================
' Parameters:
'   message (STRING) - Warning message to display
' Description:
'   Displays warning message but continues execution.
'   Use for non-critical issues where operation can continue with defaults.
' Side Effects:
'   - Displays warning message
'   - Execution continues
'============================================================================
SUB HandleWarning (message AS STRING)
    CALL ShowStatusWarning(message)
    ' Note: Does NOT exit - execution continues
END SUB

'============================================================================
' ValidateArmyIndex - Validate army index and handle errors
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Army index to validate
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates army index is within valid range (1-40).
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateArmyIndex% (armyIndex AS INTEGER, context AS STRING)
    IF armyIndex < 1 OR armyIndex > MAX_ARMIES THEN
        CALL ShowStatusError("Invalid army index " + LTRIM$(STR$(armyIndex)) + " in " + context)
        ValidateArmyIndex% = 0
    ELSE
        ValidateArmyIndex% = 1
    END IF
END FUNCTION

'============================================================================
' ValidateCityIndex - Validate city index and handle errors
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City index to validate
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates city index is within valid range (1-MAX_CITIES).
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateCityIndex% (cityIndex AS INTEGER, context AS STRING)
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        CALL ShowStatusError("Invalid city index " + LTRIM$(STR$(cityIndex)) + " in " + context)
        ValidateCityIndex% = 0
    ELSE
        ValidateCityIndex% = 1
    END IF
END FUNCTION

'============================================================================
' ValidateArmySide - Validate army side and handle errors
'============================================================================
' Parameters:
'   side (INTEGER) - Side to validate (should be 1 or 2)
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates side is 1 (French) or 2 (Allied).
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateArmySide% (side AS INTEGER, context AS STRING)
    IF side < 1 OR side > 2 THEN
        CALL ShowStatusError("Invalid side " + LTRIM$(STR$(side)) + " in " + context)
        ValidateArmySide% = 0
    ELSE
        ValidateArmySide% = 1
    END IF
END FUNCTION

'============================================================================
' ValidateCommanderIndex - Validate commander index and handle errors
'============================================================================
' Parameters:
'   commanderIndex (INTEGER) - Commander index to validate
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates commander index is within valid range (1-50).
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateCommanderIndex% (commanderIndex AS INTEGER, context AS STRING)
    IF commanderIndex < 1 OR commanderIndex > 50 THEN
        CALL ShowStatusError("Invalid commander index " + LTRIM$(STR$(commanderIndex)) + " in " + context)
        ValidateCommanderIndex% = 0
    ELSE
        ValidateCommanderIndex% = 1
    END IF
END FUNCTION

'============================================================================
' ValidateCityMatrixColumn - Validate cityMatrix access bounds
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City index to validate
'   column (INTEGER) - Column index to validate (1-CITY_MATRIX_COLUMNS)
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates both city index and column index for cityMatrix access.
'   cityMatrix bounds: (1 TO MAX_CITIES, 1 TO CITY_MATRIX_COLUMNS)
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateCityMatrixColumn% (cityIndex AS INTEGER, column AS INTEGER, context AS STRING)
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        CALL ShowStatusError("Invalid city index " + LTRIM$(STR$(cityIndex)) + " for cityMatrix access in " + context)
        ValidateCityMatrixColumn% = 0
    ELSEIF column < 1 OR column > CITY_MATRIX_COLUMNS THEN
        CALL ShowStatusError("Invalid cityMatrix column " + LTRIM$(STR$(column)) + " (valid: 1-" + LTRIM$(STR$(CITY_MATRIX_COLUMNS)) + ") in " + context)
        ValidateCityMatrixColumn% = 0
    ELSE
        ValidateCityMatrixColumn% = 1
    END IF
END FUNCTION

'============================================================================
' Common Validation Pattern Helpers
'============================================================================
' These functions extract common validation patterns to reduce code duplication
'============================================================================

'============================================================================
' IsArmyActive - Check if army exists and is active (has size > 0)
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Army index to check
' Returns:
'   INTEGER - 1 if army is active (exists and has size > 0), 0 otherwise
' Description:
'   Checks if an army exists and is active (has non-zero size).
'   This is a common pattern: IF armies(i).size > 0
'   Does NOT validate index bounds - use ValidateArmyIndex% first if needed.
'============================================================================
FUNCTION IsArmyActive% (armyIndex AS INTEGER)
    IF armyIndex < 1 OR armyIndex > MAX_ARMIES THEN
        IsArmyActive% = 0
    ELSEIF armies(armyIndex).size > 0 THEN
        IsArmyActive% = 1
    ELSE
        IsArmyActive% = 0
    END IF
END FUNCTION

'============================================================================
' IsCityActive - Check if city exists and is active (has name)
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City index to check
' Returns:
'   INTEGER - 1 if city is active (exists and has name), 0 otherwise
' Description:
'   Checks if a city exists and is active (has non-empty name).
'   This is a common pattern: IF cities(i).name <> ""
'   Does NOT validate index bounds - use ValidateCityIndex% first if needed.
'============================================================================
FUNCTION IsCityActive% (cityIndex AS INTEGER)
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        IsCityActive% = 0
    ELSEIF cities(cityIndex).name <> "" THEN
        IsCityActive% = 1
    ELSE
        IsCityActive% = 0
    END IF
END FUNCTION

'============================================================================
' IsFleetActive - Check if fleet exists and is active (has size > 0)
'============================================================================
' Parameters:
'   side (INTEGER) - Side to check (1=French, 2=Allied)
' Returns:
'   INTEGER - 1 if fleet is active (has size > 0), 0 otherwise
' Description:
'   Checks if a fleet exists and is active (has non-zero size).
'   This is a common pattern: IF fleets(side).size > 0
'   Does NOT validate side - use ValidateArmySide% first if needed.
'============================================================================
FUNCTION IsFleetActive% (side AS INTEGER)
    IF side < 1 OR side > 2 THEN
        IsFleetActive% = 0
    ELSEIF fleets(side).size > 0 THEN
        IsFleetActive% = 1
    ELSE
        IsFleetActive% = 0
    END IF
END FUNCTION

'============================================================================
' IsPortCity - Check if city is a port city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City index to check
' Returns:
'   INTEGER - 1 if city is a port (cityMatrix(cityIndex, CITY_MATRIX_COLUMNS) = 1), 0 otherwise
' Description:
'   Checks if a city is a port city using the cityMatrix.
'   This is a common pattern: IF cityMatrix(i, CITY_MATRIX_COLUMNS) = 1
'   Does NOT validate index bounds - use ValidateCityIndex% first if needed.
'============================================================================
FUNCTION IsPortCity% (cityIndex AS INTEGER)
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        IsPortCity% = 0
    ELSEIF cityMatrix(cityIndex, CITY_MATRIX_COLUMNS) = 1 THEN
        IsPortCity% = 1
    ELSE
        IsPortCity% = 0
    END IF
END FUNCTION

'============================================================================
' IsCityOwnedBy - Check if city is owned by specified side
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City index to check
'   side (INTEGER) - Side to check (1=French, 2=Allied)
' Returns:
'   INTEGER - 1 if city is owned by side, 0 otherwise
' Description:
'   Checks if a city is owned by the specified side.
'   This is a common pattern: IF cities(i).owner = side
'   Does NOT validate index bounds or side - use ValidateCityIndex% and ValidateArmySide% first if needed.
'============================================================================
FUNCTION IsCityOwnedBy% (cityIndex AS INTEGER, side AS INTEGER)
    IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
        IsCityOwnedBy% = 0
    ELSEIF side < 1 OR side > 2 THEN
        IsCityOwnedBy% = 0
    ELSEIF cities(cityIndex).owner = side THEN
        IsCityOwnedBy% = 1
    ELSE
        IsCityOwnedBy% = 0
    END IF
END FUNCTION

'============================================================================
' ValidateUnitIndex - Validate tactical unit index and handle errors
'============================================================================
' Parameters:
'   unitIndex (INTEGER) - Tactical unit index to validate
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates tactical unit index is within valid range (1-100).
'   Tactical unit arrays (unit$, unitx, unity, strength, etc.) use indices 1-100.
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateUnitIndex% (unitIndex AS INTEGER, context AS STRING)
    IF unitIndex < 1 OR unitIndex > 100 THEN
        CALL ShowStatusError("Invalid unit index " + LTRIM$(STR$(unitIndex)) + " (valid: 1-100) in " + context)
        ValidateUnitIndex% = 0
    ELSE
        ValidateUnitIndex% = 1
    END IF
END FUNCTION

'============================================================================
' ValidateMapCoordinates - Validate tactical map coordinates and handle errors
'============================================================================
' Parameters:
'   x (INTEGER) - X coordinate to validate
'   y (INTEGER) - Y coordinate to validate
'   context (STRING) - Context description for error message
' Returns:
'   INTEGER - 1 if valid, 0 if invalid
' Description:
'   Validates tactical map coordinates are within valid bounds.
'   Map bounds: X = 1-27 (MAP_WIDTH), Y = 1-20 (MAP_HEIGHT).
'   Shows error message if invalid.
'============================================================================
FUNCTION ValidateMapCoordinates% (x AS INTEGER, y AS INTEGER, context AS STRING)
    DIM isValid AS INTEGER
    isValid = 1
    
    IF x < 1 OR x > 27 THEN
        CALL ShowStatusError("Invalid X coordinate " + LTRIM$(STR$(x)) + " (valid: 1-27) in " + context)
        isValid = 0
    END IF
    
    IF y < 1 OR y > 20 THEN
        CALL ShowStatusError("Invalid Y coordinate " + LTRIM$(STR$(y)) + " (valid: 1-20) in " + context)
        isValid = 0
    END IF
    
    ValidateMapCoordinates% = isValid
END FUNCTION

