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
    ' Note: mtx$ is declared as mtx$(0 TO 20) in declarations.bas
    ' Clamp size to prevent array bounds overflow
    IF size > 20 THEN
        CALL HandleWarning("Menu size (" + LTRIM$(STR$(size)) + ") exceeds maximum (20), clamping to 20")
        size = 20
    END IF
    
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

FUNCTION ShowListMenu% (title AS STRING, items$, itemCount AS INTEGER)
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

'============================================================================
' Generic Menu Helper Functions
'============================================================================
' These functions reduce code duplication by providing common menu patterns
'============================================================================

'============================================================================
' SetupMenu - Configure menu with title and items
'============================================================================
' Parameters:
'   title (STRING) - Menu title (stored in mtx$(0))
'   items$ (STRING array) - Array of menu item strings
'   itemCount (INTEGER) - Number of items in array
'   menuX (INTEGER) - X position (optional, defaults to 67)
'   menuY (INTEGER) - Y position (optional, defaults to 13)
'   menuColor (INTEGER) - Menu border color (optional, defaults to 4)
'   menuHilite (INTEGER) - Highlight color (optional, defaults to 11)
' Description:
'   Sets up menu variables (mtx$, size, tlx, tly, colour, hilite) for use
'   with ShowMenu. This reduces duplication in menu setup code.
' Side Effects:
'   Modifies global menu variables: mtx$, size, tlx, tly, colour, hilite
'============================================================================
SUB SetupMenu (title AS STRING, items$, itemCount AS INTEGER, menuX AS INTEGER, menuY AS INTEGER, menuColor AS INTEGER, menuHilite AS INTEGER)
    DIM i AS INTEGER
    
    ' Set title
    mtx$(0) = title
    
    ' Set items
    IF itemCount > 20 THEN
        CALL HandleWarning("Menu item count (" + LTRIM$(STR$(itemCount)) + ") exceeds maximum (20), clamping to 20")
        itemCount = 20
    END IF
    
    size = itemCount
    FOR i = 1 TO itemCount
        mtx$(i) = items$(i)
    NEXT i
    
    ' Set position (use defaults if 0 passed)
    IF menuX > 0 THEN
        tlx = menuX
    ELSE
        tlx = 67 ' Default
    END IF
    
    IF menuY > 0 THEN
        tly = menuY
    ELSE
        tly = 13 ' Default
    END IF
    
    ' Set colors (use defaults if 0 passed)
    IF menuColor > 0 THEN
        colour = menuColor
    ELSE
        colour = 4 ' Default (red)
    END IF
    
    IF menuHilite > 0 THEN
        hilite = menuHilite
    ELSE
        hilite = 11 ' Default (cyan)
    END IF
END SUB

'============================================================================
' ShowSimpleMenu% - Display and get selection from simple menu
'============================================================================
' Parameters:
'   title (STRING) - Menu title
'   items$ (STRING array) - Array of menu item strings
'   itemCount (INTEGER) - Number of items in array
'   menuX (INTEGER) - X position (optional, 0 = default 67)
'   menuY (INTEGER) - Y position (optional, 0 = default 13)
'   menuColor (INTEGER) - Menu border color (optional, 0 = default 4)
'   menuHilite (INTEGER) - Highlight color (optional, 0 = default 11)
' Returns:
'   INTEGER - Selected item index (1-based), or 0 if cancelled
' Description:
'   Convenience function that sets up and displays a menu in one call.
'   Returns the selected item index (1-based) or 0 if user cancelled.
'============================================================================
FUNCTION ShowSimpleMenu% (title AS STRING, items$, itemCount AS INTEGER, menuX AS INTEGER, menuY AS INTEGER, menuColor AS INTEGER, menuHilite AS INTEGER)
    CALL SetupMenu(title, items$, itemCount, menuX, menuY, menuColor, menuHilite)
    CALL ShowMenu(0)
    ShowSimpleMenu% = choose
END FUNCTION

'============================================================================
' ShowMenuWithBack% - Display menu with "Back" option automatically added
'============================================================================
' Parameters:
'   title (STRING) - Menu title
'   items$ (STRING array) - Array of menu item strings (without "Back")
'   itemCount (INTEGER) - Number of items in array (without "Back")
'   menuX (INTEGER) - X position (optional, 0 = default 67)
'   menuY (INTEGER) - Y position (optional, 0 = default 13)
'   menuColor (INTEGER) - Menu border color (optional, 0 = default 4)
'   menuHilite (INTEGER) - Highlight color (optional, 0 = default 11)
' Returns:
'   INTEGER - Selected item index (1-based), or 0 if "Back" selected or cancelled
' Description:
'   Sets up menu with items plus a "Back" option at the end.
'   Returns selected item index (1-based) or 0 if "Back" was selected or cancelled.
'============================================================================
FUNCTION ShowMenuWithBack% (title AS STRING, items$, itemCount AS INTEGER, menuX AS INTEGER, menuY AS INTEGER, menuColor AS INTEGER, menuHilite AS INTEGER)
    DIM i AS INTEGER
    DIM menuItems$(1 TO 21) AS STRING ' Max 20 items + Back
    
    ' Copy items
    FOR i = 1 TO itemCount
        menuItems$(i) = items$(i)
    NEXT i
    
    ' Add "Back" option
    menuItems$(itemCount + 1) = "Back"
    
    CALL SetupMenu(title, menuItems$, itemCount + 1, menuX, menuY, menuColor, menuHilite)
    CALL ShowMenu(0)
    
    ' Return 0 if "Back" selected or cancelled, otherwise return selection
    IF choose = itemCount + 1 OR choose = 0 THEN
        ShowMenuWithBack% = 0
    ELSE
        ShowMenuWithBack% = choose
    END IF
