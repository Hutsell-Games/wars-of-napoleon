# QB64 Test Compilation Issue: "Statement cannot be placed between SUB/FUNCTIONs"

## Root Cause Analysis

### The Fundamental QB64 Rule

QB64 has a **strict code organization requirement**:

1. **ALL declarations** (CONST, DIM, TYPE, DECLARE) must come FIRST
2. **ALL executable code** must come AFTER all SUB/FUNCTION declarations
3. **You CANNOT mix executable statements between SUB/FUNCTION declarations**

### Why This Happens

The error `Statement cannot be placed between SUB/FUNCTIONs` occurs when:

1. A file with executable statements (like `most = 80`, `file$ = ""`) is included
2. Then a file with SUB/FUNCTION declarations is included
3. Then another file with SUB/FUNCTION declarations is included
4. QB64 sees the executable statements as being "between" the SUB/FUNCTION declarations

### The Problem in declarations.bas

`src/common/declarations.bas` contains executable statements mixed with declarations:

```basic
' Line 95-99
DIM SHARED m1 AS INTEGER
DIM SHARED m2 AS INTEGER
DIM SHARED most AS INTEGER
' Initialize these values (from NAP10.BI: most = 80, m1 = 40, m2 = 41)
most = 80: m1 = 40: m2 = 41  ' ← EXECUTABLE STATEMENT

' Line 105-107
DIM SHARED file$
' Initialize file$ to empty string to prevent undefined variable errors
file$ = ""  ' ← EXECUTABLE STATEMENT

' Line 213-215
DIM SHARED scenario$
' Initialize scenario$ to empty string to prevent undefined variable errors
scenario$ = ""  ' ← EXECUTABLE STATEMENT
```

### Why It Works in WON.BAS But Not in Tests

**WON.BAS structure:**
```basic
DECLARE SUB Main ()
CALL Main
END  ' ← This END prevents falling into SUB/FUNCTION definitions

' All includes come AFTER END
'$INCLUDE: 'src/common/declarations.bas'  ' Has executable statements
'$INCLUDE: 'src/common/game_types.bas'    ' Has TYPE definitions
'$INCLUDE: 'src/strategic/campaign.bas'   ' Has SUB/FUNCTION declarations
' ... etc ...
```

The `END` statement creates a clear boundary: all executable code before `END`, all SUB/FUNCTION definitions after `END`.

**Test structure (WRONG):**
```basic
'$INCLUDE: 'test_declarations.bas'      ' Includes declarations.bas with executable statements
'$INCLUDE: 'test_framework_simple.bas'  ' Has SUB declarations
'$INCLUDE: 'test_campaign.bas'           ' Has SUB declarations
' ... etc ...
```

When QB64 processes this:
1. It processes `declarations.bas` and sees executable statements (`most = 80`, etc.)
2. It processes `test_framework_simple.bas` and sees SUB declarations
3. It processes `test_campaign.bas` and sees more SUB declarations
4. **QB64 sees the executable statements as being "between" the SUB declarations from different files**

### The Solution

**Option 1: Comment out executable statements in test declarations (RECOMMENDED)**

Create a test-specific declarations file that comments out the executable statements:

```basic
' test_declarations.bas
'$INCLUDE: '../common/declarations.bas'
' But comment out the executable statements - they'll be initialized in InitializeTestVariables
```

Then initialize them in a SUB called after all SUB/FUNCTION declarations:

```basic
SUB InitializeTestVariables
    most = 80: m1 = 40: m2 = 41
    file$ = ""
    scenario$ = ""
END SUB
```

**Option 2: Move executable statements to an initialization SUB**

Modify `declarations.bas` to move executable statements to a SUB:

```basic
SUB InitializeDeclarations
    most = 80: m1 = 40: m2 = 41
    file$ = ""
    scenario$ = ""
END SUB
```

But this requires modifying the main codebase, which may break existing code.

**Option 3: Use END statement pattern (like WON.BAS)**

```basic
' test_runner_all.bas
DECLARE SUB RunAllTests ()
CALL RunAllTests
END  ' ← Clear boundary

'$INCLUDE: 'test_declarations.bas'
'$INCLUDE: 'test_framework_simple.bas'
' ... etc ...
```

But this still has the problem that declarations.bas has executable statements that will be processed.

## Recommended Fix

The cleanest solution is to create a test-specific declarations file that comments out the executable statements, then initialize them in a SUB that's called after all includes:

```basic
' test_runner_all.bas
'$INCLUDE: 'test_declarations.bas'  ' Has declarations, executable statements commented out
'$INCLUDE: 'test_framework_simple.bas'
'$INCLUDE: 'test_campaign.bas'
' ... etc ...

' Initialize variables (must be after all SUB/FUNCTION declarations)
CALL InitializeTestVariables

' Run tests
CALL RunAllTests
END
```

## Key Takeaways

1. **QB64 requires strict ordering**: Declarations → SUB/FUNCTION declarations → Executable code
2. **Executable statements cannot appear between SUB/FUNCTION declarations**, even if they're in different included files
3. **The `END` statement in WON.BAS creates a boundary** that prevents this issue in the main program
4. **For tests, we need to either**:
   - Comment out executable statements in declarations and initialize them in a SUB
   - Or restructure to ensure all executable code comes after all SUB/FUNCTION declarations

