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
| `PEEK(1052) = 30` | `navy`, `WON2.BAS` lines 1024, 1034, 1055, 1091 | True when no key has been typed since `BuffClear` (corrected in step 7a: it reads the tail, which a read does not move). Then the sea battle played its sound, showed its icon or paused. It reads segment 0 because `BuffClear` runs at line 1019, after the last `europe`, and nothing in between changes `DEF SEG` | Kept. Under a script the keys typed differ from DOS's, so the checks can differ: "Step 7a" below |
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
  GOSUB" (`WON2.BAS` line 624). QB64Rust exits with code 1, QB64pe with 0 (QB64Rust's `DIVERGENCES-QB64PE.md`
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

## Step 5: what DOS did that QB64 does not (2026-11-08)

### The changes

The numbers go on from step 4. Line numbers are those of the files before this step.

10. **Every `GOSUB` routine in a SUB ends by `RETURN`.** QB64 keeps one `GOSUB` stack for the whole program, so
    a routine that leaves its SUB by `GOTO` or `EXIT SUB` leaves its entry behind (step 2, section 2). Each of
    the six routines step 2 found now returns. It sets a flag where it used to leave, and the line after its
    `GOSUB` does what the routine did:

    | Routine | Where it left | Now |
    |---|---|---|
    | `crsr` in the strategic `menu` (`WONMENU.BM`) | `GOTO called` at 6 places: Esc, an entry's first letter, any key when `switch` is 3, F4, F1, and F7 when `switch` is 0 | `leave = 1: RETURN`. The line after `GOSUB crsr` is `IF leave = 1 GOTO called` |
    | `crsr` in the tactical `menu` (`NAP1C.BM`) | `GOTO called` at 3 places: the space bar, Esc and an entry's first letter | The same |
    | `getlist` in `init` (`WON2.BM`) | `EXIT SUB` at 3 places, each after `choose = -1` | `RETURN`. The line after `GOSUB getlist` is `IF choose = -1 THEN EXIT SUB`. On the way that goes on, `choose` is the chosen entry, never -1 |
    | `otherside` in `order` (`NAP1.BM`) | `GOTO asleep` at 4 places | `RETURN`. The one `GOSUB otherside` is followed by `GOTO asleep`, so the play goes on at the same line |
    | `wait5` in `order` (`NAP1.BM`) | `EXIT SUB` on F10 | `leave = 1: RETURN`. The line after `GOSUB wait5` is `IF leave = 1 THEN EXIT SUB` |
    | `eval` in `general` (`NAP1A.BM`) | `GOTO improve` | `leave = 1: RETURN`. Each of the six `GOSUB eval` lines ends with `IF leave = 1 GOTO improve`, inside its one-line `IF`. `leave = 0` comes before the first |

    `leave` is a new local variable of each SUB. No SUB of either program has that name, and none of the four
    SUBs is `STATIC`. Each routine has a comment that says why it returns.
11. **The copy of `NWS.HIS` goes through `scriptshell`** (`WON.BAS` line 632). The line is now `CALL
    scriptshell("copy nws.his oldhist.ory")`. `scriptshell` is Civil War Strategy's, unchanged, in a new
    `SCRIPT.BM` that `WON.BAS` includes after `QB64.BM`. When the program runs under a script, it copies the
    file in BASIC. Otherwise it runs the `SHELL` as before. `WON.BI` declares `scripted` (`DIM SHARED`), which
    nothing sets until step 6's hooks, so for now the program always runs the `SHELL`. In normal play QB64 runs
    `copy` through `cmd.exe` (step 3, section 3). Whether a console window then shows for a moment was not
    measured. The game makes the copy only when history is on, which the shipped `NWS.CFG` turns off.
    `scriptshell` uses `_FILEEXISTS`, which PDS 7.1 does not have, so step 7's PDS build needs its own form.
12. **`OUTCOME.&&&` holds the numbers DOS wrote** (`over`, `NAP1A.BM`, decision D8). The line was `WRITE #1, 3 -
    sidex(flag), .01 * score&(sidex(1)), .01 * score&(sidex(2))`. Now `hundredth! = .01` comes first, and each
    product is `hundredth! * CDBL(score&(…))`. Step 3 measured that form in QB64Rust and QB64pe at 30 scores:
    each gave the value PDS 7.1 gives, so `INPUT #` reads the same INTEGER as in DOS. The text can have one
    more digit: `1.499999966472387` for 150, where PDS 7.1 writes `1.49999996647239`. PDS 7.1 gives the same numbers as before, so the bridge of step 7 sees no change.
