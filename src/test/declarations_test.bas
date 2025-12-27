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

'============================================================================
' DIM SHARED statements (must come before any SUB/FUNCTION declarations)
'============================================================================
' Module-level variables used by tactical/ui.bas
' Declared here early to avoid "between SUB/FUNCTION" errors
' Note: ui.bas also declares this, but declaring it here first ensures
' it appears before any SUB/FUNCTION declarations
DIM SHARED a AS INTEGER

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
' Note: strength is declared in declarations.bas
' Note: unitx is declared in declarations.bas
' Note: unity is declared in declarations.bas
' Note: leader is declared in declarations.bas
' Note: xper is declared in declarations.bas
' Note: morale is declared in declarations.bas
' Note: uorder is declared in declarations.bas
' Note: Visible is declared in declarations.bas
' Note: terrain is declared in declarations.bas
' Note: name$ is declared in declarations.bas
' Note: unit$ is declared in declarations.bas
' Note: elan is declared in declarations.bas
' Note: bigg is declared in declarations.bas
' Note: m1 is declared in declarations.bas
' Note: m2 is declared in declarations.bas
' Note: most is declared in declarations.bas
' Initialize these values (from NAP10.BI: most = 80, m1 = 40, m2 = 41)
' TEST: Commented out to avoid "between SUB/FUNCTION" errors - initialized in InitializeTestVariables
' most = 80: m1 = 40: m2 = 41
' Note: obstruct is declared in declarations.bas
' Note: possess is declared in declarations.bas
' Note: objx is declared in declarations.bas
' Note: objy is declared in declarations.bas
' Note: sdtext$ is declared in declarations.bas
' Note: file$ is declared in declarations.bas
' Initialize file$ to empty string to prevent undefined variable errors
' TEST: Commented out to avoid "between SUB/FUNCTION" errors - initialized in InitializeTestVariables
' file$ = ""
' Note: setupx is declared in declarations.bas
' Note: timelimit is declared in declarations.bas
' Note: unitsize& is declared in declarations.bas
' Note: equip$ is declared in declarations.bas
' Note: recon is declared in declarations.bas
' most, m1, m2 already declared above - removing duplicate
' Note: toa is declared in declarations.bas
' Note: score& is declared in declarations.bas
' Note: waver is declared in declarations.bas
' Note: stex$ is declared in declarations.bas
' Note: highscore is declared in declarations.bas
' Note: commander$ is declared in declarations.bas
' Note: expbase is declared in declarations.bas
' Note: leadbase is declared in declarations.bas
' Note: sidex is declared in declarations.bas
' Note: vp& is declared in declarations.bas
' Note: adj1$ is declared in declarations.bas
' Note: adj2$ is declared in declarations.bas
' Note: adj3$ is declared in declarations.bas
' Note: sname$ is declared in declarations.bas
' Note: morlev$ is declared in declarations.bas
' Note: xplev$ is declared in declarations.bas
' Note: ledlev$ is declared in declarations.bas
' Note: stakk is declared in declarations.bas
' Note: Mighty is declared in declarations.bas
' Note: artimp is declared in declarations.bas
' Note: batint is declared in declarations.bas
' Note: movesleft is declared in declarations.bas
' Note: limber is declared in declarations.bas
' Note: version is declared in declarations.bas
' Note: artcap is declared in declarations.bas
' Note: DEBUG is declared in declarations.bas
' Note: startit! is declared in declarations.bas
' Note: timex is declared in declarations.bas

' Shared variables from strategic game
' Note: graphic is declared in declarations.bas

' Function declarations for NAPOLEON.BAS subroutines
' These will be included when NAPOLEON.BAS is integrated
DECLARE FUNCTION randmap% ()
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
DECLARE FUNCTION iconload% ()
DECLARE SUB scrcol (which%)
DECLARE SUB Tara (x%, y%, flag%)
DECLARE SUB YouorMe (index%, F%)
DECLARE SUB inspect (index%)
DECLARE SUB snapshot (x%, y%, flag%)
DECLARE SUB touchup ()
DECLARE SUB order ()
DECLARE SUB expire ()
DECLARE SUB whois (x%, y%, Enemy%, index%)
DECLARE SUB replace (y%, x%, z%)
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB startmap ()
DECLARE FUNCTION LEFTY$ (index%)
DECLARE SUB over (flag%)
DECLARE SUB TICK (sec!)
DECLARE SUB clrbot ()
DECLARE SUB BuffClear ()

' Function declarations for main game
DECLARE FUNCTION ShowMainMenu% ()
DECLARE FUNCTION SelectCommander% (side AS INTEGER, cityIndex AS INTEGER)
DECLARE FUNCTION SelectScenario% ()

' Army management function declarations
DECLARE SUB MarkCommanderAvailable (armyIndex AS INTEGER)

' Utility function declarations
DECLARE FUNCTION GetFileSize& (filename AS STRING)
DECLARE SUB LogMessage (message AS STRING)
DECLARE SUB CloseLogFile
DECLARE SUB ShowHelp (topic AS STRING)

