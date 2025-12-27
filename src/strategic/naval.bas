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
    ' Cost: SHIP_COST money units
    ' Maximum: MAX_FLEET_SIZE ships per fleet
    
    IF fleets(side).size >= MAX_FLEET_SIZE THEN
        CALL HandleValidationError("Maximum fleet size reached (" + LTRIM$(STR$(MAX_FLEET_SIZE)) + " ships)")
        EXIT SUB
    END IF
    
    DIM cost AS INTEGER
    cost = SHIP_COST
    
    IF GetGameStateCash&(side) < cost THEN
        CALL HandleValidationError("Ship costs " + LTRIM$(STR$(cost)) + " money units")
        EXIT SUB
    END IF
    
    ' Check if city is a port using cityMatrix(cityIndex, CITY_MATRIX_COLUMNS)
    IF ValidateCityIndex%(portCity, "BuildShip") = 0 THEN
        EXIT SUB
    END IF
    
    IF IsPortCity%(portCity) = 0 THEN
        CALL HandleValidationError("City is not a port")
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
    
    ' Validate inputs
    IF ValidateArmySide%(side, "MoveFleet") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateCityIndex%(destinationPort, "MoveFleet") = 0 THEN
        EXIT SUB
    END IF
    
    IF IsFleetActive%(side) = 0 THEN
        CALL HandleValidationError("No fleet to move")
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
    
    ' Validate inputs
    IF ValidateArmySide%(side1, "ExecuteNavalCombat") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateArmySide%(side2, "ExecuteNavalCombat") = 0 THEN
        EXIT SUB
    END IF
    
    DIM hits1 AS INTEGER
    DIM hits2 AS INTEGER
    DIM i AS INTEGER
    DIM englishBonus AS SINGLE
    
    hits1 = 0
    hits2 = 0
    
    ' English advantage (side 2 = Allies, which includes England)
    englishBonus = 1.0
    IF side2 = 2 THEN
        englishBonus = ENGLISH_NAVAL_BONUS ' 10% bonus
    END IF
    
    ' Combat resolution
    ' Each ship can take SHIP_HITS_TO_SINK hits
    FOR i = 1 TO fleets(side1).size
        IF RND < NAVAL_COMBAT_HIT_CHANCE THEN hits1 = hits1 + 1
    NEXT i
    
    FOR i = 1 TO fleets(side2).size
        IF RND < NAVAL_COMBAT_HIT_CHANCE * englishBonus THEN hits2 = hits2 + 1
    NEXT i
    
    ' Remove sunk ships
    fleets(side1).size = fleets(side1).size - (hits1 \ 10)
    fleets(side2).size = fleets(side2).size - (hits2 \ 10)
    
    IF fleets(side1).size < 0 THEN fleets(side1).size = 0
    IF fleets(side2).size < 0 THEN fleets(side2).size = 0
    
    CALL ShowStatusMessage("Naval combat: Side " + LTRIM$(STR$(side1)) + " lost " + LTRIM$(STR$(hits1 \ SHIP_HITS_TO_SINK)) + " ships, Side " + LTRIM$(STR$(side2)) + " lost " + LTRIM$(STR$(hits2 \ SHIP_HITS_TO_SINK)) + " ships", 11)
END SUB

