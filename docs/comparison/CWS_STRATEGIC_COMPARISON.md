# CWS Strategic Functionality Comparison

## Executive Summary

This document compares the strategic-level functionality between **Civil War Strategy** (`CWS.EXE`) and **Wars of Napoleon** (`WON.EXE`) to identify:
- Features that exist in both games
- Features present in WON but missing from CWS
- Features unique to CWS
- Recommendations for enhancing WON with CWS's strategic features

**Key Finding**: CWS shares many features with WON, including Random Events, History/Recap reports, Relieve command, and raze fortifications. CWS adds unique features like Railroad system and Move Capital that could enhance WON.

---

## 1. Strategic Level Features Comparison

### 1.1 Campaign Management

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Turn Duration** | 2 months | 2 months | **IDENTICAL** |
| **Scenario System** | Year-based (1796, 1805, 1807, 1808, 1812, 1813, 1815) | Single scenario (1861-1865) | WON has multiple scenarios |
| **Game Initialization** | From `NWSxxxx.INI` files | From `CWS.INI` file | Similar file-based initialization |
| **Sequence of Play** | Decision Phase → Move & Combat → Turn Update | Decision Phase → Move & Combat → Turn Update | **IDENTICAL** three-phase structure |
| **Save Games** | 8 slots (`NWS1.SAV` - `NWS8.SAV`) + autosave (`NWS9.SAV`) | 9 slots (`CWS1.SAV` - `CWS9.SAV`) | CWS has more save slots |
| **Autosave** | End of decision phase | Not documented | WON has autosave |

**Analysis:**
- Both games share identical turn structure (2 months)
- WON has multiple scenarios vs CWS single scenario
- CWS has more save slots (9 vs 8)
- Both use similar initialization file formats

### 1.2 Army Management

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Army Attributes** | Strength, Leader, Experience, Supply | Strength, Leader, Experience, Supply | **IDENTICAL** |
| **Strength** | Number of men | Number of men | Same |
| **Leadership** | 1-10 rating | 1-10 rating | Same |
| **Experience** | 0-10 (battles won) | 0-10 (battles won) | Same |
| **Supply** | 0-10 | 0-10 | Same |
| **Unit Types** | Generic armies | Generic armies | **IDENTICAL** (both generic) |
| **Recruitment** | 100 money units | 100 money units | Same cost |
| **Recruitment Cities** | Random selection from owned/neutral | Random selection from owned (Realism affects) | CWS Realism toggle affects |
| **New Army Size** | Variable (depends on city) | 7,000 men (fixed) or variable (Realism ON) | CWS has Realism toggle |
| **New Army Movement** | Cannot move turn created | Cannot move turn created | Same |
| **Commander System** | 25 preset + generic (Roman numerals) | 20 preset + generic (Roman numerals) | Similar (WON has more commanders) |
| **Stacking** | Unlimited friendly stacking | Unlimited friendly stacking | Same |
| **Stack Indicators** | Small gold circle on flag | Small gold circle on flag | Same |
| **Combine/Join** | Up to 400,000 men | Up to 125,000 men | WON allows larger combines |
| **Detach** | Both sides, 30% split, requires 6,500+ men | Rebel side ONLY, 30% split, requires 6,500+ men | CWS restricts to one side |
| **Drill** | Increases experience (max 5) | Increases experience (max 5, cannot exceed leader rating) | Similar (CWS adds leader rating limit) |
| **Relieve** | Replace commander, -1 exp/lead | Replace commander, -1 exp/lead | **IDENTICAL** |

**Analysis:**
- Both share identical core army attributes
- Both use generic armies (no unit types)
- WON allows larger army combines (400K vs 125K)
- CWS restricts Detach to Rebel side only
- CWS Realism toggle affects recruitment (city size matters)
- Both have Relieve command with identical mechanics

