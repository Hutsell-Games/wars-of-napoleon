'============================================================================
' Tactical Integration System
'============================================================================
' UNIQUE TO WON - Battle trigger logic and result processing
' Modern unified approach: Direct function calls instead of file I/O

' Note: battle_types.bas and game_types.bas are included in main.bas
' Note: army.bas, city.bas, campaign.bas, cohesion.bas are included in main.bas
' Note: tactical/battle.bas will be implemented in Phase 3

' Note: LaunchTacticalBattle is defined in tactical/battle.bas
' DECLARE statement added for clarity and consistency
DECLARE SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)

'============================================================================
' ShouldTriggerTacticalBattle - Determine if tactical battle should be triggered
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
' Returns:
'   INTEGER - 1 if tactical battle should be triggered, 0 otherwise
' Description:
'   Checks if conditions are met for tactical battle:
'   1. TACTICAL option enabled (from NWS.CFG)
'   2. Force ratio between 1:3 and 3:1 (inclusive)
'============================================================================
FUNCTION ShouldTriggerTacticalBattle% (attackerIndex AS INTEGER, defenderIndex AS INTEGER)
    
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
    
    ' Calculate ratio (attacker:defender) - division by zero already prevented above
    ratio = attackerStrength / defenderStrength
    
    ' Check if ratio is between 1:3 and 3:1
    IF ratio >= (1 / 3) AND ratio <= 3 THEN
        ShouldTriggerTacticalBattle% = 1 ' Trigger tactical battle
    END IF
END FUNCTION

'============================================================================
' ResolveCombat - Resolve strategic combat between armies
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
'   cityIndex (INTEGER) - Index of city where combat occurs (0 if no city)
' Returns:
'   INTEGER - Winner side (1=attacker, 2=defender)
' Description:
'   Resolves combat between two armies. May trigger tactical battle if conditions
'   are met. Updates army strengths, captures cities, and awards victory points.
' Side Effects:
'   - May launch tactical battle (if ShouldTriggerTacticalBattle returns 1)
'   - Updates army strengths based on combat results
'   - May capture city if attacker wins
'   - Awards victory points to winner
'============================================================================
FUNCTION ResolveCombat% (attackerIndex AS INTEGER, defenderIndex AS INTEGER, cityIndex AS INTEGER)
    ' May trigger tactical battle or use strategic resolution
    
    DIM attackerSide AS INTEGER
    DIM defenderSide AS INTEGER
    DIM winner AS INTEGER
    DIM battleData AS BattleData
    DIM battleResult AS BattleResult
    
    ' Determine sides using helper function
    attackerSide = GetArmySide%(attackerIndex)
    defenderSide = GetArmySide%(defenderIndex)
    
    ' Validate sides
    IF attackerSide = 0 OR defenderSide = 0 THEN
        CALL HandleValidationError("Invalid army indices in ResolveCombat")
        ' Return defender side as fallback (defender wins by default on error)
        ResolveCombat% = defenderSide
        IF defenderSide = 0 THEN ResolveCombat% = 2 ' Default to Allied if both invalid
        EXIT FUNCTION
    END IF
    
    ' Check if tactical battle should be triggered
    IF ShouldTriggerTacticalBattle%(attackerIndex, defenderIndex) = 1 THEN
        ' ============================================================
        ' PREPARE BATTLE DATA FOR TACTICAL LAYER
        ' ============================================================
        ' Convert strategic game state to tactical battle parameters
        ' This is the critical data transformation between layers
        
        ' Scenario and game state
        battleData.scenario = scenario$
        battleData.side = gameState.side ' Current player side (1=French, 2=Allied)
        battleData.sideID1 = attackerSide ' Side identifier for attacker (1 or 2)
        battleData.sideID2 = defenderSide ' Side identifier for defender (1 or 2)
        
        ' Commander information
        battleData.commander1 = armies(attackerIndex).name
        battleData.commander2 = armies(defenderIndex).name
        
        ' Army strengths - CONVERSION: Strategic uses raw size, tactical uses hundreds
        ' Example: 5000 men -> 50 (hundreds) for tactical battle
        battleData.vp1 = armies(attackerIndex).size \ 100
        battleData.vp2 = armies(defenderIndex).size \ 100
        
        ' Leadership and experience ratings (1-10 scale)
        battleData.leadbase1 = armies(attackerIndex).lead
        battleData.leadbase2 = armies(defenderIndex).lead
        battleData.expbase1 = armies(attackerIndex).exper
        battleData.expbase2 = armies(defenderIndex).exper
        
        ' Battle configuration
        battleData.difficult = config_balance ' Difficulty level from config
        battleData.fort = cities(cityIndex).fort ' Fortification level (0-5)
        battleData.quiet = config_sound ' Sound enabled/disabled
        
        ' ============================================================
        ' APPLY STRATEGIC MODIFIERS
        ' ============================================================
        ' Supply status affects tactical battle strength
        ' Out-of-supply armies fight at 50% effectiveness
        IF IsOutOfSupply%(attackerIndex) = 1 THEN
            battleData.vp1 = battleData.vp1 \ 2 ' 50% strength penalty
        END IF
        IF IsOutOfSupply%(defenderIndex) = 1 THEN
            battleData.vp2 = battleData.vp2 \ 2 ' 50% strength penalty
        END IF
        
        ' ============================================================
        ' LAUNCH TACTICAL BATTLE
        ' ============================================================
        ' This is the critical integration point: strategic -> tactical
        ' The tactical battle will:
        '   1. Initialize battle map and units
        '   2. Run tactical battle loop
        '   3. Check victory conditions
        '   4. Calculate casualties
        '   5. Return results in battleResult structure
        ' NOTE: Avoid ON ERROR GOTO + in-procedure labels inside FUNCTIONs.
        ' QB64/QB64-PE can report "Common label within a SUB/FUNCTION" for that pattern.
        CALL LaunchTacticalBattle(battleData, battleResult)
        
        ' ============================================================
        ' PROCESS TACTICAL BATTLE RESULTS
        ' ============================================================
        ' Validate battle result - check if battle completed successfully
        ' battleResult.winner = 0 indicates error/failure
        IF battleResult.winner = 0 THEN
            ' Battle initialization failed or error occurred
            ' Fall back to strategic combat resolution (no tactical battle)
            CALL ShowStatusWarning("Tactical battle failed, using strategic resolution")
            winner = ResolveStrategicCombat%(attackerIndex, defenderIndex, cityIndex)
        ELSE
            ' Process results from successful tactical battle
            ' This updates army strengths, city control, experience, etc.
            winner = ProcessTacticalResults%(battleResult, attackerIndex, defenderIndex, cityIndex, attackerSide, defenderSide)
        END IF
    ELSE
        ' Strategic combat resolution
        winner = ResolveStrategicCombat%(attackerIndex, defenderIndex, cityIndex)
    END IF
    
    ResolveCombat% = winner
    EXIT FUNCTION
