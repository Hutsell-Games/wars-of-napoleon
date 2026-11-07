# Tools for recovering the strategic game's source

`WON.EXE` came without its source. These scripts support getting it back by
compiling BASIC with Microsoft BASIC PDS 7.1 until the result matches
`WON.EXE`. The plan is `docs\won-source-study.md` (study 45, moved here
from the QB64Rust project).

They need Python 3, DOSBox 0.74-3 at its default install path, and PDS 7.1
(`BC.EXE`, `LINK.EXE`, `BCL71ENR.LIB`, `QBX.LIB` and the `NO*.OBJ` stubs) in
one folder. `normalign.py`, `compare.py`, `pairprocs.py` and `commonmap.py` also need the
`capstone` package. DOSBox runs
with SDL's dummy video driver, so no window opens.

| Script | What it does |
|---|---|
| `unlzexe91.py PACKED.EXE OUT.EXE` | Unpacks LZEXE 0.91, then EXEPACK (LINK's `/E`), giving a plain MZ file with its relocations. `WON.EXE`, `NAPOLEON.EXE` and Civil War Strategy's `CWS.EXE` are packed both ways. |
| `omfdump.py A.OBJ [B.OBJ]` | Lists an object file's module name and segments. With two files, counts equal code bytes per segment. |
| `calibrate_bc.py SRC PDS71 WORK MODULE[=SWITCHES] ...` | Compiles modules with BC 7.10. Switches are letters without slashes, such as `CWSTRAT=O,E` (default `O,E`), because Git Bash turns an argument with a slash into a path. Exits with 1 if a module gives no object file. |
| `linkcheck.py [--drop STUB] PDS71 WORK FILE.LNK SHIPPED.EXE OBJ...` | Links with a response file such as `NWS.LNK`, unpacks the result and the shipped program, and compares them. |
| `normalign.py WON_UNPACKED.EXE BUILT SHIPPED` | Compares code as instruction shapes (numbers masked) between the unpacked `WON.EXE`'s modules and the Civil War Strategy objects compiled into `BUILT`. As a control, also compares the compiled `CWSMENU.OBJ` with Hutsell's in `SHIPPED`. |
| `omflib.py FILE.LIB [MODULE]` | Reads an OMF library or object file: each module's segments, the bytes LINK fills in (fixups), and its public names. Lists the modules, or one module's segments and names. |
| `buildlib.py PDS71 OUT` | Builds the runtime library Hutsell linked with into `OUT`, with copies of `LINK.EXE`, `QBX.LIB` and the stubs, so that `OUT` can be the PDS folder of `linkcheck.py`. It is the far-string library (see below). |
| `runtimemap.py UNPACKED.EXE OUT.tsv LIB...` | Finds each library module's code in an unpacked program, with fixups as wildcards, and writes the address of each runtime routine (`B$PESD`, `B$OPEN`, ...) to `OUT.tsv`. Checks that every far call from the game's code into the runtime hits a name. |
| `procsplit.py UNPACKED.EXE RUNTIME.tsv MODULE... [--tsv OUT]` or `procsplit.py FILE.OBJ...` | Splits module code into its SUBs and FUNCTIONs, from BC's entry (`mov cx / mov bx / call far B$ENRA`) and exit (`call far B$EXSA / retf`). Lists each one's place, size, frame, parameters, calls and callers in other modules. In a program, procedures are labeled `MODULE.NN` in order; in an object file they get their public names. |
| `compare.py UNPACKED.EXE RUNTIME.tsv OBJ... [--show LABEL]` | The compare tool. Compares each compiled module (`MODULE_CODE` in the object) with the same module in the program, procedure by procedure in order, and the module-level code. Reports each as `exact`, `shape` (same instructions, other numbers) or the share that aligns with the first instruction that differs. Then compares the module's constant segment `BC_CN` with its place in the program. `--show` prints one procedure side by side. Compile first with `calibrate_bc.py`. |
| `pairprocs.py UNPACKED.EXE RUNTIME.tsv MODULES OBJ... [--tsv OUT]` | Pairs each procedure of the program with a procedure of the objects (Civil War Strategy's), by shape, keeping each module's alphabetical order. Gives `same`, `changed` or `new` per procedure. Its output is the table of `docs\recovery.md`. |
| `commonmap.py FILE.BI UNPACKED.EXE RUNTIME.tsv MODULES PAIRS.tsv OBJ...` | Works out the `COMMON SHARED` layout of `FILE.BI` and maps each variable to its place in the program, through the paired procedures. Lists the program's other `COMMON` offsets. |

| `disasm.py UNPACKED.EXE RUNTIME.tsv MODULES LABEL... [--lift]` | Prints a procedure, or `MODULE(module)`, with runtime calls and game procedures named, and string and floating-point constants shown. `--lift` folds the pushed arguments into each call's line, such as `B$DRAW("C10R2")` or `B$N1I2(500, 185)`. |
| `lift2bas.py LIFTED.txt` | Turns the graphics statements of a lifted listing back into BASIC (`SCREEN`, `CLS`, `LINE`, `PSET`, `PAINT`, `DRAW`). Other lines become `'?` comments to write by hand. |
| `stmtdiff.py DRAFT.bas SOURCE.BAS NAME` | Diffs a draft from `lift2bas.py` against a procedure of the source, statement by statement, with the source's line numbers. Used to edit a changed procedure in place, keeping Hutsell's layout. |

`codecmp.py` holds what `compare.py` and `pairprocs.py` share: instruction shapes, BC's floating-point
emulator calls (`INT 34h`–`3Dh`), and the exact comparison. Two details matter for `/E` modules and static
arrays. A word that points into the module's own code (a `GOSUB` target) is an offset from the module's start
in both the object and the program, so its base is 0 and is not voted for. A 16-bit displacement that LINK
fills in is 0 in the object, which capstone prints as `[si]`; the shape writes it `[si + N]`, as in the program.

To compare all three modules at once, and so check the calls between them, compile them into one folder and
pass all three objects:

```
python -I calibrate_bc.py . PDS W/out_repo WON=O,E,Fs WON2=O,Fs WONMENU=O,Fs
python -I compare.py W/WON_unp.EXE W/won_runtime.tsv W/out_repo/WON.OBJ W/out_repo/WON2.OBJ W/out_repo/WONMENU.OBJ
```

A typical round of step 4, with the PDS 7.1 folder in `PDS` and the scratch folder in `W`:

```
python -I calibrate_bc.py SRC PDS W/out WON2=O,Fs
python -I compare.py W/WON_unp.EXE W/won_runtime.tsv W/out/WON2.OBJ
```

## What the tools have shown

- **Hutsell's runtime is the far-string one.** `CWS.LNK` and `NWS.LNK` name
  `bcl71enr.lib`, but the runtime in `CWS.EXE` and `WON.EXE` is made of PDS's
  far-string parts (`B71OBF`, `B71ROBF`, `B71ROEF`, `B71OOF`, `B71ROOF`).
  With `buildlib.py`'s library, `runtimemap.py` finds every linked runtime
  segment of both programs: 151 exactly in `WON.EXE`, plus 8 short ones in
  the gaps. All 3,693 far calls from `WON.EXE`'s game code into the runtime
  hit a named routine (5,511 in `CWS.EXE`).
- **So the modules were compiled with `/Fs`.** `calibrate_bc.py` with `/O /Fs`
  gives Hutsell's `CWSMENU.OBJ` and, with `/E`, `CWSTRAT.OBJ`; `CWSTRAT2.OBJ`
  comes from `/O /Fs` without `/E`, although `CWSMAK.BTM` says `/o/e`. Each
  code segment then equals Hutsell's except one word at offset `0x2C`: `FFFF`
  from our BC, `0002` in his. It is not a fixup; what sets it is not known.
- **The whole program does not match yet.** `linkcheck.py --drop nocom`
  (the shipped `CWS.EXE` has the serial-port code that `nocom` would remove)
  gives 220,944 bytes against 220,912, with the same 6,299 relocations. The
  modules are laid out in another order: Hutsell's LINK took the runtime in
  one pass over the library, part after part, while ours makes three.

- **The compare tool is exact on Civil War Strategy.** `CWSMENU` and
  `CWSTRAT` from `calib-fs`, and `CWSTRAT2` from `calib-fs2`, compared
  with the unpacked `CWS.EXE`: all 76 procedures, the 3 module-level
  bodies and the 3 constant segments are equal. A literal changed by one
  letter is caught in `BC_CN`.
- **87% of `WON.EXE`'s procedure code pairs with Civil War Strategy.** The
  table and what follows from it are in `docs\recovery.md`.
