'============================================================================
' Menu System
'============================================================================
' Menu display and selection system
' Ported from CWS/WW2 with enhancements

' Config is included in declarations.bas

' Note: mtx$, choose, tlx, tly, colour, hilite, size are declared in declarations.bas

SUB InitializeMenus
    ' Initialize menu system
    choose = 0
    tlx = 67 ' Default X position (center-right)
    tly = 13 ' Default Y position (center)
    colour = 4 ' Default color (red)
    hilite = 11 ' Default highlight (cyan)
    size = 0
END SUB

SUB ShowMenu (menuType AS INTEGER)
    ' Display menu and get user selection
    ' menuType: 0=standard, 1=centered, etc.
    
    DIM i AS INTEGER
    DIM keyPress AS STRING
    DIM selected AS INTEGER
    
    selected = 1 ' Default selection
    
    ' Display menu
    DO
        CLS
        CALL DrawMenu(selected)
        
        ' Get input
        keyPress = INKEY$
        
        SELECT CASE keyPress
            CASE CHR$(0) + "H" ' Up arrow
                selected = selected - 1
                IF selected < 1 THEN selected = size
            CASE CHR$(0) + "P" ' Down arrow
                selected = selected + 1
                IF selected > size THEN selected = 1
            CASE CHR$(13) ' Enter
                choose = selected
                EXIT DO
            CASE CHR$(27) ' Escape
                choose = 0
                EXIT DO
            CASE "1" TO "9"
                ' Number key selection
                DIM num AS INTEGER
                num = VAL(keyPress)
                IF num <= size THEN
                    choose = num
                    EXIT DO
                END IF
        END SELECT
        
        ' Handle mouse if enabled
        IF mouseEnabled = 1 THEN
            CALL HandleMenuMouse(selected)
        END IF
        
        CALL TICK(0.1)
    LOOP
    
    CLS
END SUB

SUB DrawMenu (selected AS INTEGER)
    ' Draw menu on screen
    
    DIM i AS INTEGER
    DIM x AS INTEGER
    DIM y AS INTEGER
    DIM width AS INTEGER
    DIM height AS INTEGER
    
    ' Calculate menu dimensions
    width = 0
    FOR i = 0 TO size
        IF LEN(mtx$(i)) > width THEN width = LEN(mtx$(i))
    NEXT i
    width = width + 4
    
    height = size + 2
    
    ' Calculate position
    x = tlx * 8 ' Convert to pixels
    y = tly * 8
    
    ' Draw menu box
    LINE (x - 4, y - 4)-(x + width * 8, y + height * 8), colour, B
    LINE (x - 3, y - 3)-(x + width * 8 - 1, y + height * 8 - 1), 7, B
    
    ' Draw menu title
    COLOR 15
    LOCATE tly, tlx
    PRINT mtx$(0)
    
    ' Draw menu items
    FOR i = 1 TO size
        IF i = selected THEN
            COLOR hilite
            ' Highlight selected item
            LINE (x - 2, y + i * 8 - 2)-(x + width * 8 - 2, y + i * 8 + 6), hilite, BF
        ELSE
            COLOR 7
        END IF
        
        LOCATE tly + i, tlx
        PRINT i; ". "; mtx$(i)
    NEXT i
    
    COLOR 7 ' Reset color
END SUB

SUB HandleMenuMouse (selected AS INTEGER)
    ' Handle mouse input for menu
    ' Click to select, right-click to cancel
    
    IF mouseEnabled = 0 THEN EXIT SUB
    
    DIM mx AS INTEGER
    DIM my AS INTEGER
    DIM button AS INTEGER
    
    mx = GetMouseX%
    my = GetMouseY%
    button = GetMouseButton%
    
    ' Calculate menu bounds
    DIM menuX AS INTEGER
    DIM menuY AS INTEGER
    DIM menuWidth AS INTEGER
    DIM menuHeight AS INTEGER
    
    menuX = tlx * 8
    menuY = tly * 8
    menuWidth = 200 ' Approximate
    menuHeight = (size + 1) * 8
    
    ' Check if mouse is over menu
    IF mx >= menuX AND mx <= menuX + menuWidth AND _
       my >= menuY AND my <= menuY + menuHeight THEN
        
        ' Calculate which item
        DIM item AS INTEGER
        item = ((my - menuY) \ 8)
        
        IF item >= 1 AND item <= size THEN
            selected = item
            
            IF button = 1 THEN ' Left click
                choose = selected
            ELSEIF button = 2 THEN ' Right click
                choose = 0 ' Cancel
            END IF
        END IF
    END IF
END SUB

FUNCTION ShowYesNoMenu% (prompt AS STRING)
    ' Show Yes/No menu
    ' Returns 1=Yes, 0=No
    
    mtx$(0) = prompt
    mtx$(1) = "No"
    mtx$(2) = "Yes"
    size = 2
    tlx = 62 - LEN(prompt) \ 2
    tly = 2
    colour = 4
    hilite = 11
    
    CALL ShowMenu(0)
    
    IF choose = 2 THEN
        ShowYesNoMenu% = 1
    ELSE
        ShowYesNoMenu% = 0
    END IF
END FUNCTION

SUB ShowMessage (message AS STRING, duration AS SINGLE)
    ' Show message on screen
    ' Duration in seconds (0 = until keypress)
    
    COLOR 11
    CALL clrbot
    PRINT message
    
    IF duration > 0 THEN
        CALL TICK(duration)
    ELSE
        PRINT "Press any key to continue..."
        DO WHILE INKEY$ = "": LOOP
    END IF
    
    CALL clrbot
END SUB

SUB ShowError (errorMessage AS STRING)
    ' Show error message
    ' Red color, beep
    
    BEEP
    COLOR 12 ' Red
    CALL clrbot
    PRINT "ERROR: "; errorMessage
    CALL TICK(2)
    CALL clrbot
    COLOR 7 ' Reset
END SUB

SUB ShowInfo (infoMessage AS STRING)
    ' Show info message
    ' Cyan color
    
    COLOR 11 ' Cyan
    CALL clrbot
    PRINT infoMessage
    CALL TICK(1)
    CALL clrbot
    COLOR 7 ' Reset
END SUB

SUB ShowWarning (warningMessage AS STRING)
    ' Show warning message
    ' Yellow color
    
    COLOR 14 ' Yellow
    CALL clrbot
    PRINT "WARNING: "; warningMessage
    CALL TICK(1.5)
    CALL clrbot
    COLOR 7 ' Reset
END SUB

FUNCTION ShowListMenu% (title AS STRING, items$(), itemCount AS INTEGER)
    ' Show list menu with custom items
    ' Returns selected index (0 = cancelled)
    
    mtx$(0) = title
    size = itemCount
    
    DIM i AS INTEGER
    FOR i = 1 TO itemCount
        mtx$(i) = items$(i)
    NEXT i
    
    CALL ShowMenu(0)
    
    ShowListMenu% = choose
END FUNCTION

SUB BubbleSortMenu (count AS INTEGER)
    ' Sort menu items alphabetically
    ' Used for file lists, etc.
    
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM temp AS STRING
    DIM swapped AS INTEGER
    
    FOR i = 1 TO count - 1
        swapped = 0
        FOR j = 1 TO count - i
            IF mtx$(j) > mtx$(j + 1) THEN
                temp = mtx$(j)
                mtx$(j) = mtx$(j + 1)
                mtx$(j + 1) = temp
                swapped = 1
            END IF
        NEXT j
        IF swapped = 0 THEN EXIT FOR
    NEXT i
END SUB

