# Tests

The port's tests play the game from keys files and compare what it shows and writes. Two references hold it:

- **The DOSBox-X recordings** (`recorded\<name>\`): 15 sessions of the shipped `WON.EXE` and six battles of the
  port's tactical game built with PDS 7.1. Each holds its screenshots and the files the game wrote, with
  `manifest.txt` listing the SHA-256 of each. They show what the game did in DOS.
- **The port's own references** (`<keys>.screen`, beside each keys file): what the QB64 builds show and write,
  recorded twice with QB64Rust and twice with QB64pe. They catch any change of the port's behavior.

Three more kinds of test need no recording: the unit tests of the game's SUBs (`rules_test.bas`,
`battle_test.bas`), the tests of the Python tools (`test_play.py`), and coverage.

## Running them

From the repo's folder, with QB64Rust's repo beside it (`..\QB64Rust`, built in release) and QB64pe beside that
(`..\QB64pe\qb64pe.exe`):

```
python -I tests/play.py check                  # every script with the QB64Rust build, against its reference
python -I tests/play.py check 0*               # the sessions only (a name, or a pattern)
python -I tests/play.py compare                # the QB64Rust and QB64pe builds against each other
python -I tests/play.py record [script ...]    # both builds, twice each; writes <keys>.screen
python -I tests/play.py bridge [--compiler rust|pe|both]     # the sessions against the DOS recordings
python -I tests/play.py tactical [--compiler rust|pe|both]   # the battles against the DOS recordings
python -I tests/play.py coverage               # the lines and SUBs that the scripts and unit tests reach
python -I tests/play.py explore <keys file>    # one run, a PNG of every screen; for writing a script
python -I tests/make_scripts.py                # writes the generated games again (below)
qb64rust test tests                            # the unit tests
python -I -m unittest discover -s tests -p "test_*.py"   # the tests of the Python tools
```

`--jobs N` sets how many runs go at once (default 4). Each run starts in a fresh copy of the game's files in
`tests\out\qb64\run\`, on a desktop of its own that is never shown, so your keys and mouse cannot reach it. A
build is made again only when a source file, the compiler or the screen hook changed. What a command prints also
goes to `tests\out\qb64\last-<command>.txt`. Git ignores `tests\out\`.

The scripts use QB64Rust's screen tool, a C++ file linked into the program. It gives the program keys from a
file, at the waits the program announces, and writes the screen out where the file asks. Its manual is QB64Rust's
`tools\screen\README.md`. The places and letters of the waits are listed in `SCRIPT.BM` and `NAPSCRIPT.BM`.

## The scripts

| Folder | What a script plays | Its run ends |
|---|---|---|
| `sessions\` | One of the 15 sessions, as an announce-driven keys file (step 7a of `docs\port-study.md`). `tools\play\sessions.py` writes them from the trace runs of the port's PDS 7.1 build; do not edit them by hand | When the state of its last shot is written: the run is stopped there |
| `sessions\`, `09-1805-tactical-battle` | Session 9 once more, with the port's tactical game (D4 of the plan): the strategic game starts `napoleon.exe`, which plays `battles\b1-innsbruck-retreat.keys`. It has no keys file of its own; `play.py` makes it from session 9's | As the session |
| `battles\` | The tactical game alone, from `<name>.battle` as its `BATTLE.$$$` | When the game exits |
| `games\` | The strategic game from its start to its end: the generated games and the hand-written ones | When the game exits |

A game's `#!` lines set up its run: `#! seed N`, `#! timeout SECONDS`, `#! battle KEYS` (the keys of the next
battle the strategic game starts; without one, no battle starts) and `#! save FILE AS` (a file of `tests\data\`
copied into the run's folder). `play.py`'s docstring has the details. Every run starts with the files of
`tests\data\` in its folder: `NWS9.SAV`, the saved game that came with the game.

A reference holds one line per entry of the run: each state as its digest, then each state of a battle the
strategic game started, then `file NAME HASH` for each file the run wrote or changed. `check` fails at the first
entry that differs and names it.

## Against DOS: bridge and tactical

`bridge` plays the sessions and `tactical` the battles, and holds each run to its DOSBox-X recording through
`dosshot.py`:

- **Graphics screens** (`SCREEN 12` and `SCREEN 9`) are compared pixel by pixel. In `SCREEN 9` a cell of 8 × 14
  pixels counts as equal when one character, drawn with each side's own font, explains it: QB64 has no 8 × 14
  font of DOS's (Q-023). DOSBox-X's font is `recorded\dosbox-x-font-8x14.bin` (`tools\play\play.py font`),
  QB64's comes from `font9.bas`.
- **Text screens** (`SCREEN 0`) are drawn as DOSBox-X saves them, 720 × 400 with cells 9 pixels wide, with QB64's
  8 × 16 font from `font12.bas`, which is DOSBox-X's pixel for pixel.
- **Files**: each file the recording's run wrote, byte for byte, and no file that it did not write. `OUTCOME.&&&` is compared by value: PDS 7.1
  writes a DOUBLE with 15 digits, QB64 with 16.

**`known-differences.txt`** lists every difference from DOS that is known and explained, and each run leaves
those out. Most are how QB64 draws small circles and sloped lines (QB64Rust's `DIVERGENCES-QB45.md` Q-025 and
Q-036), on every map: the city markers, the ships, an army's pointer. Others are D12's rounding (Q-022) and one shot
that DOS took where the port has no wait. A run of every
session or battle says when a line is no longer met, so the list stays true. For each shot that still differs,
`tests\out\qb64\run\<name>-<compiler>\diff\` gets a picture: the recorded screen dimmed, the pixels that differ
in magenta. With `--compiler both`, the two builds' runs are also held to each other.

## Generated games

`make_scripts.py` writes `games\end-<year>-<side>.keys`: each of the seven scenarios, as each side, Tactical off,
the player only ending turns until the game ends. So the computer plays the other side to the end of every
scenario, which the sessions do in only a few. A digest at the main menu of each turn shows where a difference
starts. The tool plays each game first to count its turns. Run it again only when a change of the game is meant
to change how its games go, then record.

## Hand-written scripts

| Script | What it plays |
|---|---|
| `games\invasion-1796-french` | 1796 as the French. The fleet sails to Amsterdam, a neutral port of a minor nation; in the next turn the Ships menu offers Invasion, which places a new army there. Then the player only ends turns to the game's end |
| `battles\b6-innsbruck-stalemate` | Session 9's battle with the French cut to one unit of 500 men. The time runs out while neither side holds the field, so `expire` calls `over(3)`. DOS wrote 3 as the winner, which gives the battle to the defender, and the port now does too (`docs\devnotes.md`, step 8) |

**Not reached by any script yet:** Napoleon's exile, and a battle won by wiping out the other side
(`scriptend("W")`). `TODO.md` says what each needs.

## Unit tests

`rules_test.bas` (the strategic game) and `battle_test.bas` (the tactical game) call SUBs that draw nothing and
record what they give today. They cover only what the scripts cannot show: `bubble` with equal names and with a
list of one, `Compact` with a side that has no unit left, and the lean of `normal`, whose results come out half a
standard deviation above the mean.

## The battles

| Battle | What it plays |
|---|---|
| `b1-innsbruck-retreat` | Session 9's battle at Innsbruck, the Allies defending. F9 and Yes at the first order |
| `b2-innsbruck-defend` | The same battle. Every Allied unit rests to the time limit, while the French attack |
| `b3-waterloo-attack` | The `BATTLE.$$$` the game ships: Waterloo, the French player resting to the time limit |
| `b4-innsbruck-advance` | Session 9's battle, the French player attacking: each unit steps south, then rests |
| `b5-innsbruck-quit` | Session 9's battle, the Allies defending. Intell at the first order, then F10, which quits and writes no `OUTCOME.&&&` |
| `b6-innsbruck-stalemate` | Session 9's battle with one French unit of 500 men. Every Allied unit rests until the time is up, with neither side holding the field: `over(3)` |

## The sessions

The sessions were recorded from the shipped game. Each script in `scripts\` plays `WON.EXE` by keys at fixed
times, with a fixed random seed and a fixed date. The harness, how to run it, and the script format are in
`tools\play\README.md`:

```
python -I tools/play/play.py check tests/scripts/*.keys
```

| Session | What it covers |
|---|---|
| `01-1796-french` | 1796 as the French, Tactical off. The intro, the start menu, every menu and page once, Recruit, Moves, Fortify, Files → Save, and two turn ends with the Allies' moves. |
| `02-1796-allies` | 1796 as the Allies (the shipped settings), Tactical off. The Allies only end turns. France takes its objective in the third turn. The game ends with the Battle Summary, the Hall of Fame and "Game Over", and the session quits to DOS. |
| `03-1805-two-players` | 1805, two players, Tactical off. The French move from Stuttgart, then the "ALLIES PLAYER TURN" hand-over screen. The Allies recruit and move from Innsbruck and win at Milan. The French player chooses Bernadotte's retreat. A second month shows the two-player Utility menu, which has no Aggress item. |
| `04-1807` | 1807 (starts October 1806) as the Allies, Tactical off. The end conditions and the force summary. The Allies only end turns. In September 1807 the player chooses Hohenlohe's retreat. France takes Friedland, the Allies' objective; the player overrides the end. In July 1808 time runs out; the game ends, and France's 620 VP enter the Hall of Fame as COMPUTER. Quits to DOS. |
| `05-1808` | 1808 as the Allies, Tactical off. The start screens, one retreat chosen by the player, and the end when time runs out in November 1809. Quits to DOS. |
| `06-1812` | 1812 as the Allies, Tactical off. The objective, end conditions, force summary and Allied armies, then three turns. |
| `07-1813` | 1813 as the Allies, Tactical off. The same screens as session 6, then three turns. |
| `08-1815` | 1815 as the Allies, Tactical off. The start screens, a retreat chosen by the player in the first turn, and the end when time runs out in September 1815. Quits to DOS. |
| `09-1805-tactical` | 1805 as the Allies with the shipped Tactical on. Bernadotte attacks Alexander in Innsbruck at odds within 3:1, so `WON.EXE` writes `BATTLE.$$$` and runs `NAPOLEON.EXE` (which shows `NAPIC.EXE`'s picture). The Allies rest one unit, then take F9, the strategic retreat. `WON.EXE` reads `OUTCOME.&&&` back: "Bernadotte is VICTORIOUS in Innsbruck". |
| `10-1805-events-vary` | 1805 as the Allies, Tactical off, in two games. The first sets random events to Neutral and plays three turns, with four retreats chosen by the player. Files → New Game starts the second, which takes Vary Start and plays two turns. |
| `11-1812-aggression` | 1812 as the French, Tactical off. The computer plays the Allies at aggression PASSIVE (0) for two turns, then RECKLESS (5) for two. |
| `12-1796-balance` | 1796 as the Allies, Tactical off, in two games. The first plays two turns at balance French ++, the second (after Files → New Game) two turns at Allied ++. Each shows the funds on the Recruit screen. |
| `13-1796-save-load` | 1796 as the Allies, Tactical off. Recruit, then Files → Save to `NWS1.SAV`, and two turns (the monthly autosave writes `NWS9.SAV`). Files → New Game, then Resume Saved Game loads `NWS1.SAV`; Files → Load loads `NWS9.SAV`. Files → Quit to DOS. |
| `14-1796-naval` | 1796 as the French, Tactical off. Ships: Build, then Sail to London, where the English fleet is. Three rounds of naval combat, then Retreat. In the second turn the fleet goes to raid Allied commerce; two more turns. |
| `15-1815-high-score` | 1815, two players, Tactical off. Both sides only end turns. In September 1815 time runs out and the players override, which gives the Allies 300 VP. The French player turns the time condition on again in End Cond, and the game ends when November's turn ends. The Allies' 300 is a new high score: the Hall of Fame, `VIC.EXE`'s picture, the name prompt ("Wellington"), and quit to DOS. |

Sessions 6, 7 and 11 to 15 close messages with Esc rather than space. Esc closes a message, matches no item
of the main menu, and answers a retreat menu by letting the game choose. At the End Game prompt Esc means No-Override, so a session
that ends a game answers that prompt with a letter.

**Not reached by any session:** a naval invasion, and Napoleon's exile ("Napoleon removed to Corsica", or
"Napoleon banished to St. Helena" when Corsica is occupied). An invasion needs a fleet of two or more ships at
a neutral port that is open to invasion; `games\invasion-1796-french` makes one. The exile needs Napoleon's own
army to be crushed in battle, or beaten with no friendly city to retreat to.

**Found while recording:**

- **Vary Start can remove Napoleon's army.** It drops each of the first six French armies with a chance of
  40%. In one game of session 10's drafts that took Napoleon, and the game then offered to end after the first
  turn: "END GAME VICTORY CONDITION 7 REACHED / NAPOLEON UTTERLY DEFEATED". After an override it offered the
  same every turn. The recorded session uses a draw that keeps Napoleon.
- **Overriding the end gives the other side 300 VP and turns that condition off.** Session 15 depends on both.
- **A human's high score overwrites an entry instead of pushing the rest down.** In session 15, the Allies'
  300 enters in place 3. The list then holds 588, 386, 300, 206 and 203: steve's 245, which was in place 3, is
  gone, and the last entry stays. `maxx` (`WON2.BAS`) shifts the lower entries down, then shows the Hall of
  Fame again before asking the name, and that reads the list back from `HISCORE.NWS`, which undoes the shift.
  The computer's entries skip that step, so session 4's COMPUTER 620 pushes the others down as it should.
