# ADR-0009: Code Reuse Strategy

**Status:** Accepted  
**Date:** 2025-12-25 (implicit, based on code structure)  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The Wars of Napoleon recreation project is part of a family of wargames by W.R. Hutsell:
- **Civil War Strategy (CWS)**: Strategic-level Civil War game
- **World War 2 (WW2)**: Strategic-level World War 2 game
- **Wars of Napoleon (WON)**: Strategic-tactical Napoleonic game

These games share significant common functionality:
- Campaign management (turns, phases, save/load)
- Army management (recruitment, movement, combat)
- City/territory control (income, fortification, victory points)
- Economic systems (income, supply, costs)
- Victory conditions (multiple end game conditions)
- Reports systems (various reports and summaries)
- Naval operations (fleet management, combat)
- Modern enhancements (mouse support, PBM, Move Capital, Realism)

Recreating WON from scratch would be inefficient when much code already exists in CWS and WW2.

## Decision

We decided to adopt a code reuse strategy:

### Code Reuse Breakdown

1. **From CWS (~50% of strategic module)**:
   - Campaign management (`campaign.bas`)
   - Army management (`army.bas`)
   - City control (`city.bas`)
   - Economic system (`economy.bas`)
   - Victory conditions (`victory.bas`)
   - Reports system (`reports.bas`)
   - Move Capital feature (`move_capital.bas`)
   - Realism toggle (`realism.bas`)

2. **From WW2 (~20% of strategic module)**:
   - Naval operations (`naval.bas`)
   - Mouse support (`mouse.bas`)
   - PBM support (`pbm.bas`)

3. **Must Build (~30% of strategic module)**:
   - Tactical integration (`tactical_integration.bas`) - WON unique
   - Cohesion system (`cohesion.bas`) - WON unique
   - Scenario system (`scenario.bas`) - WON-specific scenarios

4. **Refactor (~100% of tactical module)**:
   - Convert `NAPOLEON.BAS` to function-based architecture
   - Split into modular structure
   - Modernize code patterns

### Reuse Approach

- **Direct port**: Copy code from CWS/WW2, adapt to WON data structures
- **Adaptation**: Modify code to work with WON-specific features
- **Integration**: Ensure reused code works with WON unique features
- **Documentation**: Document source of reused code

## Consequences

### Positive
- **Faster development**: ~70% of strategic code reused
- **Proven code**: Reused code already tested in CWS/WW2
- **Consistency**: Similar games have similar behavior
- **Maintainability**: Bug fixes in one game benefit others
- **Feature parity**: Modern enhancements available in all games

### Negative
- **Adaptation effort**: Code must be adapted to WON specifics
- **Dependency management**: Changes in CWS/WW2 may affect WON
- **Documentation burden**: Must track code sources
- **Testing**: Reused code still needs testing in WON context

### Neutral
- Game mechanics may differ slightly between games
- Some features may be game-specific

## Implementation Notes

- Code adapted from CWS/WW2 with WON-specific modifications
- WON unique features (cohesion, tactical integration) built from scratch
- All reused code documented with source attribution
- Testing ensures reused code works correctly in WON context

## Related ADRs

- ADR-0005: Modular Architecture
- ADR-0010: Error Handling Standardization

