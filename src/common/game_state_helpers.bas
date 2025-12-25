'============================================================================
' Game State Helper Functions
'============================================================================
' Helper functions to access gameState fields with array-like syntax
' QB64 doesn't support arrays in TYPE definitions, so we use separate fields

FUNCTION GetGameStateCash& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateCash& = gameState.cashFrench
    ELSE
        GetGameStateCash& = gameState.cashAllied
    END IF
END FUNCTION

SUB SetGameStateCash (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.cashFrench = value
    ELSE
        gameState.cashAllied = value
    END IF
END SUB

FUNCTION GetGameStateIncome& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateIncome& = gameState.incomeFrench
    ELSE
        GetGameStateIncome& = gameState.incomeAllied
    END IF
END FUNCTION

SUB SetGameStateIncome (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.incomeFrench = value
    ELSE
        gameState.incomeAllied = value
    END IF
END SUB

FUNCTION GetGameStateVictory& (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateVictory& = gameState.victoryFrench
    ELSE
        GetGameStateVictory& = gameState.victoryAllied
    END IF
END FUNCTION

SUB SetGameStateVictory (side AS INTEGER, value AS LONG)
    IF side = 1 THEN
        gameState.victoryFrench = value
    ELSE
        gameState.victoryAllied = value
    END IF
END SUB

FUNCTION GetGameStateControl% (side AS INTEGER)
    IF side = 1 THEN
        GetGameStateControl% = gameState.controlFrench
    ELSE
        GetGameStateControl% = gameState.controlAllied
    END IF
END FUNCTION

SUB SetGameStateControl (side AS INTEGER, value AS INTEGER)
    IF side = 1 THEN
        gameState.controlFrench = value
    ELSE
        gameState.controlAllied = value
    END IF
END SUB

