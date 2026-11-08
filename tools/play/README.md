# The play harness

These scripts play the strategic game (`WON.EXE`) by script, in a DOSBox-X that no one sees, and record its
screens and the files it writes. They are step 2 of `docs\won-source-study.md`. The recordings are what the
recovered source must reproduce (step 6), and later the QB64Rust port.

## What it needs

- Python 3. Nothing else from PyPI.
- DOSBox-X 2026.10.01, the portable 64-bit build (`dosbox-x-vsbuild-win64-2026.10.01-portable.zip`), unpacked
  into `..\won-hutsellgames\dosbox-x\` beside this repo (decision D5 of the study). `--dosbox PATH` names
  another copy. The version and the start of `dosbox-x.exe`'s SHA-256 are written into each recording's
  `manifest.txt`. Another build may write other PNG bytes for the same screen, so record and check with the
  same one.
- Git: the game's files are the ones git tracks (below).

## Running it

From the repo's folder:

```
python -I tools/play/play.py run tests/scripts/01-1796-french.keys     # one run; everything in tests/out/<name>/
python -I tools/play/play.py record tests/scripts/01-1796-french.keys  # two runs that must agree; kept in tests/recorded/<name>/
python -I tools/play/play.py check tests/scripts/01-1796-french.keys   # one run, compared with the recording
```

`run` is for writing a script: add a few keys and a `shot`, run, and look at the last PNG in
`tests\out\<name>\shots\`. `record` plays the script twice and refuses to record unless both runs give the
same screens and files. `check` plays it once and lists every screen or file that differs. `--exe` plays
another build of `WON.EXE`. A build other than the shipped one also needs `--timr` and `--rnzp`: the
addresses of `B$TIMR` and `B$RNZP` in its load image, from `tools\recover\runtimemap.py`; the two go
together.

On the branch `qb64rust`, a build of the port in the repo's folder overwrites `WON.EXE` and `NAPOLEON.EXE`,
and `ARCH2.EXE`, `VIC.EXE` and `NAPIC.EXE` are not there (`docs\devnotes.md`, step 5). To replay with the
shipped programs, run the harness in a worktree of `main`, which has all five: `git worktree add
..\won-main main`, then the commands above from that folder. Once the branch is merged into `main`, use the
commit `7738434` instead of `main`.

Session 1 has 320 seconds of play, and a run takes about 3 minutes.

A run stops after 120 seconds plus three times its play time, with the shots it has. If Windows goes into
standby during a run, DOSBox-X hardly runs, and the run ends that way with few or no shots. Run it again
with the computer awake.

## How a run works

1. A new folder, `tests\out\<name>\game\`, gets the game's files from the repo's folder: every file git
   tracks there, except the sources, documents and build files. Untracked files are left out. A save left by
   playing the game in the repo's folder would otherwise enable the start menu's Load, and change every
   screen after it. A tracked file with local changes is used as it is, with a warning.
2. `wonseed.py` writes `WONSEED.EXE`: the unpacked `WON.EXE`, with `RANDOMIZE TIMER` (`WON.BAS` line 78)
   replaced by `RANDOMIZE <seed>`. It changes 20 bytes of code and removes one relocation entry, and checks
   that nothing else changed. So the computer player and the random events are the same in every run.
3. `playkeys.py` writes `PLAYKEYS.COM`, a resident DOS program of 326 bytes, and the key file `KEYS.BIN`.
   `PLAYKEYS.COM` hooks the timer interrupt. At each point of the script it either puts a key in the BIOS
   keyboard buffer, as if it had been typed, or asks DOSBox-X for a screenshot through DOSBox-X's
   integration device. In the tick of the last screenshot it stops the emulated machine for good
   (`cli / hlt`). DOSBox-X still draws the screen, so that screenshot is saved, but the game runs no
   further. So the files the harness keeps are the same in every run, however long the host takes to stop
   DOSBox-X. This is why a script must end with a `shot`.
4. DOSBox-X starts with `-silent` and SDL's dummy video driver, so no window opens. The configuration sets:
   - fixed CPU cycles, and turbo, so it runs as fast as the host can;
   - no time synchronization with the host, and a fixed date and time (06/24/1998, 12:00:00). The game
     writes the date into `NWS.HIS`, so a recording would otherwise hold the day it was made. DOSBox-X's
     `DATE` command needs slashes; given dashes it keeps the host's date without a word. So the autoexec
     writes `date /t` to `RUNDATE.TXT`, and the harness refuses a run whose date is not 06/24/1998;
   - no serial ports, network card or debugger port, so nothing listens on the network.
   The autoexec loads `PLAYKEYS.COM` and starts `WONSEED.EXE`. The programs the game starts (`ARCH2.EXE`,
   `NAPOLEON.EXE`, `VIC.EXE`, `COPY`) are DOS programs inside DOSBox-X, so no console window opens on the host.
   After the game, the autoexec runs `IDLE.COM` (`sti / hlt / jmp`), which waits forever. Without it,
   `-silent` would end DOSBox-X as soon as the game quits, before a last shot of what it left on the screen.
5. When the last screenshot has been written, the harness stops DOSBox-X. It copies the screenshots to
   `shots\NN-name.png`, and every file the game wrote or changed to `files\`.

Why it is repeatable: the keys and screenshots come at fixed timer ticks, which count emulated time, not the
host's. With fixed cycles, each key reaches the game at the same instruction in every run. The game's own
pauses read `TIMER`, which is emulated time too. Two runs of session 1, including the computer's turns,
give the same 49 screens and the same 4 files.

DOSBox-X's own `AUTOTYPE` command was tried first and dropped. DOS cuts a command line at 127 characters,
which is a dozen keys, and its timing follows the host's clock.

## Script format

One command per line. `#` starts a comment, except in a `type` line.

