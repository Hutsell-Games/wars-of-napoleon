# Critical Path Unit Tests

This document lists all critical path unit tests that should be created to ensure core game functionality works correctly. These tests cover the essential systems that must function properly for the game to be playable.

## Test Organization

Tests are organized by module/system, following the structure of the codebase. Each test should:
- Use the QB64 test framework (see `TESTING_FRAMEWORK.md`)
- Be independent (no dependencies on other tests)
- Test both success and failure cases
- Include edge cases and boundary conditions
- Use descriptive test names

---

## 1. Campaign Management (`campaign.bas`)

### 1.1 Campaign Initialization
- [ ] `test_initialize_campaign_valid_year` - Initialize campaign with valid scenario year
- [ ] `test_initialize_campaign_sets_correct_month` - Verify starting month is set correctly (March)
- [ ] `test_initialize_campaign_sets_correct_year` - Verify starting year matches scenario
- [ ] `test_initialize_campaign_resets_game_state` - Verify all game state values are reset
- [ ] `test_initialize_campaign_sets_phase_decision` - Verify initial phase is DECISION

### 1.2 Turn Advancement
- [ ] `test_advance_turn_decision_to_move_combat` - Advance from DECISION to MOVE_COMBAT phase
- [ ] `test_advance_turn_move_combat_to_update` - Advance from MOVE_COMBAT to UPDATE phase
- [ ] `test_advance_turn_update_to_decision` - Advance from UPDATE back to DECISION
- [ ] `test_advance_turn_increments_month_by_2` - Verify month advances by 2 months
- [ ] `test_advance_turn_year_rollover` - Verify year increments when month exceeds 12
- [ ] `test_advance_turn_increments_turn_number` - Verify turn counter increments
- [ ] `test_advance_turn_switches_sides_2_player` - Verify side switches in 2-player mode
- [ ] `test_advance_turn_autosave_on_decision_complete` - Verify autosave triggers at end of DECISION phase

### 1.3 Month/Year Queries
- [ ] `test_get_current_month_format` - Verify month name format (e.g., "March 1796")
- [ ] `test_is_harvest_month_july` - Verify July is identified as harvest month
- [ ] `test_is_harvest_month_september` - Verify September is identified as harvest month
- [ ] `test_is_harvest_month_other_months` - Verify other months are not harvest months

### 1.4 Save Game
- [ ] `test_save_game_valid_slot` - Save game to valid slot (1-8)
- [ ] `test_save_game_autosave_slot` - Save game to autosave slot (9)
- [ ] `test_save_game_writes_all_game_state` - Verify all game state is written
- [ ] `test_save_game_writes_army_data` - Verify all army data is written
- [ ] `test_save_game_writes_city_data` - Verify all city data is written
- [ ] `test_save_game_writes_fleet_data` - Verify fleet data is written
- [ ] `test_save_game_writes_occupation_data` - Verify occupation array is written
- [ ] `test_save_game_writes_battle_stats` - Verify battle statistics are written

### 1.5 Load Game
- [ ] `test_load_game_valid_slot` - Load game from valid slot
- [ ] `test_load_game_autosave_slot` - Load game from autosave slot
- [ ] `test_load_game_file_not_found` - Handle missing save file gracefully
- [ ] `test_load_game_restores_game_state` - Verify all game state is restored
- [ ] `test_load_game_restores_army_data` - Verify all army data is restored
- [ ] `test_load_game_restores_city_data` - Verify all city data is restored
- [ ] `test_load_game_restores_phase` - Verify current phase is restored
- [ ] `test_load_game_places_armies` - Verify armies are placed on map after load

### 1.6 Save File List
- [ ] `test_get_save_file_list_counts_files` - Verify correct count of save files
- [ ] `test_get_save_file_list_returns_first_file` - Verify first filename is returned
- [ ] `test_get_save_file_list_no_files` - Handle case when no save files exist

---

## 2. Army Management (`army.bas`)

### 2.1 Army Initialization
- [ ] `test_initialize_armies_clears_all_armies` - Verify all armies are reset to empty
- [ ] `test_initialize_armies_clears_occupation` - Verify occupation array is cleared

