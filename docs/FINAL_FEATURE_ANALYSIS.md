# Final Feature Analysis: CWS vs WW2 for WON Implementation

## Executive Summary

This document analyzes features from **Civil War Strategy (CWS)** and **World War 2 (WW2)** to determine which implementation would be best for enhancing **Wars of Napoleon (WON)**. For each feature category, we compare the CWS and WW2 implementations and recommend the best approach for WON.

**Key Finding**: CWS provides more applicable features for WON's Napoleonic era setting, while WW2's features are largely modern warfare elements not suitable for the Napoleonic period.

---

## 1. Feature-by-Feature Analysis

### 1.1 Move Capital Feature

**CWS Implementation:**
- Move capital to different city
- Cost: 500 money units
- Awards enemy 50 victory points
- Prevents capital capture ending game
- Strategic retreat option
- Accessed via Commands menu

**WW2 Implementation:**
- Not available

**Analysis:**
- CWS has this feature, WW2 does not
- Historically appropriate for Napoleonic era (governments did relocate)
- Adds strategic depth and prevents automatic game end

**Recommendation**: **Implement CWS version**
- CWS provides complete implementation
- WW2 has no equivalent
- Feature is historically appropriate
- Adds strategic flexibility

---

### 1.2 Realism Toggle / Historical Accuracy Options

**CWS Implementation:**
- Comprehensive Realism toggle affecting:
  - Recruitment: City size affects recruit numbers
  - Recruitment Location: Only in originally friendly/neutral cities
  - Isolated Cities: Reduced recruitment (1/3 normal)
  - Railroad Capacity: Variable based on cities held
  - Invasions: Union only (vs both sides)
  - Defender Advantage: Increased combat bonus
  - Ironclad Timing: Cannot build before 1862
- Single toggle affects multiple systems
- Accessed via Utility menu

**WW2 Implementation:**
- No comprehensive realism toggle
- Individual options (Neutrals, Weather) but not unified
- No recruitment restrictions
- No invasion restrictions

**Analysis:**
- CWS has comprehensive realism system
- WW2 has individual options but not unified
- CWS approach is more elegant (single toggle)
- More applicable to WON (historical accuracy)

**Recommendation**: **Implement CWS version (adapted)**
- CWS provides unified realism system
- WW2 has fragmented options
- Adapt CWS features to Napoleonic era:
  - City size affects recruitment ✓
  - Recruitment only in originally friendly/neutral ✓
  - Isolated cities reduced recruitment ✓
  - Increased defender advantage ✓
  - Skip railroad/ironclad features (not applicable)

---

### 1.3 Seasonal Campaign Restrictions

**CWS Implementation:**
- January Campaigns toggle
- When OFF: No land campaigns in January
- Can move to friendly cities, fortify, naval OK
- Historical: Winter campaigns were difficult
- Toggle on/off in Utility menu

**WW2 Implementation:**
- Weather system with 4 conditions:
  - Clear: No effect
  - Blizzard: Infantry (exp<8) and Artillery (move tech<2) can't move, +1 supply use
  - Flood: Units need move tech≥2 or high leadership/experience
  - Storm: Prohibits naval/air unless highest tech level, 3× invasion losses
- Weather affects movement, supply, naval/air operations
- More complex system

**Analysis:**
- CWS: Simple seasonal restriction (January)
- WW2: Complex weather system affecting multiple systems
- CWS simpler and more appropriate for Napoleonic era
- WW2 weather system too complex and modern

**Recommendation**: **Implement CWS version (adapted)**
- CWS provides simpler seasonal restriction
- WW2 weather system too complex for Napoleonic era
- Adapt CWS to WON:
  - Winter months (January, February) restrict campaigns
  - Can move to friendly, fortify, naval OK
  - Historical accuracy for Napoleonic campaigns

---

### 1.4 Map Design Utilities

**CWS Implementation:**
- Check Links utility
- Identifies missing return route links
- Can correct links for current game
- Useful for custom map design
- Accessed via Utility menu

**WW2 Implementation:**
- Scenario Editor access from main menu
- Create/edit custom scenarios
- Modify starting conditions
- Customize game parameters

**Analysis:**
- CWS: Utility to check map connectivity
- WW2: Full scenario editor
- Both useful but different purposes
- CWS utility is simpler and more focused
- WW2 editor is more comprehensive

