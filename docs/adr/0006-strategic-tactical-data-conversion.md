# ADR-0006: Strategic-Tactical Data Conversion

**Status:** Accepted  
**Date:** 2025-12-25  
**Deciders:** Dave Mackey  
**Git Commit:** 72dafaafc957de4c95f4874df10fbd9b45edc364

## Context

The strategic and tactical layers use different data representations:
- **Strategic Layer**: Uses "men" (actual number of soldiers, e.g., 5000 men)
- **Tactical Layer**: Uses "hundreds" (VP - Victory Points, e.g., 50 hundreds = 5000 men)

Additionally:
- Strategic layer tracks supply status (0-10)
- Tactical layer applies supply penalties (50% effectiveness if out of supply)
- Strategic layer has commander ratings (1-10)
- Tactical layer uses commander ratings for battle calculations
- Strategic layer tracks army experience (0-10)
- Tactical layer uses experience for combat bonuses

The conversion between these representations must be:
- **Accurate**: No loss of information
- **Consistent**: Same conversion rules always applied
- **Reversible**: Can convert back from tactical to strategic
- **Documented**: Clear conversion formulas

## Decision

We decided to implement a centralized conversion system in `tactical_integration.bas`:

### Strategic → Tactical Conversion

1. **Army Size**: `men / 100 = hundreds (VP)`
   - Example: 5000 men → 50 VP
   - Example: 3000 men → 30 VP

2. **Supply Penalty**: If supply = 0, apply 50% penalty
   - Example: 50 VP out of supply → 25 VP

3. **Commander Ratings**: Direct mapping (1-10 → 1-10)

4. **Experience**: Direct mapping (0-10 → 0-10)

### Tactical → Strategic Conversion

1. **Casualties**: `hundreds * 100 = men`
   - Example: 15 hundreds lost → 1500 men lost
   - Example: 20 hundreds lost → 2000 men lost

2. **Army Updates**: `original_men - casualties = new_men`
   - Example: 5000 men - 1500 casualties = 3500 men

3. **Supply Status**: Preserved (not modified by tactical battle)

4. **Commander Ratings**: Preserved (not modified by tactical battle)

5. **Experience**: Updated based on battle outcome (victory = +1)

## Consequences

### Positive
- **Centralized logic**: All conversion in one module
- **Consistency**: Same conversion rules everywhere
- **Documentation**: Conversion formulas clearly documented
- **Maintainability**: Changes to conversion logic in one place
- **Testability**: Conversion functions can be unit tested

### Negative
- **Conversion overhead**: Small performance cost for conversions
- **Potential for errors**: Must ensure conversions are correct
- **Data loss**: Rounding may cause minor data loss (acceptable)

### Neutral
- Game mechanics unchanged
- User experience unchanged
- Battle outcomes unchanged

## Implementation Notes

- Conversion functions in `tactical_integration.bas`:
  - `PrepareBattleData()` - Converts strategic to tactical
  - `ProcessTacticalResults()` - Converts tactical to strategic
- All conversions documented with examples
- Error handling for invalid values
- Validation to ensure conversions are within expected ranges

## Related ADRs

- ADR-0004: Unified Architecture
- ADR-0005: Modular Architecture

