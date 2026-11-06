# Tools for recovering the strategic game's source

`WON.EXE` came without its source. These scripts support getting it back by
compiling BASIC with Microsoft BASIC PDS 7.1 until the result matches
`WON.EXE`. The plan is `docs\won-source-study.md` (study 45, moved here
from the QB64Rust project).

They need Python 3, DOSBox 0.74-3 at its default install path, and PDS 7.1
(`BC.EXE`, `LINK.EXE`, `BCL71ENR.LIB`, `QBX.LIB` and the `NO*.OBJ` stubs) in
one folder. `normalign.py` also needs the `capstone` package. DOSBox runs
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

The procedure splitter and the compare tool come next.