END FUNCTION

'============================================================================
' List Building Helper Functions
'============================================================================
' These functions reduce duplication in menu code by providing common
' list building patterns for cities and armies
'============================================================================

'============================================================================
' BuildCityList% - Build a filtered list of cities
'============================================================================
' Parameters:
'   cityIndices() (INTEGER array) - Output array of city indices (1-based)
'   cityNames$ (STRING array) - Output array of city names
'   side (INTEGER) - Side to filter by (0 = any side, 1 = French, 2 = Allied)
'   requirePort (INTEGER) - 1 = only port cities, 0 = any city
'   requireOwned (INTEGER) - 1 = only owned by side, 0 = any ownership
'   requireActive (INTEGER) - 1 = only active cities, 0 = any city
'   nameFormatter$ (STRING) - Optional format string for names (use "%s" for city name)
'   additionalFilter% (INTEGER) - Optional function pointer for additional filtering
' Returns:
'   INTEGER - Number of cities in the list
' Description:
'   Builds a filtered list of cities matching the specified criteria.
'   The cityIndices and cityNames arrays are populated with matching cities.
'   Returns the count of cities found.
' Side Effects:
'   Modifies cityIndices() and cityNames$ arrays
'============================================================================
FUNCTION BuildCityList% (cityIndices() AS INTEGER, cityNames() AS STRING, side AS INTEGER, requirePort AS INTEGER, requireOwned AS INTEGER, requireActive AS INTEGER, nameFormatter$ AS STRING)
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM cityName AS STRING
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        ' Check active requirement
        IF requireActive = 1 THEN
            IF IsCityActive%(i) = 0 THEN
                GOTO SkipCity
            END IF
        END IF
        
        ' Check ownership requirement
        IF requireOwned = 1 AND side > 0 THEN
            IF IsCityOwnedBy%(i, side) = 0 THEN
                GOTO SkipCity
            END IF
        END IF
        
        ' Check port requirement
        IF requirePort = 1 THEN
            IF IsPortCity%(i) = 0 THEN
                GOTO SkipCity
            END IF
        END IF
        
        ' City passed all filters
        count = count + 1
        cityIndices(count) = i
        
        ' Format city name
        IF LEN(nameFormatter$) > 0 THEN
            ' Simple string replacement for %s placeholder
            cityName = nameFormatter$
            IF INSTR(cityName, "%s") > 0 THEN
                cityName = LEFT$(cityName, INSTR(cityName, "%s") - 1) + cities(i).name + MID$(cityName, INSTR(cityName, "%s") + 2)
            END IF
            cityNames(count) = cityName
        ELSE
            cityNames(count) = cities(i).name
        END IF
        
        SkipCity:
    NEXT i
    
    BuildCityList% = count
END FUNCTION

'============================================================================
' BuildArmyList% - Build a filtered list of armies
'============================================================================
' Parameters:
'   armyIndices() (INTEGER array) - Output array of army indices (1-based)
'   armyNames$ (STRING array) - Output array of army names
'   side (INTEGER) - Side to filter by (1 = French, 2 = Allied)
'   requireActive (INTEGER) - 1 = only active armies, 0 = any army
'   requireCanMove (INTEGER) - 1 = only armies that can move, 0 = any army
'   nameFormatter$ (STRING) - Optional format string for names (use "%s" for army name, "%l" for location)
' Returns:
'   INTEGER - Number of armies in the list
' Description:
'   Builds a filtered list of armies matching the specified criteria.
'   The armyIndices and armyNames arrays are populated with matching armies.
'   Returns the count of armies found.
' Side Effects:
'   Modifies armyIndices() and armyNames$ arrays
'============================================================================
FUNCTION BuildArmyList% (armyIndices() AS INTEGER, armyNames() AS STRING, side AS INTEGER, requireActive AS INTEGER, requireCanMove AS INTEGER, nameFormatter$ AS STRING)
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armyName AS STRING
    DIM locationName AS STRING
    
    ' Determine army range for side
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    count = 0
    FOR i = startIndex TO endIndex
        ' Check active requirement
        IF requireActive = 1 THEN
            IF IsArmyActive%(i) = 0 THEN
                GOTO SkipArmy
            END IF
        END IF
        
        ' Check can move requirement
        IF requireCanMove = 1 THEN
            IF armies(i).move = -1 THEN
                GOTO SkipArmy
            END IF
        END IF
        
        ' Army passed all filters
        count = count + 1
        armyIndices(count) = i
        
        ' Get location name
        IF armies(i).loc > 0 THEN
            IF ValidateCityIndex%(armies(i).loc, "BuildArmyList") = 1 THEN
                locationName = cities(armies(i).loc).name
            ELSE
                locationName = "Unknown"
            END IF
        ELSE
            locationName = "Unknown"
        END IF
        
        ' Format army name
        IF LEN(nameFormatter$) > 0 THEN
            armyName = nameFormatter$
            ' Replace %s with army name
            IF INSTR(armyName, "%s") > 0 THEN
                armyName = LEFT$(armyName, INSTR(armyName, "%s") - 1) + armies(i).name + MID$(armyName, INSTR(armyName, "%s") + 2)
            END IF
            ' Replace %l with location name
            IF INSTR(armyName, "%l") > 0 THEN
                armyName = LEFT$(armyName, INSTR(armyName, "%l") - 1) + locationName + MID$(armyName, INSTR(armyName, "%l") + 2)
            END IF
            armyNames(count) = armyName
        ELSE
            armyNames(count) = armies(i).name + " (" + locationName + ")"
        END IF
        
        SkipArmy:
    NEXT i
    
    BuildArmyList% = count
