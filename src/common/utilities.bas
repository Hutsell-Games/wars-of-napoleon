'============================================================================
' Utility Functions
'============================================================================
' Common utility functions used throughout the game

' Shared error flag for file operations (module-level)
' Must be declared before any SUB/FUNCTION declarations
DIM SHARED fileOpenErrorFlag AS INTEGER
DIM SHARED fileOpenErrorMessage AS STRING

DECLARE SUB TICK (duration AS SINGLE)
DECLARE SUB clrbot ()
DECLARE SUB clrrite ()
DECLARE SUB ShowStatusMessage (message AS STRING, drawColor AS INTEGER)
DECLARE SUB ShowStatusError (message AS STRING)
DECLARE SUB ShowStatusWarning (message AS STRING)
DECLARE FUNCTION GetArmySide% (armyIndex AS INTEGER)
DECLARE FUNCTION SafeOpenFile% (filename AS STRING, mode AS STRING, fileNumber AS INTEGER)
' Error handling functions (from error_handling.bas)
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

'============================================================================
' TICK - Wait for specified duration
'============================================================================
' NOTE: TICK is implemented in tactical/napoleon_subs.bas for tactical battles
' This declaration is removed to avoid "Name already in use" errors
' Strategic/UI code should use the tactical version
'============================================================================
' SUB TICK (duration AS SINGLE) - REMOVED: Duplicate of tactical/napoleon_subs.bas

'============================================================================
' clrbot - Clear bottom area of screen
'============================================================================
' NOTE: clrbot is implemented in tactical/napoleon_subs.bas for tactical battles
' This declaration is removed to avoid "Name already in use" errors
' Strategic/UI code should use the tactical version
'============================================================================
' SUB clrbot - REMOVED: Duplicate of tactical/napoleon_subs.bas

SUB clrrite
    ' Clear right side of screen
    ' Used for menus
    
    LINE (500, 0)-(640, 480), 0, BF
END SUB

'============================================================================
' LEFTY$ - Get left character of unit type string
'============================================================================
' NOTE: LEFTY$ is implemented in tactical/napoleon_subs.bas for tactical battles
' This placeholder is removed to avoid "Name already in use" errors
'============================================================================
' FUNCTION LEFTY$ (index AS INTEGER) - REMOVED: Duplicate of tactical/napoleon_subs.bas

'============================================================================
' GetRandomNumber - Generate random integer in range
'============================================================================
' Parameters:
'   min (INTEGER) - Minimum value (inclusive)
'   max (INTEGER) - Maximum value (inclusive)
' Returns:
'   INTEGER - Random number between min and max (inclusive)
'============================================================================
FUNCTION GetRandomNumber% (min AS INTEGER, max AS INTEGER)
    GetRandomNumber% = INT(RND * (max - min + 1)) + min
END FUNCTION

'============================================================================
' ClampValue - Clamp integer value between minimum and maximum
'============================================================================
' Parameters:
'   value (INTEGER) - Value to clamp
'   min (INTEGER) - Minimum allowed value
'   max (INTEGER) - Maximum allowed value
' Returns:
'   INTEGER - Clamped value (min if value < min, max if value > max, else value)
' Description:
'   Ensures a value stays within specified bounds. Returns min if value is
'   less than min, max if value is greater than max, otherwise returns
'   the original value unchanged.
'============================================================================
FUNCTION ClampValue% (value AS INTEGER, min AS INTEGER, max AS INTEGER)
    ' Clamp value between min and max
    IF value < min THEN
        ClampValue% = min
    ELSEIF value > max THEN
        ClampValue% = max
    ELSE
        ClampValue% = value
    END IF
END FUNCTION

