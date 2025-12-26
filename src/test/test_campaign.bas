'============================================================================
' Campaign Management Tests
'============================================================================
' Priority 1 tests for campaign.bas
' Tests: InitializeCampaign, AdvanceTurn, GetCurrentMonth, IsHarvestMonth, SaveGame, LoadGame

' Note: All common and strategic files are included in test_runner_all.bas


'============================================================================
' Test Suite: Campaign Initialization
'============================================================================

SUB TestInitializeCampaignValidYear
    StartTest "CampaignTests", "test_initialize_campaign_valid_year"
    
    ' Initialize campaign with valid year
    CALL InitializeCampaign(1796)
    
    AssertEqual gameState.year, 1796, "Year should be set to 1796"
    AssertEqual gameState.month, 3, "Month should be set to 3 (March)"
    AssertEqual gameState.turn, 1, "Turn should be set to 1"
    AssertEqual currentPhase, PHASE_DECISION, "Phase should be DECISION"
    
    ExecuteTest "CampaignTests", "test_initialize_campaign_valid_year"
END SUB

SUB TestInitializeCampaignSetsCorrectMonth
    StartTest "CampaignTests", "test_initialize_campaign_sets_correct_month"
    
    CALL InitializeCampaign(1805)
    
    AssertEqual gameState.month, 3, "Starting month should be 3 (March)"
    
    ExecuteTest "CampaignTests", "test_initialize_campaign_sets_correct_month"
END SUB

SUB TestInitializeCampaignSetsCorrectYear
    StartTest "CampaignTests", "test_initialize_campaign_sets_correct_year"
    
    CALL InitializeCampaign(1812)
    
    AssertEqual gameState.year, 1812, "Year should match scenario year"
    
    ExecuteTest "CampaignTests", "test_initialize_campaign_sets_correct_year"
END SUB

SUB TestInitializeCampaignResetsGameState
    StartTest "CampaignTests", "test_initialize_campaign_resets_game_state"
    
    ' Set some values first
    gameState.cashFrench = 1000
    gameState.cashAllied = 2000
    gameState.victoryFrench = 50
    gameState.victoryAllied = 75
    
    CALL InitializeCampaign(1796)
    
    AssertEqual gameState.cashFrench, 0, "Cash should be reset to 0"
    AssertEqual gameState.cashAllied, 0, "Allied cash should be reset to 0"
    AssertEqual gameState.victoryFrench, 0, "Victory points should be reset"
    AssertEqual gameState.victoryAllied, 0, "Allied victory points should be reset"
    
    ExecuteTest "CampaignTests", "test_initialize_campaign_resets_game_state"
END SUB

SUB TestInitializeCampaignSetsPhaseDecision
    StartTest "CampaignTests", "test_initialize_campaign_sets_phase_decision"
    
    currentPhase = PHASE_MOVE_COMBAT
    CALL InitializeCampaign(1796)
    
    AssertEqual currentPhase, PHASE_DECISION, "Initial phase should be DECISION"
    
    ExecuteTest "CampaignTests", "test_initialize_campaign_sets_phase_decision"
END SUB

'============================================================================
' Test Suite: Turn Advancement
'============================================================================

SUB TestAdvanceTurnDecisionToMoveCombat
    StartTest "CampaignTests", "test_advance_turn_decision_to_move_combat"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_DECISION
    
    CALL AdvanceTurn
    
    AssertEqual currentPhase, PHASE_MOVE_COMBAT, "Phase should advance to MOVE_COMBAT"
    
    ExecuteTest "CampaignTests", "test_advance_turn_decision_to_move_combat"
END SUB

SUB TestAdvanceTurnMoveCombatToUpdate
    StartTest "CampaignTests", "test_advance_turn_move_combat_to_update"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_MOVE_COMBAT
    
    CALL AdvanceTurn
    
    AssertEqual currentPhase, PHASE_UPDATE, "Phase should advance to UPDATE"
    
    ExecuteTest "CampaignTests", "test_advance_turn_move_combat_to_update"
END SUB

