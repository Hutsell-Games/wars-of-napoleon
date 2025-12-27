'============================================================================
' Strategic Combat Resolution
'============================================================================
' Strategic-level combat when tactical battles are not triggered
' Handles combat calculations, casualties, retreats

' Note: game_types.bas is included in main.bas
' Note: army.bas, city.bas, cohesion.bas, economy.bas, victory.bas, tactical_integration.bas are included in main.bas

'============================================================================
' CalculateCombatStrength - Calculate effective combat strength of an army
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army to calculate strength for
' Returns:
'   LONG - Effective combat strength (base strength * effectiveness modifiers)
' Description:
'   Calculates the effective combat strength of an army by applying various
'   modifiers to the base strength. Factors include:
'   - Leadership modifier (based on commander's leadership rating)
'   - Experience modifier (based on army's experience level)
'   - Supply modifier (50% effectiveness if out of supply)
'   - Cohesion modifier (penalty for low army cohesion)
'   Returns 0 if army index is invalid.
'============================================================================
FUNCTION CalculateCombatStrength& (armyIndex AS INTEGER)
    ' Calculate effective combat strength
    ' Factors: base strength, leadership, experience, supply, cohesion
    ' Uses cache to avoid recalculating when army attributes haven't changed
    
    ' Validate input
    IF ValidateArmyIndex%(armyIndex, "CalculateCombatStrength") = 0 THEN
        CalculateCombatStrength& = 0
        EXIT FUNCTION
    END IF
    
    ' Check cache first
    ' Note: We check cache validity flag, not the value itself, because
    ' a valid cached strength could be 0 (e.g., for destroyed armies)
    IF armyIndex >= 1 AND armyIndex <= MAX_ARMIES THEN
        IF combatStrengthCacheValid(armyIndex) = 1 THEN
            CalculateCombatStrength& = combatStrengthCache(armyIndex)
            EXIT FUNCTION
        END IF
    END IF
    
    DIM baseStrength AS LONG
    DIM effectiveness AS SINGLE
    
    baseStrength = armies(armyIndex).size
    
    ' Leadership modifier
    effectiveness = 1.0 + (armies(armyIndex).lead - LEADERSHIP_BASE_RATING) * LEADERSHIP_MODIFIER
    
    ' Experience modifier
    effectiveness = effectiveness * (1.0 + armies(armyIndex).exper * EXPERIENCE_MODIFIER)
    
    ' Supply modifier
    IF IsOutOfSupply%(armyIndex) = 1 THEN
        effectiveness = effectiveness * OUT_OF_SUPPLY_EFFECTIVENESS ' 50% if out of supply
    END IF
    
    ' Cohesion modifier
    effectiveness = ApplyCohesionPenalty!(armyIndex, effectiveness)
    
    DIM calculatedStrength AS LONG
    calculatedStrength = baseStrength * effectiveness
    
    ' Cache the result
    CALL SetCachedCombatStrength(armyIndex, calculatedStrength)
    
    CalculateCombatStrength& = calculatedStrength
END FUNCTION

'============================================================================
' CalculateDefenderBonus - Calculate defender bonus for city combat
'============================================================================
' Parameters:
'   cityIndex (INTEGER) - Index of city where combat occurs
' Returns:
'   SINGLE - Defender bonus multiplier (1.0 = no bonus, >1.0 = bonus)
' Description:
'   Calculates the defensive bonus multiplier for a city. Factors include:
'   - Fortification level (FORT_PLUS = 50% bonus, FORT_PLUS_PLUS = 100% bonus)
'   - Realism mode defender advantage (if realism mode enabled)
'   Returns 1.0 (no bonus) if city index is invalid.
'============================================================================
FUNCTION CalculateDefenderBonus! (cityIndex AS INTEGER)
    ' Calculate defender bonus
    ' Factors: fortification, terrain
    
    ' Validate input
    IF ValidateCityIndex%(cityIndex, "CalculateDefenderBonus") = 0 THEN
        CalculateDefenderBonus! = 1.0
        EXIT FUNCTION
    END IF
    
    DIM bonus AS SINGLE
    bonus = 1.0
    
    ' Fortification bonus
    IF cities(cityIndex).fort = FORT_PLUS THEN
        bonus = bonus * FORT_PLUS_DEFENDER_BONUS ' 50% bonus
    ELSEIF cities(cityIndex).fort = FORT_PLUS_PLUS THEN
        bonus = bonus * FORT_PLUS_PLUS_DEFENDER_BONUS ' 100% bonus
    END IF
    
    ' Realism mode defender advantage
    IF realismMode = 1 THEN
        bonus = bonus * GetDefenderAdvantage!(cityIndex, cities(), realismMode)
    END IF
    
    CalculateDefenderBonus! = bonus
END FUNCTION