### 2.2 Army Recruitment
- [ ] `test_recruit_army_french_side` - Recruit army for French side
- [ ] `test_recruit_army_allied_side` - Recruit army for Allied side
- [ ] `test_recruit_army_assigns_commander` - Verify commander name is assigned
- [ ] `test_recruit_army_assigns_rating` - Verify commander rating is set
- [ ] `test_recruit_army_sets_initial_supply` - Verify initial supply is set (5)
- [ ] `test_recruit_army_sets_move_restriction` - Verify army cannot move this turn (-1)
- [ ] `test_recruit_army_sets_nationality` - Verify nationality matches city
- [ ] `test_recruit_army_occupies_city` - Verify city occupation is set
- [ ] `test_recruit_army_max_armies_reached` - Handle case when all army slots are full
- [ ] `test_recruit_army_finds_empty_slot` - Verify finds first available slot

### 2.3 Army Movement
- [ ] `test_move_army_sets_destination` - Verify move order is set
- [ ] `test_move_army_empty_army` - Handle empty army gracefully
- [ ] `test_move_army_restricted_turn` - Prevent movement when move = -1
- [ ] `test_move_army_valid_destination` - Verify valid destination is accepted

### 2.4 Army Combining
- [ ] `test_combine_armies_minimum_two` - Require at least 2 armies to combine
- [ ] `test_combine_armies_sums_sizes` - Verify total size is calculated correctly
- [ ] `test_combine_armies_averages_attributes` - Verify leadership/experience/supply are averaged
- [ ] `test_combine_armies_best_commander` - Verify best commander takes leadership
- [ ] `test_combine_armies_max_size_limit` - Prevent combining if total exceeds 400,000
- [ ] `test_combine_armies_clears_other_armies` - Verify other armies are cleared
- [ ] `test_combine_armies_marks_commanders_available` - Verify commanders are marked available
- [ ] `test_combine_armies_same_side_only` - Only combine armies of same side

### 2.5 Commander Relief
- [ ] `test_relieve_commander_assigns_new_commander` - Verify new commander is assigned
- [ ] `test_relieve_commander_applies_penalty` - Verify -1 penalty to leadership/experience
- [ ] `test_relieve_commander_minimum_values` - Verify values don't go below minimum (1 for lead, 0 for exper)
- [ ] `test_relieve_commander_empty_army` - Handle empty army gracefully

### 2.6 Commander Availability
- [ ] `test_mark_commander_available_on_destroy` - Mark commander available when army destroyed
- [ ] `test_mark_commander_available_finds_by_name` - Verify commander found by army name
- [ ] `test_mark_commander_available_invalid_army` - Handle invalid army index
- [ ] `test_mark_commander_available_no_commander` - Handle army with no commander name

### 2.7 Army Strength
- [ ] `test_get_army_strength_french_side` - Calculate total strength for French
- [ ] `test_get_army_strength_allied_side` - Calculate total strength for Allies
- [ ] `test_get_army_strength_sums_all_armies` - Verify all armies are summed
- [ ] `test_get_army_strength_excludes_empty` - Verify empty armies are excluded

### 2.8 Army Placement
- [ ] `test_place_army_updates_occupation` - Verify occupation array is updated
- [ ] `test_place_army_valid_location` - Verify valid city location is set
- [ ] `test_place_army_zero_location` - Handle zero location (no placement)

### 2.9 City Occupation
- [ ] `test_occupy_city_finds_best_army` - Verify highest strength army occupies
- [ ] `test_occupy_city_no_armies` - Handle city with no armies
- [ ] `test_occupy_city_multiple_armies` - Verify correct army selected when multiple present

---

## 3. City Management (`city.bas`)

### 3.1 City Initialization
- [ ] `test_initialize_cities_clears_all_cities` - Verify all cities reset to empty
- [ ] `test_initialize_cities_clears_city_matrix` - Verify cityMatrix is cleared

