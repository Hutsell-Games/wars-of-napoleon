# Wars of Napoleon - Architecture Documentation

**Date:** 2024  
**Scope:** System architecture, module structure, and data flow diagrams  
**Language:** QB64/QBASIC

---

## 🏗️ Architecture Diagrams

### System Architecture Overview

The Wars of Napoleon game uses a unified architecture with three main layers: Common, Strategic, and Tactical. The game flow moves from strategic decision-making through tactical battles and back to strategic updates.

```mermaid
graph TB
    subgraph "Entry Point"
        MAIN[main.bas<br/>Main Entry Point]
    end
    
    subgraph "Common Layer"
        DECL[declarations.bas<br/>Global Types & Constants]
        TYPES[battle_types.bas<br/>game_types.bas<br/>Data Structures]
        CONFIG[config.bas<br/>Configuration]
        UTILS[utilities.bas<br/>Helper Functions]
        ERR[error_handling.bas<br/>Error Management]
    end
    
    subgraph "Strategic Layer"
        CAMPAIGN[campaign.bas<br/>Game Loop & Phases]
        ARMY[army.bas<br/>Army Management]
        CITY[city.bas<br/>City Control]
        NAVAL[naval.bas<br/>Naval Operations]
        ECONOMY[economy.bas<br/>Economic System]
        VICTORY[victory.bas<br/>Victory Conditions]
        REPORTS[reports.bas<br/>Reports System]
        COHESION[cohesion.bas<br/>Cohesion System]
        TACT_INT[tactical_integration.bas<br/>Strategic-Tactical Bridge]
        COMBAT[combat.bas<br/>Strategic Combat]
    end
    
    subgraph "Tactical Layer"
        BATTLE[battle.bas<br/>Tactical Battle Entry]
        CORE[core.bas<br/>Battle Mechanics]
        UNITS[units.bas<br/>Unit Management]
        TERRAIN[terrain.bas<br/>Terrain System]
        AI[ai.bas<br/>AI Opponent]
        UI_TACT[ui.bas<br/>Tactical UI]
    end
    
    subgraph "UI Layer"
        MENUS[menus.bas<br/>Menu System]
        GRAPHICS[graphics.bas<br/>Graphics Rendering]
        MOUSE[mouse.bas<br/>Mouse Support]
    end
    
    MAIN --> DECL
    MAIN --> CAMPAIGN
    MAIN --> MENUS
    
    CAMPAIGN --> ARMY
    CAMPAIGN --> CITY
    CAMPAIGN --> NAVAL
    CAMPAIGN --> ECONOMY
    CAMPAIGN --> TACT_INT
    
    TACT_INT --> BATTLE
    BATTLE --> CORE
    BATTLE --> UNITS
    BATTLE --> TERRAIN
    BATTLE --> AI
    BATTLE --> UI_TACT
    
    ARMY --> TYPES
    CITY --> TYPES
    BATTLE --> TYPES
    
    CAMPAIGN --> CONFIG
    CAMPAIGN --> UTILS
    CAMPAIGN --> ERR
    
    style MAIN fill:#ff6b6b
    style TACT_INT fill:#4ecdc4
    style BATTLE fill:#4ecdc4
```

### Data Flow: Strategic to Tactical Integration

This diagram shows how data flows when a tactical battle is triggered from strategic combat.

```mermaid
sequenceDiagram
    participant CAMPAIGN as Campaign Loop
    participant MOVE as Movement System
    participant COMBAT as Strategic Combat
    participant TACT_INT as Tactical Integration
    participant TACTICAL as Tactical Battle
    participant STRATEGIC as Strategic Update
    
    CAMPAIGN->>MOVE: Execute Movement Orders
    MOVE->>COMBAT: Army Moves to Enemy City
    COMBAT->>TACT_INT: ResolveCombat()
    
    Note over TACT_INT: Check Force Ratio<br/>(1:3 to 3:1)
    Note over TACT_INT: Check Tactical Enabled
    
    TACT_INT->>TACT_INT: Prepare BattleData
    Note over TACT_INT: Convert Strategic → Tactical<br/>- size (men) → vp (hundreds)<br/>- Apply supply penalties<br/>- Extract commander ratings
    
    TACT_INT->>TACTICAL: LaunchTacticalBattle(BattleData)
    
    Note over TACTICAL: Initialize Battle Map<br/>Place Units<br/>Run Battle Loop
    
    TACTICAL->>TACTICAL: Calculate Casualties
    TACTICAL->>TACT_INT: Return BattleResult
    
    Note over TACT_INT: Convert Tactical → Strategic<br/>- casualties (hundreds) → men<br/>- Update army sizes<br/>- Transfer city control
    
    TACT_INT->>STRATEGIC: ProcessTacticalResults()
    STRATEGIC->>STRATEGIC: Update Army Strengths
    STRATEGIC->>STRATEGIC: Capture City (if attacker wins)
    STRATEGIC->>STRATEGIC: Process Retreat (if defender wins)
    STRATEGIC->>CAMPAIGN: Return to Campaign Loop
```

