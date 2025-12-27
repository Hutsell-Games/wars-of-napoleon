# WW2 Strategic Functionality Comparison

## Executive Summary

This document compares the strategic-level functionality between **World War 2 in Europe** (`WW2.EXE`) and **Wars of Napoleon** (`WON.EXE`) to identify:
- Features that exist in both games
- Features present in WON but missing from WW2
- Features unique to WW2
- Recommendations for enhancing WW2 with WON's strategic features

**Key Finding**: WW2 lacks tactical battle integration entirely, resolving all combat at the strategic level only. WON provides optional tactical battle resolution for balanced engagements (force ratios ≤ 3:1).

---

## 1. Strategic Level Features Comparison

### 1.1 Campaign Management

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Turn Duration** | 2 months | 1 month | WW2 has finer time granularity |
| **Scenario System** | Year-based (1796, 1805, 1807, 1808, 1812, 1813, 1815) | Year-based (1939, 1940, 1941, 1942, 1943, 1944, 1945) | Both use year-based scenarios |
| **Game Initialization** | From `NWSxxxx.INI` files | From `WW19xx.INI` files | Similar file-based initialization |
| **Sequence of Play** | Decision Phase → Move & Combat → Turn Update | Decision Phase → Move & Combat → Turn Update | Identical three-phase structure |
| **Save Games** | 8 slots (`NWS1.SAV` - `NWS8.SAV`) + autosave (`NWS9.SAV`) | 5 slots (`WWII1.SAV` - `WWII5.SAV`) + autosave | WON has more save slots |
| **Autosave** | End of decision phase | End of update phase (if enabled) | Different timing |

**Analysis:**
- Both games share similar campaign management structure
- WW2's monthly turns provide more granular control
- WON provides more save game slots
- Both use similar initialization file formats

### 1.2 Army Management

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Army Attributes** | Strength, Leader, Experience, Supply | Strength, Leader, Experience, Supply, Unit Type | WW2 adds unit type differentiation |
| **Strength** | Number of men | Number of men | Same |
| **Leadership** | 1-10 rating | 1-10 rating | Same |
| **Experience** | 0-10 (battles won) | 0-10 (battles won) | Same |
| **Supply** | 0-10 | 0-10 | Same |
| **Unit Types** | Generic armies | Infantry, Armor, Elite, Artillery, Static | WW2 has unit type system |
| **Recruitment** | 100 money units | Variable cost by unit type | WW2 costs vary by type |
| **Recruitment Cities** | Random selection from owned/neutral | Random selection from owned/neutral | Same |
| **New Army Movement** | Cannot move turn created | Cannot move turn created | Same |
| **Commander System** | 25 preset + generic (Roman numerals) | Similar system | Both have commander pools |
| **Stacking** | Unlimited friendly stacking | Unlimited friendly stacking | Same |
| **Stack Indicators** | Small gold circle on flag | Yellow circle on flag | Same visual indicator |
| **Combine/Join** | Up to 400,000 men | Same-type units only | WW2 restricts by unit type |
| **Detach** | 30% split, requires 6,500+ men | Similar split mechanism | Similar |
| **Drill** | Increases experience (max 5) | Increases experience | Similar |
| **Relieve** | Replace commander, -1 exp/lead | Not documented | WON has commander replacement |

**Analysis:**
- WW2 adds unit type differentiation (Infantry, Armor, Elite, Artillery, Static)
- WON allows combining different unit types up to 400,000 men
- WW2 restricts combining to same unit types only
- Both share core army management features

