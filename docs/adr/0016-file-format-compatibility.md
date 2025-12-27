# ADR-0016: File Format Compatibility

**Status:** Accepted  
**Date:** 2021-04-03 (implicit, based on preservation decision)  
**Deciders:** Dave Mackey  
**Git Commit:** 6e0930f134a3e703f20ed7c1763d61d685ab0528

## Context

The original Wars of Napoleon game used specific file formats:
- **Save games**: `NWSx.SAV` (x = 1-8) + autosave `NWS9.SAV`
- **Configuration**: `NWS.CFG`
- **Scenario data**: `NWSxxxx.INI`, `LEADxxxx.DAT`, `EUROxxxx.MAP`
- **Game data**: `ALLIES.DAT`, `FRENCH.DAT`, `EQUIP.DAT`, `QUOTES.DAT`
- **Graphics**: `.EGA`, `.VGA` binary formats
- **Temporary battle files**: `BATTLE.$$$`, `OUTCOME.&&&` (legacy, no longer used)

Users may have:
- Existing save games from original game
- Custom scenarios
- Modified configuration files
- High score files

The recreation project needed to decide whether to:
- Maintain compatibility with original file formats
- Create new file formats
- Support both (migration path)

## Decision

We decided to maintain full backward compatibility with original file formats:

### File Format Compatibility

1. **Save Games**: 
   - Maintain `NWSx.SAV` format (x = 1-8)
   - Maintain `NWS9.SAV` autosave format
   - Original save games can be loaded in modernized game

2. **Configuration**:
   - Maintain `NWS.CFG` format
   - Maintain `PREFER.CFG` format
   - Maintain `SETUP.INI` format
   - Original configuration files work with modernized game

3. **Scenario Data**:
   - Maintain `NWSxxxx.INI` format
   - Maintain `LEADxxxx.DAT` format
   - Maintain `EUROxxxx.MAP` format
   - Original scenario files work with modernized game

4. **Game Data**:
   - Maintain `ALLIES.DAT` format
   - Maintain `FRENCH.DAT` format
   - Maintain `EQUIP.DAT` format
   - Maintain `QUOTES.DAT` format
   - Original data files work with modernized game

5. **Graphics**:
   - Maintain `.EGA` format
   - Maintain `.VGA` format
   - Original graphics files work with modernized game

6. **Legacy Files** (no longer used but preserved):
   - `BATTLE.$$$` - No longer used (unified architecture)
   - `OUTCOME.&&&` - No longer used (unified architecture)
   - Files preserved for reference but not used in modern build

### File Location Changes

While maintaining format compatibility, files are organized in directories:
- Data files → `data/`
- Graphics files → `data/graphics/`
- Scenario files → `data/scenarios/`
- Save games → `saved/`

## Consequences

### Positive
- **User continuity**: Users can continue existing games
- **Data preservation**: No data loss during migration
- **Backward compatibility**: Original files work with modernized game
- **Community support**: Users can share save games, scenarios
- **Migration ease**: No complex migration process needed

### Negative
- **Legacy constraints**: Must maintain compatibility with old formats
- **Format limitations**: Cannot easily improve file formats
- **Testing burden**: Must test with original file formats
- **Documentation**: Must document original file formats

### Neutral
- Game functionality unchanged
- Performance unchanged
- User experience unchanged (except file locations)

## Implementation Notes

- All file I/O code maintains original format compatibility
- File format reading/writing code preserved from original
- File locations updated but formats unchanged
- Original save games can be loaded
- Original scenarios can be used
- Graphics files work with modernized code

## Related ADRs

- ADR-0001: Preserve Original Source Code
- ADR-0003: Organize Files into Directory Structure
- ADR-0004: Unified Architecture (removed need for BATTLE.$$$ / OUTCOME.&&&)