END FUNCTION

'============================================================================
' ProcessTacticalResults - Process results from tactical battle
'============================================================================
' This function bridges tactical battle results back to strategic layer
' Parameters:
'   result (BattleResult) - Results from tactical battle (winner, casualties)
'   attackerIndex, defenderIndex (INTEGER) - Strategic army indices
'   cityIndex (INTEGER) - City where battle occurred (0 if no city)
'   attackerSide, defenderSide (INTEGER) - Side identifiers (1 or 2)
' Returns:
'   INTEGER - Strategic army index of winner
' Description:
'   Converts tactical battle results into strategic game state updates:
'   - Applies casualties to army strengths
'   - Updates army experience (winner gains +1)
'   - Transfers city control if attacker wins
'   - Processes retreat for losing army
'   - Handles army destruction if strength reaches 0
'============================================================================
FUNCTION ProcessTacticalResults% (result AS BattleResult, attackerIndex AS INTEGER, defenderIndex AS INTEGER, _
                                  cityIndex AS INTEGER, attackerSide AS INTEGER, defenderSide AS INTEGER)
    
    DIM winner AS INTEGER
    DIM loser AS INTEGER
    DIM winnerSide AS INTEGER
    DIM loserSide AS INTEGER
    
    ' ============================================================
    ' DETERMINE WINNER AND LOSER
    ' ============================================================
    ' result.winner contains side ID (1 or 2), convert to army index
    ' This mapping is critical: tactical layer uses side IDs (1/2),
    ' but strategic layer needs army indices to update the correct army
    winner = result.winner
    IF winner = attackerSide THEN
        ' Attacker won - map side ID back to strategic army index
        winnerSide = attackerSide
        loserSide = defenderSide
        winner = attackerIndex ' Convert to strategic army index
        loser = defenderIndex
    ELSE
        ' Defender won - map side ID back to strategic army index
        winnerSide = defenderSide
        loserSide = attackerSide
        winner = defenderIndex ' Convert to strategic army index
        loser = attackerIndex
    END IF
    
    ' ============================================================
    ' APPLY CASUALTIES
    ' ============================================================
    ' Casualties are in scaled units (hundreds), same as strategic size
    ' Example: 50 casualties (hundreds) = 5000 men lost
    ' The tactical battle returns casualties in the same units as strategic
    ' army sizes, so we can directly subtract them
    armies(attackerIndex).size = armies(attackerIndex).size - result.casualties1
    armies(defenderIndex).size = armies(defenderIndex).size - result.casualties2
    
    ' Ensure strengths don't go negative (safety check)
    ' This prevents invalid states if casualty calculation had errors
    IF armies(attackerIndex).size < 0 THEN armies(attackerIndex).size = 0
    IF armies(defenderIndex).size < 0 THEN armies(defenderIndex).size = 0
    
    ' ============================================================
    ' UPDATE EXPERIENCE
    ' ============================================================
    ' Winner gains experience (max 10)
    ' Experience increases combat effectiveness, so winners get stronger
    ' over time while losers don't benefit from defeats
    IF armies(winner).exper < 10 THEN
        armies(winner).exper = armies(winner).exper + 1
    END IF
    
    ' ============================================================
    ' CITY CONTROL TRANSFER
    ' ============================================================
    ' If attacker wins, they capture the city
    ' Note: CaptureCity is defined in src/strategic/city.bas (line 160)
    ' Only attackers can capture cities; defenders just hold them
    ' cityIndex > 0 check ensures we're at a city, not open terrain
    IF winnerSide = attackerSide AND cityIndex > 0 THEN
        CaptureCity cityIndex, attackerSide
    END IF
    
    ' ============================================================
    ' RETREAT PROCESSING
    ' ============================================================
    ' Loser must retreat if army still exists
    ' If army is destroyed (size = 0), mark commander available instead
    ' This handles two scenarios:
    '   1. Army survives but must retreat (ProcessRetreat finds friendly city)
    '   2. Army destroyed (commander freed, army cleared)
    IF armies(loser).size > 0 THEN
        ' Army survives - attempt retreat to adjacent friendly city
        ' ProcessRetreat will find best retreat path or surrender if none
        ProcessRetreat loser, cityIndex
    ELSE
        ' Army destroyed - mark commander as available
        ' This allows the commander to be reassigned to a new army
        CALL MarkCommanderAvailable(loser)
        armies(loser).size = 0
        armies(loser).name = ""
        armies(loser).loc = 0
    END IF
    
    ' Update battle statistics
    ' Note: UpdateBattleStats is defined in src/strategic/reports.bas (line 322)
    ' Tracks overall battle performance for both sides
    UpdateBattleStats winnerSide, result.casualties1, result.casualties2
    
    ' Record in history
    ' Note: RecordBattleHistory is defined in src/strategic/reports.bas (line 300)
    ' Records battle details for end-game reports and replay
    ' Note: We add casualties back to size to get pre-battle strength for display
    RecordBattleHistory armies(attackerIndex).name, armies(attackerIndex).size + result.casualties1, result.casualties1, _
                        armies(defenderIndex).name, armies(defenderIndex).size + result.casualties2, result.casualties2, _
                        armies(winner).name, cities(cityIndex).name
    
    ProcessTacticalResults% = winnerSide
