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
    IF ValidateArmySide%(side, "SelectCommander") = 0 THEN
        SelectCommander% = 0
        EXIT FUNCTION
    END IF
    
    ' Validate cityIndex if provided
    IF cityIndex > 0 THEN
        IF ValidateCityIndex%(cityIndex, "SelectCommander") = 0 THEN
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
        ' Validate commander index before accessing commanders array
        IF ValidateCommanderIndex%(i, "SelectCommander") = 0 THEN
            ' Skip invalid commander index
        ELSEIF commanders(i).available = 1 THEN
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

'============================================================================
' ShowCommandsMenu - Display commands menu for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to show commands for (1=French, 2=Allies)
' Description:
'   Displays the main commands menu with options for army management:
'   Cancel Move Orders, Fortify, Join (Combine), Supply, Detach, Drill,
'   and Relieve. Shows menu in a loop until user selects "Back to Main Menu".
'   Each command option calls the corresponding command function.
'============================================================================
SUB ShowCommandsMenu (side AS INTEGER)
    ' Show commands menu for side
    ' Options available for armies
    
    DIM choice AS INTEGER
    
    DIM menuItems$(1 TO 8) AS STRING
    
    DO
        menuItems$(1) = "Cancel Move Orders"
        menuItems$(2) = "Fortify"
        menuItems$(3) = "Join (Combine)"
        menuItems$(4) = "Supply"
        menuItems$(5) = "Detach"
        menuItems$(6) = "Drill"
        menuItems$(7) = "Relieve"
        menuItems$(8) = "Back to Main Menu"
        
        choice = ShowSimpleMenu%("Commands", menuItems$, 8, 67, 13, 4, 11)
        
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

