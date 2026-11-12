"""Scratch: for each PDS 7.1 part library, which of its code segments match a
program exactly. Usage: python -I partmatch.py UNPACKED.EXE PDS71_DIR LIB..."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from omflib import read_library  # noqa: E402
from runtimemap import place  # noqa: E402
from unlzexe91 import read_mz  # noqa: E402

image = bytes(read_mz(Path(sys.argv[1]).read_bytes()).data)
pds = Path(sys.argv[2])
for lib in sys.argv[3:]:
    hit, miss = [], []
    for m in read_library(pds / lib):
        for s in m.segments[1:]:
            if s.is_code() and s.size:
                st, _, _ = place(image, s)
                short = m.name.split("\\")[-1]
                (hit if st == "exact" else miss).append(short)
    print(f"{lib}: {len(hit)} of {len(hit) + len(miss)} match")
    print("   yes:", " ".join(hit))
    print("   no: ", " ".join(miss))