'============================================================================
' ApplyCombatCasualties - Apply casualties to armies after combat
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
'   winner (INTEGER) - Winner side (1=attacker, 2=defender)
' Description:
'   Applies casualties to both armies based on combat result. The winner
'   takes fewer casualties (COMBAT_WINNER_CASUALTIES = 10%) while the loser
'   takes more casualties (COMBAT_LOSER_CASUALTIES = 15%). Updates army
'   strengths and ensures they don't go negative. Also updates battle statistics.
' Side Effects:
'   - Modifies armies(attackerIndex).size
'   - Modifies armies(defenderIndex).size
'   - Updates battle statistics via UpdateBattleStats
'============================================================================
SUB ApplyCombatCasualties (attackerIndex AS INTEGER, defenderIndex AS INTEGER, winner AS INTEGER)
    ' Apply casualties based on combat result
    ' Winner takes fewer casualties
    
    ' Validate inputs
    IF ValidateArmyIndex%(attackerIndex, "ApplyCombatCasualties") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateArmyIndex%(defenderIndex, "ApplyCombatCasualties") = 0 THEN
        EXIT SUB
    END IF
    
    DIM attackerCasualties AS LONG
    DIM defenderCasualties AS LONG
    DIM attackerStrength AS LONG
    DIM defenderStrength AS LONG
    
    attackerStrength = armies(attackerIndex).size
    defenderStrength = armies(defenderIndex).size
    
    IF winner = 1 THEN
        ' Attacker wins
        attackerCasualties = attackerStrength * COMBAT_WINNER_CASUALTIES ' 10% casualties
        defenderCasualties = defenderStrength * COMBAT_LOSER_CASUALTIES ' 15% casualties
    ELSE
        ' Defender wins
        attackerCasualties = attackerStrength * COMBAT_LOSER_CASUALTIES ' 15% casualties
        defenderCasualties = defenderStrength * COMBAT_WINNER_CASUALTIES ' 10% casualties
    END IF
    
    ' Apply casualties
    armies(attackerIndex).size = armies(attackerIndex).size - attackerCasualties
    armies(defenderIndex).size = armies(defenderIndex).size - defenderCasualties
    
    ' Ensure non-negative
    IF armies(attackerIndex).size < 0 THEN armies(attackerIndex).size = 0
    IF armies(defenderIndex).size < 0 THEN armies(defenderIndex).size = 0
    
    ' Invalidate combat strength cache for both armies
    CALL InvalidateCombatStrengthCache(attackerIndex)
    CALL InvalidateCombatStrengthCache(defenderIndex)
    
    ' Update battle statistics
    CALL UpdateBattleStats(winner, attackerCasualties, defenderCasualties)
END SUB

'============================================================================
' DetermineCombatWinner - Determine winner of strategic combat
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
'   cityIndex (INTEGER) - Index of city where combat occurs (0 if no city)
'   winner (INTEGER) - Output parameter: Winner side (1=attacker, 2=defender)
' Description:
'   Determines the winner of strategic combat by comparing effective combat
'   strengths. Calculates attacker and defender effective strengths, applies
'   defender bonus for city combat, then applies random combat roll (80-120%
'   of strength) to add variability. The side with the higher roll wins.
'   Returns winner via output parameter (1=attacker wins, 2=defender wins).
'   Defaults to defender wins (2) if any input validation fails.
' Side Effects:
'   - Sets winner parameter with combat result
'============================================================================
SUB DetermineCombatWinner (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER, winner AS INTEGER)
    ' Determine combat winner based on effective strengths
    ' Returns winner (1=attacker, 2=defender) via parameter
    
    ' Validate inputs
    IF ValidateArmyIndex%(attackerIndex, "DetermineCombatWinner") = 0 THEN
        winner = 2 ' Default to defender wins on error
        EXIT SUB
    END IF
    IF ValidateArmyIndex%(defenderIndex, "DetermineCombatWinner") = 0 THEN
        winner = 2 ' Default to defender wins on error
        EXIT SUB
    END IF
    IF cityIndex > 0 THEN
        IF ValidateCityIndex%(cityIndex, "DetermineCombatWinner") = 0 THEN
            winner = 2 ' Default to defender wins on error
            EXIT SUB
        END IF
    END IF
    
    DIM attackerStrength AS LONG
    DIM defenderStrength AS LONG
    DIM attackerRoll AS SINGLE
    DIM defenderRoll AS SINGLE
    
    ' Calculate effective strengths
    attackerStrength = CalculateCombatStrength&(attackerIndex)
    defenderStrength = CalculateCombatStrength&(defenderIndex)
    
    ' Apply defender bonus
    defenderStrength = defenderStrength * CalculateDefenderBonus(cityIndex)
    
    ' Combat roll with randomness
    attackerRoll = attackerStrength * (COMBAT_ROLL_MIN + RND * (COMBAT_ROLL_MAX - COMBAT_ROLL_MIN)) ' 80-120% of strength
    defenderRoll = defenderStrength * (COMBAT_ROLL_MIN + RND * (COMBAT_ROLL_MAX - COMBAT_ROLL_MIN))
    
    ' Determine winner
    IF attackerRoll > defenderRoll THEN
        winner = 1 ' Attacker wins
    ELSE
        winner = 2 ' Defender wins
    END IF
