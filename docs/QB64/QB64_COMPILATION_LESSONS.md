# QB64 Compilation Lessons Learned

## Critical QB64 Syntax Rules

### 1. Arrays in TYPE Definitions
**Issue**: QB64 does NOT support arrays directly in TYPE definitions
**Error**: `Expected element-name AS type, AS type element-list, or END TYPE`
**Solution**: 
- Use separate fields instead of arrays (e.g., `cashFrench` and `cashAllied` instead of `cash(1 TO 2)`)
- Or use separate arrays declared outside the TYPE

**Example - WRONG:**
```basic
TYPE GameStateType
    cash(1 TO 2) AS LONG
END TYPE
```

**Example - CORRECT:**
```basic
TYPE GameStateType
    cashFrench AS LONG
    cashAllied AS LONG
END TYPE
```

### 2. Function Return Type Syntax
**Issue**: QB64 uses type suffixes, NOT `AS type` syntax for function return types
**Error**: `Expected )` or `Type symbols after a SUB name are invalid`
**Solution**: Use type suffixes: `%` for INTEGER, `&` for LONG, `!` for SINGLE, `$` for STRING

**Example - WRONG:**
```basic
FUNCTION GetValue (x AS INTEGER) AS INTEGER
    GetValue = x
END FUNCTION
```

**Example - CORRECT:**
```basic
FUNCTION GetValue% (x AS INTEGER)
    GetValue% = x
END FUNCTION
```

**Type Suffixes:**
- `%` = INTEGER
- `&` = LONG
- `!` = SINGLE
- `#` = DOUBLE
- `$` = STRING

### 3. SUB Cannot Have Type Suffixes
**Issue**: SUBs cannot have type suffixes - only functions can
**Error**: `Type symbols after a SUB name are invalid`
**Solution**: SUBs don't return values, so no suffix needed

**Example - WRONG:**
```basic
SUB FormatNumber$ (number AS LONG)
END SUB
```

**Example - CORRECT:**
```basic
FUNCTION FormatNumber$ (number AS LONG)
    FormatNumber$ = LTRIM$(STR$(number))
END FUNCTION
```

### 4. ELSE IF vs ELSEIF
**Issue**: QB64 uses `ELSEIF` (one word), not `ELSE IF` (two words)
**Error**: Compiles but may cause issues
**Solution**: Always use `ELSEIF`

**Example - WRONG:**
```basic
IF x = 1 THEN
    ' code
ELSE IF x = 2 THEN
    ' code
END IF
```

**Example - CORRECT:**
```basic
IF x = 1 THEN
    ' code
ELSEIF x = 2 THEN
    ' code
END IF
```

### 5. CONST Declaration Placement
**Issue**: CONST declarations CANNOT be placed between SUB/FUNCTION declarations
**Error**: `Statement cannot be placed between SUB/FUNCTIONs`
**Solution**: 
- ALL CONST declarations must come BEFORE any SUB/FUNCTION declarations
- Best practice: Put all CONST declarations in `declarations.bas` (included first)
- CONST declarations in files included after SUB/FUNCTION declarations will fail
- Even if CONST appears before SUBs in a file, if that file is included after another file with SUBs, it will fail

**Example - WRONG:**
```basic
' File A (included first)
SUB DoSomething
END SUB

' File B (included after File A)
CONST MY_CONST = 1  ' ERROR: Cannot place CONST after SUB
```

**Example - CORRECT:**
```basic
' declarations.bas (included first)
CONST MY_CONST = 1
CONST OTHER_CONST = 2

' Other files (included after)
SUB DoSomething
END SUB
```

### 6. Duplicate Include Prevention
**Issue**: Including the same file multiple times causes "Name already in use" errors
**Error**: `Name already in use (TypeName)` or `Name already in use (FunctionName)`
**Solution**: 
- Include common files (like game_types.bas) only once in main.bas
- Remove duplicate includes from other files
- Add comments indicating where the file is included: `' Note: game_types.bas is included in main.bas`

