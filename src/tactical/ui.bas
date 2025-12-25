'============================================================================
' Tactical UI
'============================================================================
' Tactical battle user interface
' Map display, unit rendering, order interface, combat animations

' $INCLUDE: 'core.bas'

SUB DisplayTacticalMap
    ' Display tactical battle map with hex grid
    ' 27x20 hex grid
    ' Shows terrain, units, objectives
    
    ' This will use the mainmap subroutine from NAPOLEON.BAS
    ' TODO: Implement mainmap SUB from NAPOLEON.BAS
    ' CALL mainmap
END SUB

SUB RenderUnit (unitIndex AS INTEGER)
    ' Render unit on tactical map
    ' Shows unit type, strength, status
    
    ' This will use the SHOWUNIT subroutine from NAPOLEON.BAS
    CALL SHOWUNIT(unitIndex)
END SUB

SUB ShowOrderInterface
    ' Show order interface for unit
    ' Options: Move, Charge, Rest, Wait, etc.
    
    ' Placeholder - will implement menu system
    COLOR 11: CALL clrbot: PRINT "Order Interface - Select action"
END SUB

SUB ShowCombatAnimation (attackerIndex AS INTEGER, defenderIndex AS INTEGER)
    ' Show combat animation
    ' Visual feedback for combat resolution
    
    ' Placeholder - will implement animation
    COLOR 14: CALL clrbot: PRINT name$(attackerIndex); " attacks"; name$(defenderIndex)
    CALL TICK(1)
END SUB

SUB ShowVictoryScreen (winner AS INTEGER)
    ' Show victory/defeat screen
    ' Displays battle results
    
    CLS
    COLOR 15: PRINT "BATTLE RESULTS"
    PRINT STRING$(80, "-")
    
    IF winner = 1 THEN
        PRINT "French Victory!"
    ELSE
        PRINT "Allied Victory!"
    END IF
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB ShowDefeatScreen (loser AS INTEGER)
    ' Show defeat screen
    ' Displays battle loss
    
    CLS
    COLOR 12: PRINT "DEFEAT"
    PRINT STRING$(80, "-")
    
    IF loser = 1 THEN
        PRINT "French forces defeated"
    ELSE
        PRINT "Allied forces defeated"
    END IF
    
    PRINT
    PRINT "Press any key to continue..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB UpdateTacticalDisplay
    ' Update tactical battle display
    ' Refreshes map, units, status
    
    CALL refresh ' From NAPOLEON.BAS
END SUB

SUB HighlightUnit (unitIndex AS INTEGER)
    ' Highlight selected unit
    ' Visual feedback for unit selection
    
    ' Placeholder - will implement highlighting
END SUB

SUB ShowUnitInfo (unitIndex AS INTEGER)
    ' Show unit information panel
    ' Displays strength, leadership, experience, morale, etc.
    
    COLOR 11: CALL clrbot
    PRINT "Unit:"; name$(unitIndex)
    PRINT "Strength:"; strength(unitIndex)
    PRINT "Leadership:"; leader(unitIndex)
    PRINT "Experience:"; xper(unitIndex)
    PRINT "Morale:"; morale(unitIndex)
END SUB