END FUNCTION

'============================================================================
' ShowCitySelectionMenu% - Build city list and show selection menu
'============================================================================
' Parameters:
'   title (STRING) - Menu title
'   cityIndices() (INTEGER array) - Output array of selected city indices
'   side (INTEGER) - Side to filter by (0 = any side, 1 = French, 2 = Allied)
'   requirePort (INTEGER) - 1 = only port cities, 0 = any city
'   requireOwned (INTEGER) - 1 = only owned by side, 0 = any ownership
'   requireActive (INTEGER) - 1 = only active cities, 0 = any city
'   nameFormatter$ (STRING) - Optional format string for names
'   emptyMessage$ (STRING) - Message to show if no cities found
' Returns:
'   INTEGER - Selected city index (1-based in cityIndices array), or 0 if cancelled
' Description:
'   Convenience function that builds a filtered city list and displays
'   a selection menu. Returns the selected city index (1-based in the
'   cityIndices array) or 0 if cancelled or no cities found.
' Side Effects:
'   Modifies cityIndices() array
'============================================================================
FUNCTION ShowCitySelectionMenu% (title AS STRING, cityIndices() AS INTEGER, side AS INTEGER, requirePort AS INTEGER, requireOwned AS INTEGER, requireActive AS INTEGER, nameFormatter$ AS STRING, emptyMessage$ AS STRING)
    DIM count AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES) AS STRING
    DIM selected AS INTEGER
    
    ' Build city list
    count = BuildCityList%(cityIndices(), cityNames$, side, requirePort, requireOwned, requireActive, nameFormatter$)
    
    ' Check if any cities found
    IF count = 0 THEN
        IF LEN(emptyMessage$) > 0 THEN
            CALL ShowInfo(emptyMessage$)
        END IF
        ShowCitySelectionMenu% = 0
        EXIT FUNCTION
    END IF
    
    ' Show menu
    selected = ShowListMenu%(title, cityNames$, count)
    
    ' Return selected index (0 if cancelled)
    ShowCitySelectionMenu% = selected
END FUNCTION

'============================================================================
' ShowArmySelectionMenu% - Build army list and show selection menu
'============================================================================
' Parameters:
'   title (STRING) - Menu title
'   armyIndices() (INTEGER array) - Output array of selected army indices
'   side (INTEGER) - Side to filter by (1 = French, 2 = Allied)
'   requireActive (INTEGER) - 1 = only active armies, 0 = any army
'   requireCanMove (INTEGER) - 1 = only armies that can move, 0 = any army
'   nameFormatter$ (STRING) - Optional format string for names
'   emptyMessage$ (STRING) - Message to show if no armies found
' Returns:
'   INTEGER - Selected army index (1-based in armyIndices array), or 0 if cancelled
' Description:
'   Convenience function that builds a filtered army list and displays
'   a selection menu. Returns the selected army index (1-based in the
'   armyIndices array) or 0 if cancelled or no armies found.
' Side Effects:
'   Modifies armyIndices() array
'============================================================================
FUNCTION ShowArmySelectionMenu% (title AS STRING, armyIndices() AS INTEGER, side AS INTEGER, requireActive AS INTEGER, requireCanMove AS INTEGER, nameFormatter$ AS STRING, emptyMessage$ AS STRING)
    DIM count AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES) AS STRING
    DIM selected AS INTEGER
    
    ' Build army list
    count = BuildArmyList%(armyIndices(), armyNames$, side, requireActive, requireCanMove, nameFormatter$)
    
    ' Check if any armies found
    IF count = 0 THEN
        IF LEN(emptyMessage$) > 0 THEN
            CALL ShowInfo(emptyMessage$)
        END IF
        ShowArmySelectionMenu% = 0
        EXIT FUNCTION
    END IF
    
    ' Show menu
    selected = ShowListMenu%(title, armyNames$, count)
    
    ' Return selected index (0 if cancelled)
    ShowArmySelectionMenu% = selected
END FUNCTION

