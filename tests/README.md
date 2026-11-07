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

| Session | What it covers |
|---|---|
| `01-1796-french` | 1796 as the French, Tactical off. The intro, the start menu, every menu and page once, Recruit, Moves, Fortify, Files → Save, and two turn ends with the Allies' moves. |
| `02-1796-allies` | 1796 as the Allies (the shipped settings), Tactical off. The Allies only end turns. France takes its objective in the third turn. The game ends with the Battle Summary, the Hall of Fame and "Game Over", and the session quits to DOS. |

The other sessions planned in section 3.2 of the study are still to be written.
