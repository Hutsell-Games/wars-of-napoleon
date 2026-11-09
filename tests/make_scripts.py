#!/usr/bin/env python3
"""Writes the generated scripts of tests/games (tests/README.md, "Generated games"; D10 of
docs/port-study.md).

    python -I tests/make_scripts.py [--only <name> ...]

Each generated script starts one of the seven scenarios as one side, turns Tactical off, and
then only ends its turns until the game ends: end-<year>-<side>. The computer plays the other
side, so these scripts run the computer's play in every scenario to its end, which the 15
sessions do in only a few. At the end, a human high score asks for a name; the script gives
"Tester". It then quits to DOS from the start menu.

A script takes a digest at the main menu of each turn, so a difference shows at the turn where
it starts. How many turns a game has, and whether it asks for a name, depends on the game, so
this tool plays each one first with probes and writes what they found. Run it again only when a
change of the game is meant to change how its games go; then record.
"""
from __future__ import annotations

import argparse
import sys
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

# The start menu's years, in its order: "Start NEW Game" lists them from 1796 down.
YEARS = ["1796", "1805", "1807", "1808", "1812", "1813", "1815"]
# The side the player takes. The shipped NWS.CFG plays the Allies; the Utility menu's
# "a" swaps to the French (session 1).
SIDES = {"allies": "the Allies", "french": "the French"}
PROBE_TURNS = 3000


def script_name(year: str, side: str) -> str:
    return f"end-{year}-{side}"


def seed(name: str) -> int:
    return zlib.crc32(name.encode()) % 100000


def header(year: str, side: str, about: str) -> list[str]:
    name = script_name(year, side)
    other = SIDES["french" if side == "allies" else "allies"]
    downs = ["key down", "prompt"] * YEARS.index(year)
    swap = ["text a", "prompt"] if side == "french" else []
    return [
        f"# {name}: {year} as {SIDES[side]}, one player, Tactical off. The player only ends turns;",
        f"# the computer plays {other}. {about}",
        "# Written by tests/make_scripts.py.",
        f"#! seed {seed(name)}",
        "",
        "# A TICK: any key ends it. A pause that waits for a key: a space. The End Turn",
        "# question and the End Game question: Yes. A retreat the player is asked to choose:",
        "# Esc, which lets the game choose.",
        "rule 3 key f12",
        "rule 1 key space",
        "rule 2:E text y",
        "rule 2:R key esc",
        "",
        "# The built-in title, then the start menu: Start NEW Game, the year.",
        "play until 2:W",
        "text s",
        "prompt",
        *downs,
        "key enter",
        "",
        "# The main menu. Utility: " + ("swap to the French, " if swap else "") + "Tactical off.",
        "play until 2:M",
        "digest",
        "text u",
        "prompt",
        *swap,
        "text t",
        "prompt",
        "key esc",
    ]


def turns(count: int) -> list[str]:
    return ["", "# Each turn: a digest at the main menu, then End Turn.",
            f"repeat {count}", "play until 2:M", "digest", "text e", "end"]


def ending(name_prompt: bool) -> list[str]:
    lines = [""]
    if name_prompt:
        lines += ["# The game ends; a new high score asks for the commander's name.",
                  "play until 4", "text Tester", "key enter"]
    else:
        lines += ["# The game ends: the Battle Summary, the Hall of Fame and Game Over."]
    return lines + [
        "",
        "# The start menu: Quit to DOS, and a key for END's \"Press any key to continue\".",
        "play until 2:W",
        "digest",
        "text q",
        "repeat space",
    ]


def probe_run(exes, name: str, lines: list[str]) -> tuple[int, str, str | None]:
    """Runs a probe: its digests, the last line of its state file, and its problem."""
    keys = play.OUT / "probe" / f"{name}.keys"
    keys.parent.mkdir(parents=True, exist_ok=True)
    keys.write_text("\n".join(lines) + "\n")
    script = play.game_script(keys)
    run = play.run_script(script, "rust", exes)
    digests = sum(1 for e in run.states if e.startswith(b"digest "))
    last = run.states[-1].decode(errors="replace") if run.states else "no state"
    return digests, last, run.problem


def probe(exes, year: str, side: str) -> list[str] | str:
    """The script's lines, or why the probes could not play the game to its end."""
    name = "probe-" + script_name(year, side)
    head = header(year, side, "")
    digests, last, _ = probe_run(exes, name, head + turns(PROBE_TURNS))
    if last.endswith("no rule for the wait at place 2:W"):
        name_prompt = False
    elif last.endswith("no rule for the wait at place 4"):
        name_prompt = True
    else:
        return f"the game did not end: {last}"
    count = digests - 1  # the first is at the main menu before the Utility menu
    about = f"A digest at the main menu of each of its {count} turns."
    lines = header(year, side, about) + turns(count) + ending(name_prompt)
    _, last, problem = probe_run(exes, name, lines)
    if problem:
        return f"the script does not end the game: {problem}"
    return lines


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--only", nargs="*", help="names of the scripts to write (default: all)")
    args = ap.parse_args(argv)
    exes = play.build_all(["rust"])
    games = [(y, s) for y in YEARS for s in SIDES if not args.only or script_name(y, s) in args.only]
    found = play.parallel(args.jobs, [lambda g=g: probe(exes, *g) for g in games])
    failed = 0
    play.GAMES.mkdir(parents=True, exist_ok=True)
    for (year, side), lines in zip(games, found):
        name = script_name(year, side)
        if isinstance(lines, str):
            failed += 1
            print(f"FAIL  {name}: {lines}")
            continue
        (play.GAMES / f"{name}.keys").write_text("\n".join(lines) + "\n")
        count = next(x for x in lines if x.startswith("repeat ")).split()[1]
        print(f"wrote {name}.keys: {count} turns" + (", a name prompt" if "play until 4" in lines else ""))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
