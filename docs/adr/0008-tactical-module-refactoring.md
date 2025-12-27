# ADR-0008: Tactical Module Refactoring

**Status:** Accepted  
**Date:** 2025-12-26  
**Deciders:** Dave Mackey  
**Git Commit:** f9cf5ae963d2a85436559ccc7d105aada50e5cd4

## Context

After converting GOSUB/GOTO to structured programming (ADR-0007), the tactical battle code in `napoleon_subs.bas` was still a large monolithic file (3467+ lines). The code needed further organization into logical modules:

- **Battle mechanics**: Core battle loop, turn processing
- **Unit management**: Unit creation, movement, combat
- **Terrain system**: Hex map, terrain effects, movement costs
- **AI system**: Computer opponent logic
- **UI system**: Display, menus, input handling
- **Combat resolution**: Tactical combat calculations
- **Order processing**: Unit orders, movement orders
- **Unit placement**: Initial unit placement on map

## Decision

We decided to split the tactical module into focused, single-responsibility modules:

```
src/tactical/
├── battle.bas              # Main battle entry point, initialization
├── core.bas                # Core battle mechanics, turn loop
├── units.bas               # Unit types, unit data structures
├── terrain.bas             # Terrain system, hex map, terrain effects
├── ai.bas                  # AI opponent logic, computer player
├── ui.bas                  # Tactical UI, display, menus
├── combat.bas              # Tactical combat resolution
├── orders.bas              # Order processing, unit orders
├── unit_management.bas     # Unit creation, updates, removal
├── unit_placement.bas     # Initial unit placement
├── utilities.bas           # Tactical utility functions
└── napoleon_subs.bas      # Legacy code (being phased out)
```

### Module Responsibilities

- **battle.bas**: Battle initialization, parameter validation, battle entry/exit
- **core.bas**: Main battle loop, turn sequence, phase management
- **units.bas**: Unit type definitions, unit data structures
- **terrain.bas**: Hex map, terrain types, movement costs, terrain effects
- **ai.bas**: AI decision making, unit selection, movement planning
- **ui.bas**: Screen display, menu system, input handling
- **combat.bas**: Combat calculations, damage, casualties
- **orders.bas**: Order processing, movement orders, attack orders
- **unit_management.bas**: Unit lifecycle, creation, updates, removal
- **unit_placement.bas**: Initial placement logic, deployment zones
- **utilities.bas**: Helper functions, calculations, conversions

## Consequences

### Positive
- **Single responsibility**: Each module has clear purpose
- **Easier navigation**: Developers can find code quickly
- **Better testing**: Modules can be tested independently
- **Reduced complexity**: Smaller files easier to understand
- **Parallel development**: Multiple developers can work on different modules
- **Code reuse**: Utility functions shared across modules

### Negative
- **Refactoring effort**: Significant code splitting required
- **Dependency management**: Need to manage inter-module dependencies
- **Interface design**: Must design good module interfaces
- **File count**: More files to manage (but better organized)

### Neutral
- Game functionality unchanged
- Performance characteristics unchanged
- User experience unchanged

## Implementation Notes

- Modules split based on functionality, not file size
- Clear interfaces between modules
- Common utilities extracted to shared modules
- Documentation added to each module
- Legacy `napoleon_subs.bas` kept for reference during transition

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0007: Structured Programming

