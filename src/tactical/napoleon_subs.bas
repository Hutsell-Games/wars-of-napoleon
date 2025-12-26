'============================================================================
' NAPOLEON.BAS Subroutines - Extracted for WON integration
'============================================================================
' Main program code (lines 7-95) has been removed to prevent execution when included
' All SUB and FUNCTION definitions from original NAPOLEON.BAS are preserved here
'============================================================================
' Note: The original NAPOLEON.BAS had executable code at module level that would
' run when included. This file contains only SUB/FUNCTION definitions.
' NOTE: DECLARE statements moved to battle.bas
' NOTE: cannon, CalculateCannonDamage, CheckCannonExplosion, flash moved to combat.bas
' NOTE: help and iconload moved to ui.bas
' NOTE: los moved to utilities.bas
' NOTE: SUB order and related functions have been moved to orders.bas
' Removed functions:
' - order (moved to orders.bas)
' - cupdate (moved to orders.bas)
' - ProcessMovementCommand (moved to orders.bas)
' - ProcessEnemyUnit (moved to orders.bas)
' - UpdateUnitAfterAction (moved to orders.bas)
' - ProcessCursorCommand (moved to orders.bas)
' - DrawCommandLine (moved to orders.bas)
' - WaitForKeypress (moved to orders.bas)
' - CanPlaceUnit (moved to orders.bas)
' - CancelOrders (moved to orders.bas)
' - RefreshAhead (moved to orders.bas)
' - HandleRAlly (moved to orders.bas)
' - HandleHere (moved to orders.bas)
' - AwakenUnit (moved to orders.bas)
' - FlashCursor (moved to orders.bas)
' Note: Enemy unit processing is now handled by ProcessEnemyUnit% function
' The otherside label has been removed and replaced with function call
' NOTE: PlayNoise1, PlayNoise2, PlayNoise3 moved to utilities.bas
' GOSUB stats converted to SUB
' NOTE: Functions moved to orders.bas and ui.bas
' Removed: ShowUnitStats, DrawCommandLine, WaitForKeypress, CanPlaceUnit,
' CancelOrders, RefreshAhead, HandleRAlly, HandleHere, ProcessCursorCommand,
' AwakenUnit, UpdateAllTerrain, ShowIntelligenceLine, FlashCursor
' NOTE: placeunit moved to unit_management.bas
' NOTE: CheckEnemyEngagement moved to ai.bas
' NOTE: randarm, CalculateXY, CheckOddHex, FindValidUnitPlacement,
' InitializeUnitAttributes moved to unit_placement.bas
' NOTE: randmap, RandomLocation, MoveNearHere, AdjustHexX, CheckLimits,
' PlaceWaterFeatures, PlaceRoads, PlaceTrees, PlaceHills, PlaceOtherTerrain,
' replace, Tara, Terra, vistarg moved to terrain.bas
' NOTE: vistarg moved to terrain.bas
' NOTE: arrange moved to unit_placement.bas
' NOTE: ATTENTION moved to ui.bas
' NOTE: brittle and BuffClear moved to utilities.bas
' NOTE: BUTTON and clrbot moved to ui.bas
' NOTE: CalculateAICombatChoice and combat moved to combat.bas
' NOTE: cupdate moved to orders.bas
' NOTE: curser moved to utilities.bas
' NOTE: despair moved to combat.bas
' NOTE: expire moved to ui.bas
' NOTE: flee moved to combat.bas
' NOTE: general, EvaluateLocation, EvaluateAllLocations moved to ai.bas
' NOTE: inspect, kleer, LITEUP moved to ui.bas
' NOTE: LEFTY$, lowtime, namer, Near1, Near2, normal moved to utilities.bas
' NOTE: over moved to utilities.bas
' NOTE: proximity moved to utilities.bas
' NOTE: pursue, CanPursueToTerrain, TryCaptureArtillery moved to combat.bas
' NOTE: ranger moved to utilities.bas
' NOTE: refresh, report, WaitForKey, FormatUnitStats moved to ui.bas
' NOTE: retreat, CalculateRetreatDirection, FindRetreatLocation, CheckRunLocation,
' ApplyRetreatExtraDamage, ApplyRetreatDamage, routed moved to combat.bas
' NOTE: scrcol and UpdateTimeDisplay moved to ui.bas
' Helper Functions for see SUB - Extracted to reduce nesting
' NOTE: ShouldEngageEnemy, CheckManualCombatOrder, ProcessEngagementOrders,
' see, target moved to ai.bas
' NOTE: TICK moved to utilities.bas
' NOTE: victory moved to combat.bas
' NOTE: whois moved to utilities.bas
' NOTE: wipeout moved to combat.bas
' NOTE: YesNo moved to ui.bas
' NOTE: YouorMe moved to utilities.bas