"""Build one of the port's programs with BASIC PDS 7.1: the bridge of docs/port-study.md (step 7).

Usage (from anywhere):
    python -I tools/pdsbuild.py OUT [--game won|napoleon] [--pds DIR] [--lib DIR]

--game napoleon builds the tactical game the same way: NAPOLEON.BAS with NAP1.BM,
NAPSCRIPT.BM and PDS.BM after its main code, the pictures' DIM SHARED lines back after
the include of nap10.bi, and NAP1A.BAS and NAP1C.BAS with their old headers. The
program is OUT/NAPOLEON.EXE. What follows says how the strategic game is built.

The port is one QB64 program: WON.BAS includes its other files at its end. PDS 7.1 compiles
modules, so this writes the three modules that WON.EXE was built from back into OUT/src:

- WON.BAS: WON.BAS of the port, then WON1.BM, SCRIPT.BM and PDS.BM (in place of QB64.BM;
  PDS 7.1 has DIR$, and PDS.BM draws the dotted lines with the plain LINE). The pictures'
  DIM SHARED line goes back before the include of won.bi, where it was in DOS.
- WON2.BAS and WONMENU.BAS: the headers that step 4 removed (DEFINT A-Z, the DECLAREs and
  the include of won.bi), then WON2.BM or WONMENU.BM. The bare DIR$ of getlist, which the
  port writes DIR$(""), is DIR$ again.
- WON.BI without the pictures' line, so that WON2 and WONMENU get no copy of those arrays.
- FOLDERS.BI with the folders' DOS names: "SCENARIO\" for "scenarios/". The build reads the
  data folders as the QB64 builds do, and DOS takes no "/" and no name of 9 letters.

It then compiles them with the recovery's switches and links them with WON.LNK and the
far-string runtime of tools/recover/buildlib.py (docs/won-source-study.md, section 12).
The program is OUT/WON.EXE. BC's messages are in OUT/obj/<MODULE>.CMP, LINK's in
OUT/link/LINK.OUT.

--src builds the sources of another folder, such as a scratch copy with trace lines added.
--pds is the PDS 7.1 folder of QB64Rust's tools/qb45/pds71_install.py (default
../pds71/install beside the repo). --lib reuses a library folder made by buildlib.py;
without it the library is built into OUT/lib.

The tools of tools/recover run DOSBox 0.74-3, hidden, as they do for the recovery.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RECOVER = REPO / "tools" / "recover"
DEFAULT_PDS = REPO.parent / "pds71" / "install"
DOSBOX = Path(r"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe")

# The module headers of the source before step 4 (git 7738434: WON2.BAS, WONMENU.BAS,
# NAP1A.BAS and NAP1C.BAS).
HEADERS = {
    "WON2": [
        "DEFINT A-Z",
        "DECLARE SUB armyxy (x%, y%, z%)",
        "DECLARE SUB center (y%, a$)",
        "DECLARE SUB flags (who%, w%, a%)",
        "DECLARE SUB image2 (a$, s%)",
        "DECLARE SUB maptext ()",
        "DECLARE SUB mountain (xx%, yy%)",
        "DECLARE SUB mxw (wide%)",
        "DECLARE SUB roman (target%, a$)",
        "DECLARE SUB stax (who%)",
        "' $INCLUDE: 'won.bi'",
    ],
    "WONMENU": [
        "DEFINT A-Z",
        "DECLARE SUB choices (b1%, wide%)",
        "DECLARE SUB mxw (wide%)",
        "DECLARE SUB stax (who%)",
        "' $INCLUDE: 'won.bi'",
    ],
    "NAP1A": [
        "DEFINT A-Z",
        "DECLARE SUB arrange (who%, xloc%, yloc%)",
        "DECLARE SUB brittle (who%)",
        "DECLARE SUB routed (index%, flag%)",
        "DECLARE SUB ishi (x%)",
        "DECLARE SUB over (flag%)",
        "REM $INCLUDE: 'nap10.bi'",
    ],
    "NAP1C": [
        "DEFINT A-Z",
        "DECLARE SUB Mickey (a$, lButton%, rButton%, xc%, yc%)",
        "REM $INCLUDE: 'nap10.bi'",
    ],
}


class Game:
    """What pdsbuild.py needs to know of one of the two programs."""

    def __init__(self, main, bi, includes, modules, switches, pictures_before):
        self.main = main          # the main module, WON or NAPOLEON
        self.bi = bi              # its include file, which holds the pictures' DIM SHARED lines
        self.includes = includes  # the main module's includes and what the PDS module gets for each
        self.modules = modules    # the linked modules: (name, .BM file, blank line after the header)
        self.switches = switches  # BC's switches of each module
        # In DOS the pictures' lines stood before the include of the .BI (WON.BAS) or after it
        # (NAPOLEON.BAS, after its RANDOMIZE TIMER: CLS, which is now CALL napstart: CLS).
        self.pictures_before = pictures_before
        self.pictures_comment = f"' The pictures' arrays, declared in {main}.BAS for DOS."
        names = "+".join(m.lower() for m in [main] + [n for n, _, _ in modules])
        self.link_rsp = f"{names} /E\r\n{main.lower()}\r\nnul\r\nc:\\bcl71enr.lib c:\\qbx.lib;\r\n"


GAMES = {
    # The strategic game: the three modules that WON.EXE was built from, with the recovery's
    # switches (docs/won-source-study.md, section 12).
    "won": Game(
        "WON", "WON.BI",
        {"won1.bm": "WON1.BM", "won2.bm": None, "wonmenu.bm": None,  # None: a module of its own
         "qb64.bm": "PDS.BM", "script.bm": "SCRIPT.BM"},
        [("WON2", "WON2.BM", True), ("WONMENU", "WONMENU.BM", False)],
        ["WON=O,E,Fs,C:512", "WON2=O,Fs,C:512", "WONMENU=O,Fs,C:512"],
        pictures_before=True),
    # The tactical game: the modules of NAPOLEON.MAK (git 6e0930f). Its source is not the
    # shipped NAPOLEON.EXE, so no switches were recovered; it takes the strategic game's.
    "napoleon": Game(
        "NAPOLEON", "NAP10.BI",
        {"nap1.bm": "NAP1.BM", "nap1a.bm": None, "nap1c.bm": None,
         "qb64.bm": "PDS.BM", "napscript.bm": "NAPSCRIPT.BM"},
        [("NAP1A", "NAP1A.BM", True), ("NAP1C", "NAP1C.BM", False)],
        ["NAPOLEON=O,E,Fs,C:512", "NAP1A=O,Fs,C:512", "NAP1C=O,Fs,C:512"],
        pictures_before=False),
}


SRC = REPO  # the folder of the port's sources; --src changes it


def dos_folder(name):
    """A folder's name as a DOS program gives it: its first 8 letters, in upper case."""
    return name[:8].upper()