13. **The DOS programs with no source leave the branch (D6), and their pictures are in `docs\`:**
    [ARCH2.png](ARCH2.png) (the intro, from session 1), [VIC.png](VIC.png) (the victory picture) and
    [NAPIC.png](NAPIC.png) (the tactical title, from session 9). Session 15's shot of the victory picture was
    taken while `VIC.EXE` was still drawing it. So `VIC.png` comes from a run of `VIC.EXE` alone in the play
    harness's DOSBox-X: shots at 4, 8, 12, 20, 30, 45 and 60 seconds were byte-identical. The three
    `.EXE` files are still in the folder: removing a tracked file is the user's to do (`ARCH2.EXE`, `VIC.EXE`,
    `NAPIC.EXE`). Every `SHELL` of them is guarded by `DIR$`, so no line of the game changes. Without
    `ARCH2.EXE` the game shows its own title, as step 4 checked.

**Where `WON.EXE` and `NAPOLEON.EXE` stay (D7, decided again).** The plan had them move to a folder `dos\`, so
that a build in the repo's folder could not overwrite them. The user chose to leave them where they are, and
let a build overwrite them (2026-11-08). They stay in git's history. `tools\play\play.py`, which replays the
recordings with the shipped programs, then refuses an overwritten `WON.EXE` ("not the shipped WON.EXE").
`tools\play\README.md` says to replay from a worktree of `main` instead. The recordings
already made, and step 7's bridge, which plays the PDS 7.1 builds of the port, do not need the shipped
programs in the folder.

### The checks

Both programs build with QB64Rust 0.3.0 and QB64pe 4.7.0, with the same warnings as in step 4.

Each check ran the QB64Rust build with the screen tool, on a hidden desktop, with timed keys. The run's folder
held the game's data and no `.EXE`, so no `SHELL` of a DOS program ran. There are no test hooks yet, so the
games seeded their random numbers from `TIMER`.

- **The start year chosen by its letter.** Key `1` at "Start Year" chooses 1796. Step 4's build, built again
  from `HEAD`, stopped there with exit code 1, as step 4 found. In 1 of 12 runs, the first, it stopped
  with 0xC0000374 instead, a heap corruption, on the same path. It did not come back in the next eleven.
  The cause is not the error but the `SOUND 700, .5` that `called` plays just before it. In libqb, as
  QB64pe has it at the reference commit, the audio thread swaps the two buffers of a `SOUND` stream without
  the lock that the program thread holds while it fills them. A small program that plays a `SOUND` and ends
  with `SYSTEM` crashed in about 1 run in 40, with QB64Rust and with QB64pe alike. Upstream added the lock on
  2026-10-28 (QB64pe pull request 800), and with it no run of 380 crashed. QB64Rust took that line on
  2026-11-08 (its divergence D-062), so a build with a later qb64rust has the lock. QB64pe 4.7.0 does not. This
  step's build loads 1796 and shows the objective, then the main menu.
- **Esc at "Start Year"** (`getlist`'s first `RETURN` with -1) goes back to the start menu. **`i` at the main
  menu** opens Information by its letter, and **F1** shows the Hot Keys box. Both go through `crsr`'s new
  `RETURN`.
- **The tactical game alone**, from the repo's `BATTLE.$$$` (a Waterloo battle): two runs of 40 seconds each,
  with many computer moves. Each of those moves goes through `otherside`, and some through `general`. No error. The
  timed F9 never met the player's turn, so the retreat's Yes/No menu was not reached by letter. Nor was F10
  (`wait5`). Step 6's hooks make both scriptable, and step 8's scripts cover them.

## Step 6: the test hooks (2026-11-08)

### The changes

The numbers go on from step 5. Line numbers are those of the files before this step.

14. **Two hook files, in BASIC that PDS 7.1 compiles too.** `SCRIPT.BM` (the strategic game, included at the end
    of `WON.BAS`) and a new `NAPSCRIPT.BM` (the tactical game, included at the end of `NAPOLEON.BAS`). They use
    no QB64-only name. `scriptcopy` tests for a file with `DIR$`, which PDS has and `QB64.BM` gives QB64. Step
    5's `scriptshell` used `_FILEEXISTS`. It copies 16 KB at a time, because a PDS string holds at most 32,767
    bytes and the history file can grow larger.
15. **The variables that choose the mode.**

    | Variable | Program | What it does |
    |---|---|---|
    | `WON_SEED` | strategic | `RANDOMIZE VAL(WON_SEED)` in place of `RANDOMIZE TIMER`. Alone, it makes the program scripted |
    | `WON_TRACE` | strategic | Trace mode: the waits are announced and nothing else changes. The seed still comes from `WON_SEED` when that is set |
    | `WON_OUTCOME` | strategic, scripted | A battle copies this file to `OUTCOME.&&&` instead of starting `napoleon.exe` (D4) |
    | `NAP_SEED` | tactical | As `WON_SEED`. `scriptbattle` sets it to `WON_SEED` for each battle, unless it is set already |
    | `NAP_TRACE` | tactical | As `WON_TRACE` |

    The plan named only `WON_TRACE`. The tactical game is a program of its own, and runs alone for D3's
    references, so it has its own trace variable.

    Each program has two flags, `scripted` and `traced`, in a `COMMON SHARED` line after the `COMMON` block of
    `WON.BI` and `NAP10.BI`. Step 5's `DIM SHARED scripted` is gone: in the PDS build each module would have its
    own copy of a `DIM SHARED` variable, and only `COMMON` shares one between modules.
16. **The seed.** `RANDOMIZE TIMER` (`WON.BAS` line 77) is now `CALL scriptseed`. That is the place that
    `tools\play\wonseed.py` patched to `RANDOMIZE 1#` for the recordings, and `VAL("1")` is the same DOUBLE.
    `CALL scriptstart`, which sets the flags, is now the program's first statement, before the title's `TICK`.
    In the tactical game, `RANDOMIZE TIMER` (`NAPOLEON.BAS` line 18) is `CALL napstart`, which does both.
