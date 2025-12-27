# ADR-0015: Module Include Order

**Status:** Accepted  
**Date:** 2025-12-25 (implicit, based on code structure)  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

QB64 requires specific ordering of code elements:
- CONST declarations must come before SUB/FUNCTION declarations
- TYPE definitions must be declared before use
- Module dependencies must be included in correct order
- Shared variables must be declared before use

The codebase has multiple modules with dependencies:
- Common modules (declarations, types, utilities)
- Strategic modules (campaign, army, city, etc.)
- Tactical modules (battle, core, units, etc.)
- UI modules (graphics, menus, mouse)

Modules have dependencies:
- Strategic modules depend on common modules
- Tactical modules depend on common modules
- UI modules depend on common modules
- Some modules depend on other strategic/tactical modules

## Decision

We decided to establish a strict module include order:

### Include Order (in WON.BAS / main.bas)

1. **Common Layer** (foundation):
   - `src/common/declarations.bas` - All CONST, SHARED variables, TYPE definitions
   - `src/common/battle_types.bas` - Battle-related types
   - `src/common/game_types.bas` - Game data types
   - `src/common/config.bas` - Configuration management
   - `src/common/utilities.bas` - Utility functions
   - `src/common/error_handling.bas` - Error handling system
   - `src/common/game_state_helpers.bas` - Game state helpers
   - `src/common/performance_cache.bas` - Performance caching

2. **Strategic Layer** (depends on common):
   - `src/strategic/scenario.bas` - Scenario management
   - `src/strategic/campaign.bas` - Campaign management
   - `src/strategic/army.bas` - Army management
   - `src/strategic/city.bas` - City control
   - `src/strategic/cohesion.bas` - Cohesion system
   - `src/strategic/economy.bas` - Economic system
   - `src/strategic/naval.bas` - Naval operations
   - `src/strategic/victory.bas` - Victory conditions
   - `src/strategic/reports.bas` - Reports system
   - `src/strategic/combat.bas` - Strategic combat
   - `src/strategic/tactical_integration.bas` - Tactical integration
   - `src/strategic/commands.bas` - Command processing
   - `src/strategic/move_capital.bas` - Move Capital
   - `src/strategic/realism.bas` - Realism toggle
   - `src/strategic/pbm.bas` - PBM support

3. **Tactical Layer** (depends on common, may depend on strategic):
   - `src/tactical/utilities.bas` - Tactical utilities
   - `src/tactical/terrain.bas` - Terrain system
   - `src/tactical/units.bas` - Unit types
   - `src/tactical/unit_placement.bas` - Unit placement
   - `src/tactical/unit_management.bas` - Unit management
   - `src/tactical/combat.bas` - Tactical combat
   - `src/tactical/orders.bas` - Order processing
   - `src/tactical/ai.bas` - AI opponent
   - `src/tactical/ui.bas` - Tactical UI
   - `src/tactical/core.bas` - Core battle mechanics
   - `src/tactical/battle.bas` - Battle entry point
   - `src/tactical/napoleon_subs.bas` - Legacy code

4. **UI Layer** (depends on common, may depend on strategic):
   - `src/ui/mouse.bas` - Mouse support
   - `src/ui/graphics.bas` - Graphics rendering
   - `src/ui/menus.bas` - Menu system

5. **Main Entry Point**:
   - `src/main.bas` - Main game logic, initialization, menu loop

### Module Documentation Pattern

Each module documents its dependencies:
```qb64
' Note: game_types.bas is included in main.bas
' Note: army.bas, city.bas are included in main.bas
```

## Consequences

### Positive
- **Correct compilation**: Code compiles without errors
- **Clear dependencies**: Module dependencies are explicit
- **Maintainability**: Easy to understand module relationships
- **Documentation**: Include order documented in each module
- **Predictability**: Consistent include order across project

### Negative
- **Rigidity**: Must maintain strict include order
- **Dependency management**: Changes to dependencies affect include order
- **Complexity**: Many modules with complex dependencies

### Neutral
- Game functionality unchanged
- Performance unchanged
- User experience unchanged

## Implementation Notes

- Include order enforced in `WON.BAS` / `main.bas`
- Each module documents its dependencies in comments
- CONST declarations in `declarations.bas` (included first)
- TYPE definitions in common modules (included early)
- Dependencies documented in module headers

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0014: QB64 Syntax Constraints