### 1.3 City/Territory Control

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Total Cities** | 67 cities | 40 cities | WON has more cities |
| **City Display** | Colored circles | Colored circles | Same visual system |
| **City Types** | French, Allied, Neutral, Allied at peace | Union, Confederate, Neutral | Similar |
| **Objective/Capital Cities** | 2 objectives (yellow cross) | 2 capitals (yellow cross) | Similar |
| **Capital Bonus** | +100 VP + bonus income | +50 VP + bonus income | WON has larger bonus |
| **Move Capital** | Not available | **YES** (500 money, awards enemy 50 VP) | **CWS UNIQUE** |
| **Fortification Levels** | 0, FORT+, FORT++ | 0, FORT+, FORT++ | Same system |
| **Fortification Cost** | 200 money units | 200 money units | Same |
| **Fortification Visual** | Hollow black box (FORT+), Solid black box (FORT++) | Same | Same |
| **Fortification Reduction** | -1 level when captured in combat | -1 level when captured in combat | Same |
| **Raze Fortifications** | Option when capturing unoccupied | Option when capturing unoccupied | **IDENTICAL** |
| **Income Generation** | Based on city value | Based on city value | Same |
| **Victory Points** | Based on city value | Based on city value | Same |
| **Neutral City Capture** | Automatic capture | Automatic capture | Same |
| **City Bombing** | Naval bombardment only | Naval bombardment only | Same |

**Analysis:**
- WON has more cities (67 vs 40)
- **CWS has Move Capital feature** - WON lacks this
- WON has larger capital bonus (+100 vs +50 VP)
- Both share identical fortification systems
- Both allow razing fortifications

### 1.4 Naval Operations

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Fleet Size** | 0-10 ships | 0-10 ships | Same |
| **Ship Types** | Generic ships | **Wooden ships AND Ironclads** | **CWS UNIQUE** |
| **Wooden Ship Cost** | 100 money units | 100 money units | Same |
| **Ironclad Cost** | N/A | 200 money units | CWS only |
| **Ironclad Advantages** | N/A | 10% more effective, 20 hits vs 10 hits | CWS only |
| **Ship Movement** | Any port city per turn | Any port city per turn | Same |
| **Naval Combat** | Ship-to-ship, 10 hits per ship | Ship-to-ship, 10 hits (wooden) or 20 hits (ironclad) | CWS has ironclads |
| **English Advantage** | 10% combat bonus | Not documented | WON has nationality bonus |
| **Bombardment** | Damage armies, reduce forts, drive to neutrality | Damage armies, reduce forts, drive to neutrality | Same |
| **Blockade** | Reduces enemy supply | Reduces enemy supply | Same |
| **Commerce Raiding** | Reduces enemy income, risks ship loss | Reduces enemy income, risks ship loss | Same |
| **Marine Invasions** | Small invasions at neutral cities (2+ ships) | Small invasions at neutral cities (2+ ships, 3,500 men) | Similar (CWS specifies size) |
| **Invasion Restrictions** | None | Union only if Realism ON | CWS Realism affects |
| **Port Attack Restriction** | Not documented | Cannot move to port and attack same turn | CWS has restriction |

**Analysis:**
- **CWS has ironclads** - WON lacks ship type differentiation
- CWS ironclads are more powerful but cost more
- CWS Realism toggle affects invasion ability
- CWS has port attack restriction
- Both share core naval mechanics

### 1.5 Economic System

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Income Source** | Controlled cities | Controlled cities | Same |
| **Income Calculation** | City value = income = VP | City value = income = VP | Same |
| **Bonus Income** | Allies get off-map income | Union gets off-map income | Similar (different sides) |
| **Supply Cost (Auto)** | 0.002 money per 1,000 men | 0.002 money per 1,000 men | **IDENTICAL** |
| **Supply Cost (Manual)** | 0.001 money per 1,000 men | 0.001 money per 1,000 men | **IDENTICAL** |
| **Free Supply Months** | July, September (harvest) | July, September (harvest) | **IDENTICAL** |
| **Supply Order** | Numerical order (higher numbers last) | Numerical order (higher numbers last) | Same |
| **Unit Costs** | Fixed (Recruit: 100, Fortify: 200) | Fixed (Recruit: 100, Fortify: 200) | Same |
| **Cash Limits** | Not documented | Not documented | Neither has documented cap |