### Module Dependency Graph

This diagram shows the dependency relationships between modules, indicating which modules depend on others.

```mermaid
graph LR
    subgraph "Core Dependencies"
        DECL[declarations.bas]
        TYPES[battle_types.bas<br/>game_types.bas]
    end
    
    subgraph "Strategic Modules"
        CAMPAIGN[campaign.bas]
        ARMY[army.bas]
        CITY[city.bas]
        NAVAL[naval.bas]
        ECONOMY[economy.bas]
        VICTORY[victory.bas]
        REPORTS[reports.bas]
        COHESION[cohesion.bas]
        TACT_INT[tactical_integration.bas]
        COMBAT[combat.bas]
    end
    
    subgraph "Tactical Modules"
        BATTLE[battle.bas]
        CORE[core.bas]
        UNITS[units.bas]
        TERRAIN[terrain.bas]
        AI[ai.bas]
    end
    
    subgraph "Support Modules"
        CONFIG[config.bas]
        UTILS[utilities.bas]
        ERR[error_handling.bas]
        MENUS[menus.bas]
        GRAPHICS[graphics.bas]
        MOUSE[mouse.bas]
    end
    
    DECL --> CAMPAIGN
    DECL --> ARMY
    DECL --> CITY
    DECL --> BATTLE
    
    TYPES --> TACT_INT
    TYPES --> BATTLE
    TYPES --> ARMY
    
    CAMPAIGN --> ARMY
    CAMPAIGN --> CITY
    CAMPAIGN --> NAVAL
    CAMPAIGN --> ECONOMY
    CAMPAIGN --> TACT_INT
    
    TACT_INT --> BATTLE
    TACT_INT --> ARMY
    TACT_INT --> CITY
    TACT_INT --> COHESION
    
    BATTLE --> CORE
    BATTLE --> UNITS
    BATTLE --> TERRAIN
    BATTLE --> AI
    
    ARMY --> COHESION
    COMBAT --> ARMY
    COMBAT --> CITY
    
    CAMPAIGN --> CONFIG
    CAMPAIGN --> UTILS
    CAMPAIGN --> ERR
    CAMPAIGN --> MENUS
    
    MENUS --> GRAPHICS
    BATTLE --> GRAPHICS
    MENUS --> MOUSE
    
    style DECL fill:#ffd93d
    style TYPES fill:#ffd93d
    style TACT_INT fill:#6bcf7f
    style BATTLE fill:#6bcf7f
```

### Game Loop Flow

This diagram shows the main game loop and how phases transition.

```mermaid
stateDiagram-v2
    [*] --> Initialize: Start Game
    Initialize --> MainMenu: Load Config & Data
    
    MainMenu --> NewGame: New Game
    MainMenu --> LoadGame: Load Game
    MainMenu --> PBMGame: Continue PBM
    MainMenu --> Utility: Utility Menu
    MainMenu --> [*]: Quit
    
    NewGame --> SelectScenario
    LoadGame --> GameLoop
    PBMGame --> GameLoop
    SelectScenario --> GameLoop
    
    state GameLoop {
        [*] --> DecisionPhase
        DecisionPhase --> DecisionPhase: Player Actions
        DecisionPhase --> MoveCombatPhase: End Turn
        
        MoveCombatPhase --> ExecuteMovements
        ExecuteMovements --> ResolveCombats
        ResolveCombats --> CheckTacticalBattle
        
        CheckTacticalBattle --> TacticalBattle: Force Ratio 1:3-3:1
        CheckTacticalBattle --> StrategicCombat: Other Cases
        TacticalBattle --> ProcessResults
        StrategicCombat --> ProcessResults
        
        ProcessResults --> UpdatePhase
        UpdatePhase --> CheckEndGame
        
        CheckEndGame --> EndGame: Condition Met
        CheckEndGame --> AdvanceTurn: Continue
        AdvanceTurn --> DecisionPhase: Next Turn
    }
    
    state DecisionPhase {
        [*] --> ShowMenu
        ShowMenu --> Recruit: Recruit Army
        ShowMenu --> MoveOrders: Move Orders
        ShowMenu --> NavalOps: Naval Operations
        ShowMenu --> Commands: Commands
        ShowMenu --> Reports: Reports
        ShowMenu --> [*]: End Turn
    }
    
    state TacticalBattle {
        [*] --> InitializeBattle
        InitializeBattle --> BattleLoop
        BattleLoop --> PlayerTurn: Player Phase
        BattleLoop --> AITurn: AI Phase
        PlayerTurn --> CheckVictory
        AITurn --> CheckVictory
        CheckVictory --> [*]: Battle Complete
        CheckVictory --> BattleLoop: Continue
    }
    
    EndGame --> MainMenu
    Utility --> MainMenu
```

