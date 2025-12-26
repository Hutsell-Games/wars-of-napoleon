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