'============================================================================
' ClampValueLong - Clamp long integer value between minimum and maximum
'============================================================================
' Parameters:
'   value (LONG) - Value to clamp
'   min (LONG) - Minimum allowed value
'   max (LONG) - Maximum allowed value
' Returns:
'   LONG - Clamped value (min if value < min, max if value > max, else value)
' Description:
'   Ensures a long integer value stays within specified bounds. Returns min
'   if value is less than min, max if value is greater than max, otherwise
'   returns the original value unchanged.
'============================================================================
FUNCTION ClampValueLong& (value AS LONG, min AS LONG, max AS LONG)
    ' Clamp long value between min and max
    IF value < min THEN
        ClampValueLong& = min
    ELSEIF value > max THEN
        ClampValueLong& = max
    ELSE
        ClampValueLong& = value
    END IF
END FUNCTION

'============================================================================
' ClampValueSingle - Clamp single-precision value between minimum and maximum
'============================================================================
' Parameters:
'   value (SINGLE) - Value to clamp
'   min (SINGLE) - Minimum allowed value
'   max (SINGLE) - Maximum allowed value
' Returns:
'   SINGLE - Clamped value (min if value < min, max if value > max, else value)
' Description:
'   Ensures a single-precision floating point value stays within specified
'   bounds. Returns min if value is less than min, max if value is greater
'   than max, otherwise returns the original value unchanged.
'============================================================================
FUNCTION ClampValueSingle! (value AS SINGLE, min AS SINGLE, max AS SINGLE)
    ' Clamp single value between min and max
    IF value < min THEN
        ClampValueSingle! = min
    ELSEIF value > max THEN
        ClampValueSingle! = max
    ELSE
        ClampValueSingle! = value
    END IF
END FUNCTION

FUNCTION FormatNumber$ (number AS LONG)
    ' Format number with commas (e.g., 1,234,567)
    ' Returns formatted string with commas inserted every 3 digits from right
    ' 
    ' Algorithm:
    '   1. Convert number to string
    '   2. Process from right to left
    '   3. Insert comma every 3 digits (except at the end)
    
    DIM numStr AS STRING
    DIM result AS STRING
    DIM i AS INTEGER
    DIM digitCount AS INTEGER
    DIM lenNum AS INTEGER
    
    ' Convert to string and remove leading space from STR$
    numStr = LTRIM$(STR$(number))
    lenNum = LEN(numStr)
    
    ' Handle negative numbers
    DIM isNegative AS INTEGER
    isNegative = 0
    IF LEFT$(numStr, 1) = "-" THEN
        isNegative = 1
        numStr = MID$(numStr, 2) ' Remove minus sign temporarily
        lenNum = lenNum - 1
    END IF
    
    ' If number is small (3 digits or less), no commas needed
    IF lenNum <= 3 THEN
        IF isNegative THEN
            FormatNumber$ = "-" + numStr
        ELSE
            FormatNumber$ = numStr
        END IF
        EXIT FUNCTION
    END IF
    
    ' Build result string from right to left, inserting commas
    result = ""
    digitCount = 0
    
    FOR i = lenNum TO 1 STEP -1
        ' Add digit
        result = MID$(numStr, i, 1) + result
        digitCount = digitCount + 1
        
        ' Insert comma every 3 digits (but not at the start)
        IF digitCount = 3 AND i > 1 THEN
            result = "," + result
            digitCount = 0
        END IF
    NEXT i
    
    ' Add negative sign back if needed
    IF isNegative THEN
        result = "-" + result
    END IF
    
    FormatNumber$ = result
END FUNCTION

'============================================================================
' GetPercentage - Calculate percentage of part relative to total
'============================================================================
' Parameters:
'   part (LONG) - Part value
'   total (LONG) - Total value
' Returns:
'   SINGLE - Percentage (0-100), or 0 if total is 0 (prevents division by zero)
' Description:
'   Safely calculates percentage with division by zero protection
'============================================================================
FUNCTION GetPercentage! (part AS LONG, total AS LONG)
    IF total = 0 THEN
        GetPercentage! = 0
    ELSE
        GetPercentage! = (part / total) * 100
    END IF
END FUNCTION

