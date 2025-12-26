'============================================================================
' Graphics Rendering
'============================================================================
' Graphics rendering functions for strategic and tactical displays
' Ported from original game with QB64 compatibility

' Note: game_types.bas, city.bas, and army.bas are included in main.bas
' Note: utilities.bas provides FileExists% function

SUB InitializeGraphics
    ' Initialize graphics system
    ' Load graphics files, set up display
    ' Graphics files are in data/graphics/ directory
    
    ' Set graphics mode
    SCREEN 12 ' VGA 640x480
    
    ' Load graphics files
    ' Note: Graphics are loaded on-demand by iconload() in tactical battles
    ' For strategic map, we use simple drawing functions
    ' If specific graphics are needed, they can be loaded here
    
    ' Attempt to load main graphics file if it exists
    ' The graphic() array is used for storing loaded graphics data
    DIM graphicsPath AS STRING
    graphicsPath = "data/graphics/"
    
    ' Check if graphics directory exists
    ' Note: iconload() in napoleon_subs.bas handles tactical battle graphics
    ' Strategic graphics use simple drawing, so no file loading needed here
    
    ' For now, graphics are loaded on-demand:
    ' - Tactical battle graphics: Loaded by iconload() when battle starts
    ' - Strategic map graphics: Drawn using simple shapes (circles, lines, etc.)
    ' - If specific strategic graphics files are needed, add loading here
    
    CLS
END SUB

FUNCTION LoadGraphicsFile% (filename AS STRING, graphicsArray() AS INTEGER)
    ' Load a graphics file into the graphics array
    ' Returns: 1 on success, 0 on failure
    ' Uses QB64 BLOAD which works directly with arrays
    
    DIM fullPath AS STRING
    DIM fileExists AS INTEGER
    
    ' Construct full path
    IF INSTR(filename, "data/graphics/") = 0 THEN
        fullPath = "data/graphics/" + filename
    ELSE
        fullPath = filename
    END IF
    
    ' Check if file exists
    fileExists = FileExists%(fullPath)
    IF fileExists = 0 THEN
        LoadGraphicsFile% = 0 ' File doesn't exist
        EXIT FUNCTION
    END IF
    
    ' Load graphics file using QB64 BLOAD
    ' QB64 BLOAD works directly with arrays - no DEF SEG needed
    ON ERROR GOTO loadError
    
    BLOAD fullPath, graphicsArray(1)
    
    ON ERROR GOTO 0
    LoadGraphicsFile% = 1 ' Success
    EXIT FUNCTION
    
loadError:
    ON ERROR GOTO 0
    LoadGraphicsFile% = 0 ' Failed to load
END FUNCTION

SUB DrawStrategicMap
    ' Draw strategic map
    ' Shows cities, connections, armies, fleets
    
    CLS
    
    ' Draw cities
    DIM i AS INTEGER
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" THEN
            CALL DrawCity(i)
        END IF
    NEXT i
    
    ' Draw city connections
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" THEN
            CALL DrawCityConnections(i)
        END IF
    NEXT i
    
    ' Draw armies
    FOR i = 1 TO MAX_ARMIES
        IF armies(i).size > 0 THEN
            CALL DrawArmy(i)
        END IF
    NEXT i
    
    ' Draw fleets
    FOR i = 1 TO 2
        IF fleets(i).size > 0 THEN
            CALL DrawFleet(i)
        END IF
    NEXT i
END SUB

SUB DrawCity (cityIndex AS INTEGER)
    ' Draw city on strategic map
    ' Color based on ownership: French (blue), Allied (red), Neutral (gray), At Peace (green)
    
    DIM x AS INTEGER
    DIM y AS INTEGER
    DIM drawColor AS INTEGER
    
    x = cities(cityIndex).x
    y = cities(cityIndex).y
    
    ' Set color based on ownership
    SELECT CASE cities(cityIndex).owner
        CASE CITY_FRENCH
            drawColor = 9 ' Blue
        CASE CITY_ALLIED
            drawColor = 4 ' Red
        CASE CITY_NEUTRAL
            drawColor = 8 ' Gray
        CASE CITY_AT_PEACE
            drawColor = 10 ' Green
        CASE ELSE
            drawColor = 7 ' White
    END SELECT
    
    ' Draw city circle
    CIRCLE (x, y), 4, drawColor
    PAINT (x, y), drawColor, drawColor
    
    ' Draw fortification indicator
    IF cities(cityIndex).fort > FORT_NONE THEN
        IF cities(cityIndex).fort = FORT_PLUS THEN
            ' Hollow box
            LINE (x - 6, y - 6)-(x + 6, y + 6), drawColor, B
        ELSEIF cities(cityIndex).fort = FORT_PLUS_PLUS THEN
            ' Solid box
            LINE (x - 6, y - 6)-(x + 6, y + 6), drawColor, BF
        END IF
    END IF
    
    ' Draw objective indicator (yellow cross)
    IF cities(cityIndex).objective = 1 THEN
        COLOR 14 ' Yellow
        LINE (x - 3, y)-(x + 3, y)
        LINE (x, y - 3)-(x, y + 3)
    END IF
    
    ' Draw city name (if graphics level allows)
    IF config_display >= 2 THEN
        COLOR 15
        LOCATE (y \ 8) + 1, (x \ 8) + 1
        PRINT cities(cityIndex).name
    END IF
END SUB

