# ADR-0017: Documentation Standards

**Status:** Accepted  
**Date:** 2025-12-25 (implicit, based on code structure)  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The codebase needed consistent documentation standards for:
- Function documentation
- Module documentation
- Architecture documentation
- Code comments
- User documentation

Different parts of the codebase had inconsistent documentation:
- Some functions had no documentation
- Some had brief comments
- Some had detailed documentation
- No standard format for function documentation

The project also needed documentation for:
- Architecture decisions (ADRs)
- Code conventions (naming, error handling)
- QB64-specific constraints
- Integration patterns

## Decision

We decided to establish comprehensive documentation standards:

### Function Documentation Template

All functions use a standard documentation template:

```qb64
'============================================================================
' FunctionName - Brief description
'============================================================================
' Parameters:
'   param1 (TYPE) - Description
'   param2 (TYPE) - Description
' Returns:
'   TYPE - Description
' Description:
'   Detailed description of what the function does.
'   Include any important notes about behavior, side effects, etc.
' Side Effects:
'   - List any side effects (if applicable)
'============================================================================
```

### Module Documentation

Each module includes:
- Module purpose
- Dependencies (what modules it depends on)
- Key functions
- Usage examples (if applicable)

### Architecture Documentation

- **ADRs**: Architecture Decision Records in `docs/adr/`
- **Architecture diagrams**: Mermaid diagrams in `ARCHITECTURE.md`
- **Integration docs**: Strategic-tactical integration in `STRATEGIC_TACTICAL_INTEGRATION.md`
- **Code conventions**: Naming, error handling patterns documented

### Code Comments

- **Inline comments**: Explain why, not what
- **Function headers**: Use standard template
- **Complex logic**: Document algorithm or reasoning
- **QB64 constraints**: Document workarounds for QB64 limitations

### User Documentation

- **README.md**: Project overview, features, building
- **CHANGELOG.md**: Version history, changes
- **QB64 guides**: QB64-specific documentation in `docs/QB64/`

## Consequences

### Positive
- **Consistency**: All documentation follows same format
- **Completeness**: Standard template ensures all important info included
- **Maintainability**: Easy to update documentation
- **Onboarding**: New developers can understand code quickly
- **Reference**: Comprehensive documentation serves as reference

### Negative
- **Time investment**: Writing documentation takes time
- **Maintenance burden**: Documentation must be kept up to date
- **Verbosity**: Some functions may have more documentation than code

### Neutral
- Game functionality unchanged
- Performance unchanged
- User experience unchanged

## Implementation Notes

- Documentation template enforced in code reviews
- All new functions must include documentation
- Existing functions gradually updated to standard
- Documentation reviewed alongside code changes
- ADRs document architectural decisions
- Code conventions documented in separate files

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0010: Error Handling Standardization
- ADR-0013: Naming Conventions