'============================================================================
' GetRatio - Calculate ratio between two values
'============================================================================
' Parameters:
'   value1 (LONG) - First value (numerator)
'   value2 (LONG) - Second value (denominator)
' Returns:
'   SINGLE - Ratio (value1/value2), or 0 if value2 is 0 (prevents division by zero)
' Description:
'   Safely calculates ratio with division by zero protection
'============================================================================
FUNCTION GetRatio! (value1 AS LONG, value2 AS LONG)
    IF value2 = 0 THEN
        GetRatio! = 0
    ELSE
        GetRatio! = value1 / value2
    END IF
END FUNCTION

SUB LogMessage (message AS STRING)
    ' Log message to file (if logging enabled)
    ' Writes timestamped messages to log file
    ' Log file: "logs/game.log" (created if doesn't exist)
    
    DIM logFilename AS STRING
    DIM timestamp AS STRING
    DIM logDir AS STRING
    
    ' Check if logging should be enabled (can be controlled by config)
    ' For now, always log if function is called
    
    ' Initialize log file on first call
    IF logInitialized = 0 THEN
        logFilename = "logs/game.log"
        logDir = "logs"
        
        ' Create logs directory if it doesn't exist (QB64 will create on file open)
        ' Note: In QB64, we can't directly create directories, but file open will work
        
        ' Open log file in append mode using SafeOpenFile
        logFileNum = FREEFILE
        IF SafeOpenFile%(logFilename, "A", logFileNum) = 1 THEN
            logInitialized = 1
            
            ' Write header if file is new (check if file is empty)
            IF LOF(logFileNum) = 0 THEN
                PRINT #logFileNum, "=== Game Log Started ==="
                PRINT #logFileNum, "Date: "; DATE$; " Time: "; TIME$
                PRINT #logFileNum, ""
            END IF
        ELSE
            ' If logging fails, silently continue (don't break game)
            ' Could optionally show warning, but logging should be non-critical
            logInitialized = 0
            logFileNum = 0
        END IF
    END IF
    
    ' Write log message with timestamp
    IF logFileNum > 0 THEN
        timestamp = DATE$ + " " + TIME$
        PRINT #logFileNum, "["; timestamp; "] "; message
        ' Flush to ensure message is written immediately
        ' Note: QB64 may buffer, but this ensures data is written
    END IF
END SUB

SUB CloseLogFile
    ' Close log file (call on game exit)
    ' Uses shared logFileNum variable from LogMessage
    
    IF logFileNum > 0 THEN
        PRINT #logFileNum, "=== Game Log Ended ==="
        PRINT #logFileNum, ""
        CLOSE #logFileNum
        logFileNum = 0
        logInitialized = 0
    END IF
END SUB

SUB DebugPrint (message AS STRING)
    ' Debug print (only in debug mode)
    ' Checks DEBUG flag from declarations.bas and prints message if DEBUG = 1
    IF DEBUG = 1 THEN
        PRINT "DEBUG: "; message
    END IF
END SUB

FUNCTION GetFileSize& (filename AS STRING)
    ' Get file size in bytes
    ' Uses QB64 file operations to determine file size
    ' Returns file size in bytes, or -1 if file doesn't exist or error
    
    DIM fileNum AS INTEGER
    DIM fileSize AS LONG
    
    ' Check if file exists first
    IF NOT _FILEEXISTS(filename) THEN
        GetFileSize& = -1 ' File doesn't exist
        EXIT FUNCTION
    END IF
    
    ' Open file in binary mode to get size using SafeOpenFile
    fileNum = FREEFILE
    IF SafeOpenFile%(filename, "B", fileNum) = 1 THEN
        fileSize = LOF(fileNum) ' Get length of file
        CLOSE #fileNum
        GetFileSize& = fileSize
    ELSE
        ' File open failed
        GetFileSize& = -1 ' Error reading file
    END IF
END FUNCTION