| Command | Meaning |
|---|---|
| `seed N` | the `RANDOMIZE` value (default 1) |
| `cycles N` | fixed CPU cycles (default 20000) |
| `pace S` | seconds of emulated time before each key or shot (default 0.5) |
| `wait S` | extra seconds before the next key or shot |
| `key NAME...` | keys by name: `enter esc space tab bksp up down left right home end pgup pgdn ins del f1`–`f12`, a letter or digit, a punctuation name (`comma period slash semicolon quote minus equals lbracket rbracket backslash grave`), or `shift-NAME` for its shifted character |
| `type TEXT` | each character of the rest of the line, as keys |
| `shot NAME` | a screenshot, saved as `NN-NAME.png` |
| `repeat N` … `end` | the lines between, N times; blocks may nest |

A script must end with a `shot`, with no `wait` after it: the machine stops there, so a later key or wait
could not happen. A wait may not be longer than 65,535 timer ticks
(about an hour).

The BIOS keyboard buffer holds 15 keys. A key typed while it is full is dropped, without a message. Scripts
wait between keys, so this does not happen in practice; if a script ever types many keys while the game is
busy, a dropped key shows as a wrong screen in the next shot.

## What the game does with keys

Learned while writing session 1:

- A menu takes the first letter of an item, or arrows and Enter. Esc leaves it. Keys that match nothing are
  ignored, so `space` is a safe key for closing a message.
- A message box or a report page waits for any key. "press a key" pages are `TICK(99)`.
- Some pages step on their own and let a key skip ahead. Intelligence shows each army for a second, so a
  script waits about 6 seconds there; an early key would skip an army, and the next keys would land
  somewhere else.
- Most UTILITY items act at once instead of opening a list: History toggles, Aggress steps to the next level,
  and item 1 (the side's name) swaps sides. Since item 1 is the side's name, `u a` swaps sides when the
  player is the Allies, and changes Aggress when the player is the French.
- The end of each month autosaves to `NWS9.SAV` and rewrites `NWS.CFG`.

Learned while writing sessions 3 to 15:

- **A beaten army of the human's side may ask where to retreat.** The menu comes up when the army has two
  or more friendly cities next to it, also in the middle of the computer's turn. It ignores spaces, so a
  script that closes messages with spaces stalls there, and its later keys land in the wrong place.
- **Esc is the safe key for closing a turn's messages.** It closes a message box and matches no item of the
  main menu. At a retreat menu it lets the game choose the retreat, as it does for the computer.
- **At the End Game prompt Esc means No-Override.** An override gives the other side 300 VP and turns that end
  condition off until End Cond turns it on again. A script that wants the game to end answers `y` there.
- **A turn's number of messages varies.** A script that ends a turn and then types a fixed handful of keys can
  run past the main menu into the next turn. Sessions 4 to 8 and 10 to 14 end each turn with `e y`, wait 30 seconds, then type
  16 Esc (or space) keys 2 seconds apart.
- **In the tactical game (`NAPOLEON.EXE`) a space orders the current unit to rest.** No key is typed until
  its battle map is up. F9 is the strategic retreat; the game then asks "RETREAT?", and `y` ends the battle.

## Files

| File | What it is |
|---|---|
| `play.py` | the harness: `run`, `record`, `check` |
| `wonseed.py` | makes `WONSEED.EXE`; also a command (`wonseed.py WON.EXE OUT.EXE --seed N`) |
| `playkeys.py` | `PLAYKEYS.COM` (written by a small assembler in the file) and the key file format |
