# Wars of Napoleon - Full Recreation

A complete recreation of W.R. Hutsell's Wars of Napoleon strategic-tactical wargame, modernized for QB64 with unified architecture.

## Overview

This project recreates the complete Wars of Napoleon game, modernizing the architecture from a dual-executable DOS design to a unified game with direct function calls between strategic and tactical modules.

**Key Features:**
- **Strategic Campaign**: 7 scenarios (1796-1815), 2-month turns, full campaign management
- **Tactical Battles**: Hex-based tactical combat integrated seamlessly with strategic game
- **Cohesion System**: Unique nationality-based combat penalties
- **Modern Enhancements**: Mouse support, PBM, Move Capital, Realism Toggle

## Architecture

### Modern Unified Architecture

- **Before**: File-based (`battle.$$$` → `outcome.&&&`) + process spawning (`SHELL`)
- **After**: Direct function calls with parameters/return values
- **Benefits**: No file I/O overhead, simpler error handling, shared memory

### Code Reuse

- **From CWS**: ~50% of strategic module (campaign, army, economy, victory, reports)
- **From WW2**: ~20% of strategic module (naval, mouse, PBM)
- **Must Build**: ~30% of strategic module (tactical integration, cohesion)
- **Refactor**: ~100% of tactical module (convert NAPOLEON.BAS to function)

## Project Structure

```
wars-of-napoleon/
├── src/
│   ├── main.bas                 # Main entry point
│   ├── common/                  # Common modules
│   │   ├── declarations.bas     # Global declarations
│   │   ├── battle_types.bas     # BattleData, BattleResult types
│   │   ├── game_types.bas       # Game data types
│   │   ├── config.bas           # Configuration management
│   │   └── utilities.bas        # Utility functions
│   ├── strategic/               # Strategic game modules
│   │   ├── campaign.bas         # Campaign management
│   │   ├── army.bas             # Army management
│   │   ├── city.bas             # City/territory control
│   │   ├── naval.bas            # Naval operations
│   │   ├── economy.bas          # Economic system
│   │   ├── victory.bas          # Victory conditions
│   │   ├── reports.bas          # Reports system
│   │   ├── scenario.bas         # Scenario management
│   │   ├── cohesion.bas         # Cohesion system (WON unique)
│   │   ├── tactical_integration.bas # Tactical integration
│   │   ├── combat.bas           # Strategic combat resolution
│   │   ├── move_capital.bas     # Move Capital (CWS)
│   │   ├── realism.bas          # Realism Toggle (CWS)
│   │   └── pbm.bas              # PBM Support (WW2)
│   ├── tactical/                # Tactical battle modules
│   │   ├── battle.bas           # Main tactical battle function
│   │   ├── core.bas             # Battle mechanics
│   │   ├── ui.bas               # Tactical UI
│   │   └── units.bas            # Unit types and behaviors
│   └── ui/                      # User interface modules
│       ├── mouse.bas            # Mouse support (WW2)
│       ├── graphics.bas         # Graphics rendering
│       └── menus.bas            # Menu system
├── data/
│   ├── scenarios/               # Scenario data files
│   └── graphics/                # Graphics files
├── docs/                        # Documentation
├── BUILD_INSTRUCTIONS.md        # Build instructions
├── IMPLEMENTATION_STATUS.md     # Implementation status
└── README.md                    # This file
```

## Building

See `BUILD_INSTRUCTIONS.md` for detailed build instructions.

### Quick Start

1. Install QB64 from https://www.qb64.org/
2. Copy original game files (NAPOLEON.BAS, data files, graphics)
3. Open `src/main.bas` in QB64
4. Compile and run

## Implementation Status

See `IMPLEMENTATION_STATUS.md` for detailed status of all modules.

### Completed ✅

- All Phase 1 modules (Core Strategic)
- All Phase 2 modules (Unique WON Features)
- All Phase 3 modules (Tactical Refactoring structure)
- All Phase 4 modules (Modernization Enhancements)
- All Phase 5 modules (Integration)

### In Progress ⚠️

- NAPOLEON.BAS code integration
- File format analysis and refinement
- Graphics file loading
- Full menu system implementation

## Features

### Strategic Game

- **7 Scenarios**: 1796, 1805, 1807, 1808, 1812, 1813, 1815
- **2-Month Turns**: Matches original game structure
- **Army Management**: Recruitment, movement, combining, RELIEVE command
- **City Control**: Fortification, income, victory points
- **Naval Operations**: Fleet management, combat, bombard, blockade, raid, invasion
- **Economic System**: Income, supply, harvest months (July, September free)
- **Victory Conditions**: 5 end game conditions
- **Reports**: 7 reports including History/Recap

### Unique WON Features

- **Cohesion System**: Nationality-based combat penalties
- **Tactical Integration**: Seamless strategic-tactical battle flow
- **Allied Countries**: At-peace status, auto-activation

### Modern Enhancements

- **Mouse Support**: Full mouse control (ported from WW2)
- **PBM Support**: Play-by-mail file exchange (ported from WW2)
- **Move Capital**: Strategic flexibility (ported from CWS)
- **Realism Toggle**: Historical accuracy options (ported from CWS)

## Documentation

- **Full Recreation Plan**: `docs/FULL_RECREATION_PLAN.md`
- **Strategic Module Analysis**: `docs/STRATEGIC_MODULE_RECREATION_ANALYSIS.md`
- **Strategic-Tactical Integration**: `docs/STRATEGIC_TACTICAL_INTEGRATION.md`
- **Feature Analysis**: `docs/FINAL_FEATURE_ANALYSIS.md`
- **Build Instructions**: `BUILD_INSTRUCTIONS.md`
- **Implementation Status**: `IMPLEMENTATION_STATUS.md`

## License

Based on original game by W.R. Hutsell. See LICENSE file for details.

## Credits

- **Original Game**: W.R. Hutsell
- **Recreation**: Modernized architecture and QB64 implementation
- **Code Sources**: 
  - Civil War Strategy (CWS) - Strategic module base
  - World War 2 (WW2) - Naval, mouse, PBM features
  - Wars of Napoleon (WON) - Original tactical module

---

*For questions or issues, refer to the documentation in the `docs/` directory.*