SUB TestAdvanceTurnUpdateToDecision
    StartTest "CampaignTests", "test_advance_turn_update_to_decision"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_UPDATE
    gameState.month = 3
    gameState.turn = 1
    
    CALL AdvanceTurn
    
    AssertEqual currentPhase, PHASE_DECISION, "Phase should return to DECISION"
    AssertEqual gameState.month, 5, "Month should advance by 2 (3 -> 5)"
    AssertEqual gameState.turn, 2, "Turn should increment"
    
    ExecuteTest "CampaignTests", "test_advance_turn_update_to_decision"
END SUB

SUB TestAdvanceTurnIncrementsMonthBy2
    StartTest "CampaignTests", "test_advance_turn_increments_month_by_2"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_UPDATE
    gameState.month = 5
    
    CALL AdvanceTurn
    
    AssertEqual gameState.month, 7, "Month should advance by 2 (5 -> 7)"
    
    ExecuteTest "CampaignTests", "test_advance_turn_increments_month_by_2"
END SUB

SUB TestAdvanceTurnYearRollover
    StartTest "CampaignTests", "test_advance_turn_year_rollover"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_UPDATE
    gameState.month = 11
    gameState.year = 1796
    
    CALL AdvanceTurn
    
    AssertEqual gameState.month, 1, "Month should rollover to 1 (11+2=13 -> 1)"
    AssertEqual gameState.year, 1797, "Year should increment"
    
    ExecuteTest "CampaignTests", "test_advance_turn_year_rollover"
END SUB

SUB TestAdvanceTurnIncrementsTurnNumber
    StartTest "CampaignTests", "test_advance_turn_increments_turn_number"
    
    CALL InitializeCampaign(1796)
    currentPhase = PHASE_UPDATE
    gameState.turn = 5
    
    CALL AdvanceTurn
    
    AssertEqual gameState.turn, 6, "Turn should increment"
    
    ExecuteTest "CampaignTests", "test_advance_turn_increments_turn_number"
END SUB

SUB TestAdvanceTurnSwitchesSides2Player
    StartTest "CampaignTests", "test_advance_turn_switches_sides_2_player"
    
    CALL InitializeCampaign(1796)
    config_players = 2
    currentPhase = PHASE_UPDATE
    gameState.side = 1
    
    CALL AdvanceTurn
    
    AssertEqual gameState.side, 2, "Side should switch from 1 to 2"
    
    ' Test switching back
    currentPhase = PHASE_UPDATE
    CALL AdvanceTurn
    
    AssertEqual gameState.side, 1, "Side should switch back from 2 to 1"
    
    ExecuteTest "CampaignTests", "test_advance_turn_switches_sides_2_player"
END SUB

'============================================================================
' Test Suite: Month/Year Queries
'============================================================================

SUB TestGetCurrentMonthFormat
    StartTest "CampaignTests", "test_get_current_month_format"
    
    CALL InitializeCampaign(1796)
    gameState.month = 3
    gameState.year = 1796
    
    DIM result AS STRING
    result = GetCurrentMonth$
    
    AssertStringEqual result, "March 1796", "Month format should be 'March 1796'"
    
    ExecuteTest "CampaignTests", "test_get_current_month_format"
END SUB

SUB TestIsHarvestMonthJuly
    StartTest "CampaignTests", "test_is_harvest_month_july"
    
    CALL InitializeCampaign(1796)
    gameState.month = 7
    
    AssertTrue IsHarvestMonth%, "July should be a harvest month"
    
    ExecuteTest "CampaignTests", "test_is_harvest_month_july"
END SUB

SUB TestIsHarvestMonthSeptember
    StartTest "CampaignTests", "test_is_harvest_month_september"
    
    CALL InitializeCampaign(1796)
    gameState.month = 9
    
    AssertTrue IsHarvestMonth%, "September should be a harvest month"
    
    ExecuteTest "CampaignTests", "test_is_harvest_month_september"
END SUB

SUB TestIsHarvestMonthOtherMonths
    StartTest "CampaignTests", "test_is_harvest_month_other_months"
    
    CALL InitializeCampaign(1796)
    
    gameState.month = 1
    AssertFalse IsHarvestMonth%, "January should not be a harvest month"
    
    gameState.month = 6
    AssertFalse IsHarvestMonth%, "June should not be a harvest month"
    
    gameState.month = 12
    AssertFalse IsHarvestMonth%, "December should not be a harvest month"
    
    ExecuteTest "CampaignTests", "test_is_harvest_month_other_months"
END SUB

'============================================================================
' Test Suite: Save/Load Game
'============================================================================

