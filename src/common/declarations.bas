'============================================================================
' Global Declarations
'============================================================================
' Shared variable declarations and function prototypes
' Include this file first in main.bas

DEFINT A-Z

'============================================================================
' CONSTANTS - MUST BE DEFINED BEFORE ANY SUB/FUNCTION DECLARATIONS
'============================================================================

' Turn sequence phases (used in campaign.bas)
CONST PHASE_DECISION = 1
CONST PHASE_MOVE_COMBAT = 2
CONST PHASE_UPDATE = 3

' Array size constants
CONST MAX_ARMIES = 40
CONST MAX_CITIES = 60
CONST FRENCH_START = 1
CONST ALLIED_START = 21

' City type constants
CONST CITY_NEUTRAL = 0
CONST CITY_FRENCH = 1
CONST CITY_ALLIED = 2
CONST CITY_AT_PEACE = 3

' Fortification levels
CONST FORT_NONE = 0
CONST FORT_PLUS = 1
CONST FORT_PLUS_PLUS = 2

' Naval action constants
CONST NAVAL_BOMBARD = 1
CONST NAVAL_BLOCKADE = 2
CONST NAVAL_RAID = 3
CONST NAVAL_INVASION = 4

' Victory condition constants
CONST END_TIME = 1
CONST END_CITIES = 2
CONST END_INCOME = 3
CONST END_OBJECTIVE = 4
CONST END_ARMY_RATIO = 5

' Nationality constants
CONST NAT_FRENCH = 1
CONST NAT_AUSTRIAN = 2
CONST NAT_ENGLISH = 3
CONST NAT_RUSSIAN = 4
CONST NAT_PRUSSIAN = 5
CONST NAT_SPANISH = 6

' Supply cost constants
CONST SUPPLY_AUTO_COST = 0.002 ' Per 1,000 men
CONST SUPPLY_MANUAL_COST = 0.001 ' Per 1,000 men (cheaper)

' Report type constants
CONST REPORT_FRIENDLY_ARMY = 1
CONST REPORT_ENEMY_ARMY = 2
CONST REPORT_CITY = 3
CONST REPORT_FORCE_SUMMARY = 4
CONST REPORT_INTELLIGENCE = 5
CONST REPORT_BATTLE_SUMMARY = 6
CONST REPORT_RECAP = 7

' Main menu options
CONST MENU_NEW_GAME = 1
CONST MENU_LOAD_GAME = 2
CONST MENU_CONTINUE_PBM = 3
CONST MENU_UTILITY = 4
CONST MENU_QUIT = 5

'============================================================================
' SHARED VARIABLE DECLARATIONS
'============================================================================

' Shared arrays and variables from NAPOLEON.BAS (tactical module)
' These will be populated when tactical battle runs
DIM SHARED strength(1 TO 100) AS INTEGER
DIM SHARED unitx(1 TO 100) AS INTEGER
DIM SHARED unity(1 TO 100) AS INTEGER
DIM SHARED leader(1 TO 100) AS INTEGER
DIM SHARED xper(1 TO 100) AS INTEGER
DIM SHARED morale(1 TO 100) AS INTEGER
DIM SHARED uorder(1 TO 100) AS INTEGER
DIM SHARED Visible(1 TO 100) AS INTEGER
DIM SHARED terrain(1 TO 100) AS INTEGER
DIM SHARED name$(1 TO 100)
DIM SHARED unit$(1 TO 100)
DIM SHARED elan(1 TO 2) AS INTEGER
DIM SHARED bigg(1 TO 2) AS INTEGER
DIM SHARED m1 AS INTEGER
DIM SHARED m2 AS INTEGER
DIM SHARED most AS INTEGER
DIM SHARED obstruct AS INTEGER
DIM SHARED possess AS INTEGER
DIM SHARED objx AS INTEGER
DIM SHARED objy AS INTEGER
DIM SHARED sdtext$(1 TO 10)
DIM SHARED file$