### 3.2 City Data Loading
- [ ] `test_load_city_data_valid_file` - Load city data from valid scenario file
- [ ] `test_load_city_data_file_not_found` - Handle missing file gracefully
- [ ] `test_load_city_data_sets_city_properties` - Verify name, coordinates, value are set
- [ ] `test_load_city_data_sets_owner` - Verify ownership is set correctly
- [ ] `test_load_city_data_sets_fortification` - Verify fortification level is set
- [ ] `test_load_city_data_sets_nationality` - Verify nationality is set
- [ ] `test_load_city_data_sets_connections` - Verify city connections are stored
- [ ] `test_load_city_data_sets_port_flag` - Verify port indicator is set
- [ ] `test_load_city_data_updates_game_state` - Verify control/income counters updated
- [ ] `test_load_city_data_max_cities_limit` - Respect MAX_CITIES limit

### 3.3 City Capture
- [ ] `test_capture_city_changes_owner` - Verify ownership changes
- [ ] `test_capture_city_updates_old_owner_stats` - Verify old owner loses control/income
- [ ] `test_capture_city_updates_new_owner_stats` - Verify new owner gains control/income
- [ ] `test_capture_city_awards_victory_points` - Verify victory points are awarded
- [ ] `test_capture_city_objective_bonus` - Verify objective city bonus (+100 VP)
- [ ] `test_capture_city_reduces_fortification` - Verify fortification reduced by 1 level
- [ ] `test_capture_city_minimum_fortification` - Verify fortification doesn't go below FORT_NONE

### 3.4 City Fortification
- [ ] `test_fortify_city_increases_level` - Verify fortification level increases
- [ ] `test_fortify_city_maximum_level` - Prevent fortification beyond FORT_PLUS_PLUS
- [ ] `test_fortify_city_deducts_cost` - Verify 200 money units are deducted
- [ ] `test_fortify_city_insufficient_funds` - Handle insufficient funds gracefully
- [ ] `test_fortify_city_requires_friendly_army` - Require friendly army in city

### 3.5 City Income
- [ ] `test_get_city_income_french_side` - Calculate income for French side
- [ ] `test_get_city_income_allied_side` - Calculate income for Allied side
- [ ] `test_get_city_income_sums_all_cities` - Verify all owned cities are summed
- [ ] `test_get_city_income_excludes_other_side` - Verify other side's cities excluded

### 3.6 City Victory Points
- [ ] `test_get_city_victory_points_french_side` - Calculate VP for French side
- [ ] `test_get_city_victory_points_allied_side` - Calculate VP for Allied side
- [ ] `test_get_city_victory_points_includes_objective_bonus` - Verify objective bonus included
- [ ] `test_get_city_victory_points_sums_all_cities` - Verify all owned cities are summed

### 3.7 City Nationality
- [ ] `test_get_city_nationality_returns_value` - Verify nationality is returned correctly
- [ ] `test_get_city_nationality_valid_index` - Handle valid city index

### 3.8 Fortification Destruction
- [ ] `test_raze_fortifications_sets_to_none` - Verify fortification set to FORT_NONE
- [ ] `test_raze_fortifications_displays_message` - Verify destruction message shown

---

## 4. Combat Resolution (`combat.bas`)

### 4.1 Combat Strength Calculation
- [ ] `test_calculate_combat_strength_base_size` - Verify base strength is army size
- [ ] `test_calculate_combat_strength_leadership_modifier` - Verify leadership affects strength
- [ ] `test_calculate_combat_strength_experience_modifier` - Verify experience affects strength
- [ ] `test_calculate_combat_strength_supply_penalty` - Verify out-of-supply reduces to 50%
- [ ] `test_calculate_combat_strength_cohesion_penalty` - Verify cohesion penalty applied
- [ ] `test_calculate_combat_strength_all_modifiers` - Verify all modifiers combine correctly

### 4.2 Defender Bonus
- [ ] `test_calculate_defender_bonus_no_fortification` - Verify no bonus for unfortified city
- [ ] `test_calculate_defender_bonus_fort_plus` - Verify 50% bonus for FORT_PLUS
- [ ] `test_calculate_defender_bonus_fort_plus_plus` - Verify 100% bonus for FORT_PLUS_PLUS
- [ ] `test_calculate_defender_bonus_realism_mode` - Verify realism mode defender advantage

