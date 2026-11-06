"""Read an OMF library (.LIB) or object file (.OBJ) into modules.

Each module gives its segments (name, class, size, bytes), a mask of the
bytes that LINK fills in (fixups), and its public symbols. The runtime map
(runtimemap.py) uses this to find each library module in a linked program.

Usage: python -I omflib.py FILE.LIB [MODULE]
Lists the modules with their code size and public names. With a module
name, also lists its segments and the offset of each public name.
"""
import struct
import sys
from dataclasses import dataclass, field

# How many bytes each fixup location type covers.
LOC_SIZE = {0: 1, 1: 2, 2: 2, 3: 4, 4: 1, 5: 2, 9: 4, 11: 6, 13: 4}


@dataclass
class Segment:
    name: str
    cls: str
    size: int
    data: bytearray = field(default_factory=bytearray)
    fixed: bytearray = field(default_factory=bytearray)  # 1 where a fixup writes

    def is_code(self):
        return self.cls.upper().endswith("CODE")


@dataclass
class Module:
    name: str
    segments: list  # index 0 unused, as in OMF
    publics: list  # (name, segment index, offset); segment index 0 = absolute
    externs: list  # index 0 unused


def _index(b, p):
    if b[p] & 0x80:
        return ((b[p] & 0x7F) << 8) | b[p + 1], p + 2
    return b[p], p + 1


def _parse_fixupp(body, wide, last):
    """Mark the bytes of the last LEDATA/LIDATA that this FIXUPP record patches."""
    p = 0
    while p < len(body):
        b0 = body[p]
        if not b0 & 0x80:  # THREAD subrecord
            method = (b0 >> 2) & 7
            p += 1
            if b0 & 0x40:  # target thread: methods 0..3 carry an index
                method &= 3
            if method < 3:
                _, p = _index(body, p)
            elif method == 3:
                p += 2
            continue
        locat = (b0 << 8) | body[p + 1]
        loc = (locat >> 10) & 0x0F
        offset = locat & 0x3FF
        p += 2
        fixdat = body[p]
        p += 1
        if not fixdat & 0x80:  # explicit frame
            frame = (fixdat >> 4) & 7
            if frame < 3:
                _, p = _index(body, p)
            elif frame == 3:
                p += 2
        if not fixdat & 0x08:  # explicit target
            target = fixdat & 3
            if target < 3:
                _, p = _index(body, p)
            else:
                p += 2
        if not fixdat & 0x04:  # displacement present
            p += 4 if wide else 2
        if last is not None:
            seg, start = last
            n = LOC_SIZE.get(loc, 2)
            for i in range(start + offset, start + offset + n):
                if i < len(seg.fixed):
                    seg.fixed[i] = 1


def _expand_lidata(body, q, wide):
    """Expand one LIDATA iterated data block; return (bytes, new position)."""
    if wide:
        count = struct.unpack_from("<I", body, q)[0]
        q += 4
    else:
        count = struct.unpack_from("<H", body, q)[0]
        q += 2
    blocks = struct.unpack_from("<H", body, q)[0]
    q += 2
    if blocks == 0:
        n = body[q]
        content = bytes(body[q + 1 : q + 1 + n])
        q += 1 + n
    else:
        parts = []
        for _ in range(blocks):
            part, q = _expand_lidata(body, q, wide)
            parts.append(part)
        content = b"".join(parts)
    return content * count, q