### 7. Include Path Resolution
**Issue**: Include paths are relative to the file doing the including
**Error**: `File not found`
**Solution**: 
- From `src/main.bas`: Use `' $INCLUDE: 'common/file.bas'`
- From `src/common/file.bas`: Use `' $INCLUDE: 'other.bas'` (same directory)
- From `src/strategic/file.bas`: Use `' $INCLUDE: '../common/file.bas'`

### 8. Command Line Compilation
**Key Discovery**: Use `-x` flag instead of `-c` to avoid separate compiler window
- `-x`: Compiles and outputs to console (no separate window)
- `-c`: Compiles but opens separate window
- `-w`: Show warnings
- `-q`: Quiet mode (still shows errors)

**Command:**
```bash
qb64pe -x src\main.bas -o output.exe -w
```

### 8b. Avoid Non-ASCII / Unicode Characters in Source
**Issue**: QB64/QB64-PE may fail with `Unexpected character` when source files contain Unicode characters (even in comments), such as `→`, `×`, `≤`, `≠`.
**Solution**: Replace with plain ASCII equivalents:
- `→` → `->`
- `×` → `x`
- `≤` → `<=`
- `≠` → `<>`

### 8c. Legacy DOS/IBM (CP437) Bytes and Embedded Control Characters
**Issue**: Legacy sources can contain non-ASCII bytes (CP437 box/marker glyphs) and even raw control bytes embedded inside string literals (e.g., the old DOS cursor marker).
This can cause confusing compiler errors, and it also makes files hard to edit reliably in modern editors.

**Solution**:
- Normalize sources to plain ASCII wherever possible.
- If the original behavior depends on a special glyph/control byte, use explicit `CHR$()` instead of embedding the byte in a quoted string.
  - Example: replace `PRINT ""` with `PRINT CHR$(16)`.

### 8d. Avoid `ON ERROR GOTO <label>` Inside SUB/FUNCTION
**Issue**: QB64/QB64-PE can raise `Common label within a SUB/FUNCTION` when using `ON ERROR GOTO SomeLabel` with an in-procedure label like `SomeLabel:` inside a `FUNCTION` (and sometimes inside `SUB`).

**Solution**:
- Prefer built-in QB64 functions (like `_FILEEXISTS`) over `ON ERROR`-based probing.
- If you must handle errors, avoid label-based `ON ERROR GOTO` inside procedures; refactor to higher-level error handling patterns that don't require in-procedure labels.

### 8e. Use `_FILEEXISTS` for File Checks (QB64-PE)
**Issue**: `ON ERROR GOTO` + a label inside a function can trigger `Common label within a SUB/FUNCTION`.

**Solution**:
- Use `_FILEEXISTS(filename$)` which returns `-1` if the file exists and `0` if it does not.
- Wiki: `https://wiki.qb64.dev/qb64wiki/index.php/FILEEXISTS`

Example:
```basic
IF _FILEEXISTS("mysettings.ini") THEN
    PRINT "Settings file found."
END IF
```

### 8f. EXE Launches then Immediately Exits (“Press any key…”)
**Issue**: If your compiled program has no module-level startup code, launching the EXE can immediately exit and show a console “Press any key…” prompt.

**Solution**:
- Use a tiny launcher entrypoint at the very top of the entry file (before `$INCLUDE`s):
  - `DECLARE SUB Main ()`
  - `CALL Main`
  - `END`

## Systematic Fixes Needed

### Phase 1: Fix All Function Declarations
Find all functions using `AS type` syntax and convert to type suffixes:
- `AS INTEGER` → `%`
- `AS LONG` → `&`
- `AS SINGLE` → `!`
- `AS STRING` → `$`

### Phase 2: Fix All Function Bodies
Update function bodies to use type suffix in assignments:
- `FunctionName = value` → `FunctionName% = value` (for INTEGER)
- `FunctionName = value` → `FunctionName& = value` (for LONG)
- etc.