**Recommendation**: **Implement WW2 version (preferred) OR CWS version**
- **WW2 Scenario Editor** - More comprehensive, allows full scenario creation
- **CWS Check Links** - Simpler utility, useful for map validation
- **Best**: Implement WW2 Scenario Editor (more powerful)
- **Alternative**: Implement CWS Check Links (simpler, focused)

---

### 1.5 Graphics and Display Options

**CWS Implementation:**
- Four graphics levels: G0-G3
  - G0: No additional graphics (BASIC)
  - G1: Show city connections
  - G2: Show city connections and city names
  - G3: Show connections, names, and combat graphics
- Higher levels slow game slightly
- Toggle in Utility menu

**WW2 Implementation:**
- Display speed setting (fast to very slow)
- Graphics toggle (on/off)
- No multiple graphics levels
- Simpler system

**Analysis:**
- CWS: Multiple graphics levels (4 levels)
- WW2: Simple graphics toggle + display speed
- CWS provides more granular control
- WW2 simpler but less flexible

**Recommendation**: **Implement CWS version**
- CWS provides more granular graphics control
- WW2 has simpler system
- CWS approach allows user preference for performance vs visuals
- Better user experience

---

### 1.6 User Interface Enhancements

**CWS Implementation:**
- Keyboard-only interface
- Hot keys: F1=Help, F3=Redraw, F7=End Turn
- Menu-based navigation

**WW2 Implementation:**
- **Mouse support** - Full mouse control
- Keyboard support
- Click to move armies
- Right mouse button = Escape
- Convenient for movement and selection

**Analysis:**
- CWS: Keyboard-only
- WW2: Mouse + keyboard
- WW2 provides better UI
- Mouse support is modern convenience

**Recommendation**: **Implement WW2 version**
- WW2 has mouse support, CWS does not
- Mouse support improves user experience
- Modern interface feature
- Better accessibility

---

### 1.7 Play-by-Mail (PBM) Support

**CWS Implementation:**
- Not available

**WW2 Implementation:**
- Automated file exchange system
- `PBM` file created after each turn
- Supports email or disk exchange
- Automated turn sequence
- Score screen at game end
- Full PBM workflow

**Analysis:**
- CWS: No PBM support
- WW2: Full PBM system
- WW2 provides remote multiplayer capability
- Useful for long-distance play

**Recommendation**: **Implement WW2 version**
- WW2 has complete PBM system
- CWS has no equivalent
- Enables remote multiplayer
- Modern convenience feature

---

### 1.8 Neutral City Handling

**CWS Implementation:**
- Neutral cities automatically captured
- No cost or penalty
- Simple system

**WW2 Implementation:**
- Neutrals option toggle
- When ON: 10 VP cost to enter neutral cities
- Only applies to cities neutral at scenario start
- Special case: Minsk activates Russia
- Toggle on/off in Utility menu

**Analysis:**
- CWS: Simple automatic capture
- WW2: Optional VP cost system
- WW2 provides strategic cost to expansion
- More historical (respecting neutrality)

**Recommendation**: **Implement WW2 version**
- WW2 provides optional neutral penalty system
- CWS has simple automatic capture
- WW2 approach adds strategic depth
- More historically accurate
- Optional (can be toggled off)

---

### 1.9 End Game Conditions

**CWS Implementation:**
- 5 end game conditions:
  - Time (Month & Year)
  - % Cities Controlled
  - % Income
  - Capital Capture
  - Total Force Strength Ratio
- End Game Override: Increases threshold
- Victory Condition Override: Increases threshold

**WW2 Implementation:**
- 3 end game conditions:
  - Time (Month & Year)
  - % Cities Controlled
  - Capital Capture
- End Game Override: Increases threshold
- End Game Bonuses: 10% VP bonus + annihilation bonus + early end bonus

**Analysis:**
- CWS: 5 conditions (more comprehensive)
- WW2: 3 conditions (simpler)
- CWS has % Income and Strength Ratio conditions
- WW2 has end game bonuses system

**Recommendation**: **Implement CWS version (with WW2 bonuses)**
- CWS has more end game conditions (better)
- WW2 has end game bonuses system (good addition)
- **Best**: Combine both:
  - Use CWS's 5 conditions
  - Add WW2's end game bonuses system
  - Provides comprehensive end game system

---

### 1.10 Combat Model Customization

