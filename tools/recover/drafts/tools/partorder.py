"""Scratch: list the runtime modules of a map in program order, each with the
part library it comes from, and collapse runs of the same part.
Usage: python -I partorder.py MAP.txt PDS71_DIR PART..."""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from omflib import read_library  # noqa: E402

owner = {}
for part in sys.argv[3:]:
    for m in read_library(Path(sys.argv[2]) / (part + ".LIB")):
        for s in m.segments[1:]:
            if s.is_code() and s.size:
                owner.setdefault(f"{m.name}:{s.name}", []).append(part)
seq = []
for line in open(sys.argv[1]):
    m = re.match(r"  ([0-9a-f]+)-([0-9a-f]+) (\S+)", line)
    if m:
        seq.append((m.group(1), m.group(3), "/".join(owner.get(m.group(3), ["?"]))))
run = None
for addr, name, part in seq:
    if part != run:
        print(f"{addr} {part:16} from {name.split(chr(92))[-1]}")
        run = part