### Phase 3: Fix All Array Accesses
Update all `gameState.cash(side)` to use helper functions or direct field access:
- `gameState.cash(1)` → `gameState.cashFrench`
- `gameState.cash(2)` → `gameState.cashAllied`
- Or use helper functions: `GetGameStateCash(side)`

### Phase 4: Fix BattleData Array Accesses
Update all `battleData.sidex(1)` to use new field names:
- `battleData.sidex(1)` → `battleData.sideID1`
- `battleData.sidex(2)` → `battleData.sideID2`
- `battleData.commander(1)` → `battleData.commander1`
- `battleData.commander(2)` → `battleData.commander2`
- etc.

### Phase 5: Fix BattleResult Array Accesses
Update all `battleResult.casualties(1)` to use new field names:
- `battleResult.casualties(1)` → `battleResult.casualties1`
- `battleResult.casualties(2)` → `battleResult.casualties2`

## Files That Need Updates

### Function Declarations (66 functions found):
- `src/main.bas`: ShowMainMenu
- `src/ui/menus.bas`: ShowYesNoMenu, ShowListMenu
- `src/ui/mouse.bas`: GetMouseX, GetMouseY, GetMouseButton, IsMouseOverCity
- `src/tactical/core.bas`: ResolveMeleeCombat, CheckVictoryConditions, CheckLineOfSight
- `src/tactical/units.bas`: GetUnitType, CanInfantryCharge, CanHollowSquareMove, GetCavalryChargeBonus, CanArtilleryMove, GetGeneralBonus, GetUnitCombatEffectiveness
- `src/strategic/combat.bas`: CalculateCombatStrength, CalculateDefenderBonus
- `src/strategic/economy.bas`: GetRecruitmentCost, GetFortificationCost, GetShipCost, IsOutOfSupply
- `src/strategic/city.bas`: GetCityIncome, GetCityVictoryPoints, GetCityNationality
- `src/strategic/scenario.bas`: SelectScenario, GetCommanderByIndex, GetCommanderByName$, GetCommanderNationalityByName
- `src/strategic/cohesion.bas`: CheckCohesion, GetCommanderNationality, ApplyCohesionPenalty, IsAtPeace, CanRecruitInCity, GetCityIncomeForNationality, GetNationalityName$
- `src/strategic/army.bas`: GetArmyStrength
- `src/strategic/tactical_integration.bas`: ShouldTriggerTacticalBattle, ResolveCombat, ProcessTacticalResults, ResolveStrategicCombat
- `src/strategic/realism.bas`: GetRecruitmentSize, CanRecruitInCityRealism, GetIsolatedCityRecruitment, IsCityIsolated, GetDefenderAdvantage
- `src/strategic/move_capital.bas`: IsCapitalCity
- `src/tactical/battle.bas`: RunTacticalBattleLoop, GetRemainingStrength
- `src/strategic/victory.bas`: CheckEndGameConditions, GetVictoryPoints
- `src/strategic/campaign.bas`: IsHarvestMonth, GetSaveFileList$

### Array Access Updates Needed:
- All `gameState.cash(side)` → Use helper functions or direct fields
- All `gameState.income(side)` → Use helper functions or direct fields
- All `gameState.victory(side)` → Use helper functions or direct fields
- All `gameState.control(side)` → Use helper functions or direct fields
- All `battleData.sidex()` → Use new field names
- All `battleData.commander()` → Use new field names
- All `battleData.vp()` → Use new field names
- All `battleData.leadbase()` → Use new field names
- All `battleData.expbase()` → Use new field names
- All `battleResult.casualties()` → Use new field names

## Compilation Strategy