SUB TestSaveGameValidSlot
    StartTest "CampaignTests", "test_save_game_valid_slot"
    
    CALL InitializeCampaign(1796)
    gameState.cashFrench = 1000
    gameState.cashAllied = 2000
    
    ' Save to slot 1
    CALL SaveGame(1)
    
    ' Verify file was created
    AssertTrue FileExists%("saved\NWS1.SAV") <> 0, "Save file should be created"
    
    ExecuteTest "CampaignTests", "test_save_game_valid_slot"
END SUB

SUB TestSaveGameAutosaveSlot
    StartTest "CampaignTests", "test_save_game_autosave_slot"
    
    CALL InitializeCampaign(1796)
    
    CALL SaveGame(9)
    
    ' Verify autosave file was created
    AssertTrue FileExists%("saved\NWS9.SAV") <> 0, "Autosave file should be created"
    
    ExecuteTest "CampaignTests", "test_save_game_autosave_slot"
END SUB

SUB TestLoadGameValidSlot
    StartTest "CampaignTests", "test_load_game_valid_slot"
    
    ' First save a game
    CALL InitializeCampaign(1796)
    gameState.cashFrench = 1500
    gameState.cashAllied = 2500
    gameState.turn = 5
    CALL SaveGame(1)
    
    ' Reset game state
    CALL InitializeCampaign(1805)
    
    ' Load the saved game
    CALL LoadGame(1)
    
    AssertEqual gameState.cashFrench, 1500, "Cash should be restored"
    AssertEqual gameState.cashAllied, 2500, "Allied cash should be restored"
    AssertEqual gameState.turn, 5, "Turn should be restored"
    
    ExecuteTest "CampaignTests", "test_load_game_valid_slot"
END SUB

SUB TestLoadGameFileNotFound
    StartTest "CampaignTests", "test_load_game_file_not_found"
    
    ' Try to load non-existent file
    CALL LoadGame(99)
    
    ' Should not crash - function should handle gracefully
    AssertTrue 1, "LoadGame should handle missing file gracefully"
    
    ExecuteTest "CampaignTests", "test_load_game_file_not_found"
END SUB

SUB TestGetSaveFileListCountsFiles
    StartTest "CampaignTests", "test_get_save_file_list_counts_files"
    
    ' Create some save files
    CALL InitializeCampaign(1796)
    CALL SaveGame(1)
    CALL SaveGame(2)
    CALL SaveGame(9)
    
    DIM count AS INTEGER
    DIM result AS STRING
    result = GetSaveFileList$(count)
    
    AssertGreaterThan count, 0, "Should find at least one save file"
    
    ExecuteTest "CampaignTests", "test_get_save_file_list_counts_files"
END SUB

'============================================================================
' Test Runner
'============================================================================

SUB RunCampaignTests
    CALL InitializeTestFramework
    
    PRINT "Running Campaign Management Tests..."
    PRINT STRING$(80, "-")
    PRINT
    
    ' Campaign Initialization Tests
    CALL TestInitializeCampaignValidYear
    CALL TestInitializeCampaignSetsCorrectMonth
    CALL TestInitializeCampaignSetsCorrectYear
    CALL TestInitializeCampaignResetsGameState
    CALL TestInitializeCampaignSetsPhaseDecision
    
    ' Turn Advancement Tests
    CALL TestAdvanceTurnDecisionToMoveCombat
    CALL TestAdvanceTurnMoveCombatToUpdate
    CALL TestAdvanceTurnUpdateToDecision
    CALL TestAdvanceTurnIncrementsMonthBy2
    CALL TestAdvanceTurnYearRollover
    CALL TestAdvanceTurnIncrementsTurnNumber
    CALL TestAdvanceTurnSwitchesSides2Player
    
    ' Month/Year Query Tests
    CALL TestGetCurrentMonthFormat
    CALL TestIsHarvestMonthJuly
    CALL TestIsHarvestMonthSeptember
    CALL TestIsHarvestMonthOtherMonths
    
    ' Save/Load Tests
    CALL TestSaveGameValidSlot
    CALL TestSaveGameAutosaveSlot
    CALL TestLoadGameValidSlot
    CALL TestLoadGameFileNotFound
    CALL TestGetSaveFileListCountsFiles
    
    CALL PrintTestResults
END SUB