### 1.3 City/Territory Control

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Total Cities** | 67 cities | 58 cities | WON has more cities |
| **City Display** | Colored circles | Colored circles | Same visual system |
| **City Types** | French, Allied, Neutral, Allied at peace | Allied, Axis, Neutral | Similar |
| **Objective Cities** | 2 objectives (yellow cross) | 2 capitals (yellow cross) | Both mark special cities |
| **Fortification Levels** | 0, FORT+, FORT++ | 0, FORT+, FORT++ | Same system |
| **Fortification Cost** | 200 money units | 200 money units (reduced by Production tech) | WW2 tech affects cost |
| **Fortification Visual** | Hollow black box (FORT+), Solid black box (FORT++) | Same | Same |
| **Fortification Reduction** | -1 level when captured in combat | Same | Same |
| **Raze Fortifications** | Option when capturing unoccupied | Not documented | WON allows razing |
| **Income Generation** | Based on city value | Based on city value | Same |
| **Victory Points** | Based on city value | Based on city value | Same |
| **Objective Bonus** | +100 VP + bonus income | Capital = +100 bonus income | Similar bonus system |
| **Neutral City Capture** | Automatic capture | May require VP cost if NEUTRALS option ON | WW2 has neutral penalty option |
| **City Bombing** | Naval bombardment only | Air force can bomb cities | WW2 adds air bombing |

**Analysis:**
- WON has more cities (67 vs 58)
- Both use similar fortification systems
- WW2 adds air force city bombing capability
- WW2 has optional neutral city penalty system
- WON allows razing fortifications when capturing unoccupied cities

### 1.4 Naval Operations

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Fleet Size** | 0-10 ships | 0-10 ships | Same |
| **Ship Cost** | 100 money units | Variable (affected by Production tech) | WW2 tech affects cost |
| **Ship Movement** | Any port city per turn | Any port city per turn | Same |
| **Naval Combat** | Ship-to-ship, 10 hits per ship | Ship-to-ship, variable hits | Similar |
| **English Advantage** | 10% combat bonus | Not documented | WON has nationality bonus |
| **Bombardment** | Damage armies, reduce forts, drive to neutrality | Similar | Similar |
| **Blockade** | Reduces enemy supply | Similar | Similar |
| **Commerce Raiding** | Reduces enemy income, risks ship loss | Similar | Similar |
| **Marine Invasions** | Small invasions at neutral cities (2+ ships) | Amphibious assaults (requires Amphibious tech) | WW2 requires technology |
| **Special Sea Routes** | England-continent, Sicily/Sardinia-continent | North Sea-Baltic (Kiel), Atlantic-Mediterranean (Gibraltar) | Both have special routes |
| **Route Restrictions** | Fleet must be at origin, enemy fleet cannot be at destination | Similar + special rules for Kiel/Gibraltar | WW2 has more complex routing |

**Analysis:**
- Both share core naval mechanics
- WW2 adds technology requirements for amphibious operations
- WW2 has more complex special sea route rules (Kiel, Gibraltar)
- WON has English naval combat bonus
- Both support similar naval actions (bombardment, blockade, commerce raiding)

### 1.5 Economic System

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Income Source** | Controlled cities | Controlled cities | Same |
| **Income Calculation** | City value = income = VP | City value = income = VP | Same |
| **Bonus Income** | Allies get off-map income | Not documented | WON has bonus income |
| **Supply Cost (Auto)** | 0.002 money per 1,000 men | Similar | Similar |
| **Supply Cost (Manual)** | 0.001 money per 1,000 men | Similar | Similar |
| **Free Supply Months** | July, September (harvest) | Not documented | WON has harvest months |
| **Supply Order** | Numerical order (higher numbers last) | Similar | Same |
| **Unit Costs** | Fixed (Recruit: 100, Fortify: 200) | Variable (affected by Production tech) | WW2 tech reduces costs |
| **Cash Limits** | Not documented | Max 30,000 | WW2 has cash cap |

**Analysis:**
- Both share similar income and supply systems
- WON has harvest months with free supply
- WW2's Production technology affects unit costs
- WW2 has cash cap (30,000)
- WON gives Allies bonus income from off-map territories

