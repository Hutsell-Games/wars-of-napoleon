# ADR-0003: Organize Files into Directory Structure

**Status:** Accepted  
**Date:** 2024-12-15  
**Deciders:** Dave Mackey  
**Git Commit:** ceb988747a06b1ef59570fc4914f0af14b5ead46

## Context

The original project structure had all files in the root directory:
- Source files mixed with data files
- Graphics files mixed with configuration files
- Executables mixed with source code
- No clear separation of concerns
- Difficult to navigate and maintain

This made it difficult to:
- Understand project structure
- Locate specific file types
- Maintain clean repository
- Organize documentation

## Decision

We decided to organize the project into a clear directory structure:

```
wars-of-napoleon/
├── data/              # All game data files
│   ├── graphics/      # Graphics files (.EGA, .VGA)
│   └── scenarios/    # Scenario data files (.MAP, .DAT, .INI)
├── docs/             # Documentation files
├── saved/            # Save game files
└── src/              # Source code (added later)
```

Specific moves:
- All `.DAT`, `.CFG`, `.INI` files → `data/`
- All `.EGA`, `.VGA` files → `data/graphics/`
- All scenario files → `data/scenarios/`
- All `.SAV` files → `saved/`
- All documentation → `docs/`
- Removed legacy executables (`.EXE`)
- Removed legacy build files (`.MAK`, `.BAT`)

## Consequences

### Positive
- **Clear organization**: Easy to find files by type
- **Better maintainability**: Logical grouping of related files
- **Cleaner repository**: Root directory no longer cluttered
- **Easier navigation**: Developers can quickly locate needed files
- **Version control friendly**: Clear structure helps with git operations

### Negative
- **Path updates required**: All file references in code need updating
- **Migration effort**: One-time refactoring required
- **Documentation updates**: Path references in docs need updating

### Neutral
- File formats unchanged
- Game functionality unchanged
- Only organizational change

## Implementation Notes

- All file paths in code updated to use `data/` prefix
- Graphics loading functions updated to use `data/graphics/`
- Scenario loading functions updated to use `data/scenarios/`
- Save game functions updated to use `saved/`
- Documentation references updated

