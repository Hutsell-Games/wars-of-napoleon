# Recovering `WON.EXE`'s source: the procedure table

This is the working record of the recovery planned in `docs\won-source-study.md` (study 45). It holds the
table of step 3: each procedure of the shipped `WON.EXE`, paired with its counterpart in Civil War Strategy.
It also holds the facts the tools found that step 4 (writing the source) needs, and the open questions.

The tools are in `tools\recover\`; their `README.md` gives the commands. The scratch files they read and write
were in `..\won-hutsellgames\work\`, outside the repo, which was deleted on 2026-11-12. Its scripts and drafts
are kept in `tools\recover\drafts\` (its `README.md` says what each is).

**The exact build works on `canonical-recovery` only** (named `won-source` until 2026-11-09). On `main` and
`qb64rust`, the port has moved and edited the source files (`docs\devnotes.md`, step 4), so the commands of
`docs\won-source-study.md` section 12 no longer give `WON.EXE` there.

## Summary (2026-11-06)

- **`WON.EXE` has 66 procedures:** 17 in module `WON`, 44 in `WON2` and 5 in `WONMENU`. Civil War Strategy
  1.57 has 76: 28 in `CWSTRAT`, 42 in `CWSTRAT2` and 6 in `CWSMENU`.
- **87% of the procedure code pairs with Civil War Strategy:**

  | Kind | Procedures | Bytes | Share |
  |---|---|---|---|
  | same: equal instruction shapes | 11 | 2,484 | 3% |
  | changed: 50% or more of the instructions align | 37 | 76,021 | 84% |
  | new: less than 50%, written from the disassembly | 18 | 12,081 | 13% |

- **The module-level code pairs too.** The code outside procedures aligns 70% between `WON` and `CWSTRAT`
  (13,344 and 14,483 bytes), 83% between `WON2` and `CWSTRAT2`, and 77% between `WONMENU` and `CWSMENU`.
- **The panel's checkpoint is passed.** Section 7 of the study asked the panel to meet again before step 4 if
  more than about 60% of the program had no counterpart. About 13% has none.

## How the table was made

1. `procsplit.py` splits each module's code into procedures. BC starts every SUB and FUNCTION with
   `mov cx, FRAME / mov bx, TEMPS / call far B$ENRA` and ends it with `call far B$EXSA / retf ARGS`.
   It finds the 76 procedures of Hutsell's Civil War Strategy objects, the same number as the source has.
2. `compare.py` was checked first on Civil War Strategy. Its three modules, compiled with `/O /Fs`
   (`CWSTRAT` also with `/E`), were compared with the unpacked `CWS.EXE`. All 76 procedures and the three
   module-level bodies are exact, and the three constant segments (`BC_CN`) are equal. As a negative check,
   `"M E N U"` was changed to `"M E N V"` in `CWSMENU.BAS`. The code stayed exact, and `BC_CN` showed the
   one changed byte.
3. `pairprocs.py` compares each `WON.EXE` procedure with each Civil War Strategy procedure by shape. It then
   pairs each module in order, as the next section explains.

## Facts for step 4

**Procedures are in alphabetical order.** The QBX editor keeps a module's SUBs and FUNCTIONs sorted by name,
and BC compiles them in the order of the file. Civil War Strategy's modules are sorted this way. The paired
procedures of each `WON.EXE` module are also in alphabetical order of their Civil War Strategy names, with
no exception. So a new procedure's name must sort between its neighbors' names. For example, `WON2.05` and
`WON2.06` lie between `BUBBLE` and `CANCEL`. The names in parentheses in the table only fit that order; they
are not pairs.

**Five procedures moved from `CWSTRAT` to `WON2`:** `CUTOFF`, `ITERATE`, `NAVY`, `NORMAL` and `SMARTS`.

**Civil War Strategy names that pair with nothing (22):** `ARMYSTAT`, `ARMYXY`, `BURN`, `CANNON`, `CAPITOL`,
`CHESSIE`, `ENGINE`, `FLAGS`, `INTEGRITY`, `IRONCLAD`, `RAILROAD`, `RWIN`, `SCRNSAVR`, `SHEN`, `SHIPTYPE`,
`SHOWCITY`, `SURRENDER`, `TINYTRAIN`, `TOPBAR`, `TOUCHUP`, `TRAINCAPACITY` and `USA`. Most are about the
Civil War: railroads, ironclads, the Union. Some new procedures may be rewrites of them under the same name.
For example, `WON2.06` (1,495 bytes, between `BUBBLE` and `CANCEL`) is 41% like `CAPITOL`.

**The module header names each data segment's place.** BC's code segment starts with a 46-byte header: the
marker `bl` and the module name, then the DGROUP offsets of the module's segments. They are `BC_DS` at +0Ch,
`BC_DATA` at +0Eh, `BC_FT` at +10h, `COMMON` at +18h and `BC_CN` at +20h. `compare.py` reads them, so it
knows where each module's constants are without having to guess.

| Module | `BC_CN` (constants) | `BC_DATA` | Word +22h |
|---|---|---|---|
| `WON` | DGROUP+1F90h | DGROUP+0912h | 0008 |
| `WON2` | DGROUP+3410h | DGROUP+1EAAh | 0000 |
| `WONMENU` | DGROUP+4B30h | DGROUP+1F16h | 0000 |

**`WON` was compiled with `/E`; `WON2` and `WONMENU` were not.** The word at +22h is nonzero only with `/E`.
For Civil War Strategy it is 0006 in `CWSTRAT` (`/O /E /Fs`) and 0000 in the other two (`/O /Fs`). So the
compile switches are `WON=O,E,Fs,C:512`, `WON2=O,Fs,C:512` and `WONMENU=O,Fs,C:512`.

**The word at +2Ch is BC's `/C:n` switch, the size of the COM port buffer** (found 2026-11-07). Without the
switch BC writes FFFF there. With `/C:512` it writes 0200h, the bytes `00 02`, which is what Hutsell's objects
and `WON.EXE` hold in every module. (The earlier note read the two bytes as "0002".) 512 is also BC's default
buffer size, so the switch changes nothing else: `WONMENU` compiled with and without it differs only in these
two bytes. Hutsell's `CWSMENU.OBJ` and ours compiled with `/O /Fs /C:512` have every segment equal.
`compare.py` now checks this word like the rest of the header.

**The `COMMON SHARED` block is 2,242 bytes, 4 more than Civil War Strategy's 2,238.** `commonmap.py` worked
out `CWS14.BI`'s layout from BC's sizes: INTEGER 2 bytes, SINGLE 4, an array's descriptor 46. The total is
2,238 bytes, which matches the objects. Then it mapped each variable to its place in `WON.EXE` through the
aligned instructions:

- From `choose%` to `rating()` (offsets 0000h to 0265h), the layout is the same.
- `rflag` moved to 07C8h. `nflag`, `bold` and `turbo!` moved 2 bytes down, to 0266h–026Dh.
- `WON.EXE` uses integers at 026Eh and 0270h. Four of the five arrays `rr()`, `starx()`, `stary()`, `mtn()`
  and `rrfrom()` are not found. They are railroad and map arrays, which Wars of Napoleon may not have.
- From `image()` to `grudge`, nearly every variable is found, 136 to 230 bytes lower than in Civil War
  Strategy. `price()`, `bw`, `train()`, `font$()`, `realism` and `pcode` are not found.
- Eight offsets are used directly and match no Civil War Strategy variable. They are 0150h, 026Eh, 0270h,
  073Ah, 07CAh, 07CCh, 0834h and 08C0h; 0834h is used 64 times. These are Wars of Napoleon's own variables.

Step 4 writes the `.BI` from this. `compare.py` checks it: each reference to `COMMON` must point to the same
place as in `WON.EXE`.

## Step 4: the source so far

| Module | Status | Source |
|---|---|---|
| `WONMENU` | **exact** (2026-11-06): all 5 procedures, the module-level code and the constant segment equal `WON.EXE` byte for byte | `WONMENU.BAS`, `WON.BI` |
| `WON2` | **exact** (2026-11-06): all 44 procedures, the module-level code and the constant segment (5,906 bytes) | `WON2.BAS`, `WON.BI` |
| `WON` | **exact** (2026-11-06): all 17 procedures, the module-level code (13,275 bytes) and the constant segment (5,240 bytes) | `WON.BAS`, `WON.BI` |

`compare.py` on the three objects compiled from the repo together
(`calibrate_bc.py . PDS W WON=O,E,Fs,C:512 WON2=O,Fs,C:512 WONMENU=O,Fs,C:512`) reports
`69 exact, 0 shape, 0 differ`: the 66 procedures and the three module-level bodies. The three constant
segments are equal, and so are the three headers. Every call between the modules is checked: it calls the
paired procedure. Checking them found one mistake in `WON2.BAS`, now fixed: `navy` called `showcity`, Civil
War Strategy's name, where `WON.EXE` calls `showcities`.

**The whole program is exact too (step 5, 2026-11-07).** The three objects, linked with `tools\recover\WON.LNK`
and `buildlib.py`'s library, give a program whose unpacked load image equals the unpacked `WON.EXE` byte for
byte: 193,056 bytes, the same 4,438 relocations and the same entry point. Section 12 of the study has how.

`WON2.BAS` is built from Hutsell's `CWSTRAT2.BAS` and `CWSTRAT.BAS` (for the five procedures that moved), with
edits; the procedures that exist in neither were written from the disassembly. The drafts and the edit lists that
produced it are in `tools\recover\drafts\` (`make_won2.py`, `edits_won2.py`, `new\`); the repo keeps the
result.

**How `WONMENU` differs from `CWSMENU`:**

- `europe` (`WONMENU.02`) is new. It draws the map of Europe with about 40 `DRAW` strings, as `usa` draws the
  map in Civil War Strategy. It was written from `disasm.py --lift` and `lift2bas.py`, and was exact on the
  second compile.
- `choices` moves a menu that would run off the right edge, and clears its box with black `LINE ... BF` boxes
  instead of `VIEW` and `CLS 1`.
- `menu` saves the screen under the menu in a local array `box(1 TO 13000)` with `GET`, and puts it back with
  `PUT`. It no longer draws the box itself, shows the generals' faces (`CASE 8`) or runs the screen saver.
  `CASE 4` shows the army's name and size. F1 shows a "Hot Keys" box instead of running `cwsdoc.com`. `>`
  calls `report` with two arguments.
- `schooner` has some coordinates moved and one more figure.
- `ironclad` and `scrnsavr` are gone.
- The module-level code has four lines of a battle screen ("Attacker"), which never run.

**What `WON.BI` holds so far.** The `DECLARE`s are `CWS14.BI`'s, with the new procedures added and `report`
given two parameters. The `COMMON SHARED` and `DIM SHARED` lines come from `WONMENU`'s `B$DDIM` calls, which
give every shared array's bounds and descriptor place. The variables Civil War Strategy does not have first
had placeholder names `uNNN`, after their `COMMON` offset; their names are under "Variable names" below. Found
on the way:

- `cities = 67`, set before the `DIM`s, is the upper bound of every city array. It is the variable at
  `COMMON`+0834h, the one used 64 times. Civil War Strategy has 40 cities, as constants.
- `homenat(50)` is a shared static array in the `.BI`, so each module has its own copy in its `BC_DATA`; only
  `WON` uses it. Its lower bound is 0: `WON`'s code reads element *i* at 1DA4h + 2*i*. It holds each army's home
  nation (see "How `WON` differs" below). An earlier draft had it as `graphic(1 TO 51)`.
- `bw` is not in `COMMON`: `menu`'s `IF bw > 0` reads a local variable, which is always 0. The `COMMON` slot at
  073Ah, after `usadv`, is another variable.
- `mtnx(19)` and `mtny(19)` hold where `europe` puts the 19 mountains.

**How `WON` differs from `CWSTRAT`.** `WON.BAS` keeps Hutsell's `CWSTRAT.BAS` text wherever the code is the
same; the rest was written from `disasm.py --lift`. In `tools\recover\drafts\`, `make_won.py` builds it from
`new\won_main1.txt` (module-level code to the main menu), CWS lines 278–704 edited by `edits_won.py`,
`new\won_tail.txt` (the module's subroutines) and `new\*.bas` (the procedures). Changes, in brief:

- The module-level code: a tricolor title screen; seven 17×14 icons (`nap`, `fren`, `nat2`–`nat6`) cut from
  `napicon.vga` with `GET`; a start menu (Resume Saved Game, Start NEW Game, Quit to DOS); a main menu without
  Railroad; a Commands menu without Capital (Detach is open to both sides); a Utility menu with Tactical and
  Save CFG and without Graphics, Jan Campgn, Realism and Chk Links. The settings file is `nws.cfg`. There are
  no `DATA` lines.
- `filer` reads `gamedata.ini` (`CASE -1`), starts a scenario from `nws<name>.ini`, `lead<name>.dat` and
  `euro<name>.map`, where *name* is `scenario$`, and saves to `nws1.sav`–`nws9.sav`. `filer(9)` saves to slot 9
  without a menu.
- `battle` can hand the battle to the tactical game: it writes `battle.$$$`, runs `napoleon.exe` and reads
  `outcome.&&&`. It does so when Tactical is on (`tactical`), `rrs.exe` is absent, and neither army is more
  than three times the other. Armies whose nation differs from their home nation (`armynat()` against
  `homenat()`) fight at 70% ("LOW COHESION").
- `placearmy` puts the army's icon by nation. `armies` lists a move when `matrix(c, 7)` of either city is below
  90 (an inland city), or the side's fleet holds the city. Otherwise it refuses the move when either city is one
  of the four islands in `island()`. `tupdate` draws a surrender flag, and moves Napoleon (army 1) to city 16
  (Corsica) when he is beaten.
- `showcities` (new) redraws every city with `cityicon`; `recruit`, `icon`, `movefrom`, `newarmy` and
  `animate` changed in many small ways.

**Variable names (user, 2026-11-07).** These variables are not in Civil War Strategy, so they had placeholder
names after their `COMMON` offset (`homenat` after its address in `BC_DATA`). The user chose the names below
(D6). None of them has a counterpart in Civil War Strategy's source. `rescue` sits after `usadv`, where Civil
War Strategy has `bw`, but it means something else. The renamed source compiles to the same three object
files, byte for byte.

| Name | Was | What it holds |
|---|---|---|
| `scenario$` | `u29c$` | The chosen start year, such as `"1796"`, part of every scenario file name. `init` sets it. |
| `tactical` | `u8c0` | The Tactical switch, saved in `nws.cfg`. When on, battles go to `napoleon.exe`. |
| `island()` | `u2a0()` | The four islands, read from the last line of `gamedata.ini`: 16, 35, 57, 58 (Corsica, London, Sardinia, Sicily). |
| `armynat()` | `u558()` | Each army's nation now. |
| `homenat()` | `u1da4()` | Each army's home nation: 1 for the French, read from `lead*.dat` for the others. Only `WON` uses it. |
| `nation$()` | `u836$()` | The 12 nations' names, from `gamedata.ini`. |
| `attitude()` | `u892()` | Each nation's attitude, 0 to 99: PEACE below 25, UNEASE to 50, WAR! above. |
| `rescue` | `u73a` | 16 while Napoleon's army is stranded on Corsica. The French computer player then sails its fleet there and buys no ships. |
| `navyto` | `u7ca` | A city the computer's fleet is to sail to. `smarts` sets it when an army's move needs a boat and cancels the move; `navy` sails there and clears it. |
| `spare()` | `u864()` | Never used. It stays because removing it would shift the `COMMON` offsets after it. |

`matrix(c, 7)` is 0 for an inland city and above 90 for a coastal one, as in Civil War Strategy. A fleet may
sail to any coastal city. The two games use the values above 90 differently:

- Civil War Strategy uses only 99 for its ports. It sells ships only at a city with 99.
- Wars of Napoleon sells ships at any coastal city (`navy`, `WON2.BAS` line 800). Its maps use 96 to 99, and
  `ships` uses the value to place the fleet's icon beside the city: 96 to the right, 97 to the left, 98 above,
  99 below. In the 1796 map, 96 is London and Sardinia, 97 Bordeaux, Corsica, Nantes, Naples and Sicily, 98
  Amsterdam, Brest, Cherbourg and Konigsberg, and 99 Genoa, Marseilles, Nice and Venice.
- In Wars of Napoleon, 99 also matters to supply (`WON2.BAS` lines 645–646). An army in any other city, inland or
  coastal, loses supply in every month outside July to October. An army in a 99 city loses supply when the enemy fleet is there ("is
  blockaded").

`cityo()` is in both games with different meanings. In Civil War Strategy it is each city's side at the start
(`cityo(i) = cityp(i)`). In Wars of Napoleon it is each city's nation.

`battle` writes the attacker's leader rating for both armies into `battle.$$$`: the `WRITE #1` at `WON.BAS`
line 829 has `armylead(attack)` where the defender's would be. The shipped program does the same, so the source
keeps it.

