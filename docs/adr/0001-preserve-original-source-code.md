# ADR-0001: Preserve Original Source Code

**Status:** Accepted  
**Date:** 2021-04-03  
**Deciders:** Dave Mackey  
**Git Commit:** 6e0930f134a3e703f20ed7c1763d61d685ab0528

## Context

The Wars of Napoleon game was originally developed by W.R. Hutsell as a DOS-based wargame with separate executables for strategic (`WON.EXE`) and tactical (`NAPOLEON.EXE`) gameplay. The original source code existed in various forms including:
- `NAPOLEON.BAS` - Main tactical battle module
- `NAP1A.BAS` - Strategic game module
- `NAP1C.BAS` - Additional strategic components
- `NAP10.BI` - Include file with declarations
- Various data files (`.DAT`, `.MAP`, `.INI`, `.CFG`)
- Graphics files (`.EGA`, `.VGA`)

The project needed to be preserved and modernized for future development.

## Decision

We decided to preserve the original source code in its entirety as the canonical source for the recreation project. This includes:
- All original `.BAS` source files
- All data files (scenarios, configuration, save games)
- All graphics files
- Original documentation (`WON.DOC`, `NAPOLEON.DOC`)
- Original executables (for reference, though not used in modern build)

## Consequences

### Positive
- **Complete historical record**: All original code preserved for reference
- **Baseline for modernization**: Original code serves as specification for recreation
- **Backward compatibility**: Original data files can be used with modernized code
- **Documentation source**: Original documentation provides game mechanics details

### Negative
- **Legacy code structure**: Original monolithic structure not suitable for modern development
- **DOS dependencies**: Original code uses DOS-specific features that need modernization
- **File-based communication**: Original dual-executable design uses file I/O for integration

### Neutral
- Original executables preserved but not used in modern build process
- Original documentation preserved but may be superseded by modern docs

## Notes

This decision established the foundation for all subsequent modernization efforts. The original source code serves as the authoritative reference for game mechanics, data formats, and feature behavior.