**Analysis:**
- **IDENTICAL** economic systems
- Both have harvest months (July, September)
- Both have identical supply costs
- Both use same income calculation

### 1.6 Combat Resolution

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Strategic Combat** | Yes | Yes | Both have strategic resolution |
| **Tactical Integration** | **YES** (Registered Edition) | **NO** | WON only |
| **Tactical Trigger** | Force ratio ≤ 3:1 | N/A | WON only |
| **Combat Factors** | Base, Ldr/Exp, Outman, Supply, Cohesion, Difclt, Fort | Base, Ldr/Exp, Small, Outman, Supply, Difclt, Fort | CWS adds Small factor |
| **Base Calculation** | Strength × 0.0001 (rounded up) | Strength ÷ 10,000 (rounded up) | **IDENTICAL** (same formula) |
| **Combat Range** | 1-30 (TCR=30) | 1-20 (TCR=20, adjustable) | WON has higher range |
| **Outman Adjustments** | Similar ratio table | Similar ratio table | Similar |
| **Supply Penalty** | 50% effectiveness | 50% effectiveness | Same |
| **Fortification Bonus** | +50% (FORT+), +100% (FORT++) | Similar | Same |
| **Cohesion Penalty** | Yes (mixed nationalities) | Not documented | WON has cohesion system |
| **Small Force Penalty** | Not documented | Yes (<1,500 men) | CWS has small force penalty |
| **Realism Defense Bonus** | Not documented | Yes (when Realism ON) | CWS Realism affects combat |
| **Combat Resolution** | Random vs calculated odds | Random vs calculated odds | Same method |

**Analysis:**
- **WON has tactical integration** - CWS lacks this
- Both share similar strategic combat systems
- CWS adds Small force penalty
- CWS Realism toggle increases defender advantage
- WON has cohesion penalty system
- WON has higher combat range (30 vs 20)

### 1.7 Reports and Information

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Friendly Army Report** | Yes | Yes | Both have |
| **Enemy Army Report** | Yes | Yes | Both have |
| **City Report** | Yes | Yes | Both have |
| **Force Summary** | Yes (F4 hotkey) | Yes | Both have (WON has hotkey) |
| **Intelligence Report** | Yes (friendly armies only) | Yes (friendly armies only) | Both have |
| **Battle Summary** | Yes | Yes | Both have |
| **Recap/History Report** | Yes (if History option ON) | Yes (if History option ON) | **IDENTICAL** |
| **History File** | Not documented | `CWS.HIS` and `BATTSUMM` files | CWS creates files |
| **Hot Keys** | F1=Help, F3=Redraw, F4=Force Summary, F7=End Turn | F1=Help, F3=Redraw, F7=End Turn | WON has F4 hotkey |

**Analysis:**
- Both provide identical reporting capabilities
- Both have History/Recap report
- CWS creates history files (`CWS.HIS`, `BATTSUMM`)
- WON has F4 hotkey for Force Summary
- Both share core intelligence and reporting features

### 1.8 Game Options

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Side Selection** | French/Allies | Union/Rebel | Both allow side switching |
| **Player Mode** | 1-player/2-player | Solo/2-player | Same |
| **Sound Options** | Sound & Music, Sound Only, Quiet | Sound & Music, Sound Only, Quiet | Same |
| **Display Speed** | Very Fast to Very Slow | Fast to Very Slow | Similar |
| **Play Balance** | Allies++ to French++ | Rebel++ to Union++ | Similar |
| **Difficulty** | Not documented | Yes (face graphics) | CWS has difficulty |
| **Enemy Aggression** | 0-5 levels | 0-5 levels | **IDENTICAL** |
| **Random Events** | Favor French, Neutral, Favor Allies | Favor Union, Neutral, Favor Rebels | **IDENTICAL** |
| **History Option** | On/Off (enables Recap report) | On/Off (enables Recap report, creates files) | **IDENTICAL** |
| **Tactical Battles** | On/Off (Registered Edition) | N/A | WON only |
| **Vary Start** | Yes | Yes | Both have |
| **End Game Conditions** | 5 types (Time, % Cities, % Income, Objective, Strength Ratio) | 5 types (Time, % Cities, % Income, Capital, Strength Ratio) | **IDENTICAL** |
| **End Game Override** | Yes (with VP penalty) | Yes (increases threshold) | Both have (different mechanics) |
| **Realism Toggle** | Not documented | **YES** (affects recruitment, invasions, railroad, combat) | **CWS UNIQUE** |
| **January Campaigns** | Not documented | **YES** (toggle to allow/disallow) | **CWS UNIQUE** |
| **Check Links** | Not documented | **YES** (utility to check map links) | **CWS UNIQUE** |
| **Graphics Levels** | Not documented | **G0-G3** (4 levels) | **CWS UNIQUE** |

