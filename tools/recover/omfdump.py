"""Summarize an OMF object file: module name, segments and their sizes,
and the bytes of each segment's LEDATA records (concatenated by offset).

Usage: python -I omfdump.py FILE.OBJ [OTHER.OBJ]
With two files, also reports for each segment how many code bytes are equal.
"""
import struct
import sys


def index(b, p):
    if b[p] & 0x80:
        return ((b[p] & 0x7F) << 8) | b[p + 1], p + 2
    return b[p], p + 1


def parse(path):
    b = open(path, "rb").read()
    p = 0
    names = [None]
    segs = [None]
    data = {}
    module = ""
    while p < len(b):
        typ = b[p]
        ln = struct.unpack_from("<H", b, p + 1)[0]
        body = b[p + 3 : p + 3 + ln - 1]
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
            else:
                size = struct.unpack_from("<I", body, q)[0]
                q += 4
            ni, q = index(body, q)
            segs.append((names[ni], size))
        elif typ in (0xA0, 0xA1):
            si, q = index(body, 0)
            off = struct.unpack_from("<H", body, q)[0]
            q += 2
            buf = data.setdefault(si, bytearray())
            chunk = body[q:]
            if len(buf) < off + len(chunk):
                buf.extend(b"\0" * (off + len(chunk) - len(buf)))
            buf[off : off + len(chunk)] = chunk
        elif typ == 0x8A or typ == 0x8B:
            break
        p += 3 + ln
    return module, segs, data


def main():
    first = parse(sys.argv[1])
    other = parse(sys.argv[2]) if len(sys.argv) > 2 else None
    for label, (module, segs, data) in [("A", first)] + ([("B", other)] if other else []):
        print(f"{label}: module {module!r}")
        for i, s in enumerate(segs[1:], 1):
            print(f"   seg {i} {s[0]:12} size {s[1]}")
    if other:
        for i in range(1, min(len(first[1]), len(other[1]))):
            a = first[2].get(i, b"")
            c = other[2].get(i, b"")
            same = sum(1 for x, y in zip(a, c) if x == y)
            print(f"seg {i} {first[1][i][0]}: {len(a)} vs {len(c)} bytes, {same} equal at the same offset")


if __name__ == "__main__":
    main()
