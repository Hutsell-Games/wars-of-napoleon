# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) for the Wars of Napoleon project. ADRs document important architectural decisions made throughout the project's evolution.

## What are ADRs?

Architecture Decision Records are documents that capture important architectural decisions, along with their context and consequences. They help:
- Understand why decisions were made
- Track the evolution of the architecture
- Onboard new developers
- Avoid revisiting already-decided issues

## ADR Format

Each ADR follows this structure:
- **Status**: Proposed, Accepted, Deprecated, Superseded
- **Date**: When the decision was made
- **Deciders**: Who made the decision
- **Git Commit**: Related git commit hash
- **Context**: The situation that led to the decision
- **Decision**: What was decided
- **Consequences**: Positive, negative, and neutral consequences

## ADR Index

### Foundation Decisions

- [ADR-0001: Preserve Original Source Code](0001-preserve-original-source-code.md) - Decision to preserve original codebase
- [ADR-0002: Migrate to QB64](0002-migrate-to-qb64.md) - Decision to use QB64 compiler

### Organization Decisions

- [ADR-0003: Organize Files into Directory Structure](0003-organize-files-into-directories.md) - Decision to organize files into directories

### Architecture Decisions

- [ADR-0004: Unified Architecture - Single Executable](0004-unified-architecture-single-executable.md) - Decision to use single executable instead of dual-executable
- [ADR-0005: Modular Architecture](0005-modular-architecture.md) - Decision to refactor into modular structure
- [ADR-0006: Strategic-Tactical Data Conversion](0006-strategic-tactical-data-conversion.md) - Decision on data conversion between layers

### Code Quality Decisions

- [ADR-0007: Structured Programming - GOSUB to SUB Conversion](0007-structured-programming-gosub-to-sub.md) - Decision to convert to structured programming
- [ADR-0008: Tactical Module Refactoring](0008-tactical-module-refactoring.md) - Decision to split tactical module into focused modules
- [ADR-0009: Code Reuse Strategy](0009-code-reuse-strategy.md) - Decision to reuse code from CWS/WW2
- [ADR-0010: Error Handling Standardization](0010-error-handling-standardization.md) - Decision to standardize error handling
- [ADR-0011: Utility Function Standardization](0011-utility-function-standardization.md) - Decision to extract common patterns into utilities
- [ADR-0012: Testing Framework](0012-testing-framework.md) - Decision to implement testing framework

### Language and Syntax Decisions

- [ADR-0013: Naming Conventions - Type Suffixes](0013-naming-conventions-type-suffixes.md) - Decision to use QB64 type suffix conventions
- [ADR-0014: QB64 Syntax Constraints](0014-qb64-syntax-constraints.md) - Decision to work within QB64 limitations
- [ADR-0015: Module Include Order](0015-module-include-order.md) - Decision on module include order and dependencies

### Compatibility and Standards Decisions

- [ADR-0016: File Format Compatibility](0016-file-format-compatibility.md) - Decision to maintain backward compatibility with original file formats
- [ADR-0017: Documentation Standards](0017-documentation-standards.md) - Decision on documentation templates and standards
- [ADR-0018: Entry Point Design](0018-entry-point-design.md) - Decision on WON.BAS vs main.bas structure

## How to Read ADRs

1. **Start with ADR-0001**: Understand the foundation decisions
2. **Follow chronologically**: ADRs are numbered sequentially
3. **Check related ADRs**: Many ADRs reference each other
4. **Review git commits**: Each ADR includes related commit hash

## How to Create New ADRs

1. **Identify the decision**: What architectural decision was made?
2. **Gather context**: What situation led to the decision?
3. **Document consequences**: What are the positive, negative, and neutral consequences?
4. **Number sequentially**: Use next available number (e.g., 0013)
5. **Include git commit**: Reference the commit where decision was made
6. **Update this README**: Add new ADR to the index

## ADR Status

- **Accepted**: Decision has been made and implemented
- **Proposed**: Decision is under consideration
- **Deprecated**: Decision has been superseded or reversed
- **Superseded**: Decision has been replaced by a newer ADR

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md) - System architecture overview
- [Full Recreation Plan](../FULL_RECREATION_PLAN.md) - Implementation plan
- [Strategic-Tactical Integration](../STRATEGIC_TACTICAL_INTEGRATION.md) - Integration details
- [Changelog](../../CHANGELOG.md) - Project changelog

