'============================================================================
' Battle Data Types for Strategic-Tactical Integration
'============================================================================
' These types define the interface between strategic and tactical modules
' in the unified game architecture (replacing file-based communication)

' Note: QB64 doesn't support arrays in TYPE definitions, so we use separate fields
TYPE BattleData
    scenario AS STRING
    side AS INTEGER
    sideID1 AS INTEGER       ' Side identifier 1
    sideID2 AS INTEGER       ' Side identifier 2
    commander1 AS STRING     ' Commander name 1
    commander2 AS STRING     ' Commander name 2
    vp1 AS LONG              ' Victory points/strength 1 (in 100s)
    vp2 AS LONG              ' Victory points/strength 2 (in 100s)
    leadbase1 AS INTEGER      ' Base leadership rating 1
    leadbase2 AS INTEGER      ' Base leadership rating 2
    expbase1 AS INTEGER       ' Base experience level 1
    expbase2 AS INTEGER       ' Base experience level 2
    difficult AS INTEGER
    fort AS INTEGER
    quiet AS INTEGER
END TYPE

TYPE BattleResult
    winner AS INTEGER        ' 1 or 2 (side that won)
    casualties1 AS LONG     ' Casualties for side 1
    casualties2 AS LONG     ' Casualties for side 2
END TYPE