SUB DrawCityConnections (cityIndex AS INTEGER)
    ' Draw connections between cities
    ' Shows movement paths
    
    IF config_display < 1 THEN EXIT SUB ' Graphics level 0 = no connections
    
    DIM i AS INTEGER
    DIM connectedCity AS INTEGER
    
    COLOR 7 ' Gray for connections
    
    FOR i = 1 TO 7
        connectedCity = cityMatrix(cityIndex, i)
        IF connectedCity > 0 THEN
            ' Draw line to connected city
            LINE (cities(cityIndex).x, cities(cityIndex).y)-_
                  (cities(connectedCity).x, cities(connectedCity).y), 7, , &HF0F0 ' Dotted line
        END IF
    NEXT i
END SUB

SUB DrawArmy (armyIndex AS INTEGER)
    ' Draw army on strategic map
    ' Shows army icon at city location
    
    IF armies(armyIndex).loc = 0 THEN EXIT SUB
    
    DIM x AS INTEGER
    DIM y AS INTEGER
    DIM side AS INTEGER
    
    x = cities(armies(armyIndex).loc).x
    y = cities(armies(armyIndex).loc).y
    
    ' Determine side
    IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START THEN
        side = 1
    ELSE
        side = 2
    END IF
    
    ' Draw army flag icon
    IF side = 1 THEN
        COLOR 9 ' Blue for French
    ELSE
        COLOR 4 ' Red for Allies
    END IF
    
    ' Draw flag (simplified)
    LINE (x + 5, y - 5)-(x + 5, y + 5) ' Flag pole
    LINE (x + 5, y - 5)-(x + 8, y - 2) ' Flag
    LINE (x + 5, y - 2)-(x + 8, y + 1)
    
    ' Show strength if graphics level allows
    IF config_display >= 3 THEN
        COLOR 15
        LOCATE (y \ 8) + 2, (x \ 8) + 1
        PRINT armies(armyIndex).size \ 100 ' Show in hundreds
    END IF
END SUB

SUB DrawFleet (side AS INTEGER)
    ' Draw fleet on strategic map
    ' Shows fleet icon at port location
    
    IF fleets(side).loc = 0 THEN EXIT SUB
    
    DIM x AS INTEGER
    DIM y AS INTEGER
    
    x = cities(fleets(side).loc).x
    y = cities(fleets(side).loc).y
    
    ' Draw ship icon
    COLOR 11 ' Cyan for ships
    CIRCLE (x - 5, y), 2, 11 ' Ship hull
    LINE (x - 5, y)-(x - 3, y - 3) ' Mast
    LINE (x - 3, y - 3)-(x - 1, y - 1) ' Sail
    
    ' Show fleet size
    COLOR 15
    LOCATE (y \ 8) + 3, (x \ 8) + 1
    PRINT fleets(side).size
END SUB

SUB DrawTacticalMap
    ' Draw tactical battle map
    ' 27x20 hex grid with terrain and units
    
    ' This will call the mainmap subroutine from NAPOLEON.BAS
    ' TODO: Implement mainmap SUB from NAPOLEON.BAS
    ' CALL mainmap
END SUB

SUB DrawUnitOnTacticalMap (unitIndex AS INTEGER)
    ' Draw unit on tactical map
    ' Shows unit type, strength, status
    
    ' TODO: Implement SHOWUNIT SUB from NAPOLEON.BAS
    ' CALL SHOWUNIT (unitIndex%)
END SUB

SUB DrawCombatGraphics (attackerIndex AS INTEGER, defenderIndex AS INTEGER)
    ' Draw combat graphics
    ' Visual feedback for combat resolution
    
    DIM ax AS INTEGER
    DIM ay AS INTEGER
    DIM dx AS INTEGER
    DIM dy AS INTEGER
    
    ax = unitx(attackerIndex)
    ay = unity(attackerIndex)
    dx = unitx(defenderIndex)
    dy = unity(defenderIndex)
    
    ' Draw combat animation
    COLOR 14 ' Yellow for combat
    FOR i = 1 TO 3
        CIRCLE (ax, ay), 5 + i, 14
        CIRCLE (dx, dy), 5 + i, 14
        CALL TICK(0.1)
        CIRCLE (ax, ay), 5 + i, 0
        CIRCLE (dx, dy), 5 + i, 0
    NEXT i
END SUB

SUB DrawStatusBar
    ' Draw status bar at bottom of screen
    ' Shows current turn, side, cash, etc.
    
    COLOR 7
    LINE (0, 450)-(640, 480), 0, BF ' Clear status bar
    
    COLOR 15
    LOCATE 29, 1
    PRINT "Turn:"; gameState.turn; "Month:"; GetCurrentMonth$
    
    LOCATE 29, 30
    IF gameState.side = 1 THEN
        PRINT "French"
    ELSE
        PRINT "Allies"
    END IF
    
    LOCATE 29, 40
    PRINT "Cash:"; GetGameStateCash&(gameState.side)
    
    LOCATE 29, 55
    PRINT "VP:"; GetGameStateVictory&(gameState.side)
END SUB

SUB ClearBottom
    ' Clear bottom area of screen
    ' Used for messages
    
    LINE (0, 400)-(640, 450), 0, BF
END SUB

SUB ClearRight
    ' Clear right side of screen
    ' Used for menus
    
    LINE (500, 0)-(640, 480), 0, BF
END SUB

SUB FlashCity (cityIndex AS INTEGER)
    ' Flash city to draw attention
    ' Used for important events
    
    DIM i AS INTEGER
    DIM x AS INTEGER
    DIM y AS INTEGER
    
    x = cities(cityIndex).x
    y = cities(cityIndex).y
    
    FOR i = 1 TO 3
        CIRCLE (x, y), 6, 14 ' Yellow flash
        CALL TICK(0.1)
        CIRCLE (x, y), 6, 0
        CALL TICK(0.1)
    NEXT i
    
    ' Redraw city
    CALL DrawCity(cityIndex)
END SUB

