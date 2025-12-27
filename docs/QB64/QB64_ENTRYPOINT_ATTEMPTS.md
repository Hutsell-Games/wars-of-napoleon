'============================================================================
' QB64 Entry Point Attempts Log
'============================================================================

Context:
- Goal: resolve QB64 error "Statement cannot be placed between SUB/FUNCTIONs" during compilation of Wars of Napoleon when trying to establish a clean entry point.
- Key constraint: `$INCLUDE` is a preprocessor that splices file contents inline; QB64 disallows executable module-level statements that appear between any SUB/FUNCTION definitions after preprocessing.

Attempts (chronological):
1) Module-level CALL Main at end of src/main.bas  
   - Approach: keep existing includes in main.bas; place `CALL Main` + `END` after SUB definitions.  
   - Result: QB64 error "Statement cannot be placed between SUB/FUNCTIONs" at CALL Main.  
   - Root cause: included files define SUBs before module-level code; module-level CALL appears between definitions.

2) Move module-level code to top of main.bas, before SUBs  
   - Approach: place CALL InitializeGame + menu loop before SUBs in main.bas.  
   - Result: same error at CALL InitializeGame.  
   - Root cause: includes still inject SUBs before this code, so QB64 still sees code between definitions.

3) Create wrapper WON.BAS; include main.bas and all modules; keep module-level code at end  
   - Approach: WON.BAS includes all modules then main.bas, then module-level menu/cleanup code.  
   - Result: same error at CALL InitializeGame.  
   - Root cause: module-level code still parsed after SUBs; QB64 rejects code after any SUB/FUNCTION in final expanded file.

4) Move all CONSTs to top of declarations.bas  
   - Goal: ensure no executable statements are interleaved; done to remove "Statement cannot be placed..." related to CONST placement.  
   - Result: later compile progressed further; entry-point error persisted.

5) Move module-level code to beginning of WON.BAS (before includes)  
   - Approach: put menu/loop before all includes.  
   - Result: new error "Name already in use (MENU_NEW_GAME)" because constants from declarations.bas were not yet included.  
   - Root cause: early module-level code cannot see constants/DECLs defined in later includes.

6) Wrap entry code in SUB WONMain; call it at end (module-level call)  
   - Approach: define SUB WONMain containing initialize/menu/cleanup; module-level CALL WONMain after SUB.  
   - Result: same "between SUB/FUNCTIONs" error at CALL WONMain.  
   - Root cause: QB64 still rejects any executable statements after a SUB definition when includes have already introduced SUBs.

7) Move CALL WONMain before SUB WONMain in WON.BAS  
   - Approach: place CALL WONMain (module-level) before the SUB definition, hoping to satisfy ordering.  
   - Result: not compiled (user interrupted run), but expectation: constants still unresolved before includes; likely same or constant-name errors.

Key lessons learned:
- `$INCLUDE` is purely textual; after expansion, QB64 forbids executable statements anywhere after the first SUB/FUNCTION definition.
- Module-level executable code must appear before any SUB/FUNCTION in the fully expanded file. With many includes that define SUBs, that is effectively impossible if we rely on module-level code after includes.
- Wrapping logic in a SUB and invoking it from module-level still leaves a module-level CALL after SUB definitions; QB64 disallows this as well.
- Placing module-level code before includes prevents use of constants/DECLs that are defined in the included files.
- Civil-war-strategy works because it is a single file: module-level code first, then all SUBs—no `$INCLUDE` boundaries.

Possible next steps (not yet attempted):
- Adopt a single top-level SUB (e.g., SUB Main) as the entry point and rely on QB64's implicit entry (no module-level CALL). That requires:
  - Remove all module-level executable code; keep only SUB/FUNCTION definitions in all included files.
  - Ensure QB64 calls SUB Main implicitly (verify QB64PE behavior) or compile with a tiny launcher file that only CALLs Main and includes no other SUBs.
- Alternative: create a tiny launcher file with only:
    DECLARE SUB Main ()
    CALL Main
    END
  and ensure every included file contains only SUB/FUNCTION definitions (no module-level statements, no CONST after SUBs).
- Confirm in QB64 docs whether SUB Main is auto-invoked when present (to avoid any module-level CALL).

Status:
- Entry-point issue remains unresolved; need a launcher-only file or reliance on implicit SUB Main without any module-level code after SUB/FUNCTION definitions.

Update (working solution):
- Use `WON.BAS` as the launcher with this pattern at the very top:
  - `DECLARE SUB Main ()`
  - `CALL Main`
  - `END`
  - then all the `$INCLUDE` lines.
- This prevents the compiled EXE from starting and immediately exiting when launched from Explorer, and avoids the QB64 restriction about executable statements appearing after SUB/FUNCTION definitions.

