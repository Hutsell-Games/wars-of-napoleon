"""Scratch: build a BCL71ENR.LIB from the far-string parts (N swapped for F)
in a work folder, with PDS 7.1's LIB under DOSBox.
Usage: python -I mkefr.py PDS71_DIR OUT_DIR"""
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[5] / "QB64Rust" / "tools" / "qb45"))
import pds71_install as pi  # noqa: E402

pds, out = Path(sys.argv[1]), Path(sys.argv[2])
parts = tuple(sys.argv[3].split(",")) if len(sys.argv) > 3 else ("B71ROOF", "B71OOF", "B71ROOJ", "B71ROEF", "B71ROBF", "B71OEJ", "B71OBF",
         "B71ROEJ", "B71OBJ", "B71ROBJ", "EMR", "BLIBFP")
out.mkdir(parents=True, exist_ok=True)
for name in ("LIB.EXE", *(p + ".LIB" for p in parts)):
    shutil.copy(pds / name, out / name)
(out / "BCL71ENR.LIB").unlink(missing_ok=True)
pi.PARTS = parts
print(pi.build_library(out, pi.DEFAULT_DOSBOX))
print("built:", (out / "BCL71ENR.LIB").is_file())
