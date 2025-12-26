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

' Recruitment and army constants
CONST RECRUITMENT_COST = 100 ' Cost to recruit a new army
CONST DEFAULT_ARMY_SIZE = 10000 ' Default starting size for newly recruited armies
CONST SHIP_COST = 100 ' Cost to build a ship
CONST OBJECTIVE_BONUS = 100 ' Victory points bonus for capturing objective city
CONST END_GAME_BONUS = 100 ' Victory points bonus for triggering end game condition

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
DIM SHARED m1 AS INTEGER ' Middle point 1 (40)
DIM SHARED m2 AS INTEGER ' Middle point 2 (41)
DIM SHARED most AS INTEGER ' Maximum unit index (80)
' Initialize these values (from NAP10.BI: most = 80, m1 = 40, m2 = 41)
most = 80: m1 = 40: m2 = 41
DIM SHARED obstruct AS INTEGER ' Obstruction counter for map generation
DIM SHARED possess AS INTEGER ' Objective possessor (1 or 2, 3 = neutral)
DIM SHARED objx AS INTEGER
DIM SHARED objy AS INTEGER
DIM SHARED sdtext$(1 TO 24) ' Map text data (24 lines for 20 hex rows + buffer)
DIM SHARED file$ ' Used to signal battle end (CHR$(219) = time expired)
' Initialize file$ to empty string to prevent undefined variable errors
file$ = ""
DIM SHARED setupx AS INTEGER ' Setup position (1-5)
DIM SHARED timelimit AS SINGLE ' Battle time limit
DIM SHARED unitsize& ' Base unit size
DIM SHARED equip$(0 TO 5) ' Equipment types
DIM SHARED recon AS INTEGER ' Recon mode (0 = normal, 1 = show all)
' most, m1, m2 already declared above - removing duplicate
DIM SHARED toa(1 TO 100) AS SINGLE ' Time of action for each unit
DIM SHARED score&(1 TO 2) ' Score for each side
DIM SHARED waver(1 TO 2) AS INTEGER ' Waver state for each side
DIM SHARED stex$(1 TO 22) ' Status text
DIM SHARED highscore(1 TO 2) AS INTEGER ' High score tracking
DIM SHARED commander$(1 TO 2) ' Commander names
DIM SHARED expbase(1 TO 2) AS INTEGER ' Base experience for each side
DIM SHARED leadbase(1 TO 2) AS INTEGER ' Base leadership for each side
DIM SHARED sidex(1 TO 2) AS INTEGER ' Side identifiers
DIM SHARED vp&(1 TO 2) ' Victory points/strength for each side
DIM SHARED adj1$(1 TO 5) ' Adjectives 1
DIM SHARED adj2$(1 TO 5) ' Adjectives 2
DIM SHARED adj3$(1 TO 5) ' Adjectives 3
DIM SHARED sname$(1 TO 2) ' Side names ("Allies", "French")
DIM SHARED morlev$(1 TO 5) ' Morale level names
DIM SHARED xplev$(1 TO 5) ' Experience level names
DIM SHARED ledlev$(1 TO 5) ' Leadership level names
DIM SHARED stakk AS INTEGER ' Stack counter
DIM SHARED Mighty AS INTEGER ' Mighty flag
DIM SHARED artimp AS INTEGER ' Artillery improvement
DIM SHARED batint AS INTEGER ' Battle intensity
DIM SHARED movesleft AS INTEGER ' Moves left for current unit
DIM SHARED limber AS INTEGER ' Limber mode
DIM SHARED version AS INTEGER ' Version number
DIM SHARED artcap AS INTEGER ' Artillery capture enabled
DIM SHARED DEBUG AS INTEGER ' Debug mode
DIM SHARED startit! ' Start time
DIM SHARED timex AS SINGLE ' Current time

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
' DECLARE SUB snapshot (x%, y%, flag%) ' Removed: not implemented and not used
' DECLARE SUB touchup () ' Removed: not implemented and not used
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
DECLARE FUNCTION GetCurrentMonth$ ()
DECLARE FUNCTION GetVictoryPoints& (side AS INTEGER)
DECLARE SUB AwardEndGameBonus (side AS INTEGER)
DECLARE SUB SaveHighScore (side AS INTEGER, score AS LONG)

' Army management function declarations
DECLARE SUB MarkCommanderAvailable (armyIndex AS INTEGER)

' Utility function declarations
DECLARE FUNCTION GetFileSize& (filename AS STRING)
DECLARE SUB LogMessage (message AS STRING)
DECLARE SUB CloseLogFile
DECLARE SUB ShowHelp (topic AS STRING)
DECLARE FUNCTION GetSaveFileList$ (count AS INTEGER)
DECLARE FUNCTION CanRecruitInCity% (cityIndex AS INTEGER)
DECLARE SUB DrawStrategicMap

' Function declarations for tactical battle system
DECLARE FUNCTION RunTacticalBattleLoop% (side AS INTEGER, sidex(1 TO 2) AS INTEGER)
DECLARE FUNCTION GetRemainingStrength& (side AS INTEGER)
DECLARE FUNCTION CheckVictoryConditions% ()
DECLARE FUNCTION CheckObjectiveControl% (sideNum AS INTEGER)
DECLARE SUB LoadTacticalConfig ()

' Note: LaunchTacticalBattle is declared in tactical_integration.bas after battle_types.bas is included

' Shared configuration variables
DIM SHARED mdsp AS INTEGER ' Display mode
DIM SHARED mdly! ' Display delay
DIM SHARED bold AS INTEGER ' Boldness level (3-5)
DIM SHARED seelimit AS INTEGER ' Visibility limit
DIM SHARED quiet AS INTEGER ' Quiet mode (sound off)
DIM SHARED difficult AS INTEGER ' Difficulty level
DIM SHARED lineofsight AS INTEGER ' Line of sight enabled

' Shared game state variables
DIM SHARED scenario$
' Initialize scenario$ to empty string to prevent undefined variable errors
scenario$ = ""
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

' Shared variables for logging system
DIM SHARED logFileNum AS INTEGER ' Log file handle
DIM SHARED logInitialized AS INTEGER ' Log initialization flag

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
DECLARE FUNCTION IsCityIsolated% (cityIndex AS INTEGER)

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

