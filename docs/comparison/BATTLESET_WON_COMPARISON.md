# Civil War Battleset vs WON Source Code Comparison Report

## Executive Summary

This report compares the source code between **Civil War Battleset** (tactical-level wargame) and **Wars of Napoleon** (tactical-level wargame) to identify functions that exist in Battleset but are missing from WON. Since both games are tactical-level wargames, the comparison is highly relevant and many functions are directly applicable.

## Key Findings

### Functions in Battleset That Are Missing from WON

#### 1. **Bubble** - Bubble Sort Algorithm ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 51

**Implementation:**
```basic
SUB Bubble (limit)
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

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 6 as `DECLARE SUB Bubble (size%)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Simple sorting utility that can be directly ported.

---

#### 2. **Enput** - Text Input with Cursor Editing ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1129
- `CIVSET24.BAS` line 845

**Implementation:**
- Full-featured text input subroutine with:
  - Cursor positioning and editing
  - Insert/Overwrite mode toggle
  - Arrow key navigation (← → Home End)
  - Backspace and Delete keys
  - Input mask validation
  - Escape to cancel
  - Enter to confirm

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 19 as `DECLARE SUB Enput (t$, tlx, tly, brx, mask$)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Advanced text input handler that could enable save game naming, scenario editing, etc.

---

#### 3. **customize** - Game Customization Menu ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 772

**Implementation:**
- Comprehensive game options menu including:
  - Difficulty settings
  - Visibility range
  - Enemy aggression
  - Display speed
  - Sound/Quiet toggle
  - Unit reliability
  - Computer vs Computer mode
  - Stack limits
  - Limber settings
  - Line of sight toggle
  - Artillery capture
  - History mode
  - Artillery fire rate
  - Battle intensity
  - Save settings

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 16 as `DECLARE SUB customize (flag%)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** This is a comprehensive options menu that would significantly enhance WON's configurability. Highly recommended for porting.

---

#### 4. **deadlead** - Leader Death Handling ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1017

**Implementation:**
```basic
SUB deadlead (index)
s = 1: COLOR 7: IF index > m1 THEN COLOR 9: s = 2
clrbot
unit$(0) = "X": Visible(0) = 1
unitx(0) = 1: unity(0) = 22
PRINT "    "; sname$(s); " LEADER KILLED! UNIT :"; name$(index);
CALL SHOWUNIT(0)
leader(index) = (.5 + .5 * RND) * leader(index)
COLOR 11: LOCATE 23, 55: PRINT "New Leader Ability ="; leader(index); : CALL dirge
TICK mdly!
Visible(0) = 0: unit$(0) = "": strength(0) = 0
END SUB
```

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 17 as `DECLARE SUB deadlead (index%)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Adds dramatic leader death mechanics. Could enhance WON's gameplay.

---

#### 5. **dirge** - Death Music/Sound ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1062

**Implementation:**
```basic
SUB dirge
IF quiet = 1 THEN
    IF sblast$ = "" THEN
        PLAY "MBt120l16o1mna4a8.aa2a4a8.aa2"
    ELSE
        CALL sndblst("sad1")
    END IF
END IF
END SUB
```

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 18 as `DECLARE SUB dirge ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Simple audio enhancement for dramatic moments.

---

#### 6. **intel** - Intelligence Reporting ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1460

**Implementation:**
```basic
SUB intel (i, a1$, a2$)
COLOR 7: IF i > m1 THEN COLOR 9
a2$ = "Outstanding"
IF leader(i) > 90 THEN a2$ = "Brilliant"
IF leader(i) < 81 THEN a2$ = "Average"
IF leader(i) < 51 THEN a2$ = "Weak": COLOR 4, 0
IF leader(i) < 31 THEN a2$ = "INEPT": COLOR 4, 0

a1$ = "Good"
IF morale(i) > 90 THEN a1$ = "Excellent"
IF morale(i) < 81 THEN a1$ = "Fair"
IF morale(i) < 51 THEN a1$ = "POOR": COLOR 4, 0
IF morale(i) < 31 THEN a1$ = "TERRIBLE": COLOR 4, 0
END SUB
```

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 28 as `DECLARE SUB intel (i%, a$, b$)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Note:** WON's declaration has different parameter names (`a$`, `b$` vs `a1$`, `a2$`), but the function is essentially the same.

**Recommendation:** Provides descriptive text for unit intelligence reports. Could enhance WON's reporting system.

---

#### 7. **menufile** - File Menu System ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR25.BAS` line 1132
- `CIVSET24.BAS` line 1072