**Analysis:**
- Both share core options (side, players, sound, display, balance)
- **CWS has Realism toggle** - WON lacks this comprehensive option
- **CWS has January Campaigns toggle** - WON lacks this
- **CWS has Check Links utility** - WON lacks this
- **CWS has Graphics levels** - WON lacks this
- Both have Random Events and History options

### 1.9 Special Features

| Feature | WON | CWS | Notes |
|---------|-----|-----|-------|
| **Railroad System** | Not available | **YES** (1 army per side, capacity 30K-60K) | **CWS UNIQUE** |
| **Railroad Capacity** | N/A | Variable (Realism affects) | CWS only |
| **Move Capital** | Not available | **YES** (500 money, awards enemy 50 VP) | **CWS UNIQUE** |
| **Ironclads** | Not available | **YES** (200 money, superior to wooden) | **CWS UNIQUE** |
| **Realism Toggle** | Not available | **YES** (affects recruitment, invasions, railroad, combat, ironclad timing) | **CWS UNIQUE** |
| **January Campaigns** | Not available | **YES** (toggle to allow/disallow) | **CWS UNIQUE** |
| **Check Links** | Not available | **YES** (utility to check map connectivity) | **CWS UNIQUE** |
| **Graphics Levels** | Not available | **YES** (G0-G3, 4 levels) | **CWS UNIQUE** |
| **Tactical Integration** | **YES** | Not available | **WON UNIQUE** |
| **Cohesion System** | **YES** (mixed nationalities) | Not available | **WON UNIQUE** |
| **More Cities** | **67 cities** | 40 cities | WON has more |
| **More Scenarios** | **7 scenarios** | 1 scenario | WON has more |
| **More Commanders** | **25 per side** | 20 per side | WON has more |

**Analysis:**
- **CWS has Railroad system** - Major unique feature
- **CWS has Move Capital** - Strategic option WON lacks
- **CWS has Realism toggle** - Comprehensive gameplay modifier
- **WON has Tactical integration** - Major unique feature
- **WON has Cohesion system** - Historical accuracy feature
- WON has more cities, scenarios, and commanders

---

## 2. Missing Functionality in CWS

### 2.1 Tactical Battle Integration

**Status**: **COMPLETELY MISSING**

**What WON Provides:**
- Optional tactical battle resolution for balanced engagements (force ratios ≤ 3:1)
- Seamless transition from strategic to tactical level
- Detailed hex-based battle resolution
- Results feed back to strategic game

**Impact:**
- CWS players cannot experience detailed tactical battles
- All combat resolved abstractly at strategic level
- Missing immersive battlefield experience
- No opportunity to influence battle outcomes through tactical skill

**Recommendation**: **HIGH PRIORITY** - Implement tactical battle integration similar to WON

### 2.2 Cohesion System

**Status**: Missing

**What WON Provides:**
- Penalty when commander nationality differs from army nationality
- Affects combat effectiveness
- Can be remedied by swapping commanders (Relieve command)

**Impact:**
- CWS lacks nationality cohesion mechanics
- Less historical accuracy
- Missing strategic decision point (commander assignment)