1. **Move all CONST declarations to declarations.bas** (must come before SUB/FUNCTION)
2. **Remove duplicate includes** (game_types.bas only in main.bas)
3. **Fix syntax errors** (function declarations, ELSE IF)
4. **Fix TYPE definitions** (remove arrays)
5. **Fix all function bodies** (use type suffixes)
6. **Fix all array accesses** (use new field names or helpers)
7. **Compile incrementally** (fix one error at a time)
8. **Use `-x` flag** to see errors in console

### 9. DIM SHARED Declaration Placement
**Issue**: DIM SHARED declarations CANNOT be placed between SUB/FUNCTION declarations
**Error**: `Statement cannot be placed between SUB/FUNCTIONs` or `Name already in use`
**Solution**: 
- ALL DIM SHARED declarations must come BEFORE any SUB/FUNCTION declarations
- Best practice: Put all DIM SHARED declarations in `declarations.bas` (included first)
- Remove duplicate DIM SHARED declarations from other files
- Add comments indicating where variables are declared: `' Note: variableName is declared in declarations.bas`

**Example - WRONG:**
```basic
' File A (included first)
SUB DoSomething
END SUB

' File B (included after File A)
DIM SHARED myVar AS INTEGER  ' ERROR: Cannot place DIM SHARED after SUB
```

**Example - CORRECT:**
```basic
' declarations.bas (included first)
DIM SHARED myVar AS INTEGER
DIM SHARED otherVar AS INTEGER

' Other files (included after)
' Note: myVar is declared in declarations.bas
SUB DoSomething
END SUB
```

