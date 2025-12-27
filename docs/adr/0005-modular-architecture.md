# ADR-0005: Modular Architecture

**Status:** Accepted  
**Date:** 2025-12-25  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The original codebase was organized as monolithic files:
- `NAPOLEON.BAS` - 2005+ lines, all tactical battle code
- `NAP1A.BAS` - 1308 lines, strategic game code
- `NAP1C.BAS` - 116 lines, additional strategic code
- `NAP10.BI` - Include file with declarations

This structure had problems:
- **Hard to navigate**: Large files difficult to understand
- **Poor separation of concerns**: Related functionality scattered
- **Difficult to test**: Can't test individual components
- **Code duplication**: Similar code repeated across files
- **Maintenance burden**: Changes affect large portions of code

## Decision

We decided to refactor into a modular architecture with clear separation of concerns:

```
src/
├── main.bas                    # Entry point
├── common/                     # Shared utilities and types
│   ├── declarations.bas        # Global declarations
│   ├── battle_types.bas       # Battle data structures
│   ├── game_types.bas        # Game data types
│   ├── config.bas            # Configuration management
│   ├── utilities.bas         # Utility functions
│   └── error_handling.bas    # Error handling system
├── strategic/                  # Strategic game modules
│   ├── campaign.bas          # Campaign management
│   ├── army.bas              # Army management
│   ├── city.bas              # City/territory control
│   ├── naval.bas             # Naval operations
│   ├── economy.bas           # Economic system
│   ├── victory.bas           # Victory conditions
│   ├── reports.bas           # Reports system
│   ├── scenario.bas          # Scenario management
│   ├── cohesion.bas          # Cohesion system (WON unique)
│   ├── tactical_integration.bas # Strategic-tactical bridge
│   ├── combat.bas            # Strategic combat resolution
│   ├── commands.bas          # Command processing
│   ├── move_capital.bas      # Move Capital feature
│   ├── realism.bas           # Realism toggle
│   └── pbm.bas               # Play-by-mail support
├── tactical/                   # Tactical battle modules
│   ├── battle.bas            # Main tactical battle function
│   ├── core.bas              # Battle mechanics
│   ├── units.bas             # Unit types and behaviors
│   ├── terrain.bas           # Terrain system
│   ├── ai.bas                # AI opponent
│   ├── ui.bas                # Tactical UI
│   ├── combat.bas            # Tactical combat resolution
│   ├── orders.bas            # Order processing
│   ├── unit_management.bas   # Unit management
│   ├── unit_placement.bas    # Unit placement
│   ├── utilities.bas         # Tactical utilities
│   └── napoleon_subs.bas     # Refactored NAPOLEON.BAS
└── ui/                        # User interface modules
    ├── graphics.bas          # Graphics rendering
    ├── menus.bas             # Menu system
    └── mouse.bas             # Mouse support
```

## Consequences

### Positive
- **Clear organization**: Easy to find code by functionality
- **Separation of concerns**: Each module has single responsibility
- **Testability**: Individual modules can be tested independently
- **Maintainability**: Changes isolated to specific modules
- **Code reuse**: Common functionality in shared modules
- **Documentation**: Each module can be documented independently

### Negative
- **Refactoring effort**: Significant restructuring required
- **Dependency management**: Need to manage module dependencies
- **File count**: More files to manage (but better organized)
- **Include order**: Must include modules in correct order

### Neutral
- Game functionality unchanged
- Performance characteristics similar
- User experience unchanged

## Implementation Notes

- Modules organized by layer (common, strategic, tactical, ui)
- Each module has clear responsibility
- Common utilities extracted to shared modules
- Error handling standardized across modules
- Documentation added to each module

## Related ADRs

- ADR-0004: Unified Architecture
- ADR-0007: Structured Programming (GOSUB to SUB)

