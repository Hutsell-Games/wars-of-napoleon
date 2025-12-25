'============================================================================
' Mouse Support
'============================================================================
' Ported from WW2
' Full mouse control for modern interface

' Config is included in declarations.bas

' Note: mouseEnabled is declared in declarations.bas

SUB InitializeMouse
    ' Initialize mouse support
    mouseEnabled = 0 ' Default disabled
    ' Will be enabled based on config
END SUB

FUNCTION GetMouseX% ()
    ' Get mouse X coordinate
    ' Placeholder - will use QB64 mouse functions
    GetMouseX% = 0
END FUNCTION

FUNCTION GetMouseY% ()
    ' Get mouse Y coordinate
    ' Placeholder - will use QB64 mouse functions
    GetMouseY% = 0
END FUNCTION

FUNCTION GetMouseButton% ()
    ' Get mouse button state
    ' Returns: 0=none, 1=left, 2=right
    ' Placeholder - will use QB64 mouse functions
    GetMouseButton% = 0
END FUNCTION

FUNCTION IsMouseOverCity% (cityIndex AS INTEGER)
    ' Check if mouse is over city
    ' Used for click selection
    
    IF mouseEnabled = 0 THEN
        IsMouseOverCity% = 0
        EXIT FUNCTION
    END IF
    
    DIM mx AS INTEGER
    DIM my AS INTEGER
    DIM dx AS INTEGER
    DIM dy AS INTEGER
    
    mx = GetMouseX%
    my = GetMouseY%
    
    dx = ABS(mx - cities(cityIndex).x)
    dy = ABS(my - cities(cityIndex).y)
    
    ' Check if within city circle (radius ~10 pixels)
    IF dx * dx + dy * dy <= 100 THEN
        IsMouseOverCity% = 1
    ELSE
        IsMouseOverCity% = 0
    END IF
END FUNCTION

SUB HandleMouseClick
    ' Handle mouse click events
    ' Left click: Select/move
    ' Right click: Escape/cancel
    
    IF mouseEnabled = 0 THEN EXIT SUB
    
    DIM button AS INTEGER
    button = GetMouseButton%
    
    IF button = 1 THEN
        ' Left click - select city or menu item
        ' Placeholder - will implement selection logic
    ELSEIF button = 2 THEN
        ' Right click - Escape
        ' Simulate Escape key press
    END IF
END SUB

SUB EnableMouse
    ' Enable mouse support
    mouseEnabled = 1
    ' Save to config
    ' Will be added to config.bas
    COLOR 11: CALL clrbot: PRINT "Mouse support enabled"
END SUB

SUB DisableMouse
    ' Disable mouse support
    mouseEnabled = 0
    COLOR 11: CALL clrbot: PRINT "Mouse support disabled"
END SUB
