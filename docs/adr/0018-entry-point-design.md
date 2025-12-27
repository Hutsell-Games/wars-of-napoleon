# ADR-0018: Entry Point Design

**Status:** Accepted  
**Date:** 2025-12-25  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The project needed a clear entry point design:
- QB64 requires a main entry point
- Multiple modules need to be included in correct order
- Initialization sequence must be correct
- Entry point should be simple and clear

Options considered:
1. **Single entry file** (`WON.BAS`): Includes all modules, calls main function
2. **Main module** (`main.bas`): Contains main logic, includes other modules
3. **Hybrid approach**: `WON.BAS` includes modules, `main.bas` contains logic

The original codebase had:
- `NAPOLEON.BAS` - Tactical battle entry
- `NAP1A.BAS` - Strategic game entry
- Multiple executables with different entry points

## Decision

We decided to use a hybrid approach:

### Entry Point Structure

1. **WON.BAS** (root entry point):
   - Includes all modules in correct order
   - Calls `Main` SUB from `main.bas`
   - Simple, clear entry point for QB64

2. **main.bas** (main game logic):
   - Contains `Main` SUB (entry point)
   - Contains `InitializeGame` SUB
   - Contains `CleanupGame` SUB
   - Contains main menu loop
   - Contains game flow logic

### Include Order in WON.BAS

```qb64
' Common modules (foundation)
$INCLUDE: 'src/common/declarations.bas'
$INCLUDE: 'src/common/battle_types.bas'
' ... (all common modules)

' Strategic modules
$INCLUDE: 'src/strategic/scenario.bas'
' ... (all strategic modules)

' Tactical modules
$INCLUDE: 'src/tactical/utilities.bas'
' ... (all tactical modules)

' UI modules
$INCLUDE: 'src/ui/mouse.bas'
' ... (all UI modules)

' Main entry point
$INCLUDE: 'src/main.bas'

' Start the game
Main
```

### Main Function Structure

```qb64
SUB Main
    CALL InitializeGame
    DO
        ' Main menu loop
    LOOP
    CALL CleanupGame
END SUB
```

## Consequences

### Positive
- **Clear entry point**: `WON.BAS` is obvious entry point
- **Separation of concerns**: Module includes separate from game logic
- **Maintainability**: Easy to see include order
- **Flexibility**: Can change main logic without changing includes
- **QB64 compatibility**: Works with QB64 compilation

### Negative
- **Two files**: Entry point split across two files
- **Include management**: Must maintain include order in WON.BAS
- **Complexity**: Slightly more complex than single file

### Neutral
- Game functionality unchanged
- Performance unchanged
- User experience unchanged

## Implementation Notes

- `WON.BAS` is the file opened in QB64
- `WON.BAS` includes all modules in correct order
- `WON.BAS` calls `Main` SUB to start game
- `main.bas` contains all game logic
- Include order documented in WON.BAS comments
- Module dependencies documented in each module

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0015: Module Include Order

