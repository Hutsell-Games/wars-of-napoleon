"""Find each runtime library module's code in a linked, unpacked program.

Usage: python -I runtimemap.py UNPACKED.EXE OUT.tsv LIB...

UNPACKED.EXE is a program after unlzexe91.py (a plain MZ file). Each code
segment of each library module is searched for in the load image. The
bytes that LINK fills in (fixups) are wildcards. A segment is:

  exact  - found at one place with every other byte equal;
  many   - found at more than one place (short or repeated code);
  near   - not found exactly; the best place has at least 80% of its
           bytes equal (Hutsell's library differs from ours in places);
  pieces - not found whole; at least half its bytes are found in order,
           in runs that may each be shifted (code inserted or removed);
  gap    - too short to search for (no run of 6 unfixed bytes), but fits
           exactly at one unclaimed place in the runtime;
  short  - too short, and not placed;
  none   - not found (most such modules are not linked at all).

OUT.tsv gets one row per public name of the modules placed: the linear
address in the load image, the name, the module and the status. Code that
calls the runtime with CALL FAR seg:off names its target by the linear
address seg*16+off. The summary goes to standard output: the counts, a
check of how many far calls from the game's code into the runtime hit a
name, then the modules in the order they lie in the program.

For WON.EXE and CWS.EXE, LIB is the library that buildlib.py makes:
Hutsell's runtime is the far-string one.
"""
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from omflib import read_library  # noqa: E402
from unlzexe91 import read_mz  # noqa: E402

MIN_ANCHOR = 6  # a segment with no longer run of fixed bytes is too short to place
NEAR = 0.80


def runs(fixed):
    """Runs of bytes that no fixup touches, as (start, length), longest first."""
    out = []
    i = 0
    n = len(fixed)
    while i < n:
        if fixed[i]:
            i += 1
            continue
        j = i
        while j < n and not fixed[j]:
            j += 1
        out.append((i, j - i))
        i = j
    return sorted(out, key=lambda r: -r[1])


def occurrences(image, needle):
    out = []
    p = image.find(needle)
    while p >= 0:
        out.append(p)
        p = image.find(needle, p + 1)
    return out


def score(image, start, seg):
    """Fraction of the segment's unfixed bytes equal at image[start:]."""
    if start < 0 or start + seg.size > len(image):
        return 0.0
    total = same = 0
    for i in range(seg.size):
        if seg.fixed[i]:
            continue
        total += 1
        if image[start + i] == seg.data[i]:
            same += 1
    return same / total if total else 0.0


def place(image, seg):
    """Return (status, [starts], score)."""
    rs = [r for r in runs(seg.fixed) if r[1] >= MIN_ANCHOR]
    if not rs:
        return "short", [], 0.0
    off, n = rs[0]
    anchor = bytes(seg.data[off : off + min(n, 32)])
    exact = [p - off for p in occurrences(image, anchor) if score(image, p - off, seg) == 1.0]
    if len(exact) == 1:
        return "exact", exact, 1.0
    if exact:
        return "many", exact, 1.0
    # Not exact: gather candidate starts from the longer runs, keep the best.
    cands = set()
    for off, n in rs[:12]:
        if n < 8:
            break
        for p in occurrences(image, bytes(seg.data[off : off + min(n, 16)])):
            cands.add(p - off)
    best, where = 0.0, None
    for c in cands:
        s = score(image, c, seg)
        if s > best:
            best, where = s, c
    if best >= NEAR:
        return "near", [where], best
    return "none", [], best


def piecewise(image, seg, claimed, lo, hi):
    """Second pass for a segment that differs from Hutsell's copy by inserted or
    removed code. Each run of unfixed bytes (6 or more) is looked for in the
    unclaimed bytes between lo and hi. The shift (image address minus segment
    offset) with the most matched bytes wins; other runs may keep their own
    shift if it is within 1 KB of it and keeps the order. Returns
    (coverage, [(segment offset, shift)]) or None."""
    hits = []  # (offset, length, shift)
    for off, n in runs(seg.fixed):
        if n < MIN_ANCHOR:
            break
        needle = bytes(seg.data[off : off + n])
        p = image.find(needle, lo, hi)
        found = 0
        while p >= 0 and found < 40:
            if not any(claimed[p : p + n]):
                hits.append((off, n, p - off))
            found += 1
            p = image.find(needle, p + 1, hi)
    if not hits:
        return None
    weight = {}
    for off, n, d in hits:
        weight[d] = weight.get(d, 0) + n
    d0 = max(weight, key=weight.get)
    # For each run, take the hit whose shift is closest to d0, within 1 KB.
    best = {}
    for off, n, d in hits:
        if abs(d - d0) <= 1024 and (off not in best or abs(d - d0) < abs(best[off][1] - d0)):
            best[off] = (n, d)
    chain = []
    last_addr = -1
    for off in sorted(best):
        n, d = best[off]
        if off + d > last_addr:  # keep the order of the code
            chain.append((off, n, d))
            last_addr = off + d + n
    unfixed = seg.size - sum(seg.fixed)
    covered = sum(n for _, n, _ in chain)
    return covered / unfixed if unfixed else 0.0, [(off, d) for off, _, d in chain]