'============================================================================
' CopyFile - Copy a file from source to destination
'============================================================================
' Parameters:
'   sourceFile (STRING) - Path to source file
'   destFile (STRING) - Path to destination file
' Description:
'   Copies a file from the source path to the destination path using the
'   system copy command. Uses SHELL to execute the copy operation.
'   Note: This function does not check if the source file exists or if the
'   destination file already exists before copying.
' Side Effects:
'   - Creates or overwrites destination file
'   - Executes system command via SHELL
'============================================================================
SUB CopyFile (sourceFile AS STRING, destFile AS STRING)
    ' Copy file
    ' Uses SHELL command for file copy
    DIM cmd AS STRING
    cmd = "copy " + sourceFile + " " + destFile
    SHELL cmd
END SUB

'============================================================================
' GetCurrentDate - Get current system date as string
'============================================================================
' Returns:
'   STRING - Current date in system format (typically MM-DD-YYYY or DD-MM-YYYY)
' Description:
'   Returns the current system date as a string using QB64's DATE$ function.
'   The format depends on system locale settings.
'============================================================================
FUNCTION GetCurrentDate$ ()
    ' Get current date as string
    GetCurrentDate$ = DATE$
END FUNCTION

'============================================================================
' GetCurrentTime - Get current system time as string
'============================================================================
' Returns:
'   STRING - Current time in system format (typically HH:MM:SS)
' Description:
'   Returns the current system time as a string using QB64's TIME$ function.
'   The format is typically HH:MM:SS in 24-hour format.
'============================================================================
FUNCTION GetCurrentTime$ ()
    ' Get current time as string
    GetCurrentTime$ = TIME$
END FUNCTION

'============================================================================
' PlaySound - Play a sound at specified frequency and duration
'============================================================================
' Parameters:
'   frequency (INTEGER) - Sound frequency in Hz (typically 37-32767)
'   duration (SINGLE) - Duration in seconds
' Description:
'   Plays a sound using QB64's SOUND statement. The frequency determines
'   the pitch (higher = higher pitch), and duration controls how long the
'   sound plays.
' Side Effects:
'   - Produces audible sound output
'============================================================================
SUB PlaySound (frequency AS INTEGER, duration AS SINGLE)
    ' Play sound
    ' QB64 compatible
    SOUND frequency, duration
END SUB

'============================================================================
' PlayBeep - Play a system beep sound
'============================================================================
' Description:
'   Plays a system beep sound using QB64's BEEP statement. This produces
'   a simple beep tone, typically used for alerts or notifications.
' Side Effects:
'   - Produces audible beep sound
'============================================================================
SUB PlayBeep
    ' Play beep sound
    BEEP
END SUB

'============================================================================
' SetScreenMode - Set the screen graphics mode
'============================================================================
' Parameters:
'   mode (INTEGER) - Screen mode number (e.g., 9=EGA, 12=VGA)
' Description:
'   Sets the screen graphics mode using QB64's SCREEN statement. Common
'   modes include 9 (EGA 640x350), 12 (VGA 640x480), etc. The available
'   modes depend on the graphics capabilities of the system.
' Side Effects:
'   - Changes screen resolution and color depth
'   - Clears the screen
'============================================================================
SUB SetScreenMode (mode AS INTEGER)
    ' Set screen mode
    ' Mode: 9=EGA, 12=VGA, etc.
    SCREEN mode
END SUB

'============================================================================
' ClearScreen - Clear the entire screen
'============================================================================
' Description:
'   Clears the entire screen using QB64's CLS statement. Removes all text
'   and graphics from the display, resetting it to a blank state.
' Side Effects:
'   - Clears all screen content
'============================================================================
SUB ClearScreen
    ' Clear entire screen
    CLS
END SUB

