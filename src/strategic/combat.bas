'============================================================================
' Strategic Combat Resolution
'============================================================================
' Strategic-level combat when tactical battles are not triggered
' Handles combat calculations, casualties, retreats

' Note: game_types.bas is included in main.bas
' Note: army.bas, city.bas, cohesion.bas, economy.bas, victory.bas, tactical_integration.bas are included in main.bas

FUNCTION CalculateCombatStrength& (armyIndex AS INTEGER)
    ' Calculate effective combat strength
    ' Factors: base strength, leadership, experience, supply, cohesion
    
    DIM baseStrength AS LONG
    DIM effectiveness AS SINGLE
    
    baseStrength = armies(armyIndex).size
    
    ' Leadership modifier
    effectiveness = 1.0 + (armies(armyIndex).lead - 5) * 0.1
    
    ' Experience modifier
    effectiveness = effectiveness * (1.0 + armies(armyIndex).exper * 0.05)
    
    ' Supply modifier
    IF IsOutOfSupply%(armyIndex) = 1 THEN
        effectiveness = effectiveness * 0.5 ' 50% if out of supply
    END IF
    
    ' Cohesion modifier
    effectiveness = ApplyCohesionPenalty!(armyIndex, effectiveness)
    
    CalculateCombatStrength& = baseStrength * effectiveness
END FUNCTION

FUNCTION CalculateDefenderBonus! (cityIndex AS INTEGER)
    ' Calculate defender bonus
    ' Factors: fortification, terrain
    
    DIM bonus AS SINGLE
    bonus = 1.0
    
    ' Fortification bonus
    IF cities(cityIndex).fort = FORT_PLUS THEN
        bonus = bonus * 1.5 ' 50% bonus
    ELSEIF cities(cityIndex).fort = FORT_PLUS_PLUS THEN
        bonus = bonus * 2.0 ' 100% bonus
    END IF
    
    ' Realism mode defender advantage
    IF realismMode = 1 THEN
        bonus = bonus * GetDefenderAdvantage!(cityIndex)
    END IF
    
    CalculateDefenderBonus! = bonus
END FUNCTION

SUB ApplyCombatCasualties (attackerIndex AS INTEGER, defenderIndex AS INTEGER, winner AS INTEGER)
    ' Apply casualties based on combat result
    ' Winner takes fewer casualties
    
    DIM attackerCasualties AS LONG
    DIM defenderCasualties AS LONG
    DIM attackerStrength AS LONG
    DIM defenderStrength AS LONG
    
    attackerStrength = armies(attackerIndex).size
    defenderStrength = armies(defenderIndex).size
    
    IF winner = 1 THEN
        ' Attacker wins
        attackerCasualties = attackerStrength * 0.1 ' 10% casualties
        defenderCasualties = defenderStrength * 0.15 ' 15% casualties
    ELSE
        ' Defender wins
        attackerCasualties = attackerStrength * 0.15 ' 15% casualties
        defenderCasualties = defenderStrength * 0.1 ' 10% casualties
    END IF
    
    ' Apply casualties
    armies(attackerIndex).size = armies(attackerIndex).size - attackerCasualties
    armies(defenderIndex).size = armies(defenderIndex).size - defenderCasualties
    
    ' Ensure non-negative
    IF armies(attackerIndex).size < 0 THEN armies(attackerIndex).size = 0
    IF armies(defenderIndex).size < 0 THEN armies(defenderIndex).size = 0
    
    ' Update battle statistics
    UpdateBattleStats winner, attackerCasualties, defenderCasualties
END SUB

SUB DetermineCombatWinner (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER, winner AS INTEGER)
    ' Determine combat winner based on effective strengths
    ' Returns winner (1=attacker, 2=defender) via parameter
    
    DIM attackerStrength AS LONG
    DIM defenderStrength AS LONG
    DIM attackerRoll AS SINGLE
    DIM defenderRoll AS SINGLE
    
    ' Calculate effective strengths
    attackerStrength = CalculateCombatStrength(attackerIndex)
    defenderStrength = CalculateCombatStrength(defenderIndex)
    
    ' Apply defender bonus
    defenderStrength = defenderStrength * CalculateDefenderBonus(cityIndex)
    
    ' Combat roll with randomness
    attackerRoll = attackerStrength * (0.8 + RND * 0.4) ' 80-120% of strength
    defenderRoll = defenderStrength * (0.8 + RND * 0.4)
    
    ' Determine winner
    IF attackerRoll > defenderRoll THEN
        winner = 1 ' Attacker wins
    ELSE
        winner = 2 ' Defender wins
    END IF
END SUB

SUB ProcessCombatResult (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER, winner AS INTEGER)
    ' Process combat result
    ' Updates game state, transfers control, processes retreats
    
    ' Apply casualties
    CALL ApplyCombatCasualties(attackerIndex, defenderIndex, winner)
    
    ' Update experience
    IF winner = 1 THEN
        IF armies(attackerIndex).exper < 10 THEN
            armies(attackerIndex).exper = armies(attackerIndex).exper + 1
        END IF
    ELSEIF armies(defenderIndex).exper < 10 THEN
        armies(defenderIndex).exper = armies(defenderIndex).exper + 1
    END IF
    
    ' Transfer city control if attacker wins
    IF winner = 1 THEN
        DIM attackerSide AS INTEGER
        IF attackerIndex >= FRENCH_START AND attackerIndex < ALLIED_START THEN
            attackerSide = 1
        ELSE
            attackerSide = 2
        END IF
        CALL CaptureCity(cityIndex, attackerSide)
    ELSE
        ' Defender wins - attacker's move cancelled
        armies(attackerIndex).move = armies(attackerIndex).loc
    END IF
    
    ' Process retreat for loser
    IF winner = 1 THEN
        ' Defender retreats
        IF armies(defenderIndex).size > 0 THEN
            CALL ProcessRetreat(defenderIndex, cityIndex)
        ELSE
            ' Army destroyed
            armies(defenderIndex).size = 0
            armies(defenderIndex).name = ""
            armies(defenderIndex).loc = 0
            AwardArmyCapture(1) ' Award to attacker
        END IF
    ELSE
        ' Attacker retreats
        armies(attackerIndex).move = armies(attackerIndex).loc ' Cancel movement
    END IF
    
    ' Award battle victory
    DIM winnerSide AS INTEGER
    IF winner = 1 THEN
        IF attackerIndex >= FRENCH_START AND attackerIndex < ALLIED_START THEN
            winnerSide = 1
        ELSE
            winnerSide = 2
        END IF
    ELSEIF defenderIndex >= FRENCH_START AND defenderIndex < ALLIED_START THEN
        winnerSide = 1
    ELSE
        winnerSide = 2
    END IF
    
    AwardBattleVictory(winnerSide)
    
    ' Record in history
    DIM attackerName AS STRING
    DIM defenderName AS STRING
    DIM attackerCasualties AS LONG
    DIM defenderCasualties AS LONG
    
    attackerName = armies(attackerIndex).name
    defenderName = armies(defenderIndex).name
    
    IF winner = 1 THEN
        attackerCasualties = armies(attackerIndex).size * 0.1
        defenderCasualties = armies(defenderIndex).size * 0.15
    ELSE
        attackerCasualties = armies(attackerIndex).size * 0.15
        defenderCasualties = armies(defenderIndex).size * 0.1
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