'============================================================================
' CancelMoveOrders - Cancel move orders for selected army
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of armies that have pending move orders and allows the
'   player to cancel those orders. Only displays armies with move > 0.
'   Cancels the move order by setting armies(armyIndex).move = 0.
' Side Effects:
'   - Sets armies(armyIndex).move = 0 for selected army
'   - Displays message if no armies have move orders
'============================================================================
SUB CancelMoveOrders (side AS INTEGER)
    ' Cancel move orders for selected army
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM armiesWithOrders(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempArmies(1 TO MAX_ARMIES) AS INTEGER
    DIM tempNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of active armies for side
    tempCount = BuildArmyList%(tempArmies(), tempNames$, side, 1, 0, "")
    
    ' Filter for armies with move orders
    count = 0
    FOR i = 1 TO tempCount
        IF armies(tempArmies(i)).move > 0 THEN
            count = count + 1
            armiesWithOrders(count) = tempArmies(i)
            armyNames$(count) = armies(tempArmies(i)).name
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

'============================================================================
' FortifyCityCommand - Fortify city command
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose cities to show (1=French, 2=Allies)
' Description:
'   Shows a menu of cities that can be fortified. Only displays cities
'   owned by the specified side that have friendly armies present and
'   fortification level < FORT_PLUS_PLUS (maximum). Calls FortifyCity
'   to perform the fortification (costs 200 money units per level).
' Side Effects:
'   - Calls FortifyCity to increase city fortification
'   - Displays message if no cities eligible to fortify
'============================================================================
SUB FortifyCityCommand (side AS INTEGER)
    
    DIM i AS INTEGER
    DIM citiesToFortify(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    DIM count AS INTEGER
    
    ' Build base list of owned active cities
    tempCount = BuildCityList%(tempCities(), tempNames$, side, 0, 1, 1, "")
    
    ' Filter for cities that can be fortified (fort < FORT_PLUS_PLUS and have friendly army)
    count = 0
    FOR i = 1 TO tempCount
        IF cities(tempCities(i)).fort < FORT_PLUS_PLUS THEN
            ' Check if friendly army in city
            IF occupied(tempCities(i)) > 0 THEN
                DIM armySide AS INTEGER
                armySide = GetArmySide%(occupied(tempCities(i)))
                
                IF armySide = side AND armySide > 0 THEN
                    count = count + 1
                    citiesToFortify(count) = tempCities(i)
                    cityNames$(count) = cities(tempCities(i)).name
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

'============================================================================
' JoinArmiesCommand - Join (combine) armies command
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of cities that contain multiple friendly armies and allows
'   the player to combine them. Only displays cities with 2 or more armies
'   of the specified side. Calls CombineArmies to perform the combination.
' Side Effects:
'   - Calls CombineArmies to combine armies in selected city
'   - Displays message if no cities have multiple armies
'============================================================================
SUB JoinArmiesCommand (side AS INTEGER)
    ' Join (combine) armies command
    ' Shows cities with multiple armies
    
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM citiesWithMultiple(1 TO MAX_CITIES) AS INTEGER
    DIM cityNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCities(1 TO MAX_CITIES) AS INTEGER
    DIM tempNames$(1 TO MAX_CITIES) AS STRING
    DIM tempCount AS INTEGER
    DIM count AS INTEGER
    
    ' Build base list of all active cities
    tempCount = BuildCityList%(tempCities(), tempNames$, 0, 0, 0, 1, "")
    
    ' Filter for cities with multiple friendly armies
    count = 0
    FOR i = 1 TO tempCount
        DIM armyCount AS INTEGER
        
        ' Use location index for faster lookup
        DIM armiesAtCity(1 TO MAX_ARMIES) AS INTEGER
        DIM armyCountAtCity AS INTEGER
        armyCountAtCity = GetArmiesAtLocation%(tempCities(i), armiesAtCity())
        
        armyCount = 0
        FOR j = 1 TO armyCountAtCity
            IF IsArmyActive%(armiesAtCity(j)) = 1 THEN
                DIM armySide AS INTEGER
                armySide = GetArmySide%(armiesAtCity(j))
                
                IF armySide = side AND armySide > 0 THEN
                    armyCount = armyCount + 1
                END IF
            END IF
        NEXT j
        
        IF armyCount >= 2 THEN
            count = count + 1
            citiesWithMultiple(count) = tempCities(i)
            cityNames$(count) = cities(tempCities(i)).name + " (" + LTRIM$(STR$(armyCount)) + " armies)"
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

'============================================================================
' SupplyArmyCommand - Manual supply command
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of armies that can be manually supplied (supply < 10).
'   Allows the player to select an army and manually supply it. Manual
'   supply costs less than automatic supply. Calls ManualSupply to perform
'   the supply operation.
' Side Effects:
'   - Calls ManualSupply to supply selected army
'   - Displays message if all armies are fully supplied
'============================================================================
SUB SupplyArmyCommand (side AS INTEGER)
    ' Manual supply command
    ' Shows armies that can be supplied
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM armiesToSupply(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempArmies(1 TO MAX_ARMIES) AS INTEGER
    DIM tempNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of active armies for side
    tempCount = BuildArmyList%(tempArmies(), tempNames$, side, 1, 0, "")
    
    ' Filter for armies with low supply
    count = 0
    FOR i = 1 TO tempCount
        IF armies(tempArmies(i)).supply < 10 THEN
            count = count + 1
            armiesToSupply(count) = tempArmies(i)
            armyNames$(count) = armies(tempArmies(i)).name + " (Supply: " + LTRIM$(STR$(armies(tempArmies(i)).supply)) + ")"
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

'============================================================================
' DetachArmyCommand - Detach command to split army
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of armies that can be detached (split). Only displays
'   armies with at least 6,500 men. Splits the selected army, creating a
'   new army with 30% of the original size. The detached army cannot move
'   the turn it's created. Requires an available army slot.
' Side Effects:
'   - Creates new army with 30% of original size
'   - Reduces original army size by 30%
'   - Sets detached army move = -1 (cannot move this turn)
'   - Displays error if insufficient size or no available slot
'============================================================================
SUB DetachArmyCommand (side AS INTEGER)
    ' Detach command - split army
    ' Splits army into two armies (30% split)
    ' Requires minimum 6,500 men
    
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM count AS INTEGER
    DIM armiesToDetach(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempArmies(1 TO MAX_ARMIES) AS INTEGER
    DIM tempNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Determine army range for side (needed later for finding available slot)
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    ' Build base list of active armies for side
    tempCount = BuildArmyList%(tempArmies(), tempNames$, side, 1, 0, "")
    
    ' Filter for armies with at least 6,500 men (minimum for detach)
    count = 0
    FOR i = 1 TO tempCount
        IF armies(tempArmies(i)).size >= 6500 THEN
            count = count + 1
            armiesToDetach(count) = tempArmies(i)
            armyNames$(count) = armies(tempArmies(i)).name + " (" + LTRIM$(STR$(armies(tempArmies(i)).size)) + " men)"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No armies with 6,500+ men available to detach")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Detach Army", armyNames$, count)
    
    IF selected > 0 THEN
        DIM armyIndex AS INTEGER
        DIM detachedSize AS LONG
        DIM newArmyIndex AS INTEGER
        DIM cityIndex AS INTEGER
        
        armyIndex = armiesToDetach(selected)
        
        ' Calculate 30% of army size
        detachedSize = armies(armyIndex).size * 0.3
        
        ' Check if remaining army would be too small
        IF armies(armyIndex).size - detachedSize < 1000 THEN
            CALL ShowError("Detaching would leave army too small (minimum 1,000 men)")
            EXIT SUB
        END IF
        
        ' Find available army slot for detached army
        cityIndex = armies(armyIndex).loc
        newArmyIndex = 0
        
        FOR j = startIndex TO endIndex
            IF armies(j).size = 0 THEN
                newArmyIndex = j
                EXIT FOR
            END IF
        NEXT j
        
        IF newArmyIndex = 0 THEN
            CALL ShowError("No available army slot for detached units")
            EXIT SUB
        END IF
        
        ' Create detached army
        armies(newArmyIndex).name = armies(armyIndex).name + " (Detached)"
        armies(newArmyIndex).size = detachedSize
        armies(newArmyIndex).lead = armies(armyIndex).lead
        armies(newArmyIndex).exper = armies(armyIndex).exper
        armies(newArmyIndex).supply = armies(armyIndex).supply
        armies(newArmyIndex).loc = cityIndex
        armies(newArmyIndex).move = -1 ' Cannot move this turn
        armies(newArmyIndex).nationality = armies(armyIndex).nationality
        
        ' Reduce original army size
        armies(armyIndex).size = armies(armyIndex).size - detachedSize
        ' Size changed - invalidate combat strength cache for both armies
        CALL InvalidateCombatStrengthCache(armyIndex)
        CALL InvalidateCombatStrengthCache(newArmyIndex)
        ' Location changed - invalidate location index
        CALL InvalidateArmyLocationIndex
        
        ' Update occupation if needed
        IF occupied(cityIndex) = armyIndex THEN
            ' Keep original army as occupier
            occupied(cityIndex) = armyIndex
        END IF
        
        CALL ShowInfo("Army detached: " + LTRIM$(STR$(detachedSize)) + " men")
    END IF
END SUB

'============================================================================
' DrillArmyCommand - Drill command to improve army experience
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of armies that can be drilled. Only displays armies with
'   experience < 5 and no pending move orders. Increases the selected
'   army's experience by 1 (maximum 5). Costs 50 money units. The army
'   cannot move the turn it's drilled (move = -1).
' Side Effects:
'   - Increases army experience by 1 (max 5)
'   - Sets army move = -1 (cannot move this turn)
'   - Deducts 50 money units from cash reserves
'   - Displays error if insufficient funds or no eligible armies
'============================================================================
SUB DrillArmyCommand (side AS INTEGER)
    ' Drill command - improve army experience
    ' Increases experience by 1 (max 5)
    ' Cost: 50 money units
    ' Army cannot move this turn
    
    DIM i AS INTEGER
    DIM count AS INTEGER
    DIM armiesToDrill(1 TO MAX_ARMIES) AS INTEGER
    DIM armyNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempArmies(1 TO MAX_ARMIES) AS INTEGER
    DIM tempNames$(1 TO MAX_ARMIES) AS STRING
    DIM tempCount AS INTEGER
    
    ' Build base list of active armies for side
    tempCount = BuildArmyList%(tempArmies(), tempNames$, side, 1, 0, "")
    
    ' Filter for armies that can drill (experience < 5, not already moving)
    count = 0
    FOR i = 1 TO tempCount
        IF armies(tempArmies(i)).exper < 5 AND armies(tempArmies(i)).move = 0 THEN
            count = count + 1
            armiesToDrill(count) = tempArmies(i)
            armyNames$(count) = armies(tempArmies(i)).name + " (Exp: " + LTRIM$(STR$(armies(tempArmies(i)).exper)) + "/5)"
        END IF
    NEXT i
    
    IF count = 0 THEN
        CALL ShowInfo("No armies available to drill (must have experience < 5 and no move orders)")
        EXIT SUB
    END IF
    
    DIM selected AS INTEGER
    selected = ShowListMenu%("Drill Army", armyNames$, count)
    
    IF selected > 0 THEN
        DIM armyIndex AS INTEGER
        DIM cost AS INTEGER
        
        armyIndex = armiesToDrill(selected)
        cost = 50
        
        ' Check if have enough money
        IF GetGameStateCash&(side) < cost THEN
            CALL ShowError("Insufficient funds (need " + LTRIM$(STR$(cost)) + ")")
            EXIT SUB
        END IF
        
        ' Increase experience (max 5)
        IF armies(armyIndex).exper < 5 THEN
            armies(armyIndex).exper = armies(armyIndex).exper + 1
        END IF
        
        ' Prevent movement this turn
        armies(armyIndex).move = -1
        
        ' Deduct cost
        CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
        
        CALL ShowInfo(armies(armyIndex).name + " drilled. Experience: " + LTRIM$(STR$(armies(armyIndex).exper)))
    END IF
END SUB

'============================================================================
' RelieveCommanderCommand - Relieve command to swap commanders
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose armies to show (1=French, 2=Allies)
' Description:
'   Shows a menu of armies that can have their commanders relieved (replaced).
'   Allows the player to select an army and choose a new commander from
'   available commanders. Filters commanders by city nationality for cohesion
'   (to avoid cohesion penalties). Marks the old commander as available and
'   the new commander as unavailable. Calls RelieveCommander to perform the swap.
' Side Effects:
'   - Marks old commander as available
'   - Marks new commander as unavailable
'   - Calls RelieveCommander to swap commanders (applies -1 penalty)
'   - Displays message if no armies available
'============================================================================
SUB RelieveCommanderCommand (side AS INTEGER)
    ' Relieve command - swap commanders
    ' Shows armies that can have commanders relieved
    
    DIM armiesToRelieve(1 TO MAX_ARMIES) AS INTEGER
    DIM selected AS INTEGER
    
    ' Build list of active armies and show menu
    selected = ShowArmySelectionMenu%("Relieve Commander", armiesToRelieve(), side, 1, 0, "", "No armies available")
    
    IF selected > 0 THEN
        ' Get the army that needs a new commander
        DIM armyIndex AS INTEGER
        armyIndex = armiesToRelieve(selected)
        
        ' Get current army's city for nationality filtering
        DIM cityIndex AS INTEGER
        cityIndex = armies(armyIndex).loc
        
        ' Get side for commander selection (use armySide to avoid shadowing parameter)
        DIM armySide AS INTEGER
        armySide = GetArmySide%(armyIndex)
        
        ' Show commander selection menu (filter by city nationality for cohesion)
        DIM newCommanderIndex AS INTEGER
        DIM newCommanderName AS STRING
        DIM newCommanderRating AS INTEGER
        
        newCommanderIndex = SelectCommander%(armySide, cityIndex)
        
        IF newCommanderIndex = 0 THEN
            ' User cancelled commander selection
            EXIT SUB
        END IF
        
        ' Validate commander index before accessing commanders array
        IF ValidateCommanderIndex%(newCommanderIndex, "RelieveCommanderMenu") = 0 THEN
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