'============================================================================
' GetKeyPress - Get key press (non-blocking)
'============================================================================
' Returns:
'   STRING - Key pressed as string, or empty string if no key pressed
' Description:
'   Checks for a key press without blocking execution. Returns the key
'   pressed as a string if one is available, or an empty string if no key
'   has been pressed. Uses QB64's INKEY$ function for non-blocking input.
'============================================================================
FUNCTION GetKeyPress$ ()
    ' Get key press (non-blocking)
    ' Returns empty string if no key pressed
    GetKeyPress$ = INKEY$
END FUNCTION

'============================================================================
' WaitForKeyPress - Wait for key press (blocking)
'============================================================================
' Returns:
'   STRING - Key pressed as string
' Description:
'   Waits for the user to press a key, blocking execution until a key is
'   pressed. Returns the key pressed as a string. Uses a loop with INKEY$
'   to wait for input.
' Side Effects:
'   - Blocks execution until user presses a key
'============================================================================
FUNCTION WaitForKeyPress$
    ' Wait for key press (blocking)
    ' Returns key pressed
    DIM keyPress AS STRING
    DO
        keyPress = INKEY$
    LOOP WHILE keyPress = ""
    WaitForKeyPress$ = keyPress
END FUNCTION

'============================================================================
' PauseGame - Pause game execution and wait for key press
'============================================================================
' Description:
'   Pauses game execution by displaying a message and waiting for the user
'   to press any key. Displays "Press any key to continue..." and blocks
'   until a key is pressed. Useful for pausing game flow to allow the
'   player to read messages or view screens.
' Side Effects:
'   - Displays message to screen
'   - Blocks execution until key press
'============================================================================
SUB PauseGame
    ' Pause game (wait for keypress)
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
' ConfirmAction - Confirm an action with Yes/No prompt
'============================================================================
' Parameters:
'   prompt (STRING) - Prompt message to display to user
' Returns:
'   INTEGER - 1 if user confirms (Yes), 0 if user declines (No)
' Description:
'   Displays a prompt message and waits for the user to respond with Y (Yes)
'   or N (No). The response is case-insensitive. Returns 1 if the user
'   responds with Y, 0 if the user responds with N or any other key.
' Side Effects:
'   - Displays prompt message to screen
'   - Waits for user input
'============================================================================
FUNCTION ConfirmAction% (prompt AS STRING)
    ' Confirm action with Yes/No
    ' Returns 1=Yes, 0=No
    DIM response AS STRING
    PRINT prompt; " (Y/N): "
    response = UCASE$(WaitForKeyPress$)
    IF response = "Y" THEN
        ConfirmAction% = 1
    ELSE
        ConfirmAction% = 0
    END IF
END FUNCTION

