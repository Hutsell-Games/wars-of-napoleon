# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Tactical Battle System Enhancements
- **Complete GOSUB to SUB Refactoring** (`src/tactical/napoleon_subs.bas`)
  - Converted all GOSUB routines to proper SUB/FUNCTION procedures
  - Eliminated GOTO-based flow control in favor of structured programming
  - Key conversions:
    - `xxyy` → `CalculateXY()` SUB
    - `odd` → `CheckOddHex()` SUB
    - `rloc` → `RandomLocation()` SUB
    - `nearhere` → `MoveNearHere()` SUB
    - `adjx` → `AdjustHexX()` SUB
    - `lim1` → `CheckLimits()` SUB
    - `eval` → `EvaluateLocation%()` FUNCTION
    - `hold8` → `WaitForKey()` SUB
    - `fog` → `FormatUnitStats()` SUB
    - `run1` → `CheckRunLocation()` SUB
    - `tim1` → `UpdateTimeDisplay()` SUB
    - `franks` → `PlayFranksSound()` SUB
    - `yanks` → `PlayYanksSound()` SUB
    - `crsr` → `GetMenuKey()` SUB
    - `limits` → `LimitRow()` SUB
    - `mxw` → `CalculateMenuWidth()` SUB
    - `noadjust` → `AdjustMenuPosition()` SUB
- **Enhanced Battle Initialization** (`src/tactical/battle.bas`)
  - Comprehensive parameter validation before battle start
  - Improved error handling with fallback to strategic resolution
  - Critical vs non-critical error distinction
  - Enhanced documentation of data conversion between strategic and tactical layers
- **Tactical Battle Documentation** (`src/tactical/battle.bas`, `src/tactical/napoleon_subs.bas`)
  - Extensive inline documentation for all major functions
  - Data flow documentation between strategic and tactical layers
  - Error handling patterns documented
  - Initialization sequence clearly documented

#### Mouse Support Implementation
- **Full Mouse Support** (`src/ui/mouse.bas`)
  - `GetMouseX%()` - Returns mouse X coordinate using QB64 `_MOUSEX`
  - `GetMouseY%()` - Returns mouse Y coordinate using QB64 `_MOUSEY`
  - `GetMouseButton%()` - Returns current mouse button state
  - `GetMouseButtonClick%()` - Detects single button clicks (not held)
  - `ProcessMouseInput()` - Processes mouse input events in game loop
  - `IsMouseAvailable%()` - Checks if mouse is available
  - Proper QB64 mouse API integration with `_MOUSEINPUT` checks

#### Graphics System Improvements
- **Graphics Loading Functions** (`src/ui/graphics.bas`)
  - `LoadGraphicsFile%()` - Loads graphics files using QB64 BLOAD
  - Proper error handling for missing graphics files
  - Support for `data/graphics/` directory structure
  - QB64-compatible graphics loading (no DEF SEG needed)

#### File Organization
- **Data Directory Structure**
  - All game data files moved to `data/` directory:
    - `ALLIES.DAT` → `data/ALLIES.DAT`
    - `FRENCH.DAT` → `data/FRENCH.DAT`
    - `EQUIP.DAT` → `data/EQUIP.DAT`
    - `QUOTES.DAT` → `data/QUOTES.DAT`
    - `HISCORE.NWS` → `data/HISCORE.NWS`
    - `NWS.CFG` → `data/NWS.CFG`
    - `PREFER.CFG` → `data/PREFER.CFG`
    - `SETUP.INI` → `data/SETUP.INI`
    - `GAMEDATA.INI` → `data/GAMEDATA.INI`
    - `BATTLE.$$$` → `data/BATTLE.$$$`
    - `OUTCOME.&&&` → `data/OUTCOME.&&&`
    - `BATTSUMM` → `data/BATTSUMM`
    - `GENERALZ` → `data/GENERALZ`
    - `MAXSKORS` → `data/MAXSKORS`
- **Saved Games Directory**
  - `NWS9.SAV` → `saved/NWS9.SAV`
  - New `saved/` directory for all save game files

#### Code Quality Improvements
- **Standardized Error Handling System** (`src/common/error_handling.bas`)
  - `HandleCriticalError()` - For critical errors that prevent operation
  - `HandleValidationError()` - For invalid input/state validation
  - `HandleFileNotFound()` - For missing required files
  - `HandleWarning()` - For non-critical warnings (continues execution)
  - `ValidateArmyIndex%()`, `ValidateCityIndex%()`, `ValidateArmySide%()` - Validation helpers
  - Comprehensive documentation in `ERROR_HANDLING_STANDARD.md`
