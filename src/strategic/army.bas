'============================================================================
' Army Management System
'============================================================================
' Ported from CWS - generic armies, combine any, RELIEVE command
' Handles army attributes, recruitment, movement, commanders

' Note: game_types.bas is included in main.bas
' Note: MAX_ARMIES, FRENCH_START, ALLIED_START are in declarations.bas

' Note: armies array is declared in declarations.bas
' Note: occupied is declared in declarations.bas
' Note: scenario.bas provides GetCommanderByName% function

'============================================================================
' MarkCommanderAvailable - Mark commander as available when army is destroyed
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army being destroyed
' Description:
'   When an army is destroyed or disbanded, marks its commander as available
'   for reassignment. Uses army name to find the commander.
' Side Effects:
'   Updates commanders array to mark commander as available
'============================================================================
SUB MarkCommanderAvailable (armyIndex AS INTEGER)
    ' Mark commander as available when army is destroyed/disbanded
    ' Uses army name to find the commander
    
    DIM commanderName AS STRING
    DIM commanderIndex AS INTEGER
    
    ' Validate army index
    IF ValidateArmyIndex%(armyIndex, "MarkCommanderAvailable") = 0 THEN
        EXIT SUB
    END IF
    
    ' Get commander name from army
    commanderName = armies(armyIndex).name
    
    ' Only proceed if army has a name (commander assigned)
    IF commanderName = "" THEN
        EXIT SUB
    END IF
    
    ' Find commander by name
    commanderIndex = GetCommanderByName%(commanderName)
    
    ' Mark commander as available if found
    IF commanderIndex > 0 AND commanderIndex <= 50 THEN
        commanders(commanderIndex).available = 1
    END IF
END SUB

'============================================================================
' InitializeArmies - Initialize all armies to empty state
'============================================================================
' Description:
'   Resets all army data structures to default empty values. Clears all
'   army attributes (name, size, leadership, experience, supply, location)
'   and resets the occupation array. Called at game start before loading
'   scenario data.
' Side Effects:
'   - Clears all armies array elements
'   - Resets occupied array to all zeros
'============================================================================
SUB InitializeArmies
    ' Initialize all armies to empty state
    DIM i AS INTEGER
    FOR i = 1 TO MAX_ARMIES
        armies(i).name = ""
        armies(i).size = 0
        armies(i).lead = 0
        armies(i).exper = 0
        armies(i).supply = 0
        armies(i).loc = 0
        armies(i).move = 0
        armies(i).nationality = 0
    NEXT i
    
    ' Clear occupation array
    FOR i = 1 TO 60
        occupied(i) = 0
    NEXT i
END SUB

'============================================================================
' RecruitArmy - Recruit new army in city
'============================================================================
' Parameters:
'   side (INTEGER) - Side recruiting army (1=French, 2=Allies)
'   cityIndex (INTEGER) - City where army is recruited
'   commanderName (STRING) - Name of commander assigned to army
'   commanderRating (INTEGER) - Leadership rating of commander (1-10)
' Description:
'   Creates a new army in the specified city with the given commander.
'   New armies start with default size, zero experience, and some initial
'   supply. They cannot move the turn they are created (move = -1).
'   The army's nationality is set based on the city's nationality.
' Side Effects:
'   - Creates new army in available slot
'   - Marks city as occupied by new army
'   - Displays error if maximum armies reached
'============================================================================
SUB RecruitArmy (side AS INTEGER, cityIndex AS INTEGER, commanderName AS STRING, commanderRating AS INTEGER)
    ' Recruit new army in city
    ' Cost: 100 money units
    ' New armies cannot move the turn they're created
    
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    
    ' Find available army slot
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    FOR i = startIndex TO endIndex
        IF armies(i).size = 0 THEN
            ' Found empty slot
            armies(i).name = commanderName
            armies(i).lead = commanderRating
            armies(i).exper = 0
            armies(i).supply = 5 ' Start with some supply
            armies(i).loc = cityIndex
            armies(i).move = -1 ' Cannot move this turn
            armies(i).nationality = GetCityNationality%(cityIndex)
            
            ' Set army size based on city value (will be set by scenario data)
            ' For now, use default
            armies(i).size = DEFAULT_ARMY_SIZE ' Default starting size
            
            ' Mark city as occupied
            occupied(cityIndex) = i
            
            EXIT SUB
        END IF
    NEXT i
    
    ' No available slot
    CALL ShowStatusError("Maximum armies reached for this side")
