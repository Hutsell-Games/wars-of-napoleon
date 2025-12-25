'============================================================================
' Tactical Integration System
'============================================================================
' UNIQUE TO WON - Battle trigger logic and result processing
' Modern unified approach: Direct function calls instead of file I/O

' Note: battle_types.bas and game_types.bas are included in main.bas
' Note: army.bas, city.bas, campaign.bas, cohesion.bas are included in main.bas
' Note: tactical/battle.bas will be implemented in Phase 3

' Note: LaunchTacticalBattle is defined in tactical/battle.bas
' DECLARE not needed - QB64 will find it automatically

FUNCTION ShouldTriggerTacticalBattle% (attackerIndex AS INTEGER, defenderIndex AS INTEGER)
    ' Check if tactical battle should be triggered
    ' Conditions:
    ' 1. TACTICAL option enabled (from NWS.CFG)
    ' 2. Force ratio <= 3:1
    
    ShouldTriggerTacticalBattle% = 0
    
    ' Check TACTICAL option
    IF config_tactical = 0 THEN
        EXIT FUNCTION ' Tactical battles disabled
    END IF
    
    ' Check force ratio
    DIM attackerStrength AS LONG
    DIM defenderStrength AS LONG
    DIM ratio AS SINGLE
    
    attackerStrength = armies(attackerIndex).size
    defenderStrength = armies(defenderIndex).size
    
    IF defenderStrength = 0 THEN
        EXIT FUNCTION ' No defender
    END IF
    
    ' Calculate ratio (attacker:defender)
    ratio = attackerStrength / defenderStrength
    
    ' Check if ratio is between 1:3 and 3:1
    IF ratio >= (1 / 3) AND ratio <= 3 THEN
        ShouldTriggerTacticalBattle% = 1 ' Trigger tactical battle
    END IF
END FUNCTION

FUNCTION ResolveCombat% (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER)
    ' Resolve combat between attacker and defender
    ' Returns winner (1=attacker, 2=defender)
    ' May trigger tactical battle or use strategic resolution
    
    DIM attackerSide AS INTEGER
    DIM defenderSide AS INTEGER
    DIM winner AS INTEGER
    DIM battleData AS BattleData
    DIM battleResult AS BattleResult
    
    ' Determine sides
    IF attackerIndex >= FRENCH_START AND attackerIndex < ALLIED_START THEN
        attackerSide = 1
    ELSE
        attackerSide = 2
    END IF
    
    IF defenderIndex >= FRENCH_START AND defenderIndex < ALLIED_START THEN
        defenderSide = 1
    ELSE
        defenderSide = 2
    END IF
    
    ' Check if tactical battle should be triggered
    IF ShouldTriggerTacticalBattle%(attackerIndex, defenderIndex) = 1 THEN
        ' Prepare battle data
        battleData.scenario = scenario$
        battleData.side = gameState.side
        battleData.sideID1 = attackerSide
        battleData.sideID2 = defenderSide
        battleData.commander1 = armies(attackerIndex).name
        battleData.commander2 = armies(defenderIndex).name
        battleData.vp1 = armies(attackerIndex).size \ 100 ' Convert to hundreds
        battleData.vp2 = armies(defenderIndex).size \ 100
        battleData.leadbase1 = armies(attackerIndex).lead
        battleData.leadbase2 = armies(defenderIndex).lead
        battleData.expbase1 = armies(attackerIndex).exper
        battleData.expbase2 = armies(defenderIndex).exper
        battleData.difficult = config_balance
        battleData.fort = cities(cityIndex).fort
        battleData.quiet = config_sound
        
        ' Apply supply penalty if out of supply
        IF IsOutOfSupply%(attackerIndex) = 1 THEN
            battleData.vp1 = battleData.vp1 \ 2 ' 50% strength
        END IF
        IF IsOutOfSupply%(defenderIndex) = 1 THEN
            battleData.vp2 = battleData.vp2 \ 2 ' 50% strength
        END IF
        
        ' Launch tactical battle
        ' NOTE: Avoid ON ERROR GOTO + in-procedure labels inside FUNCTIONs.
        ' QB64/QB64-PE can report "Common label within a SUB/FUNCTION" for that pattern.
        CALL LaunchTacticalBattle(battleData, battleResult)
        
        ' Process results
        winner = ProcessTacticalResults%(battleResult, attackerIndex, defenderIndex, cityIndex, attackerSide, defenderSide)
    ELSE
        ' Strategic combat resolution
        winner = ResolveStrategicCombat%(attackerIndex, defenderIndex, cityIndex)
    END IF
    
    ResolveCombat% = winner
    EXIT FUNCTION
