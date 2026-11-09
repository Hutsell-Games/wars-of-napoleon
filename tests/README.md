# Tests

Recorded sessions of the strategic game (`WON.EXE`). Each script in `scripts\` plays the shipped game by
keys, with a fixed random seed and a fixed date. Its screenshots and the files the game wrote are kept in
`recorded\<name>\`, with `manifest.txt` listing the SHA-256 of each one. The recovered source must play every
session the same way (step 6 of `docs\won-source-study.md`), and later the QB64Rust port must too.

The harness, how to run it, and the script format are in `tools\play\README.md`. In short, from the repo's
folder:

```
python -I tools/play/play.py check tests/scripts/*.keys
```

`tests\out\` holds what each run writes. Git ignores it.

`sessions\` holds the same 15 sessions as announce-driven keys files, for the scripted port (step 7a of
`docs\port-study.md`). `tools\play\sessions.py` writes them from the trace runs of the port's PDS 7.1 build. Do
not edit them by hand. How they are made is in `tools\play\README.md`, "Trace mode and the announce-driven keys
files".

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
a neutral port that is open to invasion. The exile needs Napoleon's own army to be crushed in battle, or
beaten with no friendly city to retreat to.

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