**CWS Implementation:**
- Combat factors adjustable in `CWS.INI`:
  - ATKFAC: Base attacker casualty rate (default 11%)
  - DEFAC: Base defender casualty rate (default 9%)
  - TCR: Total combat range (default 20)
- User customizable
- File-based configuration

**WW2 Implementation:**
- Combat factors in `WW2BASE.INI`:
  - Similar system
  - TCR adjustable (default 99, higher than CWS)
- User customizable
- File-based configuration

**Analysis:**
- Both have similar combat customization
- CWS: TCR=20 (lower, more luck)
- WW2: TCR=99 (higher, more deterministic)
- Both allow user customization
- WON uses TCR=30 (between the two)

**Recommendation**: **Keep WON's current system**
- WON already has combat customization
- TCR=30 is reasonable middle ground
- Both CWS and WW2 have similar systems
- No need to change

---

### 1.11 Reports and Information

**CWS Implementation:**
- 7 reports (same as WON):
  - Friendly Army, Enemy Army, City, Force Summary, Intelligence, Battle Summary, Recap/History
- History creates files: `CWS.HIS` and `BATTSUMM`
- Same reports as WON

**WW2 Implementation:**
- 6 reports:
  - Friendly Army, Enemy Army, City, Force Summary, Intelligence, Battle Summary
- No Recap/History report
- No file creation

**Analysis:**
- CWS: 7 reports (includes History/Recap)
- WW2: 6 reports (no History/Recap)
- CWS matches WON's reporting
- CWS creates history files

**Recommendation**: **Keep WON's current system (matches CWS)**
- WON already has 7 reports including History/Recap
- CWS matches WON's system
- WW2 lacks History/Recap report
- WON system is best

---

### 1.12 Random Events System

**CWS Implementation:**
- Random Events toggle
- Options: Favor Union, Neutral, Favor Rebels
- Historical events (Emancipation Proclamation, Lincoln re-election)
- Toggle on/off in Utility menu

**WW2 Implementation:**
- Special Events file (`SPECIAL.EVT`)
- Historical events (Bismarck sunk, Battle of the Bulge)
- Events affect victory points or game state
- File-based configuration

**Analysis:**
- CWS: Toggle with favor options
- WW2: File-based events system
- Both have historical events
- CWS has toggle for favor, WW2 has file-based system

**Recommendation**: **Keep WON's current system (matches CWS)**
- WON already has Random Events with favor options (matches CWS)
- WW2 has file-based system (more flexible but more complex)
- WON/CWS approach is simpler and adequate

---

### 1.13 Naval Operations

**CWS Implementation:**
- Two ship types: Wooden (100) and Ironclads (200)
- Ironclads: 10% more effective, 20 hits vs 10 hits
- Fleet composition shown
- Realism toggle prevents ironclads before 1862
- Port attack restriction (cannot move and attack same turn)

**WW2 Implementation:**
- Generic ships (no types)
- Ship costs variable (affected by Production tech)
- Naval combat similar to CWS
- No ship type differentiation

**Analysis:**
- CWS: Ship type system (ironclads vs wooden)
- WW2: Generic ships
- CWS ironclads not applicable to Napoleonic era
- WW2 generic ships more appropriate

**Recommendation**: **Keep WON's current system (generic ships)**
- WON already has generic ships (appropriate for era)
- CWS ironclads are post-Napoleonic
- WW2 generic ships match WON
- No need to change

---

### 1.14 Unit Type System

**CWS Implementation:**
- Generic armies (no unit types)
- All armies treated the same

**WW2 Implementation:**
- Unit type system: Infantry, Armor, Elite, Artillery, Static
- Different movement speeds, combat capabilities
- Type affects combine restrictions
- Type affects combat bonuses
- Elite units exempt from supply penalty

**Analysis:**
- CWS: Generic armies
- WW2: Unit type system
- WW2 system not appropriate for Napoleonic era (Armor, etc.)
- CWS generic approach matches WON

**Recommendation**: **Keep WON's current system (generic armies)**
- WON already has generic armies (appropriate for era)
- WW2 unit types are modern warfare (not applicable)
- CWS generic approach matches WON
- No need to change

---

### 1.15 Technology System

**CWS Implementation:**
- No technology system
- Fixed unit costs
- No research/advancement

**WW2 Implementation:**
- 8 technology categories:
  - Land Attack, Land Defense, Land Move
  - Navy Attack, Navy Defend, Seaborne (Amphibious/Invasion)
  - Air Attack, Production
