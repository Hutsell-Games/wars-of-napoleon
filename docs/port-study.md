# Porting Wars of Napoleon to QB64Rust: the plan

> Paths such as `DECISIONS.md`, `PORTING-PDS.md`, `SOMEDAY.md`, `DIVERGENCES-QB45.md`, `QB64PE-DIVERGENCES.md`,
> `CLAUDE.md`, `verification\...` and `tools\qb45\...` are QB64Rust's (`davidshq/QB64Rust`, cloned beside this
> repo as `..\QB64Rust`). `tools\play\` and `tools\recover\` are this repo's. A bare `study\44` is Civil War
> Battleset's `docs\port-study.md`, `study\45` this repo's `docs\won-source-study.md`, and `study\46` Civil War
> Strategy's `docs\port-study.md`.

Written 2026-11-07, for the user's review. It is step 7 of `docs\won-source-study.md`: the port of both
programs to QB64Rust. Section 6 holds thirteen decisions, each with the panel's view. D12 came from step 0, and D13 from step 7. The same day the
pragmatic engineer reviewed it: step 0 and the split of step 7 come from that review. The user then said
"implement", which Claude took as taking every recommendation, D1 to D11. Nothing in the game's files has been
changed yet. The branch `qb64rust` exists and is at `main`'s last commit, `7738434` ("Recover the
source of WON.EXE (#3)").

The port follows the three earlier ones: World War 2, Civil War Battleset and Civil War Strategy. Their rules
are section 0 of `PORTING-PDS.md`. This plan applies them and says where this game differs. Two things are new
here:

- **The game is two programs that start each other.** The strategic game writes a battle file, runs the
  tactical game by `SHELL`, and reads the result back.
- **The port has a reference to check against.** The 15 sessions recorded from the shipped `WON.EXE` in DOSBox-X
  show what the game did in DOS, screen by screen and file by file. The earlier ports could compare only the
  QB64pe build with the QB64Rust build. Section 5 says how the port is held to the sessions.

## 1. What the port starts from

| | Strategic game | Tactical game |
|---|---|---|
| Program | `WON.EXE` | `NAPOLEON.EXE`, started by `WON.EXE` |
| Source | `WON.BAS` (1,837 lines, 17 SUBs), `WON2.BAS` (1,900 lines, 44 SUBs), `WONMENU.BAS` (472 lines, 5 SUBs), `WON.BI` (107 lines) | `NAPOLEON.BAS` (2,005 lines, 15 SUBs), `NAP1A.BAS` (1,308 lines, 46 SUBs), `NAP1C.BAS` (116 lines, the menu), `NAP10.BI` (91 lines) |
| Where the source came from | Recovered from `WON.EXE` (`study\45`). Built with PDS 7.1 and the recovery's runtime, it gives `WON.EXE` byte for byte | Hutsell's own source. It is a different revision from the shipped `NAPOLEON.EXE`: about 1 KB more code per module, 84–92% of the instruction shapes align (`study\45` section 8) |
| Screen | `SCREEN 12` (640 × 480), and `SCREEN 0` for the Hall of Fame | `SCREEN 9` (640 × 350), with two pages |
| Mouse | none | none (`Mighty` is declared in `NAP10.BI` and never used) |
| Sound | `SOUND` and `PLAY` only | `SOUND` only |

The tactical game is ported from the source in the repo, not matched to the shipped program first (user,
2026-11-06; `study\45`, "Decisions recorded in QB64Rust"). The recorded sessions therefore check the strategic
game. Only session 9 runs the tactical game, and it ran the shipped one.

The recovered source keeps its exact build on `main` and on `won-source`. The port moves and edits the files on
`qb64rust`, so the commands of `study\45` section 12 do not rebuild `WON.EXE` there. `docs\recovery.md` gets a
line that says so.

### The battle files

`WON.EXE` and `NAPOLEON.EXE` share no memory. A battle goes through two text files in the game's folder:

- **`BATTLE.$$$`**, written by `WON.BAS` line 827 with `WRITE #`, read by `NAPOLEON.BAS` line 40 with `INPUT #`.
  15 fields: the city, the human's side, the attacker's and defender's side numbers, then for each army its
  name, size, leader and experience, then the difficulty, the city's fort and the sound setting. Session 9
  wrote `"Innsbruck",1,2,1,"Bernadotte",125,5,2,"Alexander",98,5,1,3,0,2`. The 11th field is
  `armylead(attack)`, the attacker's leader, where the defender's is meant. That is the game's own slip, kept
  as it is (a `TODO.md` row).
- **`OUTCOME.&&&`**, written by `over` (`NAP1A.BAS` line 674) with `WRITE #`: the winning side and each side's
  losses in hundreds. `WON.BAS` line 833 reads them into INTEGER variables. Session 9 got
  `1,0,.689999984577298`.

If the tactical game ends any other way, `WON.EXE` reads the file left by the battle before. `NAPOLEON.BAS`
line 107 ends the program without writing it. That stays as it is.

### SHELL

Six `SHELL` lines, all in the strategic game. The tactical source has none: the shipped `NAPOLEON.EXE` starts
`NAPIC.EXE` for its title picture, and this revision of the source does not.

| Line | What it runs | Runs when | What the port does |
|---|---|---|---|
| `WON.BAS` 11 | `arch2.exe`, the intro picture, then skips the built-in title | `ARCH2.EXE` exists and there is no command line | Nothing: `ARCH2.EXE` leaves the folder (D6), so `DIR$` finds nothing and the line runs nothing |
| `WON.BAS` 93, 609 | `rrs.exe`, on quitting | `RRS.EXE` exists. It never does: its absence is what makes this the registered copy (line 410) | Nothing |
| `WON.BAS` 633 | `copy nws.his oldhist.ory` | History is on and `NWS.HIS` exists | Under a script, copied in BASIC, as Civil War Strategy's `scriptshell` does. In normal play, the `SHELL` as before |
| `WON.BAS` 831 | `napoleon.exe`, the battle | Tactical is on and the odds are within 3:1 | The port's own `napoleon.exe`, by the game's plain `SHELL` (D5). Under a script, with the child's own keys and state files (section 5) |
| `WON2.BAS` 696 | `vic.exe`, the victory picture | A new high score, and `VIC.EXE` exists | Nothing: `VIC.EXE` leaves the folder (D6) |

So under a script only `napoleon.exe` is started. `CLAUDE.md` working rule 6 allows a port's scripts on the
host when no `SHELL` under them can show a window, after one script that reaches the `SHELL` has been checked
on the host. Step 3 measured that libqb starts `napoleon.exe` directly, with no console, and that the child
runs on the parent's hidden desktop. Step 6 runs the check with the game itself. `tests\play.py` copies no `.EXE` into a run's
folder, so a DOS program left in the repo's folder cannot be reached by a script.