### Unit Conversion Flow

This diagram illustrates the critical unit conversions between strategic (men) and tactical (hundreds) layers.

```mermaid
graph TB
    subgraph "Strategic Layer (Men)"
        S1[Army Size: 5000 men]
        S2[Army Size: 3000 men]
        S3[Supply Check: Out of Supply]
    end
    
    subgraph "Conversion Layer"
        C1[Divide by 100<br/>5000 → 50 hundreds]
        C2[Divide by 100<br/>3000 → 30 hundreds]
        C3[Apply 50% Penalty<br/>50 → 25 hundreds]
    end
    
    subgraph "Tactical Layer (Hundreds)"
        T1[VP1: 25 hundreds]
        T2[VP2: 30 hundreds]
        T3[Battle Calculation]
        T4[Casualties: 15 hundreds]
        T5[Casualties: 20 hundreds]
    end
    
    subgraph "Conversion Back"
        C4[Multiply by 100<br/>15 → 1500 men]
        C5[Multiply by 100<br/>20 → 2000 men]
    end
    
    subgraph "Strategic Update (Men)"
        S4[Army 1: 5000 - 1500 = 3500 men]
        S5[Army 2: 3000 - 2000 = 1000 men]
    end
    
    S1 --> C1
    S2 --> C2
    S3 --> C3
    C1 --> C3
    C3 --> T1
    C2 --> T2
    T1 --> T3
    T2 --> T3
    T3 --> T4
    T3 --> T5
    T4 --> C4
    T5 --> C5
    C4 --> S4
    C5 --> S5
    
    style S1 fill:#ff6b6b
    style S2 fill:#ff6b6b
    style T1 fill:#4ecdc4
    style T2 fill:#4ecdc4
    style C3 fill:#ffe66d
    style C4 fill:#ffe66d
    style C5 fill:#ffe66d
```

### Key Architecture Notes

1. **Unified Architecture**: Unlike the original dual-executable design, the modern version uses direct function calls between strategic and tactical layers, eliminating file I/O overhead.

2. **Data Transformation**: The `tactical_integration.bas` module serves as the critical bridge, converting:
   - Strategic army sizes (men) ↔ Tactical VP (hundreds)
   - Strategic supply status → Tactical effectiveness penalties
   - Tactical battle results → Strategic army updates

3. **Module Organization**:
   - **Common**: Shared types, constants, and utilities
   - **Strategic**: Campaign management, army/city control, economy
   - **Tactical**: Battle mechanics, unit management, terrain
   - **UI**: Menus, graphics, mouse support

4. **Game Phases**:
   - **Decision Phase**: Player makes strategic decisions
   - **Move & Combat Phase**: Executes orders, resolves battles
   - **Update Phase**: Income, supply, turn advancement

5. **Battle Trigger Logic**:
   - Tactical battles trigger when force ratio is between 1:3 and 3:1
   - Requires tactical battles to be enabled in configuration
   - Falls back to strategic combat resolution otherwise

---

## Related Documentation

- **Code Analysis**: See `CODE_ANALYSIS.md` for code quality metrics and recommendations
- **Full Recreation Plan**: See `docs/FULL_RECREATION_PLAN.md` for implementation details
- **Strategic-Tactical Integration**: See `docs/STRATEGIC_TACTICAL_INTEGRATION.md` for detailed integration documentation