**Implementation:**
- File browser/selector with:
  - Directory listing display
  - Arrow key navigation
  - File selection
  - Current file display
  - Enter to load
  - Escape to cancel

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 37 as `DECLARE SUB menufile (t$)`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Essential for save/load functionality. Would significantly improve WON's file management.

---

#### 8. **minsec** - Elapsed Time Display ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1582

**Implementation:**
```basic
SUB minsec
a = TIMER - startit!: x = INT(a / 60): y = a - 60 * x
B$ = RTRIM$(STR$(x)): a$ = LTRIM$(STR$(y)): IF y < 10 THEN a$ = "0" + a$
LOCATE 1, 58: PRINT "Elapsed Time "; B$; ":"; a$
END SUB
```

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 38 as `DECLARE SUB minsec ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Simple utility for displaying elapsed game time. Low priority but easy to port.

---

#### 9. **regorders** - Game Options Menu ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 1823

**Implementation:**
- Menu system providing access to:
  - Order of Battle (unit report)
  - Game Score
  - Screen Redraw
  - Briefing (scenario description)

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 48 as `DECLARE SUB regorders ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Provides quick access to common game functions. Useful utility menu.

---

#### 10. **scentex** - Scenario Briefing Display ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 2058

**Implementation:**
- Displays scenario briefing text from `stex$()` array
- Shows scenario name
- Displays up to 22 lines of briefing text
- "Press a key" prompt
- Bordered display

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 52 as `DECLARE SUB scentex ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Enhances scenario presentation. Could improve WON's scenario introduction system.

---

#### 11. **scrnload** - Screen Load Function ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 2132

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 54 as `DECLARE SUB scrload (file$)` (note: different name)
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Note:** WON declares `scrload` but Battleset implements `scrnload`. Similar functionality, different naming.

**Recommendation:** Screen loading utility. May be for loading saved screen states or graphics.

---

#### 12. **variety** - Unit Randomization ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVWAR2B.BAS` line 2245