**Recommendation**: **LOW PRIORITY** - Add cohesion system if implementing nationality mechanics

### 2.3 More Scenarios

**Status**: Partial (CWS has 1, WON has 7)

**What WON Provides:**
- Multiple year-based scenarios (1796, 1805, 1807, 1808, 1812, 1813, 1815)
- Different starting conditions
- Different historical contexts

**Impact:**
- CWS has single scenario only
- Less replayability
- Less historical variety

**Recommendation**: **LOW PRIORITY** - Add alternate scenarios (CWS does have ALTMAP system)

### 2.4 More Cities

**Status**: Partial (CWS has 40, WON has 67)

**What WON Provides:**
- 67 cities on map
- More strategic depth
- More movement options

**Impact:**
- CWS has fewer cities
- Less strategic complexity
- Smaller map

**Recommendation**: **LOW PRIORITY** - Map size is scenario-dependent

### 2.5 More Commanders

**Status**: Partial (CWS has 20 per side, WON has 25 per side)

**What WON Provides:**
- 25 commanders per side
- More flexibility in army management
- More historical commanders

**Impact:**
- CWS has fewer commanders
- Less flexibility
- Fewer historical options

**Recommendation**: **LOW PRIORITY** - Commander count is scenario-dependent

---

## 3. Additional Functionality in CWS

### 3.1 Railroad System

**Status**: CWS Only

**Features:**
- Rapid movement of 1 army per side per turn
- Union capacity: 60,000 men
- Rebel capacity: 30,000 men
- Both terminals must be in chain of 3+ connected friendly cities
- Cannot be cancelled once selected
- Arrives at BEGINNING of move phase (before other moves)
- Visual indicator: train icon in upper left corner
- Capacity variable if Realism ON (based on cities held)

**Impact:**
- Adds rapid strategic movement
- Historical Civil War feature
- Strategic decision point
- Not applicable to Napoleonic era (railroads not yet developed)

**Recommendation**: **NOT APPLICABLE** - Railroads not historically appropriate for Napoleonic era

### 3.2 Move Capital Feature

**Status**: CWS Only

**Features:**
- Move capital to different city
- Cost: 500 money units
- Awards enemy 50 victory points
- Prevents capital capture ending game
- Strategic retreat option

**Impact:**
- Adds strategic flexibility
- Historical feature (governments did relocate)
- Prevents automatic game end
- Could be applicable to Napoleonic era

**Recommendation**: **MEDIUM PRIORITY** - Could add strategic depth to WON

### 3.3 Realism Toggle

**Status**: CWS Only

**Features:**
- Comprehensive gameplay modifier affecting:
  - **Recruitment**: City size affects recruit numbers (vs fixed)
  - **Recruitment Location**: Only in originally friendly/neutral cities
  - **Isolated Cities**: Reduced recruitment (1/3 normal)
  - **Railroad Capacity**: Variable based on cities held
  - **Invasions**: Union only (vs both sides)
  - **Defender Advantage**: Increased combat bonus
  - **Ironclad Timing**: Cannot build before 1862

**Impact:**
- Adds historical accuracy options
- Multiple gameplay effects
- Strategic depth
- Could be adapted for WON

**Recommendation**: **MEDIUM PRIORITY** - Could add realism options to WON

### 3.4 Ironclads vs Wooden Ships

**Status**: CWS Only

**Features:**
- Two ship types: Wooden (100 money) and Ironclads (200 money)
- Ironclads: 10% more effective, 20 hits vs 10 hits
- Fleet composition shown (I=Ironclad, W=Wooden)
- Ironclads added to left, wooden to right
- Combat proceeds right to left
- Realism toggle prevents ironclads before 1862

**Impact:**
- Historical Civil War feature
- Strategic ship type decisions
- Cost vs effectiveness tradeoff
- Not applicable to Napoleonic era (ironclads post-Napoleonic)

**Recommendation**: **NOT APPLICABLE** - Ironclads not historically appropriate for Napoleonic era

### 3.5 January Campaigns Toggle

**Status**: CWS Only