def shift_at(pieces, off):
    """The shift of the last matched run at or before off (else the first)."""
    d = pieces[0][1]
    for o, s in pieces:
        if o > off:
            break
        d = s
    return d


def main():
    if len(sys.argv) < 4:
        raise SystemExit(__doc__)
    mz = read_mz(Path(sys.argv[1]).read_bytes())
    image = bytes(mz.data)
    out_path = Path(sys.argv[2])
    rows = []
    placed = []  # (start, end, module, status)
    counts = {}
    code_bytes = {}
    claimed = bytearray(len(image))
    later = []
    shorts = []
    for lib in sys.argv[3:]:
        for m in read_library(lib):
            segs = [(i, s) for i, s in enumerate(m.segments) if s is not None and s.is_code() and s.size]
            if not segs:
                continue
            for si, seg in segs:
                status, starts, sc = place(image, seg)
                label = f"{m.name}:{seg.name}"
                if status == "none":
                    later.append((m, si, seg, label))
                    continue
                counts[status] = counts.get(status, 0) + 1
                code_bytes[status] = code_bytes.get(status, 0) + seg.size
                if status in ("exact", "near"):
                    start = starts[0]
                    claimed[start : start + seg.size] = b"\1" * seg.size
                    placed.append((start, start + seg.size, label, status, sc))
                    for name, psi, off in m.publics:
                        if psi == si:
                            rows.append((start + off, name, label, status))
                elif status == "many":
                    print(f"many  {label} ({seg.size} bytes) at {len(starts)} places")
                elif status == "short":
                    shorts.append((m, si, seg, label))
    # Pass 2: the runtime lies after the game's code, from the first module found.
    lo = min(p[0] for p in placed) if placed else 0
    later.sort(key=lambda t: -t[2].size)
    for m, si, seg, label in later:
        got = piecewise(image, seg, claimed, lo, len(image))
        if got is None or got[0] < 0.5 or len(got[1]) < 2:
            status = "none"
        else:
            status = "pieces"
            cov, pieces = got
            start = pieces[0][0] + pieces[0][1]
            end = seg.size + pieces[-1][1]
            claimed[start:end] = b"\1" * (end - start)
            placed.append((start, end, label, status, cov))
            for name, psi, off in m.publics:
                if psi == si:
                    rows.append((off + shift_at(pieces, off), name, label, status))
        counts[status] = counts.get(status, 0) + 1
        code_bytes[status] = code_bytes.get(status, 0) + seg.size
    # Pass 3: segments too short for an anchor are tried at every unclaimed place
    # inside the runtime area; one with a single place where all its unfixed bytes
    # are equal is taken. Longest first, so that one does not take another's place.
    hi = max(p[1] for p in placed) if placed else 0
    shorts.sort(key=lambda t: -t[2].size)
    for m, si, seg, label in shorts:
        fits = [
            c for c in range(lo, hi - seg.size + 1)
            if not any(claimed[c : c + seg.size]) and score(image, c, seg) == 1.0
        ]
        if len(fits) == 1:
            start = fits[0]
            claimed[start : start + seg.size] = b"\1" * seg.size
            placed.append((start, start + seg.size, label, "gap", 1.0))
            for name, psi, off in m.publics:
                if psi == si:
                    rows.append((start + off, name, label, "gap"))
            counts["short"] -= 1
            code_bytes["short"] -= seg.size
            counts["gap"] = counts.get("gap", 0) + 1
            code_bytes["gap"] = code_bytes.get("gap", 0) + seg.size
    rows.sort()
    with out_path.open("w", encoding="ascii", newline="\n") as f:
        f.write("address\tname\tmodule\tstatus\n")
        for addr, name, label, status in rows:
            f.write(f"{addr:05x}\t{name}\t{label}\t{status}\n")
    print()
    for k in ("exact", "near", "pieces", "gap", "many", "short", "none"):
        print(f"{k:6} {counts.get(k, 0):4} segments, {code_bytes.get(k, 0):7} bytes")
    print(f"{len(rows)} public names written to {out_path}")
    # Check: each CALL FAR in the game's code (below the runtime) whose segment
    # word is relocated, and whose target is in the runtime, should hit a name.
    named = {addr for addr, _, _, _ in rows}
    relocs = {seg * 16 + off for off, seg in mz.relocs}
    hit = miss = 0
    for p in range(lo - 5):
        if image[p] == 0x9A and p + 3 in relocs:
            off, seg = struct.unpack_from("<HH", image, p + 1)
            target = seg * 16 + off
            if target >= lo:
                if target in named:
                    hit += 1
                else:
                    miss += 1
                    print(f"unnamed: CALL FAR at {p:05x} to {seg:04x}:{off:04x}")
    print(f"far calls from the game's code into the runtime: {hit} named, {miss} not")
    print("\nmodules in program order (start, end, module, status):")
    placed.sort()
    prev_end = None
    for start, end, label, status, sc in placed:
        gap = "" if prev_end is None else f"  gap {start - prev_end:+d}"
        extra = "" if status == "exact" else f"  {status} {sc:.0%}"
        print(f"  {start:05x}-{end:05x} {label}{extra}{gap}")
        prev_end = end


if __name__ == "__main__":
    main()