### 4.3 Combat Casualties
- [ ] `test_apply_combat_casualties_attacker_wins` - Verify 10% attacker, 15% defender casualties
- [ ] `test_apply_combat_casualties_defender_wins` - Verify 15% attacker, 10% defender casualties
- [ ] `test_apply_combat_casualties_non_negative` - Verify sizes don't go below 0
- [ ] `test_apply_combat_casualties_updates_stats` - Verify battle statistics updated

### 4.4 Combat Winner Determination
- [ ] `test_determine_combat_winner_attacker_wins` - Verify attacker wins when stronger
- [ ] `test_determine_combat_winner_defender_wins` - Verify defender wins when stronger
- [ ] `test_determine_combat_winner_randomness` - Verify randomness factor (80-120%)
- [ ] `test_determine_combat_winner_applies_defender_bonus` - Verify defender bonus applied
- [ ] `test_determine_combat_winner_uses_effective_strength` - Verify effective strength used

### 4.5 Combat Result Processing
- [ ] `test_process_combat_result_applies_casualties` - Verify casualties are applied
- [ ] `test_process_combat_result_awards_experience` - Verify winner gains experience
- [ ] `test_process_combat_result_captures_city_attacker_wins` - Verify city captured when attacker wins
- [ ] `test_process_combat_result_cancels_move_defender_wins` - Verify move cancelled when defender wins
- [ ] `test_process_combat_result_processes_retreat` - Verify retreat is processed
- [ ] `test_process_combat_result_destroys_army_zero_size` - Verify army destroyed when size = 0
- [ ] `test_process_combat_result_marks_commander_available` - Verify commander marked available on destruction
- [ ] `test_process_combat_result_awards_battle_victory` - Verify battle victory points awarded
- [ ] `test_process_combat_result_records_history` - Verify battle history recorded

---

## 5. Economy System (`economy.bas`)

### 5.1 Income Updates
- [ ] `test_update_income_calculates_from_cities` - Verify income calculated from city control
- [ ] `test_update_income_french_side` - Verify French income calculated correctly
- [ ] `test_update_income_allied_side` - Verify Allied income calculated correctly
- [ ] `test_update_income_adds_to_cash` - Verify income added to cash reserves
- [ ] `test_update_income_caps_at_maximum` - Verify cash capped at 19,999

### 5.2 Automatic Supply
- [ ] `test_auto_supply_harvest_month_free` - Verify free supply in harvest months
- [ ] `test_auto_supply_harvest_month_increases_supply` - Verify supply increases in harvest months
- [ ] `test_auto_supply_calculates_cost` - Verify cost calculated (0.002 per 1000 men)
- [ ] `test_auto_supply_deducts_cost` - Verify cost deducted from cash
- [ ] `test_auto_supply_insufficient_funds` - Handle insufficient funds (no supply)
- [ ] `test_auto_supply_increases_supply_level` - Verify supply level increases
- [ ] `test_auto_supply_caps_at_10` - Verify supply capped at 10
- [ ] `test_auto_supply_per_side` - Verify supply calculated separately per side

### 5.3 Manual Supply
- [ ] `test_manual_supply_calculates_cost` - Verify cost calculated (0.001 per 1000 men)
- [ ] `test_manual_supply_deducts_cost` - Verify cost deducted
- [ ] `test_manual_supply_increases_supply` - Verify supply level increases
- [ ] `test_manual_supply_insufficient_funds` - Handle insufficient funds gracefully
- [ ] `test_manual_supply_empty_army` - Handle empty army gracefully
- [ ] `test_manual_supply_caps_at_10` - Verify supply capped at 10

### 5.4 Supply Consumption
- [ ] `test_consume_supply_reduces_by_one` - Verify supply reduced by 1 per turn
- [ ] `test_consume_supply_harvest_month_skip` - Verify no consumption in harvest months
- [ ] `test_consume_supply_non_negative` - Verify supply doesn't go below 0
- [ ] `test_consume_supply_all_armies` - Verify all armies consume supply

### 5.5 Cost Queries
- [ ] `test_get_recruitment_cost` - Verify recruitment cost is 100
- [ ] `test_get_fortification_cost` - Verify fortification cost is 200
- [ ] `test_get_ship_cost` - Verify ship cost is 100

