'============================================================================
' Naval Operations System
'============================================================================
' Ported from WW2 - generic ships (no ironclads)
' Handles fleet management, combat, naval actions

' Note: game_types.bas is included in main.bas
' Note: Naval action constants are in declarations.bas
' Note: fleets array is declared in declarations.bas

'============================================================================
' InitializeNaval - Initialize naval system
'============================================================================
' Description:
'   Resets all fleet data structures to default empty values. Clears
'   fleet size, location, and movement orders for both sides.
'   Called at game start before loading scenario data.
' Side Effects:
'   - Clears all fleets array elements
'============================================================================
SUB InitializeNaval
    ' Initialize fleets
    DIM i AS INTEGER
    FOR i = 1 TO 2
        fleets(i).size = 0
        fleets(i).loc = 0
        fleets(i).move = 0
    NEXT i
END SUB

'============================================================================
' BuildShip - Build a ship in a port city
'============================================================================
' Parameters:
'   side (INTEGER) - Side building ship (1=French, 2=Allies)
'   portCity (INTEGER) - City index where ship is built (must be a port)
' Description:
'   Builds a new ship for the specified side's fleet. Cost is 100 money
'   units. Maximum fleet size is 10 ships. The city must be a port
'   (cityMatrix(cityIndex, 7) = 1).
' Side Effects:
'   - Increases fleet size by 1
'   - Sets fleet location to portCity
'   - Deducts cost from cash reserves
'   - Displays error if maximum reached, insufficient funds, or not a port
'============================================================================
SUB BuildShip (side AS INTEGER, portCity AS INTEGER)
    ' Build ship in port city
    ' Cost: 100 money units
    ' Maximum: 10 ships per fleet
    
    IF fleets(side).size >= 10 THEN
        CALL ShowStatusError("Maximum fleet size reached (10 ships)")
        EXIT SUB
    END IF
    
    DIM cost AS INTEGER
    cost = SHIP_COST
    
    IF GetGameStateCash&(side) < cost THEN
        CALL ShowStatusError("Ship costs " + LTRIM$(STR$(cost)) + " money units")
        EXIT SUB
    END IF
    
    ' Check if city is a port using cityMatrix(cityIndex, 7)
    IF ValidateCityIndex%(portCity, "BuildShip") = 0 THEN
        EXIT SUB
    END IF
    
    IF cityMatrix(portCity, 7) <> 1 THEN
        CALL ShowStatusError("City is not a port")
        EXIT SUB
    END IF
    
    fleets(side).size = fleets(side).size + 1
    fleets(side).loc = portCity
    CALL SetGameStateCash(side, GetGameStateCash&(side) - cost)
    
    CALL ShowStatusMessage("Ship built. Fleet size: " + LTRIM$(STR$(fleets(side).size)), 11)
END SUB

'============================================================================
' MoveFleet - Set movement order for fleet
'============================================================================
' Parameters:
'   side (INTEGER) - Side whose fleet to move (1=French, 2=Allies)
'   destinationPort (INTEGER) - Port city index to move fleet to
' Description:
'   Sets a movement order for a fleet. Fleets can move to any port
'   in a single turn. The actual movement is executed during the
'   Move & Combat phase.
' Side Effects:
'   - Sets fleets(side).move to destinationPort
'   - Displays error if no fleet exists
'============================================================================
SUB MoveFleet (side AS INTEGER, destinationPort AS INTEGER)
    ' Move fleet to destination port
    ' Fleets can move to any port per turn
    
    IF fleets(side).size = 0 THEN
        CALL ShowStatusError("No fleet to move")
        EXIT SUB
    END IF
    
    fleets(side).move = destinationPort
    CALL ShowStatusMessage("Fleet ordered to port " + LTRIM$(STR$(destinationPort)), 11)
END SUB

'============================================================================
' ExecuteNavalCombat - Resolve naval combat between two fleets
'============================================================================
' Parameters:
'   side1 (INTEGER) - First side in combat (1=French, 2=Allies)
'   side2 (INTEGER) - Second side in combat (1=French, 2=Allies)
' Description:
'   Resolves naval combat when two fleets meet at the same port. Each
'   ship can take 10 hits before sinking. English ships (Allied side)
'   have a 10% combat advantage. Combat is resolved probabilistically
'   with each ship having a 50% chance to score a hit (60% for English).
' Side Effects:
'   - Reduces fleet sizes based on combat results
'   - Displays combat results message
'============================================================================
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
    
    CALL ShowStatusMessage("Naval combat: Side " + LTRIM$(STR$(side1)) + " lost " + LTRIM$(STR$(hits1 \ 10)) + " ships, Side " + LTRIM$(STR$(side2)) + " lost " + LTRIM$(STR$(hits2 \ 10)) + " ships", 11)
END SUB