def lines_of(name):
    return (SRC / name).read_bytes().decode("latin1").replace("\r\n", "\n").split("\n")


def include_name(line):
    """The file of a "' $INCLUDE: 'x'" or "REM $INCLUDE: 'x'" line, in lower case, or None."""
    s = line.strip()
    if not ((s.startswith("'") or s.upper().startswith("REM ")) and "$INCLUDE:" in s.upper()):
        return None
    return s.split("'")[-2].strip().lower()


def write_modules(game, src):
    bi = lines_of(game.bi)
    if game.pictures_comment not in bi:
        raise SystemExit(f"{game.bi}: no line {game.pictures_comment!r}; "
                         "pdsbuild.py needs to know where the pictures' DIM is")
    at = bi.index(game.pictures_comment)
    end = at + 1
    while end < len(bi) and bi[end].upper().startswith("DIM SHARED "):
        end += 1
    pictures = bi[at + 1:end]
    if not pictures:
        raise SystemExit(f"{game.bi}: the line after the pictures' comment is not their DIM: {bi[at + 1]!r}")
    if any(l.strip() for l in bi[end:]):
        raise SystemExit(f"{game.bi}: more lines after the pictures' DIM SHARED lines")
    del bi[at:end]

    module = []
    seen = set()
    for line in lines_of(f"{game.main}.BAS"):
        inc = include_name(line)
        if inc == game.bi.lower():
            module += (pictures + [line]) if game.pictures_before else ([line] + pictures)
        elif inc is not None and inc.endswith(".bm"):
            if inc not in game.includes:
                raise SystemExit(f"{game.main}.BAS includes {inc}, which pdsbuild.py does not know")
            seen.add(inc)
            if game.includes[inc]:
                module += lines_of(game.includes[inc])
        else:
            module.append(line)
    if seen != set(game.includes):
        raise SystemExit(f"{game.main}.BAS does not include {sorted(set(game.includes) - seen)}")

    files = [(f"{game.main}.BAS", module)]
    for name, bm, blank in game.modules:
        files.append((f"{name}.BAS", HEADERS[name] + ([""] if blank else []) + lines_of(bm)))
    if game.main == "WON":
        # The bare DIR$ of getlist, which the port writes DIR$("").
        won2 = files[1][1]
        bare = [i for i, l in enumerate(won2) if 'DIR$("")' in l]
        if len(bare) != 1:
            raise SystemExit(f'WON2.BM: expected one DIR$(""), found {len(bare)}')
        won2[bare[0]] = won2[bare[0]].replace('DIR$("")', "DIR$")
    files.append((game.bi, bi))
    # The data folders, which the .BI includes (docs/port-study.md, D9), as DOS names them.
    # DOS takes no "/" in BLOAD's and OPEN's names (the PDS build stopped on "File not found"),
    # and a name of at most 8 letters: tools/play/play.py gives the PDS runs "scenarios" as
    # SCENARIO, its DOS name (dos_folder).
    folders = lines_of("FOLDERS.BI")
    consts = 0
    for i, l in enumerate(folders):
        m = re.match(r'(CONST \w+ = ")([^"/]+)/"(.*)$', l)
        if m:
            folders[i] = f'{m[1]}{dos_folder(m[2])}\\"{m[3]}'
            consts += 1
    if not consts:
        raise SystemExit("FOLDERS.BI: no CONST of a folder ending in /")
    files.append(("FOLDERS.BI", folders))

    src.mkdir(parents=True, exist_ok=True)
    for name, text in files:
        while text and text[-1] == "":
            text = text[:-1]
        (src / name).write_bytes(("\r\n".join(text) + "\r\n").encode("latin1"))