**Source used, and in what order.** A procedure comes from Hutsell's own source wherever there is any:
Civil War Strategy 1.57 first, then the tactical game (`NAPOLEON.BAS`, `NAP1A.BAS`, `NAP1C.BAS`). Every
`WON.EXE` procedure was compared with both, by `pairprocs.py` (the tactical modules compiled with
`/O /E /Fs`). Only where neither has it is a procedure written from the disassembly. The tactical game shares
`BuffClear`, `clrbot` and `normal` with `WON.EXE`; Civil War Strategy already has the other two.

**Names chosen so far (D6).** Each sorts between its neighbors, as the QBX editor keeps them:

| Procedure | Name | Why |
|---|---|---|
| `WONMENU.02` | `europe` | draws the map of Europe |
| `WON2.07` | `calendar` | draws a box with the month and year |
| `WON2.16` | `disband` | its message is " army has disbanded" |
| `WON2.41` | `stencil` | draws text letter by letter with `DRAW` |
| `WON2.25` | `labels` | calls `stencil` in a loop (to be checked) |
| `WON.14` | `showcities` | calls `cityicon` for each city, 1 to `cities` |
| `WON2.37` | `ships` | Civil War Strategy's `ships`, 46% alike |
| `WON.12` | `placearmy` | Civil War Strategy's `placearmy`, 34% alike |
| `WON2.01` | `barnacle` | Hutsell's name: it is called where Civil War Strategy calls `barnacle` (a ship lost) |
| `WON2.02` | `bossarmy` | shows each city's largest army |
| `WON2.05` | `BuffClear` | Hutsell's own, copied from the tactical source (`NAPOLEON.BAS`): it compiles to the same code |
| `WON2.06` | `bunting` | a picture, called when a capital falls (to be checked) |
| `WON2.11` | `cityicon` | draws one city (`city` would clash with `city$()`) |
| `WON2.18` | `enter` | " has entered the WAR!" |
| `WON2.21` | `findcity` | the city within 13 pixels of a point |
| `WON2.23` | `init` | chooses a scenario (`nws*.ini`, "Start Year") |

