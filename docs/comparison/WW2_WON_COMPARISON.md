# WW2 vs WON Source Code Comparison Report

## Executive Summary

This report compares the source code between **World War 2** (strategic-level wargame) and **Wars of Napoleon** (tactical-level wargame) to identify functions that exist in WW2 but are missing from WON. The analysis reveals several utility functions that could potentially be ported to WON.

## Key Findings

### Functions in WW2 That Are Missing from WON

#### 1. **bubble** - Bubble Sort Algorithm ✅ IMPLEMENTED IN WW2

**Location in WW2:**
- `WW2B.BAS` line 46
- `EDIT.BAS` line 424

**Implementation:**
```basic
SUB bubble (x)
DO
    y% = FALSE
    FOR i = 1 TO x - 1
        IF mtx$(i) > mtx$(i + 1) THEN
            SWAP mtx$(i), mtx$(i + 1)
            SWAP array(i), array(i + 1)
            y% = i
        END IF
    NEXT i
LOOP WHILE y%
END SUB
```

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 6 as `DECLARE SUB Bubble (size%)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** This is a simple sorting utility that could be easily ported to WON if sorting functionality is needed.

---

#### 2. **Enput** - Text Input with Cursor Editing ✅ IMPLEMENTED IN WW2

**Location in WW2:**
- `EDIT.BAS` line 496

**Implementation:**
- Full-featured text input subroutine with:
  - Cursor positioning and editing
  - Insert/Overwrite mode toggle
  - Arrow key navigation (left/right/home/end)
  - Backspace and delete support
  - Input mask validation
  - Escape to cancel/clear

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 19 as `DECLARE SUB Enput (t$, tlx, tly, brx, mask$)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** This is a sophisticated text input handler that could be very useful for WON if text input features are needed (e.g., save game names, scenario names, etc.).

---

#### 3. **bub2** - Alternative Sorting Function ✅ IMPLEMENTED IN WW2

**Location in WW2:**
- `WW2B.BAS` line 34
- `WW2.BI` line 7

**Status in WON:**
- ❌ Not declared or implemented in WON

**Note:** This appears to be a variant of the bubble sort, possibly optimized for different use cases.

---

### Functions Declared in WON But Missing (That Exist in WW2)

The following functions are **declared in WON's NAP10.BI** but **not implemented**, and **DO exist in WW2**:

1. **Bubble** → `bubble` in WW2 ✅
2. **Enput** → `Enput` in WW2 ✅

---

### WW2-Specific Strategic Functions

The following functions exist in WW2 but are specific to strategic-level gameplay and may not be applicable to WON's tactical focus:

- `airdist` - Calculate air distance
- `armystat` - Display army statistics
- `armyxy` - Army positioning
- `battle` - Strategic battle resolution
- `capture` - City capture mechanics
- `commander` - Commander assignment
- `europe` - European map display
- `events` - Historical events
- `filer` - File save/load operations
- `fortify` - Fortification building
- `hangar` - Air unit management
- `navy` - Naval unit management
- `newarmy` - Create new army
- `newcity` - Create new city
- `occupy` - Occupation mechanics
- `recruit` - Unit recruitment
- `resupply` - Supply management
- `ships` - Ship management
- `smarts` - AI intelligence
- `statusbar` - Status display
- `tupdate` - Turn update
- `victor` - Victory conditions

**Note:** These are strategic-level functions that don't apply to WON's tactical battle system.

---

### Shared Functions (Exist in Both)

Both games share several common utility functions:

- `clrbot` - Clear bottom of screen
- `menu` - Menu system
- `normal` - Normal distribution random number
- `TICK` - Time delay
- `report` - Status reporting
- `retreat` - Retreat mechanics (different implementations)

---

## Detailed Function Analysis

### bubble Function Comparison

**WW2 Implementation (WW2B.BAS):**
```basic
SUB bubble (x)
DO
    y% = FALSE
    FOR i = 1 TO x - 1
        IF mtx$(i) > mtx$(i + 1) THEN
            SWAP mtx$(i), mtx$(i + 1)
            SWAP array(i), array(i + 1)
            y% = i
        END IF
    NEXT i
LOOP WHILE y%
END SUB
```

**WW2 Implementation (EDIT.BAS - more detailed):**
```basic
SUB bubble (size)
limit = size
DO
    swaps% = FALSE
    FOR i = 1 TO limit - 1
        IF mtx$(i) > mtx$(i + 1) THEN
            SWAP mtx$(i), mtx$(i + 1)
            SWAP array(i), array(i + 1)
            swaps% = i
        END IF
    NEXT i
LOOP WHILE swaps%
END SUB
```

**WON Status:** Declared but never implemented. Could be ported directly.

---

### Enput Function Analysis

**WW2 Implementation (EDIT.BAS):**
- Full text editing with cursor
- Supports Insert/Overwrite modes
- Arrow key navigation (← → Home End)
- Backspace and Delete keys
- Input mask validation
- Escape to cancel
- Enter to confirm

**Key Features:**
- Visual cursor indicator (box around character)
- Real-time text editing
- Mask string for input validation
- Returns edited string in `t$` parameter

**WON Status:** Declared but never implemented. This is a sophisticated input handler that could significantly enhance WON's user interface if text input is needed.

---

## Recommendations

### High Priority

1. **Port `bubble` function to WON**
   - Simple sorting utility
   - Already declared in NAP10.BI
   - Could be useful for sorting unit lists, reports, etc.
   - Low risk, high utility

2. **Port `Enput` function to WON**
   - Advanced text input handler
   - Already declared in NAP10.BI
   - Could enable save game naming, scenario editing, etc.
   - Medium complexity, high utility

### Medium Priority

3. **Review other WW2 utility functions**
   - Functions like `center`, `choices`, `gcirc` might be useful
   - Evaluate based on WON's specific needs

### Low Priority

4. **Strategic-level functions**
   - Most WW2 strategic functions don't apply to WON's tactical focus
   - No need to port these

---

## Code Portability Notes

### Compatibility Considerations

1. **Variable Naming:**
   - WW2 uses `mtx$()` array (same as WON)
   - WW2 uses `array()` for parallel sorting (WON may need similar)
   - Both use similar COMMON variable structures

2. **Screen Modes:**
   - Both games use SCREEN 9 (EGA)
   - Graphics functions should be compatible

3. **Input Handling:**
   - Both use INKEY$ for keyboard input
   - Arrow key codes should be compatible

4. **File I/O:**
   - Both use standard BASIC file operations
   - Should be fully compatible

---

## Conclusion

The WW2 codebase contains **two key utility functions** that are declared but missing from WON:

1. **`bubble`** - A simple bubble sort algorithm
2. **`Enput`** - A sophisticated text input handler

Both functions are already declared in WON's include file (`NAP10.BI`) but were never implemented. These functions could be directly ported from WW2 to WON with minimal modifications, as both games share similar code structures and conventions.

The strategic-level functions in WW2 are not applicable to WON's tactical battle system and should not be ported.

---

## Files Referenced

### WW2 Files:
- `WW2.BI` - Main include file
- `WW2B.BAS` - Main game logic
- `EDIT.BAS` - Editor and utility functions
- `EDIT.BI` - Editor include file

### WON Files:
- `NAP10.BI` - Main include file
- `NAPOLEON.BAS` - Main game file
- `NAP1A.BAS` - Subroutine library
- `NAP1C.BAS` - Menu functions

---

*Report generated by comparing source code structures and function implementations between World War 2 and Wars of Napoleon codebases.*