- Levels: 0 (Standard) to 3 (Ultramodern)
- Costs: 200 credits (500 for Production)
- Technology Success Factor (TSF) controls success
- Affects combat, movement, unit costs, capabilities

**Analysis:**
- CWS: No technology system
- WW2: Comprehensive technology system
- WW2 system represents WWII technological advancement
- Not applicable to Napoleonic era (relatively static technology)

**Recommendation**: **Keep WON's current system (no technology)**
- WON has no technology system (appropriate for era)
- WW2 technology system is modern warfare
- CWS no technology matches WON
- No need to change

---

### 1.16 Air Force System

**CWS Implementation:**
- Not available

**WW2 Implementation:**
- Up to 10 planes per side
- Air base location system
- Range-based operations
- Bombing missions (cities, armies, navies)
- Dogfights when bombing enemy air bases
- Paratroop capacity based on air force size and technology
- Technology affects plane capabilities
- Cost: 70 credits per plane

**Analysis:**
- CWS: No air force
- WW2: Complete air force system
- WW2 air force is modern warfare
- Not applicable to Napoleonic era (no aircraft)

**Recommendation**: **Not applicable - Do not implement**
- Air force is modern warfare feature
- Not historically appropriate for Napoleonic era
- Neither CWS nor WON have this (correctly)

---

### 1.17 Supply System

**CWS Implementation:**
- Auto supply: 0.002 money per 1,000 men
- Manual supply: 0.001 money per 1,000 men
- Free supply in July, September (harvest months)
- Supply order: Numerical order
- Out of supply = 50% effectiveness

**WW2 Implementation:**
- Similar supply system
- Auto supply costs
- Manual supply costs
- No documented harvest months
- Supply order: Similar
- Out of supply = 50% effectiveness (except Elite units)

**Analysis:**
- CWS: Has harvest months (July, September)
- WW2: No documented harvest months
- Both have similar supply costs
- CWS harvest months add historical accuracy

**Recommendation**: **Keep WON's current system (matches CWS)**
- WON already has harvest months (matches CWS)
- CWS matches WON's supply system
- WW2 lacks harvest months
- WON/CWS system is best

---

### 1.18 Save Game System

**CWS Implementation:**
- 9 save slots (`CWS1.SAV` - `CWS9.SAV`)
- No documented autosave

**WW2 Implementation:**
- 5 save slots (`WWII1.SAV` - `WWII5.SAV`)
- Autosave: `WWII5.SAV` (if enabled)
- Autosave at end of update phase

**WON Current:**
- 8 save slots (`NWS1.SAV` - `NWS8.SAV`)
- Autosave: `NWS9.SAV` (end of decision phase)

**Analysis:**
- CWS: 9 slots, no autosave
- WW2: 5 slots, autosave
- WON: 8 slots, autosave
- WON has best system (more slots + autosave)

**Recommendation**: **Keep WON's current system**
- WON has more slots than WW2
- WON has autosave (CWS does not)
- WON system is best

---

## 2. Summary Recommendations

### 2.1 Features to Implement from CWS

| Feature | Priority | Reason |
|---------|----------|--------|
| **Move Capital** | HIGH | Strategic flexibility, prevents auto game end |
| **Realism Toggle** | MEDIUM | Historical accuracy options, gameplay depth |
| **January Campaigns Toggle** | LOW | Seasonal restrictions, historical accuracy |
| **Check Links Utility** | LOW | Map design tool, useful utility |
| **Graphics Levels** | LOW | Performance options, user preference |

### 2.2 Features to Implement from WW2

| Feature | Priority | Reason |
|---------|----------|--------|
| **Mouse Support** | HIGH | Better UI, modern convenience |
| **PBM Support** | MEDIUM | Remote multiplayer capability |
| **Neutrals Option** | MEDIUM | Strategic depth, historical accuracy |
| **Scenario Editor** | MEDIUM | User content creation, extended replayability |
| **End Game Bonuses** | LOW | Adds to end game system |

### 2.3 Features NOT to Implement

| Feature | Source | Reason |
|---------|--------|--------|
| **Railroad System** | CWS | Not historically appropriate (post-Napoleonic) |
| **Ironclads** | CWS | Not historically appropriate (post-Napoleonic) |
| **Air Force** | WW2 | Not historically appropriate (modern warfare) |
| **Technology System** | WW2 | Not historically appropriate (modern warfare) |
| **Unit Types** | WW2 | Not historically appropriate (modern warfare) |

