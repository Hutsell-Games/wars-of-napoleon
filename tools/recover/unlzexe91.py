"""Unpack a DOS executable packed with LZEXE 0.91 and, under that, with
Microsoft's EXEPACK (LINK /EXEPACK, the /E of NWS.LNK and CWS.LNK).

Usage: python -I unlzexe91.py PACKED.EXE OUT.EXE

Writes an ordinary MZ executable with the original entry point, stack and
relocation table. The memory the program asks for in total stays the same.

Formats, as published:
- LZEXE 0.91 (as unlzexe.c): a 7-word header at CS:0 (real IP, CS, SP, SS,
  ...); the relocation table at CS:0x158; an LZ77 stream with a 16-bit bit
  buffer at the start of the load module.
- EXEPACK: a header at CS:0 (real IP, real CS, mem_start, exepack_size,
  real SP, real SS, dest_len, "RB"); the packed data is everything before
  CS:0 and is unpacked from its end backwards with fill (0xB0) and copy
  (0xB2) commands, the low bit marking the last one; the relocations follow
  the loader's message "Packed file is corrupt", as 16 groups (segment
  0x0000, 0x1000, ... 0xF000) of a count and that many offsets.
"""
import struct
import sys


class Image:
    def __init__(self, data, relocs, ip, cs, sp, ss, total_paras, max_alloc):
        self.data = bytearray(data)
        self.relocs = relocs  # list of (offset, segment)
        self.ip, self.cs, self.sp, self.ss = ip, cs, sp, ss
        self.total_paras = total_paras  # load module + min alloc, in paragraphs
        self.max_alloc = max_alloc


def read_mz(data: bytes) -> Image:
    w = struct.unpack_from("<14H", data, 0)
    size = w[2] * 512 - (512 - w[1] if w[1] else 0)
    hdr = w[4] * 16
    relocs = [struct.unpack_from("<HH", data, w[12] + 4 * i) for i in range(w[3])]
    load = data[hdr:size]
    total = (len(load) + 15) // 16 + w[5]
    return Image(load, relocs, w[10], w[11], w[8], w[7], total, w[6])


def un_lzexe(img: Image) -> Image:
    data = bytes(img.data)
    fpos = img.cs * 16
    ip, cs, sp, ss = struct.unpack_from("<4H", data, fpos)

    relocs = []
    p = fpos + 0x158
    rel_seg = rel_off = 0
    while True:
        span = data[p]
        p += 1
        if span == 0:
            span = struct.unpack_from("<H", data, p)[0]
            p += 2
            if span == 0:
                rel_seg += 0x0FFF
                continue
            if span == 1:
                break
        rel_off += span
        rel_seg += (rel_off & ~0x0F) >> 4
        rel_off &= 0x0F
        relocs.append((rel_off, rel_seg))

    src = 0
    out = bytearray()
    state = {"buf": struct.unpack_from("<H", data, 0)[0], "count": 16}
    src = 2

    def getbit():
        nonlocal src
        bit = state["buf"] & 1
        state["count"] -= 1
        if state["count"] == 0:
            state["buf"] = struct.unpack_from("<H", data, src)[0]
            src += 2
            state["count"] = 16
        else:
            state["buf"] >>= 1
        return bit

    def getc():
        nonlocal src
        c = data[src]
        src += 1
        return c

    while True:
        if getbit():
            out.append(getc())
            continue
        if not getbit():
            length = ((getbit() << 1) | getbit()) + 2
            span = getc() | 0xFF00
        else:
            lo = getc()
            hi = getc()
            span = lo | ((hi & ~0x07) << 5) | 0xE000
            length = (hi & 0x07) + 2
            if length == 2:
                length = getc()
                if length == 0:
                    break
                if length == 1:
                    continue
                length += 1
        start = len(out) + (span & 0xFFFF) - 0x10000
        for i in range(length):
            out.append(out[start + i])
    return Image(out, relocs, ip, cs, sp, ss, img.total_paras, img.max_alloc)


def un_exepack(img: Image) -> Image:
    data = bytes(img.data)
    base = img.cs * 16
    real_ip, real_cs, _mem, exepack_size, real_sp, real_ss, dest_len = struct.unpack_from("<7H", data, base)
    if data[base + 14 : base + 16] != b"RB":
        raise SystemExit("no EXEPACK signature")
    buf = bytearray(max(dest_len * 16, base))
    buf[:base] = data[:base]
    src = base - 1
    while data[src] == 0xFF:
        src -= 1
    dst = dest_len * 16 - 1
    while True:
        cmd = data[src]
        length = (data[src - 1] << 8) | data[src - 2]
        src -= 3
        if cmd & 0xFE == 0xB0:
            fill = data[src]
            src -= 1
            for _ in range(length):
                buf[dst] = fill
                dst -= 1
        elif cmd & 0xFE == 0xB2:
            for _ in range(length):
                buf[dst] = data[src]
                dst -= 1
                src -= 1
        else:
            raise SystemExit(f"bad EXEPACK command {cmd:#x} at {src + 3:#x}")
        if cmd & 1:
            break
    msg = data.find(b"Packed file is corrupt", base, base + exepack_size)
    if msg < 0:
        raise SystemExit("EXEPACK relocation table not found")
    p = msg + len(b"Packed file is corrupt")
    relocs = []
    for seg_index in range(16):
        count = struct.unpack_from("<H", data, p)[0]
        p += 2
        for _ in range(count):
            relocs.append((struct.unpack_from("<H", data, p)[0], seg_index * 0x1000))
            p += 2
    out = bytes(buf[: dest_len * 16])
    return Image(out, relocs, real_ip, real_cs, real_sp, real_ss, img.total_paras, img.max_alloc)


def write_mz(img: Image) -> bytes:
    nrel = len(img.relocs)
    hdr_size = (0x1C + nrel * 4 + 0x1FF) & ~0x1FF
    total = hdr_size + len(img.data)
    load_paras = (len(img.data) + 15) // 16
    min_alloc = max(0, img.total_paras - load_paras)
    header = struct.pack(
        "<14H",
        0x5A4D, total % 512, (total + 511) // 512, nrel, hdr_size // 16,
        min_alloc, max(img.max_alloc, min_alloc), img.ss, img.sp, 0, img.ip, img.cs, 0x1C, 0,
    )
    header += b"".join(struct.pack("<HH", o, s) for o, s in img.relocs)
    return header.ljust(hdr_size, b"\0") + bytes(img.data)


def unpack(data: bytes) -> tuple[bytes, list[str]]:
    steps = []
    img = read_mz(data)
    if data[0x1C:0x20] == b"LZ91":
        img = un_lzexe(img)
        steps.append(f"LZEXE 0.91 ({len(img.relocs)} relocations)")
    if bytes(img.data[img.cs * 16 + 14 : img.cs * 16 + 16]) == b"RB":
        img = un_exepack(img)
        steps.append(f"EXEPACK ({len(img.relocs)} relocations)")
    return write_mz(img), steps


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    with open(sys.argv[1], "rb") as f:
        data = f.read()
    result, steps = unpack(data)
    with open(sys.argv[2], "wb") as f:
        f.write(result)
    print(f"{sys.argv[1]}: {len(data)} -> {len(result)} bytes; unpacked: {', '.join(steps) or 'nothing'}")


if __name__ == "__main__":
    main()
