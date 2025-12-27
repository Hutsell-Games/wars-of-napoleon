# ADR-0014: QB64 Syntax Constraints

**Status:** Accepted  
**Date:** 2025-12-25 (implicit, based on compilation issues)  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

QB64 has specific syntax constraints that differ from standard QBASIC and modern programming languages:
- Arrays cannot be declared directly in TYPE definitions
- Function return types must use type suffixes, not `AS type` syntax
- CONST declarations must come before SUB/FUNCTION declarations
- `ELSEIF` is one word, not `ELSE IF`
- Graphics loading uses BLOAD without DEF SEG
- File operations use QB64-specific APIs

These constraints required architectural decisions about:
- How to structure TYPE definitions
- How to organize CONST declarations
- How to handle graphics loading
- How to structure module includes

## Decision

We decided to work within QB64 constraints and document them:

### TYPE Definition Constraints
- **Constraint**: Arrays cannot be in TYPE definitions
- **Solution**: Use separate fields or separate arrays
- **Example**: `cashFrench` and `cashAllied` instead of `cash(1 TO 2)`

### Function Return Type Syntax
- **Constraint**: Must use type suffixes, not `AS type`
- **Solution**: Always use type suffixes (`%`, `&`, `!`, `#`, `$`)
- **Example**: `FUNCTION GetValue% (x AS INTEGER)` not `FUNCTION GetValue (x AS INTEGER) AS INTEGER`

### CONST Declaration Placement
- **Constraint**: CONST must come before SUB/FUNCTION
- **Solution**: All CONST declarations in `declarations.bas` (included first)
- **Organization**: CONST declarations at module level, before any SUB/FUNCTION

### Control Flow Syntax
- **Constraint**: `ELSEIF` is one word
- **Solution**: Always use `ELSEIF`, never `ELSE IF`

### Graphics Loading
- **Constraint**: QB64 BLOAD doesn't require DEF SEG
- **Solution**: Use BLOAD directly without DEF SEG
- **Implementation**: Graphics loading in `graphics.bas` uses QB64 BLOAD

### File Operations
- **Constraint**: QB64 uses different file APIs
- **Solution**: Use `_FILEEXISTS()` instead of DOS file operations
- **Implementation**: All file checks use `_FILEEXISTS()`

## Consequences

### Positive
- **QB64 compatibility**: Code compiles and runs correctly
- **Documentation**: Constraints documented in `QB64_COMPILATION_LESSONS.md`
- **Consistency**: All code follows QB64 constraints
- **Learning resource**: Documentation helps future developers

### Negative
- **Limitations**: Some modern patterns not available
- **Workarounds**: Some designs require workarounds (e.g., separate fields instead of arrays)
- **Learning curve**: Developers must understand QB64 constraints
- **Migration effort**: Code must be adapted to QB64 constraints

### Neutral
- Game functionality unchanged
- Performance characteristics similar
- User experience unchanged

## Implementation Notes

- All TYPE definitions follow QB64 constraints
- All CONST declarations in `declarations.bas`
- All functions use type suffixes
- Graphics loading uses QB64 BLOAD
- File operations use QB64 APIs
- Constraints documented in `docs/QB64/QB64_COMPILATION_LESSONS.md`

## Related ADRs

- ADR-0002: Migrate to QB64
- ADR-0013: Naming Conventions
- ADR-0015: Module Include Order