### 5.6 Supply Status
- [ ] `test_is_out_of_supply_zero_supply` - Verify out of supply when supply = 0
- [ ] `test_is_out_of_supply_has_supply` - Verify not out of supply when supply > 0

---

## 6. Commands System (`commands.bas`)

### 6.1 Commander Selection
- [ ] `test_select_commander_french_side` - Select commander for French side
- [ ] `test_select_commander_allied_side` - Select commander for Allied side
- [ ] `test_select_commander_filters_by_side` - Verify only commanders for side shown
- [ ] `test_select_commander_filters_by_availability` - Verify only available commanders shown
- [ ] `test_select_commander_filters_by_nationality` - Verify nationality filter works (cohesion)
- [ ] `test_select_commander_invalid_side` - Handle invalid side parameter
- [ ] `test_select_commander_no_available` - Handle no available commanders
- [ ] `test_select_commander_cancelled` - Handle user cancellation (returns 0)

### 6.2 Cancel Move Orders
- [ ] `test_cancel_move_orders_clears_move` - Verify move order cleared
- [ ] `test_cancel_move_orders_filters_by_side` - Verify only side's armies shown
- [ ] `test_cancel_move_orders_only_with_orders` - Verify only armies with orders shown
- [ ] `test_cancel_move_orders_no_armies` - Handle no armies with orders

### 6.3 Fortify City Command
- [ ] `test_fortify_city_command_shows_eligible_cities` - Verify eligible cities shown
- [ ] `test_fortify_city_command_requires_friendly_army` - Verify friendly army required
- [ ] `test_fortify_city_command_requires_owner` - Verify city must be owned by side
- [ ] `test_fortify_city_command_max_fortification` - Exclude cities at max fortification
- [ ] `test_fortify_city_command_no_eligible` - Handle no eligible cities

### 6.4 Join Armies Command
- [ ] `test_join_armies_command_shows_cities_with_multiple` - Verify cities with 2+ armies shown
- [ ] `test_join_armies_command_filters_by_side` - Verify only friendly armies considered
- [ ] `test_join_armies_command_no_cities` - Handle no cities with multiple armies

### 6.5 Supply Army Command
- [ ] `test_supply_army_command_shows_armies_low_supply` - Verify armies with supply < 10 shown
- [ ] `test_supply_army_command_filters_by_side` - Verify only side's armies shown
- [ ] `test_supply_army_command_all_fully_supplied` - Handle all armies fully supplied

### 6.6 Detach Army Command
- [ ] `test_detach_army_command_placeholder` - Placeholder for future implementation

### 6.7 Drill Army Command
- [ ] `test_drill_army_command_placeholder` - Placeholder for future implementation

### 6.8 Relieve Commander Command
- [ ] `test_relieve_commander_command_shows_armies` - Verify all armies shown
- [ ] `test_relieve_commander_command_filters_by_side` - Verify only side's armies shown
- [ ] `test_relieve_commander_command_selects_new_commander` - Verify new commander selection
- [ ] `test_relieve_commander_command_applies_nationality_filter` - Verify nationality filter for cohesion
- [ ] `test_relieve_commander_command_cancelled` - Handle user cancellation

---

## 7. Scenario System (`scenario.bas`)

### 7.1 Scenario Selection
- [ ] `test_select_scenario_displays_menu` - Verify scenario menu displayed
- [ ] `test_select_scenario_returns_year` - Verify selected year returned
- [ ] `test_select_scenario_cancelled` - Handle user cancellation (returns 0)
- [ ] `test_select_scenario_valid_selection` - Verify valid selection mapped correctly

### 7.2 Scenario Loading
- [ ] `test_load_scenario_initializes_structures` - Verify all structures initialized
- [ ] `test_load_scenario_loads_commanders` - Verify commander data loaded
- [ ] `test_load_scenario_loads_cities` - Verify city data loaded
- [ ] `test_load_scenario_loads_ini` - Verify scenario INI file loaded
- [ ] `test_load_scenario_sets_starting_month_year` - Verify starting month/year set
- [ ] `test_load_scenario_initializes_armies` - Verify armies initialized from data
- [ ] `test_load_scenario_sets_war_conditions` - Verify war conditions set
- [ ] `test_load_scenario_sets_objectives` - Verify objective cities set
- [ ] `test_load_scenario_sets_starting_cash` - Verify starting cash set
- [ ] `test_load_scenario_initializes_fleets` - Verify fleets initialized

