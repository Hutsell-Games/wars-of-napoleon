'============================================================================
' Wars of Napoleon - QB64 entry point
'============================================================================
' When launched from Explorer, QB64 programs that have no module-level
' executable statements will start and immediately exit (showing "Press any key").
'
' The correct pattern with $INCLUDE-heavy projects is:
' - Declare the entry SUB
' - CALL it
' - END to prevent falling into SUB/FUNCTION definitions
' - Then include the rest of the project (which contains only SUB/FUNCTION/TYPE/etc.)

DECLARE SUB Main ()
CALL Main
END

' $INCLUDE: 'src/common/declarations.bas'
' $INCLUDE: 'src/common/battle_types.bas'
' $INCLUDE: 'src/common/game_types.bas'
' $INCLUDE: 'src/common/game_state_helpers.bas'
' $INCLUDE: 'src/common/config.bas'
' $INCLUDE: 'src/common/utilities.bas'
' $INCLUDE: 'src/ui/menus.bas'
' $INCLUDE: 'src/ui/graphics.bas'
' $INCLUDE: 'src/strategic/campaign.bas'
' $INCLUDE: 'src/strategic/army.bas'
' $INCLUDE: 'src/strategic/city.bas'
' $INCLUDE: 'src/strategic/naval.bas'
' $INCLUDE: 'src/strategic/economy.bas'
' $INCLUDE: 'src/strategic/victory.bas'
' $INCLUDE: 'src/strategic/reports.bas'
' $INCLUDE: 'src/strategic/scenario.bas'
' $INCLUDE: 'src/strategic/cohesion.bas'
' $INCLUDE: 'src/strategic/combat.bas'
' $INCLUDE: 'src/strategic/tactical_integration.bas'
' $INCLUDE: 'src/tactical/battle.bas'
' $INCLUDE: 'src/strategic/commands.bas'
' $INCLUDE: 'src/strategic/move_capital.bas'
' $INCLUDE: 'src/strategic/realism.bas'
' $INCLUDE: 'src/strategic/pbm.bas'
' $INCLUDE: 'src/ui/mouse.bas'
' $INCLUDE: 'src/main.bas'