'============================================================================
' BombardCity - Bombard a city with fleet
'============================================================================
' Parameters:
'   side (INTEGER) - Side performing bombardment (1=French, 2=Allies)
'   targetCity (INTEGER) - City index to bombard (must be a port)
' Description:
'   Bombards a port city with a fleet. Reduces fortification level by 1.
'   The fleet must be located at the target city. Future implementation
'   will include damage to defending armies and ability to drive cities
'   to neutrality.
' Side Effects:
'   - Reduces city fortification by 1 level
'   - Displays error if no fleet, wrong location, or not a port
'============================================================================
SUB BombardCity (side AS INTEGER, targetCity AS INTEGER)
    ' Bombard city with fleet
    ' Damages defending armies, reduces fortifications, can drive cities to neutrality
    
    IF fleets(side).size = 0 THEN
        CALL ShowStatusError("No fleet available")
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetCity THEN
        CALL ShowStatusError("Fleet must be in target city port")
        EXIT SUB
    END IF
    
    ' Verify target city is actually a port
    IF ValidateCityIndex%(targetCity, "BombardCity") = 0 THEN
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
    
    ' TODO: Implement actual damage calculation:
    '   - Calculate damage based on fleet size
    '   - Apply to defending armies in city
    '   - Reduce fortification level
    CALL ShowStatusMessage("City bombarded. Fortifications reduced", 11)
END SUB

'============================================================================
' BlockadePort - Blockade an enemy port
'============================================================================
' Parameters:
'   side (INTEGER) - Side performing blockade (1=French, 2=Allies)
'   targetPort (INTEGER) - Port city index to blockade
' Description:
'   Establishes a naval blockade of an enemy port. Reduces enemy supply
'   capabilities in blockaded ports. The fleet must be located at the
'   target port.
' Side Effects:
'   - Applies blockade effects (future implementation)
'   - Displays error if no fleet or wrong location
'============================================================================
SUB BlockadePort (side AS INTEGER, targetPort AS INTEGER)
    ' Blockade port
    ' Reduces enemy supply in blockaded ports
    
    IF fleets(side).size = 0 THEN
        CALL ShowStatusError("No fleet available")
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetPort THEN
        CALL ShowStatusError("Fleet must be in target port")
        EXIT SUB
    END IF
    
    CALL ShowStatusMessage("Port blockaded. Enemy supply reduced", 11)
END SUB

'============================================================================
' RaidCommerce - Conduct commerce raiding
'============================================================================
' Parameters:
'   side (INTEGER) - Side conducting raid (1=French, 2=Allies)
' Description:
'   Conducts commerce raiding operations against enemy shipping. Reduces
'   enemy income based on fleet size (10 per ship). Requires at least 2
'   ships. There is a 20% chance of losing a ship during the raid.
' Side Effects:
'   - Reduces enemy income
'   - May lose 1 ship (20% chance)
'   - Displays error if insufficient ships
'============================================================================
SUB RaidCommerce (side AS INTEGER)
    ' Commerce raiding
    ' Reduces enemy income, risks ship loss
    
    IF fleets(side).size < 2 THEN
        CALL ShowStatusError("Need at least 2 ships for commerce raiding")
        EXIT SUB
    END IF
    
    DIM damage AS LONG
    damage = fleets(side).size * 10 ' Base damage
    
    ' Risk of ship loss
    IF RND < 0.2 THEN
        fleets(side).size = fleets(side).size - 1
        CALL ShowStatusWarning("Raider lost a ship during commerce raid")
    END IF
    
    ' Reduce enemy income
    DIM enemySide AS INTEGER
    enemySide = 3 - side
    CALL SetGameStateIncome(enemySide, GetGameStateIncome&(enemySide) - damage)
    IF GetGameStateIncome&(enemySide) < 0 THEN CALL SetGameStateIncome(enemySide, 0)
    
    CALL ShowStatusMessage("Commerce raided. Enemy income reduced by " + LTRIM$(STR$(damage)), 11)
END SUB

'============================================================================
' MarineInvasion - Launch marine invasion at neutral city
'============================================================================
' Parameters:
'   side (INTEGER) - Side launching invasion (1=French, 2=Allies)
'   targetCity (INTEGER) - Neutral city index to invade
' Description:
'   Launches a small-scale marine invasion at a neutral city. Requires
'   at least 2 ships. Future implementation will create a small army
'   (5000 men) in the neutral city with a default commander.
' Side Effects:
'   - Launches invasion (future implementation)
'   - Displays error if insufficient ships or city not neutral
'============================================================================
SUB MarineInvasion (side AS INTEGER, targetCity AS INTEGER)
    ' Marine invasion at neutral cities
    ' Requires 2+ ships
    ' Small-scale invasion
    
    IF fleets(side).size < 2 THEN
        CALL ShowStatusError("Need at least 2 ships for marine invasion")
        EXIT SUB
    END IF
    
    IF cities(targetCity).owner <> CITY_NEUTRAL THEN
        CALL ShowStatusError("Marine invasions only at neutral cities")
        EXIT SUB
    END IF
    
    ' TODO: Implement invasion force creation:
    '   - Create small army (5000 men) in neutral city
    '   - Assign default commander
    '   - Set nationality based on fleet owner
    CALL ShowStatusMessage("Marine invasion launched at " + cities(targetCity).name, 11)
END SUB