### 7.3 Commander Data Loading
- [ ] `test_load_commander_data_valid_file` - Load commander data from valid file
- [ ] `test_load_commander_data_sets_properties` - Verify name, rating, nationality set
- [ ] `test_load_commander_data_sets_availability` - Verify availability flag set
- [ ] `test_load_commander_data_file_not_found` - Handle missing file gracefully

### 7.4 Scenario INI Loading
- [ ] `test_load_scenario_ini_valid_file` - Load scenario INI from valid file
- [ ] `test_load_scenario_ini_sets_end_conditions` - Verify end game conditions set
- [ ] `test_load_scenario_ini_sets_battle_stats` - Verify battle statistics initialized
- [ ] `test_load_scenario_ini_sets_war_conditions` - Verify war conditions set
- [ ] `test_load_scenario_ini_initializes_armies` - Verify armies initialized
- [ ] `test_load_scenario_ini_sets_cash` - Verify starting cash set
- [ ] `test_load_scenario_ini_initializes_fleets` - Verify fleets initialized
- [ ] `test_load_scenario_ini_sets_objectives` - Verify objective cities set
- [ ] `test_load_scenario_ini_file_not_found` - Handle missing file gracefully

---

## 8. Victory Conditions (`victory.bas`)

### 8.1 Victory Condition Initialization
- [ ] `test_initialize_victory_conditions_resets_flags` - Verify all flags reset to 0
- [ ] `test_initialize_victory_conditions_resets_triggered` - Verify triggered flag reset
- [ ] `test_initialize_victory_conditions_resets_winner` - Verify winner reset

### 8.2 End Game Condition Checks
- [ ] `test_check_end_game_conditions_time_condition` - Verify time condition checked
- [ ] `test_check_end_game_conditions_cities_percentage` - Verify city percentage condition
- [ ] `test_check_end_game_conditions_income_percentage` - Verify income percentage condition
- [ ] `test_check_end_game_conditions_objective_capture` - Verify objective capture condition
- [ ] `test_check_end_game_conditions_army_ratio` - Verify army ratio condition
- [ ] `test_check_end_game_conditions_returns_winner` - Verify winning side returned
- [ ] `test_check_end_game_conditions_no_winner` - Verify 0 returned when no condition met
- [ ] `test_check_end_game_conditions_sets_triggered` - Verify triggered flag set
- [ ] `test_check_end_game_conditions_sets_winner` - Verify winner side set

### 8.3 Victory Points
- [ ] `test_award_victory_points_adds_to_total` - Verify points added to side's total
- [ ] `test_award_battle_victory_points` - Verify +1 VP for battle victory
- [ ] `test_award_army_capture_points` - Verify +25 VP for army capture
- [ ] `test_award_end_game_bonus_points` - Verify +100 VP for triggering end condition
- [ ] `test_get_victory_points_returns_total` - Verify total VP returned for side

### 8.4 High Score
- [ ] `test_save_high_score_inserts_new_score` - Verify new score inserted in correct position
- [ ] `test_save_high_score_maintains_top_5` - Verify only top 5 scores kept
- [ ] `test_save_high_score_sorts_descending` - Verify scores sorted descending
- [ ] `test_save_high_score_sets_side_name` - Verify side name (French/Allies) set
- [ ] `test_save_high_score_file_creation` - Verify file created if doesn't exist

---

## 9. Cohesion System (`cohesion.bas`)

### 9.1 Cohesion Initialization
- [ ] `test_initialize_cohesion_sets_war_status` - Verify initial war status set
- [ ] `test_initialize_cohesion_french_always_at_war` - Verify French always at war
- [ ] `test_initialize_cohesion_others_may_be_peace` - Verify others may start at peace

### 9.2 Nationality Assignment
- [ ] `test_assign_city_nationality` - Verify city nationality assigned
- [ ] `test_assign_army_nationality` - Verify army nationality assigned
- [ ] `test_assign_commander_nationality` - Verify commander nationality assigned
- [ ] `test_assign_commander_nationality_valid_index` - Handle valid commander index

