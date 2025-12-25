'============================================================================
' Configuration Management
'============================================================================
' Handles loading and saving of NWS.CFG configuration file

' Configuration structure
' Format from WON.DOC section 7.3:
' 1. Side chosen (1=French, 2=Allies)
' 2. Sounds (0=none, 1=sounds only, 2=sounds and music)
' 3. Play Balance (1=Allies++, 3=Balanced, 5=French++)
' 4. Computer Enemy aggressiveness (1=low, 5=high)
' 5. Number of players (1-2)
' 6. Display speed (1=very fast, 2=Normal, 4=very slow)
' 7. Random event balance (0=off, 3=favor Allies, 5=neutral, 7=favor French)
' 8. History switch (0=off, 1=on)
' 9. Tactical Battles (0=off, 1=on)

' Note: All config_* variables are declared in declarations.bas

SUB LoadConfig
    ' Load configuration from NWS.CFG
    IF FileExists%("NWS.CFG") = 0 THEN
        ' Default values if file doesn't exist
        config_side = 1
        config_sound = 2
        config_balance = 3
        config_aggression = 3
        config_players = 1
        config_display = 2
        config_randevent = 5
        config_history = 1
        config_tactical = 1
        EXIT SUB
    END IF
    
    OPEN "I", 1, "NWS.CFG"
    INPUT #1, config_side, config_sound, config_balance, config_aggression
    INPUT #1, config_players, config_display, config_randevent, config_history
    INPUT #1, config_tactical
    CLOSE #1
    
    ' Validate ranges
    IF config_side < 1 OR config_side > 2 THEN config_side = 1
    IF config_sound < 0 OR config_sound > 2 THEN config_sound = 2
    IF config_balance < 1 OR config_balance > 5 THEN config_balance = 3
    IF config_aggression < 1 OR config_aggression > 5 THEN config_aggression = 3
    IF config_players < 1 OR config_players > 2 THEN config_players = 1
    IF config_display < 1 OR config_display > 4 THEN config_display = 2
    IF config_randevent < 0 OR config_randevent > 7 THEN config_randevent = 5
    IF config_history < 0 OR config_history > 1 THEN config_history = 1
    IF config_tactical < 0 OR config_tactical > 1 THEN config_tactical = 1
END SUB

SUB SaveConfig
    ' Save configuration to NWS.CFG
    OPEN "O", 1, "NWS.CFG"
    WRITE #1, config_side, config_sound, config_balance, config_aggression
    WRITE #1, config_players, config_display, config_randevent, config_history
    WRITE #1, config_tactical
    CLOSE #1
END SUB


