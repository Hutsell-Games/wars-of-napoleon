'============================================================================
' Utility Functions
'============================================================================
' Common utility functions used throughout the game

DECLARE SUB TICK (duration AS SINGLE)
DECLARE SUB clrbot ()
DECLARE SUB clrrite ()

SUB TICK (duration AS SINGLE)
    ' Wait for specified duration in seconds
    ' QB64 compatible delay function
    
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

FUNCTION GetRandomNumber% (min AS INTEGER, max AS INTEGER)
    ' Get random number between min and max (inclusive)
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

FUNCTION GetPercentage! (part AS LONG, total AS LONG)
    ' Calculate percentage
    IF total = 0 THEN
        GetPercentage! = 0
    ELSE
        GetPercentage! = (part / total) * 100
    END IF
END FUNCTION

FUNCTION GetRatio! (value1 AS LONG, value2 AS LONG)
    ' Calculate ratio
    IF value2 = 0 THEN
        GetRatio! = 0
    ELSE
        GetRatio! = value1 / value2
    END IF
END FUNCTION

SUB LogMessage (message AS STRING)
    ' Log message to file (if logging enabled)
    ' Placeholder - will implement logging
END SUB

SUB DebugPrint (message AS STRING)
    ' Debug print (only in debug mode)
    ' Placeholder - will implement debug system
    ' Commented out for now - will use debug flag when implemented
    ' PRINT "DEBUG: "; message
END SUB

FUNCTION FileExists% (filename AS STRING)
    ' Check if file exists.
    ' Use QB64-PE builtin _FILEEXISTS (returns -1 when it exists, 0 when it does not).
    ' Ref: https://wiki.qb64.dev/qb64wiki/index.php/FILEEXISTS
    IF _FILEEXISTS(filename) THEN
        FileExists% = 1
    ELSE
        FileExists% = 0
    END IF
END FUNCTION

FUNCTION GetFileSize& (filename AS STRING)
    ' Get file size in bytes
    ' Placeholder - will implement file size check
    GetFileSize& = 0
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
    ' Placeholder - will implement help system
    CLS
    COLOR 15: PRINT "HELP: "; topic
    PRINT STRING$(80, "-")
    PRINT "Help content for "; topic; " will be displayed here"
    PRINT
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