### 1.6 Combat Resolution

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Strategic Combat** | Yes | Yes | Both have strategic resolution |
| **Tactical Integration** | **YES** (Registered Edition) | **NO** | **CRITICAL DIFFERENCE** |
| **Tactical Trigger** | Force ratio ≤ 3:1 | N/A | WON only |
| **Combat Factors** | Base, Ldr/Exp, Outman, Supply, Cohesion, Difclt, Fort | Base, Ldr/Exp, Small, Outman, Supply, Difclt, Technol, Fort | WW2 adds Technology factor |
| **Base Calculation** | Strength × 0.0001 (rounded up) | Strength × 0.2 + unit type bonus | Different formulas |
| **Combat Range** | 1-30 | 1-TCR (default 99, adjustable) | WW2 has higher/adjustable range |
| **Outman Adjustments** | Similar ratio table | Similar ratio table | Similar |
| **Supply Penalty** | 50% effectiveness | 50% (except Elite units) | WW2 Elite units exempt |
| **Fortification Bonus** | +50% (FORT+), +100% (FORT++) | Similar | Same |
| **Cohesion Penalty** | Yes (mixed nationalities) | Not documented | WON has cohesion system |
| **Technology Factor** | No | Yes (Land Attack/Defense tech) | WW2 only |
| **Combat Resolution** | Random vs calculated odds | Random vs calculated odds | Same method |

**Analysis:**
- **CRITICAL GAP**: WW2 completely lacks tactical battle integration
- WW2 adds technology as combat factor
- WW2 has higher/adjustable combat range (TCR)
- WW2 Elite units exempt from supply penalty
- WON has cohesion penalty for mixed nationalities
- Both use similar strategic combat resolution methods

### 1.7 Reports and Information

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Friendly Army Report** | Yes | Yes | Both have |
| **Enemy Army Report** | Yes | Yes | Both have |
| **City Report** | Yes | Yes | Both have |
| **Force Summary** | Yes (F4 hotkey) | Yes | Both have |
| **Intelligence Report** | Yes (friendly armies only) | Yes (friendly armies only) | Both have |
| **Battle Summary** | Yes | Yes | Both have |
| **Recap/History Report** | Yes (if History option ON) | Not documented | WON has chronicle |
| **Hot Keys** | F1=Help, F3=Redraw, F4=Force Summary, F7=End Turn | F1=Help, F3=Redraw, F7=End Turn | WON has F4 hotkey |

**Analysis:**
- Both provide similar reporting capabilities
- WON adds History/Recap report with battle chronicle
- WON has F4 hotkey for Force Summary
- Both share core intelligence and reporting features

### 1.8 Game Options

| Feature | WON | WW2 | Notes |
|---------|-----|-----|-------|
| **Side Selection** | French/Allies | Allies/Axis | Both allow side switching |
| **Player Mode** | 1-player/2-player | 1-player/2-player | Same |
| **Sound Options** | Sound & Music, Sound Only, Quiet | Sound & Music, Sound Only, Quiet | Same |
| **Display Speed** | Very Fast to Very Slow | Fast to Very Slow | Similar |
| **Play Balance** | Allies++ to French++ | Axis++ to Ally++ | Similar |
| **Difficulty** | Not documented | Yes | WW2 has difficulty setting |
| **Enemy Aggression** | 0-5 levels | Not documented | WON has aggression levels |
| **Random Events** | Favor French, Neutral, Favor Allies | Not documented | WON has random events |
| **History Option** | On/Off (enables Recap report) | Not documented | WON only |
| **Tactical Battles** | **On/Off (Registered Edition)** | **N/A** | **WON only** |
| **Vary Start** | Yes | Yes | Both have |
| **End Game Conditions** | 5 types (Time, % Cities, % Income, Objective, Strength Ratio) | 3 types (Time, % Cities, Capital) | WON has more conditions |
| **End Game Override** | Yes (with VP penalty) | Yes (increases threshold) | Both have |
| **Neutrals Option** | Not documented | Yes (10 VP cost to enter) | WW2 only |
| **Weather** | Not documented | Yes (Clear, Blizzard, Flood, Storm) | WW2 only |
| **Mouse Support** | Not documented | Yes | WW2 only |
| **PBM Support** | Not documented | Yes | WW2 only |
| **Editor Access** | Not documented | Yes (scenario editor) | WW2 only |