### 9.3 Cohesion Checks
- [ ] `test_check_cohesion_matching_nationalities` - Verify no penalty when nationalities match
- [ ] `test_check_cohesion_mismatched_nationalities` - Verify penalty when nationalities differ
- [ ] `test_check_cohesion_empty_army` - Handle empty army (no penalty)
- [ ] `test_get_commander_nationality_by_name` - Verify commander found by army name
- [ ] `test_get_commander_nationality_not_found` - Handle commander not found (returns army nationality)

### 9.4 Cohesion Penalties
- [ ] `test_apply_cohesion_penalty_reduces_effectiveness` - Verify 25% reduction applied
- [ ] `test_apply_cohesion_penalty_no_penalty_when_matching` - Verify no penalty when matching
- [ ] `test_apply_cohesion_penalty_empty_army` - Handle empty army

### 9.5 Allied Country Activation
- [ ] `test_activate_allied_country_changes_status` - Verify status changes to at-war
- [ ] `test_activate_allied_country_updates_cities` - Verify city ownership updated
- [ ] `test_activate_allied_country_already_at_war` - Handle already at-war country
- [ ] `test_activate_allied_country_french_ignored` - Ignore activation for French

### 9.6 City Ownership Updates
- [ ] `test_update_city_ownership_for_nationality` - Verify cities updated from at-peace to allied
- [ ] `test_update_city_ownership_only_matching_nationality` - Verify only matching nationality updated
- [ ] `test_update_city_ownership_only_at_peace` - Verify only at-peace cities updated

### 9.7 Peace Status
- [ ] `test_is_at_peace_returns_true` - Verify returns true when at peace
- [ ] `test_is_at_peace_returns_false` - Verify returns false when at war
- [ ] `test_can_recruit_in_city_at_peace` - Verify cannot recruit in at-peace city
- [ ] `test_can_recruit_in_city_at_war` - Verify can recruit in at-war city

### 9.8 Nationality Income
- [ ] `test_get_city_income_for_nationality_at_peace` - Verify 0 income for at-peace country
- [ ] `test_get_city_income_for_nationality_at_war` - Verify income calculated for at-war country
- [ ] `test_get_city_income_for_nationality_sums_cities` - Verify all cities summed

### 9.9 Nationality Names
- [ ] `test_get_nationality_name_french` - Verify "French" returned
- [ ] `test_get_nationality_name_austrian` - Verify "Austrian" returned
- [ ] `test_get_nationality_name_english` - Verify "English" returned
- [ ] `test_get_nationality_name_russian` - Verify "Russian" returned
- [ ] `test_get_nationality_name_prussian` - Verify "Prussian" returned
- [ ] `test_get_nationality_name_spanish` - Verify "Spanish" returned
- [ ] `test_get_nationality_name_unknown` - Verify "Unknown" for invalid nationality

### 9.10 Cohesion Fixing
- [ ] `test_fix_cohesion_with_relieve_matching_nationality` - Verify cohesion fixed when nationalities match
- [ ] `test_fix_cohesion_with_relieve_mismatched_nationality` - Handle mismatched nationality
- [ ] `test_fix_cohesion_with_relieve_applies_penalty` - Verify RELIEVE penalty still applied

---

## 10. Tactical Integration (`tactical_integration.bas`)

### 10.1 Battle Triggering
- [ ] `test_should_trigger_tactical_battle_conditions` - Verify conditions for tactical battle
- [ ] `test_should_trigger_tactical_battle_size_threshold` - Verify size threshold check
- [ ] `test_should_trigger_tactical_battle_objective_city` - Verify objective city check

### 10.2 Battle Data Preparation
- [ ] `test_prepare_battle_data_army_info` - Verify army data prepared correctly
- [ ] `test_prepare_battle_data_city_info` - Verify city data prepared correctly
- [ ] `test_prepare_battle_data_terrain` - Verify terrain data prepared
- [ ] `test_prepare_battle_data_weather` - Verify weather data prepared

