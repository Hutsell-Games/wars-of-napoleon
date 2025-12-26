'============================================================================
' Game State Helper Functions
'============================================================================
' Helper functions to access gameState fields with array-like syntax
' QB64 doesn't support arrays in TYPE definitions, so we use separate fields

'============================================================================
' GetGameStateCash - Get cash amount for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to get cash for (1=French, 2=Allies)
' Returns:
'   LONG - Cash amount for the specified side
'============================================================================
FUNCTION GetGameStateCash& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateCash& = gameState.cashFrench
    ELSE
        GetGameStateCash& = gameState.cashAllied
    END IF
END FUNCTION

'============================================================================
' SetGameStateCash - Set cash amount for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to set cash for (1=French, 2=Allies)
'   value (LONG) - Cash amount to set
' Side Effects:
'   Updates gameState.cashFrench or gameState.cashAllied
'============================================================================
SUB SetGameStateCash (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.cashFrench = value
    ELSE
        gameState.cashAllied = value
    END IF
END SUB

'============================================================================
' GetGameStateIncome - Get income amount for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to get income for (1=French, 2=Allies)
' Returns:
'   LONG - Income amount for the specified side
'============================================================================
FUNCTION GetGameStateIncome& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateIncome& = gameState.incomeFrench
    ELSE
        GetGameStateIncome& = gameState.incomeAllied
    END IF
END FUNCTION

'============================================================================
' SetGameStateIncome - Set income amount for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to set income for (1=French, 2=Allies)
'   value (LONG) - Income amount to set
' Side Effects:
'   Updates gameState.incomeFrench or gameState.incomeAllied
'============================================================================
SUB SetGameStateIncome (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.incomeFrench = value
    ELSE
        gameState.incomeAllied = value
    END IF
END SUB

'============================================================================
' GetGameStateVictory - Get victory points for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to get victory points for (1=French, 2=Allies)
' Returns:
'   LONG - Victory points for the specified side
'============================================================================
FUNCTION GetGameStateVictory& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateVictory& = gameState.victoryFrench
    ELSE
        GetGameStateVictory& = gameState.victoryAllied
    END IF
END FUNCTION

'============================================================================
' SetGameStateVictory - Set victory points for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to set victory points for (1=French, 2=Allies)
'   value (LONG) - Victory points to set
' Side Effects:
'   Updates gameState.victoryFrench or gameState.victoryAllied
'============================================================================
SUB SetGameStateVictory (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.victoryFrench = value
    ELSE
        gameState.victoryAllied = value
    END IF
END SUB

'============================================================================
' GetGameStateControl - Get control percentage for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to get control for (1=French, 2=Allies)
' Returns:
'   INTEGER - Control percentage for the specified side
'============================================================================
FUNCTION GetGameStateControl% (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateControl% = gameState.controlFrench
    ELSE
        GetGameStateControl% = gameState.controlAllied
    END IF
END FUNCTION

'============================================================================
' SetGameStateControl - Set control percentage for specified side
'============================================================================
' Parameters:
'   side (INTEGER) - Side to set control for (1=French, 2=Allies)
'   value (INTEGER) - Control percentage to set
' Side Effects:
'   Updates gameState.controlFrench or gameState.controlAllied
'============================================================================
SUB SetGameStateControl (side AS INTEGER, value AS INTEGER)
    IF side = 1 THEN
        gameState.controlFrench = value
    ELSE
        gameState.controlAllied = value
    END IF
END SUB