**Analysis:**
- WON has Tactical Battles option (WW2 lacks)
- WON has Random Events system (WW2 lacks)
- WON has History option (WW2 lacks)
- WW2 has Weather system (WON lacks)
- WW2 has Mouse support (WON lacks)
- WW2 has PBM support (WON lacks)
- WW2 has scenario editor access (WON lacks)
- Both share core options (side, players, sound, display, balance)

---

## 2. Missing Functionality in WW2

### 2.1 Tactical Battle Integration

**Status**: **COMPLETELY MISSING**

**What WON Provides:**
- Optional tactical battle resolution for balanced engagements (force ratios ≤ 3:1)
- Seamless transition from strategic to tactical level
- Detailed hex-based battle resolution
- Results feed back to strategic game

**Impact:**
- WW2 players cannot experience detailed tactical battles
- All combat resolved abstractly at strategic level
- Missing immersive battlefield experience
- No opportunity to influence battle outcomes through tactical skill

**Recommendation**: **HIGH PRIORITY** - Implement tactical battle integration similar to WON

### 2.2 Random Events System

**Status**: Missing

**What WON Provides:**
- Random events that affect gameplay
- Options: Favor French, Neutral, Favor Allies
- Events can award victory points or affect game state
- Historical flavor (e.g., French commander disloyalty)

**Impact:**
- WW2 lacks historical event system
- Less variety in gameplay
- Missing historical flavor

**Recommendation**: **MEDIUM PRIORITY** - Add random events system

### 2.3 History/Recap Report

**Status**: Missing

**What WON Provides:**
- Chronicle of battle outcomes and losses
- Historical record of game progress
- Example format: `Metz *Napoleon (3200/29600) defeats Alvintzi (5400/30200)`
- Accessible via Inform menu when History option enabled

**Impact:**
- WW2 lacks battle history tracking
- Cannot review past engagements
- Less historical context

**Recommendation**: **LOW PRIORITY** - Add history/recap report

### 2.4 Cohesion System

**Status**: Missing

**What WON Provides:**
- Penalty when commander nationality differs from army nationality
- Affects combat effectiveness
- Can be remedied by swapping commanders (Relieve command)

**Impact:**
- WW2 lacks nationality cohesion mechanics
- Less historical accuracy
- Missing strategic decision point (commander assignment)

**Recommendation**: **LOW PRIORITY** - Add cohesion system if implementing nationality mechanics

### 2.5 Relieve Command

**Status**: Missing

**What WON Provides:**
- Replace commander with another from available pool
- Unit cannot have move orders
- Penalty: -1 experience, -1 leadership
- Relieved commander returns to available pool

**Impact:**
- WW2 cannot swap commanders
- Less flexibility in army management
- Cannot remedy cohesion issues

**Recommendation**: **LOW PRIORITY** - Add Relieve command if implementing cohesion

### 2.6 Raze Fortifications

**Status**: Missing

**What WON Provides:**
- Option to raze fortifications when capturing unoccupied fortified city
- Completely destroys fortifications (even FORT++)
- Strategic decision point

**Impact:**
- WW2 cannot destroy fortifications when capturing
- Fortifications persist after capture
- Less strategic options

**Recommendation**: **LOW PRIORITY** - Add raze fortifications option

### 2.7 Harvest Months

**Status**: Missing

**What WON Provides:**
- July and September provide free supply
- Represents harvest season
- Reduces economic pressure during these months

**Impact:**
- WW2 lacks seasonal supply variations
- Less historical accuracy
- Missing economic cycle

**Recommendation**: **LOW PRIORITY** - Add seasonal supply variations

### 2.8 More Save Game Slots

**Status**: Partial (WON has 8, WW2 has 5)

**What WON Provides:**
- 8 user save slots (`NWS1.SAV` - `NWS8.SAV`)
- Plus autosave slot (`NWS9.SAV`)

**Impact:**
- WW2 has fewer save slots
- Less flexibility for multiple games

**Recommendation**: **LOW PRIORITY** - Increase save slots to 8

### 2.9 More End Game Conditions

**Status**: Partial (WON has 5, WW2 has 3)