### 10.3 Battle Result Processing
- [ ] `test_process_tactical_battle_result_casualties` - Verify casualties applied from result
- [ ] `test_process_tactical_battle_result_winner` - Verify winner determined correctly
- [ ] `test_process_tactical_battle_result_retreat` - Verify retreat processed
- [ ] `test_process_tactical_battle_result_city_capture` - Verify city capture on victory
- [ ] `test_process_tactical_battle_result_experience` - Verify experience awarded

---

## 11. Common Utilities (`utilities.bas`, `game_state_helpers.bas`)

### 11.1 Game State Helpers
- [ ] `test_get_game_state_cash` - Verify cash retrieved correctly
- [ ] `test_set_game_state_cash` - Verify cash set correctly
- [ ] `test_get_game_state_income` - Verify income retrieved correctly
- [ ] `test_set_game_state_income` - Verify income set correctly
- [ ] `test_get_game_state_victory` - Verify victory points retrieved correctly
- [ ] `test_set_game_state_victory` - Verify victory points set correctly
- [ ] `test_get_game_state_control` - Verify control count retrieved correctly
- [ ] `test_set_game_state_control` - Verify control count set correctly

### 11.2 Utility Functions
- [ ] `test_file_exists_valid_file` - Verify file existence check works
- [ ] `test_file_exists_invalid_file` - Verify non-existent file returns false
- [ ] `test_clamp_value_within_range` - Verify value clamped within range
- [ ] `test_clamp_value_below_minimum` - Verify value clamped to minimum
- [ ] `test_clamp_value_above_maximum` - Verify value clamped to maximum
- [ ] `test_get_army_side_french` - Verify French side identification
- [ ] `test_get_army_side_allied` - Verify Allied side identification
- [ ] `test_get_army_side_invalid` - Handle invalid army index

---

## 12. Error Handling (`error_handling.bas`)

### 12.1 Error Display
- [ ] `test_show_status_error_displays_message` - Verify error message displayed
- [ ] `test_show_status_warning_displays_message` - Verify warning message displayed
- [ ] `test_show_status_message_displays_message` - Verify status message displayed
- [ ] `test_show_info_displays_message` - Verify info message displayed

### 12.2 File Error Handling
- [ ] `test_handle_file_not_found_displays_error` - Verify error displayed for missing file
- [ ] `test_handle_file_not_found_exits_gracefully` - Verify graceful exit on file error

### 12.3 Validation Error Handling
- [ ] `test_handle_validation_error_displays_error` - Verify validation error displayed
- [ ] `test_handle_validation_error_logs_details` - Verify error details logged

---

## Test Implementation Priority

### Priority 1 (Critical - Must Have)
1. Campaign Management - Turn advancement, save/load
2. Army Management - Recruitment, movement, combining
3. City Management - Capture, fortification, income
4. Combat Resolution - Strength calculation, winner determination, casualties
5. Economy - Income, supply, costs

### Priority 2 (Important - Should Have)
6. Commands System - All command functions
7. Scenario System - Loading and initialization
8. Victory Conditions - End game checks, victory points
9. Cohesion System - Nationality matching, penalties

### Priority 3 (Nice to Have)
10. Tactical Integration - Battle triggering and result processing
11. Common Utilities - Helper functions
12. Error Handling - Error display and logging

---

## Test File Organization

Recommended test file structure:
- `test_campaign.bas` - Campaign management tests
- `test_army.bas` - Army management tests
- `test_city.bas` - City management tests
- `test_combat.bas` - Combat resolution tests
- `test_economy.bas` - Economy system tests
- `test_commands.bas` - Commands system tests
- `test_scenario.bas` - Scenario system tests
- `test_victory.bas` - Victory conditions tests
- `test_cohesion.bas` - Cohesion system tests
- `test_tactical_integration.bas` - Tactical integration tests
- `test_utilities.bas` - Common utilities tests
- `test_error_handling.bas` - Error handling tests

---

## Notes

- All tests should use the QB64 test framework (see `TESTING_FRAMEWORK.md`)
- Tests should be independent and not rely on execution order
- Use descriptive test names that clearly indicate what is being tested
- Include both success and failure cases
- Test edge cases and boundary conditions
- Mock or stub external dependencies (file I/O, user input) where possible
- Tests should be fast and not require user interaction

