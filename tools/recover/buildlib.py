"""Build the runtime library that Hutsell linked with, and a PDS folder to link in.

Usage: python -I buildlib.py PDS71_DIR OUT_DIR

PDS71_DIR holds PDS 7.1's expanded files, as made by QB64Rust's
tools\\qb45\\pds71_install.py. OUT_DIR gets BCL71ENR.LIB, joined with PDS's
LIB.EXE under DOSBox, and copies of LINK.EXE, QBX.LIB and the NO*.OBJ stubs.
linkcheck.py can then take OUT_DIR as its PDS folder.

Hutsell's response files name bcl71enr.lib, but the runtime code in the
shipped CWS.EXE and WON.EXE is that of the far-string parts (B71OBF,
B71ROBF, B71ROEF, B71OOF, B71ROOF), not the near-string ones. With these
parts every runtime module those programs link is found in them byte for
byte (runtimemap.py). The part order is the order in which the shipped
CWS.EXE lays out the runtime; it does not yet reproduce Hutsell's module
order (docs/won-source-study.md, section 8).
"""
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

DOSBOX = Path(r"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe")
PARTS = (
    "BLIBFP", "EMR", "B71OBJ", "B71OEJ", "B71OBF", "B71OOF",
    "B71ROBJ", "B71ROOJ", "B71ROEJ", "B71ROBF", "B71ROOF", "B71ROEF",
)  # fmt: skip
STUBS = ("NOISAM", "NOEMS", "NOCGA", "NOEGA", "NOCOM", "NOHERC", "NOOGA")


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    pds, out = (Path(a).resolve() for a in sys.argv[1:])
    out.mkdir(parents=True, exist_ok=True)
    for name in ("LINK.EXE", "QBX.LIB", *(s + ".OBJ" for s in STUBS)):
        shutil.copy(pds / name, out / name)
    (out / "BCL71ENR.LIB").unlink(missing_ok=True)
    with tempfile.TemporaryDirectory(prefix="hutsell-lib-") as tmp:
        work = Path(tmp)
        for name in ("LIB.EXE", *(p + ".LIB" for p in PARTS)):
            shutil.copy(pds / name, work / name)
        parts = [f"+{p}.LIB" for p in PARTS]
        half = len(parts) // 2
        rsp = "BCL71ENR.LIB\r\ny\r\n" + "".join(parts[:half]) + "&\r\n" + "".join(parts[half:]) + "\r\nNUL;\r\n"
        (work / "MKLIB.RSP").write_bytes(rsp.encode("ascii"))
        conf = work / "lib.conf"
        conf.write_text("\n".join([
            "[sdl]", "output=surface", "",
            "[cpu]", "cycles=max", "",
            "[autoexec]",
            f'mount c "{work}"', "c:",
            "lib @MKLIB.RSP > MKLIB.LOG",
            "exit", "",
        ]), encoding="ascii")
        env = dict(os.environ, SDL_VIDEODRIVER="dummy")
        subprocess.run([str(DOSBOX), "-conf", str(conf), "-noconsole"], cwd=work, env=env,
                       timeout=120, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        lib = work / "BCL71ENR.LIB"
        if not lib.is_file():
            log = work / "MKLIB.LOG"
            raise SystemExit("LIB made no library:\n" + (log.read_text(errors="replace") if log.is_file() else "(no log)"))
        shutil.copy(lib, out / "BCL71ENR.LIB")
    print(f"built {out / 'BCL71ENR.LIB'} from {len(PARTS)} parts")


if __name__ == "__main__":
    main()