17. **`announce` before each wait for a key**, as in Civil War Battleset. Byte `&H4F1` gets the place, `&H4F2`
    the letter and `&H4F0` the count (QB64Rust's `tools\screen\README.md`, "Places and rules"). It does nothing
    unless the program is scripted or traced. It leaves `DEF SEG` at 0, as `BuffClear` does, for the four
    `PEEK(1052)` checks. The places:

    | Place | Letter | Strategic game | Tactical game |
    |---|---|---|---|
    | 1 | | "press a key" after the random events, and the player's turn (`WON.BAS` lines 488 and 620) | "hit a key" (`hold8`, `NAP1A.BM` line 841) |
    | 2 | first letter of the menu's title | `crsr` (`WONMENU.BM`) | `crsr` (`NAP1C.BM`) |
    | 3 | `S` for less than a second (strategic only) | every `TICK` | a `TICK` of a second or more |
    | 4 | | the commander's name in the Hall of Fame (`INPUT`, `WON2.BM` line 692) | |
    | 5 | | | the command for a unit (`wait3`, `NAP1.BM` line 610) |
    | 6 | | | the cursor on the map: move, Intell and inspire, where F10 quits (`wait5`, `NAP1.BM` line 878) |

    The strategic `crsr` and the tactical `wait3` and `wait5` were loops by `GOTO` to their own label. Each is
    now `announce` and a `DO` loop, so it announces once for each key it reads. A key that the routine ignores
    reaches its `GOTO` back to the label, and it announces again.
18. **`TICK` under a script (D2).** Each `TICK` calls `scripttick%` first.
    - Strategic: every `TICK` reads `INKEY$` at least once, even for 0 seconds, because BASIC evaluates both
      sides of `AND`. So every `TICK` is a wait, as D2 says. Scripted, it waits for a key and throws it away.
      Traced, it announces and then pauses as before.
    - Tactical: its `TICK` reads no key when the pause is under a second (`NAP1A.BM` line 1205). Such a pause is
      not announced, and under a script it returns at once. A longer one is a wait, as in the strategic game.
      D2 was written for the strategic game, and this is Claude's reading of it for the tactical one. An
      announced wait that takes no key in DOS would give step 7's converter waits that no recorded key went to.
      `scripttick%` comes after `sec! = ABS(sec!)`, which changes the caller's variable, so that still happens.
19. **The date.** The history file's first line takes `scriptdate$`: `06-24-1998` when scripted, which is the
    date the DOSBox-X sessions ran with, else `DATE$`. No other line reads the date or the time.
20. **The battle goes through `scriptbattle`** (`WON1.BM` line 182, `SHELL "napoleon.exe"`). When the program
    is not scripted, it runs the `SHELL` as before (D5). When it is scripted, it does what section 4 of the plan
    says: the n-th battle gets the keys file `<keys>.battle<n>`, the state file `<state>.battle<n>` and
    `NAP_SEED`. The three variables are put back after the `SHELL`. With `WON_OUTCOME` set, it copies that file
    instead (D4).

### The checks

Both programs build with QB64Rust 0.3.0 and QB64pe 4.7.0, with the same warnings as in step 4. Each run below
used the QB64Rust build with the screen tool, on a hidden desktop. The run's folder held the game's data and the
two built programs, and no DOS `.EXE`. Under a script no `SHELL` of `cmd.exe` can run: the copy of `NWS.HIS` is
done in BASIC, and `napoleon.exe` is started directly (step 3).

- **Session 9's first turn, by announced waits.** The keys file has rules for places 1 and 3, and a
  `play until 2` at each menu: Start NEW Game, 1805, End Turn, Yes, and the Retreat menu after the battle. The
  battle's keys file plays until place 5 twice, then gives F9, and `y` at the "RETREAT?" menu. `BATTLE.$$$`
  and `NWS9.SAV` are session 9's, byte for byte. `OUTCOME.&&&` is `1,0,.6599999852478504`, as in step 4: the
  port's tactical game is another revision from the shipped one. The QB64pe build gave the same states, byte
  for byte, in both programs.
- **`WON_OUTCOME`**, set to session 9's recorded `OUTCOME.&&&`: no battle ran, the file was copied, and the
  Retreat menu showed the recording's losses, 000/12500 and 100/14000.
- **The tactical game alone**, with `NAP_SEED=1` and the same `BATTLE.$$$`, wrote the same `OUTCOME.&&&` as the
  battle that the strategic game started. Step 5 could not reach two keys with timed keys. Both work now:
  - `y` at the "RETREAT?" menu chooses Yes by its letter;
  - F10 at the map cursor (Intell, then F10) ends the program with exit code 0 and writes no `OUTCOME.&&&`
    (`TODO.md`, "The game"). At the unit's command, F10 does not quit.
- **Three battles in one run.** Rules answered the main menu with End Turn, its Yes/No menu with Yes, and the
  Retreat menu with Enter, and each battle's keys file retreated as in session 9. Three battles ran, at
  Innsbruck, Salzburg and Budapest. Each wrote 4 states to its own file, `screen.txt.battle1` to
  `screen.txt.battle3`, and the strategic game's state at exit went to its own file. So `scriptbattle` counts
  the battles and puts the screen tool's variables back each time. Every battle ran scripted, so each had
  `NAP_SEED`. The run does not show whether `ENVIRON "NAP_SEED="` cleared it in between: either way the next
  battle sets it again. The game then came back to its start menu, where the rules stopped.
- **Trace mode** (`WON_TRACE=1`): the waits are announced, and a keys file reaches the start menu and the year
  menu with `play until 2`.
- **No variable set:** the title pauses for its 2 seconds, and the start menu waits, with nothing announced.
- **PDS 7.1** (QB64Rust's `tools\qb45\qb45.py --compiler pds71`): two small programs that include `SCRIPT.BM`
  and `NAPSCRIPT.BM` compile and run. The copy in BASIC, the date, the announce bytes (the count, place 3,
  letter 83 for `S`) and `scripttick%` in trace mode all give what they should. One finding: **`ENVIRON
  "NAP_SEED=5"` stops with error 7, "Out of memory"**, because the DOS environment had no room for a new
  variable. So no `ENVIRON` statement may run in DOS. `scriptbattle` sets `NAP_SEED` only when it is not set,
  and the screen tool's variables are never set in DOS. Step 7's harness therefore sets `NAP_SEED` and
  `NAP_TRACE` itself, before `WON.EXE` starts.
- **The copy of a large file:** a 50,893-byte file copied over an existing one came out the same, in PDS 7.1
  and in QB64Rust. A copy whose source is missing makes no file.

**Left for step 7: the modules.** Step 7's `pdsbuild.py` splits each program back into PDS modules. Each module
includes `WON.BI` or `NAP10.BI`, and so gets the flags' `COMMON` line and the `DECLARE FUNCTION` lines of
`scriptdate$` and `scripttick%`. Which module the hook SUBs go into is for `pdsbuild.py` to choose.

**Found on the way: the French moves differ already in May.** `TODO.md` had the difference from July. With the
hooks, the screen can be saved at every wait of the first turn. Before the battle, the port marches Davout to
Köln, and a French army stands at Bologna. Session 9's attack screenshot (`03-attack`) shows French armies at
Cherbourg and Rouen, and none at Bologna. May's `NWS9.SAV` is still equal. Step 4's
runs with timed keys also had the army at Bologna, so the hooks did not cause this. Step 7's trace mode is
meant to find where the two plays part.

## Step 7: the bridge, started (2026-11-08)

The pragmatic engineer's review asked for one session first, before the 15: build the port with PDS 7.1, play
session 9, and find out why the French move elsewhere than in DOS. This is that part of 7a.

### The changes

21. **`tools/pdsbuild.py` builds the strategic game with PDS 7.1.** It writes the three modules that `WON.EXE`
    was built from back into a scratch folder: `WON.BAS` with `WON1.BM`, `SCRIPT.BM` and `PDS.BM` after its main
    code; `WON2.BAS` and `WONMENU.BAS` with the headers that step 4 removed; and `WON.BI` without the pictures'
    `DIM SHARED` line, which goes back before the include in `WON.BAS`, where it was in DOS. The bare `DIR$`
    of `getlist` is `DIR$` again. It then compiles and links them with the recovery's switches and runtime
    (`docs/won-source-study.md`, section 12). `--src` builds a copy of the sources instead, for trace lines.
    The tactical game is not built yet.
22. **`PDS.BM`** is `QB64.BM`'s PDS form: `styledline` is the plain `LINE` with the style, as DOS drew it.
    PDS 7.1 has `DIR$` itself.
23. **`tools/play/play.py --port WON.EXE`** plays a PDS build of the port in trace mode. The autoexec sets
    `WON_SEED` (the script's seed) and `WON_TRACE=1` before the game starts, and the run's folder gets
    `ARCH2.EXE`, `VIC.EXE`, `NAPIC.EXE` and `NAPOLEON.EXE` from git (`7738434`), so the build runs them as the
    recordings did. The branch still tracks the shipped `NAPOLEON.EXE`, but a QB64 build of the port in the
    repo's folder overwrites it with a Windows program.

### Session 9 with the PDS build

The build has no warning in BC 7.10 or LINK 5.10. **`play.py check` of session 9 with it gives the recording:
12 of 12 screens and the 3 files.** So the port's source, with the edits of steps 4 to 6 and the hooks in trace
mode, plays as `WON.EXE` did.

### Why the French move elsewhere in QB64: PDS 7.1 skips the right side of AND

The QB64 builds part from DOS in the computer's first turn: by the battle, French armies stand at Bologna and
near Köln, where DOS has them at Cherbourg and Rouen (session 9's `03-attack`).

**The cause:** in a condition, PDS 7.1 does not evaluate the right side of `AND` when the left side is false,
nor the right side of `OR` when the left side is true. QB 4.5, QB64pe and QB64Rust evaluate both sides. So a
line like `recruit`'s

```
IF y > x AND RND > .5 THEN x = y: choose = i      ' WON1.BM line 874, in randsel
```

calls `RND` in QB64 each time, and in DOS only when `y > x`. After the computer's first recruiting, every
later `RND` of the QB64 build is another draw than in DOS.

How it was found:

- A scratch copy with trace lines in `evaluate` and `smarts`, built with PDS 7.1 and with QB64Rust, gave the
  same trace in both. But each such PDS build no longer matched the recording from `03-attack` on. A build
  that only replaced each `RND` by a FUNCTION that returns `RND`, with no trace line at all, did not match
  either. A build that only added two variables to the `COMMON` block did.
- Replacing `RND` by that FUNCTION at chosen places, and halving the places each time, gave one place that
  changes the play: `WON1.BM` line 874. A FUNCTION on the right side of `AND` is always called in PDS, so
  the FUNCTION made PDS call `RND` there as QB64 does.
- QB64Rust's new `verification\qb45\q45_and_short_circuit` measures it, with `.pds71.txt` and `.qb45.txt`.
  PDS 7.1 skips the right side in a single-line or block `IF`, in `ELSEIF`, and in the conditions of
  `DO WHILE`, `DO UNTIL`, `LOOP WHILE` and `WHILE`. It does so only when both sides are relations:
  `IF y AND RND > .5` (an INTEGER on the left), `XOR` and a value stored with `z = y > x AND RND > .5` evaluate both sides.
  QB 4.5, QB64pe and QB64Rust evaluate both sides in every case. QB64Rust's `DIVERGENCES-QB45.md` has it as
  row Q-026.
- With line 874 written as `IF y > x THEN IF RND > .5 THEN x = y: choose = i`, in a scratch copy, the QB64Rust
  build played session 9's first turn by announced waits to the Retreat menu after the battle. Its screen there
  shows the armies where session 9's `10-retreat` has them, with the same losses. Without the change, it had
  the army at Bologna.

**Where else it can happen.** A line is affected when the side that PDS can skip has an effect. In these
programs that is `RND` and `INKEY$`:

- **The strategic game: 13 lines** with `RND` on the right of an `AND` or `OR` in a condition: `WON1.BM` lines
  874 and 929; `WON2.BM` lines 375, 441, 480, 531, 533, 734, 825, 1100, 1586, 1627 and 1648.
- **`TICK`** (`WON2.BM` line 1761 and `NAP1A.BM` line 1208): `DO WHILE TIMER - start! < sec! AND INKEY$ = ""`.
  In DOS, a `TICK` whose time is already up reads no key. `TICK(0)` (`turbo! - 1` with `turbo!` at 1) leaves a
  key typed ahead in the buffer, where QB64 takes it and throws it away. Step 6 read this line the other way
  ("BASIC evaluates both sides of `AND`", change 18): under a script, every strategic `TICK` is announced as a
  wait (D2), but in DOS a `TICK(0)` takes no key. That matters for `sessions.py`, which maps each recorded key
  to the wait that took it.
- **The tactical game:** 34 lines have `RND` or `INKEY$` next to an `AND` or `OR` in a condition, not yet sorted
  into those where the skipped side has an effect.

The user chose to rewrite the lines (D13 of `docs\port-study.md`, 2026-11-08).

### The rewrite

24. **The conditions that PDS 7.1 cut short are written so that QB64 does the same.** Each rewritten line has a
    comment that says why. Line numbers are those before the change.
    - **Nested single-line `IF`s**, so that `RND` comes after a test of its own: `WON1.BM` line 874 (`IF y > x
      THEN IF RND > .5 THEN …`); `WON2.BM` lines 375, 480, 531, 533, 734, 825, 1100 and 1648; and line 1586,
      whose `… AND RND > .5 AND cash(2) < 222 GOTO signup` became `… THEN IF RND > .5 AND cash(2) < 222 THEN
      GOTO signup`. The parentheses of line 533 went, as they now enclose the whole test.
    - **Nested block `IF`s:** `WON1.BM` line 929 (`brray(i) <> 999`, then `armylead(i) > 10 * RND`) and
      `WON2.BM` line 441 (Trafalgar: `navysize(2) < 10`, then the `RND` and the date).
    - **`ELSEIF`** for the one `OR`, `WON2.BM` line 1627: `IF occupied(navyloc(who)) = 0 THEN` and `ELSEIF RND >
      .3 THEN` both call `navy(who, 2)`, so that line is there twice.
    - **Both `TICK`s** (`WON2.BM` line 1761, `NAP1A.BM` line 1208) loop on the time alone, and read `INKEY$`
      inside with `EXIT DO`. A `TICK` whose time is up leaves a key typed ahead in the buffer, as in DOS. The
      hooks are unchanged: under a script every strategic `TICK` still waits for a key (D2), also `TICK(0)`,
      which in DOS takes no key. `sessions.py` has to know that a `TICK(0)` of a recording took no key.

    The tactical game's other lines are left for its PDS build (`TODO.md`).

### The checks

- **PDS 7.1** builds the rewritten source with no warning. **All 15 sessions with that build give their
  recordings**, every screen and every file (`play.py check --port`, 2026-11-08). So the rewrite changes
  nothing in DOS.
- **QB64Rust 0.3.0 and QB64pe 4.7.0** build both programs, with the same warnings as in step 4.
- **Session 9's first turn with the QB64Rust build**, by announced waits with `WON_OUTCOME` set to the recorded
  `OUTCOME.&&&`, now ends at the Retreat menu with the armies where session 9's `10-retreat` has them, and the
  same losses. 290 pixels of that screen differ from the screenshot, across the map: about the size of the
  city-marker difference of step 4 (`TODO.md`).

## Step 7a: the trace mode and the keys files (2026-11-08)

The rest of 7a: the trace mode of `PLAYKEYS.COM`, `sessions.py`, and the 15 sessions in trace mode.

### The changes

25. **`PLAYKEYS.COM` has a trace mode** (`tools/play/playkeys.py`). `play.py --port` turns it on. It logs three
    kinds of thing into its own memory:
    - at each timer tick where the count of waits at `0:4F0h` changed, a sample with the place and the letter.
      The 8-bit count goes into a 16-bit total;
    - each key it types and each screenshot, with the total of waits at that moment;
    - each key a program reads. It hooks INT 16h, passes each read (AH = 00h or 10h) on, and then logs the key,
      the buffer slot it came from, and the PSP of the program that read it (INT 21h AH = 62h).

    The log fills the part of the key buffer that `KEYS.BIN` leaves free. So the program stays resident with
    the same 2,037 paragraphs as before, and the game loads at the same address as in the recordings. Without
    trace mode, `PLAYKEYS.COM` is still the same 326 bytes, byte for byte.
26. **`play.py` reads the log from DOSBox-X's memory file.** With `--port`, the configuration sets `memory
    file=` to `MEMORY.BIN` in the run's folder, so the guest's memory is a file on the host. After the run,
    `play.py` finds the log by its magic, writes `trace.json`, and deletes the 16 MB file. A log in memory needs
    no file I/O from inside an interrupt handler, and adds only a few instructions per tick and per key.
27. **`tools/play/sessions.py` writes `tests/sessions/<name>.keys`** from a trace, in the screen tool's format.
    - Each wait the strategic game announced is a `prompt`, followed by the keys that the wait read in DOS.
    - A wait that read no key gets `key space`. A scripted `TICK` waits for a key and throws it away (D2).
    - Each screenshot is a `state` after the prompt of the wait at which DOS took it.
    - Runs of three or more pauses that read no key are written as a `repeat` block.
    - Each comment is a line of its own. The screen tool takes `#` only at the start of a line, and a `text`
      step takes the rest of its line (`screen_state.cpp`, line 346).

    The keys and screens of the other programs are left out, and so are the `dos` shots. The keys are told
    apart by the PSP that read them, and the screens by the video mode. The other programs are `ARCH2.EXE`,
    `VIC.EXE`, `NAPIC.EXE` and the shipped `NAPOLEON.EXE`. Session 9's file is for its run with
    `WON_OUTCOME` (D4), and its header says so.

### The checks

- **All 15 sessions in trace mode give their recordings**, every screen and every file (`play.py check
  --port`, the PDS build of the branch's last commit). So the INT 16h hook and the log change nothing that
  the game does.
- **Every key is accounted for.** 1,587 keys were typed in the 15 sessions. The strategic game read 1,567.
  The other 20 were read by the other programs. In each session, the first key closes `ARCH2.EXE`'s picture.
  Session 9 adds `NAPIC.EXE`'s key and the battle's three, and session 15 adds the key that closes `VIC.EXE`'s
  picture. No key was thrown away by `BuffClear` or a pause, and none was dropped with the buffer full.
- **Each wait read at most one key**, except the one `INPUT` of the Hall of Fame (place 4) in session 15. It
  read 11 keys: "Wellington" and Enter. So the 16-Esc tails of ten sessions are no guess: each key belongs to
  one wait.
- **The shots:** 305 of the 317 become states, and 12 are left out. These are the 12 of section 5 of
  `docs\port-study.md`: `01-intro`, `16-vic`, the six `dos` shots, and session 9's `04-tactical-title` and three
  battle screens. No kept shot was taken after a wait had read its key and before the next wait. The trace
  cannot show a shot taken after a pause ran out and before the next wait was announced. Such a shot is
  filed under the pause's wait, and step 7b's comparison would show it.
- **The waits:** 6,610 in the 15 sessions, from 88 in session 15 to 1,654 in session 4. In some ticks the game
  announces up to 8 pauses, so a sample misses the place of all but the last. Each of those waits read no key,
  and every wait but a `TICK` loops until a key comes, so they were pauses. The keys files say "in a tick with
  others" for them.
- **Four keys were typed before their wait was announced** and waited in the buffer while the game was busy:
  session 4 at waits 327 and 1508, session 5 at 138, and session 10 at 724. Under a script each of them is
  typed later, at its wait.

**Found in the review: the four `PEEK(1052) = 30` checks do not ask whether a key waits.** They are in naval
combat (`WON2.BM` lines 1024, 1034, 1055 and 1091), right after `BuffClear` (lines 985 and 1019), and each
guards a `TICK`. They read the buffer's tail. Every key typed moves the tail on, and reading a key moves the
head, not the tail. Only `BuffClear` sets the tail back to 30. So a check is true only when no key has been
typed since the last `BuffClear`, or when the tail has wrapped round to 30 again. The traces show it: the
slots of the keys typed go 30, 32, … 60, 30 and do not come back to 30 when a key is read. Step 2's table
(above) and row 12 and section 5 of the plan said "when a key waits", which is wrong.

This matters for the keys files. A scripted run types `key space` for each pause that read no key in DOS,
and it types the four keys above later than DOS did. Either can move the tail where DOS's had not moved. A
check is then false where it was true in DOS, and it skips a `TICK` that DOS ran. The scripted run announces
one wait fewer, and every later prompt is answered one wait off. Trace mode types no filler, so it gives the
recordings, and the converter cannot see the checks. The slot sequence starts again at 30 between keys in
sessions 1, 4, 5, 6, 9 and 14. In session 9 that comes from the tactical game. Step 7b first finds which of the
others reach the strategic game's naval combat, and measures whether libqb keeps the tail at `0:41C` as the
BIOS does. The fix proposed in the review is a filler key of its own, which `scripttick` takes back out of the
buffer, so that a filler leaves the tail where DOS had it.

The 15 keys files hold 6,638 lines (124 KB). `sessions.py --check` gives exit code 0 with the traces of this
run.

## Step 7b: the four naval checks (2026-11-09)

The pragmatic engineer's order for 7b: measure libqb's tail first, then find the sessions with naval combat,
then run the check, and build a fix for the filler keys only if the check needs one.

### libqb keeps the tail as the BIOS does

A small program set both bytes to 30, as `BuffClear` does. It then read 17 keys, each given by the screen tool
at an announced wait, and wrote the head (1050) and the tail (1052) after each. QB64Rust and QB64pe builds gave
the same: 30 after the clear, then 32, 34, … 60 for keys 1 to 15, 30 for key 16 and 32 for key 17. The head
followed the tail, because each key was read before the next came. That is the slot sequence of the DOS traces
(step 7a). QB64Rust's `tests\corpus\screen\k05_bios_keyboard_buffer` already shows the head, the tail and
`BuffClear`'s `POKE`s, but not the wrap from 60 to 30.

So the four checks give in a QB64 build what they give in DOS, as long as the same number of keys is typed
between two `BuffClear`s. The game needs no change for the QB64 builds.

### Which sessions fight at sea

In the strategic game, `BuffClear` runs only in naval combat (`WON2.BM` lines 985 and 1019). So the sessions
whose slot sequence starts again at 30 between keys are those that fight at sea: 1, 4, 5, 6 and 14. Session 9's
reset comes from the tactical game, which has no `PEEK(1052)` check.

### What this means for a scripted run

Every shot of a naval combat runs one of the checked `TICK`s: line 1024 when the sound is on, line 1091 in
`showhit` when it is off. In a combat where DOS typed no key, every check was true. Under a script, the first
such `TICK` reads its filler key, which moves the tail to 32. The next check is then false and skips a `TICK`
that DOS ran. From there each `prompt` of the keys file answers the wait after the one it was written for. So
sessions 1, 4, 5, 6 and 14 will go out of step in their first naval combat, and the check does not need to run to
show it.

`scripttick` cannot simply put the head and the tail back after each key. In DOS a `TICK` also reads a real key
that was typed during the pause, and that key moved the tail there too. Only a filler key that `scripttick` can
tell apart from a real one can be taken back without a trace, as the step 7a review proposed.

### The fix: F12 as the filler (the user chose it, 2026-11-09)

- `sessions.py` writes `key f12` for a pause that read no key in DOS, in place of `key space`. The game reads
  F12 nowhere. The 15 keys files were written again from the traces of step 7a: 299 lines changed, each a
  `key space` filler that became `key f12`. The spaces the player typed stay. No keys file has a finding, so
  every filler answers a `TICK`.
- `scripttick` (`SCRIPT.BM`) reads its key, and when it is F12 (`CHR$(0) + CHR$(134)`) it sets the head and the
  tail back one slot, wrapping from 30 to 60. That is where both were before the screen tool typed it, since
  the tool types a key only when the buffer is empty. A real key that a `TICK` reads stays counted, as in DOS.
  The new lines run only when the program is scripted, so trace mode and the recordings it gives are as before.

The checks:

- A small program with the same lines, given F12, F12 and a space at three announced waits, gave head and
  tail 30 after each F12 and 32 after the space, with QB64Rust and QB64pe builds. `PEEK(1052) = 30` was true
  after the two F12s and false after the space.
- `WON.BAS` builds with QB64Rust, QB64pe and, through `pdsbuild.py`, PDS 7.1.
- The wrap and the F12 lines are now a QB64Rust screen program, `tests\corpus\screen\k06_bios_buffer_wrap`,
  recorded with QB64pe. After 15 keys the tail is at 60. An F12 wraps it to 30, and is set back to 60.

Left for the check: the four keys that DOS typed before their wait was announced (sessions 4 and 5 have
naval combat). The filler does not touch them. If one of them came before a checked `TICK` in DOS, the check
shows it.

### The check (2026-11-09)

`tests\play.py bridge` builds `WON.BAS` with the screen hook and plays each keys file of `tests\sessions\`
on a hidden desktop. No `SHELL` can run: the run's folder holds no `.EXE` but the build, the history file is
copied in BASIC, and `WON_OUTCOME` is always set, so no battle starts. Each run is stopped when its last state is
written. A session takes 2 to 25 seconds, so the 15 take about a minute with four at once.

**The built-in title.** The first run of session 9 went out of step at once. The recordings ran `ARCH2.EXE`,
whose picture took the first key. The port runs no `ARCH2.EXE`, so `WON.BAS` draws its built-in title, and its
`TICK 2` is one more wait. `sessions.py` now starts every keys file with a filler for that wait.

**The result.** All 15 sessions ran to their last shot with both builds. Any difference in the count of waits
would have stopped a run with exit code 124 or 125. The QB64Rust and QB64pe builds gave the same report, line
for line, so every difference below is between QB64 and DOS, not between the two compilers. Text screens (8)
are not compared yet.

- **Files.** The recordings hold 35 files that the strategic game wrote (session 9's `OUTCOME.&&&` is given,
  not written). 32 are equal byte for byte: the saved games, `NWS.CFG`, `NWS.HIS`, `HISCORE.NWS` and
  `BATTLE.$$$`. The other 3 are `NWS9.SAV` of sessions 4, 5 and 10.
- **The city markers** (`TODO.md`): 160 to 420 pixels on every map screen. This is the known `CIRCLE`
  difference.
- **D12, a SINGLE product stored as an INTEGER**, in four sessions:
  - Sessions 9 and 10, the attack on Alexander at Innsbruck (`WON1.BM` line 136, `x1 = .7 * x1` with
    `x1 = 5`). SINGLE rounds 0.7 × 5 to 3.5, and QB64 rounds that to the even 4. The x87 keeps 3.49999994 and
    stores 3. So the panel shows 4 for Cohesion, Difclt, Fort and Defend, and Odds of 42% against 50%. In
    session 9 the tactical game fights the battle and the saved game is still equal. In session 10 the
    strategic game decides it from those odds, so the game takes another course from that battle (shots 5
    to 26).
  - Session 5: army 5's supply, from DOS's wait 80 (below). The run announces one wait fewer than DOS before
    shot `12-turn-end`, so that state already shows the victory box at Salzburg. That screen also shows Base
    7 against 6 (`WON1.BM` line 111, `INT(.01 * armysize(defend))` with 700), which is display only.
  - Session 4: three numbers of `NWS9.SAV` differ by one (639 against 640, 258 against 257, 271 against
    272), with no screen that shows more than the city markers.
- **The palette after `WIDTH , 60`** (session 1, `12-cities`, 5,629 pixels). `europe` (`WONMENU.BM`
  line 56) sets palette entry 2 to the darker green 008A00. The City Report starts with `WIDTH , 60`
  (`WON2.BM` line 1292). PDS kept the palette across it, but QB64 resets entry 2 to 00AA00. This is new to
  QB64Rust's records.
- **Drawing**: the ships of naval combat (session 14, 1,700 to 3,150 pixels on 4 screens), and the burning
  building of session 2's `07-turn-end` (668). The counts, the numbers and the text are the same. Session 14
  stays in step through its three rounds of naval combat, and its saved game is equal: the F12 filler works.

### Session 5's missing wait (2026-11-09)

A scratch copy of the game, outside the repo, logged what each run did at each wait, with the PDS 7.1 build in
DOSBox-X and with QB64Rust. Every `RND` was replaced by a function that counted its calls and noted their
call site. The logs were kept in memory and written once, so that the DOS run still gave the recording.

- **The missing wait** is in the naval combat of DOS waits 307 to 356, which begins with `BuffClear`. QB64's
  combat ends one shot sooner. Its shots are DOS's, one `RND` ahead: QB64's first shot is DOS's second.
  The head and the tail of the buffer were 30 at every check, so it is not the F12 filler.
- **The extra `RND`** is at DOS wait 290, in `WON1.BM` line 1137:
  `IF supply(active) < 10 THEN supply(active) = supply(active) + 1: IF RND > .8 GOTO horde`. Both runs drew
  the same numbers. DOS's army reached supply 10 one draw sooner, so the loop drew one `RND` fewer.
- **The supply** of army 5 first differs at DOS wait 80, 9 in DOS and 10 in QB64, with the same count of
  `RND` calls in both runs. That is the month's update in `iterate` (`WON2.BM` lines 636 to 640):
  `IF cash(s) >= .2 * armysize(i) THEN … supply(i) = supply(i) + 1: cash(s) = cash(s) - .2 * armysize(i)`.
  Army 5 is French, of 75 hundreds; France had 35 before the update. The SINGLE product `.2 * 75` is
  15.0000002 on the x87, and QB64 rounds it to 15.0. With 15 left when army 5's turn comes, QB64's test is
  true and DOS's false. The 15 is inferred: the cash at army 5's turn was not logged. The comparison
  itself is measured: QB64Rust's `verification\qb45\q45_single_compare` gives false for `15 >= .2 * 75` in
  QB 4.5 and PDS 7.1 and true in QB64pe and QB64Rust, and the same for every multiple of 5 to 1000
  (`DIVERGENCES-QB45.md` Q-022).

So this is D12's kind too, in a comparison, not a store: a SINGLE expression that the x87 keeps wider than
QB64 does. A search for (b) would have to take in comparisons as well (`docs\SOMEDAY.md`).

D12 said to bring (b) back to the user if more than two or three sessions meet the rounding. Four do: 4, 5, 9
and 10. The user kept (a), and (b) is a row of `docs\SOMEDAY.md`.

## Step 7b: the tactical game's conditions, and its PDS build (2026-11-09)

The first part of the tactical references (D3): the tactical game's lines that PDS 7.1 cut short (D13), and a
PDS build to show them.

### Which lines

34 lines had `RND` or `INKEY$` next to an `AND` or `OR` in a condition. One was `TICK` (`NAP1A.BM`), already
rewritten in change 24. The other 33 all have `RND`, and no `INKEY$`. QB64Rust's
`verification\qb45\q45_and_short_circuit` sorts them. It now also measures two shapes found here:

- **A condition in parentheses as a side.** In `NAP1.BM` line 1352, `LEFTY$(index) = "Φ" AND (RND > .97 OR
  (…))`, PDS 7.1 skips the whole parenthesis when the test on the left is false. So its `RND` is skipped too,
  though it comes first inside.
- **`a OR b AND RND`.** `AND` binds closer than `OR`, so `NAP1A.BM` line 725 is `z = 43 OR (z = 46 AND RND <
  .15 * bold)`. PDS 7.1 calls its `RND` only when `z` is 46.

QB 4.5, QB64pe and QB64Rust call `RND` in every case (`.qb45.txt` and `.pds71.txt`, both recorded again).

The sort: 29 lines draw an `RND` that PDS 7.1 could skip. The other 4 draw it on the left, where PDS always
evaluates it, and stay as they are: `NAP1.BM` 1529 (`IF RND > .5 OR toa(index) > 15`) and `NAP1A.BM` 264, 865
and 1124.

### The changes

28. **The 29 lines are written so that QB64 draws the same numbers as PDS 7.1.** Each place has a comment that
    says why, as in change 24. Line numbers are those before the change.
    - **Nested single-line `IF`s:** `NAP1.BM` lines 1217, 1352, 1499, 1526, 1527 and 1530. `NAP1A.BM` lines 146
      and 147 (two each), 219, 336 to 339, 423 to 426, 428, 433, 434, 721, 722, 724, 1120 and 1121. The
      parentheses of `NAP1A.BM` lines 433 and 721 went, as the test is now alone before `THEN`.
    - **Nested block `IF`s:** `NAP1.BM` line 83, in `cannon`.
    - **`ELSEIF`:** `NAP1.BM` line 389, whose `ELSE` was `GOTO smash`. It became `IF LEFTY$(defend) <> "S" THEN
      GOTO smash`, then `ELSEIF RND < .18 * morale(defend) THEN` with the old body, and the old `ELSE`.
    - **Two lines for an `OR`:** `NAP1.BM` line 923, `IF Enemy = 0 OR RND > .5 THEN …: RETURN`, became one line
      for `Enemy = 0` and one for the `RND`, each with the same statements. `NAP1A.BM` line 725 became `IF z = 43
      THEN GOTO runn`, then `IF z = 46 THEN IF RND < .15 * bold THEN GOTO runn`.

    `NAP1.BM` line 1499 sets `amrx`, where the line before it and the rest of `randarm` use `armx`. So its `IF`
    does nothing but draw an `RND`. That is the game's own slip, kept (`TODO.md`).
29. **`tools/pdsbuild.py --game napoleon` builds the tactical game** with PDS 7.1, as change 21 builds the
    strategic game:
    - `NAPOLEON.BAS` gets `NAP1.BM`, `NAPSCRIPT.BM` and `PDS.BM` after its main code.
    - The pictures' seven `DIM SHARED` lines go back after the include of `nap10.bi`, where they were in DOS.
    - `NAP1A.BAS` and `NAP1C.BAS` get their headers of `7738434` back.

    It links them with the modules of `NAPOLEON.MAK`. No switches were recovered for the tactical game, since its
    source is not the shipped `NAPOLEON.EXE`, so it takes the strategic game's: `/O /E /Fs /C:512` for the main
    module and `/O /Fs /C:512` for the others. `include_name` now also reads the `REM $INCLUDE:` form, which
    `NAPOLEON.BAS` uses.

### The checks

- **PDS 7.1** compiles the three modules with no warning, and LINK makes a `NAPOLEON.EXE` of 158,446 bytes.
- **The strategic build is unchanged:** the old and the new `pdsbuild.py` write the same four modules for
  `WON.EXE`, byte for byte.
- **QB64Rust 0.3.0 and QB64pe 4.7.0** build `NAPOLEON.BAS` with no warning, and with the same messages as
  before the change.
- **Not checked yet: what the battles do.** No battle has been played with either build. The tactical game has
  no recording from its source, so there is nothing to compare a run with until the references of D3 are made.

### What the references still need: a mode of `PLAYKEYS.COM` that waits

The game's side is ready. `NAPSCRIPT.BM` announces every wait in DOS too (bytes `0:4F0h` to `4F2h`). With
`NAP_SEED` alone, the PDS build is scripted as the QB64 builds are: a `TICK` of a second or more waits for a
key, and a shorter one returns at once. `napstart` only reads the environment, so PDS 7.1's `ENVIRON` problem
of step 6 does not arise.

`PLAYKEYS.COM` is the missing part. It types each key after a fixed number of timer ticks, and its trace mode
only logs the waits. A tactical keys file has no recording behind it, so its keys must come at announced waits,
as the screen tool gives them to the QB64 builds. That needs a mode that holds the next key until the count at
`0:4F0h` changes. Trace mode already reads that count at every tick, so the new mode is small.