END FUNCTION

'============================================================================
' ResolveStrategicCombat - Resolve combat using strategic-level calculations
'============================================================================
' Parameters:
'   attackerIndex (INTEGER) - Index of attacking army
'   defenderIndex (INTEGER) - Index of defending army
'   cityIndex (INTEGER) - Index of city where combat occurs (0 if no city)
' Returns:
'   INTEGER - Winner side (1=attacker, 2=defender)
' Description:
'   Resolves combat using strategic-level calculations when tactical battles
'   are disabled or when force ratio exceeds 3:1. This provides a faster
'   resolution method that doesn't require launching the tactical battle system.
'   Delegates actual combat calculations to the combat.bas module.
' Side Effects:
'   - Updates army strengths based on combat results
'   - May capture city if attacker wins
'   - Awards victory points to winner
'============================================================================
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

'============================================================================
' ProcessRetreat - Process retreat for losing army after battle
'============================================================================
' Parameters:
'   armyIndex (INTEGER) - Index of army that must retreat
'   fromCity (INTEGER) - City index where battle occurred (starting retreat point)
' Description:
'   Handles retreat logic for a losing army after combat. Searches for an
'   adjacent friendly city to retreat to. If no friendly city is available,
'   the army surrenders and is destroyed. The commander is marked as
'   available for reassignment if the army is destroyed.
' Side Effects:
'   - Moves army to retreat city if found
'   - Destroys army if no retreat path available
'   - Marks commander as available if army destroyed
'   - Awards army capture victory points to enemy if army surrenders
'============================================================================
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
            side = GetArmySide%(armyIndex)
            
            IF side > 0 AND cities(adjCity).owner = side AND occupied(adjCity) = 0 THEN
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
        CALL ShowStatusMessage(armies(armyIndex).name + " retreats to " + cities(bestCity).name, 11)
    ELSE
        ' Surrender - mark commander as available
        CALL MarkCommanderAvailable(armyIndex)
        CALL ShowStatusMessage(armies(armyIndex).name + " surrenders - no retreat path", 11)
        armies(armyIndex).size = 0
        armies(armyIndex).name = ""
        armies(armyIndex).loc = 0
        ' Note: AwardArmyCapture is defined in src/strategic/victory.bas (line 135)
        AwardArmyCapture 3 - side ' Award to enemy
    END IF
END SUB