**More of what `WON.BI` holds** (from `WON2`):

- Wars of Napoleon has 50 armies, 25 a side, where Civil War Strategy has 40 and 20.
- `cityo()` holds each city's nation; `nation$()` the nations' names (12); `armynat()` each army's nation;
  `attitude()` each nation's leaning, 0 to 99: above 50 it is at war.
- `realism` is not in `COMMON`; `resupply` always checks the supply line.
- `COMMON`+029Ch is one string, the chosen start year (`init` sets it); +07CCh is `pcode`, as in Civil War
  Strategy; +0266h is `nflag`, which `smarts` sets after each naval action; +073Ah (`rescue`) and +07CAh
  (`navyto`) are naval flags that `smarts` reads.

**Ways of writing found by trying.** Where BC's code depends on how a statement is written:

- A value tested twice must be in a variable: `p = POINT(...): IF p = 1` (`labels`), `z = POINT(...)`
  (`stencil`).
- `x1 * .1 * armysize(c)` multiplies as floating point; `x1 * armysize(c) * .1` multiplies as integers first.
- `IF a THEN IF b THEN` and `IF a AND b THEN` give different jumps. A conditional `GOTO` ends BC's reuse of
  computed values where a nested block `IF` does not.
- When the program has fewer locals than the draft, a variable of the draft is one already used elsewhere in
  the procedure: `relieve`'s, `iterate`'s and `smarts`'s new lines reuse `x`, `y` and `a`. When it has more, a
  part of the procedure uses its own name where Civil War Strategy reuses one (`report`'s intelligence page,
  `navy`'s invasion).
- BC pads the start of a loop (`FOR`, `DO`) with `NOP` but not a label reached by `GOTO`: a loop written with
  `GOTO` where the program has the padding was a `DO WHILE ... LOOP` (`init`).
- BC keeps one copy of equal string literals in a module. A constant that points back at an earlier one shows a
  text that is now the same: `"nws.his"` in `scribe` and `report`, `" side close to"` (Civil War Strategy lacks
  the space in one place).
- The place a `GOTO` lands shows where a label is, even inside a block: `menu`'s `CASE 1` jumps into `CASE 2`,
  `navy`'s `admiral:` stands before a new line.

The city page of `report` shows each nation's `attitude()` as "PEACE" below 25, "UNEASE" to 50, and "WAR!"
above.

**What BC does, learned on the way.** These decide how the source must be written:

- A line label resets BC's reuse of computed values. A label in the wrong place, or a missing one, changes which
  registers and temporaries the next statements use.
- After an unconditional `GOTO`, BC emits no jump to the end of the `SELECT CASE` or block.
- BC pads the start of a loop to an even address with `NOP`. So a procedure's bytes change with the size of the
  code before it; `compare.py` leaves the `NOP` out of the shapes.
- BC frees a SUB's local dynamic arrays at its end (`B$ERAS`); there is no `ERASE` in the source.
- A long expression passed to `PALETTE` is computed before the other argument only if it is first stored in a
  variable. `europe` has `c& = 65536 * a + 256 * x + y: PALETTE 2, c&`.

Learned on `WON`:

- BC sometimes loads the right operand first. `k + x - 7` compiles as `mov ax, x / add ax, k`, so the program's
  `mov ax, k / add ax, x` was written `x + k - 7` (`tupdate`). The same holds for comparisons: the program's
  `mov ax, side / cmp ax, s` was written `s <> side`.
- An `IF` whose conditions are all comparisons joined by `AND` or `OR` compiles to a chain of jumps. One term
  that is not a comparison, such as `NOT (...)` or `a > 3 XOR b > 3`, makes BC compute the whole condition as a
  value. `battle` has three lines, `IF tactical <= 0 GOTO grapple`, `IF LEN(DIR$("rrs.exe")) <> 0 GOTO grapple` and
  `IF ... XOR ... GOTO grapple`; the last tests the `XOR` with `and dx, dx`.
- A string literal passed to a SUB from module-level code is copied to a temporary that BC frees after the call
  (`B$STDL`). Where the program has no `B$STDL`, the text was first put in a variable (`obj$`, `m$`).
- `DATA` lines at the end of the module-level code add seven `NOP`s after the last `RETURN`.
- A static array's lower bound shows in the code: `[si + 1DA4h]` with `si` = 2 × *i* means element 0 is at
  1DA4h.

## Open questions

1. **What sets the word at +2Ch of the module header?** Settled (2026-11-07): BC's `/C:512`. See "Facts for
   step 4" above.
2. **Is the word at +22h the size of something?** It is 0006 in `CWSTRAT` and 0008 in `WON`, so it is not a
   flag. It may count `RESUME` line-table entries or error handlers. This needs no answer as long as the
   compiled module's word equals the program's; `compare.py` prints both.
3. **Which `DECLARE`s did Hutsell's `.BI` have?** A `DECLARE` for a procedure that is never called leaves no
   trace in the program. `WON.BI` keeps all of `CWS14.BI`'s, including ones for procedures Wars of Napoleon
   no longer has (`showcity`, `usa`, `railroad` and others). They do not change the code.
4. **Names for the `uNNN` placeholders.** Settled (user, 2026-11-07): see "Variable names" above.

## The table

One row per procedure of `WON.EXE`, in program order. *Address* is the start in the unpacked load image.
*Params* comes from the procedure's `RETF`. *Aligned* is the share of instructions in equal runs of 4 or more.
*Civil War Strategy* is the paired procedure, with its module when that is not the matching one. For a new
procedure, it gives a name that fits the alphabetical order, if one scored 15% or more, and the nearest
procedure by score alone. *Called from other modules* lists the callers outside the procedure's own module.

| Procedure | Address | Bytes | Params | Kind | Aligned | Civil War Strategy | Its bytes | Called from other modules |
|---|---|---|---|---|---|---|---|---|
| `WON.01` | `03409` | 1059 | 2 | changed | 80% | ANIMATE | 847 | - |
| `WON.02` | `0382f` | 1052 | 0 | changed | 80% | ARMIES | 760 | - |
| `WON.03` | `03c4e` | 7455 | 4 | changed | 78% | BATTLE | 6194 | - |
| `WON.04` | `05970` | 1841 | 1 | changed | 99% | COMBINE | 1850 | WON2.38 |
| `WON.05` | `060a4` | 5626 | 1 | changed | 67% | FILER | 4506 | - |
| `WON.06` | `076a1` | 233 | 1 | changed | 64% | FLASHCITY | 448 | WON2.09, WON2.20 |
| `WON.07` | `0778d` | 954 | 1 | changed | 99% | FORTIFY | 968 | - |
| `WON.08` | `07b4a` | 1971 | 3 | changed | 93% | ICON | 1810 | WON2.08, WON2.11, WON2.27, WON2.30, WON2.38, WONMENU.03 |
| `WON.09` | `08300` | 721 | 2 | changed | 86% | MOVEFROM | 613 | - |
| `WON.10` | `085d4` | 711 | 4 | changed | 85% | NEWARMY | 593 | WON2.27 |
| `WON.11` | `0889e` | 501 | 1 | same | 100% | NEWCITY | 501 | - |
| `WON.12` | `08a96` | 552 | 1 | new | 34% | (PLACEARMY?) | 219 | WON2.16, WON2.20, WON2.24, WONMENU.03 |
| `WON.13` | `08cc1` | 2564 | 1 | changed | 87% | RECRUIT | 2315 | WON2.38 |
| `WON.14` | `096c8` | 53 | 0 | new | - | -; nearest MXW 42% | - | WON2.09, WON2.27, WON2.38, WONMENU.02 |
| `WON.15` | `09700` | 148 | 3 | same | 100% | SNAPSHOT | 148 | - |
| `WON.16` | `09797` | 84 | 1 | same | 100% | STRONG | 84 | WON2.31, WONMENU(module) |
| `WON.17` | `097ee` | 7261 | 0 | changed | 81% | TUPDATE | 6997 | - |
| `WON2.01` | `0b8e9` | 82 | 1 | new | 34% | (BARNACLE?) | 202 | WON.17 |
| `WON2.02` | `0b93e` | 247 | 0 | new | - | -; nearest STAX 46% | - | WON.17 |
| `WON2.03` | `0ba38` | 126 | 1 | changed | 93% | BUB2 | 125 | WON.17 |
| `WON2.04` | `0bab9` | 167 | 1 | same | 100% | BUBBLE | 167 | WON.02, WON.09, WON.13 |
| `WON2.05` | `0bb63` | 53 | 0 | new | - | -; nearest TICK 0% | - | - |
| `WON2.06` | `0bb9b` | 1495 | 0 | new | - | -; nearest CAPITOL 41% | - | - |
| `WON2.07` | `0c175` | 307 | 0 | new | - | -; nearest ENGINE 43% | - | WON(module), WON.03, WON.05, WON.17, WONMENU.03 |
| `WON2.08` | `0c2ab` | 814 | 1 | same | 100% | CANCEL | 814 | WON(module) |
| `WON2.09` | `0c5dc` | 1089 | 4 | changed | 56% | CAPTURE | 752 | WON.17 |
| `WON2.10` | `0ca20` | 78 | 2 | same | 100% | CENTER | 78 | - |
| `WON2.11` | `0ca71` | 822 | 1 | new | - | -; nearest SHOWCITY 48% | - | WON.06, WON.14, WON.17 |
| `WON2.12` | `0cdaa` | 78 | 0 | same | 100% | CLRBOT | 78 | WON(module), WON.02, WON.03, WON.04, WON.05, WON.07, WON.10, WON.13, WON.17, WONMENU.03 |
| `WON2.13` | `0cdfb` | 62 | 0 | changed | 58% | CLRRITE | 62 | WON(module), WON.02, WON.09, WON.11, WON.13 |
| `WON2.14` | `0ce3c` | 314 | 2 | same | 100% | COMMANDER | 314 | WON(module), WON.13 |
| `WON2.15` | `0cf79` | 105 | 3 | changed | 99% | CUTOFF (in `CWSTRAT`) | 104 | WON(module), WON.10, WON.13 |
| `WON2.16` | `0cfe5` | 449 | 0 | new | - | -; nearest STAX 34% | - | WON.03, WONMENU.02 |
| `WON2.17` | `0d1a9` | 783 | 0 | changed | 96% | ENDIT | 795 | WON(module) |
| `WON2.18` | `0d4bb` | 343 | 1 | new | - | -; nearest SHIPS 33% | - | WON.03, WON.17 |
| `WON2.19` | `0d615` | 3013 | 2 | changed | 81% | EVALUATE | 2283 | - |
| `WON2.20` | `0e1dd` | 2572 | 0 | new | 33% | (EVENTS?) | 3045 | - |
| `WON2.21` | `0ebec` | 124 | 3 | new | - | -; nearest OCCUPY 31% | - | - |
| `WON2.22` | `0ec6b` | 576 | 2 | changed | 100% | IMAGE2 | 574 | WON(module), WON.03, WON.17 |
| `WON2.23` | `0eeae` | 502 | 0 | new | - | -; nearest NEWCITY 17% | - | WON(module) |
| `WON2.24` | `0f0a7` | 1136 | 0 | changed | 89% | ITERATE (in `CWSTRAT`) | 1035 | WON.17 |
| `WON2.25` | `0f51a` | 221 | 0 | new | 24% | (MAPTEXT?); nearest SHIPS 32% | 347 | WONMENU.02 |
| `WON2.26` | `0f5fa` | 1611 | 0 | new | 43% | (MAXX?) | 1512 | - |
| `WON2.27` | `0fc48` | 9514 | 2 | changed | 83% | NAVY (in `CWSTRAT`) | 10114 | WON(module) |
| `WON2.28` | `12175` | 112 | 3 | changed | 99% | NORMAL (in `CWSTRAT`) | 113 | WON.03 |
| `WON2.29` | `121e8` | 103 | 1 | changed | 99% | OCCUPY | 104 | WON(module), WON.01, WON.05, WON.07, WON.13, WON.17 |
| `WON2.30` | `12252` | 1218 | 1 | changed | 97% | RELIEVE | 1210 | WON(module) |
| `WON2.31` | `12717` | 6877 | 2 | changed | 85% | REPORT | 6233 | WON(module), WONMENU.03 |
| `WON2.32` | `141f7` | 479 | 1 | changed | 99% | RESUPPLY | 489 | WON(module) |
| `WON2.33` | `143d9` | 430 | 2 | changed | 97% | RETREAT | 444 | WON.17 |
| `WON2.34` | `1458a` | 298 | 2 | changed | 98% | ROMAN | 288 | - |
| `WON2.35` | `146b7` | 162 | 2 | same | 100% | SCRIBE | 162 | WON(module), WON.03, WON.17 |
| `WON2.36` | `1475c` | 418 | 1 | changed | 76% | SHIPICON | 450 | - |
| `WON2.37` | `14901` | 572 | 0 | new | 46% | (SHIPS?) | 424 | WON.17, WONMENU.02 |
| `WON2.38` | `14b40` | 4171 | 0 | changed | 89% | SMARTS (in `CWSTRAT`) | 3681 | WON.17 |
| `WON2.39` | `15b8e` | 52 | 3 | same | 100% | STARFIN | 52 | WON(module), WON.04, WON.05, WON.07, WON.09 |
| `WON2.40` | `15bc5` | 369 | 1 | changed | 69% | STAX | 210 | WON(module), WON.04, WON.07, WON.17, WONMENU.02 |
| `WON2.41` | `15d39` | 250 | 4 | new | - | -; nearest MAPTEXT 31% | - | WONMENU.02 |
| `WON2.42` | `15e36` | 86 | 1 | same | 100% | TICK | 86 | WON(module), WON.01, WON.02, WON.03, WON.04, WON.06, WON.07, WON.08, WON.10, WON.13, WON.17, WONMENU.03 |
| `WON2.43` | `15e8f` | 2764 | 0 | changed | 86% | VICTOR | 3010 | WON(module) |
| `WON2.44` | `1695e` | 310 | 2 | changed | 100% | VOID | 311 | - |
| `WONMENU.01` | `16fcf` | 603 | 2 | changed | 74% | CHOICES | 506 | - |
| `WONMENU.02` | `1722d` | 1826 | 0 | new | 17% | (MAXX?); nearest CAPITOL 33% | 1512 | WON(module), WON.03, WON.05, WON2.17, WON2.27, WON2.31, WON2.43 |
| `WONMENU.03` | `17952` | 3937 | 1 | changed | 71% | MENU | 3755 | WON(module), WON.02, WON.04, WON.05, WON.07, WON.09, WON.11, WON.13, WON.17, WON2.08, WON2.17, WON2.23, WON2.27, WON2.30, WON2.31, WON2.33, WON2.43 |
| `WONMENU.04` | `188b6` | 94 | 1 | changed | 99% | MXW | 93 | WON2.22 |
| `WONMENU.05` | `18917` | 5986 | 0 | changed | 99% | SCHOONER | 5870 | WON2.27 |