**What WON Provides:**
- Time (Month & Year)
- % Cities Controlled
- % Income
- Objective Capture
- Total Force Strength Ratio

**WW2 Has:**
- Time (Month & Year)
- % Cities Controlled
- Capital Capture

**Missing:**
- % Income condition
- Total Force Strength Ratio condition

**Recommendation**: **LOW PRIORITY** - Add % Income and Strength Ratio conditions

---

## 3. Additional Functionality in WW2

### 3.1 Air Force System

**Status**: WW2 Only

**Features:**
- Up to 10 planes per side
- Air base location system
- Range-based operations
- Bombing missions (cities, armies, navies)
- Dogfights when bombing enemy air bases
- Paratroop capacity based on air force size and technology
- Technology affects plane capabilities
- Cost: 70 credits per plane (base, reduced by Production tech)

**Impact:**
- Adds modern warfare element
- Strategic bombing capability
- Air superiority mechanics
- Not applicable to Napoleonic era

### 3.2 Technology System

**Status**: WW2 Only

**Features:**
- 8 technology categories:
  1. Land Attack
  2. Land Defense
  3. Land Move
  4. Navy Attack
  5. Navy Defend
  6. Seaborne (Amphibious/Invasion)
  7. Air Attack
  8. Production
- Levels: 0 (Standard), 1 (Improved), 2 (Advanced), 3 (Ultramodern)
- Costs: 200 credits (500 for Production)
- Technology Success Factor (TSF) controls success chance
- Affects combat, movement, unit costs, capabilities

**Impact:**
- Represents technological advancement during WWII
- Strategic research decisions
- Affects all aspects of gameplay
- Not applicable to Napoleonic era (relatively static technology)

### 3.3 Weather System

**Status**: WW2 Only

**Features:**
- 4 weather conditions: Clear, Blizzard, Flood, Storm
- Affects movement, supply, naval/air operations
- Blizzard: Infantry (exp<8) and Artillery (move tech<2) can't move, +1 supply use
- Flood: Units need move tech≥2 or high leadership/experience
- Storm: Prohibits naval/air unless highest tech level, 3× invasion losses

**Impact:**
- Adds environmental factors
- Historical weather effects
- Strategic planning considerations
- Not in WON (simpler model)

### 3.4 Unit Type System

**Status**: WW2 Only

**Features:**
- Infantry, Armor, Elite, Artillery, Static unit types
- Different movement speeds, combat capabilities
- Type affects combine restrictions (same type only)
- Type affects combat bonuses
- Elite units exempt from supply penalty

**Impact:**
- More detailed unit differentiation
- Historical unit types
- Strategic unit composition decisions
- WON uses generic armies

### 3.5 Mouse Support

**Status**: WW2 Only

**Features:**
- Full mouse control for menu selection
- Map-based unit selection
- Click to move armies
- Right mouse button = Escape key
- Convenient for movement and selection

**Impact:**
- Improved user interface
- Faster gameplay
- Modern interface feature
- WON keyboard-only

### 3.6 PBM (Play-by-Mail) Support

**Status**: WW2 Only

**Features:**
- Automated file exchange system
- `PBM` file created after each turn
- Supports email or disk exchange
- Automated turn sequence
- Score screen at game end

**Impact:**
- Enables remote multiplayer
- Automated file management
- Convenient for long-distance play
- WON lacks this feature

### 3.7 Scenario Editor Access

**Status**: WW2 Only

**Features:**
- Built-in editor access from main menu
- Create/edit custom scenarios
- Modify starting conditions
- Customize game parameters

**Impact:**
- User-created content
- Extended replayability
- Custom scenarios
- WON lacks editor access

### 3.8 Neutrals Option

**Status**: WW2 Only

**Features:**
- Optional 10 VP cost to enter neutral cities
- Only applies to cities neutral at scenario start
- Special case: Minsk activates Russia
- Toggle on/off in Utility menu

**Impact:**
- Adds strategic cost to expansion
- Historical neutrality respect
- Strategic decision point
- WON treats neutrals as free captures

