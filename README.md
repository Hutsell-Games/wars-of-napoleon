# W.R. Hutsell's Wars of Napoleon Game
A strategic and tactical level, one or two player wargame simulating the Napoleonic Wars.

## The Canonical Source
The branch `main` contains the original source code as provided by W.R. Hutsell to Dave Mackey. That branch
should not be edited; it is there for historical purposes.

## This branch: the QB64 port
W.R. Hutsell wrote the game in Microsoft BASIC PDS 7.1 for DOS. This branch, `qb64rust`, changes that source as
little as possible so that the game builds with QB64Rust and QB64pe, and so that its SUBs can be tested. It
builds two programs:

```
qb64rust -x WON.BAS -o won.exe             the strategic game
qb64rust -x NAPOLEON.BAS -o napoleon.exe   the tactical game, which fights each battle
```

`WON.BAS` includes `WON.BI`, `WON1.BM`, `WON2.BM`, `WONMENU.BM`, `QB64.BM` and `SCRIPT.BM`. `NAPOLEON.BAS`
includes `NAP10.BI`, `NAP1.BM`, `NAP1A.BM`, `NAP1C.BM`, `QB64.BM` and `NAPSCRIPT.BM`. Both `.BI` files include
`FOLDERS.BI`. Keep the name `napoleon.exe`: the strategic game runs it for each battle when Tactical is on.

The shipped DOS programs `WON.EXE` and `NAPOLEON.EXE` stay on this branch, because the tests and the recovery's
tools use them. Windows does not tell `WON.EXE` from `won.exe`, so a build in this folder overwrites them, and
git then shows them as changed. The tests build into `tests\out\` instead. The DOS picture programs `ARCH2.EXE`,
`VIC.EXE` and `NAPIC.EXE` are on `main` only; their screens are in `docs\` (`ARCH2.png`, `VIC.png`,
`NAPIC.png`). Each push to `main` or `qb64rust` also builds the two programs on GitHub Actions (it can be started
by hand too, under Actions, Build, Run workflow). The run's artifact `wars-of-napoleon` holds them with the
files they read, ready to play.

Run the programs from this folder. They read their pictures and icons from `graphics` and their scenarios and
the tactical game's armies from `scenarios`. The settings (`NWS.CFG`), the high scores (`HISCORE.NWS`), saved
games, the history of a game (`NWS.HIS`) and the files that pass a battle between the two programs
(`BATTLE.$$$`, `OUTCOME.&&&`) stay beside the programs. The saved game that came with the game, `NWS9.SAV`, is
in `tests\data\`.

The tests are described in [tests/README.md](tests/README.md). Work still to do is in [TODO.md](TODO.md).

The original documentation of the game is in `docs`: the manual of the strategic game (`WON.DOC`) and of the
tactical game (`NAPOLEON.DOC`, `NAPOLEON.PAG`, `NAPOLEON.TXT`). The notes on the port are in
[docs/devnotes.md](docs/devnotes.md), and its plan in [docs/port-study.md](docs/port-study.md). The recovery of
`WON.EXE`'s source is in [docs/won-source-study.md](docs/won-source-study.md) and
[docs/recovery.md](docs/recovery.md).
