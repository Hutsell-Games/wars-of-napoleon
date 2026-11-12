# Drafts of the recovered source

These are the scripts and drafts that produced `WON.BAS`, `WON2.BAS`, `WONMENU.BAS` and the first `WON.BI`
(steps 4 and 5 of `docs\won-source-study.md`). They are kept as history: they show which lines are Hutsell's
Civil War Strategy text and which were written from the disassembly. The result is the source in the repo,
which builds `WON.EXE` byte for byte (section 12 of the study).

They do not run from here. They ran in the scratch folder `..\won-hutsellgames\work\`, which was deleted on
2026-11-12, and read files from it by relative paths:

- `cws-orig\`: Hutsell's Civil War Strategy 1.57 files (`CWSTRAT.BAS`, `CWSTRAT2.BAS`, `CWSMENU.BAS`,
  `CWS14.BI` and the rest of its download). The same sources are in the `civil-war-strategy` repo, at commit
  `5d75791`.
- `src\`: where the `make_*.py` scripts wrote the modules.
- the listings of `tools\recover\disasm.py` and `lift2bas.py` (`dis_*.txt`, `lift_*.txt`), which were not kept.
  The tools make them again from the unpacked `WON.EXE`.

| File | What it is |
|---|---|
| `make_won.py`, `edits_won.py` | Build `WON.BAS` from `new\won_main1.txt` (module-level code to the main menu), CWS lines 278–704 edited by `edits_won.py`, `new\won_tail.txt` (the module's subroutines) and `new\*.bas` (the procedures). |
| `make_won2.py`, `edits_won2.py` | Build `WON2.BAS` from `CWSTRAT2.BAS` and `CWSTRAT.BAS`, with the edits; `new_evaluate.txt` and `new_navy_battle.txt` are blocks it puts in. |
| `make_wonmenu.py`, `edits_wonmenu.py` | Build `WONMENU.BAS` from `CWSMENU.BAS`. |
| `make_won_bi.py` | The first draft of `WON.BI`: `CWS14.BI`'s `DECLARE`s and the new procedures. |
| `make_maxx.py`, `edit_tupdate4.py`, `procedit.py`, `splice_bunting.py`, `splice_europe.py`, `write_battle.py`, `write_filer.py` | Write or edit one procedure each. |
| `new\*.bas` | The procedures that are new or rewritten, written from `disasm.py --lift`. |
| `*_draft.bas`, `europe.bas`, `draft_WON.17.bas` | Drafts of single procedures from `lift2bas.py`, before editing. |
| `rt.sh`, `rt2.sh`, `rt3.sh` | One round of step 4 for `WONMENU`, `WON2` or `WON`: build the module, compile it with BC 7.10 and compare it with `compare.py`. |
| `regions.sh`, `reg3.sh`, `rng.sh` | Show the regions of one procedure that still differ, or the lines of a listing between two addresses. |
| `tools\` | Scratch tools not kept in `tools\recover\`: `filerefs.py` (the file names the programs open), `align.py`, `partmatch.py` and `partorder.py` (matching the runtime library's parts), `mkefr.py` and `trylink.sh` (trial links). |
