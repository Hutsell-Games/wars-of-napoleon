# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Project Structure
- **New modular architecture**: Complete reorganization of codebase into structured directories
  - `src/` directory with organized module structure:
    - `src/common/` - Shared utilities and type definitions
      - `battle_types.bas` - Battle data structures
      - `config.bas` - Configuration management
      - `declarations.bas` - Global declarations
      - `game_state_helpers.bas` - Game state utility functions
      - `game_types.bas` - Core game data types
      - `utilities.bas` - General utility functions
    - `src/strategic/` - Strategic game modules
      - `army.bas` - Army management
      - `campaign.bas` - Campaign management
      - `city.bas` - City and territory control
      - `cohesion.bas` - Cohesion system (WON unique feature)
      - `combat.bas` - Strategic combat resolution
      - `commands.bas` - Command processing
      - `economy.bas` - Economic system
      - `move_capital.bas` - Move Capital feature
      - `naval.bas` - Naval operations
      - `pbm.bas` - Play-by-mail support
      - `realism.bas` - Realism toggle feature
      - `reports.bas` - Reports system
      - `scenario.bas` - Scenario management
      - `tactical_integration.bas` - Strategic-tactical integration
      - `victory.bas` - Victory conditions
    - `src/tactical/` - Tactical battle modules
      - `battle.bas` - Main tactical battle function
      - `core.bas` - Battle mechanics
      - `ui.bas` - Tactical user interface
      - `units.bas` - Unit types and behaviors
    - `src/ui/` - User interface modules
      - `graphics.bas` - Graphics rendering
      - `menus.bas` - Menu system
      - `mouse.bas` - Mouse support
    - `src/main.bas` - Main entry point
- **Data organization**: New `data/` directory structure
  - `data/graphics/` - All graphics files (EGA/VGA)
  - `data/scenarios/` - All scenario data files
- **New main entry point**: `WON.BAS` - Entry point for the unified game
- **Configuration**: `.cursorrules` - Cursor IDE configuration
- **Documentation**: `cursor/commands/review-code.md` - Code review command documentation

#### Data Files
- Scenario map files moved to `data/scenarios/`:
  - `EURO1796.MAP` (new location)
  - `EURO1807.MAP` (new location)
  - `EURO1808.MAP` (new location)
  - `EURO1812.MAP` (new location)
  - `EURO1813.MAP` (new location)
- All scenario data files (LEAD*.DAT, NWS*.INI) moved to `data/scenarios/`

### Changed

#### Code Refactoring
- **NAPOLEON.BAS**: Major refactoring and modernization (1537+ lines added)
  - Integration with new modular architecture
  - Updated to work with unified game structure
- **NAP10.BI**: Updated include file with 21+ changes
  - Compatibility with new module structure
  - Updated type definitions

#### Documentation
- **README.md**: Comprehensive update (158+ lines changed)
  - Added modern architecture overview
  - Documented new project structure
  - Added build instructions reference
  - Updated feature documentation
  - Added implementation status section

#### File Organization
- **Graphics files**: All moved to `data/graphics/`
  - `ALTICON.EGA` → `data/graphics/ALTICON.EGA`
  - `MISC.EGA` → `data/graphics/MISC.EGA`
  - `MTN.VGA` → `data/graphics/MTN.VGA`
  - `NAP1.EGA` → `data/graphics/NAP1.EGA`
  - `NAP2.EGA` → `data/graphics/NAP2.EGA`
  - `NAPICON.VGA` → `data/graphics/NAPICON.VGA`
  - `STDICON.EGA` → `data/graphics/STDICON.EGA`
  - `TERRAIN.EGA` → `data/graphics/TERRAIN.EGA`
- **Scenario files**: All moved to `data/scenarios/`
  - `EURO1805.MAP` → `data/scenarios/EURO1805.MAP`
  - `EURO1815.MAP` → `data/scenarios/EURO1815.MAP`
  - All `LEAD*.DAT` files → `data/scenarios/`
  - All `NWS*.INI` files → `data/scenarios/`

### Removed

- **Legacy source files**:
  - `NAP1A.BAS` - Replaced by modular structure (1308 lines removed)
  - `NAP1C.BAS` - Replaced by modular structure (116 lines removed)
- **Legacy documentation**:
  - `WRHGAMES.DOC` - Replaced by modern documentation (114 lines removed)
- **Temporary files**:
  - `~QBLNK.TMP` - QB64 temporary file (6 lines removed)
- **Root-level scenario files** (moved to `data/scenarios/`):
  - `EURO1796.MAP`
  - `EURO1807.MAP`
  - `EURO1808.MAP`
  - `EURO1812.MAP`
  - `EURO1813.MAP`

### Technical Details

#### Architecture Improvements
- **Before**: Monolithic files with file-based communication
- **After**: Modular architecture with direct function calls
- **Benefits**:
  - Better code organization and maintainability
  - Easier testing and debugging
  - Improved code reuse
  - Clear separation of concerns

#### Code Statistics
- **Total changes**: 73 files changed
- **Additions**: 8,164 lines added
- **Deletions**: 1,624 lines removed
- **Net change**: +6,540 lines

#### Module Breakdown
- **Common modules**: 6 files, ~666 lines
- **Strategic modules**: 15 files, ~3,000+ lines
- **Tactical modules**: 4 files, ~815 lines
- **UI modules**: 3 files, ~680 lines
- **Main entry**: 1 file, ~780 lines

---

## Notes

This changelog entry represents a major architectural refactoring that modernizes the codebase from a monolithic structure to a modular, maintainable architecture. The reorganization maintains backward compatibility with game data files while significantly improving code organization and maintainability.