### 3.9 Production Technology Cost Reduction

**Status**: WW2 Only

**Features:**
- Production technology reduces unit costs
- Example: Fortifications cost 190 instead of 200 at Improved level
- Affects all unit purchases
- Reduces technology costs themselves

**Impact:**
- Economic progression
- Technology investment payoff
- Strategic research decisions
- WON has fixed costs

---

## 4. Recommendations

### 4.1 High Priority: Tactical Battle Integration

**Recommendation**: Implement tactical battle integration similar to WON

**Implementation Approach:**
1. Create tactical battle module (`WW2TACTICAL.EXE` or similar)
2. Implement hex-based battle system
3. Create `battle.$$$` file interface
4. Add TACTICAL option to Utility menu
5. Trigger tactical battles for force ratios ≤ 3:1
6. Transfer unit types, technology levels, and other WW2-specific data
7. Return battle results to strategic game

**Benefits:**
- Immersive battlefield experience
- Player skill affects outcomes
- Detailed combat resolution
- Matches WON's feature set

**Challenges:**
- Requires new tactical module development
- Must handle WW2 unit types (Infantry, Armor, Elite, Artillery)
- Must incorporate technology effects
- File format must include WW2-specific data

### 4.2 Medium Priority: Random Events System

**Recommendation**: Add random events system

**Implementation Approach:**
1. Create `SPECIAL.EVT` file (WW2 already has this file!)
2. Add random event triggers during turn update
3. Add Utility menu option: Favor Axis, Neutral, Favor Allies
4. Events affect victory points, unit strengths, or game state
5. Historical events (e.g., Operation Barbarossa, D-Day, etc.)

**Benefits:**
- Adds historical flavor
- Increases gameplay variety
- Strategic uncertainty
- Matches WON's feature set

### 4.3 Low Priority: History/Recap Report

**Recommendation**: Add battle history chronicle

**Implementation Approach:**
1. Track battle outcomes in memory/array
2. Format: `City *Attacker (casualties/total) defeats Defender (casualties/total)`
3. Add History option to Utility menu
4. Add Recap report to Inform menu (when History ON)
5. Display scrollable list of battles

**Benefits:**
- Historical record
- Review past engagements
- Better game context

### 4.4 Low Priority: Additional Features

**Consider Adding:**
- Cohesion system (if implementing nationality mechanics)
- Relieve command (if implementing cohesion)
- Raze fortifications option
- Harvest months (seasonal supply)
- More save slots (8 instead of 5)
- Additional end game conditions (% Income, Strength Ratio)

**Priority**: Low - Nice to have but not critical

---

## 5. Compatibility Considerations

### 5.1 File Format Compatibility

**Current WW2 Files:**
- `WW19xx.INI` - Scenario initialization
- `EURO19xx.DAT` - City data
- `WW2.CFG` - Configuration
- `WWIIx.SAV` - Save games

**WON Files:**
- `NWSxxxx.INI` - Scenario initialization
- `EUROxxxx.MAP` - City data
- `NWS.CFG` - Configuration
- `NWSx.SAV` - Save games

**Considerations:**
- File formats are similar but not identical
- WW2 uses `.DAT` for city files, WON uses `.MAP`
- WW2 uses `WW19xx.INI`, WON uses `NWSxxxx.INI`
- Naming conventions differ but structure similar

### 5.2 Data Structure Compatibility

**WW2 Additional Data:**
- Unit types (Infantry, Armor, Elite, Artillery, Static)
- Technology levels (8 categories)
- Air force data
- Weather conditions
- Mouse/PBM settings

**WON Additional Data:**
- Cohesion information
- Random event flags
- History data
- Tactical battle settings

**Considerations:**
- WW2 has more complex data structures
- Tactical integration must handle WW2-specific data
- File format must accommodate all WW2 features

### 5.3 Integration Challenges

**WW2-Specific Considerations:**
1. **Unit Types**: Tactical module must handle Infantry, Armor, Elite, Artillery, Static
2. **Technology**: Must transfer technology levels and apply effects
3. **Air Force**: May need to represent air support in tactical battles
4. **Weather**: May affect tactical battle conditions
5. **Mouse Support**: Tactical module should support mouse if strategic does

