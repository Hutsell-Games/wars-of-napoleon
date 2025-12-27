# ADR-0004: Unified Architecture - Single Executable

**Status:** Accepted  
**Date:** 2025-12-25  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The original Wars of Napoleon used a dual-executable architecture:
- **Strategic Module**: `WON.EXE` - Campaign management, army movement, city control
- **Tactical Module**: `NAPOLEON.EXE` - Hex-based tactical battles
- **Integration**: File-based communication
  - Strategic writes `BATTLE.$$$` with battle parameters
  - Strategic spawns `NAPOLEON.EXE` via `SHELL` command
  - Tactical reads `BATTLE.$$$`, runs battle, writes `OUTCOME.&&&`
  - Strategic reads `OUTCOME.&&&` to get battle results

This design had several problems:
- **File I/O overhead**: Reading/writing battle files for every battle
- **Process spawning**: `SHELL` command overhead and complexity
- **Error handling**: Difficult to handle errors across process boundaries
- **State management**: No shared memory between modules
- **Debugging**: Difficult to debug across executables

## Decision

We decided to refactor to a unified single-executable architecture:
- **Single Entry Point**: `src/main.bas` / `WON.BAS`
- **Direct Function Calls**: Strategic calls tactical functions directly
- **Shared Memory**: All game state in shared variables
- **Structured Integration**: `tactical_integration.bas` module bridges layers
- **No File I/O**: Battle data passed as parameters, results returned as values

Architecture:
```
Strategic Layer (campaign.bas, army.bas, etc.)
    ↓ (function call)
Tactical Integration (tactical_integration.bas)
    ↓ (function call)
Tactical Layer (battle.bas, core.bas, etc.)
    ↓ (return value)
Tactical Integration
    ↓ (return value)
Strategic Layer (updates game state)
```

## Consequences

### Positive
- **Performance**: No file I/O overhead, faster battle transitions
- **Simplicity**: Direct function calls easier to understand and debug
- **Error handling**: Can use standard error handling patterns
- **State sharing**: Shared memory allows better state management
- **Testing**: Easier to unit test individual functions
- **Maintainability**: Single codebase easier to maintain

### Negative
- **Refactoring effort**: Significant code restructuring required
- **Integration complexity**: Need careful data conversion between layers
- **Memory management**: All code loaded into single executable (larger binary)
- **Coupling**: Strategic and tactical layers more tightly coupled

### Neutral
- Game mechanics unchanged
- Data formats unchanged
- User experience unchanged

## Implementation Notes

- Created `src/strategic/tactical_integration.bas` as bridge module
- Battle data converted from strategic format (men) to tactical format (hundreds)
- Battle results converted back from tactical to strategic format
- Error handling allows fallback to strategic resolution if tactical fails
- All file-based communication removed

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0006: Strategic-Tactical Data Conversion