## 2. What was measured today

On a copy of the sources in a scratch folder outside every repo (`..\won-hutsellgames\port-measure\`), with the
release build of QB64Rust 0.3.0:

- **Merged as the earlier ports were** (the strategic game: `WON` + `WON2` + `WONMENU`; the tactical game:
  `NAPOLEON` + `NAP1A` + `NAP1C`; each linked module from its first SUB on), QB64Rust finds 15 errors in the
  strategic game and 2 in the tactical game:
  - 15 `DIR$` calls in the strategic game, and 1 in the tactical game (`NAPOLEON.BAS` line 1713,
    `DIR$("quotes.dat")`). QB64 reads each as an array;
  - `FRE(-1)` in the tactical menu (`NAP1C.BAS` line 91, a hidden key that prints the free memory).
- **With Civil War Strategy's `DIR$` FUNCTION added, the one bare `DIR$` written `DIR$("")`** (`WON2.BAS`
  line 611, `f$ = DIR$` in the list of scenarios), **and the `FRE` line taken out, both programs build.** No
  other PDS-only form is left: no `CURDIR$`, `CHDRIVE`, `ON LOCAL ERROR`, named `COMMON` or mouse interrupt.
  Unnamed `COMMON SHARED` (13 lines in `WON.BI`, 10 in `NAP10.BI`) is accepted, as Civil War Battleset
  measured.
- **Warnings:** 21 in the strategic game and 33 in the tactical game. All are of the kinds the earlier ports
  had: labels never used, names used once, a SUB never called (`findcity`), code after an `EXIT SUB` or a
  `GOTO`. None was looked at one by one yet.
- **`WONMENU.BAS` has four lines of module-level code before its first SUB** (lines 23–26, `y = 68: ...
  PRINT "Attacker"`). In PDS the module-level code of a linked module never runs, and nothing jumps there. The
  recovery wrote them because `WON.EXE` holds them. The merge left them out.
- **PDS and QB64 type `.01 * score&` differently.** The recorded `OUTCOME.&&&` holds `.689999984577298`: the
  SINGLE constant `.01` times 69, computed in DOUBLE. A three-line program that writes the same expression gives
  `.69` with QB64Rust: SINGLE. So the port writes other bytes into `OUTCOME.&&&` than DOS did. `WON.EXE` reads
  the numbers into INTEGERs, where 0.69 and 0.689999984577298 both become 1. Decision D8 is about this. The PDS
  side is inferred from the recorded files; step 3 measures it with `tools\qb45\qb45.py --compiler pds71`.

The two merged programs were built, not run.

## 3. Where this game differs from the earlier ports

Each row says what the port does. "Measure first" means the behavior is not yet known; a small program shows it
before the game is changed.

| # | What | Where, how many | What the port does |
|---|---|---|---|
| 1 | Two programs, each of three modules | `WON2`, `WONMENU`; `NAP1A`, `NAP1C` | As the earlier ports: `git mv` each linked module to `.BM`, remove its header, include it at the end of its main module. Each main module's SUBs move unchanged to a `.BM` of their own (`WON1.BM`, `NAP1.BM`), so that unit tests can include them |
| 2 | The main modules' `DIM SHARED` lines | `WON.BAS` line 8, `NAPOLEON.BAS` lines 20–26 | Into `WON.BI` and `NAP10.BI`, as `PORTING-PDS.md` section 1 says |
| 3 | `WONMENU.BAS`'s four lines of module-level code | Lines 23–26 | Commented out, with a `devnotes.md` item: they never ran in DOS. QB64 accepts code between SUBs and runs it as part of the main program's code (measured in step 4) |
| 4 | `DIR$` | 16 calls in the strategic game, one of them bare, and 1 in the tactical game (`docs\devnotes.md`, step 2) | Civil War Strategy's `DIR$` FUNCTION in a `QB64.BM` that both programs include. The bare one becomes `DIR$("")` |
| 5 | `FRE(-1)` | `NAP1C.BAS` line 91 | Commented out, as Civil War Battleset did (QB64pe has no `FRE`) |
| 6 | `END` in the tactical game | `NAPOLEON.BAS` line 107, `NAP1A.BAS` lines 677 (`over`) and 1290 | `SYSTEM`. In QB64, `END` shows "Press any key to continue" and waits. `WON.EXE` waits for the tactical game to end, so every battle would stop there until the player pressed a key in the tactical window. In DOS, `END` went straight back. The strategic game's two `END`s stay, as in the earlier ports |
| 7 | `SHELL "napoleon.exe"` | `WON.BAS` line 831 | Stays a plain `SHELL` (D5), in `scriptbattle`. Under a script, `scriptbattle` gives the child its own keys, state and seed (section 4) |
| 8 | `SHELL "copy nws.his oldhist.ory"` | `WON.BAS` line 633 | Through `scriptshell`, which copies in BASIC under a script. Taken from Civil War Strategy |
| 9 | The DOS programs with no source | `ARCH2.EXE` (intro), `VIC.EXE` (victory picture), `NAPIC.EXE` (tactical title, not called by the source); `RRS.EXE` is not in the repo | D6. Every `SHELL` of them is guarded by `DIR$`, so once the files are gone no line needs to change |
| 10 | `GOSUB` routines that may leave their SUB | 107 `GOSUB`s inside SUBs: 34 in the strategic game (8 in `WON`, 19 in `WON2`, 7 in `WONMENU`), 83 in the tactical game (55 in `NAPOLEON`, 18 in `NAP1A`, 10 in `NAP1C`) | Read every routine one by one (step 2). Already seen: `crsr` in both menus leaves by `GOTO called` on Esc or a letter, the bug of the other three games. Whether a `RETURN` then takes the stale entry, and stops the port with "RETURN without GOSUB", is what step 2 finds. The fix is the earlier ports': the routine sets a flag and `RETURN`s, and the line after the `GOSUB` jumps |
| 11 | `BLOAD` into arrays, then `PUT` | `MTN.VGA` and `NAPICON.VGA` (strategic); `STDICON.EGA`, `ALTICON.EGA`, `TERRAIN.EGA`, `MISC.EGA` (tactical) | Expected to work: Civil War Battleset and Civil War Strategy measured it. Checked against the recorded screens |
| 12 | The BIOS keyboard buffer | `BuffClear` (in `WON2.BAS` and in `NAP1A.BAS`: `POKE 1050, 30: POKE 1052, 30`); four `PEEK(1052) = 30` checks in `WON2.BAS` (lines 1024, 1034, 1055, 1091) that skip a pause, a sound or an icon when a key waits | Expected to work: libqb keeps the buffer there (Civil War Battleset, step 3). Under a script a key comes only at a wait, so the buffer is always empty at a check. Section 5 says what that changes |
| 13 | The clock | `RANDOMIZE TIMER` in both programs; `TICK` (`WON2.BAS` line 1768, `NAP1A.BAS` line 1201); `DATE$` in `NWS.HIS` (`WON.BAS` line 635) | Test hooks (step 6): the seed from an environment variable, the date 06-24-1998, which is the date the DOSBox-X sessions ran with, and `TICK` as D2 says |
| 14 | The waits for a key | Strategic: the menu's `crsr`, two `DO WHILE INKEY$ = ""` loops, `TICK` and one `INPUT` (the commander's name). Tactical: the menu, two command reads (`NAPOLEON.BAS` lines 744 and 1010), one loop (`NAP1A.BAS` line 841) and `TICK` | Each gets an `announce` call, as in the earlier ports |
| 15 | `CIRCLE` with an aspect, then `PAINT` inside it | The built-in title: `WON.BAS` lines 17–20 (aspect 0.1, then `PAINT`) | Look at the screen in step 4. QB64 draws such ellipses with other pixels than DOS (`DIVERGENCES-QB45.md` Q-020), and Civil War Strategy's map was flooded by such a leak. No recorded session shows this title: `ARCH2.EXE` ran instead |
| 16 | The precision of LONG times SINGLE | `.01 * score&(...)` in `over`; others to be found in step 2 | D8 |
| 17 | Names of different case | The code opens `"battle.$$$"`, `"nws.cfg"`; the files are upper case | Works on Windows. A `TODO.md` row for Linux, as in the earlier ports |

## 4. How a script plays both programs

The scripts use QB64Rust's screen-state check, as the earlier ports did (`tools\screen\README.md`). The
environment variable `QB64_SCREEN_KEYS` names the keys file and `QB64_SCREEN_STATE` the file the screens go to.
A program started by `SHELL` inherits the environment. So without care, `napoleon.exe` would read the strategic
game's keys file from its first line and write over its states.

Under a script, `scriptbattle` (`SCRIPT.BM`, step 6) starts the battle like this:

1. It counts the battle (1, 2, …) and sets, with `ENVIRON`, the child's keys file to `<keys>.battle<n>`, its
   state file to `<state>.battle<n>`, and `NAP_SEED` to the seed of the run.
2. It runs `SHELL "napoleon.exe"` and waits.
3. It puts the three variables back as they were. Whether libqb reads `QB64_SCREEN_STATE` at the start or at
   exit is checked in step 3; if at exit, putting it back is what keeps the strategic game's states.

`tests\play.py` writes each battle's keys file from the session's script and joins the states afterwards. While
the battle runs, the strategic game's keys file waits at its next `prompt`. That wait ends the run after 30
seconds unless `QB64_SCREEN_PROMPT_MS` gives it longer, so `play.py` sets it to the run's time limit.

The tactical game also runs alone, from a `BATTLE.$$$` that the script's folder holds. Its own scripts test
the battles that no strategic session reaches.

## 5. The 15 sessions as the port's test

The port must play the 15 sessions the same way as the shipped game. That means, for each session:

- **the same files**, byte for byte: the saved games, `NWS.HIS`, `NWS.CFG`, `HISCORE.NWS` and the battle files
  (36 files in all). A saved game holds the whole state of the game, so this is the strongest check;
- **the same screens** at each point where DOSBox-X took a screenshot, except the ones listed below.

### Why the recorded scripts cannot be used as they are

The sessions were played by `tools\play\PLAYKEYS.COM`, which puts each key into the BIOS buffer at a fixed tick
of emulated time. The QB64 scripts give each key at a wait the program announces. The two differ wherever time
matters:

- **A key that came during a pause was eaten by it.** `TICK` reads `INKEY$` until its time is up or a key
  comes. Sessions 4 to 8 and 10 to 14 type 16 Esc keys, 2 seconds apart, after each turn. Some end a pause, some
  close a message, and some reach a menu. Which one depends on timing.
- **Many screenshots were taken during a pause.** In session 9, "victorious" and "losses" are messages
  shown for a few seconds with no key. The earlier ports' `TICK` hook returns at once under a script,
  so those screens would never be at a wait.
- **The four `PEEK(1052)` checks** skip a pause, a sound or an icon when a key is waiting. Under a script none
  is.

### The bridge: the port's source built with PDS 7.1 (D1)

The port's changes are small, and none needs QB64. So the port's source can also be built with PDS 7.1 and run
in DOSBox-X. That build is the bridge between the recordings and the QB64 builds:

1. **`tools\pdsbuild.py`** writes three PDS modules from the port's files. It puts back the headers the merge
   removed, leaves out `QB64.BM` (PDS has `DIR$`) and includes a `PDS.BM` instead, which holds the PDS form of
   the few QB64-only lines. It then compiles and links them with the recovery's
   switches and runtime (`study\45` section 12). It also shows that every edit of the port is still valid PDS.
2. **Trace mode.** With `WON_TRACE` set, the hooks only announce: they write the place of each wait into bytes
   `&H4F0`–`&H4F2`, as for QB64, and change nothing else. `PLAYKEYS.COM` gets a mode that logs, at each tick,
   the announce counter and the BIOS buffer's pointers. Each timed session is run with this build. It must give
   the recording's screens and files, which shows that the port's edits and the hooks did not change the play.
   From the log, `tools\play\sessions.py` finds the wait that took each key, the keys that a pause or
   `BuffClear` threw away, and the wait at which each screenshot was taken. It writes an announce-driven keys
   file for the session.
3. **Scripted mode.** With `WON_SEED` set, the hooks act as they do under QB64: each `TICK` waits for a key (D2),
   the date is fixed, the history file is copied in BASIC. `PLAYKEYS.COM` gets a second new mode that gives the
   next key when the program announces a wait, and takes a screenshot after a given announcement, as the screen
   tool's `prompt` and `state` do. Each announce-driven keys file is run this way. Its screens and files are
   compared with the recording. Every difference must come from the hooks (a pause that waited for a key, an
   icon that a waiting key used to skip) and is listed in the session's notes. The files must be equal.
4. **The QB64 builds.** The same announce-driven keys files run with the QB64Rust and QB64pe builds. Their
   screens and files are compared with the scripted DOSBox-X run (step 3): the same program, the same keys, in
   another compiler. A difference is then a difference of the compilers or of libqb, not of timing. Each one is
   either fixed in the port or recorded, with the program that shows it, as a QB64Rust divergence.

So each kind of difference shows at one stage only: the port's edits at stage 2, the hooks at stage 3, the
compiler at stage 4.

### Comparing a DOSBox-X screenshot with a QB64 screen

A QB64 state gives each pixel as a palette index, and in `SCREEN 0` each cell as a character and an attribute.
The DOSBox-X screenshots are RGB PNGs. A new `tests\dosshot.py` turns a screenshot into the same form:

- **Graphics screens** (`SCREEN 12`, 640 × 480, and `SCREEN 9`, 640 × 350): each pixel's color becomes the
  nearest of the 16 palette entries. The two images must then be equal. If they are not, the report gives the
  number of pixels that differ and the boxes around them.
- **Text screens** (`SCREEN 0`, which DOSBox-X saves at 720 × 400 with a 9-pixel cell): each cell's 8 × 16
  glyph and two colors are read back to a character and an attribute, using the font of a screen whose text is
  known. The cells must be equal.

Step 3 measures whether QB64's 8 × 16 and 8 × 14 fonts draw the same pixels as DOSBox-X's. If they do, the
comparison is exact. If not, text is compared by cell on graphics screens too, and pixels only outside text.

**Screenshots left out**, 12 of the 317:

- `01-intro`, the picture of `ARCH2.EXE`, and `16-vic` in session 15, the picture of `VIC.EXE` (D6);
- the six `dos` screenshots, the DOS prompt after Quit. The QB64 program shows "Press any key to continue"
  there, and the script's last key ends it;
- in session 9, `04-tactical-title` (`NAPIC.EXE`, which the source does not run) and the three battle screens
  (`05-battle-map`, `06-rested`, `07-retreat-ask`), which show the shipped tactical game, not the source (D3).

That leaves 305: 297 graphics screens and 8 text screens.

### Session 9 and the tactical game

Session 9 is the only one that runs a battle. The port runs its own tactical game, a different revision with
another seed, so its battle may end differently. Then `OUTCOME.&&&` and everything after it would differ, and
the session would show nothing about the strategic game. D4 splits it into two runs.

The tactical game itself has no recording from its own source. D3 makes one: the tactical source built with PDS
7.1, played in DOSBox-X from a few recorded `BATTLE.$$$` files, by the same trace and scripted modes. The
tactical port is then held to that, by stages 2 to 4.

### What depends on what

All of this assumes that QB64's `RND` after `RANDOMIZE 1` gives the numbers PDS 7.1 gives. The harness seeded
`WON.EXE` with `RANDOMIZE` of the DOUBLE 1.0 (`tools\play\wonseed.py`). The hook passes `VAL` of `WON_SEED`,
which is the same DOUBLE. Nobody has compared QB64's `RND` with PDS's yet, so step 3 does it first. If they
differ, no session can match, and the first risk of section 8 applies.

## 6. Decisions for the user

The panel: the pragmatic engineer, the QB64 engineer, the compiler engineer, the Rust engineer, the test
engineer, and two more roles. The **reverse engineer** of the recovery is added because the plan builds the
port's source with PDS 7.1 and extends `PLAYKEYS.COM`. **A QB64 user porting an old program** is added as in
`study\44`, because this is the first port of two programs that start each other.

The Rust engineer has no view on D1 to D12: no Rust code changes. What the port finds about QB64Rust goes to
QB64Rust as verification programs and divergence rows.

**D1. How the 15 sessions become the port's test.**
- (a) Through the bridge of section 5: the port's source built with PDS 7.1, run in trace mode against the
  recordings, then in scripted mode as the reference for the QB64 builds.
- (b) Convert the timed scripts to announce-driven ones by hand, from their comments and screenshots, and
  compare the QB64 builds with the recordings directly.
- (c) Compare only the QB64pe build with the QB64Rust build, as the earlier ports did, and look at the
  sessions' screenshots by eye.

*Panel:* the test engineer wants (a). In (b), a difference could come from timing, the hooks, the port's edits
or the compiler, and nothing tells them apart. The 16-Esc tails of 10 sessions make a hand conversion a guess.
The reverse engineer notes that the pieces exist: the recovery's build, `PLAYKEYS.COM`'s assembler, the runtime
map. The two new modes of `PLAYKEYS.COM` are small. The pragmatic engineer accepts (a): it is Claude's time,
and what stays is one tool (`pdsbuild.py`), two modes and a converter. The compiler engineer adds that stage 4
is the first test of QB64Rust against the old compiler on a whole game, with the timing taken out. The QB64
user notes that (c) would leave the recordings unused. **Recommended: (a).**

**D2. Under a script, every `TICK` waits for a key.** In the earlier ports, a pause under 99 seconds returns at
once under a script.
- (a) Every `TICK` announces a wait (place 3) and waits for a key, in the PDS and the QB64 builds alike. A rule
  answers the pauses no session stops at.
- (b) As in the earlier ports. Screenshots taken during a pause are dropped from the comparison.

*Panel:* the test engineer wants (a): screenshots of messages shown during a pause are in many sessions (step
7 counts them), and in (b) they would be lost. The pragmatic engineer notes that (a) makes
the keys files longer, and that the rules of the screen tool answer the pauses without a line each. The QB64
engineer notes that `TICK` throws its key away, so the key a rule gives a pause changes nothing in the game.
**Recommended: (a).**

**D3. A reference for the tactical game.**
- (a) Build `NAPOLEON.BAS`, `NAP1A.BAS` and `NAP1C.BAS` with PDS 7.1 (the module list of `NAPOLEON.MAK`, in
  the first commit `6e0930f`), and record 3 to 5 battles in DOSBox-X from different `BATTLE.$$$` files: both sides, the
  computer against the player, an F9 retreat, a battle to its time limit. The tactical port is held to them
  as in D1.
- (b) Compare the tactical port only between QB64pe and QB64Rust.

*Panel:* the QB64 user wants (a): the battles are half of what the game is. The reverse engineer notes that
the seed needs the same patch as `WONSEED.EXE`, at `NAPOLEON.BAS` line 18, or the hook, since the source is
ours to build. The pragmatic engineer agrees, with the number of battles kept small. The test engineer wants
the hand-written tactical scripts of step 8 on top. **Recommended: (a), with the hook rather than a patch.**

**D4. Session 9 runs twice.**
- (a) Once with the battle replaced: under a script with `WON_OUTCOME` set, `scriptbattle` copies the recorded
  `OUTCOME.&&&` in place of starting the tactical game. That run is held to the whole recording but the battle
  screens. A second run starts the port's tactical game, and is held to the strategic screens up to the battle
  and to `BATTLE.$$$`.
- (b) Only the run with the real tactical game.

*Panel:* the test engineer wants (a): without it the strategic code after a battle, which reads `OUTCOME.&&&`
and applies the losses, is checked by no session. The pragmatic engineer notes that the hook is a few lines,
in `scriptshell`, which exists anyway. **Recommended: (a).**

**D5. `napoleon.exe` is started with `SHELL _HIDE`, also in normal play.**
- (a) Always `SHELL _HIDE`.
- (b) `SHELL _HIDE` only under a script; normal play keeps `SHELL`.

*Panel:* the QB64 user wants (a). With a plain `SHELL`, Windows opens a `cmd.exe` console window for the length
of every battle, which DOS never showed. The pragmatic engineer agrees: it is the same line either way. The
QB64 engineer notes that QB64pe and QB64Rust both take `SHELL _HIDE` (QB64Rust's `tests\callsite\shell_hide_*`),
and that the copy of `NWS.HIS` keeps its plain `SHELL` in normal play, as Civil War Strategy's does. Step 3
checks that the tactical window comes to the front. **Recommended: (a).**

*Reopened by step 3 (2026-11-07).* The reason for (a) was wrong. libqb starts `napoleon.exe` directly with
`ShellExecuteEx`, not through `cmd.exe`, so a plain `SHELL` opens no console. And `SHELL _HIDE` passes `SW_HIDE`,
which hides the battle window itself for as long as the battle runs. Measured with QB64Rust and QB64pe
(`docs\devnotes.md`, "Step 3"). Put to the user again: (a) keep the game's plain `SHELL "napoleon.exe"`, in
normal play and under scripts; (b) `SHELL _HIDE` as above. **User (2026-11-07): (a).** The line stays as it is.
Under a script the battle runs on the script's hidden desktop, and no console opens.

**D6. The DOS programs with no source** (`ARCH2.EXE`, `VIC.EXE`, `NAPIC.EXE`).
- (a) As in the earlier ports: they leave the branch, and their screens go into `docs\` as PNGs. The sessions
  already hold them (`01-1796-french\shots\01-intro.png`, `15-1815-high-score\shots\16-vic.png`,
  `09-1805-tactical\shots\04-tactical-title.png`), so no new DOSBox run is needed. Without `ARCH2.EXE` the game
  shows its own built-in title, as it did in DOS where the file was missing.
- (b) Show the three pictures in the game with `_LOADIMAGE`, where it ran the programs.

*Panel:* the pragmatic engineer wants (a), for the reason of Civil War Strategy's D2: all four games wait for
the same choice, and (b) is new code. The QB64 user would like (b) later, for all four games at once. The test
engineer notes that (a) changes the start of every session: the built-in title and its `TICK 2` come where
`ARCH2.EXE` was. The converter of section 5 handles it, since the trace shows which keys `ARCH2.EXE` took.
**Recommended: (a), with a `TODO.md` row for (b).**

**D7. Where the DOS programs go.** The recovery's tools and the DOSBox-X harness need `WON.EXE` and
`NAPOLEON.EXE`, and replaying the recordings needs `ARCH2.EXE`, `VIC.EXE` and `NAPIC.EXE`. The port's builds take
the names `won.exe` and `napoleon.exe`, and Windows does not tell `WON.EXE` from `won.exe`.
- (a) `git mv` the five into a folder `dos\`. `tools\play\play.py` and the recovery's instructions take them
  from there. The builds go beside the data and are ignored by git.
- (b) Leave them where they are, and never build in the repo's folder.
- (c) Remove them from the branch, and have the tools read them from `main` with `git show`.

*Panel:* the pragmatic engineer and the test engineer want (a): a build in the repo's folder, which is how a
player would build it, would overwrite `WON.EXE` in (b), as Civil War Strategy's D9 warned. In (c) the tools
would break once `qb64rust` is merged into `main`. The reverse engineer notes that `play.py` hashes
`WON.EXE` to recognize the shipped program, so only its path changes. **Recommended: (a).** This departs from
`PORTING-PDS.md`'s "remove the DOS programs from the branch". The reason is that this repo's tests use them.

*User (2026-11-08), at step 5:* `WON.EXE` and `NAPOLEON.EXE` stay where they are, as in (b), but a build in
the repo's folder may overwrite them. `ARCH2.EXE`, `VIC.EXE` and `NAPIC.EXE` leave the branch as D6 says. To
replay the recordings with the shipped programs, `tools\play\README.md` uses a worktree of `main`. The bridge
of step 7 plays the PDS 7.1 builds of the port, so it does not need them.

**D8. LONG times SINGLE.** PDS computes `.01 * score&` in DOUBLE, QB64 in SINGLE (section 2). The values differ
in the 8th digit.
- (a) Leave the game's lines as they are. Compare `OUTCOME.&&&` by the values `WON.EXE` reads from it,
  INTEGERs, not by its bytes. Measure the rule in PDS 7.1 and QB 4.5, and give QB64Rust a `DIVERGENCES-QB45.md`
  row and a `verification\qb45\` program.
- (b) Change such lines so that QB64 also computes in DOUBLE (`.01#`).

*Panel:* the compiler engineer wants (a), and the measurement before anything else: it is a typing rule of the
old compiler, not something of the machine, so `CLAUDE.md` working rule 8 does not cover it. Whether QB64Rust
should follow PDS here is a QB64Rust question, put to the user there with its own panel. The pragmatic engineer
notes that a port is not a fix. If step 2 finds a line where the difference changes what the game does (a
saved game, a casualty count), that line is put to the user on its own. **Recommended: (a).**

*The `OUTCOME.&&&` line, put to the user on its own after step 3 (2026-11-07).* For tactical scores of 150,
350, 550 and every 200 after, the strategic game reads one hundred more losses than in DOS. (a) Leave it. (b)
Change that line so that QB64 computes the product as DOS did. **User (2026-11-07): (b).** The form was
measured the same day (QB64Rust's `verification\qb45\q45_outcome_input`, part 4): only a SINGLE variable works.
`over` sets `hundredth! = .01` and writes `hundredth! * CDBL(score&(…))`. In QB64, `.01! * CDBL(s&)` and
`CSNG(.01) * CDBL(s&)` still use the DOUBLE 0.01. The change is made in step 5. The other lines of D8 stay as
(a) says.

**D9. Data folders.**
- (a) As in the earlier ports, done after the scripts exist: `graphics\` (`MTN.VGA`, `NAPICON.VGA` and the four
  `.EGA` icon sets), `scenarios\` (`GAMEDATA.INI`, the seven `NWSxxxx.INI`, `EUROxxxx.MAP` and `LEADxxxx.DAT`,
  and the tactical game's `ALLIES.DAT`, `FRENCH.DAT`, `EQUIP.DAT` and `QUOTES.DAT`), named in a `FOLDERS.BI`
  that both programs include. The battle files, the saves, `NWS.CFG`, `NWS.HIS`, `HISCORE.NWS` and `BATTSUMM`
  stay beside the programs. `tools\play\play.py` copies the folders flat into DOSBox-X's folder, as the DOS
  game wants.
- (b) No folders.

*Panel:* the QB64 user wants (a): the folder holds about 70 files, and the user chose folders for the other
three games. The pragmatic engineer agrees, after the scripts, so that they show the move changed nothing. The
reverse engineer asks that `pdsbuild.py` build the PDS version with the same `FOLDERS.BI`, so the bridge keeps
working. **Recommended: (a).**

**D10. Scripts beyond the 15 sessions.**
- (a) Generated whole games, as Civil War Battleset's: each of the seven scenarios played by each side, the
  player only ending turns, compared between QB64pe and QB64Rust. Hand-written scripts for what no session
  reaches: a naval invasion, Napoleon's exile, battles of the tactical game alone. Then coverage, with the
  uncovered SUBs in `TODO.md`.
- (b) Only the 15 sessions and the tactical references of D3.

*Panel:* the test engineer wants (a): the sessions run the computer's play in only a few scenarios to their
end, and they were written for the recovery, not for coverage. The pragmatic engineer agrees, with the
generated scripts compared only between the two QB64 builds, since they use the screen tool's rules, which
`PLAYKEYS.COM` does not have. **Recommended: (a).**

**D11. The files no program opens.** `PREFER.CFG`, `GENERALZ` and `MAXSKORS` are Civil War Battleset's file
names. `SETUP.INI`, `NAP1.EGA` and `NAP2.EGA` are opened by no source; at most by `NAPIC.EXE`, `VIC.EXE` or
`ARCH2.EXE`, which leave (D6). `NWS.LNK` is the old link file, which the recovery replaced by
`tools\recover\WON.LNK`.
- (a) They leave the branch in step 9, and stay on `main`.
- (b) They stay.

*Panel:* all agree on (a), after a check that no session's trace opens them. **Recommended: (a).**

**D12. Products that round to the other integer in QB64** (step 0; QB64Rust's `DIVERGENCES-QB45.md` Q-022).
`x = .7 * x` gives 115 in DOS and 116 in QB64 for `x = 165`. The game's battle lines are of this kind
(`WON.BAS` lines 823–824 and 886–887, and many in the tactical game). It happened 2 times in 120 values.
- (a) Leave the game's lines. A session that meets it is compared up to that battle. The line and the values
  are written in its notes, found with QB64Rust's `--trace-values`.
- (b) Change each such line so that QB64 multiplies the SINGLE constant by the INTEGER in DOUBLE. A SINGLE
  times an INTEGER is exact in DOUBLE, so it then rounds as DOS did, for the scripts and for players. The form
  must keep the constant a SINGLE: in step 0, `d# = .01 * s&` gave `.6900000000000001` in QB64, which is the
  DOUBLE 0.01 times 69, not the SINGLE `.01` widened. So the form is probably `CSNG(.7) * CDBL(x)` rather than `.7 * CDBL(x)`. The form is measured and the lines
  counted in step 2.
- (c) Change QB64Rust to keep the exact product before the store, as the x87 did.

*Panel:* the compiler engineer rules out (c): `CLAUDE.md` working rule 8 says not to follow the x87, and
QB64Rust follows QB64pe. The pragmatic engineer wants (a) first, and to count in step 7 how many of the 15
sessions meet it. A port is not a fix, and the count may be zero. The QB64 user leans to (b): a player's battles
then come out as in DOS. The test engineer notes that (b) touches many lines that the bridge must also show to be
unchanged in PDS, which it can: in PDS the `CDBL` changes nothing. The reverse engineer agrees with the count
first. **Recommended: (a), with (b) put to the user again if more than two or three sessions meet it.**
**User (2026-11-07): (a).**

Found while the user weighed (b): the set of lines is not only a constant times an INTEGER. The old compilers
keep the x87's precision across a whole SINGLE expression until it is stored, so any SINGLE expression stored
in an INTEGER can round the other way (`.8 * killa + .2 * killd`, a division, a `SQR` in a sum). If (b) comes
back, it needs three things: a search for every such store by type (QB64Rust's `--dump typed`), the form
measured in all four compilers until QB64 gives the old compilers' integers, and the bridge showing no
difference left in the 15 sessions.

**D13. Conditions that PDS 7.1 cut short** (step 7; QB64Rust's `DIVERGENCES-QB45.md` Q-026). PDS 7.1 skips
the right side of `AND` when the left side is false, and of `OR` when the left side is true. QB64 evaluates
both. So `IF y > x AND RND > .5` draws an `RND` in QB64 that DOS did not, and every later `RND` differs. In
session 9 the computer's first recruiting already played another game. Both `TICK`s read `INKEY$` the same
way.
- (a) Write each such line so that the skipped side comes after a test of its own: a nested `IF`, an `ELSEIF`,
  or an `EXIT DO` in `TICK`. It then does the same in PDS 7.1 and QB64.
- (b) Leave the lines. The QB64 builds then match no session past the computer's first recruiting.

*Panel:* the pragmatic engineer wants (a): about 15 mechanical lines, and the PDS build shows that DOS is
unchanged. The compiler engineer notes that this is a rule of the old compiler, not of the machine, so
`CLAUDE.md` working rule 8 does not apply, and that a QB64Rust change is a separate QB64Rust question. The test
engineer asks for the 15 sessions with the PDS build after the change. **Recommended: (a).**
**User (2026-11-08): (a).** Done in the strategic game and in both `TICK`s (`docs\devnotes.md`, change 24).
The tactical game's other lines are sorted when its PDS build comes (`TODO.md`).

## 7. The plan

Each step ends with a review of its changes, the user staging them, and one commit. Claude never stages
(`CLAUDE.md` rule 1). From step 8 on, each step also runs the port's `tests\play.py check`, and any screen that
changes is either a mistake or is named in the commit message.

0. **The two measurements that decide D1** (the pragmatic engineer's review, 2026-11-07). Before anything is
   built for section 5:
   - `RND` after `RANDOMIZE 1#`: the first 1,000 numbers, PDS 7.1 against QB64Rust and QB64pe;
   - LONG times SINGLE (D8), and a few SINGLE sums of the kind the casualty lines make, in PDS 7.1 and QB 4.5
     against QB64.

   If `RND` differs, or the sums round differently often, D1 is put to the user again before step 7.

   **Done (2026-11-07).** `RND` is the same, bit for bit, in PDS 7.1, QB 4.5, QB64Rust and QB64pe. Two kinds of
   arithmetic differ (QB64Rust's `DIVERGENCES-QB45.md` Q-021 and Q-022). A SINGLE constant times a LONG is a
   DOUBLE in the old compilers: that is the `OUTCOME.&&&` line of D8. And `x = .7 * x` can round to the other
   integer, 2 times in 120 of the program's values: the old compilers keep the x87's precision before storing.
   That one is in the game's battle lines, so a session that meets it differs from that battle on. D12 below
   asks what to do. The details are in `docs\devnotes.md`, "Step 0".
1. **The branch.** `qb64rust` exists at `7738434`. Check that it is still at `main` before step 2.
2. **The searches, before any edit.** Into a new `docs\devnotes.md`:
   - every PDS-only name of `SOMEDAY.md`'s list "Popular BASIC PDS 7.1 features";
   - every `GOSUB` routine in a SUB, read one by one (row 10), with the ones that can leave before `RETURN`;
   - every `PEEK`, `POKE`, `DEF SEG`, `BLOAD`, `SHELL` and `END`, with what each did in DOS;
   - every expression that mixes a LONG with a SINGLE (D8), and what PDS and QB64 give for it.
3. **The measurements.** Small programs, built with both compilers and run on the host one by one. The old
   compiler's side through `tools\qb45\qb45.py --compiler pds71`.
   - `WRITE #` and `PRINT #` of the kinds of numbers the saved games and `NWS.CFG` hold.
   - A QB64 program that starts another by `SHELL _HIDE`, run on a hidden desktop on the host: that no window
     shows on the user's desktop, that the child sees the variables set with `ENVIRON`, that the child's window
     comes to the front in normal play, and when libqb reads `QB64_SCREEN_STATE` (section 4). This is the check
     that `CLAUDE.md` working rule 6 asks for before any script with a `SHELL` runs on the host.
   - The fonts: a `SCREEN 12`, a `SCREEN 9` and a `SCREEN 0` screen of text, from DOSBox-X and from QB64, to
     settle how `dosshot.py` compares them (section 5).
   A result that QB64Rust has not recorded before becomes a program in QB64Rust's `verification\`.

   **Done (2026-11-07).** The tactical window comes to the front, measured in one run on the user's desktop.
   Three findings change the plan (`docs\devnotes.md`, "Step 3"):
   - `SHELL _HIDE` hides the battle window, and a plain `SHELL` opens no console, so D5 goes back to the user.
   - For one score in 200, `OUTCOME.&&&` gives one hundred more losses than in DOS (D8).
   - The 8 × 14 font of `SCREEN 9` differs from DOSBox-X's, so `dosshot.py` compares the tactical game's text
     by character.
4. **One program each, building.** Rows 1–6 and 17. The strategic game is `WON.BAS`, including `WON.BI`,
   `WON1.BM`, `WON2.BM`, `WONMENU.BM`, `QB64.BM` and `SCRIPT.BM`. The tactical game is `NAPOLEON.BAS`, including
   `NAP10.BI`, `NAP1.BM`, `NAP1A.BM`, `NAP1C.BM`, `QB64.BM` and its own `NAPSCRIPT.BM`. Build `won.exe` and
   `napoleon.exe` with both compilers, play the first screens and one battle by hand, and compare the two
   builds. Look at the built-in title (row 15).

   **Done (2026-11-07).** Both programs build with both compilers. Played with timed keys on a hidden
   desktop, the two builds show the same screens, and the first turn writes the same `BATTLE.$$$` and
   `NWS9.SAV` as session 9 did in DOS. The title's `PAINT` does not leak. Choosing the start year by its
   letter stops the game with "RETURN without GOSUB", as step 2 expected. QB64 drew the dotted roads with
   other pixels than DOS; the port now draws them with QB 4.5's own steps, as the user chose. On the user's
   desktop, the battle window came to the front. Two differences from DOS are left for later steps: the
   pixels of the small city circles, and one army in another city by July 1805 (`docs\devnotes.md`,
   "Step 4", and `TODO.md`).
5. **What DOS did that QB64 does not.** Rows 7–10: the copy of `NWS.HIS`, the DOS programs (D6, D7), and the
   `GOSUB` fixes. `SHELL "napoleon.exe"` stays as it is (D5). The `OUTCOME.&&&` line of `over` computes in
   DOUBLE (D8).

   **Done (2026-11-08).** The six `GOSUB` routines that could leave their SUB now end by `RETURN`, and a flag
   tells the line after the `GOSUB` what to do. Choosing the start year by its letter no longer stops the game.
   The copy of `NWS.HIS` goes through `scriptshell` in a new `SCRIPT.BM`. Until step 6 sets `scripted`, it runs
   the `SHELL` as before. `over` writes `hundredth! * CDBL(score&(…))`. The pictures of the three DOS programs
   are in `docs\`, and the user removes the three files. `WON.EXE` and `NAPOLEON.EXE` stay where they are (D7,
   decided again). The tactical changes build and ran through many computer moves, but the Yes/No menu by
   letter and F10 wait for step 6's hooks (`docs\devnotes.md`, "Step 5").
6. **The test hooks**, in BASIC that both PDS 7.1 and QB64 compile: the seed from `WON_SEED` and `NAP_SEED`,
   `announce` before each wait (row 14), `TICK` as D2 says, the date 06-24-1998, `scriptshell` (section 4 and
   D4), and trace mode (`WON_TRACE`). Both programs play as before when no variable is set.

   **Done (2026-11-08).** The hooks are in `SCRIPT.BM` and a new `NAPSCRIPT.BM`. The battle goes through a new
   `scriptbattle`, and the tactical game has its own trace variable, `NAP_TRACE`. A tactical `TICK` under a
   second reads no key in DOS, so it is not a wait. Played by announced waits, session 9's first turn writes
   the recording's `BATTLE.$$$` and `NWS9.SAV`, and the QB64pe and QB64Rust builds give the same screens. The
   Yes/No menu by letter and F10 work. Two findings for step 7 (`docs\devnotes.md`, "Step 6"):
   - In DOS, PDS 7.1's `ENVIRON` stops with "Out of memory" when the environment has no room. So the harness
     sets `NAP_SEED` and `NAP_TRACE` before `WON.EXE` starts.
   - The French moves already differ from session 9 in May, before the battle (`TODO.md`).
7. **The bridge** (D1, section 5), in two halves with a check between them (the pragmatic engineer's review,
   2026-11-07).
   - **7a.** In `tools\`: `pdsbuild.py`; the trace mode of `PLAYKEYS.COM`; `sessions.py`, which writes the
     announce-driven keys files into `tests\sessions\`. Run the 15 sessions in trace mode and check them against
     the recordings.

     The DOSBox-X folder of a trace run holds `ARCH2.EXE` and `VIC.EXE`, taken from git history (they left the
     branch in step 5). The recordings ran both: the first key of each session dismissed `ARCH2.EXE`'s
     picture, and session 15 shows `VIC.EXE`'s. Without them the PDS build shows its built-in title, whose
     `TICK 2` takes another key, and the trace parts from the recording at its first key. `WON.BAS` still runs
     each program when its file is there. The harness also sets `NAP_SEED` and `NAP_TRACE` itself: PDS
     7.1's `ENVIRON` has no room for a new variable in DOS (`docs\devnotes.md`, "Step 6").
     **Started (2026-11-08).** `pdsbuild.py` and `play.py --port` exist, and session 9 with the PDS build gives
     the recording. The trace mode of `PLAYKEYS.COM` and `sessions.py` are not written yet. Found on the way:
     PDS 7.1 skips the right side of `AND` and `OR` in conditions, and QB64 does not. That is why the French
     move elsewhere in the QB64 builds. The strategic game's lines and both `TICK`s are rewritten (D13), and
     all 15 sessions with the PDS build still give their recordings (`docs\devnotes.md`, "Step 7").
   - **The check.** Run the converted keys files once with the QB64 builds and compare them straight with the
     recordings. If the only differences are screens of pauses and the four `PEEK(1052)` checks (row 12), the
     scripted reference of 7b is made only for the sessions that need it. Otherwise for all 15.
   - **7b.** The announce mode of `PLAYKEYS.COM`. Run the sessions in scripted mode and keep their screens and
     files beside the keys files, as the reference for step 8. List each difference from the recordings and its
     cause. Then the same for the tactical references of D3.

   While the bridge is used, every edit of the port must also compile with PDS 7.1, so a QB64-only statement
   goes into `QB64.BM` with its PDS form in `PDS.BM`. The bridge is kept until the first refactoring of the
   game; then the user decides whether it stays.
8. **The port's tests.**
   - `tests\play.py`, `tests\make_scripts.py` and `tests\test_play.py`, adapted from Civil War Strategy's, and
     `tests\dosshot.py`.
   - The 15 sessions and the tactical references with both QB64 builds, held to step 7's reference and to the
     recordings. Session 9 twice (D4).
   - Unit tests in `tests\rules_test.bas` for SUBs that draw nothing. Candidates, to check one by one: `normal`
     (in both programs), the sort in `WON2.BAS`, `strong`, `Compact`.
   - The generated and hand-written scripts of D10, then `play.py coverage`.
9. **The files.** Remove what the port does not use: `NWS.LNK` and the files of D11. Check before each one that
   neither program needs it to exist. Move `NWS9.SAV`, `HISCORE.NWS` and the shipped `NWS.CFG` to `tests\data\`,
   and ignore the copies that playing makes. Then the folders of D9, and the documents (`WON.DOC`,
   `NAPOLEON.DOC`, `NAPOLEON.PAG`, `NAPOLEON.TXT`) into `docs\`. `play.py check` and a scripted run of the bridge
   show that no screen changed.
10. **The build on GitHub Actions.** World War 2's `build.yml`, with the artifact `wars-of-napoleon`: `won.exe`,
    `napoleon.exe` and the data folders.
11. **The documents.**
    - In this repo: `README.md` (a section for the branch, as World War 2's), `docs\devnotes.md` (the numbered
      changes, what was checked, what it found), `tests\README.md`, `tools\play\README.md`, `TODO.md`, and this
      study.
    - In QB64Rust: what the port found goes into `PORTING-PDS.md` (sections 0 and 3 to 5: two programs that
      start each other, `END` in a program run by `SHELL`, the bridge through the old compiler), divergence rows
      and verification programs, and `DECISIONS.md` rows where the user decides something about QB64Rust.

Not in the plan: any refactoring, reformatting, a fix to how the game plays, the tactical source matched to
the shipped `NAPOLEON.EXE` (a `SOMEDAY.md` row of `study\45`), and joining the two programs into one. Each of
these is a `TODO.md` row if it comes up.

**Effort, in Claude's time.** Steps 1 to 6 are of the size of Civil War Battleset's, about a session. Step 7
is new and the largest: one tool, two small modes of a DOS program written by a Python assembler, a converter,
and 15 sessions to get through two modes. Step 8 is about a session. What costs more than Claude's time:

- **Machine time.** A session takes about 3 minutes in DOSBox-X. Steps 7 and 9 run the 15 sessions in two modes,
  and again whenever the hooks change: about 1.5 hours each time, in the background.
- **The user's time:** this plan, the list of differences of step 7, and the staging of each step.
- **Disk:** the scripted references are about 300 more PNGs, about 6 MB, as the recordings are.

## 8. Risks

- **`RND` may not match.** If QB64's `RANDOMIZE 1#` and `RND` give other numbers than PDS 7.1, the computer
  plays another game in every session. Stage 4 of section 5 then cannot compare anything after the first random
  number. A fallback, to put to the user then: the hook seeds QB64 so that its sequence starts where PDS's
  does, if QB64's `RND` is the same generator with another seeding. If the generator itself differs, the port
  is held to the sessions only up to the first `RND`, and to the QB64pe build after it.
- **Other arithmetic may differ.** The game computes casualties, money and cohesion in SINGLE, with `INT`,
  `CINT` and the rounding of assignment to INTEGER. PDS 7.1 runs SINGLE on the x87 or its emulator; QB64 compiles
  C++. A result that rounds the other way changes a saved game. `CLAUDE.md` working rule 8 says not to build
  QB64Rust to match the machine bit for bit. So each such difference is found with QB64Rust's `--trace-values`,
  written down with its line, and the session keeps a note of it.
- **Trace mode shifts the timing a little.** The hooks add a few instructions at each wait. A key that came near
  the end of a pause in DOS might come just after it, and land at the next wait. The trace check of step 7 shows
  it: the screens differ. Then the key is moved in the converted keys file. The recordings are the reference
  and are not made again without the user's approval.
- **The strategic game waits while the battle runs.** The screen tool ends a run when a `prompt` waits more than
  `QB64_SCREEN_PROMPT_MS`. `play.py` sets it to the run's time limit (section 4). A battle that hangs then takes
  the whole time limit to fail.
- **Two windows.** In normal play the tactical game opens its own window while the strategic window waits. If
  it does not come to the front, the player has to click it. Step 3 checked it with a small parent and child,
  and it does come to the front. Step 4 confirms it with the game's own battle.
- **Row 10, the `GOSUB` routines.** Until the menu's `crsr` is fixed, Quit and then No is expected to stop the
  strategic game. The fix comes in step 5, before the scripts.
- **Row 15, the built-in title.** It draws an ellipse with an aspect of 0.1 and paints inside it. In QB64 the
  paint may leak and cover the title. If it does, the fix is in the program, as in Civil War Strategy: one
  radius or aspect changed, checked by looking.
- **`SHELL "copy ..."` under load.** Civil War Strategy's corpus script `g12_game.files` hangs in its copy of
  the history file late in long runs. Here the copy is done in BASIC under a script, so the scripts do not meet
  it.
- **Windows standby stalls DOSBox-X runs**, as `tools\play\README.md` warns. A stalled run is run again.