**Recommendations:**
- Design flexible file format to accommodate WW2 data
- Tactical module should handle unit types appropriately
- Technology effects should modify tactical combat
- Consider air support representation
- Maintain UI consistency (mouse support)

---

## 6. Summary Tables

### 6.1 Feature Comparison Summary

| Category | WON Features | WW2 Features | Shared Features | WW2 Missing | WON Missing |
|---------|-------------|-------------|----------------|-------------|-------------|
| **Campaign** | 2-month turns, 8 saves | 1-month turns, 5 saves | Scenario system, 3-phase play | More save slots | Finer time granularity |
| **Armies** | Generic, combine any | Unit types, combine same | Core attributes, recruitment | Cohesion, Relieve | Unit types |
| **Cities** | 67 cities, raze forts | 58 cities | Fortification, income | Raze option | Air bombing |
| **Naval** | English bonus | Tech requirements | Core mechanics | - | Tech system |
| **Economic** | Harvest months, bonus income | Production tech | Core system | Harvest months | Tech cost reduction |
| **Combat** | **Tactical integration** | Technology factor | Strategic combat | **TACTICAL** | Technology |
| **Reports** | History/Recap | - | Core reports | History report | - |
| **Options** | Tactical, Random Events, History | Weather, Mouse, PBM, Editor | Core options | Tactical, Events | Weather, Mouse, PBM |

### 6.2 Priority Recommendations

| Priority | Feature | Impact | Effort | Recommendation |
|----------|---------|--------|--------|----------------|
| **HIGH** | Tactical Integration | Very High | High | Implement tactical battle module |
| **MEDIUM** | Random Events | Medium | Medium | Add events system |
| **LOW** | History Report | Low | Low | Add battle chronicle |
| **LOW** | Cohesion System | Low | Medium | Add if implementing nationalities |
| **LOW** | Additional Features | Low | Low | Various small enhancements |

---

## 7. Conclusion

**Key Findings:**

1. **WW2 lacks tactical battle integration** - This is the most significant gap compared to WON
2. **WW2 has modern warfare features** - Air force, technology, weather (not applicable to WON)
3. **WON has historical features** - Random events, history report, cohesion (not in WW2)
4. **Both share core strategic mechanics** - Similar campaign, army, city, naval, economic systems
5. **WW2 has better UI** - Mouse support, PBM, editor access

**Primary Recommendation:**

Implement tactical battle integration for WW2 to match WON's feature set. This would provide:
- Immersive battlefield experience
- Player skill affecting outcomes
- Detailed combat resolution
- Feature parity with WON

**Secondary Recommendations:**

- Add random events system for historical flavor
- Add history/recap report for battle tracking
- Consider cohesion system if implementing nationality mechanics

**WW2 Strengths to Preserve:**

- Air force system (unique to WW2)
- Technology system (represents WWII advancement)
- Weather system (adds environmental factors)
- Mouse support (better UI)
- PBM support (remote multiplayer)
- Scenario editor (user content)

---

## 8. References

### Source Files

- **WON Documentation**: `c:\code\hutsell\wars-of-napoleon\WON.DOC`
- **WW2 Documentation**: `c:\code\hutsell\world-war-2\WW2.DOC`
- **WON Source**: `c:\code\hutsell\wars-of-napoleon\NAPOLEON.BAS` (tactical module)
- **WW2 Source**: `c:\code\hutsell\world-war-2\WW2.BAS` (strategic game)

### Key Documentation Sections

- **WON Strategic Features**: `WON.DOC` sections 2-6
- **WON Tactical Integration**: `WON.DOC` sections 1.4, 5.5
- **WW2 Strategic Features**: `WW2.DOC` sections 2-7
- **WW2 Combat Resolution**: `WW2.DOC` section 7.4-7.5

---

*Document created based on comprehensive analysis of WON.DOC and WW2.DOC documentation.*

