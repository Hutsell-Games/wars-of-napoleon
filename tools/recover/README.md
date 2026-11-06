# Tools for recovering the strategic game's source

`WON.EXE` came without its source. These scripts support getting it back by
compiling BASIC with Microsoft BASIC PDS 7.1 until the result matches
`WON.EXE`. The plan is study 45 of the QB64Rust project
(`study\45-wars-of-napoleon-strategic-source.md`).

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

The scripts are working tools of step 1 of the plan; the procedure splitter,
the runtime map and the compare tool come next.
