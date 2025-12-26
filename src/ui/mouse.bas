'============================================================================
' Mouse Support
'============================================================================
' Ported from WW2
' Full mouse control for modern interface

' Config is included in declarations.bas

' Note: mouseEnabled is declared in declarations.bas

SUB InitializeMouse
    ' Initialize mouse support
    ' QB64 automatically initializes mouse when in graphics mode
    mouseEnabled = 0 ' Default disabled
    ' Will be enabled based on config
    ' Note: Mouse is available in SCREEN modes (SCREEN 12, etc.)
END SUB

FUNCTION GetMouseX% ()
    ' Get mouse X coordinate
    ' Uses QB64 _MOUSEX function
    ' Returns screen X coordinate (0 to screen width)
    
    IF mouseEnabled = 0 THEN
        GetMouseX% = 0
        EXIT FUNCTION
    END IF
    
    ' Check for mouse input before reading coordinates
    IF _MOUSEINPUT THEN
        GetMouseX% = _MOUSEX
    ELSE
        GetMouseX% = _MOUSEX ' Still return current position even if no new input
    END IF
END FUNCTION

FUNCTION GetMouseY% ()
    ' Get mouse Y coordinate
    ' Uses QB64 _MOUSEY function
    ' Returns screen Y coordinate (0 to screen height)
    
    IF mouseEnabled = 0 THEN
        GetMouseY% = 0
        EXIT FUNCTION
    END IF
    
    ' Check for mouse input before reading coordinates
    IF _MOUSEINPUT THEN
        GetMouseY% = _MOUSEY
    ELSE
        GetMouseY% = _MOUSEY ' Still return current position even if no new input
    END IF
END FUNCTION

FUNCTION GetMouseButton% ()
    ' Get mouse button state
    ' Uses QB64 _MOUSEBUTTON function
    ' Returns: 0=none, 1=left button down, 2=right button down, 3=middle button down
    ' Note: Returns button state only when button is currently pressed
    
    IF mouseEnabled = 0 THEN
        GetMouseButton% = 0
        EXIT FUNCTION
    END IF
    
    ' Check for mouse input
    IF _MOUSEINPUT THEN
        ' Check button states
        IF _MOUSEBUTTON(1) THEN
            GetMouseButton% = 1 ' Left button
        ELSEIF _MOUSEBUTTON(2) THEN
            GetMouseButton% = 2 ' Right button
        ELSEIF _MOUSEBUTTON(3) THEN
            GetMouseButton% = 3 ' Middle button
        ELSE
            GetMouseButton% = 0 ' No button
        END IF
    ELSE
        ' No new input, check current state
        IF _MOUSEBUTTON(1) THEN
            GetMouseButton% = 1
        ELSEIF _MOUSEBUTTON(2) THEN
            GetMouseButton% = 2
        ELSEIF _MOUSEBUTTON(3) THEN
            GetMouseButton% = 3
        ELSE
            GetMouseButton% = 0
        END IF
    END IF
END FUNCTION

FUNCTION GetMouseButtonClick% ()
    ' Get mouse button click (single press, not held)
    ' Returns: 0=none, 1=left click, 2=right click, 3=middle click
    ' This function detects button press events, not held states
    
    STATIC lastButton AS INTEGER
    STATIC buttonHeld AS INTEGER
    DIM currentButton AS INTEGER
    
    IF mouseEnabled = 0 THEN
        GetMouseButtonClick% = 0
        EXIT FUNCTION
    END IF
    
    ' Check for mouse input
    IF _MOUSEINPUT THEN
        currentButton = 0
        IF _MOUSEBUTTON(1) THEN currentButton = 1
        IF _MOUSEBUTTON(2) THEN currentButton = 2
        IF _MOUSEBUTTON(3) THEN currentButton = 3
        
        ' Detect button press (transition from not pressed to pressed)
        IF currentButton > 0 AND lastButton = 0 AND buttonHeld = 0 THEN
            buttonHeld = 1
            lastButton = currentButton
            GetMouseButtonClick% = currentButton
        ELSEIF currentButton = 0 THEN
            ' Button released
            buttonHeld = 0
            lastButton = 0
            GetMouseButtonClick% = 0
        ELSE
            ' Button still held
            GetMouseButtonClick% = 0
        END IF
    ELSE
        GetMouseButtonClick% = 0
    END IF
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
    ' Uses GetMouseButtonClick% to detect single clicks, not held buttons
    
    IF mouseEnabled = 0 THEN EXIT SUB
    
    DIM button AS INTEGER
    button = GetMouseButtonClick% ' Use click detection, not button state
    
    IF button = 1 THEN
        ' Left click - select city or menu item
        ' This will be handled by calling code based on mouse position
        ' For now, just process the click event
    ELSEIF button = 2 THEN
        ' Right click - Escape/cancel
        ' Simulate Escape key by setting a flag or calling cancel handler
        ' Note: Actual key simulation would require more complex handling
    END IF
END SUB

SUB ProcessMouseInput
    ' Process mouse input continuously
    ' Should be called in main game loop when mouse is enabled
    ' Checks for mouse events and processes them
    
    IF mouseEnabled = 0 THEN EXIT SUB
    
    ' Process mouse input events
    DO WHILE _MOUSEINPUT
        ' Mouse input is being processed
        ' Individual handlers will check button states as needed
    LOOP
END SUB

SUB EnableMouse
    ' Enable mouse support
    ' QB64 mouse is automatically available in graphics modes
    mouseEnabled = 1
    ' Save to config
    ' Will be added to config.bas
    CALL ShowStatusMessage("Mouse support enabled", 11)
END SUB

SUB DisableMouse
    ' Disable mouse support
    mouseEnabled = 0
    CALL ShowStatusMessage("Mouse support disabled", 11)
END SUB

FUNCTION IsMouseAvailable% ()
    ' Check if mouse is available
    ' QB64 mouse is available in graphics modes (SCREEN 12, etc.)
    ' Returns 1 if mouse is available, 0 if not
    
    ' In QB64, mouse is available when in a graphics screen mode
    ' We can check by attempting to read mouse position
    ' If we're in a graphics mode, mouse should be available
    IsMouseAvailable% = 1 ' QB64 mouse is generally available in graphics modes
END FUNCTION