def python(script, cwd, *args):
    # DOSBox 0.74 writes stdout.txt and stderr.txt into the folder it starts in, so the tools
    # run in the build's own folder, not in the repo's.
    r = subprocess.run([sys.executable, "-I", str(RECOVER / script), *map(str, args)], cwd=cwd, check=False)
    if r.returncode:
        raise SystemExit(f"{script} failed (exit {r.returncode})")


def link(game, lib, objdir, work):
    work.mkdir(parents=True, exist_ok=True)
    exe = work / f"{game.main}.EXE"
    exe.unlink(missing_ok=True)
    for m in [game.main] + [n for n, _, _ in game.modules]:
        shutil.copy(objdir / f"{m}.OBJ", work / f"{m}.OBJ")
    (work / "LINK.RSP").write_bytes(game.link_rsp.encode("ascii"))
    conf = work / "run.conf"
    conf.write_text("\n".join([
        "[sdl]", "fullscreen=false", "output=surface", "",
        "[cpu]", "cycles=max", "",
        "[autoexec]",
        f'mount c "{lib}"', f'mount d "{work}"',
        "path c:\\", "set LIB=c:\\", "d:",
        "link @LINK.RSP > LINK.OUT",
        "exit", "",
    ]), encoding="ascii")
    env = dict(os.environ, SDL_VIDEODRIVER="dummy")
    subprocess.run([str(DOSBOX), "-conf", str(conf), "-noconsole"], env=env, timeout=300, cwd=work,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if not exe.is_file():
        out = work / "LINK.OUT"
        raise SystemExit(f"LINK made no {exe.name}:\n"
                         + (out.read_text(errors="replace") if out.is_file() else "(no LINK.OUT)"))
    return exe


def main():
    ap = argparse.ArgumentParser(description="Build one of the port's two programs with PDS 7.1.")
    ap.add_argument("out")
    ap.add_argument("--game", choices=sorted(GAMES), default="won",
                    help="won, the strategic game (the default), or napoleon, the tactical game")
    ap.add_argument("--pds", default=str(DEFAULT_PDS))
    ap.add_argument("--lib")
    ap.add_argument("--src", help="build the sources of this folder instead of the repo's (a scratch copy)")
    args = ap.parse_args()
    global SRC
    if args.src:
        SRC = Path(args.src).resolve()
    out = Path(args.out).resolve()
    pds = Path(args.pds).resolve()
    if not (pds / "BC.EXE").is_file():
        raise SystemExit(f"no BC.EXE in {pds}: give the PDS 7.1 folder with --pds")
    if not DOSBOX.is_file():
        raise SystemExit(f"no DOSBox 0.74-3 at {DOSBOX}")
    game = GAMES[args.game]
    write_modules(game, out / "src")
    python("calibrate_bc.py", out, out / "src", pds, out / "obj", *game.switches)
    lib = Path(args.lib).resolve() if args.lib else out / "lib"
    if not args.lib:
        python("buildlib.py", out, pds, lib)
    elif not (lib / "BCL71ENR.LIB").is_file():
        raise SystemExit(f"--lib {lib} has no BCL71ENR.LIB: make it with tools/recover/buildlib.py")
    exe = link(game, lib, out / "obj", out / "link")
    built = out / exe.name
    shutil.copy(exe, built)
    print(f"built {built}: {built.stat().st_size} bytes")


if __name__ == "__main__":
    main()
