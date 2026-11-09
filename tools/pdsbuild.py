"""Build the port's strategic game with BASIC PDS 7.1: the bridge of docs/port-study.md (step 7).

Usage (from anywhere):
    python -I tools/pdsbuild.py OUT [--pds DIR] [--lib DIR]

The port is one QB64 program: WON.BAS includes its other files at its end. PDS 7.1 compiles
modules, so this writes the three modules that WON.EXE was built from back into OUT/src:

- WON.BAS: WON.BAS of the port, then WON1.BM, SCRIPT.BM and PDS.BM (in place of QB64.BM;
  PDS 7.1 has DIR$, and PDS.BM draws the dotted lines with the plain LINE). The pictures'
  DIM SHARED line goes back before the include of won.bi, where it was in DOS.
- WON2.BAS and WONMENU.BAS: the headers that step 4 removed (DEFINT A-Z, the DECLAREs and
  the include of won.bi), then WON2.BM or WONMENU.BM. The bare DIR$ of getlist, which the
  port writes DIR$(""), is DIR$ again.
- WON.BI without the pictures' line, so that WON2 and WONMENU get no copy of those arrays.

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
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RECOVER = REPO / "tools" / "recover"
DEFAULT_PDS = REPO.parent / "pds71" / "install"
DOSBOX = Path(r"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe")

# The module headers of the source before step 4 (git 7738434, WON2.BAS and WONMENU.BAS).
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
}
# The main module's includes and what the PDS module gets for each.
MAIN_INCLUDES = {
    "won1.bm": "WON1.BM",
    "won2.bm": None,  # a module of its own
    "wonmenu.bm": None,
    "qb64.bm": "PDS.BM",
    "script.bm": "SCRIPT.BM",
}
SWITCHES = ["WON=O,E,Fs,C:512", "WON2=O,Fs,C:512", "WONMENU=O,Fs,C:512"]
PICTURES_COMMENT = "' The pictures' arrays, declared in WON.BAS for DOS."
LINK_RSP = "won+won2+wonmenu /E\r\nwon\r\nnul\r\nc:\\bcl71enr.lib c:\\qbx.lib;\r\n"


SRC = REPO  # the folder of the port's sources; --src changes it


def lines_of(name):
    return (SRC / name).read_bytes().decode("latin1").replace("\r\n", "\n").split("\n")


def include_name(line):
    """The file of a "' $INCLUDE: 'x'" line, in lower case, or None."""
    s = line.strip()
    if not (s.startswith("'") and "$INCLUDE:" in s.upper()):
        return None
    return s.split("'")[-2].strip().lower()


def write_modules(src):
    bi = lines_of("WON.BI")
    if PICTURES_COMMENT not in bi:
        raise SystemExit(f"WON.BI: no line {PICTURES_COMMENT!r}; pdsbuild.py needs to know where the pictures' DIM is")
    at = bi.index(PICTURES_COMMENT)
    pictures = bi[at + 1]
    if not pictures.upper().startswith("DIM SHARED GRAPHIC("):
        raise SystemExit(f"WON.BI: the line after the pictures' comment is not their DIM: {pictures!r}")
    del bi[at:at + 2]

    won = []
    seen = set()
    for line in lines_of("WON.BAS"):
        inc = include_name(line)
        if inc == "won.bi":
            won.append(pictures)
            won.append(line)
        elif inc is not None and inc.endswith(".bm"):
            if inc not in MAIN_INCLUDES:
                raise SystemExit(f"WON.BAS includes {inc}, which pdsbuild.py does not know")
            seen.add(inc)
            if MAIN_INCLUDES[inc]:
                won += lines_of(MAIN_INCLUDES[inc])
        else:
            won.append(line)
    if seen != set(MAIN_INCLUDES):
        raise SystemExit(f"WON.BAS does not include {sorted(set(MAIN_INCLUDES) - seen)}")

    won2 = HEADERS["WON2"] + [""] + lines_of("WON2.BM")
    bare = [i for i, l in enumerate(won2) if 'DIR$("")' in l]
    if len(bare) != 1:
        raise SystemExit(f'WON2.BM: expected one DIR$(""), found {len(bare)}')
    won2[bare[0]] = won2[bare[0]].replace('DIR$("")', "DIR$")
    menu = HEADERS["WONMENU"] + lines_of("WONMENU.BM")

    src.mkdir(parents=True, exist_ok=True)
    for name, text in [("WON.BAS", won), ("WON2.BAS", won2), ("WONMENU.BAS", menu), ("WON.BI", bi)]:
        while text and text[-1] == "":
            text = text[:-1]
        (src / name).write_bytes(("\r\n".join(text) + "\r\n").encode("latin1"))


def python(script, cwd, *args):
    # DOSBox 0.74 writes stdout.txt and stderr.txt into the folder it starts in, so the tools
    # run in the build's own folder, not in the repo's.
    r = subprocess.run([sys.executable, "-I", str(RECOVER / script), *map(str, args)], cwd=cwd, check=False)
    if r.returncode:
        raise SystemExit(f"{script} failed (exit {r.returncode})")


def link(lib, objdir, work):
    work.mkdir(parents=True, exist_ok=True)
    (work / "WON.EXE").unlink(missing_ok=True)
    for m in ("WON", "WON2", "WONMENU"):
        shutil.copy(objdir / f"{m}.OBJ", work / f"{m}.OBJ")
    (work / "LINK.RSP").write_bytes(LINK_RSP.encode("ascii"))
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
    exe = work / "WON.EXE"
    if not exe.is_file():
        out = work / "LINK.OUT"
        raise SystemExit("LINK made no WON.EXE:\n" + (out.read_text(errors="replace") if out.is_file() else "(no LINK.OUT)"))
    return exe


def main():
    ap = argparse.ArgumentParser(description="Build the port's strategic game with PDS 7.1.")
    ap.add_argument("out")
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
    write_modules(out / "src")
    python("calibrate_bc.py", out, out / "src", pds, out / "obj", *SWITCHES)
    lib = Path(args.lib).resolve() if args.lib else out / "lib"
    if not args.lib:
        python("buildlib.py", out, pds, lib)
    elif not (lib / "BCL71ENR.LIB").is_file():
        raise SystemExit(f"--lib {lib} has no BCL71ENR.LIB: make it with tools/recover/buildlib.py")
    exe = link(lib, out / "obj", out / "link")
    shutil.copy(exe, out / "WON.EXE")
    print(f"built {out / 'WON.EXE'}: {(out / 'WON.EXE').stat().st_size} bytes")


if __name__ == "__main__":
    main()
