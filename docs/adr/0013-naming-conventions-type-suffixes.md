# ADR-0013: Naming Conventions - Type Suffixes

**Status:** Accepted  
**Date:** 2025-12-25 (implicit, based on code structure)  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

QB64 has specific requirements for function naming that differ from modern programming languages:
- Functions must use type suffixes (`%`, `&`, `!`, `#`, `$`) to indicate return type
- Function calls must include the type suffix
- SUBs cannot have type suffixes (they don't return values)
- Type suffixes are required for QB64 compatibility

The codebase needed consistent naming conventions for:
- Functions (with type suffixes)
- Subroutines (without type suffixes)
- Variables (optional type suffixes)
- Constants (UPPER_SNAKE_CASE)
- Type definitions (PascalCase with Type suffix)

## Decision

We decided to adopt strict QB64 naming conventions:

### Function Naming
- **Required**: All functions MUST use type suffixes
- **Convention**: `FunctionName<TypeSuffix>`
- **Type Suffixes**:
  - `%` - INTEGER
  - `&` - LONG
  - `!` - SINGLE
  - `#` - DOUBLE
  - `$` - STRING

**Examples**:
```qb64
FUNCTION GetArmySide% (armyIndex AS INTEGER)
FUNCTION GetVictoryPoints& (side AS INTEGER)
FUNCTION GetCurrentMonth$ ()
```

### Subroutine Naming
- **Required**: No type suffixes (SUBs don't return values)
- **Convention**: `SubroutineName` (PascalCase)

**Examples**:
```qb64
SUB LaunchTacticalBattle (battleData AS BattleData)
SUB ShowStatusMessage (message AS STRING)
```

### Variable Naming
- **Optional**: Type suffixes allowed but not required
- **Convention**: `variableName` or `variableName<TypeSuffix>`
- **Recommendation**: Use explicit `AS Type` declarations for clarity

### Constant Naming
- **Convention**: `CONSTANT_NAME` (UPPER_SNAKE_CASE)

**Examples**:
```qb64
CONST MAX_ARMIES = 40
CONST FRENCH_START = 1
CONST PHASE_DECISION = 1
```

### Type Naming
- **Convention**: `TypeNameType` (PascalCase with Type suffix)

**Examples**:
```qb64
TYPE BattleData
TYPE ArmyType
TYPE GameStateType
```

## Consequences

### Positive
- **QB64 compatibility**: Code compiles correctly
- **Type safety**: Type suffixes make return types explicit
- **Code clarity**: Easy to see what type a function returns
- **Consistency**: All code follows same conventions
- **Documentation**: Naming conventions documented in `NAMING_CONVENTIONS.md`

### Negative
- **Learning curve**: Developers must learn QB64-specific syntax
- **Verbosity**: Function names include type suffixes
- **Migration effort**: All functions must use type suffixes
- **Modern language differences**: Different from modern languages (C#, Java, etc.)

### Neutral
- Game functionality unchanged
- Performance unchanged
- User experience unchanged

## Implementation Notes

- All functions updated to use type suffixes
- All function calls include type suffixes
- Naming conventions documented in `docs/NAMING_CONVENTIONS.md`
- Code review checks for proper type suffix usage
- QB64 compiler enforces type suffix requirements

## Related ADRs

- ADR-0002: Migrate to QB64
- ADR-0014: QB64 Syntax Constraints