### 10. Type Suffix Variables Don't Need AS Type
**Issue**: Variables with type suffixes ($, !, %, &, #) should NOT have `AS type` in DIM statements
**Error**: `DIM: Expected ,` or `Illegal string-number conversion`
**Solution**: Remove `AS type` from DIM statements for variables with type suffixes

**Example - WRONG:**
```basic
DIM SHARED name$ AS STRING
DIM SHARED value! AS SINGLE
DIM SHARED count% AS INTEGER
```

**Example - CORRECT:**
```basic
DIM SHARED name$
DIM SHARED value!
DIM SHARED count%
```

### 11. Functions Cannot Return TYPEs
**Issue**: QB64 functions cannot return TYPE structures directly
**Error**: `Expected )` or `Type symbols after a FUNCTION name are invalid`
**Solution**: Convert functions that return TYPEs to SUBs with result parameters

**Example - WRONG:**
```basic
FUNCTION GetCommander (index AS INTEGER) AS CommanderType
    GetCommander = commanders(index)
END FUNCTION
```

**Example - CORRECT:**
```basic
SUB GetCommander (index AS INTEGER, result AS CommanderType)
    result = commanders(index)
END SUB
```

### 12. DIR$ Usage Issues
**Issue**: `LEN(DIR$(filename))` causes "Illegal string-number conversion" errors
**Error**: `Illegal string-number conversion`
**Solution**: Prefer `_FILEEXISTS` (QB64-PE) directly, instead of `ON ERROR` labels inside functions or wrapper functions.

**Example - WRONG:**
```basic
IF LEN(DIR$("file.txt")) = 0 THEN
    PRINT "File not found"
END IF
```

**Example - CORRECT:**
```basic
IF NOT _FILEEXISTS("file.txt") THEN
    PRINT "File not found"
END IF
```

### 13. Preprocessor Directives
**Issue**: QB64 doesn't support `#IFDEF` / `#ENDIF` preprocessor directives
**Error**: `Syntax error` or `Expected (...)`
**Solution**: Comment out debug code or use runtime flags instead

**Example - WRONG:**
```basic
#IFDEF DEBUG
    PRINT "Debug message"
#ENDIF
```

**Example - CORRECT:**
```basic
' Commented out - use debug flag when implemented
' IF debugMode = 1 THEN PRINT "Debug message"
```

### 14. Variable Name Conflicts
**Issue**: Reserved words or already-declared names cause "Name already in use" errors
**Error**: `Name already in use (variableName)`
**Solution**: Rename variables to avoid conflicts (e.g., `command` → `cmd`, `key` → `keyPress`)

**Example - WRONG:**
```basic
DIM command AS STRING  ' Conflicts with COMMAND statement
DIM key AS STRING      ' Conflicts with KEY statement
```

**Example - CORRECT:**
```basic
DIM cmd AS STRING
DIM keyPress AS STRING
```

### 15. Function Call Syntax for No-Parameter Functions
**Issue**: Functions with `$` suffix and no parameters may need different call syntax
**Error**: `Expected (...)`
**Solution**: Remove empty parentheses `()` from function calls for no-parameter functions

**Example - WRONG:**
```basic
FUNCTION GetString$
    GetString$ = "test"
END FUNCTION

result$ = GetString$()  ' May cause error
```

**Example - CORRECT:**
```basic
FUNCTION GetString$
    GetString$ = "test"
END FUNCTION

result$ = GetString$  ' No parentheses needed
```

### 16. CALL Statement Syntax
**Issue**: QB64 CALL statement syntax differs from QBasic
**Error**: `Expected CALL sub-name [(...)]`
**Solution**: 
- When using `CALL`, the subroutine name MUST be followed by parentheses `()` even if no parameters
- `CALL` is optional - you can call subroutines directly: `subname` or `subname()`
- If DECLARE SUB has `()`, then CALL must use `()`: `CALL subname ()` (with space before parentheses)
- Match the spacing in DECLARE: `DECLARE SUB name ()` → `CALL name ()`

**Example - WRONG:**
```basic
DECLARE SUB mainmap ()
CALL mainmap  ' ERROR: Missing parentheses
CALL mainmap()  ' May work but spacing doesn't match DECLARE
```

**Example - CORRECT:**
```basic
DECLARE SUB mainmap ()
CALL mainmap  ' No parentheses for no-parameter SUBs

DECLARE SUB TICK (sec!)
CALL TICK(turbo!)  ' Parentheses required for parameter SUBs
```

**Reference**: Based on working QB64 code in civil-war-strategy project (CWSTRAT.BAS)

### 17. Reserved Word Conflicts
**Issue**: QB64 has reserved words that cannot be used as variable names
**Error**: `Name already in use (color)` or `Expected element-name`
**Solution**: Rename variables that conflict with reserved words

**Common Reserved Words**:
- `COLOR` (statement) → use `colour` or `drawColor`
- `KEY` (statement) → use `keyPress` or `keyVal`
- `COMMAND` (statement) → use `cmd` or `commandVal`
- `SIZE`, `NAME`, `TYPE`, `DATE`, `TIME` → add suffix like `sizeVal`, `nameVal`, etc.

**Example - WRONG:**
```basic
DIM color AS INTEGER  ' Conflicts with COLOR statement
COLOR color  ' ERROR: color is reserved
```

**Example - CORRECT:**
```basic
DIM drawColor AS INTEGER
COLOR drawColor  ' Works fine
```

### 18. TYPE Return Values from Functions
**Issue**: `User defined types in expressions are invalid` when trying to return a TYPE from a FUNCTION.
**Error**: `User defined types in expressions are invalid`
**Solution**: Convert the FUNCTION to a SUB that takes the result as a by-reference parameter.

**Example - WRONG:**
```basic
FUNCTION LaunchTacticalBattle (battleData AS BattleData) AS BattleResult
    DIM result AS BattleResult
    result.winner = winner
    LaunchTacticalBattle = result
END FUNCTION
```

**Example - CORRECT:**
```basic
SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)
    result.winner = winner
    result.casualties1 = casualties1
    result.casualties2 = casualties2
END SUB

' Usage:
CALL LaunchTacticalBattle(battleData, battleResult)
```

### 19. DECLARE Statements with TYPE Parameters
**Issue**: DECLARE statements referencing TYPEs must come after TYPE definitions are available.
**Error**: `Expected CALL sub-name [(...)]` or `Type not defined`
**Solution**: Place DECLARE statements after the TYPE definitions are included.

**Example - WRONG:**
```basic
' declarations.bas (included first, before battle_types.bas)
DECLARE SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)
```

**Example - CORRECT:**
```basic
' tactical_integration.bas (included after battle_types.bas)
' Note: battle_types.bas is included in main.bas
DECLARE SUB LaunchTacticalBattle (battleData AS BattleData, result AS BattleResult)
```

### 20. IF/END IF Structure with ELSEIF
**Issue**: `END IF without IF` errors when ELSEIF blocks are improperly structured.
**Error**: `END IF without IF`
**Solution**: Ensure each IF/ELSEIF/ELSE block has exactly one matching END IF.

**Example - WRONG:**
```basic
IF winner = 1 THEN
    IF condition THEN
        ' code
    END IF
ELSEIF otherCondition THEN
        ' code
    END IF  ' Extra END IF!
END IF
```

**Example - CORRECT:**
```basic
IF winner = 1 THEN
    IF condition THEN
        ' code
    END IF
ELSEIF otherCondition THEN
    ' code
END IF
```

### 21. Reserved Word Conflicts - LINE
**Issue**: `Name already in use (line)` errors when using `line` as a variable name.
**Error**: `Name already in use (line)` or `Incorrect number of arguments`
**Solution**: Rename the variable to something else like `lineText`.

**Example - WRONG:**
```basic
DIM line AS STRING
LINE INPUT #1, line
PRINT line
```

**Example - CORRECT:**
```basic
DIM lineText AS STRING
LINE INPUT #1, lineText
PRINT lineText
```

### 22. Array Initialization Between SUB/FUNCTION Declarations
**Issue**: `Statement cannot be placed between SUB/FUNCTIONs` when initializing arrays after SUB/FUNCTION declarations start.
**Error**: `Statement cannot be placed between SUB/FUNCTIONs`
**Solution**: Move array initialization to declarations.bas before any SUB/FUNCTION declarations, or to an initialization SUB.

**Example - WRONG:**
```basic
FUNCTION SelectScenario%()
    ' ...
END FUNCTION

DIM SHARED scenarioYears(1 TO 7) AS INTEGER
scenarioYears(1) = 1796  ' Error: between SUB/FUNCTIONs
```

**Example - CORRECT:**
```basic
' declarations.bas (before SUB/FUNCTION declarations)
DIM SHARED scenarioYears(1 TO 7) AS INTEGER
scenarioYears(1) = 1796
scenarioYears(2) = 1805
' ... etc ...
```

### 23. Executable Statements Between SUB/FUNCTION Declarations
**Issue**: Executable statements (like `most = 80`, `file$ = ""`) cannot be placed between SUB/FUNCTION declarations, even if they're in different included files.
**Error**: `Statement cannot be placed between SUB/FUNCTIONs`
**Solution**: 
- Move executable statements to declarations.bas BEFORE any SUB/FUNCTION declarations, OR
- Comment them out in declarations.bas and initialize them in an initialization SUB called AFTER all SUB/FUNCTION declarations
- For test files, use a test-specific declarations file with executable statements commented out

**Example - WRONG:**
```basic
' File A (included first)
SUB DoSomething
END SUB

' File B (included after File A)
most = 80  ' ERROR: Executable statement between SUB/FUNCTIONs
```

**Example - CORRECT:**
```basic
' declarations.bas (included first, BEFORE any SUB/FUNCTION declarations)
DIM SHARED most AS INTEGER
most = 80  ' OK: Before any SUB/FUNCTION declarations

' Other files (included after)
SUB DoSomething
END SUB
```

**Example - CORRECT (for tests):**
```basic
' declarations_test.bas (test-specific, executable statements commented)
DIM SHARED most AS INTEGER
' most = 80  ' Commented out to avoid "between SUB/FUNCTION" errors

' test_init.bas (included AFTER all SUB/FUNCTION declarations)
SUB InitializeTestVariables
    most = 80  ' Initialize here, after all SUB/FUNCTION declarations
END SUB
```

### 24. Duplicate Includes Causing "Name already in use"
**Issue**: Including the same file multiple times (e.g., each test file including declarations.bas) causes "Name already in use" errors.
**Error**: `Name already in use (TypeName)` or `Name already in use (FunctionName)`
**Solution**: 
- Include common files (declarations, game_types, utilities, etc.) ONLY ONCE at the top level
- Remove duplicate includes from individual test files
- Add comments indicating where files are included: `' Note: game_types.bas is included in test_runner_all.bas`

**Example - WRONG:**
```basic
' test_campaign.bas
'$INCLUDE: 'test_declarations.bas'  ' Includes declarations.bas
'$INCLUDE: 'test_framework_simple.bas'

' test_army.bas
'$INCLUDE: 'test_declarations.bas'  ' Includes declarations.bas AGAIN - ERROR!
'$INCLUDE: 'test_framework_simple.bas'
```

**Example - CORRECT:**
```basic
' test_runner_all.bas
'$INCLUDE: 'test_declarations.bas'  ' Include ONCE at top level
'$INCLUDE: 'test_framework_simple.bas'
'$INCLUDE: 'test_campaign.bas'  ' No includes of declarations here
'$INCLUDE: 'test_army.bas'  ' No includes of declarations here
```

### 25. Identifier Name Length Limit
**Issue**: QB64 has a 40-character limit on identifier names (SUB, FUNCTION, variable names).
**Error**: `Identifier longer than 40 character limit`
**Solution**: Shorten identifier names to 40 characters or less.

**Example - WRONG:**
```basic
SUB TestGetCityVictoryPointsIncludesObjectiveBonus  ' 44 characters - ERROR!
END SUB
```

**Example - CORRECT:**
```basic
SUB TestGetCityVPIncludesObjectiveBonus  ' 35 characters - OK
END SUB
```

### 26. Mock Functions Conflicting with Real Functions
**Issue**: Test files with mock functions that have the same name as real functions cause "Name already in use" errors.
**Error**: `Name already in use (FunctionName)`
**Solution**: 
- Remove mock functions that duplicate real functions
- Add comments indicating where the real function is defined
- If test-specific behavior is needed, use a different approach (e.g., test flags, dependency injection)

**Example - WRONG:**
```basic
' test_combat.bas
SUB LoadCommanderData (scenarioYear AS INTEGER)  ' Mock
END SUB

' scenario.bas (included later)
SUB LoadCommanderData (scenarioYear AS INTEGER)  ' Real function - ERROR!
END SUB
```

**Example - CORRECT:**
```basic
' test_combat.bas
' LoadCommanderData is defined in scenario.bas (included in test_runner_all.bas)
```

## Notes

- QB64 is case-insensitive for keywords but case-sensitive for some identifiers
- QB64 uses `DEFINT A-Z` to default all variables to INTEGER
- String arrays use `$` suffix: `name$(1 TO 100)` (no `AS STRING` needed)
- Function names with `$` return strings, with `%` return integers, etc.
- Always use type suffixes in function body assignments matching the function name
- All CONST and DIM SHARED declarations must be in declarations.bas (included first)
- Remove all duplicate includes and declarations
- CALL statements must match DECLARE SUB spacing (space before parentheses if DECLARE has space)
- Functions cannot return TYPE values - use SUBs with by-reference parameters instead
- DECLARE statements with TYPE parameters must come after TYPE definitions
- Array initialization statements cannot be placed between SUB/FUNCTION declarations
- Executable statements cannot be placed between SUB/FUNCTION declarations (even in different files)
- Include common files only once at the top level to avoid "Name already in use" errors
- Identifier names are limited to 40 characters
- Mock functions in tests must not conflict with real function names