- **Reusable Utility Functions** (`src/common/utilities.bas`)
  - `ShowStatusMessage()`, `ShowStatusError()`, `ShowStatusWarning()` - Standardized message display
  - `GetArmySide%()` - Centralized side determination logic
  - Consistent use of `ClampValue%()` and `ClampValueLong&()` for value validation

### Fixed

#### Code Duplication Elimination
- **Message Display Patterns**: Extracted repeated `COLOR X: CALL clrbot: PRINT` patterns into standardized functions
  - Applied to: `battle.bas`, `tactical_integration.bas`, `city.bas`, `scenario.bas`, `campaign.bas`, `pbm.bas`, `reports.bas`
- **Side Determination Logic**: Extracted repeated `IF armyIndex >= FRENCH_START AND armyIndex < ALLIED_START` checks into `GetArmySide%()` function
  - Applied to: `tactical_integration.bas`, `army.bas`, `combat.bas`, `economy.bas`, `commands.bas`
- **Value Clamping**: Standardized use of `ClampValue%()` and `ClampValueLong&()` functions
  - Applied to: `battle.bas` for fort, obstruct, expVal, leadVal, and casualty calculations
- **File Existence Checks**: Removed redundant duplicate checks (both `FileExists%()` and `_FILEEXISTS()`)

#### Error Handling Standardization
- **Consistent Error Patterns**: All error handling now uses standardized functions
  - Critical errors: `HandleCriticalError()` + EXIT
  - Validation errors: `HandleValidationError()` + EXIT
  - File not found: `HandleFileNotFound()` + EXIT
  - Warnings: `HandleWarning()` (continues execution)
- **Function Name Conflicts**: Resolved conflict between `utilities.bas` and `menus.bas` message functions
  - Renamed utilities functions to `ShowStatusMessage`, `ShowStatusError`, `ShowStatusWarning`
  - All calls updated throughout codebase

#### Code Review Fixes (GOSUB/GOTO Refactoring)
- **EvaluateLocation - GOTO to label in different SUB**
  - Fixed: Changed `GOTO improve` (which was in different SUB) to FUNCTION that returns 1 if location should trigger improve, 0 otherwise
  - Impact: Prevents compile/runtime error, maintains functionality

- **AwakenUnit - Missing parameter**
  - Fixed: Added `id AS INTEGER, xloc AS INTEGER, yloc AS INTEGER` parameters
  - Impact: Fixes undefined variable error

- **WaitForKeypress - Recursion risk**
  - Fixed: Converted recursive calls to DO...LOOP structure
  - Impact: Prevents potential stack overflow, improves performance

- **Duplicate END SUB**
  - Fixed: Removed extra `END SUB` after `CheckOddHex` SUB definition
  - Impact: Prevents compile error

- **Missing variable declarations**
  - Fixed: Added `DIM flag AS INTEGER` and `DIM spin AS INTEGER` in `randmap` SUB
  - Fixed: Moved `DIM flag AS INTEGER` before first use in `randarm` SUB
  - Impact: Prevents undefined variable errors, ensures proper variable scoping

#### Code Quality Improvements (Previous)
- Eliminated recursion in `WaitForKeypress` - safer and more efficient
- Proper function return values - `EvaluateLocation` now returns a value instead of using GOTO
- Explicit parameter passing - `AwakenUnit` now properly receives all needed parameters
- Proper variable declarations - All variables now properly declared in correct scope

#### Code Quality Improvements (Latest)
- Eliminated code duplication across 12+ files
- Standardized error handling patterns throughout codebase
- Improved maintainability with reusable helper functions
- Consistent error messages and validation
- Reduced code complexity through function extraction

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
- **NAPOLEON.BAS → napoleon_subs.bas**: Major refactoring and modernization
  - Renamed from `NAPOLEON.BAS` to `src/tactical/napoleon_subs.bas`
  - Integration with new modular architecture
  - Updated to work with unified game structure
  - All GOSUB routines converted to SUB/FUNCTION procedures
  - Improved error handling throughout
  - Enhanced documentation
- **File Path Updates**: All file references updated to use `data/` prefix
  - Updated in: `battle.bas`, `napoleon_subs.bas`, `victory.bas`, `scenario.bas`
  - Consistent use of `data/` directory for all data files
  - QB64-compatible file existence checks using `_FILEEXISTS()`
- **Tactical Integration** (`src/strategic/tactical_integration.bas`)
  - Enhanced error handling for battle initialization failures
  - Improved validation of army indices and sides
  - Better documentation of data conversion between layers
  - Fallback to strategic resolution if tactical battle fails
  - Commander availability tracking added