END SUB

'============================================================================
' MoveArmy - Set move order for army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to move
'   destinationCity (INTEGER) - City index to move army to
' Description:
'   Sets a movement order for an army. The actual movement is executed
'   during the Move & Combat phase. Armies cannot move if they were
'   just recruited this turn (move = -1).
' Side Effects:
'   - Sets armies(armyIndex).move to destinationCity
'   - Displays error if army cannot move
'============================================================================
SUB MoveArmy (armyIndex AS INTEGER, destinationCity AS INTEGER)
    ' Set move order for army
    ' Movement executed during Move & Combat phase
    
    IF armies(armyIndex).size = 0 THEN EXIT SUB
    IF armies(armyIndex).move = -1 THEN
        CALL ShowStatusError(armies(armyIndex).name + " cannot move this turn")
        EXIT SUB
    END IF
    
    armies(armyIndex).move = destinationCity
    CALL ShowStatusMessage(armies(armyIndex).name + " ordered to move to city " + LTRIM$(STR$(destinationCity)), 11)
END SUB

'============================================================================
' CombineArmies - Combine all friendly armies in a city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City where armies are located
' Description:
'   Combines all friendly armies in the specified city into a single army.
'   Unlike WW2, any armies can be combined regardless of type. The combined
'   army uses the best commander's name and leadership rating, while other
'   attributes (experience, supply) are averaged. Maximum combined size is
'   400,000 men. Other armies are destroyed and their commanders marked
'   as available.
' Side Effects:
'   - Combines armies into first army slot
'   - Destroys other armies in city
'   - Marks commanders of destroyed armies as available
'   - Displays error if less than 2 armies or size limit exceeded
'============================================================================
SUB CombineArmies (cityIndex AS INTEGER)
    ' Combine all friendly armies in city
    ' Can combine any armies (unlike WW2 which restricts by type)
    ' Maximum combined size: 400,000 men
    ' Attributes averaged, best commander takes leadership
    
    DIM i AS INTEGER
    DIM side AS INTEGER
    DIM armiesInCity(1 TO MAX_ARMIES) AS INTEGER
    DIM count AS INTEGER
    DIM totalSize AS LONG
    DIM totalLead AS INTEGER
    DIM totalExper AS INTEGER
    DIM totalSupply AS INTEGER
    DIM bestCommander AS INTEGER
    DIM bestRating AS INTEGER
    DIM combinedName AS STRING
    
    count = 0
    totalSize = 0
    totalLead = 0
    totalExper = 0
    totalSupply = 0
    bestRating = 0
    
    ' Find all armies in city
    FOR i = 1 TO MAX_ARMIES
        IF armies(i).loc = cityIndex AND armies(i).size > 0 THEN
            count = count + 1
            armiesInCity(count) = i
            
            ' Determine side
            side = GetArmySide%(i)
            IF side = 0 THEN side = 1 ' Fallback to French if invalid
            
            totalSize = totalSize + armies(i).size
            totalLead = totalLead + armies(i).lead
            totalExper = totalExper + armies(i).exper
            totalSupply = totalSupply + armies(i).supply
            
            ' Track best commander
            IF armies(i).lead > bestRating THEN
                bestRating = armies(i).lead
                bestCommander = i
                combinedName = armies(i).name
            END IF
        END IF
    NEXT i
    
    IF count < 2 THEN
        CALL ShowStatusError("Need at least 2 armies to combine")
        EXIT SUB
    END IF
    
    ' Check maximum size
    IF totalSize > 400000 THEN
        CALL ShowStatusError("Combined army would exceed 400,000 men")
        EXIT SUB
    END IF
    
    ' Create combined army in first slot
    armies(armiesInCity(1)).size = totalSize
    armies(armiesInCity(1)).lead = totalLead \ count ' Average leadership
    armies(armiesInCity(1)).exper = totalExper \ count ' Average experience
    armies(armiesInCity(1)).supply = totalSupply \ count ' Average supply
    armies(armiesInCity(1)).name = combinedName
    
    ' Clear other armies
    FOR i = 2 TO count
        ' Mark commander available before destroying army
        CALL MarkCommanderAvailable(armiesInCity(i))
        armies(armiesInCity(i)).size = 0
        armies(armiesInCity(i)).name = ""
        armies(armiesInCity(i)).loc = 0
        armies(armiesInCity(i)).move = 0
    NEXT i
    
    CALL ShowStatusMessage("Armies combined under " + combinedName, 11)