SUB ShowHelp (topic AS STRING)
    ' Show help for topic
    ' Displays context-sensitive help information
    ' Topics: "general", "commands", "combat", "economy", "naval", "tactical", "reports"
    
    DIM helpTopic AS STRING
    DIM i AS INTEGER
    
    ' Normalize topic to lowercase for comparison
    helpTopic = LCASE$(LTRIM$(RTRIM$(topic)))
    
    ' If topic is empty, show general help
    IF helpTopic = "" THEN helpTopic = "general"
    
    CLS
    COLOR 15: PRINT "HELP: "; UCASE$(topic)
    PRINT STRING$(80, "-")
    PRINT
    
    ' Display help based on topic
    SELECT CASE helpTopic
        CASE "general", "main", "overview"
            PRINT "WARS OF NAPOLEON - GENERAL HELP"
            PRINT
            PRINT "This is a strategic wargame set during the Napoleonic era."
            PRINT "You command armies, manage resources, and fight battles."
            PRINT
            PRINT "MAIN MENU OPTIONS:"
            PRINT "  - Move: Move armies between cities"
            PRINT "  - Recruit: Recruit new armies"
            PRINT "  - Build: Build ships and fortifications"
            PRINT "  - Combat: Engage in strategic combat"
            PRINT "  - Reports: View game status and intelligence"
            PRINT "  - Save/Load: Manage game saves"
            PRINT
            PRINT "KEYS:"
            PRINT "  Arrow Keys: Navigate menus"
            PRINT "  Enter: Select option"
            PRINT "  Escape: Cancel/Back"
            PRINT "  F1: Show this help"
            
        CASE "commands", "army", "armies"
            PRINT "ARMY COMMANDS HELP"
            PRINT
            PRINT "Available commands for armies:"
            PRINT "  - Cancel Move Orders: Cancel pending movement"
            PRINT "  - Fortify: Increase city fortification level"
            PRINT "  - Join: Combine two armies"
            PRINT "  - Supply: Manually supply army"
            PRINT "  - Detach: Split army into smaller units"
            PRINT "  - Drill: Improve army experience"
            PRINT "  - Relieve: Replace army commander"
            PRINT
            PRINT "ARMY ATTRIBUTES:"
            PRINT "  - Size: Number of men (in hundreds)"
            PRINT "  - Leadership: Commander rating (1-10)"
            PRINT "  - Experience: Combat experience (0-10)"
            PRINT "  - Supply: Supply level (0-10)"
            
        CASE "combat", "battle", "fighting"
            PRINT "COMBAT HELP"
            PRINT
            PRINT "Strategic combat occurs when armies meet in the same city."
            PRINT
            PRINT "COMBAT RESOLUTION:"
            PRINT "  - Automatic: Small battles resolved automatically"
            PRINT "  - Tactical: Large battles can be fought tactically"
            PRINT "  - Results: Casualties, experience gain, city control"
            PRINT
            PRINT "FACTORS:"
            PRINT "  - Army strength and size"
            PRINT "  - Commander leadership"
            PRINT "  - Army experience"
            PRINT "  - Fortification level"
            PRINT "  - Supply status"
            PRINT "  - Terrain and weather"
            
        CASE "economy", "money", "income", "resources"
            PRINT "ECONOMY HELP"
            PRINT
            PRINT "RESOURCES:"
            PRINT "  - Money: Used for recruitment, building, supply"
            PRINT "  - Income: Generated from controlled cities"
            PRINT "  - Victory Points: Earned from objectives"
            PRINT
            PRINT "COSTS:"
            PRINT "  - Recruit Army: 100 money units"
            PRINT "  - Build Ship: 100 money units"
            PRINT "  - Fortify City: 50 money units per level"
            PRINT "  - Supply Army: Variable cost"
            
        CASE "naval", "fleet", "ships"
            PRINT "NAVAL OPERATIONS HELP"
            PRINT
            PRINT "FLEET MANAGEMENT:"
            PRINT "  - Build Ships: Create ships in port cities"
            PRINT "  - Move Fleet: Move fleet between ports"
            PRINT "  - Blockade: Blockade enemy ports"
            PRINT "  - Bombard: Bombard coastal cities"
            PRINT
            PRINT "RESTRICTIONS:"
            PRINT "  - Ships can only be built in port cities"
            PRINT "  - Fleets can move to any port per turn"
            PRINT "  - Maximum fleet size: 10 ships"
            
        CASE "tactical", "tactical battle", "battle mode"
            PRINT "TACTICAL BATTLE HELP"
            PRINT
            PRINT "Tactical battles allow you to control individual units."
            PRINT
            PRINT "CONTROLS:"
            PRINT "  - Arrow Keys: Move cursor"
            PRINT "  - Enter: Select unit/execute order"
            PRINT "  - Escape: Cancel order"
            PRINT "  - Mouse: Click to select units (if enabled)"
            PRINT
            PRINT "UNIT TYPES:"
            PRINT "  - Infantry: Basic foot soldiers"
            PRINT "  - Cavalry: Fast moving, good for charges"
            PRINT "  - Artillery: Long range, powerful"
            PRINT "  - Guards: Elite units with high morale"
            
        CASE "reports", "intelligence", "status"
            PRINT "REPORTS HELP"
            PRINT
            PRINT "Available reports (F1-F7):"
            PRINT "  F1 - Friendly Army Report: Your armies"
            PRINT "  F2 - Enemy Army Report: Enemy armies"
            PRINT "  F3 - City Report: City status"
            PRINT "  F4 - Force Summary: Map with army strengths"
            PRINT "  F5 - Intelligence Report: Detailed army info"
            PRINT "  F6 - Battle Summary: Recent battles"
            PRINT "  F7 - History: Game history log"
            
        CASE "scenario", "scenarios", "campaign"
            PRINT "SCENARIO HELP"
            PRINT
            PRINT "Available scenarios:"
            PRINT "  - 1796 Campaign: Early Napoleonic Wars"
            PRINT "  - 1805 Campaign: Austerlitz campaign"
            PRINT "  - 1807 Campaign: Friedland campaign"
            PRINT "  - 1808 Campaign: Peninsular War begins"
            PRINT "  - 1812 Campaign: Russian campaign"
            PRINT "  - 1813 Campaign: War of the Sixth Coalition"
            PRINT "  - 1815 Campaign: Waterloo campaign"
            PRINT
            PRINT "Each scenario has different starting conditions,"
            PRINT "objectives, and victory conditions."
            
        CASE ELSE
            ' Unknown topic - show general help
            COLOR 14: PRINT "Unknown help topic: "; topic
            PRINT
            COLOR 15: PRINT "Available help topics:"
            PRINT "  - general: General game help"
            PRINT "  - commands: Army commands"
            PRINT "  - combat: Combat system"
            PRINT "  - economy: Economy and resources"
            PRINT "  - naval: Naval operations"
            PRINT "  - tactical: Tactical battles"
            PRINT "  - reports: Game reports"
            PRINT "  - scenario: Scenarios and campaigns"
            PRINT
            PRINT "Type: ShowHelp ""topic"" to see specific help"
    END SELECT
    
    PRINT
    PRINT STRING$(80, "-")
    COLOR 11: PRINT "Press any key to continue..."
    CALL PauseGame