- **Scenario Loading** (`src/strategic/scenario.bas`)
  - Updated file references to use `data/scenarios/` directory
  - Improved error handling with `HandleFileNotFound()`
  - Standardized status messages using `ShowStatusMessage()`
  - Documentation references updated from `WON.DOC` to `WON.TXT`
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

- **Legacy executable files** (replaced by QB64 source compilation):
  - `ARCH2.EXE` - Legacy executable (121,104 bytes)
  - `NAPIC.EXE` - Legacy executable (89,424 bytes)
  - `NAPOLEON.EXE` - Legacy executable (96,571 bytes)
  - `TACTICAL.EXE` - Legacy executable (46,967 bytes)
  - `VIC.EXE` - Legacy executable (48,885 bytes)
  - `WON.EXE` - Legacy executable (114,795 bytes)
- **Legacy build files**:
  - `NAPOLEON.MAK` - Legacy makefile (3 lines)
  - `GO.BAT` - Legacy batch file (1 line)
  - `PRINTDOC.BAT` - Legacy batch file (11 lines)
- **Legacy include files**:
  - `NAP10.BI` - Replaced by `src/common/declarations.bas` (110 lines)
- **Legacy documentation files**:
  - `NAPOLEON.PAG` - Legacy pagination file (935 lines)
  - `NAPOLEON.TXT` - Legacy text file (829 lines)
  - `SHAREW.TXT` - Legacy shareware text (77 lines)
  - `REGISTER.DOC` - Legacy registration document (2,647 bytes)
- **Legacy source files**:
  - `NAP1A.BAS` - Replaced by modular structure (1308 lines removed)
  - `NAP1C.BAS` - Replaced by modular structure (116 lines removed)
- **Legacy documentation**:
  - `WRHGAMES.DOC` - Replaced by modern documentation (114 lines removed)
- **Temporary files**:
  - `~QBLNK.TMP` - QB64 temporary file (6 lines removed)
- **Root-level data files** (moved to `data/` directory):
  - All `*.DAT` files → `data/`
  - All `*.CFG` files → `data/`
  - All `*.INI` files → `data/`
  - All temporary battle files → `data/`
- **Root-level scenario files** (moved to `data/scenarios/`):
  - `EURO1796.MAP`
  - `EURO1807.MAP`
  - `EURO1808.MAP`
  - `EURO1812.MAP`
  - `EURO1813.MAP`
- **Documentation file renames**:
  - `WON.DOC` → `WON.TXT` (updated format and location)
  - `NAPOLEON.DOC` → `TACTICAL.TXT` (renamed for clarity)

### Technical Details

#### Architecture Improvements
- **Before**: Monolithic files with file-based communication
- **After**: Modular architecture with direct function calls
- **Benefits**:
  - Better code organization and maintainability
  - Easier testing and debugging
  - Improved code reuse
  - Clear separation of concerns

#### Technical Improvements (This Update)
- **Structured Programming**: Complete elimination of GOSUB/GOTO patterns in tactical code
  - All flow control now uses proper SUB/FUNCTION procedures
  - Improved code readability and maintainability
  - Better error handling capabilities
- **File System Organization**: Consistent directory structure
  - All data files in `data/` directory
  - All saved games in `saved/` directory
  - All scenarios in `data/scenarios/` directory
  - Easier file management and backup
- **QB64 Compatibility**: Full QB64 API usage
  - `_FILEEXISTS()` for file existence checks
  - `_MOUSEX`, `_MOUSEY`, `_MOUSEBUTTON()` for mouse support
  - `_MOUSEINPUT` for mouse event processing
  - Proper BLOAD usage without DEF SEG
- **Error Handling**: Enhanced error recovery
  - Tactical battle failures fall back to strategic resolution
  - File loading errors handled gracefully
  - Validation prevents invalid state transitions

#### Code Statistics
- **Total changes**: 58 files changed (this update)
- **Additions**: 2,751 lines added (this update)
- **Deletions**: 2,731 lines removed (this update)
- **Net change**: +20 lines (this update)
- **Cumulative changes**: 131+ files changed
- **Cumulative additions**: 10,915+ lines added
- **Cumulative deletions**: 4,355+ lines removed
- **Cumulative net change**: +6,560+ lines

#### Module Breakdown
- **Common modules**: 6 files, ~666 lines
- **Strategic modules**: 15 files, ~3,000+ lines
- **Tactical modules**: 4 files, ~815 lines
- **UI modules**: 3 files, ~680 lines
- **Main entry**: 1 file, ~780 lines

---

## Notes

This changelog entry represents a major architectural refactoring that modernizes the codebase from a monolithic structure to a modular, maintainable architecture. The reorganization maintains backward compatibility with game data files while significantly improving code organization and maintainability.