---

## 3. Implementation Priority Matrix

### 3.1 High Priority Features

**1. Move Capital (CWS)**
- **Source**: CWS
- **Effort**: Low
- **Impact**: High
- **Historical**: Yes
- **Recommendation**: Implement CWS version

**2. Mouse Support (WW2)**
- **Source**: WW2
- **Effort**: Medium
- **Impact**: High
- **Historical**: N/A (UI feature)
- **Recommendation**: Implement WW2 version

### 3.2 Medium Priority Features

**3. Realism Toggle (CWS)**
- **Source**: CWS
- **Effort**: Medium
- **Impact**: Medium
- **Historical**: Yes
- **Recommendation**: Implement CWS version (adapted)

**4. PBM Support (WW2)**
- **Source**: WW2
- **Effort**: Medium
- **Impact**: Medium
- **Historical**: N/A (convenience feature)
- **Recommendation**: Implement WW2 version

**5. Neutrals Option (WW2)**
- **Source**: WW2
- **Effort**: Low
- **Impact**: Medium
- **Historical**: Yes
- **Recommendation**: Implement WW2 version

**6. Scenario Editor (WW2)**
- **Source**: WW2
- **Effort**: High
- **Impact**: Medium
- **Historical**: N/A (utility feature)
- **Recommendation**: Implement WW2 version

### 3.3 Low Priority Features

**7. January Campaigns Toggle (CWS)**
- **Source**: CWS
- **Effort**: Low
- **Impact**: Low
- **Historical**: Yes
- **Recommendation**: Implement CWS version (adapted)

**8. Check Links Utility (CWS)**
- **Source**: CWS
- **Effort**: Low
- **Impact**: Low
- **Historical**: N/A (utility feature)
- **Recommendation**: Implement CWS version

**9. Graphics Levels (CWS)**
- **Source**: CWS
- **Effort**: Low
- **Impact**: Low
- **Historical**: N/A (UI feature)
- **Recommendation**: Implement CWS version

**10. End Game Bonuses (WW2)**
- **Source**: WW2
- **Effort**: Low
- **Impact**: Low
- **Historical**: N/A (gameplay feature)
- **Recommendation**: Add to WON's end game system

---

## 4. Feature Implementation Details

### 4.1 Move Capital (CWS)

**Implementation:**
1. Add "Move Capital" option to Commands menu
2. Cost: 500 money units (or appropriate for WON economy)
3. Awards enemy 50 victory points (or appropriate)
4. Prevents objective capture ending game
5. Only available if capital not yet captured
6. Menu shows candidate cities
7. Cannot be cancelled once selected

**Adaptation for WON:**
- Use "Move Objective" instead of "Move Capital"
- Cost should be balanced for WON economy
- VP penalty should be appropriate
- Prevents objective capture ending game

**Code Reference**: `CWS.DOC` section 5.6

### 4.2 Mouse Support (WW2)

**Implementation:**
1. Add mouse support to Utility menu
2. Enable mouse control for:
   - Menu selection (click menu items)
   - Map-based unit selection (click on cities/armies)
   - Movement (click origin, then destination)
   - Right mouse button = Escape key
3. Save mouse preference to configuration file
4. Keyboard still works when mouse enabled

**Adaptation for WON:**
- Direct port from WW2
- No historical considerations
- Pure UI enhancement

**Code Reference**: `WW2.DOC` section 1.9

### 4.3 Realism Toggle (CWS)

**Implementation:**
1. Add "Realism" toggle to Utility menu
2. When ON, affects:
   - **Recruitment**: City size affects recruit numbers (vs fixed)
   - **Recruitment Location**: Only in originally friendly/neutral cities
   - **Isolated Cities**: Reduced recruitment (1/3 normal)
   - **Defender Advantage**: Increased combat bonus
   - **Other historical restrictions** (adapt as appropriate)
3. Toggle affects multiple game systems
4. Save preference to configuration file

**Adaptation for WON:**
- Adapt CWS features to Napoleonic era:
  - City size affects recruitment ✓
  - Recruitment only in originally friendly/neutral ✓
  - Isolated cities reduced recruitment ✓
  - Increased defender advantage ✓
  - Skip railroad/ironclad features (not applicable)
- Focus on applicable features

**Code Reference**: `CWS.DOC` section 6.13

### 4.4 PBM Support (WW2)