END SUB

SUB ShowAbout
    ' Show about screen
    CLS
    COLOR 15: PRINT "WARS OF NAPOLEON"
    PRINT STRING$(80, "-")
    PRINT "Strategic and Tactical Wargame"
    PRINT "Recreated in QB64"
    PRINT
    PRINT "Based on original game by W.R. Hutsell"
    PRINT "Modernized architecture with unified strategic-tactical integration"
    PRINT
    CALL PauseGame
END SUB

'============================================================================
' Message Display Functions
'============================================================================
' Helper functions for consistent message display throughout the game

'============================================================================
' ShowStatusMessage - Display informational message in status area
'============================================================================
' Parameters:
'   message (STRING) - Message text to display
'   color (INTEGER) - Color code (default 11 = cyan)
' Description:
'   Displays a message in the bottom area of the screen with consistent formatting.
'   Clears bottom area first, then displays message in specified color.
'   Note: This is for status messages. For user-facing messages with duration,
'   use ShowMessage from menus.bas instead.
'============================================================================
SUB ShowStatusMessage (message AS STRING, drawColor AS INTEGER)
    COLOR drawColor: CALL clrbot: PRINT message
END SUB

'============================================================================
' ShowStatusError - Display error message in status area
'============================================================================
' Parameters:
'   message (STRING) - Error message text to display
' Description:
'   Displays an error message in red (color 12) in the bottom area of the screen.
'   Note: This is for status messages. For user-facing error messages with beep,
'   use ShowError from menus.bas instead.
'============================================================================
SUB ShowStatusError (message AS STRING)
    COLOR 12: CALL clrbot: PRINT "ERROR: "; message
END SUB