**Features:**
- Toggle to allow/disallow January campaigns
- When OFF: No land campaigns in January (can move to friendly, fortify, naval OK)
- Historical: Winter campaigns were difficult
- Can be toggled on/off

**Impact:**
- Adds historical accuracy
- Seasonal campaign restrictions
- Strategic planning consideration
- Could be applicable to WON (winter restrictions)

**Recommendation**: **LOW PRIORITY** - Could add seasonal restrictions to WON

### 3.6 Check Links Utility

**Status**: CWS Only

**Features:**
- Utility to check map connectivity
- Identifies missing return route links
- Can correct links for current game
- Useful for custom map design
- Accessed via Utility menu

**Impact:**
- Map design tool
- Prevents connectivity errors
- Useful for scenario creation
- Could be useful for WON map editing

**Recommendation**: **LOW PRIORITY** - Useful utility but not critical

### 3.7 Graphics Levels

**Status**: CWS Only

**Features:**
- Four graphics levels: G0-G3
  - G0: No additional graphics (BASIC)
  - G1: Show city connections
  - G2: Show city connections and city names
  - G3: Show connections, names, and combat graphics
- Higher levels slow game slightly
- Toggle in Utility menu

**Impact:**
- Performance options
- User preference
- Visual clarity options
- Could be useful for WON

**Recommendation**: **LOW PRIORITY** - Nice to have but not essential

---

## 4. Recommendations

### 4.1 High Priority: Tactical Battle Integration

**Recommendation**: CWS should implement tactical battle integration similar to WON

**Implementation Approach:**
1. Create tactical battle module (`CWSTACTICAL.EXE` or similar)
2. Implement hex-based battle system
3. Create `battle.$$$` file interface
4. Add TACTICAL option to Utility menu
5. Trigger tactical battles for force ratios ≤ 3:1
6. Transfer army data, commander info, and other CWS-specific data
7. Return battle results to strategic game

**Benefits:**
- Immersive battlefield experience
- Player skill affects outcomes
- Detailed combat resolution
- Matches WON's feature set

**Challenges:**
- Requires new tactical module development
- Must handle CWS-specific features (no unit types, generic armies)
- File format must include CWS-specific data

### 4.2 Medium Priority: Move Capital Feature

**Recommendation**: WON could benefit from Move Capital feature

**Implementation Approach:**
1. Add Move Capital option to Commands menu
2. Cost: 500 money units (or appropriate for WON)
3. Awards enemy victory points (50 or appropriate)
4. Prevents objective capture ending game
5. Strategic retreat option

**Benefits:**
- Adds strategic flexibility
- Historical feature (governments did relocate)
- Prevents automatic game end
- Strategic depth

**Considerations:**
- Cost should be balanced for WON economy
- VP penalty should be appropriate
- Should prevent game-ending objective capture

### 4.3 Medium Priority: Realism Toggle

**Recommendation**: WON could benefit from Realism toggle options

**Implementation Approach:**
1. Add Realism toggle to Utility menu
2. Implement options:
   - City size affects recruitment (vs fixed)
   - Recruitment only in originally friendly/neutral cities
   - Isolated cities have reduced recruitment
   - Increased defender advantage
   - Other historical restrictions
3. Toggle affects multiple game systems

**Benefits:**
- Adds historical accuracy options
- Multiple gameplay effects
- Strategic depth
- User preference

**Considerations:**
- Must adapt CWS features to Napoleonic era
- Some features may not apply (railroad, ironclads)
- Should focus on applicable features

### 4.4 Low Priority: Additional Features

**Consider Adding:**
- January Campaigns toggle (seasonal restrictions)
- Check Links utility (map design tool)
- Graphics levels (performance options)
- More save slots (9 vs 8)

**Priority**: Low - Nice to have but not critical

---

## 5. Summary Tables

### 5.1 Feature Comparison Summary