**Implementation:**
1. Add "PBM" option to Utility menu
2. Create `PBM` file after each turn
3. File contains complete game state
4. Supports email or disk exchange
5. "Continue PBM Game" option in initial menu
6. Automated turn sequence
7. Score screen at game end

**Adaptation for WON:**
- Direct port from WW2
- No historical considerations
- Pure convenience feature

**Code Reference**: `WW2.DOC` section 1.13

### 4.5 Neutrals Option (WW2)

**Implementation:**
1. Add "Neutrals" toggle to Utility menu
2. When ON: 10 VP cost to enter neutral cities
3. Only applies to cities neutral at scenario start
4. Special cases can be added (like Minsk in WW2)
5. Toggle on/off in Utility menu
6. Save preference to configuration file

**Adaptation for WON:**
- Direct port from WW2
- VP cost should be appropriate for WON economy
- Can add special cases for specific neutral cities
- Optional feature (can be toggled off)

**Code Reference**: `WW2.DOC` section 6.11

### 4.6 Scenario Editor (WW2)

**Implementation:**
1. Add "Editor" option to Main menu
2. Launch separate editor program
3. Allow editing:
   - Starting conditions
   - City data
   - Commander data
   - End game conditions
   - Other scenario parameters
4. Save custom scenarios

**Adaptation for WON:**
- Direct port from WW2
- No historical considerations
- Pure utility feature
- Enables user content creation

**Code Reference**: `WW2.DOC` section 3.16

### 4.7 January Campaigns Toggle (CWS)

**Implementation:**
1. Add "January Campaigns" toggle to Utility menu
2. When OFF: No land campaigns in January
3. Can move to friendly cities, fortify, naval OK
4. When ON: Normal campaigns allowed
5. Toggle on/off in Utility menu
6. Save preference to configuration file

**Adaptation for WON:**
- Adapt to winter months (January, February)
- Historical: Winter campaigns were difficult
- Can move to friendly, fortify, naval OK
- Adds seasonal restrictions

**Code Reference**: `CWS.DOC` section 6.12

### 4.8 Check Links Utility (CWS)

**Implementation:**
1. Add "Check Links" option to Utility menu
2. Check map connectivity
3. Identify missing return route links
4. Can correct links for current game
5. Display results
6. Note: Does not fix data file (user must edit)

**Adaptation for WON:**
- Direct port from CWS
- No historical considerations
- Pure utility feature
- Useful for map design

**Code Reference**: `CWS.DOC` section 6.14

### 4.9 Graphics Levels (CWS)

**Implementation:**
1. Add "Graphics" option to Utility menu
2. Four levels: G0-G3
   - G0: No additional graphics (BASIC)
   - G1: Show city connections
   - G2: Show city connections and city names
   - G3: Show connections, names, and combat graphics
3. Higher levels slow game slightly
4. Save preference to configuration file

**Adaptation for WON:**
- Direct port from CWS
- No historical considerations
- Pure UI/performance feature
- Allows user preference

**Code Reference**: `CWS.DOC` section 6.4

### 4.10 End Game Bonuses (WW2)

**Implementation:**
1. Add bonus system to end game:
   - 10% VP bonus for triggering end condition
   - Additional 10% for annihilating enemy
   - 10 VP per month early (if ends before time limit)
2. Display bonuses on end game screen
3. Add to victory point calculation

**Adaptation for WON:**
- Add to WON's existing end game system
- Enhance current +100 VP bonus
- Add annihilation and early end bonuses
- Improves end game rewards

**Code Reference**: `WW2.DOC` section 6.8

---

## 5. Final Recommendations Summary

### 5.1 Implement from CWS

**High Priority:**
1. ✅ **Move Capital** - Strategic flexibility

**Medium Priority:**
2. ✅ **Realism Toggle** - Historical accuracy options

**Low Priority:**
3. ✅ **January Campaigns Toggle** - Seasonal restrictions
4. ✅ **Check Links Utility** - Map design tool
5. ✅ **Graphics Levels** - Performance options

### 5.2 Implement from WW2

**High Priority:**
1. ✅ **Mouse Support** - Better UI

**Medium Priority:**
2. ✅ **PBM Support** - Remote multiplayer
3. ✅ **Neutrals Option** - Strategic depth
4. ✅ **Scenario Editor** - User content creation

**Low Priority:**
5. ✅ **End Game Bonuses** - Enhance end game system

