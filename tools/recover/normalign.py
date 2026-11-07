"""Compare code as instruction shapes: disassemble 16-bit code, keep each
instruction's mnemonic and registers, replace every number (address,
offset, immediate) by N, then align the two instruction streams.

Usage: python normalign.py WON_UNPACKED.EXE BUILT_DIR SHIPPED_DIR
Compares the three module code segments of the unpacked WON.EXE with the
Civil War Strategy objects compiled by calibrate_bc.py into BUILT_DIR
(CWSTRAT.OBJ, CWSTRAT2.OBJ, CWSMENU.OBJ). As a control, compares the
compiled CWSMENU.OBJ with Hutsell's own CWSMENU.OBJ in SHIPPED_DIR.
"""
import difflib
import re
import sys
from pathlib import Path

import capstone

sys.path.insert(0, str(Path(__file__).parent))
from omfdump import parse  # noqa: E402

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_16)
NUM = re.compile(r"(0x[0-9a-f]+|\b\d+\b)")


def shapes(code: bytes):
    out = []
    p = 0
    while p < len(code):
        insn = next(md.disasm(code[p:p + 16], p), None)
        if insn is None:
            out.append("db")
            p += 1
            continue
        out.append(insn.mnemonic + " " + NUM.sub("N", insn.op_str))
        p += insn.size
    return out


def compare(label, a: bytes, b: bytes):
    x, y = shapes(a), shapes(b)
    sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
    same = sum(bl.size for bl in sm.get_matching_blocks() if bl.size >= 4)
    print(f"{label}: {same} of {len(y)} instructions align in runs of 4+ ({100 * same / len(y):.0f}%)")


def module_segments(exe: bytes, names):
    """Each module's code, from its "bl<NAME>" marker to the next marker (the last: 19,000 bytes)."""
    starts = sorted((exe.find(b"bl" + n.encode().ljust(8)[:8]), n) for n in names)
    out = {}
    for i, (s, n) in enumerate(starts):
        if s < 0:
            raise SystemExit(f"module {n} not found")
        end = starts[i + 1][0] if i + 1 < len(starts) else s + 19000
        out[n] = exe[s:end]
    return out


def main():
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    exe = Path(sys.argv[1]).read_bytes()
    built, shipped_dir = Path(sys.argv[2]), Path(sys.argv[3])
    won = module_segments(exe, ["WON", "WON2", "WONMENU"])
    cws = {n: bytes(parse(str(built / f"{n}.OBJ"))[2][1]) for n in ("CWSTRAT", "CWSTRAT2", "CWSMENU")}
    shipped = {"CWSMENU": bytes(parse(str(shipped_dir / "CWSMENU.OBJ"))[2][1])}
    compare("control: rebuilt CWSMENU vs shipped CWSMENU.OBJ", cws["CWSMENU"], shipped["CWSMENU"])
    compare("WONMENU vs CWSMENU", cws["CWSMENU"], won["WONMENU"])
    compare("WON2 vs CWSTRAT2", cws["CWSTRAT2"], won["WON2"])
    compare("WON vs CWSTRAT", cws["CWSTRAT"], won["WON"])


if __name__ == "__main__":
    main()