END SUB

'============================================================================
' RelieveCommander - Replace army commander (RELIEVE command)
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army
'   newCommanderName (STRING) - Name of new commander
'   newCommanderRating (INTEGER) - Leadership rating of new commander (1-10)
' Description:
'   Replaces the commander of an army with a new commander. This is the
'   RELIEVE command ported from CWS. Applies a -1 penalty to both
'   experience and leadership ratings to represent disruption from
'   command change. The new commander's rating replaces the leadership.
' Side Effects:
'   - Updates army commander name and leadership
'   - Reduces army experience and leadership by 1
'   - Displays status message
'============================================================================
SUB RelieveCommander (armyIndex AS INTEGER, newCommanderName AS STRING, newCommanderRating AS INTEGER)
    ' RELIEVE command - swap commanders
    ' Ported from CWS
    ' Applies -1 experience/leadership penalty
    
    IF armies(armyIndex).size = 0 THEN EXIT SUB
    
    ' Apply penalty
    IF armies(armyIndex).lead > 1 THEN
        armies(armyIndex).lead = armies(armyIndex).lead - 1
    END IF
    IF armies(armyIndex).exper > 0 THEN
        armies(armyIndex).exper = armies(armyIndex).exper - 1
    END IF
    
    ' Assign new commander
    armies(armyIndex).name = newCommanderName
    armies(armyIndex).lead = newCommanderRating
    
    CALL ShowStatusMessage(armies(armyIndex).name + " assumes command (penalty applied)", 11)
END SUB

'============================================================================
' GetArmyStrength - Calculate total army strength for a side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to calculate strength for (1=French, 2=Allies)
' Returns:
'   LONG - Total strength of all armies for the side
' Description:
'   Sums the size of all active armies for the specified side. Used for
'   victory condition calculations and strategic assessments.
'============================================================================
FUNCTION GetArmyStrength& (side AS INTEGER)
    ' Get total strength for side
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM total AS LONG
    
    total = 0
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
    END IF
    
    FOR i = startIndex TO endIndex
        total = total + armies(i).size
    NEXT i
    
    GetArmyStrength& = total
END FUNCTION

' GetCityNationality is implemented in city.bas

'============================================================================
' PlaceArmy - Place army in its current location
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to place
' Description:
'   Updates the occupation array to mark the city as occupied by the
'   specified army. Called after army movement or when initializing
'   army positions.
' Side Effects:
'   - Updates occupied(cityIndex) to armyIndex
'============================================================================
SUB PlaceArmy (armyIndex AS INTEGER)
    ' Place army in its current location
    ' Updates occupation array
    DIM cityLoc AS INTEGER
    
    cityLoc = armies(armyIndex).loc
    IF cityLoc > 0 THEN
        occupied(cityLoc) = armyIndex
    END IF
END SUB

'============================================================================
' OccupyCity - Determine which army occupies a city
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - City to check
' Description:
'   Finds the highest strength army in the city and marks it as the
'   occupying army. Used when multiple armies are in the same city
'   to determine which one controls the city.
' Side Effects:
'   - Updates occupied(cityIndex) to highest strength army index
'============================================================================
SUB OccupyCity (cityIndex AS INTEGER)
    ' Update occupation for city
    ' Finds highest strength army in city
    DIM i AS INTEGER
    DIM bestArmy AS INTEGER
    DIM bestSize AS LONG
    
    bestArmy = 0
    bestSize = 0
    
    FOR i = 1 TO MAX_ARMIES
        IF armies(i).loc = cityIndex AND armies(i).size > bestSize THEN
            bestSize = armies(i).size
            bestArmy = i
        END IF
    NEXT i
    
    occupied(cityIndex) = bestArmy
END SUB