**Implementation:**
- Randomizes unit positions slightly
- Prevents exact stacking
- Adds variety to unit placement
- Checks for collisions
- Updates terrain

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 65 as `DECLARE SUB variety ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Adds randomization to unit placement. Could be useful for scenario generation or setup variety.

---

#### 13. **title** - Title Screen ✅ IMPLEMENTED IN BATTLESET

**Location in Battleset:**
- `CIVSET24.BAS` line 2236

**Implementation:**
- Displays game title screen
- Formatted with borders
- Shows version information
- Copyright notice
- EGA requirement notice

**Status in WON:**
- ❌ Declared in `NAP10.BI` line 63 as `DECLARE SUB title ()`
- ❌ **NOT IMPLEMENTED** anywhere in WON codebase
- ❌ Never called in WON code

**Recommendation:** Standard title screen. Easy to customize for WON.

---

### Functions Declared But Not Found in Battleset

The following functions are declared in `CIV20.BI` but implementations were not found:

1. **survey** - Declared but no implementation found
2. **setup** - Declared but no implementation found  
3. **gameparm** - Declared but no implementation found

These may be:
- Planned but never implemented
- Part of a different module
- Removed in later versions

---

## Comparison Summary

### Functions Found in Battleset That Are Missing from WON

| Function | Status in WON | Priority | Complexity |
|----------|---------------|----------|------------|
| **Bubble** | Declared, not implemented | Medium | Low |
| **Enput** | Declared, not implemented | High | Medium |
| **customize** | Declared, not implemented | **High** | High |
| **deadlead** | Declared, not implemented | Medium | Low |
| **dirge** | Declared, not implemented | Low | Low |
| **intel** | Declared, not implemented | Medium | Low |
| **menufile** | Declared, not implemented | **High** | Medium |
| **minsec** | Declared, not implemented | Low | Low |
| **regorders** | Declared, not implemented | Medium | Low |
| **scentex** | Declared, not implemented | Medium | Low |
| **scrnload** | Declared as `scrload`, not implemented | Low | Unknown |
| **variety** | Declared, not implemented | Low | Medium |
| **title** | Declared, not implemented | Low | Low |

---

## Detailed Function Analysis

### customize Function

This is one of the most valuable functions for porting. It provides a comprehensive game options menu that would significantly enhance WON's configurability:

**Features:**
- Difficulty adjustment
- Visibility range settings
- Enemy aggression levels
- Display speed control
- Sound toggle
- Unit reliability settings
- Computer vs Computer mode
- Stack limits
- Limber mechanics toggle
- Line of sight toggle
- Artillery capture toggle
- History mode
- Artillery fire rate
- Battle intensity
- Save settings functionality

**Code Size:** ~250 lines
**Complexity:** High (menu system with multiple sub-menus)
**Value:** Very High (would add significant functionality to WON)

---

### menufile Function

Essential for file management:

**Features:**
- Directory file listing
- Arrow key navigation
- File selection
- Current file display
- Load confirmation
- Escape to cancel

**Code Size:** ~70 lines
**Complexity:** Medium
**Value:** High (essential for save/load functionality)

---

### Enput Function

Advanced text input handler (identical to WW2 implementation):

**Features:**
- Cursor editing
- Insert/Overwrite modes
- Arrow key navigation
- Backspace/Delete support
- Input mask validation
- Escape to cancel
- Enter to confirm

**Code Size:** ~100 lines
**Complexity:** Medium
**Value:** High (enables text input features)

---

## Recommendations

### High Priority (Should Port)

1. **customize** - Comprehensive options menu
2. **menufile** - File browser/selector
3. **Enput** - Text input handler

### Medium Priority (Consider Porting)

4. **intel** - Intelligence reporting
5. **regorders** - Quick access menu
6. **scentex** - Scenario briefing
7. **deadlead** - Leader death mechanics
8. **Bubble** - Sorting utility

### Low Priority (Nice to Have)

9. **minsec** - Elapsed time display
10. **dirge** - Death sound effect
11. **variety** - Unit randomization
12. **title** - Title screen
13. **scrnload** - Screen loading (if needed)

---

## Code Portability Notes

### Compatibility Considerations

1. **Variable Naming:**
   - Both games use `mtx$()` array
   - Both use `array()` for parallel sorting
   - Similar COMMON variable structures
   - Both use `Bigg()` in Battleset vs `bigg()` in WON (case difference)

2. **Screen Modes:**
   - Both games use SCREEN 9 (EGA)
   - Graphics functions should be compatible

3. **Input Handling:**
   - Both use INKEY$ for keyboard input
   - Arrow key codes should be compatible

4. **File I/O:**
   - Both use standard BASIC file operations
   - Should be fully compatible

5. **Function Signatures:**
   - Most functions have identical signatures
   - `intel` has slight parameter name differences but same functionality
   - `scrnload` vs `scrload` naming difference

---

## Unique Battleset Features

Battleset has some additional functions not found in WON:

1. **Rally** - Rally unit function (different from WON's routing system)
2. **trumpet** - Trumpet sound effect
3. **camess** - Campaign message display
4. **codex** - Codex/help system
5. **commander** - Commander assignment
6. **area** - Area selection
7. **cmap** - Campaign map
8. **center** - Text centering utility

These are Battleset-specific and may not be directly applicable to WON.

---

## Conclusion

The Civil War Battleset codebase contains **13 key functions** that are declared but missing from WON:

1. **Bubble** - Sorting algorithm
2. **Enput** - Text input handler
3. **customize** - Game options menu ⭐ **HIGH VALUE**
4. **deadlead** - Leader death handling
5. **dirge** - Death sound
6. **intel** - Intelligence reporting
7. **menufile** - File browser ⭐ **HIGH VALUE**
8. **minsec** - Elapsed time
9. **regorders** - Options menu
10. **scentex** - Scenario briefing
11. **scrnload** - Screen loading
12. **variety** - Unit randomization
13. **title** - Title screen

Since both games are tactical-level wargames with similar code structures, these functions can be ported with minimal modifications. The **customize** and **menufile** functions are particularly valuable as they would significantly enhance WON's functionality.

---

## Files Referenced

### Battleset Files:
- `CIV20.BI` - Main include file
- `CIVWAR2B.BAS` - Main game logic (most functions)
- `CIVWAR25.BAS` - Additional game functions
- `CIVSET24.BAS` - Setup/editor functions
- `CIVWAR2C.BAS` - Menu functions

### WON Files:
- `NAP10.BI` - Main include file
- `NAPOLEON.BAS` - Main game file
- `NAP1A.BAS` - Subroutine library
- `NAP1C.BAS` - Menu functions

---

*Report generated by comparing source code structures and function implementations between Civil War Battleset and Wars of Napoleon codebases.*