'============================================================================
' ShowStatusWarning - Display warning message in status area
'============================================================================
' Parameters:
'   message (STRING) - Warning message text to display
' Description:
'   Displays a warning message in yellow (color 14) in the bottom area of the screen.
'   Note: This is for status messages. For user-facing warning messages,
'   use ShowWarning from menus.bas instead.
'============================================================================
SUB ShowStatusWarning (message AS STRING)
    COLOR 14: CALL clrbot: PRINT "Warning: "; message
END SUB

'============================================================================
' GetArmySide - Determine which side an army belongs to
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to check
' Returns:
'   INTEGER - Side number (1=French, 2=Allied, 0=invalid)
' Description:
'   Determines which side an army belongs to based on its index.
'   French armies are indices 1-20 (FRENCH_START to ALLIED_START-1).
'   Allied armies are indices 21-40 (ALLIED_START to ALLIED_START+19).
'============================================================================
FUNCTION GetArmySide% (armyIndex AS INTEGER)
    IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START THEN
        GetArmySide% = 1 ' French
    ELSEIF armyIndex >= ALLIED_START AND armyIndex <= ALLIED_START + 19 THEN
        GetArmySide% = 2 ' Allied
    ELSE
        GetArmySide% = 0 ' Invalid
    END IF
END FUNCTION

'============================================================================
' SafeOpenFile - Open file with error checking
'============================================================================
' Parameters:
'   filename (STRING) - Path to file to open
'   mode (STRING) - File mode ("I" for input, "O" for output, "A" for append)
'   fileNumber (INTEGER) - File number to use (1-255)
' Returns:
'   INTEGER - 1 if file opened successfully, 0 if error
' Description:
'   Opens a file with proper error checking. For input mode, checks if file
'   exists first. Returns 1 on success, 0 on failure.
' Side Effects:
'   Opens file handle for subsequent I/O operations
'============================================================================
FUNCTION SafeOpenFile% (filename AS STRING, mode AS STRING, fileNumber AS INTEGER)
    ' Open file with proper error handling
    ' Validates inputs and attempts to open file
    ' Returns 1 on success, 0 on failure
    
    ' Validate mode parameter
    IF mode <> "I" AND mode <> "O" AND mode <> "A" THEN
        CALL HandleCriticalError("Invalid file mode: " + mode)
        SafeOpenFile% = 0
        EXIT FUNCTION
    END IF
    
    ' Validate file number
    IF fileNumber < 1 OR fileNumber > 255 THEN
        CALL HandleCriticalError("Invalid file number: " + LTRIM$(STR$(fileNumber)))
        SafeOpenFile% = 0
        EXIT FUNCTION
    END IF
    
    ' For input mode, check if file exists first
    IF mode = "I" THEN
        IF NOT _FILEEXISTS(filename) THEN
            SafeOpenFile% = 0
            EXIT FUNCTION
        END IF
    END IF
    
    ' Attempt to open the file with error handling
    ' Use ON ERROR RESUME NEXT to suppress errors, then check if open succeeded
    fileOpenErrorFlag = 0
    fileOpenErrorMessage = ""
    
    ' Set error handler to resume next (suppress errors temporarily)
    ON ERROR RESUME NEXT
    OPEN mode, fileNumber, filename
    
    ' Check if error occurred
    IF ERR <> 0 THEN
        ' Error occurred - determine error message
        IF mode = "I" THEN
            fileOpenErrorMessage = "Failed to open file for reading: " + filename
        ELSEIF mode = "O" THEN
            fileOpenErrorMessage = "Failed to open file for writing: " + filename + " (disk full or permission denied?)"
        ELSE
            fileOpenErrorMessage = "Failed to open file for appending: " + filename
        END IF
        
        fileOpenErrorFlag = 1
        CALL HandleCriticalError(fileOpenErrorMessage)
        ON ERROR GOTO 0 ' Clear error handler
        SafeOpenFile% = 0
        EXIT FUNCTION
    END IF
    
    ' Clear error handler - file opened successfully
    ON ERROR GOTO 0
    SafeOpenFile% = 1
END FUNCTION

