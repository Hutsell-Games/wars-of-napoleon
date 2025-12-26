'============================================================================
' Commands System
'============================================================================
' Commands available for individual armies
' Options: Cancel, Fortify, Join, Supply, Detach, Drill, Relieve

' Note: game_types.bas is included in main.bas
' Note: army.bas, city.bas, economy.bas are included in main.bas

'============================================================================
' SelectCommander - Show commander selection menu
'============================================================================
' Parameters:
'   side (INTEGER) - Side selecting commander (1=French, 2=Allied)
'   cityIndex (INTEGER) - Optional city index for nationality filtering (0 = no filter)
' Returns:
'   INTEGER - Commander index (1-50) if selected, 0 if cancelled
' Description:
'   Shows a menu of available commanders for the specified side.
'   Filters by:
'   - Side (1-25 for French, 26-50 for Allied)
'   - Available flag (must be 1)
'   - Optionally by city nationality if cityIndex > 0 (for cohesion system)
'============================================================================
FUNCTION SelectCommander% (side AS INTEGER, cityIndex AS INTEGER)
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM availableCommanders(1 TO 50) AS INTEGER
    DIM commanderNames$(1 TO 50)
    DIM cityNationality AS INTEGER
    DIM selected AS INTEGER
    
    ' Validate side parameter
    IF side <> 1 AND side <> 2 THEN
        CALL ShowStatusError("Invalid side parameter")
        SelectCommander% = 0
        EXIT FUNCTION
    END IF
    
    ' Validate cityIndex if provided
    IF cityIndex > 0 THEN
        IF cityIndex < 1 OR cityIndex > MAX_CITIES THEN
            CALL ShowStatusError("Invalid city index")
            SelectCommander% = 0
            EXIT FUNCTION
        END IF
    END IF
    
    ' Determine commander range for this side
    IF side = 1 THEN
        ' French commanders: indices 1-25
        startIndex = 1
        endIndex = 25
    ELSE
        ' Allied commanders: indices 26-50
        startIndex = 26
        endIndex = 50
    END IF
    
    ' Get city nationality if filtering by city
    IF cityIndex > 0 THEN
        cityNationality = GetCityNationality%(cityIndex)
    ELSE
        cityNationality = 0 ' No nationality filter
    END IF
    
    ' Build list of available commanders
    count = 0
    FOR i = startIndex TO endIndex
        ' Check if commander is available
        IF commanders(i).available = 1 THEN
            ' If cityIndex provided, filter by nationality for cohesion
            IF cityIndex > 0 THEN
                ' Check if commander nationality matches city nationality
                IF commanders(i).nationality = cityNationality THEN
                    count = count + 1
                    availableCommanders(count) = i
                    ' Format: "Name (Rating X)"
                    commanderNames$(count) = commanders(i).name + " (Rating " + LTRIM$(STR$(commanders(i).rating)) + ")"
                END IF
            ELSE
                ' No nationality filter - show all available commanders
                count = count + 1
                availableCommanders(count) = i
                ' Format: "Name (Rating X)"
                commanderNames$(count) = commanders(i).name + " (Rating " + LTRIM$(STR$(commanders(i).rating)) + ")"
            END IF
        END IF
    NEXT i
    
    ' Check if any commanders available
    IF count = 0 THEN
        IF cityIndex > 0 THEN
            CALL ShowStatusWarning("No commanders available matching city nationality")
        ELSE
            CALL ShowStatusWarning("No commanders available for this side")
        END IF
        SelectCommander% = 0
        EXIT FUNCTION
    END IF
    
    ' Show commander selection menu
    selected = ShowListMenu%("Select Commander", commanderNames$, count)
    
    ' Return selected commander index or 0 if cancelled
    IF selected > 0 AND selected <= count THEN
        SelectCommander% = availableCommanders(selected)
    ELSE
        SelectCommander% = 0
    END IF
END FUNCTION

SUB ShowCommandsMenu (side AS INTEGER)
    ' Show commands menu for side
    ' Options available for armies
    
    DIM choice AS INTEGER
    
    DO
        mtx$(0) = "Commands"
        mtx$(1) = "Cancel Move Orders"
        mtx$(2) = "Fortify"
        mtx$(3) = "Join (Combine)"
        mtx$(4) = "Supply"
        mtx$(5) = "Detach"
        mtx$(6) = "Drill"
        mtx$(7) = "Relieve"
        mtx$(8) = "Back to Main Menu"
        size = 8
        tlx = 67
        tly = 13
        colour = 4
        hilite = 11
        
        CALL ShowMenu(0)
        choice = choose
        
        SELECT CASE choice
            CASE 1
                CALL CancelMoveOrders(side)
            CASE 2
                CALL FortifyCityCommand(side)
            CASE 3
                CALL JoinArmiesCommand(side)
            CASE 4
                CALL SupplyArmyCommand(side)
            CASE 5
                CALL DetachArmyCommand(side)
            CASE 6
                CALL DrillArmyCommand(side)
            CASE 7
                CALL RelieveCommanderCommand(side)
            CASE 8
                EXIT DO
        END SELECT
    LOOP
END SUB

SUB CancelMoveOrders (side AS INTEGER)
    ' Cancel move orders for selected army
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armiesWithOrders(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES)
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    count = 0
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 AND armies(i).move > 0 THEN
            count = count + 1
            armiesWithOrders(count) = i
            armyNames$(count) = armies(i).name
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No armies with move orders")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Cancel Move Orders", armyNames$, count)
    
    IF selected > 0 THEN
        armies(armiesWithOrders(selected)).move = 0
        CALL ShowInfo(armies(armiesWithOrders(selected)).name + " move orders cancelled")
    END IF