END FUNCTION

FUNCTION ProcessTacticalResults% (result AS BattleResult, attackerIndex AS INTEGER, defenderIndex AS INTEGER, _
                                  cityIndex AS INTEGER, attackerSide AS INTEGER, defenderSide AS INTEGER)
    ' Process results from tactical battle
    ' Updates army strengths, city control, experience, retreats
    
    DIM winner AS INTEGER
    DIM loser AS INTEGER
    DIM winnerSide AS INTEGER
    DIM loserSide AS INTEGER
    
    winner = result.winner
    IF winner = attackerSide THEN
        winnerSide = attackerSide
        loserSide = defenderSide
        winner = attackerIndex
        loser = defenderIndex
    ELSE
        winnerSide = defenderSide
        loserSide = attackerSide
        winner = defenderIndex
        loser = attackerIndex
    END IF
    
    ' Update army strengths based on casualties
    armies(attackerIndex).size = armies(attackerIndex).size - result.casualties1
    armies(defenderIndex).size = armies(defenderIndex).size - result.casualties2
    
    ' Ensure strengths don't go negative
    IF armies(attackerIndex).size < 0 THEN armies(attackerIndex).size = 0
    IF armies(defenderIndex).size < 0 THEN armies(defenderIndex).size = 0
    
    ' Update experience (+1 for winner)
    IF armies(winner).exper < 10 THEN
        armies(winner).exper = armies(winner).exper + 1
    END IF
    
    ' Transfer city control if attacker wins
    IF winnerSide = attackerSide THEN
        CaptureCity cityIndex, attackerSide
    END IF
    
    ' Process retreat for loser
    IF armies(loser).size > 0 THEN
        ProcessRetreat loser, cityIndex
    ELSE
        ' Army destroyed
        armies(loser).size = 0
        armies(loser).name = ""
        armies(loser).loc = 0
    END IF
    
    ' Update battle statistics
    UpdateBattleStats winnerSide, result.casualties1, result.casualties2
    
    ' Record in history
    RecordBattleHistory armies(attackerIndex).name, armies(attackerIndex).size + result.casualties1, result.casualties1, _
                        armies(defenderIndex).name, armies(defenderIndex).size + result.casualties2, result.casualties2, _
                        armies(winner).name, cities(cityIndex).name
    
    ProcessTacticalResults% = winnerSide
END FUNCTION

FUNCTION ResolveStrategicCombat% (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER)
    ' Strategic-level combat resolution
    ' Used when tactical battles are disabled or force ratio > 3:1
    ' Delegates to combat.bas module
    
    DIM winner AS INTEGER
    
    ' Determine winner
    CALL DetermineCombatWinner(attackerIndex, defenderIndex, cityIndex, winner)
    
    ' Process result
    CALL ProcessCombatResult(attackerIndex, defenderIndex, cityIndex, winner)
    
    ResolveStrategicCombat% = winner
END FUNCTION

SUB ProcessRetreat (armyIndex AS INTEGER, fromCity AS INTEGER)
    ' Process retreat for losing army
    ' Finds adjacent friendly city or surrenders if none available
    
    DIM i AS INTEGER
    DIM bestCity AS INTEGER
    DIM bestValue AS INTEGER
    
    bestCity = 0
    bestValue = 0
    
    ' Find best retreat city
    FOR i = 1 TO 7
        DIM adjCity AS INTEGER
        adjCity = cityMatrix(fromCity, i)
        
        IF adjCity > 0 THEN
            ' Check if friendly city
            DIM side AS INTEGER
            IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START THEN
                side = 1
            ELSE
                side = 2
            END IF
            
            IF cities(adjCity).owner = side AND occupied(adjCity) = 0 THEN
                IF cities(adjCity).value > bestValue THEN
                    bestValue = cities(adjCity).value
                    bestCity = adjCity
                END IF
            END IF
        END IF
    NEXT i
    
    IF bestCity > 0 THEN
        ' Retreat to city
        armies(armyIndex).loc = bestCity
        PlaceArmy armyIndex
        COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " retreats to"; cities(bestCity).name
    ELSE
        ' Surrender
        COLOR 11: CALL clrbot: PRINT armies(armyIndex).name; " surrenders - no retreat path"
        armies(armyIndex).size = 0
        armies(armyIndex).name = ""
        armies(armyIndex).loc = 0
        AwardArmyCapture 3 - side ' Award to enemy
    END IF
END SUB

