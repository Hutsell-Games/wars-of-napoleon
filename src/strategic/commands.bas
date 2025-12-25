'============================================================================
' Commands System
'============================================================================
' Commands available for individual armies
' Options: Cancel, Fortify, Join, Supply, Detach, Drill, Relieve

' Note: game_types.bas is included in main.bas
' Note: army.bas, city.bas, economy.bas are included in main.bas

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
    selected = ShowListMenu("Cancel Move Orders", armyNames$, count)
    
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
                IF occupied(i) >= FRENCH_START AND occupied(i) < ALLIED_START THEN
                    armySide = 1
                ELSE
                    armySide = 2
                END IF
                
                IF armySide = side THEN
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
    selected = ShowListMenu("Fortify City", cityNames$, count)
    
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
                    IF j >= FRENCH_START AND j < ALLIED_START THEN
                        armySide = 1
                    ELSE
                        armySide = 2
                    END IF
                    
                    IF armySide = side THEN
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
    selected = ShowListMenu("Join Armies", cityNames$, count)
    
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
    selected = ShowListMenu("Supply Army", armyNames$, count)
    
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
    selected = ShowListMenu("Relieve Commander", armyNames$, count)
    
    IF selected > 0 THEN
        ' Show available commanders (placeholder)
        DIM newCommanderName AS STRING
        DIM newCommanderRating AS INTEGER
        
        ' TODO: Show commander selection menu
        CALL ShowInfo("Select new commander (to be implemented)")
        
        ' For now, use placeholder
        newCommanderName = "New Commander"
        newCommanderRating = 5
        
        CALL RelieveCommander(armiesToRelieve(selected), newCommanderName, newCommanderRating)
    END IF
END SUB