END SUB

SUB FortifyCityCommand (side AS INTEGER)
    ' Fortify city command
    ' Shows cities that can be fortified
    
    DIM i AS INTEGER
    DIM cityIndex AS INTEGER
    
    ' Find cities with friendly armies that can be fortified
    DIM citiesToFortify(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES)
    DIM count AS INTEGER
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" AND cities(i).owner = side AND cities(i).fort < FORT_PLUS_PLUS THEN
            ' Check if friendly army in city
            IF occupied(i) > 0 THEN
                DIM armySide AS INTEGER
                armySide = GetArmySide%(occupied(i))
                
                IF armySide = side AND armySide > 0 THEN
                    count = count + 1
                    citiesToFortify(count) = i
                    cityNames$(count) = cities(i).name
                END IF
            END IF
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No cities eligible to fortify")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Fortify City", cityNames$, count)
    
    IF selected > 0 THEN
        CALL FortifyCity(citiesToFortify(selected))
    END IF
END SUB

SUB JoinArmiesCommand (side AS INTEGER)
    ' Join (combine) armies command
    ' Shows cities with multiple armies
    
    DIM i AS INTEGER
    DIM cityIndex AS INTEGER
    
    ' Find cities with multiple friendly armies
    DIM citiesWithMultiple(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES)
    DIM count AS INTEGER
    
    count = 0
    FOR i = 1 TO MAX_CITIES
        IF cities(i).name <> "" THEN
            DIM armyCount AS INTEGER
            DIM j AS INTEGER
            
            armyCount = 0
            FOR j = 1 TO MAX_ARMIES
                IF armies(j).loc = i AND armies(j).size > 0 THEN
                    DIM armySide AS INTEGER
                    armySide = GetArmySide%(j)
                    
                    IF armySide = side AND armySide > 0 THEN
                        armyCount = armyCount + 1
                    END IF
                END IF
            NEXT j
            
            IF armyCount >= 2 THEN
                count = count + 1
                citiesWithMultiple(count) = i
                cityNames$(count) = cities(i).name + " (" + LTRIM$(STR$(armyCount)) + " armies)"
            END IF
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No cities with multiple armies to combine")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Join Armies", cityNames$, count)
    
    IF selected > 0 THEN
        CALL CombineArmies(citiesWithMultiple(selected))
    END IF
END SUB

SUB SupplyArmyCommand (side AS INTEGER)
    ' Manual supply command
    ' Shows armies that can be supplied
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armiesToSupply(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES)
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    count = 0
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 AND armies(i).supply < 10 THEN
            count = count + 1
            armiesToSupply(count) = i
            armyNames$(count) = armies(i).name + " (Supply: " + LTRIM$(STR$(armies(i).supply)) + ")"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("All armies fully supplied")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Supply Army", armyNames$, count)
    
    IF selected > 0 THEN
        CALL ManualSupply(armiesToSupply(selected))
    END IF
END SUB

SUB DetachArmyCommand (side AS INTEGER)
    ' Detach command - split army
    ' Placeholder - will implement army splitting
    
    CALL ShowInfo("Detach command - Split army (to be implemented)")
END SUB

SUB DrillArmyCommand (side AS INTEGER)
    ' Drill command - improve army experience
    ' Placeholder - will implement drilling
    
    CALL ShowInfo("Drill command - Improve experience (to be implemented)")
END SUB

SUB RelieveCommanderCommand (side AS INTEGER)
    ' Relieve command - swap commanders
    ' Shows armies that can have commanders relieved
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armiesToRelieve(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES)
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    count = 0
    FOR i = startIndex TO endIndex
        IF armies(i).size > 0 THEN
            count = count + 1
            armiesToRelieve(count) = i
            armyNames$(count) = armies(i).name + " (" + armies(i).name + ")"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No armies available")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Relieve Commander", armyNames$, count)
    
    IF selected > 0 THEN
        ' Get the army that needs a new commander
        DIM armyIndex AS INTEGER
        armyIndex = armiesToRelieve(selected)
        
        ' Get current army's city for nationality filtering
        DIM cityIndex AS INTEGER
        cityIndex = armies(armyIndex).loc
        
        ' Get side for commander selection
        DIM side AS INTEGER
        side = GetArmySide%(armyIndex)
        
        ' Show commander selection menu (filter by city nationality for cohesion)
        DIM newCommanderIndex AS INTEGER
        DIM newCommanderName AS STRING
        DIM newCommanderRating AS INTEGER
        
        newCommanderIndex = SelectCommander%(side, cityIndex)
        
        IF newCommanderIndex = 0 THEN
            ' User cancelled commander selection
            EXIT SUB
        END IF
        
        ' Get commander details
        newCommanderName = commanders(newCommanderIndex).name
        newCommanderRating = commanders(newCommanderIndex).rating
        
        ' Mark old commander as available before replacing
        ' Use MarkCommanderAvailable to handle finding and marking the old commander
        CALL MarkCommanderAvailable(armyIndex)
        
        ' Mark new commander as unavailable (assigned to army)
        commanders(newCommanderIndex).available = 0
        
        CALL RelieveCommander(armyIndex, newCommanderName, newCommanderRating)
    END IF
END SUB