END SUB

'============================================================================
' ProcessCombatResult - Process results of strategic combat
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
'   cityIndex (INTEGER) - Index of city where combat occurred (0 if no city)
'   winner (INTEGER) - Winner side (1=attacker, 2=defender)
' Description:
'   Processes the results of strategic combat by:
'   1. Applying casualties to both armies
'   2. Updating experience for the winning army (+1, max MAX_EXPERIENCE)
'   3. Transferring city control if attacker wins
'   4. Processing retreat for the losing army
'   5. Awarding battle victory points
'   6. Recording battle in history
'   Handles army destruction if strength reaches 0, marks commanders as
'   available, and awards army capture points if applicable.
' Side Effects:
'   - Modifies army strengths, experience, and locations
'   - May transfer city ownership
'   - Updates battle statistics and history
'   - Awards victory points
'============================================================================
SUB ProcessCombatResult (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER, winner AS INTEGER)
    ' Process combat result
    ' Updates game state, transfers control, processes retreats
    
    ' Validate inputs
    IF ValidateArmyIndex%(attackerIndex, "ProcessCombatResult") = 0 THEN
        EXIT SUB
    END IF
    IF ValidateArmyIndex%(defenderIndex, "ProcessCombatResult") = 0 THEN
        EXIT SUB
    END IF
    IF cityIndex > 0 THEN
        IF ValidateCityIndex%(cityIndex, "ProcessCombatResult") = 0 THEN
            EXIT SUB
        END IF
    END IF
    
    ' Apply casualties
    CALL ApplyCombatCasualties(attackerIndex, defenderIndex, winner)
    
    ' Update experience
    IF winner = 1 THEN
        IF armies(attackerIndex).exper < MAX_EXPERIENCE THEN
            armies(attackerIndex).exper = armies(attackerIndex).exper + 1
            CALL InvalidateCombatStrengthCache(attackerIndex)
        END IF
    ELSEIF armies(defenderIndex).exper < MAX_EXPERIENCE THEN
        armies(defenderIndex).exper = armies(defenderIndex).exper + 1
        CALL InvalidateCombatStrengthCache(defenderIndex)
    END IF
    
    ' Transfer city control if attacker wins
    IF winner = 1 THEN
        DIM attackerSide AS INTEGER
        attackerSide = GetArmySide%(attackerIndex)
        IF attackerSide > 0 THEN
            CALL CaptureCity(cityIndex, attackerSide)
        END IF
    ELSE
        ' Defender wins - attacker's move cancelled
        armies(attackerIndex).move = armies(attackerIndex).loc
    END IF
    
    ' Process retreat for loser
    IF winner = 1 THEN
        ' Defender retreats
        IF IsArmyActive%(defenderIndex) = 1 THEN
            CALL ProcessRetreat(defenderIndex, cityIndex)
        ELSE
            ' Army destroyed - mark commander as available
            CALL MarkCommanderAvailable(defenderIndex)
            armies(defenderIndex).size = 0
            armies(defenderIndex).name = ""
            armies(defenderIndex).loc = 0
            ' Invalidate caches (army destroyed, location changed)
            CALL InvalidateArmyLocationIndex
            CALL InvalidateCombatStrengthCache(defenderIndex)
            AwardArmyCapture(1) ' Award to attacker
        END IF
    ELSE
        ' Attacker retreats
        armies(attackerIndex).move = armies(attackerIndex).loc ' Cancel movement
    END IF
    
    ' Award battle victory
    DIM winnerSide AS INTEGER
    IF winner = 1 THEN
        winnerSide = GetArmySide%(attackerIndex)
    ELSE
        winnerSide = GetArmySide%(defenderIndex)
    END IF
    IF winnerSide = 0 THEN winnerSide = 1 ' Fallback if invalid
    
    AwardBattleVictory(winnerSide)
    
    ' Record in history
    DIM attackerName AS STRING
    DIM defenderName AS STRING
    DIM attackerCasualties AS LONG
    DIM defenderCasualties AS LONG
    
    attackerName = armies(attackerIndex).name
    defenderName = armies(defenderIndex).name
    
    IF winner = 1 THEN
        attackerCasualties = armies(attackerIndex).size * COMBAT_WINNER_CASUALTIES
        defenderCasualties = armies(defenderIndex).size * COMBAT_LOSER_CASUALTIES
    ELSE
        attackerCasualties = armies(attackerIndex).size * COMBAT_LOSER_CASUALTIES
        defenderCasualties = armies(defenderIndex).size * COMBAT_WINNER_CASUALTIES
    END IF
    
    DIM winnerName AS STRING
    IF winner = 1 THEN
        winnerName = armies(attackerIndex).name
    ELSE
        winnerName = armies(defenderIndex).name
    END IF
    
    RecordBattleHistory attackerName, armies(attackerIndex).size + attackerCasualties, attackerCasualties, _
                        defenderName, armies(defenderIndex).size + defenderCasualties, defenderCasualties, _
                        winnerName, cities(cityIndex).name
END SUB