' Shared variables from strategic game
DIM SHARED graphic(1 TO 1564) AS INTEGER ' Graphics array

' Function declarations for NAPOLEON.BAS subroutines
' These will be included when NAPOLEON.BAS is integrated
DECLARE SUB randmap ()
DECLARE SUB randarm (k%)
DECLARE SUB mainmap ()
DECLARE SUB SHOWUNIT (index%)
DECLARE SUB refresh ()
DECLARE SUB see (index%)
DECLARE SUB los (from%, to%, result%, flag%)
DECLARE SUB Compact (side%)
DECLARE SUB victory (index%)
DECLARE SUB wipeout (index%)
DECLARE SUB lowtime ()
DECLARE SUB ranger (index%, range%)
DECLARE SUB brittle (side%)
DECLARE SUB iconload ()
DECLARE SUB scrcol (which%)
DECLARE SUB Tara (x%, y%, flag%)
DECLARE SUB YouorMe (index%, F%)
DECLARE SUB inspect (index%)
DECLARE SUB snapshot (x%, y%, flag%)
DECLARE SUB touchup ()
' Note: LaunchTacticalBattle is declared in tactical_integration.bas after battle_types.bas is included

' Shared configuration variables
DIM SHARED mdsp AS INTEGER
DIM SHARED mdly!
DIM SHARED bold AS INTEGER
DIM SHARED seelimit AS INTEGER

' Shared game state variables
DIM SHARED scenario$
DIM SHARED currentPhase AS INTEGER

' Shared arrays for strategic game
DIM SHARED armies(1 TO 40) AS ArmyType
DIM SHARED cities(1 TO 60) AS CityType
DIM SHARED fleets(1 TO 2) AS FleetType
DIM SHARED occupied(1 TO 60) AS INTEGER
DIM SHARED cityMatrix(1 TO 60, 1 TO 7) AS INTEGER
DIM SHARED gameState AS GameStateType

' Commander storage (50 total: 25 French, 25 Allied)
DIM SHARED commanders(1 TO 50) AS CommanderType
DIM SHARED commanderIndex AS INTEGER ' Current commander assignment index

' Shared configuration
DIM SHARED config_side AS INTEGER
DIM SHARED config_sound AS INTEGER
DIM SHARED config_balance AS INTEGER
DIM SHARED config_aggression AS INTEGER
DIM SHARED config_players AS INTEGER
DIM SHARED config_display AS INTEGER
DIM SHARED config_randevent AS INTEGER
DIM SHARED config_history AS INTEGER
DIM SHARED config_tactical AS INTEGER

' Shared cohesion system
DIM SHARED alliedAtWar(1 TO 6) AS INTEGER

' Shared victory system
DIM SHARED endGameFlags(1 TO 5) AS INTEGER
DIM SHARED endGameTriggered AS INTEGER
DIM SHARED endGameWinner AS INTEGER ' Side that triggered end condition

' Shared reports
DIM SHARED battleWon(1 TO 2) AS INTEGER
DIM SHARED casualties(1 TO 2) AS LONG
DIM SHARED historyFile AS INTEGER ' History file handle

' Shared capitals
DIM SHARED capitalCity(1 TO 2) AS INTEGER

' Shared realism
DIM SHARED realismMode AS INTEGER

' Shared PBM
DIM SHARED pbmEnabled AS INTEGER

' Shared mouse
DIM SHARED mouseEnabled AS INTEGER

' Shared menu system
DIM SHARED mtx$(0 TO 20)
DIM SHARED choose AS INTEGER
DIM SHARED tlx AS INTEGER
DIM SHARED tly AS INTEGER
DIM SHARED colour AS INTEGER
DIM SHARED hilite AS INTEGER
DIM SHARED size AS INTEGER

' Month names
DIM SHARED month$(1 TO 12)
' Note: month$ initialization moved to InitializeCampaign to avoid module-level executable code

