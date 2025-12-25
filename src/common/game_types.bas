'============================================================================
' Common Game Data Types
'============================================================================
' Shared data structures for strategic game

' Army attributes
TYPE ArmyType
    name AS STRING           ' Army name/commander
    size AS LONG             ' Strength (number of men)
    lead AS INTEGER           ' Leadership (1-10)
    exper AS INTEGER          ' Experience (0-10)
    supply AS INTEGER         ' Supply level (0-10)
    loc AS INTEGER            ' Current city location
    move AS INTEGER           ' Destination city (0=none, -1=resting, -2=moved)
    nationality AS INTEGER    ' Nationality (for cohesion system)
END TYPE

' City attributes
TYPE CityType
    name AS STRING            ' City name
    x AS INTEGER              ' X coordinate
    y AS INTEGER              ' Y coordinate
    value AS INTEGER          ' Income/victory point value
    owner AS INTEGER          ' Owner (0=neutral, 1=French, 2=Allied, 3=at peace)
    fort AS INTEGER           ' Fortification level (0=none, 1=FORT+, 2=FORT++)
    nationality AS INTEGER    ' Nationality (for cohesion system)
    objective AS INTEGER      ' Objective city flag (0=no, 1=yes)
END TYPE

' Commander attributes
TYPE CommanderType
    name AS STRING            ' Commander name
    rating AS INTEGER         ' Leadership rating (1-10)
    nationality AS INTEGER    ' Nationality (for cohesion system)
    available AS INTEGER      ' Available flag (0=no, 1=yes)
END TYPE

' Naval fleet
TYPE FleetType
    size AS INTEGER           ' Number of ships (0-10)
    loc AS INTEGER            ' Current port location
    move AS INTEGER           ' Destination port (0=none)
END TYPE

' Game state
' Note: QB64 doesn't support arrays in TYPE definitions, so we use separate fields
TYPE GameStateType
    month AS INTEGER          ' Current month (1-12)
    year AS INTEGER           ' Current year
    side AS INTEGER           ' Current side (1=French, 2=Allies)
    turn AS INTEGER           ' Turn number
    cashFrench AS LONG        ' Money for French side
    cashAllied AS LONG        ' Money for Allied side
    incomeFrench AS LONG      ' Income for French side
    incomeAllied AS LONG      ' Income for Allied side
    victoryFrench AS LONG     ' Victory points for French side
    victoryAllied AS LONG     ' Victory points for Allied side
    controlFrench AS INTEGER  ' Cities controlled by French
    controlAllied AS INTEGER  ' Cities controlled by Allies
END TYPE