| Category | WON Features | CWS Features | Shared Features | CWS Missing | WON Missing |
|---------|-------------|-------------|----------------|-------------|-------------|
| **Campaign** | 7 scenarios, 8 saves | 1 scenario, 9 saves | 2-month turns, 3-phase play | More scenarios | More save slots |
| **Armies** | 25 commanders, 400K combine | 20 commanders, 125K combine | Core attributes, Relieve | More commanders | Realism toggle |
| **Cities** | 67 cities, +100 VP capital | 40 cities, +50 VP capital, Move Capital | Fortification, raze | More cities | **Move Capital** |
| **Naval** | Generic ships | **Ironclads** | Core mechanics | - | **Ironclads** |
| **Economic** | Harvest months | Harvest months | **IDENTICAL** | - | - |
| **Combat** | **Tactical integration**, TCR=30 | TCR=20, Small penalty | Strategic combat | **TACTICAL** | Small penalty |
| **Reports** | History/Recap | History/Recap, creates files | **IDENTICAL** | - | File creation |
| **Options** | Tactical, Random Events, History | **Realism, January, Check Links, Graphics** | Core options | Tactical | **Realism, January, Check Links** |
| **Special** | Cohesion | **Railroad, Move Capital** | - | Cohesion | **Railroad, Move Capital** |

### 5.2 Priority Recommendations

| Priority | Feature | Impact | Effort | Recommendation |
|----------|---------|--------|--------|----------------|
| **HIGH** | Tactical Integration (for CWS) | Very High | High | CWS should implement |
| **MEDIUM** | Move Capital (for WON) | Medium | Low | WON should add |
| **MEDIUM** | Realism Toggle (for WON) | Medium | Medium | WON should add |
| **LOW** | January Campaigns (for WON) | Low | Low | WON could add |
| **LOW** | Check Links (for WON) | Low | Low | WON could add |
| **LOW** | Graphics Levels (for WON) | Low | Low | WON could add |

---

## 6. Conclusion

**Key Findings:**

1. **CWS lacks tactical battle integration** - This is the most significant gap compared to WON
2. **CWS has unique features** - Railroad, Move Capital, Realism toggle, Ironclads (not all applicable to WON)
3. **WON has unique features** - Tactical integration, Cohesion system, More scenarios/cities/commanders
4. **Both share many features** - Random Events, History/Recap, Relieve, Raze fortifications, Harvest months
5. **CWS has more utility options** - Realism toggle, January Campaigns, Check Links, Graphics levels

**Primary Recommendation for CWS:**

Implement tactical battle integration to match WON's feature set.

**Primary Recommendations for WON:**

1. **Move Capital feature** - Adds strategic flexibility and prevents automatic game end
2. **Realism toggle** - Adds historical accuracy options and gameplay depth
3. **January Campaigns toggle** - Adds seasonal restrictions (winter campaigns)

**Features Not Applicable to WON:**

- **Railroad system** - Not historically appropriate for Napoleonic era
- **Ironclads** - Post-Napoleonic technology

**CWS Strengths to Consider:**

- Realism toggle (comprehensive gameplay modifier)
- Move Capital (strategic flexibility)
- January Campaigns (seasonal restrictions)
- Check Links utility (map design tool)
- Graphics levels (performance options)

---

## 7. References

### Source Files

- **CWS Documentation**: `c:\code\hutsell\civil-war-strategy\CWS.DOC`
- **WON Documentation**: `c:\code\hutsell\wars-of-napoleon\WON.DOC`
- **CWS Source**: `c:\code\hutsell\civil-war-strategy\CWSTRAT.BAS`
- **WON Source**: `c:\code\hutsell\wars-of-napoleon\NAPOLEON.BAS` (tactical module)

### Key Documentation Sections

- **CWS Strategic Features**: `CWS.DOC` sections 2-7
- **CWS Special Features**: `CWS.DOC` sections 3.7 (Railroad), 5.6 (Move Capital), 6.13 (Realism)
- **WON Strategic Features**: `WON.DOC` sections 2-6
- **WON Tactical Integration**: `WON.DOC` sections 1.4, 5.5

---

*Document created based on comprehensive analysis of CWS.DOC and WON.DOC documentation.*

