"""Make WONSEED.EXE: the unpacked WON.EXE with RANDOMIZE TIMER replaced by
RANDOMIZE with a fixed number, so that the same keys always give the same game.

Usage: python -I wonseed.py WON.EXE OUT.EXE [--seed N]

WON.EXE may be the shipped (packed) program or the unpacked one: it is unpacked
first with tools\\recover\\unlzexe91.py.

WON.EXE seeds its random numbers once, at WON.BAS line 78 (RANDOMIZE TIMER).
BC compiles that to:

    call far B$TIMR          ; TIMER, returns a pointer to a SINGLE in ax
    mov si, ax
    fld dword ptr [si]       ; floating-point emulator calls (INT 35h ...)
    sub sp, 8
    mov bx, sp
    fstp qword ptr [bx]      ; the value as a DOUBLE on the stack
    fwait
    call far B$RNZP          ; RANDOMIZE

The bytes from the first call up to B$RNZP are replaced by four
"mov ax, imm16 / push ax" pairs that push the DOUBLE N, then NOPs. The
far call's relocation entry is removed from the MZ header. Everything
else stays as it is, and the script checks that.

The call is found by its target: B$TIMR and B$RNZP's addresses in the
shipped program's load image, from tools\\recover\\runtimemap.py. They hold
only for the shipped WON.EXE, so its SHA-256 is checked. For another build
(the recovered source, step 6), pass --timr and --rnzp from its own
runtime map.
"""
import argparse
import hashlib
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "recover"))
from unlzexe91 import unpack  # noqa: E402

# The unpacked shipped WON.EXE (1998), and its runtime routines (runtimemap.py).
SHIPPED_UNPACKED_SHA256 = "63c8895d69c5c6e55f7e49a4791707aabb6e1cf049816c6381903b0dccea9093"
B_TIMR = 0x27C7C
B_RNZP = 0x24389


def unpacked(exe_bytes):
    """The plain MZ file of a program packed with LZEXE and EXEPACK, or the program itself."""
    try:
        return bytes(unpack(exe_bytes)[0])
    except Exception:  # not packed
        return bytes(exe_bytes)


def patch(data, timr, rnzp, seed):
    """Return (patched MZ bytes, load-image offset, span) for an unpacked WON.EXE."""
    data = bytearray(data)
    w = list(struct.unpack_from("<14H", data, 0))
    if w[0] != 0x5A4D:
        raise ValueError("not an MZ file")
    hdr = w[4] * 16
    nrel, reltab = w[3], w[12]
    relocs = [struct.unpack_from("<HH", data, reltab + 4 * i) for i in range(nrel)]
    image_reloc = {seg * 16 + off for off, seg in relocs}
    image = data[hdr:]

    def far_target(i):
        off, seg = struct.unpack_from("<HH", image, i + 1)
        return seg * 16 + off

    found = []
    for i in range(len(image) - 40):
        if image[i] != 0x9A or (i + 3) not in image_reloc or far_target(i) != timr:
            continue
        if image[i + 5:i + 7] != b"\x8b\xf0":  # mov si, ax
            continue
        for j in range(i + 7, i + 40):
            if image[j] == 0x9A and (j + 3) in image_reloc and far_target(j) == rnzp:
                found.append((i, j))
                break
    if len(found) != 1:
        raise ValueError(f"expected one RANDOMIZE TIMER, found {len(found)}")
    start, end = found[0]
    span = end - start

    code = bytearray()
    words = struct.unpack("<4H", struct.pack("<d", seed))
    for word in reversed(words):  # the low word ends up at the lowest address
        code += b"\xb8" + struct.pack("<H", word) + b"\x50"  # mov ax, imm16 / push ax
    if len(code) > span:
        raise ValueError(f"patch is {len(code)} bytes, the sequence only {span}")
    code += b"\x90" * (span - len(code))

    # No relocation may fall inside the patched bytes except the B$TIMR call's.
    inside = sorted(r for r in image_reloc if start <= r < end)
    if inside != [start + 3]:
        raise ValueError(f"relocations inside the patch: {[hex(r) for r in inside]}")

    before = bytes(data)
    data[hdr + start:hdr + end] = code
    keep = [(off, seg) for off, seg in relocs if seg * 16 + off != start + 3]
    for k, (off, seg) in enumerate(keep):
        struct.pack_into("<HH", data, reltab + 4 * k, off, seg)
    struct.pack_into("<HH", data, reltab + 4 * len(keep), 0, 0)
    struct.pack_into("<H", data, 6, len(keep))

    # Check: only the patched bytes, the relocation count and the table changed.
    allowed = set(range(hdr + start, hdr + end)) | {6, 7} | set(range(reltab, reltab + 4 * nrel))
    stray = [k for k in range(len(data)) if data[k] != before[k] and k not in allowed]
    if stray:
        raise ValueError(f"unexpected changes at {[hex(k) for k in stray[:10]]}")
    return bytes(data), start, span


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("out")
    ap.add_argument("--seed", type=float, default=1.0)
    ap.add_argument("--timr", type=lambda s: int(s, 16), default=B_TIMR)
    ap.add_argument("--rnzp", type=lambda s: int(s, 16), default=B_RNZP)
    a = ap.parse_args()
    data = unpacked(Path(a.exe).read_bytes())
    shipped = hashlib.sha256(data).hexdigest() == SHIPPED_UNPACKED_SHA256
    if not shipped and (a.timr, a.rnzp) == (B_TIMR, B_RNZP):
        raise SystemExit("not the shipped WON.EXE: pass --timr and --rnzp from its runtime map")
    out, start, span = patch(data, a.timr, a.rnzp, a.seed)
    Path(a.out).write_bytes(out)
    print(f"RANDOMIZE TIMER at load image {start:#x}, {span} bytes, now RANDOMIZE {a.seed!r}; wrote {a.out}")


if __name__ == "__main__":
    main()
