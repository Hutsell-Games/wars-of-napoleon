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

`--port WON.EXE` plays a PDS 7.1 build of the port, made by `tools\pdsbuild.py`, in its trace mode. The build
seeds itself, so it is not patched: the autoexec sets `WON_SEED` (the script's seed) and `WON_TRACE=1`. The run's
folder also gets `ARCH2.EXE`, `VIC.EXE`, `NAPIC.EXE` and `NAPOLEON.EXE` from git (`7738434`), as the recordings
had them (`docs\port-study.md`, step 7). So a QB64 build of the port in the repo's folder does not change the run.

With `--port`, `PLAYKEYS.COM` also runs in trace mode (below), and the run's folder gets `trace.json`, its log.
`sessions.py` turns that log into the keys file of `tests\sessions\` (below).

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

## Trace mode and the announce-driven keys files

This is step 7a of `docs\port-study.md`. The port announces each wait for a key in the BIOS's
intra-application area: `0:4F0h` counts the waits, and `0:4F1h` and `0:4F2h` hold the place and letter
(`SCRIPT.BM`, `announce`). In trace mode, `PLAYKEYS.COM` logs three things:

- at each timer tick where the count changed, a sample: the tick, the total of waits so far, the place and
  the letter. The total is 16 bits. The game can announce up to 8 waits in one tick, so a sample holds only
  the last of them;
- each key it types and each screenshot, with the total at that moment;
- each key a program reads. `PLAYKEYS.COM` also hooks INT 16h, and logs each read (AH = 00h or 10h) after
  it returns: the key, the buffer slot it came from, and the PSP of the program that read it. DOS reads the
  keyboard through INT 16h too, so `INKEY$` and `INPUT` both show.

The log is kept in the part of the key buffer that `KEYS.BIN` does not fill. So the program stays resident
with the same number of paragraphs as the plain `PLAYKEYS.COM`, and the game loads at the same address as in
the recordings. The plain mode is byte for byte the program that made the recordings. DOSBox-X maps the
guest's memory to `MEMORY.BIN` in the run's folder (`memory file=`). After the run, `play.py` finds the log
there by its magic `PKTRACE1`, writes `trace.json`, and deletes the 16 MB file.

`sessions.py` reads `trace.json` and writes `tests\sessions\<name>.keys` in the format of QB64Rust's screen
tool:

```
python -I tools/play/play.py check --port <PDS build>\WON.EXE tests/scripts/*.keys
python -I tools/play/sessions.py tests/scripts/*.keys
python -I tools/play/sessions.py --check tests/scripts/*.keys    # exit 1 if a file would change
```

Each wait the strategic game announced becomes a `prompt`. The wait's keys follow it. A pause that read no
key gets `key space`, which a scripted `TICK` waits for and throws away (D2). Each screenshot becomes a
`state` after the prompt of the wait at which DOS took it. The file leaves out the keys read by the other
programs (told apart by their PSP) and their screens (told apart by their video mode). It also leaves out the
shots named `dos`. The file's header lists all of these. It also lists the keys that were typed before their
wait was announced, and every finding that step 7b must look at. `sessions.py` prints the same findings.

**Known limit: the four `PEEK(1052) = 30` checks of naval combat** (`WON2.BM` lines 1024 to 1091). Each one
guards a `TICK`. It reads the buffer's tail, which every key typed moves on and only `BuffClear` sets back to
30. So it asks whether a key was typed since the last `BuffClear`, not whether one is waiting. A scripted run
types `key space` for each pause, which DOS never typed, and a key typed ahead in DOS comes later. Either can
make a check skip a `TICK` that DOS ran, so that every later prompt is answered one wait off. Step 7b settles
this (`docs\devnotes.md`, "Step 7a").

## Hold mode and the battles of the tactical game

This is step 7b of `docs\port-study.md`, the references of D3. The tactical game has no recording from its
source, so its scripts cannot be timed keys. `--napoleon` plays a PDS 7.1 build of the tactical game
(`tools\pdsbuild.py --game napoleon`) alone, from the keys files of `tests\battles\`:

```
python -I tools/pdsbuild.py --game napoleon tests/out/pds-napoleon
python -I tools/play/play.py record --napoleon tests/out/pds-napoleon/NAPOLEON.EXE tests/battles/*.keys
python -I tools/play/play.py font      # DOSBox-X's 8 x 14 font, for tests/play.py tactical
```

A battle's keys file is in the format of QB64Rust's screen tool (`tools\screen\README.md` there, "The keys
file"), so the same file plays the QB64 builds (`tests\play.py tactical`). `PLAYKEYS.COM` runs in hold mode,
which plays these steps in DOS:

| Step | In hold mode |
|---|---|
| `key NAME`, `text CHARS` | each key waits until the BIOS keyboard buffer is empty |
| `prompt` | waits until the game announces its next wait |
| `state` | a screenshot, named by a `# shot NAME` line before it; the next step waits 4 ticks |
| `rule PLACE[:LETTER] KEYS` | from now on, `play until` answers a wait at that place with these keys |
| `play until PLACE[:LETTER]` | answers each wait by its rule until one at that place, which counts as a prompt |
| `repeat N` … `end` | unrolled by the harness |

The first key of a rule answers the wait; its other keys go one by one to the waits that follow, before any rule
is looked at, as in the screen tool. A wait that no rule answers, or a second wait that no step took, fails the
script: `PLAYKEYS.COM` logs the reason, takes a screenshot and stops the machine. The harness reads the guest's
memory file while DOSBox-X runs, so it sees the failure at once and prints the reason, with the screen in
`shots\fail.png`.

A battle's `BATTLE.$$$` is the file `<name>.battle` beside its keys file, and `# seed N (NAP_SEED)` gives its
seed. The run's folder has no `OUTCOME.&&&`, so the one at the end is the battle's. Each battle ends at
`scriptend` (`NAPSCRIPT.BM`): before each `SYSTEM`, the game announces a wait at place 7 and waits for a key.
The PDS runtime goes back to text mode at `SYSTEM`, so this is where the last screen can be taken. A script
ends with `play until 7`, a `state` and a key. After the game, `ENDMARK.COM` announces a wait at place 255, so
a script that missed the end fails at once. A run stops after 900 seconds.

The places of the tactical game's waits are listed in `NAPSCRIPT.BM`.

**`scriptend` waits in every scripted battle, also one that the strategic game starts.** Under a script,
`scriptbattle` (`SCRIPT.BM`) runs the tactical game with the keys file `<keys>.battle<n>`. That file must end
with a key at place 7, after `play until 7`. Without it the tactical game waits there for ever. `won.exe`
waits for it, until its own screen tool gives up after 30 seconds and ends it with exit code 124. Nothing ends
`napoleon.exe`: it is likely left running on the hidden desktop, where no one sees it. So if `won.exe` ends with
124 after a battle, look for a `napoleon.exe` in the task list and stop it. D4's second run of session 9 in step
8 is the first such run.

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
| `playkeys.py` | `PLAYKEYS.COM` (written by a small assembler in the file), its trace and hold modes and the key file formats, and `FONTDUMP.COM` |
| `sessions.py` | writes the announce-driven keys files of `tests\sessions\` from the trace runs |
