# Wars of Napoleon - Naming Conventions

This document defines the naming conventions used throughout the Wars of Napoleon codebase.

## Function Naming

### Type Suffixes (Required)

All functions **MUST** use type suffixes to indicate their return type. This is a QB64 requirement and improves code clarity.

**Convention**: `FunctionName<TypeSuffix>`

#### Type Suffixes

- `%` - INTEGER return type
- `&` - LONG return type
- `!` - SINGLE return type
- `#` - DOUBLE return type
- `$` - STRING return type

#### Examples

```qbasic
' INTEGER return type
FUNCTION GetArmySide% (armyIndex AS INTEGER)
FUNCTION CheckVictoryConditions% ()
FUNCTION ResolveCombat% (attackerIndex AS INTEGER, defenderIndex AS INTEGER)

' LONG return type
FUNCTION GetRemainingStrength& (side AS INTEGER)
FUNCTION GetVictoryPoints& (side AS INTEGER)
FUNCTION CalculateCombatStrength& (armyIndex AS INTEGER)

' STRING return type
FUNCTION GetCurrentMonth$ ()
FUNCTION GetSaveFileList$ (count AS INTEGER)
FUNCTION LEFTY$ (index AS INTEGER)

' SINGLE return type
FUNCTION GetPercentage! (part AS LONG, total AS LONG)
FUNCTION CalculateDefenderBonus! (cityIndex AS INTEGER)
```

### Function Calls

When calling functions, **always** include the type suffix:

```qbasic
' Correct
DIM side AS INTEGER
side = GetArmySide%(armyIndex)

DIM strength AS LONG
strength = GetRemainingStrength&(1)

DIM month AS STRING
month = GetCurrentMonth$()
```

**Do NOT** call functions without type suffixes:
```qbasic
' Incorrect - DO NOT DO THIS
side = GetArmySide(armyIndex)  ' Missing %
strength = GetRemainingStrength(1)  ' Missing &
```

### Function Return Assignments

When assigning return values within a function, use the type suffix:

```qbasic
FUNCTION ShowMainMenu% ()
    IF choice >= 1 AND choice <= 5 THEN
        ShowMainMenu% = choice  ' Correct - with suffix
    ELSE
        ShowMainMenu% = 0
    END IF
END FUNCTION
```

## Subroutine Naming

Subroutines do not have return types, so they do not use type suffixes.

**Convention**: `SubroutineName` (PascalCase, no suffix)

#### Examples

```qbasic
SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)
SUB LoadTacticalConfig ()
SUB ProcessRetreat (armyIndex AS INTEGER, cityIndex AS INTEGER)
SUB ShowStatusMessage (message AS STRING, color AS INTEGER)
```

## Variable Naming

### Type Suffixes (Optional but Recommended)

Variables can use type suffixes, but it's not required if the type is explicitly declared.

**Convention**: `variableName<TypeSuffix>` or `variableName AS Type`

#### Examples

```qbasic
' With type suffix (QB64 style)
DIM i%
DIM strength&
DIM name$

' With explicit type declaration (modern style)
DIM i AS INTEGER
DIM strength AS LONG
DIM name AS STRING
```

Both styles are acceptable, but be consistent within a file.

### Shared Variables

Shared variables use `SHARED` keyword and typically use explicit type declarations:

```qbasic
DIM SHARED armies(1 TO 40) AS ArmyType
DIM SHARED cities(1 TO 60) AS CityType
DIM SHARED gameState AS GameStateType
DIM SHARED currentPhase AS INTEGER
```

## Constant Naming

Constants use UPPER_SNAKE_CASE:

**Convention**: `CONSTANT_NAME`

#### Examples

```qbasic
CONST MAX_ARMIES = 40
CONST MAX_CITIES = 60
CONST FRENCH_START = 1
CONST ALLIED_START = 21
CONST PHASE_DECISION = 1
CONST PHASE_MOVE_COMBAT = 2
CONST PHASE_UPDATE = 3
```

## Type Definitions

Type definitions use PascalCase with `Type` suffix:

**Convention**: `TypeNameType`

#### Examples

```qbasic
TYPE BattleData
    scenario AS STRING
    side AS INTEGER
    sideID1 AS INTEGER
    sideID2 AS INTEGER
    ' ...
END TYPE

TYPE BattleResult
    winner AS INTEGER
    casualties1 AS LONG
    casualties2 AS LONG
END TYPE

TYPE ArmyType
    name AS STRING
    size AS LONG
    loc AS INTEGER
    ' ...
END TYPE
```

## Summary

| Element | Convention | Example |
|---------|-----------|---------|
| Functions | `FunctionName<TypeSuffix>` | `GetArmySide%()`, `GetVictoryPoints&()` |
| Subroutines | `SubroutineName` | `LaunchTacticalBattle()`, `LoadTacticalConfig()` |
| Variables | `variableName` or `variableName<TypeSuffix>` | `armyIndex` or `i%` |
| Constants | `CONSTANT_NAME` | `MAX_ARMIES`, `FRENCH_START` |
| Types | `TypeNameType` | `BattleData`, `ArmyType` |

## Enforcement

- All functions **MUST** use type suffixes in:
  - Function definitions
  - DECLARE statements
  - Function calls
  - Return value assignments

- This convention is enforced throughout the codebase and is critical for QB64 compatibility.

## Migration Notes

- Previously, some functions were called without type suffixes
- All function calls have been standardized to include type suffixes
- See CHANGELOG.md for details on the standardization effort

