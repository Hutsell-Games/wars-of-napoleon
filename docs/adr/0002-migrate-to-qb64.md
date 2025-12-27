# ADR-0002: Migrate to QB64

**Status:** Accepted  
**Date:** 2021-04-03 (implicit, based on project structure)  
**Deciders:** Dave Mackey  
**Git Commit:** Initial project setup

## Context

The original Wars of Napoleon was developed for DOS using QBASIC/QuickBASIC, which:
- Required DOS environment to run
- Used legacy graphics modes (SCREEN 12, EGA/VGA)
- Had file I/O limitations
- Required separate executables for strategic and tactical modules
- Used process spawning (`SHELL`) for module communication

Modern development requires:
- Cross-platform compatibility
- Modern graphics support
- Better error handling
- Unified executable architecture
- Improved development tooling

## Decision

We decided to migrate the entire codebase to QB64, a modern QBASIC-compatible compiler that:
- Provides cross-platform support (Windows, Linux, macOS)
- Maintains QBASIC syntax compatibility
- Offers modern graphics APIs
- Supports structured programming (SUB/FUNCTION)
- Allows unified executable compilation
- Provides better debugging tools

## Consequences

### Positive
- **Cross-platform support**: Game can run on modern operating systems
- **Modern APIs**: Access to `_FILEEXISTS()`, `_MOUSEX`, `_MOUSEY`, `_MOUSEINPUT`
- **Unified executable**: Single executable instead of dual-executable design
- **Better tooling**: Modern IDE support, better error messages
- **Backward compatibility**: QBASIC code mostly works without modification

### Negative
- **API differences**: Some DOS-specific features need QB64 equivalents
- **Graphics loading**: BLOAD behavior differs (no DEF SEG needed)
- **File paths**: Path handling differs from DOS
- **Learning curve**: Team needs to understand QB64-specific features

### Neutral
- Original DOS executables preserved but not used
- Graphics files (`.EGA`, `.VGA`) remain compatible

## Implementation Notes

- QB64 located at `c:\code\hutsell\qb64pe`
- Binary: `qb64pe.exe`
- All source files use `.bas` extension
- Graphics loading uses QB64 BLOAD without DEF SEG
- File existence checks use `_FILEEXISTS()` instead of DOS file operations

