'============================================================================
' Test Initialization
'============================================================================
' Initialize variables that need initialization
' This must be called after all SUB/FUNCTION declarations

'============================================================================
' Stub implementations for tactical functions needed by common utilities
'============================================================================
' NOTE: clrbot is defined in tactical/ui.bas, so no stub needed here
' NOTE: TICK is defined in tactical/utilities.bas, so no stub needed here

'============================================================================
' Test stubs for interactive functions
'============================================================================
' NOTE: Most tactical functions are already defined in the included tactical files:
'   - iconload, mainmap, refresh: tactical/ui.bas
'   - randmap: tactical/terrain.bas
'   - randarm: tactical/unit_placement.bas
'   - brittle, lowtime: tactical/utilities.bas
'   - startmap: tactical/terrain.bas
'   - Compact: tactical/unit_management.bas
'   - victory, wipeout: tactical/combat.bas
' Only functions not already defined need stubs here.

FUNCTION ShowListMenu% (title AS STRING, items$, itemCount AS INTEGER)
    ' Stub implementation for testing - returns first item
    ' Full implementation is in ui/menus.bas
    ' For testing, we don't want interactive menus
    ' NOTE: This may conflict with menus.bas - may need to remove if duplicate
    ShowListMenu% = 1 ' Return first item for testing
END FUNCTION

' NOTE: see is defined in tactical/ai.bas, order is defined in tactical/orders.bas
' No stubs needed for these functions

SUB InitializeTestVariables
    ' Initialize variables from declarations.bas that need initialization
    ' These executable statements are commented out in declarations_test.bas
    ' to avoid "Statement cannot be placed between SUB/FUNCTIONs" errors.
    ' They must be initialized here, AFTER all SUB/FUNCTION declarations.
    most = 80: m1 = 40: m2 = 41
    file$ = ""
    scenario$ = ""
END SUB