'============================================================================
' BombardCity - Bombard a city with fleet
'============================================================================
' Parameters:
'   side (INTEGER) - Side performing bombardment (1=French, 2=Allies)
'   targetCity (INTEGER) - City index to bombard (must be a port)
' Description:
'   Bombards a port city with a fleet. Calculates damage based on fleet size
'   (5% per ship) and applies it to defending enemy armies. Damage is reduced
'   by fortification level (15% per level). Also reduces fortification level by 1.
'   The fleet must be located at the target city.
' Side Effects:
'   - Damages defending enemy armies based on fleet size and fortifications
'   - Reduces city fortification by 1 level
'   - Displays error if no fleet, wrong location, or not a port
'============================================================================
SUB BombardCity (side AS INTEGER, targetCity AS INTEGER)
    ' Bombard city with fleet
    ' Damages defending armies, reduces fortifications, can drive cities to neutrality
    
    IF IsFleetActive%(side) = 0 THEN
        CALL HandleValidationError("No fleet available")
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetCity THEN
        CALL HandleValidationError("Fleet must be in target city port")
        EXIT SUB
    END IF
    
    ' Verify target city is actually a port
    IF ValidateCityIndex%(targetCity, "BombardCity") = 0 THEN
        EXIT SUB
    END IF
    
    IF IsPortCity%(targetCity) = 0 THEN
        CALL HandleValidationError("Target city is not a port")
        EXIT SUB
    END IF
    
    ' Calculate damage based on fleet size
    ' Base damage: 5% per ship, reduced by fortification level
    DIM baseDamage AS SINGLE
    DIM fortReduction AS SINGLE
    DIM totalDamage AS LONG
    DIM i AS INTEGER
    DIM enemySide AS INTEGER
    DIM armiesDamaged AS INTEGER
    DIM damagePerArmy AS LONG
    
    baseDamage = fleets(side).size * NAVAL_BOMBARD_DAMAGE_PER_SHIP ' 5% per ship
    fortReduction = cities(targetCity).fort * NAVAL_BOMBARD_FORT_REDUCTION ' 15% reduction per fort level
    baseDamage = baseDamage * (1.0 - fortReduction)
    IF baseDamage < NAVAL_BOMBARD_MIN_DAMAGE THEN baseDamage = NAVAL_BOMBARD_MIN_DAMAGE ' Minimum 1% damage
    
    ' Find defending armies in city (enemy side)
    enemySide = 3 - side
    armiesDamaged = 0
    
    FOR i = 1 TO MAX_ARMIES
        IF IsArmyActive%(i) = 1 AND armies(i).loc = targetCity THEN
            DIM armySide AS INTEGER
            armySide = GetArmySide%(i)
            
            ' Only damage enemy armies
            IF armySide = enemySide THEN
                ' Calculate damage for this army
                totalDamage = armies(i).size * baseDamage
                damagePerArmy = totalDamage
                
                ' Apply damage
                armies(i).size = armies(i).size - damagePerArmy
                IF armies(i).size < 0 THEN armies(i).size = 0
                
                armiesDamaged = armiesDamaged + 1
            END IF
        END IF
    NEXT i
    
    ' Reduce fortification
    IF cities(targetCity).fort > FORT_NONE THEN
        cities(targetCity).fort = cities(targetCity).fort - 1
    END IF
    
    ' Show results
    IF armiesDamaged > 0 THEN
        CALL ShowStatusMessage("City bombarded. " + LTRIM$(STR$(armiesDamaged)) + " enemy army(ies) damaged. Fortifications reduced.", 11)
    ELSE
        CALL ShowStatusMessage("City bombarded. Fortifications reduced.", 11)
    END IF
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
    
    ' Validate inputs
    IF ValidateArmySide%(side, "BlockadePort") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateCityIndex%(targetPort, "BlockadePort") = 0 THEN
        EXIT SUB
    END IF
    
    IF IsFleetActive%(side) = 0 THEN
        CALL HandleValidationError("No fleet available")
        EXIT SUB
    END IF
    
    IF fleets(side).loc <> targetPort THEN
        CALL HandleValidationError("Fleet must be in target port")
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
    
    ' Validate input
    IF ValidateArmySide%(side, "RaidCommerce") = 0 THEN
        EXIT SUB
    END IF
    
    IF fleets(side).size < MARINE_INVASION_MIN_SHIPS THEN
        CALL HandleValidationError("Need at least " + LTRIM$(STR$(MARINE_INVASION_MIN_SHIPS)) + " ships for commerce raiding")
        EXIT SUB
    END IF
    
    DIM damage AS LONG
    damage = fleets(side).size * COMMERCE_RAID_INCOME_REDUCTION ' Base damage
    
    ' Risk of ship loss
    IF RND < COMMERCE_RAID_SHIP_LOSS_CHANCE THEN
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
'   at least 2 ships. Creates a small army (5000 men) in the neutral city
'   with a default commander. The army cannot move the turn it's created.
' Side Effects:
'   - Creates 5000-man army in target city
'   - Assigns default commander and sets nationality
'   - Marks city as occupied
'   - Displays error if insufficient ships, city not neutral, or no army slots available
'============================================================================
SUB MarineInvasion (side AS INTEGER, targetCity AS INTEGER)
    ' Marine invasion at neutral cities
    ' Requires 2+ ships
    ' Small-scale invasion
    
    ' Validate inputs
    IF ValidateArmySide%(side, "MarineInvasion") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateCityIndex%(targetCity, "MarineInvasion") = 0 THEN
        EXIT SUB
    END IF
    
    IF fleets(side).size < MARINE_INVASION_MIN_SHIPS THEN
        CALL HandleValidationError("Need at least " + LTRIM$(STR$(MARINE_INVASION_MIN_SHIPS)) + " ships for marine invasion")
        EXIT SUB
    END IF
    
    IF cities(targetCity).owner <> CITY_NEUTRAL THEN
        CALL HandleValidationError("Marine invasions only at neutral cities")
        EXIT SUB
    END IF
    
    ' Find available army slot for this side
    DIM i AS INTEGER
    DIM startIndex AS INTEGER
    DIM endIndex AS INTEGER
    DIM armyCreated AS INTEGER
    DIM defaultCommanderName AS STRING
    
    armyCreated = 0
    
    IF side = 1 THEN
        startIndex = FRENCH_START
        endIndex = FRENCH_START + 19
        defaultCommanderName = "Marine Commander"
    ELSE
        startIndex = ALLIED_START
        endIndex = ALLIED_START + 19
        defaultCommanderName = "Marine Commander"
    END IF
    
    ' Find empty army slot
    FOR i = startIndex TO endIndex
        IF armies(i).size = 0 THEN
            ' Create invasion force
            armies(i).name = defaultCommanderName
            armies(i).size = MARINE_INVASION_ARMY_SIZE ' Small invasion force
            armies(i).lead = MAX_STAT_RATING ' Default leadership rating
            armies(i).exper = 0 ' No experience yet
            armies(i).supply = 5 ' Start with some supply
            armies(i).loc = targetCity
            armies(i).move = -1 ' Cannot move this turn
            armies(i).nationality = GetCityNationality%(targetCity)
            
            ' Mark city as occupied by this army
            occupied(targetCity) = i
            
            armyCreated = 1
            EXIT FOR
        END IF
    NEXT i
    
    IF armyCreated = 0 THEN
        CALL HandleValidationError("No available army slot for invasion force")
        EXIT SUB
    END IF
    
    CALL ShowStatusMessage("Marine invasion launched at " + cities(targetCity).name + ". " + LTRIM$(STR$(MARINE_INVASION_ARMY_SIZE)) + " men landed.", 11)
END SUB

