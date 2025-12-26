'============================================================================
' Utility Functions
'============================================================================
' Common utility functions used throughout the game

DECLARE SUB TICK (duration AS SINGLE)
DECLARE SUB clrbot ()
DECLARE SUB clrrite ()
DECLARE SUB ShowStatusMessage (message AS STRING, color AS INTEGER)
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

'============================================================================
' TICK - Wait for specified duration
'============================================================================
' Parameters:
'   duration (SINGLE) - Duration to wait in seconds
' Description:
'   Waits for the specified duration, allowing keyboard input to interrupt
'   QB64 compatible delay function
' Side Effects:
'   May exit early if any key is pressed
'============================================================================
SUB TICK (duration AS SINGLE)
    DIM startTime AS SINGLE
    startTime = TIMER
    
    DO WHILE TIMER < startTime + duration
        ' Allow keyboard input during wait
        IF INKEY$ <> "" THEN EXIT DO
    LOOP
END SUB

SUB clrbot
    ' Clear bottom area of screen
    ' Used for messages and status
    
    LINE (0, 400)-(640, 450), 0, BF
END SUB

SUB clrrite
    ' Clear right side of screen
    ' Used for menus
    
    LINE (500, 0)-(640, 480), 0, BF
END SUB

FUNCTION LEFTY$ (index AS INTEGER)
    ' Get left character of unit type string
    ' Returns unit type character (I, S, C, A, G)
    ' Placeholder - will get from unit data structure
    
    LEFTY$ = "I" ' Default to Infantry
    ' TODO: Implement actual unit type lookup
END FUNCTION

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
    ' Format number with commas
    ' Returns formatted string
    ' Placeholder - will implement formatting
    FormatNumber$ = LTRIM$(STR$(number))
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
        
        ' Open log file in append mode
        logFileNum = FREEFILE
        ON ERROR GOTO logError
        
        OPEN logFilename FOR APPEND AS #logFileNum
        logInitialized = 1
        
        ' Write header if file is new (check if file is empty)
        IF LOF(logFileNum) = 0 THEN
            PRINT #logFileNum, "=== Game Log Started ==="
            PRINT #logFileNum, "Date: "; DATE$; " Time: "; TIME$
            PRINT #logFileNum, ""
        END IF
        
        ON ERROR GOTO 0
    END IF
    
    ' Write log message with timestamp
    IF logFileNum > 0 THEN
        timestamp = DATE$ + " " + TIME$
        PRINT #logFileNum, "["; timestamp; "] "; message
        ' Flush to ensure message is written immediately
        ' Note: QB64 may buffer, but this ensures data is written
    END IF
    
    EXIT SUB
    
logError:
    ON ERROR GOTO 0
    ' If logging fails, silently continue (don't break game)
    ' Could optionally show warning, but logging should be non-critical
    logInitialized = 0
    IF logFileNum > 0 THEN
        CLOSE #logFileNum
        logFileNum = 0
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
    ' Placeholder - will implement debug system
    ' Commented out for now - will use debug flag when implemented
    ' PRINT "DEBUG: "; message
END SUB

'============================================================================
' FileExists - Check if file exists
'============================================================================
' Parameters:
'   filename (STRING) - Path to file to check
' Returns:
'   INTEGER - 1 if file exists, 0 if not
' Description:
'   Wrapper for QB64-PE builtin _FILEEXISTS function
'   Ref: https://wiki.qb64.dev/qb64wiki/index.php/FILEEXISTS
'============================================================================
FUNCTION FileExists% (filename AS STRING)
    IF _FILEEXISTS(filename) THEN
        FileExists% = 1
    ELSE
        FileExists% = 0
    END IF
END FUNCTION

FUNCTION GetFileSize& (filename AS STRING)
    ' Get file size in bytes
    ' Uses QB64 file operations to determine file size
    ' Returns file size in bytes, or -1 if file doesn't exist or error
    
    DIM fileNum AS INTEGER
    DIM fileSize AS LONG
    
    ' Check if file exists first
    IF FileExists%(filename) = 0 THEN
        GetFileSize& = -1 ' File doesn't exist
        EXIT FUNCTION
    END IF
    
    ' Open file in binary mode to get size
    fileNum = FREEFILE
    ON ERROR GOTO fileError
    
    OPEN filename FOR BINARY AS #fileNum
    fileSize = LOF(fileNum) ' Get length of file
    CLOSE #fileNum
    
    ON ERROR GOTO 0
    GetFileSize& = fileSize
    EXIT FUNCTION
    
fileError:
    ON ERROR GOTO 0
    IF fileNum > 0 THEN
        CLOSE #fileNum
    END IF
    GetFileSize& = -1 ' Error reading file
END FUNCTION

SUB CopyFile (sourceFile AS STRING, destFile AS STRING)
    ' Copy file
    ' Uses SHELL command for file copy
    DIM cmd AS STRING
    cmd = "copy " + sourceFile + " " + destFile
    SHELL cmd
END SUB

FUNCTION GetCurrentDate$ ()
    ' Get current date as string
    GetCurrentDate$ = DATE$
END FUNCTION

FUNCTION GetCurrentTime$ ()
    ' Get current time as string
    GetCurrentTime$ = TIME$
END FUNCTION

SUB PlaySound (frequency AS INTEGER, duration AS SINGLE)
    ' Play sound
    ' QB64 compatible
    SOUND frequency, duration
END SUB

SUB PlayBeep
    ' Play beep sound
    BEEP
END SUB

SUB SetScreenMode (mode AS INTEGER)
    ' Set screen mode
    ' Mode: 9=EGA, 12=VGA, etc.
    SCREEN mode
END SUB

SUB ClearScreen
    ' Clear entire screen
    CLS
END SUB

FUNCTION GetKeyPress$ ()
    ' Get key press (non-blocking)
    ' Returns empty string if no key pressed
    GetKeyPress$ = INKEY$
END FUNCTION

FUNCTION WaitForKeyPress$
    ' Wait for key press (blocking)
    ' Returns key pressed
    DIM keyPress AS STRING
    DO
        keyPress = INKEY$
    LOOP WHILE keyPress = ""
    WaitForKeyPress$ = keyPress
END FUNCTION

SUB PauseGame
    ' Pause game (wait for keypress)
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

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
SUB ShowStatusMessage (message AS STRING, color AS INTEGER)
    COLOR color: CALL clrbot: PRINT message
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
    ' For input mode, check if file exists first
    IF mode = "I" THEN
        IF FileExists%(filename) = 0 THEN
            SafeOpenFile% = 0
            EXIT FUNCTION
        END IF
    END IF
    
    ' Open file
    ON ERROR GOTO fileError
    OPEN mode, fileNumber, filename
    ON ERROR GOTO 0
    SafeOpenFile% = 1
    EXIT FUNCTION
    
fileError:
    ON ERROR GOTO 0
    SafeOpenFile% = 0
END FUNCTION

