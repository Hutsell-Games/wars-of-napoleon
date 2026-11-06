"""Compile BASIC modules with PDS 7.1 under DOSBox (hidden).

Usage: python -I calibrate_bc.py SRC_DIR PDS71_DIR WORK_DIR MODULE[=SWITCHES] ...

Copies the .BAS and .BI files of SRC_DIR into WORK_DIR with CRLF line ends,
then runs "bc MODULE.BAS /S1 /S2, MODULE.OBJ, NUL.LST;" for each module.
SWITCHES are BC's switch letters without the slash, separated by commas, for
example CWSTRAT=O,E or CWSMENU=O; the default is O,E. (A slash in an argument
is rewritten as a path by Git Bash, so none is used.)

BC's messages go to MODULE.CMP. Any object file left from an earlier run is
deleted first. Prints each module's object size, or the tail of BC's messages
if no object, or an empty one, was made; exits with 1 if any module failed.
"""
import os
import subprocess
import sys
from pathlib import Path

DOSBOX = Path(r"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe")


def parse_switches(text: str) -> str:
    letters = [s.strip() for s in text.split(",") if s.strip()]
    for s in letters:
        if not s.isalnum():
            raise SystemExit(f"bad switch {s!r}: give letters such as O,E")
    return " ".join("/" + s.upper() for s in letters)


def main():
    if len(sys.argv) < 5:
        raise SystemExit(__doc__)
    src, pds, work = (Path(a).resolve() for a in sys.argv[1:4])
    modules = []
    for spec in sys.argv[4:]:
        name, _, sw = spec.partition("=")
        modules.append((name.upper(), parse_switches(sw or "O,E")))
    work.mkdir(parents=True, exist_ok=True)
    for f in src.iterdir():
        if f.is_file() and f.suffix.upper() in (".BAS", ".BI"):
            text = f.read_bytes().replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
            (work / f.name.upper()).write_bytes(text)
    for name, _ in modules:
        (work / f"{name}.OBJ").unlink(missing_ok=True)
    lines = [
        "[sdl]", "fullscreen=false", "output=surface", "",
        "[cpu]", "cycles=max", "",
        "[autoexec]",
        f'mount c "{pds}"',
        f'mount d "{work}"',
        "path c:\\", "set LIB=c:\\", "d:",
    ]
    for name, sw in modules:
        lines.append(f"bc {name}.BAS {sw}, {name}.OBJ, NUL.LST; > {name}.CMP")
    lines += ["exit", ""]
    conf = work / "run.conf"
    conf.write_text("\n".join(lines), encoding="ascii")
    env = dict(os.environ, SDL_VIDEODRIVER="dummy")
    subprocess.run([str(DOSBOX), "-conf", str(conf), "-noconsole"], env=env, timeout=600, check=False)
    failed = False
    for name, sw in modules:
        obj = work / f"{name}.OBJ"
        if obj.exists() and obj.stat().st_size > 0:
            print(f"{name} {sw}: {obj.stat().st_size} bytes")
            continue
        failed = True
        cmp = work / f"{name}.CMP"
        tail = cmp.read_bytes().decode("latin1").replace("\a", "").strip().splitlines()[-3:] if cmp.exists() else []
        print(f"{name} {sw}: FAILED, no object; {' / '.join(tail) or 'no messages'}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