### 5.3 Do NOT Implement

**From CWS:**
- ❌ Railroad System (not historically appropriate)
- ❌ Ironclads (not historically appropriate)

**From WW2:**
- ❌ Air Force System (not historically appropriate)
- ❌ Technology System (not historically appropriate)
- ❌ Unit Type System (not historically appropriate)
- ❌ Weather System (too complex, not appropriate)

### 5.4 Keep WON's Current Features

**Already Best:**
- ✅ Tactical Integration (WON unique)
- ✅ Cohesion System (WON unique)
- ✅ Random Events (matches CWS)
- ✅ History/Recap Report (matches CWS)
- ✅ Harvest Months (matches CWS)
- ✅ Supply System (matches CWS)
- ✅ Save Game System (best of all three)
- ✅ End Game Conditions (matches CWS, better than WW2)

---

## 6. Implementation Roadmap

### Phase 1: High Priority Features

1. **Move Capital (CWS)**
   - Add to Commands menu
   - Implement cost and VP penalty
   - Test strategic impact

2. **Mouse Support (WW2)**
   - Add mouse interface
   - Implement click controls
   - Test usability

### Phase 2: Medium Priority Features

3. **Realism Toggle (CWS)**
   - Add toggle to Utility menu
   - Implement recruitment restrictions
   - Implement defender bonus
   - Test gameplay impact

4. **PBM Support (WW2)**
   - Add PBM option
   - Implement file creation
   - Test file exchange

5. **Neutrals Option (WW2)**
   - Add toggle to Utility menu
   - Implement VP cost system
   - Test strategic impact

6. **Scenario Editor (WW2)**
   - Create editor program
   - Implement editing capabilities
   - Test scenario creation

### Phase 3: Low Priority Features

7. **January Campaigns Toggle (CWS)**
   - Add toggle to Utility menu
   - Implement winter restrictions
   - Test gameplay impact

8. **Check Links Utility (CWS)**
   - Add to Utility menu
   - Implement link checking
   - Test utility

9. **Graphics Levels (CWS)**
   - Add to Utility menu
   - Implement 4 graphics levels
   - Test performance impact

10. **End Game Bonuses (WW2)**
    - Add to end game system
    - Implement bonus calculations
    - Test impact

---

## 7. Conclusion

**Key Findings:**

1. **CWS provides more applicable features** for WON's Napoleonic era setting
2. **WW2 provides modern UI features** (mouse, PBM) that enhance usability
3. **Both have features not applicable** to Napoleonic era (railroads, ironclads, air force, technology)
4. **WON already has many best features** (tactical integration, cohesion, random events, history)

**Primary Recommendations:**

**From CWS:**
- Move Capital (high priority)
- Realism Toggle (medium priority)
- January Campaigns, Check Links, Graphics Levels (low priority)

**From WW2:**
- Mouse Support (high priority)
- PBM Support, Neutrals Option, Scenario Editor (medium priority)
- End Game Bonuses (low priority)

**Best Implementation Strategy:**

1. **Start with CWS features** - More historically appropriate
2. **Add WW2 UI features** - Modern convenience
3. **Skip modern warfare features** - Not applicable to era
4. **Preserve WON's unique features** - Tactical integration, cohesion

**Final Priority Order:**

1. Move Capital (CWS) - Strategic flexibility
2. Mouse Support (WW2) - Better UI
3. Realism Toggle (CWS) - Historical accuracy
4. PBM Support (WW2) - Remote multiplayer
5. Neutrals Option (WW2) - Strategic depth
6. Scenario Editor (WW2) - User content
7. January Campaigns (CWS) - Seasonal restrictions
8. Check Links (CWS) - Map utility
9. Graphics Levels (CWS) - Performance options
10. End Game Bonuses (WW2) - Enhance end game

---

## 8. References

### Source Files

- **CWS Documentation**: `c:\code\hutsell\civil-war-strategy\CWS.DOC`
- **WW2 Documentation**: `c:\code\hutsell\world-war-2\WW2.DOC`
- **WON Documentation**: `c:\code\hutsell\wars-of-napoleon\WON.DOC`

### Comparison Documents

- **CWS vs WON**: `CWS_STRATEGIC_COMPARISON.md`
- **WW2 vs WON**: `WW2_STRATEGIC_COMPARISON.md`

---

*Document created based on comprehensive analysis of CWS.DOC, WW2.DOC, and WON.DOC documentation.*