' Function declarations for tactical battle system
DECLARE FUNCTION RunTacticalBattleLoop% (side AS INTEGER, sidex(1 TO 2) AS INTEGER)
DECLARE FUNCTION GetRemainingStrength& (side AS INTEGER)
DECLARE FUNCTION CheckVictoryConditions% ()
DECLARE FUNCTION CheckObjectiveControl% (sideNum AS INTEGER)
DECLARE SUB LoadTacticalConfig ()

' Note: LaunchTacticalBattle is declared in tactical_integration.bas after battle_types.bas is included

' Shared configuration variables
' Note: mdsp is declared in declarations.bas
' Note: mdly! is declared in declarations.bas
' Note: bold is declared in declarations.bas
' Note: seelimit is declared in declarations.bas
' Note: quiet is declared in declarations.bas
' Note: difficult is declared in declarations.bas
' Note: lineofsight is declared in declarations.bas

' Shared game state variables
' Note: scenario$ is declared in declarations.bas
' Initialize scenario$ to empty string to prevent undefined variable errors
' TEST: Commented out to avoid "between SUB/FUNCTION" errors - initialized in InitializeTestVariables
' scenario$ = ""
' Note: currentPhase is declared in declarations.bas

' Shared arrays for strategic game
' Note: armies is declared in declarations.bas
' Note: cities is declared in declarations.bas
' Note: fleets is declared in declarations.bas
' Note: occupied is declared in declarations.bas
' Note: cityMatrix is declared in declarations.bas
' Note: gameState is declared in declarations.bas
' TEST: Add actual declarations for test compilation
' Note: armies is declared in declarations.bas
' Note: cities is declared in declarations.bas
' Note: fleets is declared in declarations.bas
' Note: occupied is declared in declarations.bas
' Note: cityMatrix is declared in declarations.bas
' Note: gameState is declared in declarations.bas

' Commander storage (50 total: 25 French, 25 Allied)
' Note: commanders is declared in declarations.bas
' Note: commanderIndex is declared in declarations.bas
' TEST: Add actual declarations for test compilation
' Note: commanders is declared in declarations.bas
' Note: commanderIndex is declared in declarations.bas

' Shared configuration
' Note: config_side is declared in declarations.bas
' Note: config_sound is declared in declarations.bas
' Note: config_balance is declared in declarations.bas
' Note: config_aggression is declared in declarations.bas
' Note: config_players is declared in declarations.bas
' Note: config_display is declared in declarations.bas
' Note: config_randevent is declared in declarations.bas
' Note: config_history is declared in declarations.bas
' Note: config_tactical is declared in declarations.bas

' Shared cohesion system
' Note: alliedAtWar is declared in declarations.bas

' Shared victory system
' Note: endGameFlags is declared in declarations.bas
' Note: endGameTriggered is declared in declarations.bas
' Note: endGameWinner is declared in declarations.bas

' Shared reports
' Note: battleWon is declared in declarations.bas
' Note: casualties is declared in declarations.bas
' Note: historyFile is declared in declarations.bas

' Shared variables for logging system
' Note: logFileNum is declared in declarations.bas
' Note: logInitialized is declared in declarations.bas

' Mouse function declarations
DECLARE FUNCTION GetMouseX% ()
DECLARE FUNCTION GetMouseY% ()
DECLARE FUNCTION GetMouseButton% ()
DECLARE FUNCTION GetMouseButtonClick% ()
DECLARE FUNCTION IsMouseAvailable% ()
DECLARE FUNCTION IsMouseOverCity% (cityIndex AS INTEGER)
DECLARE SUB ProcessMouseInput
DECLARE SUB HandleMouseClick
DECLARE SUB InitializeMouse
DECLARE SUB EnableMouse
DECLARE SUB DisableMouse

' Graphics function declarations
DECLARE FUNCTION LoadGraphicsFile% (filename AS STRING, graphicsArray() AS INTEGER)
DECLARE FUNCTION InitializeGraphics% ()

' Realism function declarations
DECLARE FUNCTION IsCityIsolated% (cityIndex AS INTEGER, cities() AS CityType, cityMatrix() AS INTEGER)
DECLARE FUNCTION GetRecruitmentSize& (cityIndex AS INTEGER, cities() AS CityType, realismModeEnabled AS INTEGER)
DECLARE FUNCTION GetIsolatedCityRecruitment& (cityIndex AS INTEGER, cities() AS CityType, cityMatrix() AS INTEGER, realismModeEnabled AS INTEGER)
DECLARE FUNCTION CanRecruitInCityRealism% (cityIndex AS INTEGER, cities() AS CityType, side AS INTEGER, realismModeEnabled AS INTEGER)
DECLARE FUNCTION GetDefenderAdvantage! (cityIndex AS INTEGER, cities() AS CityType, realismModeEnabled AS INTEGER)