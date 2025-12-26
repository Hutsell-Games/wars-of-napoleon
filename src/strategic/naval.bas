'============================================================================
' Naval Operations System
'============================================================================
' Ported from WW2 - generic ships (no ironclads)
' Handles fleet management, combat, naval actions

' Note: game_types.bas is included in main.bas
' Note: Naval action constants are in declarations.bas
' Note: fleets array is declared in declarations.bas

SUB InitializeNaval
    ' Initialize fleets
    DIM i AS INTEGER
    FOR i = 1 TO 2
        fleets(i).size = 0
        fleets(i).loc = 0
        fleets(i).move = 0
    NEXT i
END SUB

SUB BuildShip (side AS INTEGER, portCity AS INTEGER)
    ' Build ship in port city
    ' Cost: 100 money units
    ' Maximum: 10 ships per fleet
    
    IF fleets(side).size >= 10 THEN
        COLOR 11: CALL clrbot: PRINT "Maximum fleet size reached (10 ships)"
        EXIT SUB
    END IF
    
    DIM cost AS INTEGER
    cost = 100
    
    IF GetGameStateCash&(side) < cost THEN
        COLOR 11: CALL clrbot: PRINT "Ship costs"; cost; "money units"
        EXIT SUB
    END IF
    
    ' Check if city is a port using cityMatrix(cityIndex, 7)
    IF portCity <= 0 OR portCity > MAX_CITIES THEN
        CALL ShowStatusError("Invalid port city")
        EXIT SUB
    END IF
    
    IF cityMatrix(portCity, 7) <> 1 THEN
        CALL ShowStatusError("City is not a port")
        EXIT SUB
    END IF
    
    fleets(side).size = fleets(side).size + 1
    fleets(side).loc = portCity
    CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
    
    COLOR 11: CALL clrbot: PRINT "Ship built. Fleet size:"; fleets(side).size
END SUB

SUB MoveFleet (side AS INTEGER, destinationPort AS INTEGER)
    ' Move fleet to destination port
    ' Fleets can move to any port per turn
    
    IF fleets(side).size = 0 THEN
        COLOR 11: CALL clrbot: PRINT "No fleet to move"
        EXIT SUB
    END IF
    
    fleets(side).move = destinationPort
    COLOR 11: CALL clrbot: PRINT "Fleet ordered to port"; destinationPort
END SUB

SUB ExecuteNavalCombat (side1 AS INTEGER, side2 AS INTEGER)
    ' Execute naval combat when fleets meet
    ' Each ship can take 10 hits before sinking
    ' English ships have 10% combat advantage
    
    DIM hits1 AS INTEGER
    DIM hits2 AS INTEGER
    DIM i AS INTEGER
    DIM englishBonus AS SINGLE
    
    hits1 = 0
    hits2 = 0
    
    ' English advantage (side 2 = Allies, which includes England)
    englishBonus = 1.0
    IF side2 = 2 THEN
        englishBonus = 1.1 ' 10% bonus
    END IF
    
    ' Combat resolution
    ' Each ship can take 10 hits
    FOR i = 1 TO fleets(side1).size
        IF RND < 0.5 THEN hits1 = hits1 + 1
    NEXT i
    
    FOR i = 1 TO fleets(side2).size
        IF RND < 0.5 * englishBonus THEN hits2 = hits2 + 1
    NEXT i
    
    ' Remove sunk ships
    fleets(side1).size = fleets(side1).size - (hits1 \ 10)
    fleets(side2).size = fleets(side2).size - (hits2 \ 10)
    
    IF fleets(side1).size < 0 THEN fleets(side1).size = 0
    IF fleets(side2).size < 0 THEN fleets(side2).size = 0
    
    COLOR 11: CALL clrbot: PRINT "Naval combat: Side"; side1; "lost"; hits1 \ 10; "ships, Side"; side2; "lost"; hits2 \ 10; "ships"
END SUB

SUB BombardCity (side AS INTEGER, targetCity AS INTEGER)
    ' Bombard city with fleet
    ' Damages defending armies, reduces fortifications, can drive cities to neutrality
    
    IF fleets(side).size = 0 THEN
        COLOR 11: CALL clrbot: PRINT "No fleet available"
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetCity THEN
        CALL ShowStatusError("Fleet must be in target city port")
        EXIT SUB
    END IF
    
    ' Verify target city is actually a port
    IF targetCity <= 0 OR targetCity > MAX_CITIES THEN
        CALL ShowStatusError("Invalid target city")
        EXIT SUB
    END IF
    
    IF cityMatrix(targetCity, 7) <> 1 THEN
        CALL ShowStatusError("Target city is not a port")
        EXIT SUB
    END IF
    
    ' Reduce fortification
    IF cities(targetCity).fort > FORT_NONE THEN
        cities(targetCity).fort = cities(targetCity).fort - 1
    END IF
    
    ' Damage defending armies (placeholder - will implement actual damage)
    COLOR 11: CALL clrbot: PRINT "City bombarded. Fortifications reduced"
END SUB

SUB BlockadePort (side AS INTEGER, targetPort AS INTEGER)
    ' Blockade port
    ' Reduces enemy supply in blockaded ports
    
    IF fleets(side).size = 0 THEN
        COLOR 11: CALL clrbot: PRINT "No fleet available"
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetPort THEN
        COLOR 11: CALL clrbot: PRINT "Fleet must be in target port"
        EXIT SUB
    END IF
    
    COLOR 11: CALL clrbot: PRINT "Port blockaded. Enemy supply reduced"
END SUB

SUB RaidCommerce (side AS INTEGER)
    ' Commerce raiding
    ' Reduces enemy income, risks ship loss
    
    IF fleets(side).size < 2 THEN
        COLOR 11: CALL clrbot: PRINT "Need at least 2 ships for commerce raiding"
        EXIT SUB
    END IF
    
    DIM damage AS LONG
    damage = fleets(side).size * 10 ' Base damage
    
    ' Risk of ship loss
    IF RND < 0.2 THEN
        fleets(side).size = fleets(side).size - 1
        COLOR 11: CALL clrbot: PRINT "Raider lost a ship during commerce raid"
    END IF
    
    ' Reduce enemy income
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    CALL SetGameStateIncome(enemySide, GetGameStateIncome&(enemySide) - damage)
    IF GetGameStateIncome&(enemySide) < 0 THEN CALL SetGameStateIncome(enemySide, 0)
    
    COLOR 11: CALL clrbot: PRINT "Commerce raided. Enemy income reduced by"; damage
END SUB

SUB MarineInvasion (side AS INTEGER, targetCity AS INTEGER)
    ' Marine invasion at neutral cities
    ' Requires 2+ ships
    ' Small-scale invasion
    
    IF fleets(side).size < 2 THEN
        COLOR 11: CALL clrbot: PRINT "Need at least 2 ships for marine invasion"
        EXIT SUB
    END IF
    
    IF cities(targetCity).owner <> CITY_NEUTRAL THEN
        COLOR 11: CALL clrbot: PRINT "Marine invasions only at neutral cities"
        EXIT SUB
    END IF
    
    ' Small invasion force (placeholder - will create small army)
    COLOR 11: CALL clrbot: PRINT "Marine invasion launched at"; cities(targetCity).name
END SUB