def parse_module(b, p):
    """Parse one module starting at THEADR; return (Module, position after MODEND)."""
    names = [None]
    segs = [None]
    publics = []
    externs = [None]
    module = ""
    last = None
    while p < len(b):
        typ = b[p]
        ln = struct.unpack_from("<H", b, p + 1)[0]
        body = b[p + 3 : p + 3 + ln - 1]
        wide = typ & 1
        p += 3 + ln
        if typ == 0x80:
            module = body[1 : 1 + body[0]].decode("latin1")
        elif typ == 0x96:
            q = 0
            while q < len(body):
                n = body[q]
                names.append(body[q + 1 : q + 1 + n].decode("latin1"))
                q += 1 + n
        elif typ in (0x98, 0x99):
            attr = body[0]
            q = 1
            if (attr >> 5) == 0:
                q += 3
            if typ == 0x98:
                size = struct.unpack_from("<H", body, q)[0]
                q += 2
                if attr & 2 and size == 0:
                    size = 0x10000
            else:
                size = struct.unpack_from("<I", body, q)[0]
                q += 4
            ni, q = _index(body, q)
            ci, q = _index(body, q)
            segs.append(Segment(names[ni], names[ci], size, bytearray(size), bytearray(size)))
        elif typ in (0x8C, 0xB4):  # EXTDEF, LEXTDEF
            q = 0
            while q < len(body):
                n = body[q]
                externs.append(body[q + 1 : q + 1 + n].decode("latin1"))
                q += 1 + n
                _, q = _index(body, q)
        elif typ == 0xB0:  # COMDEF: name, type index, data type, length(s)
            q = 0
            while q < len(body):
                n = body[q]
                externs.append(body[q + 1 : q + 1 + n].decode("latin1"))
                q += 1 + n
                _, q = _index(body, q)
                dtype = body[q]
                q += 1
                for _ in range(2 if dtype == 0x61 else 1):
                    first = body[q]
                    q += {0x81: 3, 0x84: 4, 0x88: 5}.get(first, 1)
        elif typ in (0x90, 0x91, 0xB6, 0xB7):  # PUBDEF, LPUBDEF
            _, q = _index(body, 0)  # group
            si, q = _index(body, q)
            if si == 0:
                q += 2
            while q < len(body):
                n = body[q]
                name = body[q + 1 : q + 1 + n].decode("latin1")
                q += 1 + n
                if wide:
                    off = struct.unpack_from("<I", body, q)[0]
                    q += 4
                else:
                    off = struct.unpack_from("<H", body, q)[0]
                    q += 2
                _, q = _index(body, q)
                publics.append((name, si, off))
        elif typ in (0xA0, 0xA1):
            si, q = _index(body, 0)
            if wide:
                off = struct.unpack_from("<I", body, q)[0]
                q += 4
            else:
                off = struct.unpack_from("<H", body, q)[0]
                q += 2
            seg = segs[si]
            chunk = body[q:]
            seg.data[off : off + len(chunk)] = chunk
            last = (seg, off)
        elif typ in (0xA2, 0xA3):
            si, q = _index(body, 0)
            if wide:
                off = struct.unpack_from("<I", body, q)[0]
                q += 4
            else:
                off = struct.unpack_from("<H", body, q)[0]
                q += 2
            seg = segs[si]
            out = bytearray()
            while q < len(body):
                part, q = _expand_lidata(body, q, wide)
                out += part
            seg.data[off : off + len(out)] = out
            last = None  # fixups of iterated data are not tracked
        elif typ in (0x9C, 0x9D):
            _parse_fixupp(body, wide, last)
        elif typ in (0x8A, 0x8B):
            return Module(module, segs, publics, externs), p
    return Module(module, segs, publics, externs), p


def read_library(path):
    """Return the modules of an OMF library, or the one module of an object file."""
    b = open(path, "rb").read()
    if b[0] != 0xF0:
        return [parse_module(b, 0)[0]]
    page = struct.unpack_from("<H", b, 1)[0] + 3
    p = page
    modules = []
    while p < len(b) and b[p] == 0x80:
        mod, end = parse_module(b, p)
        modules.append(mod)
        p = (end + page - 1) // page * page
    return modules


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    mods = read_library(sys.argv[1])
    if len(sys.argv) == 2:
        for m in mods:
            code = sum(s.size for s in m.segments[1:] if s.is_code())
            names = " ".join(n for n, _, _ in m.publics[:6])
            print(f"{m.name:14} code {code:6}  {names}")
        print(f"{len(mods)} modules")
        return
    want = sys.argv[2].upper()
    for m in mods:
        if m.name.upper() != want:
            continue
        for i, s in enumerate(m.segments[1:], 1):
            print(f"seg {i} {s.name:14} {s.cls:10} size {s.size:6} fixed {sum(s.fixed)}")
        for name, si, off in m.publics:
            print(f"   {name:24} seg {si} +{off:04x}")


if __name__ == "__main__":
    main()
