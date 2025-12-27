# QB64PE VSCode Extension - Quick Reference Guide

This guide helps you get the most out of the [QB64PE VSCode Extension](https://github.com/davidshq-contribute/qb64pe-vscode) when working on the Wars of Napoleon project.

## Installation

1. **Install from Open VSX Registry**:
   - Open VS Code
   - Go to Extensions (`CTRL+SHIFT+X`)
   - Search for "QB64PE" or "grymmjack.qb64pe"
   - Install the extension

2. **Verify QB64PE Installation**:
   - Ensure QB64 PE (Phoenix Edition) is installed on your system
   - The extension requires QB64PE to be in your system PATH or configured in settings

## Key Features for This Project

### 1. Code Completion (500+ Keywords)

The extension provides intelligent autocomplete for:
- All QB64PE keywords and functions
- Modern underscore-prefixed functions (`_NEWIMAGE`, `_DISPLAY`, `_MOUSEINPUT`, etc.)
- Your project's custom functions and SUBs
- Context-aware suggestions based on what you're typing

**Usage**: Just start typing - autocomplete will appear automatically, or press `CTRL+SPACE` to trigger it.

### 2. Navigate Include Files

Since this project uses many `$INCLUDE` statements, the extension makes navigation easy:

**Usage**:
- Place cursor on any `$INCLUDE` line in `WON.BAS`
- Press `F12` to open the included file
- Use `ALT+LEFT` to go back

**Example**:
```bas
' $INCLUDE: 'src/tactical/battle.bas'  ← Press F12 here
```

### 3. Go to Definition

Find where functions and SUBs are defined:

**Usage**:
- Place cursor on any function/SUB name
- Press `F12` to jump to its definition
- Works across all included files

**Example**:
```bas
CALL LaunchTacticalBattle(battleData, result)  ← Press F12 on LaunchTacticalBattle
```

### 4. Build & Run

Quick compilation and execution:

- **`F5`** - Build and run the current file
- **`CTRL+SHIFT+B`** - Build only (no run)

**Note**: For this project, always build from `WON.BAS` as it's the entry point.

### 5. Code Outline

See the structure of your file:

- **`CTRL+F2`** - Toggle code outline
- Shows all SUBs, FUNCTIONs, and TYPEs in the current file
- Click any item to jump to it

### 6. Documentation Access

Get help on QB64 keywords:

- **`F1`** - Open QB64PE Wiki for the keyword under cursor
- **`CTRL+F1`** - Show alphabetical keyword list
- **`SHIFT+F1`** - Show keyword list by usage category

**Example**:
```bas
DIM SHARED strength(1 TO 100) AS INTEGER  ← Press F1 on DIM or SHARED
```

### 7. Linting (Experimental)

Check for potential issues:

- **`CTRL+ALT+L`** - Run lint on current file
- May catch syntax errors, undeclared functions, etc.
- **Note**: This is experimental - report issues to the extension repository

### 8. TODO Highlighting

The extension highlights TODOs in comments:

```bas
' TODO: Extract subroutines from NAPOLEON.BAS
' TODO: Implement InitializeTacticalBattle
```

These will be visually highlighted in the editor.

## Project-Specific Tips

### Working with WON.BAS

1. **Always open `WON.BAS`** as your main file
2. Use `F12` to navigate to any included module
3. Use autocomplete when typing function names to see what's available
4. Use `F5` to build and test

### Finding Functions Across Modules

Since functions are spread across many files:

1. Start typing a function name
2. Autocomplete will show all matches across all included files
3. The tooltip will show which file it's in
4. Press `F12` to jump to it

### Checking for Issues

The extension can help identify:

- ✅ Undeclared functions (will show in autocomplete or lint)
- ✅ Type mismatches (hover over variables to see types)
- ✅ Missing `$INCLUDE` paths (will show error)
- ✅ Syntax errors (real-time highlighting)

### Using Modern QB64 Features

The extension supports all modern QB64PE functions:

```bas
' Modern graphics
DIM img AS LONG
img = _NEWIMAGE(800, 600, 32)
_DISPLAY img

' Modern input
DO
    _LIMIT 60
    IF _MOUSEINPUT THEN
        PRINT _MOUSEX, _MOUSEY
    END IF
LOOP
```

Autocomplete will suggest these modern functions over legacy QB/QBASIC patterns.

## Troubleshooting

### Extension Not Working

1. **Check QB64PE Installation**:
   - Verify QB64PE is installed
   - Check if it's in your system PATH

2. **Reload Window**:
   - `CTRL+SHIFT+P` → "Developer: Reload Window"

3. **Check Extension Status**:
   - Look at the bottom-right status bar
   - Should show QB64PE extension is active

### Autocomplete Not Showing

1. **Check File Type**:
   - Ensure file has `.bas` extension
   - VS Code should recognize it as QB64

2. **Trigger Manually**:
   - Press `CTRL+SPACE` to force autocomplete

3. **Check Settings**:
   - Verify autocomplete is enabled in VS Code settings

### Build Errors

1. **Check Entry Point**:
   - Make sure you're building from `WON.BAS`
   - Not from individual module files

2. **Check Include Paths**:
   - Verify all `$INCLUDE` paths are correct
   - Use `F12` to test if paths work

3. **Check QB64PE Path**:
   - Extension needs to find QB64PE compiler
   - May need to configure in extension settings

## Additional Resources

- **Extension Repository**: https://github.com/davidshq-contribute/qb64pe-vscode
- **QB64PE Wiki**: https://qb64phoenix.com/qb64wiki/
- **QB64PE Forum**: https://qb64phoenix.com/forum/

## Keyboard Shortcuts Summary

| Shortcut | Action |
|----------|--------|
| `F5` | Build & Run |
| `CTRL+SHIFT+B` | Build Only |
| `F12` | Go to Definition / Follow Include |
| `CTRL+F2` | Code Outline |
| `F1` | Open Wiki Help |
| `CTRL+F1` | Alphabetical Keywords |
| `SHIFT+F1` | Keywords by Usage |
| `CTRL+ALT+L` | Run Lint |
| `CTRL+SPACE` | Trigger Autocomplete |

---

*This guide is based on the QB64PE VSCode Extension v0.10.7+. For the latest features, check the [extension repository](https://github.com/davidshq-contribute/qb64pe-vscode).*

