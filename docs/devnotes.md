# Developer notes: the QB64Rust port

The port of both programs to QB64Rust and QB64pe, on the branch `qb64rust`. The plan is `docs\port-study.md`.
This file says what each step changed and what it found. Numbered items are the changes to the game's code.

## Step 0: the two measurements (2026-11-07)

Two small programs in QB64Rust's `verification\qb45\`, run with PDS 7.1 and QB 4.5 under DOSBox
(`tools\qb45\qb45.py`), and built with QB64Rust 0.3.0 and QB64pe. Their outputs from the old compilers are recorded
beside them (`.pds71.txt`, `.qb45.txt`).

**`RND` is the same in all four.** `q45_rnd_seeded` writes the bits of each `RND` (as `MKS$`) after `RANDOMIZE
1#`, `RANDOMIZE VAL("1")` and `RANDOMIZE 2#`, then 1,000 numbers after `RANDOMIZE 1#`. PDS 7.1, QB 4.5,
QB64Rust and QB64pe give the same bytes on every line. So the seed the harness gave `WON.EXE` (the DOUBLE 1.0,
`tools\play\wonseed.py`) and the port's hook (`VAL` of `WON_SEED`) start the same sequence.

**Arithmetic differs in two ways** (`q45_long_times_single`; QB64Rust's `DIVERGENCES-QB45.md` Q-021 and Q-022):

- **A SINGLE constant times a LONG is a DOUBLE in the old compilers and a SINGLE in QB64.** `.01 * s&` with
  `s& = 69` is written `.689999984577298` by PDS 7.1, `.6899999845772982` by QB 4.5 and `.69` by QB64. This is
  the line of `OUTCOME.&&&` (`over`, `NAP1A.BAS`). Read back into an INTEGER, all give the same number.
- **A SINGLE constant times an INTEGER, stored in an INTEGER, can round the other way.** `x = .7 * x` gives 115
  in the old compilers and 116 in QB64 for `x = 165`, and 269 against 270 for `x = 385`. The exact product is
  just under a half. The old compilers round it as it is. QB64 first rounds it to a SINGLE, which is exactly a
  half, then rounds the half to the even number. Of 120 values of this kind in the program, these 2 differ.
  `normal`, the game's sum of twelve `RND`s times `SQR`, gave the same 200 results in all four.

The second one is in the game: `WON.BAS` lines 823–824 (`x = .7 * x`, the cohesion penalty), 886–887
(`killa = .8 * killa + .2 * killd`) and many lines of the tactical game. Where it strikes, a battle's losses
differ by one, and every saved game after it differs. It is rare, so most sessions may not meet it.

**Also seen:** PDS 7.1 writes a DOUBLE with 15 digits, QB 4.5 and QB64 with 16 (`9.85714285714286` against
`9.857142857142858`). The game writes no DOUBLE to a file except through the first case above.

## Step 1: the branch (2026-11-07)

`qb64rust`, `main` and `origin/main` are all at `7738434` ("Recover the source of WON.EXE (#3)"), after a
`git fetch`. Nothing in the game's files has changed on the branch. Its only changes so far are this file and
`docs\port-study.md`.

## Step 2: the searches before any edit (2026-11-07)

The sources searched: `WON.BAS`, `WON2.BAS`, `WONMENU.BAS`, `WON.BI` (the strategic game) and `NAPOLEON.BAS`,
`NAP1A.BAS`, `NAP1C.BAS`, `NAP10.BI` (the tactical game). They are in code page 437, which `grep` cannot read, so
a script first wrote each one as UTF-8 with its comments and string literals blanked. Line numbers stayed the
same. Every module starts with `DEFINT A-Z` and nothing else declares a type, so the only LONGs are the names
that end in `&`, and the only SINGLEs are the names that end in `!`, decimal constants, `/` and the functions
that give a SINGLE.

### 1. Names that BASIC PDS 7.1 has and QB64 does not

The names searched for are the list "Popular BASIC PDS 7.1 features" in QB64Rust's `docs\SOMEDAY.md`, the
PDS-only names that list leaves off (ISAM, far strings, `STACK`, `UEVENT`), and the QB 4.5 forms that QB64 lacks
or treats differently (`FRE`, `COMMON`, `SETMEM`, `ERDEV`, `IOCTL`, `INTERRUPT`, `ABSOLUTE`, `SADD`, `PEN`,
`STRIG`, `CHAIN`, `$DYNAMIC`, `$STATIC`). A name ending in `@` (the currency type) was looked for too.

| Name | Where | What the port does |
|---|---|---|
| `DIR$` | 17 calls. Strategic game, 16: `WON.BAS` lines 11, 28, 45, 93, 410, 559, 609, 633, 817, 1067, 1072, 1122; `WON2.BAS` lines 597, 611, 696, 1223. Tactical game, 1: `NAPOLEON.BAS` line 1713 | Civil War Strategy's `FUNCTION DIR$`, in a `QB64.BM` that both programs include (row 4 of the plan) |
| `DIR$` with no argument | 1, `WON2.BAS` line 611 (`f$ = DIR$`, the next scenario file in `getlist`) | Becomes `DIR$("")`. Without that change both compilers read it as a string variable that is always `""`, with no message. That is why the first build found 15 errors in the strategic game for 16 calls |
| `FRE(-1)` | 1, `NAP1C.BAS` line 91, in `menu`: the extended key with code 131 (Alt+=) prints the free memory at the top left | QB64pe has no `FRE`. The line is commented out (row 5 of the plan) |
| `COMMON SHARED` | 13 lines in `WON.BI` (84 to 96), 10 in `NAP10.BI` (72 to 82). No named blocks | Kept: in one program it acts as `DIM SHARED` (Civil War Battleset measured it) |

None of the other names was found: no `CURDIR$`, `CHDRIVE` or `ON LOCAL ERROR`, no currency type, no `BYVAL`, no
`REDIM PRESERVE`, no `FORMAT$` or date and financial functions, no ISAM, no far strings, no `TYPE`, and no
`$DYNAMIC` or `$STATIC`.

### 2. `GOSUB` routines that can leave their SUB before `RETURN`

QB64pe and QB64Rust keep one `GOSUB` stack for the whole program. When a SUB ends while one of its own `GOSUB`
routines is still pending, the routine's entry stays on the stack. A later `RETURN` whose own `GOSUB` was made
before that entry takes it instead, and the program stops with "RETURN without GOSUB" (error 3). QB 4.5 and PDS
7.1 drop the entry when the SUB ends, so the original worked (QB64Rust's `DIVERGENCES-QB45.md` Q-018). An entry
that no `RETURN` ever takes does no harm: libqb grows the stack as needed, 4 bytes an entry.

**How the routines were found.** As in Civil War Battleset: a script built the control flow of each SUB,
statement by statement. It follows `GOTO`, single-line and block `IF`, `SELECT CASE`, `DO`, `WHILE` and `FOR`
loops, `EXIT DO` and `EXIT FOR`, and counts every branch as possibly taken. For each `GOSUB` routine, it looked
for a way from the routine's label to `EXIT SUB` or `END SUB` that passes no `RETURN`. It then listed every call,
direct or through other SUBs, of a SUB that can leave an entry, made while a routine is pending. Each place it
named was read by hand. The sources have no `ON … GOSUB` and no `RETURN` with a label.

**The counts.** The `GOSUB` statements inside SUBs are 34 in the strategic game (8 in `WON.BAS`, 19 in `WON2.BAS`,
7 in `WONMENU.BAS`) and 83 in the tactical game (55 in `NAPOLEON.BAS`, 18 in `NAP1A.BAS`, 10 in `NAP1C.BAS`). The
plan's row 10 said 73 for the tactical game; its own three numbers add to 83. They go to 51 routines:

- Strategic, 19: `filer` 1, `recruit` 3, `tupdate` 1 (`WON.BAS`); `init` 1, `maxx` 1, `navy` 6, `roman` 1,
  `shipicon` 1, `smarts` 1 (`WON2.BAS`); `menu` 3 (`WONMENU.BAS`).
- Tactical, 32: `order` 15, `randarm` 2, `randmap` 4 (`NAPOLEON.BAS`); `general` 1, `report` 2, `retreat` 1,
  `scrcol` 1, `victory` 2 (`NAP1A.BAS`); `menu` 4 (`NAP1C.BAS`).

Six of them can leave their SUB:

| Routine | SUB | How it leaves | When |
|---|---|---|---|
| `crsr` | `menu` (`WONMENU.BAS` line 241) | `GOTO called`, which runs on to `END SUB`: on Esc (line 245), on an entry's first letter (249), on any key when `switch` is 3 (244), on F4 and F1 (lines 254 and 259: the forces report and the hot keys box), and on F7 when `switch` is 0 (285) | At any menu of the strategic game. Enter and the arrow keys return normally |
| `getlist` | `init` (`WON2.BAS` line 604) | `EXIT SUB` when there is no scenario file (606), when the menu is left with Esc (621), or when the chosen name is empty (623) | At "Start Year", the first menu of a new game |
| `crsr` | `menu` (`NAP1C.BAS` line 68) | `GOTO called`: on the space bar (line 71), Esc (74) and an entry's first letter (79) | At any menu of the tactical game |
| `otherside` | `order` (`NAPOLEON.BAS` line 907) | `GOTO asleep` (lines 917, 922, 925, 936), back into `order`'s loop over the units | Each time a computer unit in square (`S`) moves, or a computer infantry unit forms square. Every such move leaves one more entry |
| `wait5` | `order` (`NAPOLEON.BAS` line 1009) | `EXIT SUB` on F10 (line 1024), which ends the battle without `OUTCOME.&&&` | When the player quits the battle |
| `eval` | `general` (`NAP1A.BAS` line 455) | `GOTO improve` (line 460), which runs on to `END SUB` | When a square beside a computer unit holds terrain 35, 42, 94 or 239. `general` is the computer's choice of a move |

**Where a stale entry is taken.** Three places, each a `RETURN` that the game reaches after one of the routines
above has left an entry:

- **Strategic: `getlist`'s `RETURN` (`WON2.BAS` line 624).** `getlist` calls `menu` (line 620). A start year
  chosen by its first letter leaves `crsr`'s entry. `choose` is then above 0, so `getlist` goes on to its
  `RETURN`, which takes the stale entry. Expected: "RETURN without GOSUB" when the start year is chosen by a key
  and not by Enter. This is World War 2's case (its `docs\devnotes.md`, items 11 and 12).
- **Tactical: `otherside`'s `RETURN` after `general` (`NAPOLEON.BAS` lines 959 to 966).** When `eval` leaves,
  `otherside`'s `RETURN` takes its entry. Expected: "RETURN without GOSUB" during the computer's move, whenever a
  computer unit stands next to such terrain. This is Civil War Battleset's case (its `docs\devnotes.md`, item 9),
  in the same SUBs of the same author.
- **Tactical: `otherside`'s `RETURN` after `cupdate` (lines 954 to 956, and 962 to 966).** `cupdate` moves the
  computer's unit through `placeunit`. When it meets the player's unit, `combat` runs `musket`, and `musket` can
  call `pursue` for the defender (line 641). The defender is then the player's unit, so `pursue` asks "Pursue ?"
  with `YesNo`, which calls `menu`. Answered with Y, N or Esc, `menu` leaves `crsr`'s entry, and `otherside`'s
  `RETURN` takes it. Answered with Enter, nothing happens. The other menus on this path are the player's own:
  `combat` shows its menu only for the player's attack (line 118), `placeunit`'s "Stack Units" only for the
  player's unit, and `otherside` calls `limbo` with 0, which skips its menu.

Everywhere else the entries left are never taken. `menu` leaves one at most menus of both games, `otherside`
one for each square, but each later `RETURN` in those places belongs to a `GOSUB` made after them. The main
modules' own routines (4 in `WON.BAS` with 9 `GOSUB`s, 1 in `NAPOLEON.BAS`) call no SUB that leaves an entry
while they are pending.

The fix is the earlier ports': the routine sets a flag and `RETURN`s, and the line after the `GOSUB` jumps. It
is step 5. The first builds in step 4 should show the first two cases.

### 3. Memory, `BLOAD`, `SHELL` and `END`

What each one did in DOS:

| Statement | Where | What it did in DOS | What the port does |
|---|---|---|---|
| `DEF SEG = VARSEG(mtn(1))`, `BLOAD "mtn.vga", VARPTR(mtn(1))`, `DEF SEG` | `WON.BAS` lines 46 to 48 (main module), `WONMENU.BAS` lines 131 to 133 (`europe`, the map) | Loaded the mountain picture, saved by `BSAVE`, into an array as a `GET` array. `PUT` then drew it | Expected to work unchanged: Civil War Strategy's `MTN.VGA` loads the same way (row 11) |
| The same with `graphic(1)` and `napicon.vga` | `WON.BAS` lines 53 to 55 | The same, for the army and navy icons | As the row above |
| The same with `Image(1)` and `stdicon.ega`, `alticon.ega`, `terrain.ega`, `misc.ega` | `iconload`, `NAPOLEON.BAS` lines 361 to 363, 378 to 380, 395 to 397, 410 to 412 | The same, for the tactical game's icon sets | Expected to work unchanged: Civil War Battleset loads the same four files |
| `DEF SEG = 0`, `POKE 1050, 30: POKE 1052, 30` | `BuffClear`: `WON2.BAS` lines 60 and 61, `NAP1A.BAS` lines 66 and 67 | Set the head and the tail of the BIOS keyboard buffer to its start, which threw away the keys typed ahead. It leaves `DEF SEG` at 0 | Kept: libqb emulates the buffer (Civil War Battleset measured it) |
| `PEEK(1052) = 30` | `navy`, `WON2.BAS` lines 1024, 1034, 1055, 1091 | True when no key was waiting. Then the sea battle played its sound, showed its icon or paused. It reads segment 0 because `BuffClear` runs at line 1019, after the last `europe`, and nothing in between changes `DEF SEG` | Kept. Under a script no key waits at these lines, so they always pause (section 5 of the plan) |
| `SHELL "arch2.exe"` | `WON.BAS` line 11 | Showed the intro picture, when `ARCH2.EXE` existed and there was no command line | Nothing runs: `ARCH2.EXE` leaves the folder (D6) |
| `SHELL "rrs.exe"` | `WON.BAS` lines 93 and 609, on quitting | Ran the registration reminder, when `RRS.EXE` existed. It is not in the repo | Nothing runs |
| `SHELL "copy nws.his oldhist.ory"` | `WON.BAS` line 633 | Kept a copy of the history file | Under a script, copied in BASIC by `scriptshell`; in normal play the `SHELL` as before (row 8) |
| `SHELL "napoleon.exe"` | `battle`, `WON.BAS` line 831 | Ran the tactical game. `WON.EXE` then read `OUTCOME.&&&` | Kept as it is (D5, decided again after step 3), with the script's own files under a script (row 7) |
| `SHELL "vic.exe"` | `maxx`, `WON2.BAS` line 696 | Showed the victory picture after a new high score, when `VIC.EXE` existed | Nothing runs: `VIC.EXE` leaves the folder (D6) |
| `END` | `WON.BAS` line 94 ("Quit to DOS" at the start menu) and line 610 ("Quit", Yes) | Ended the strategic game, back to DOS | Kept, as in the earlier ports (row 6) |
| `END` | `NAPOLEON.BAS` line 107, after `order` sets `file$` for F10 | Ended the tactical game without writing `OUTCOME.&&&`. `WON.EXE` then read the file of the battle before | `SYSTEM` (row 6), so that `won.exe` does not wait for a key in the tactical window |
| `END` | `over`, `NAP1A.BAS` line 677, after writing `OUTCOME.&&&` | Ended the tactical game. This is the normal end of a battle | `SYSTEM` (row 6) |
| `END` | `wipeout`, `NAP1A.BAS` line 1290, when one side has no units left | Ended the tactical game. `expire` writes `OUTCOME.&&&` (through `over`) only when the time is up, so a battle won by wiping out the other side writes nothing, and `WON.EXE` reads the file of the battle before | `SYSTEM` (row 6). The missing file is the game's own slip, kept as it is (a `TODO.md` row, beside the one of section 1) |

There is no other `PEEK`, `POKE`, `BSAVE`, `RUN`, `CHAIN`, `SYSTEM`, `STOP`, `INP`, `OUT`, `CLEAR`, `KILL`,
`NAME`, `FILES`, `ENVIRON` or `CALL ABSOLUTE`. `COMMAND$` is read once, at `WON.BAS` line 11.

### 4. Expressions that mix a LONG with a SINGLE (D8)

The rule measured in step 0: a SINGLE times a LONG is a DOUBLE in PDS 7.1 and QB 4.5, and a SINGLE in QB64. The
LONGs are `casualty&()` (strategic), `score&()`, `vp&()`, `unitsize&` and `total&` (tactical), and `c&`
(`WONMENU.BAS` line 58, a palette color, from INTEGERs only). Five places mix one with a SINGLE:

| Where | Expression | PDS 7.1 | QB64 | Does it change what the game does? |
|---|---|---|---|---|
| `over`, `NAP1A.BAS` line 675 | `WRITE #1, …, .01 * score&(…)`, read by `WON.BAS` line 833 into INTEGERs | A DOUBLE: `.689999984577298` for 69 | A SINGLE: `.69` | **Probably yes, for one score in 200.** For 150 the DOUBLE is 1.4999999665, which reads as 1. The SINGLE rounds to exactly 1.5, which reads as 2 if `INPUT #` rounds a half to even. The same for 350, 550, 750 and every 200 more: a side's losses are then one hundred men more than in DOS. This is worked out, not measured. Step 3 measures it: `WRITE #` of these products in QB64, and `INPUT #` of the written text into an INTEGER in all four compilers |
| `NAPOLEON.BAS` lines 1636, 1638, 1640, 1642 | `strength(index) = unitsize& * (.5 + .2 * RND)` and the like, into an INTEGER | A DOUBLE product, rounded once to the INTEGER | A SINGLE product, rounded to a SINGLE and then to the INTEGER | Rarely: a unit's starting strength can differ by one. A simulation with random draws gave 5 in 200,000. It is the rare kind of D12, and the user's (a) of D12 covers it: a session that meets it is compared up to there |
| `NAPOLEON.BAS` line 784 | `score&(side) = score&(side) + .2 * strength(side)`, into a LONG | DOUBLE | SINGLE | No: `.2` times an INTEGER is never near a half, and the scores are far below the 16,777,216 where a SINGLE loses whole numbers |
| `WON2.BAS` lines 1397 and 1398 | `PRINT INT(.1 * casualty&(1))` | DOUBLE | SINGLE | No: the SINGLE `.1` is a little more than 0.1, so a product that should be a whole number is just above it in both, and `INT` gives the same. The numbers are too small for `PRINT` to show them differently |
| `NAPOLEON.BAS` lines 1516 and 1600 | `unitsize& / 3`, `vp&(who) / unitsize&` | DOUBLE | DOUBLE | No: `/` with a LONG gives a DOUBLE in all four (step 0's `s& / 7`) |

The other lines with a LONG add, compare, read or print INTEGERs and LONGs only.

### What the searches found for the next steps

- **Two expected stops in the tactical game and one in the strategic game** ("RETURN without GOSUB", section 2).
  Step 4's builds should show them; step 5 fixes them.
- **`OUTCOME.&&&` may give other losses than DOS for one score in 200** (section 4). Step 3 measures it. If it
  holds, D8 says that line is put to the user on its own: D8's (a), comparing the file by the INTEGERs read
  from it, does not hide it.
- **A battle won by wiping out the other side writes no `OUTCOME.&&&`** (section 3), so the strategic game reads
  the result of the battle before. It is in the DOS game too, so the port keeps it.
- **Two counts of the plan were off by one or ten:** 16 `DIR$` calls in the strategic game, not 15 (the bare one
  gives no error), and 83 `GOSUB`s in the tactical game's SUBs, not 73.

## Step 3: the measurements (2026-11-07)

Small programs, run one by one on the host. The old compilers ran through QB64Rust's `tools\qb45\qb45.py`. The
QB64 builds were QB64Rust (release build of the working tree at `dc731652`) and the reference QB64pe.

### 1. The losses in `OUTCOME.&&&`

QB64Rust's `verification\qb45\q45_outcome_input.bas` writes `.01 * s&` with `WRITE #`, as `over` does, and reads
it back with `INPUT #` into an INTEGER, as `WON.BAS` line 833 does. It does that for every `s&` from 0 to 3,000.

- **`INPUT #` rounds a half to the even integer in all four compilers.** The texts `0.5`, `1.5`, `2.5`, `3.5`
  read as 0, 2, 2, 4.
- **PDS 7.1 and QB 4.5 write each product just under the half** (`1.49999996647239` for 150), so it reads as
  the integer below. All 3,001 values read as `s& / 100` rounded, with a half rounded down.
- **QB64Rust and QB64pe write the half itself** (`1.5`), so `INPUT #` rounds it to the even integer. For
  `s& = 150, 350, 550` and every 200 after, they read one more: 2 for 150, where DOS read 1. That is 15 of the
  3,001 values, one score in 200, as step 2 worked out.

So in the port, when a side's score in the tactical game is 150, 350, 550 and so on, the strategic game takes
one hundred men more from its army than DOS did. The numbers read are `killa` and `killd` of `battle`
(`WON.BAS` line 833). QB64Rust's `DIVERGENCES-QB45.md` row Q-021 now says this. D8 says that such a line comes
back to the user on its own (below).

### 2. The numbers in the saved files

`q45_write_save_kinds.bas` writes, with `WRITE #`, the kinds of values the saved games, `NWS.CFG` and
`HISCORE.NWS` hold: INTEGERs (0, -1, 32767, -32768), LONGs (123456, -123456), strings (empty, with a blank,
with a comma), the SINGLE `turbo!` at 2 and 8, and SINGLEs such as `.5` and `1 / 3`. It then writes, with
`PRINT #`, lines like those of `BATTSUMM` and `NWS.HIS`: `;`, `,` zones, `TAB(20)`, `SPC`, and
`100 * casualty&`. It reads everything back with `INPUT #`. **The four compilers give the same text, line for
line, and read back the same values.**

### 3. `SHELL "napoleon.exe"` and `SHELL _HIDE "napoleon.exe"`

A parent program in `SCREEN 12` sets two variables with `ENVIRON` and starts a child in `SCREEN 9` by `SHELL`. The
child writes what it sees and checks its own window every half second for 3 seconds. Both are built with the
screen tool. Each ran on a hidden desktop (QB64Rust's `tools\legacy_tests\press_any_key.py --hidden-desktop`)
while a script listed every new visible window on the user's desktop. Each mode was run with QB64Rust and with
QB64pe, and the two gave the same results.

What libqb does (QB64pe's `internal\c\libqb\src\shell.cpp`, `sub_shell` and `sub_shell2`): a command that is
not one of `cmd.exe`'s own (such as `copy`) is started directly with `ShellExecuteEx`, without `cmd.exe`.
`SHELL` passes `SW_SHOW`, `SHELL _HIDE` passes `SW_HIDE`. Only a `cmd.exe` command such as `copy` goes through
`cmd /c`.

| What | `SHELL "child.exe"` | `SHELL _HIDE "child.exe"` |
|---|---|---|
| A window on the user's desktop | None | None |
| The child's own window | Visible | **Hidden for as long as it runs** |
| `ENVIRON` of the parent reaches the child | Yes | Yes |
| The parent waits for the child | Yes | Yes |

- **`SHELL _HIDE` would hide the tactical game in normal play.** Windows applies `SW_HIDE` to the child's first
  window, so the battle would run in a window the player never sees. D5 rested on the belief that a plain
  `SHELL` opens a `cmd.exe` console for the length of the battle. It does not: `napoleon.exe` is not a command
  of `cmd.exe`, so libqb starts it directly. D5 goes back to the user (below).
- **A plain `SHELL "napoleon.exe"` is safe on the host under a script.** The child inherits the hidden desktop,
  and no console opens. That is the check `CLAUDE.md` working rule 6 asks for. Only the `copy` of `NWS.HIS` goes
  through `cmd.exe`, and `scriptshell` does it in BASIC under a script (row 8).
- **The screen tool's variables** (QB64Rust's `tools\screen\screen_state.cpp`): `QB64_SCREEN_KEYS` is read
  once, when the program starts. `QB64_SCREEN_STATE` is read each time a state is written, at a `state` step and
  at exit. `ENVIRON` changes what it reads: the parent set it to the child's file before the `SHELL` and put it
  back after. The child's state went to the child's file, and the parent's state at exit to the parent's. So
  `scriptshell` must put the variable back after the battle, as section 4 of the plan says.
  `QB64_SCREEN_PROMPT_MS` is read when the keys start.
- **The tactical window comes to the front, and the strategic window gets it back** (QB64Rust build, run once on
  the user's own desktop with the user's leave, plain `SHELL`). On a hidden desktop this cannot be seen: no
  window is in the foreground there, and `_WINDOWHASFOCUS` gave -1 even in the hidden child. On the user's
  desktop, `GetForegroundWindow` was the parent's window 1 second after it started. It was the child's window at
  each of the child's six checks, from 0.5 to 3 seconds. It was the parent's again 0.5 seconds after the
  `SHELL` returned. So in normal play the player can type into the battle at once, and then into the strategic
  game, without a click.

### 4. The fonts

QB64's glyphs were dumped by a program that prints all 256 characters in `SCREEN 12` (8 × 16) and in `SCREEN 9`
(8 × 14), built with QB64Rust and the screen tool. A script then cut every recorded DOSBox-X screenshot into
cells, and looked each two-color cell up among QB64's glyphs.

- **The 8 × 16 font is the same, pixel for pixel.** In the 300 screenshots of `SCREEN 12` and the 13 of
  `SCREEN 0`, 27,614 cells match a QB64 glyph exactly, and the menus, messages and Hall of Fame decode to their
  text. The cells that miss by a few pixels are numbers printed over a road or a box edge on the map. `SCREEN 0`
  screenshots are 720 × 400, with a cell 9 pixels wide. Its first 8 columns are the glyph.
- **The 8 × 14 font differs.** In the three `SCREEN 9` screenshots of session 9 (the shipped tactical game),
  almost no text matches. Each cell misses QB64's glyph by 3 to 7 pixels. QB64 has no 8 × 14 font: libqb draws
  rows 1 to 14 of the 8 × 16 glyph, so `U` is 10 rows tall from row 1. The EGA font of DOSBox-X draws it 9 rows
  tall from row 2. QB64Rust's `DIVERGENCES-QB45.md` has it as row Q-023.

So `tests\dosshot.py` (step 8) compares `SCREEN 12` and `SCREEN 0` screens pixel for pixel, as section 5 of the
plan hoped. For `SCREEN 9`, the tactical game's screens, it compares text by character and only the other pixels
by pixel. That needs the DOSBox-X 8 × 14 glyphs, from one DOSBox-X run of a program that prints all 256
characters in `SCREEN 9`. That run comes with the tactical references of D3, in step 7b.

### What step 3 found for the next steps

- **D5 went back to the user, who chose to keep the plain `SHELL "napoleon.exe"`.** `SHELL _HIDE` hides the
  battle window. A plain `SHELL` opens no console and is safe under a script.
- **D8: the `OUTCOME.&&&` line changes in step 5 (user, 2026-11-07).** For one score in 200, the strategic game
  read one hundred more losses than it did in DOS. Part 4 of `q45_outcome_input` measured three forms at the 30
  scores 50, 150, …, 2950:

  | Form | PDS 7.1, QB 4.5 | QB64Rust, QB64pe |
  |---|---|---|
  | `.01! * CDBL(s&)` | as DOS | writes `1.5` for 150: 15 of 30 differ |
  | `k! * CDBL(s&)`, with `k! = .01` | as DOS | **as DOS**, and the same text as QB 4.5 (`1.499999966472387`) |
  | `CSNG(.01) * CDBL(s&)` | as DOS | writes `1.5`: 15 of 30 differ |

  QB64 turns a SINGLE constant into the DOUBLE 0.01 when the other side is a DOUBLE, even with `!` or `CSNG`.
  Only a SINGLE variable keeps the SINGLE's value. So `over` gets `hundredth! = .01` and writes
  `hundredth! * CDBL(score&(…))`. PDS 7.1 still writes `1.49999996647239`, so the bridge sees no change there.
- **The battle window comes to the front** in normal play, and the strategic window gets it back after.
- The saved files and the `RND` sequence hold no surprise.

## Step 4: one program each, building (2026-11-07)

### The changes

Each program is one source file now, with its other modules included at its end. The line numbers in this
list are those of the files before the step.

1. **The linked modules are `.BM` files.** `WON2.BAS`, `WONMENU.BAS`, `NAP1A.BAS` and `NAP1C.BAS` were renamed
   with `git mv` to `WON2.BM`, `WONMENU.BM`, `NAP1A.BM` and `NAP1C.BM`. Their headers were removed: `DEFINT A-Z`,
   their `DECLARE` lines and the include of `won.bi` or `nap10.bi`. The comment blocks of the two menus stay.
2. **The SUBs of each main module moved, unchanged, to a `.BM` of their own.** `WON.BAS`'s 17 SUBs (from line
   650) are in `WON1.BM`, `NAPOLEON.BAS`'s 15 SUBs (from line 135) in `NAP1.BM`. The script that moved them checked
   that the main module and the new file, put back together, gave the original file byte for byte.
3. **The main modules' `DIM SHARED` lines moved into the `.BI` files.** `WON.BAS` line 8 (`graphic` and the
   nations' icons) went to the end of `WON.BI`. `NAPOLEON.BAS` lines 20 to 26 (`Image` and the icon arrays) went
   to the end of `NAP10.BI`. A unit test that includes the `.BI` and the `.BM` files then gets them too.
4. **`WON.BAS` and `NAPOLEON.BAS` end with the includes:** `won1.bm`, `won2.bm`, `wonmenu.bm` and `qb64.bm` for
   the strategic game, and `nap1.bm`, `nap1a.bm`, `nap1c.bm` and `qb64.bm` for the tactical game. `script.bm` and
   `napscript.bm` come with the test hooks in step 6.
5. **`DIR$` is a FUNCTION in `QB64.BM`**, which both programs include. It is Civil War Strategy's, which is World
   War 2's, unchanged. Without it, both compilers read `DIR$("nws.cfg")` as an array. The one `DIR$` with no
   argument, in `getlist` (`WON2.BAS` line 611), is `DIR$("")` now. Without the change, both compilers take it as
   a string variable that is always empty, with no message, and the list of scenarios would end after its first.
6. **`WONMENU.BAS`'s four lines of module-level code are comments** (lines 23 to 26, `y = 68: COLOR 11: ...`).
   In DOS the module-level code of a linked module never ran. The plan said QB64 cannot have code between SUBs,
   but it can: QB64Rust and QB64pe both build the program with the lines in, and a small program showed that they
   run such lines as part of the main program's code, after the code before them. The game's main code never
   falls through to its end, so the lines would not run, but as comments they cannot.
7. **`FRE(-1)` is a comment** (`NAP1C.BAS` line 91, Alt+= at a tactical menu printed the free memory). QB64pe has
   no `FRE`.
8. **The tactical game ends with `SYSTEM`, not `END`**, in its three places: F10 (`NAPOLEON.BAS` line 107), `over`
   (`NAP1A.BAS` line 677) and `wipeout` (line 1290). QB64's `END` shows "Press any key to continue" and waits, and
   `won.exe` waits for the tactical game to end. The strategic game's two `END`s stay.
9. **The dotted lines are drawn with the pixels of QB 4.5 and PDS 7.1.** `icon` (in `WON1.BM`) drew them with
   `LINE` and a style: the roads (`CASE 11`, black, `&H1111`), the marching orders (`CASE 1`, white,
   `&HF0F0`), and the same orders drawn again in green to erase them (`CASE 4` and `CASE 5`). Each now calls
   `styledline` in `QB64.BM` with the same points, color and style. The three cases of the orders change
   together: the green lines erase the white ones only if they light the same pixels. No other `LINE` in the
   strategic game has a style. The tactical game has one, a dotted box on its help screen (`TODO.md`). QB64 draws such a line differently in two ways (QB64Rust's `DIVERGENCES-QB45.md` Q-024 and Q-025):
   - it starts the dotted style at the first point, where the old compilers start at the left end (the bottom
     end of a vertical line). Each road is drawn from both of its cities, so in QB64 it got two sets of dots;
   - it steps to the next row halfway along the line, where the old compilers step earlier.

   `styledline` draws the line pixel by pixel with `PSET`, as the old compilers do: from the left end, with a
   first error of three quarters of the longer side. That rule reproduces all 625 lines that QB64Rust's
   `verification\qb45\q45_line_pixels` recorded from PDS 7.1 and QB 4.5, and the roads of session 9's map.
   The user chose this (2026-11-07), after a first try that only drew each road from its left end.
   Step 7's `PDS.BM` gives `styledline` as the plain `LINE`, so the PDS build draws as before.

The tactical sources have LF line ends and the strategic sources CRLF, as on `main`. Each file kept its own.
The new `.BM` files have their source's line ends, and `QB64.BM` has CRLF.

Not changed in this step: the `GOSUB` routines (step 5), the DOS programs (step 5), the test hooks (step 6), and
the case of file names (row 17 of the plan, a `TODO.md` row).

### The builds

QB64Rust 0.3.0 (its release build of 2026-11-07) and QB64pe 4.7.0 both build `won.exe` and `napoleon.exe` with no
error. Their warnings, with `-w`:

- the strategic game: the labels `iron` (`WON.BAS` line 66) and `topbar` (line 593) are never used (QB64Rust);
- the tactical game: the label `menu6` (`NAPOLEON.BAS` line 26) is never used (QB64Rust), and the array
  `array()` of `NAP10.BI` line 88 is never used (both).

None of them is a bug. Built again after item 9's `styledline`, each compiler gives the same warnings as
before: the tactical game includes `QB64.BM` but gets no warning for the SUB it never calls.

### Playing the builds

Each build was played on a hidden desktop with timed keys and QB64Rust's screen-state check. There are no test
hooks yet, so the keys are given by time. Two stand-ins for the hooks were made in a scratch copy of the
sources, outside the repo:

- `RANDOMIZE 1#` in place of `RANDOMIZE TIMER`, the seed the harness gave the recorded `WON.EXE`;
- before `SHELL "napoleon.exe"`, `ENVIRON` points `QB64_SCREEN_KEYS` and `QB64_SCREEN_STATE` at the battle's own
  files, and puts the state file back after.

The play followed session 9: the built-in title, the start menu, 1805, the Allies with the shipped `NWS.CFG`,
the first End Turn, and its battle in the tactical game, ended by F9 (retreat) and Y. No `.EXE` of the repo was in
the run's folder, so `SHELL "arch2.exe"` ran nothing. History is off in the shipped `NWS.CFG`, so the `copy` of
`NWS.HIS` did not run either.

What it showed:

- **The port plays the first turn exactly as `WON.EXE` did in DOS.** `BATTLE.$$$`
  (`"Innsbruck",1,2,1,"Bernadotte",125,5,2,"Alexander",98,5,1,3,0,2`) and `NWS9.SAV` are byte for byte those of
  session 9, in both builds. So the computer's moves of the first turn, its `RND` draws and the battle's
  arithmetic before the `SHELL` came out the same.
- **`OUTCOME.&&&` differs, as expected:** `1,0,.66` against DOS's `1,0,.689999984577298`. The tactical game is
  Hutsell's source, another revision from the shipped `NAPOLEON.EXE`, and the DOS session did not seed it. Both
  read as the same INTEGERs, so the strategic game went on the same: "Bernadotte is VICTORIOUS in Innsbruck",
  the losses 000/12500 and 100/14000, and the Retreat menu with Vienna and Salzburg.
- **The two builds show the same screens:** 9 of 9 in the battle, 21 of 22 in the strategic game. The one that
  differs is the map during the computer's moves: the army moving to Munich was caught at another point of its
  move. It is timing, not drawing.
- **The tactical game ends at once** after the battle, through `SYSTEM`, and `won.exe` goes on.
- **The built-in title shows, and `PAINT` does not leak** (row 15 of the plan). Both ellipses fill black inside
  and the three stripes stay whole, the same in both builds. No DOS screenshot of it exists to compare with.
- **"RETURN without GOSUB" when the start year is chosen by its letter**, as step 2 expected. Key `1` at "Start
  Year" chooses 1796 by its first letter, `crsr` leaves `menu` by `GOTO called`, and `getlist`'s `RETURN` takes
  `crsr`'s entry. A build with `$CONSOLE` added said "Runtime error: Line: 612 (in won2.bm) RETURN without
  GOSUB" (`WON2.BAS` line 624). QB64Rust exits with code 1, QB64pe with 0 (QB64Rust's `QB64PE-DIVERGENCES.md`
  D-012). The tactical case (`otherside`'s `RETURN` after `general`) did not come up in the short battle. Step 5
  fixes both.
- **The dotted roads differed from DOS, in two ways; item 9 fixes both.** QB64 starts a dotted style at the
  first point written, where QB 4.5 and PDS 7.1 start at the left end. And it steps to the next row halfway
  along a sloping line, where they step earlier (QB64Rust's `DIVERGENCES-QB45.md` Q-024 and Q-025, measured by
  `verification\qb45\q45_line_style` and `q45_line_pixels`). Before item 9, each map screen differed from
  session 9's screenshot by 1,400 to 2,600 pixels. After it, no road pixel differs on the two map screens
  checked: the first map and the screen after the battle. The marching orders, which item 9 also covers, are
  drawn and then fully erased in the replay, and the stretch from Rouen past Paris that session 9's attack
  screenshot shows has the same 34 pixels as DOS's.
- **The city markers still differ, by about 280 pixels of a map screen:** spots of 1 to 4 pixels at the top
  and bottom of the markers, which `cityicon` (`WON2.BM`) draws with `CIRCLE` of radius 4 and 3. Not measured;
  `tests\dosshot.py` can leave the markers out (`TODO.md`).
- **One French army is in another city by July 1805:** near Cherbourg in DOS, at Bologna in the port. May's
  `NWS9.SAV` is equal. Timed keys cannot show where play parts; after the hooks of step 6, step 7's trace mode or
  QB64Rust's `--trace-values` can (`TODO.md`).
- **Timed keys do not follow the play after a battle:** the battle runs longer than in DOS, so the session's
  `v` came before the Retreat menu opened. Step 6's announce hooks remove this.
- **For step 6:** the screen tool reads `QB64_SCREEN_STATE` at each state it writes, so the strategic game's
  timed `state` steps during the battle went to the battle's file. Under a script its keys wait at a `prompt`
  then, and it takes no state.
- **Do not trace the game with a `$CONSOLE` build on the host.** With `$CONSOLE`, libqb runs `SHELL` through
  `cmd.exe`, which is what working rule 6 of QB64Rust's `CLAUDE.md` keeps off the host. A trace that appends
  to a file needs no console.

**The tactical window comes to the front in the game itself** (QB64Rust build, one run on the user's own
desktop, 2026-11-07). A script logged the foreground window every half second. When the battle began,
`napoleon.exe`'s window took the foreground from VS Code, where the user was working. VS Code had it again
2.5 seconds later; the log cannot tell whether the user clicked. The battle ended normally. Whether `won.exe` gets the foreground back was not seen;
step 3's small parent and child showed that it does.

### For the user

The user chose how the roads are drawn (2026-11-07): with QB 4.5's own steps in the port (item 9), after a
first try that only drew each road from its left end.
