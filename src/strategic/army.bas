'============================================================================
' Army Management System
'============================================================================
' Ported from CWS - generic armies, combine any, RELIEVE command
' Handles army attributes, recruitment, movement, commanders

' Note: game_types.bas is included in main.bas
' Note: MAX_ARMIES, FRENCH_START, ALLIED_START are in declarations.bas

' Note: armies array is declared in declarations.bas
' Note: occupied is declared in declarations.bas

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
            armies(i).nationality = GetCityNationality(cityIndex)
            
            ' Set army size based on city value (will be set by scenario data)
            ' For now, use default
            armies(i).size = 10000 ' Default starting size
            
            ' Mark city as occupied
            occupied(cityIndex) = i
            
            EXIT SUB
        END IF
    NEXT i
    
    ' No available slot
    COLOR 11: CALL clrbot: PRINT "Maximum armies reached for this side"
END SUB

SUB MoveArmy (armyIndex AS INTEGER, destinationCity AS INTEGER)
    ' Set move order for army
    ' Movement executed during Move & Combat phase
    
    IF armies(armyIndex).size = 0 THEN EXIT SUB
    IF armies(armyIndex).move = -1 THEN
        COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " cannot move this turn"
        EXIT SUB
    END IF
    
    armies(armyIndex).move = destinationCity
    COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " ordered to move to city"; destinationCity
END SUB

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
            IF i >= FRENCH_START AND i < ALLIED_START THEN
                side = 1
            ELSE
                side = 2
            END IF
            
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
        COLOR 11: CALL clrbot: PRINT "Need at least 2 armies to combine"
        EXIT SUB
    END IF
    
    ' Check maximum size
    IF totalSize > 400000 THEN
        COLOR 11: CALL clrbot: PRINT "Combined army would exceed 400,000 men"
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
        armies(armiesInCity(i)).size = 0
        armies(armiesInCity(i)).name = ""
        armies(armiesInCity(i)).loc = 0
        armies(armiesInCity(i)).move = 0
    NEXT i
    
    COLOR 11: CALL clrbot: PRINT "Armies combined under"; combinedName
END SUB

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
    
    COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " assumes command (penalty applied)"
END SUB

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

SUB PlaceArmy (armyIndex AS INTEGER)
    ' Place army in its current location
    ' Updates occupation array
    DIM cityLoc AS INTEGER
    
    cityLoc = armies(armyIndex).loc
    IF cityLoc > 0 THEN
        occupied(cityLoc) = armyIndex
    END IF
END SUB

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

