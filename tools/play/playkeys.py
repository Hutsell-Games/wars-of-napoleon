"""PLAYKEYS.COM, the key player of the play harness, and its key file format.

PLAYKEYS.COM is a small resident DOS program. Run as "PLAYKEYS KEYS.BIN", it
reads the key file into memory, hooks the timer interrupt (INT 8, 18.2 times
a second of emulated time) and stays resident. On each tick it counts down;
when the count reaches zero it performs the next operation:

- a key: the key's word (scan code * 256 + character) is put at the tail of
  the BIOS keyboard buffer, as if the key had been typed. Programs that read
  keys through the BIOS (INKEY$, INPUT) get it. If the buffer is full, the
  key is dropped.
- a screenshot: DOSBox-X's integration device is asked for a screenshot.
  It needs "integration device=true" in the [cpu] section. The protocol:
  write 00h to port 2Ah to reset the byte latch, write the 32-bit register
  number to port 28h low byte first, reset the latch again, then write the
  32-bit value to port 29h. Register 00C54010h with value 1 takes a
  screenshot.

Then it loads the next delay. A delay of 0 runs the next operation in the
same tick. Because the ticks are emulated time, a run with fixed CPU cycles
gets each key at the same point of the program every time.

At the end of the key file it stops the emulated machine (cli / hlt), in the
same tick as the last operation. So whatever the host does next, the game's
files are as they were at that point in every run. DOSBox-X itself keeps
running: the screen is still drawn, so a screenshot asked for in that tick is
still saved.

Key file (KEYS.BIN), all words little-endian:
    first_delay:u16  { op:u8  [key:u16 if op = 1]  delay:u16 }*  0:u8
op 1 = key, op 2 = screenshot, op 0 = end.
"""
import struct

SCREENSHOT_REG = 0x00C54010
ORG = 0x100
MAX_KEYFILE = 32000
TICKS_PER_SECOND = 1193182 / 65536  # 18.2065


class Asm:
    """Just enough of a two-pass assembler: bytes, labels, short and near jumps,
    and 16-bit absolute addresses of labels."""

    def __init__(self):
        self.parts = []  # (kind, payload)

    def b(self, *xs):
        self.parts.append(("bytes", bytes(xs)))

    def raw(self, data):
        self.parts.append(("bytes", bytes(data)))

    def label(self, name):
        self.parts.append(("label", name))

    def jshort(self, opcode, target):
        self.parts.append(("jshort", (opcode, target)))

    def jnear(self, target):
        self.parts.append(("jnear", target))

    def addr(self, prefix, target, suffix=b""):
        """prefix bytes, then the 16-bit address of target, then suffix bytes."""
        self.parts.append(("addr", (bytes(prefix), target, bytes(suffix))))

    @staticmethod
    def _size(kind, payload):
        if kind == "bytes":
            return len(payload)
        if kind == "label":
            return 0
        if kind == "jshort":
            return 2
        if kind == "jnear":
            return 3
        prefix, _, suffix = payload
        return len(prefix) + 2 + len(suffix)

    def assemble(self, extra=None):
        """Return (code, labels). extra gives values for names that are not labels."""
        labels, pc = dict(extra or {}), ORG
        for kind, payload in self.parts:
            if kind == "label":
                labels[payload] = pc
            pc += self._size(kind, payload)
        labels["$end"] = pc
        out, pc = bytearray(), ORG
        for kind, payload in self.parts:
            size = self._size(kind, payload)
            if kind == "bytes":
                out += payload
            elif kind == "jshort":
                opcode, target = payload
                rel = labels[target] - (pc + 2)
                if not -128 <= rel <= 127:
                    raise ValueError(f"short jump to {target} out of range ({rel})")
                out += bytes([opcode, rel & 0xFF])
            elif kind == "jnear":
                out += b"\xE9" + struct.pack("<h", labels[payload] - (pc + 3))
            elif kind == "addr":
                prefix, target, suffix = payload
                out += prefix + struct.pack("<H", labels[target]) + suffix
            pc += size
        return bytes(out), labels


def out_byte(a, port, val):
    a.b(0xBA, port & 0xFF, port >> 8)  # mov dx, port
    a.b(0xB0, val)  # mov al, val
    a.b(0xEE)  # out dx, al


def build_com():
    a = Asm()
    a.jnear("install")

    # ---- resident part ----
    a.label("old")
    a.b(0, 0, 0, 0)
    a.label("count")
    a.b(0, 0)
    a.label("ptr")
    a.b(0, 0)
    a.label("done")
    a.b(1)  # set to 0 by the installer once the key file is read

    a.label("handler")
    a.b(0x50, 0x53, 0x52, 0x56, 0x1E, 0x06)  # push ax bx dx si ds es
    a.b(0x0E, 0x1F)  # push cs / pop ds
    a.b(0xFC)  # cld
    a.addr([0x80, 0x3E], "done", [0x00])  # cmp byte [done], 0
    a.jshort(0x75, "chain")  # jne chain
    a.addr([0xFF, 0x0E], "count")  # dec word [count]
    a.jshort(0x74, "next")  # jz next

    a.label("chain")
    a.b(0x07, 0x1F, 0x5E, 0x5A, 0x5B, 0x58)  # pop es ds si dx bx ax
    a.addr([0x2E, 0xFF, 0x2E], "old")  # jmp far cs:[old]

    a.label("next")
    a.addr([0x8B, 0x36], "ptr")  # mov si, [ptr]
    a.b(0xAC)  # lodsb (op)
    a.b(0x3C, 0x01)  # cmp al, 1
    a.jshort(0x74, "key")
    a.b(0x3C, 0x02)  # cmp al, 2
    a.jshort(0x74, "shot")
    a.label("finish")
    # The end of the script: stop the machine for good. Interrupts stay off, so nothing
    # runs again, and the game's files and screen stay as they were at the last operation.
    a.b(0xFA)  # cli
    a.label("frozen")
    a.b(0xF4)  # hlt
    a.jshort(0xEB, "frozen")  # jmp frozen

    a.label("key")
    a.b(0xAD)  # lodsw (key word)
    a.b(0xBB, 0x40, 0x00, 0x8E, 0xC3)  # mov bx, 40h / mov es, bx
    a.b(0x26, 0x8B, 0x1E, 0x1C, 0x00)  # mov bx, es:[1Ch] (tail)
    a.b(0x8B, 0xD3)  # mov dx, bx
    a.b(0x83, 0xC2, 0x02)  # add dx, 2
    a.b(0x26, 0x3B, 0x16, 0x82, 0x00)  # cmp dx, es:[82h] (buffer end)
    a.jshort(0x72, "nowrap")  # jb nowrap
    a.b(0x26, 0x8B, 0x16, 0x80, 0x00)  # mov dx, es:[80h] (buffer start)
    a.label("nowrap")
    a.b(0x26, 0x3B, 0x16, 0x1A, 0x00)  # cmp dx, es:[1Ah] (head): full?
    a.jshort(0x74, "after")  # je after (drop the key)
    a.b(0x26, 0x89, 0x07)  # mov es:[bx], ax
    a.b(0x26, 0x89, 0x16, 0x1C, 0x00)  # mov es:[1Ch], dx
    a.jshort(0xEB, "after")

    a.label("shot")
    out_byte(a, 0x2A, 0)
    for x in struct.pack("<I", SCREENSHOT_REG):
        out_byte(a, 0x28, x)
    out_byte(a, 0x2A, 0)
    for x in struct.pack("<I", 1):
        out_byte(a, 0x29, x)

    a.label("after")
    a.b(0xAD)  # lodsw (delay to the next op)
    a.addr([0x89, 0x36], "ptr")  # mov [ptr], si
    a.addr([0xA3], "count")  # mov [count], ax
    a.b(0x09, 0xC0)  # or ax, ax
    a.jshort(0x74, "again")  # jz again: a delay of 0 runs the next op now
    a.jnear("chain")
    a.label("again")
    a.jnear("next")

    # ---- installer ----
    a.label("install")
    a.b(0xFC)  # cld
    a.b(0xBE, 0x81, 0x00)  # mov si, 81h (command tail)
    a.label("skip")
    a.b(0xAC, 0x3C, 0x20)  # lodsb / cmp al, ' '
    a.jshort(0x74, "skip")
    a.b(0x4E)  # dec si
    a.b(0x8B, 0xD6)  # mov dx, si (file name)
    a.label("scan")
    a.b(0xAC, 0x3C, 0x20)  # lodsb / cmp al, ' '
    a.jshort(0x77, "scan")  # ja scan (stop at CR, space or anything below)
    a.b(0xC6, 0x44, 0xFF, 0x00)  # mov byte [si-1], 0
    a.b(0xB8, 0x00, 0x3D, 0xCD, 0x21)  # mov ax, 3D00h / int 21h (open)
    a.jshort(0x72, "fail")
    a.b(0x8B, 0xD8)  # mov bx, ax
    a.b(0xB4, 0x3F)  # mov ah, 3Fh (read)
    a.raw(b"\xB9" + struct.pack("<H", MAX_KEYFILE))  # mov cx, MAX_KEYFILE
    a.addr([0xBA], "keys")  # mov dx, keys
    a.b(0xCD, 0x21)
    a.jshort(0x72, "fail")
    a.b(0xB4, 0x3E, 0xCD, 0x21)  # mov ah, 3Eh / int 21h (close)
    a.addr([0xA1], "keys")  # mov ax, [keys] (first delay)
    a.addr([0xA3], "count")  # mov [count], ax
    a.addr([0xC7, 0x06], "ptr")  # mov word [ptr], imm16 ...
    a.addr([], "keys2")  # ... where imm16 is the address of keys + 2
    a.b(0xB8, 0x08, 0x35, 0xCD, 0x21)  # mov ax, 3508h / int 21h (es:bx = old INT 8)
    a.addr([0x89, 0x1E], "old")  # mov [old], bx
    a.addr([0x8C, 0x06], "old2")  # mov [old+2], es
    a.addr([0xBA], "handler")  # mov dx, handler
    a.b(0xB8, 0x08, 0x25, 0xCD, 0x21)  # mov ax, 2508h / int 21h
    a.addr([0xC6, 0x06], "done", [0x00])  # mov byte [done], 0
    a.addr([0xBA], "paras")  # mov dx, paragraphs (patched below)
    a.b(0xB8, 0x00, 0x31, 0xCD, 0x21)  # mov ax, 3100h / int 21h (stay resident)

    a.label("fail")
    a.addr([0xBA], "msg")  # mov dx, msg
    a.b(0xB4, 0x09, 0xCD, 0x21)  # mov ah, 9 / int 21h
    a.b(0xB8, 0x01, 0x4C, 0xCD, 0x21)  # mov ax, 4C01h / int 21h
    a.label("msg")
    a.raw(b"PLAYKEYS: cannot read the key file\r\n$")
    a.label("keys")
    return a


def com_bytes():
    a = build_com()
    # old+2, keys+2 and the paragraph count depend on labels; sizes do not depend on them.
    _, labels = a.assemble({"old2": 0, "keys2": 0, "paras": 0})
    keys = labels["keys"]
    resident_end = keys + MAX_KEYFILE
    extra = {"old2": labels["old"] + 2, "keys2": keys + 2, "paras": (resident_end + 15) // 16}
    code, _ = a.assemble(extra)
    if resident_end > 0xFF00:
        raise ValueError("key buffer does not fit in the segment")
    return code


def keyfile(ops, first_delay):
    """ops: list of (op, key_word or None, delay_after) with op 1 = key, 2 = shot.
    Delays are timer ticks; the last op's delay_after is the wait before the machine stops."""
    if not 0 <= first_delay <= 0xFFFF or any(not 0 <= d <= 0xFFFF for _, _, d in ops):
        raise ValueError("a wait is longer than 65535 timer ticks (about an hour)")
    out = bytearray(struct.pack("<H", max(1, first_delay)))
    for op, word, delay in ops:
        out.append(op)
        if op == 1:
            out += struct.pack("<H", word)
        out += struct.pack("<H", delay)
    out.append(0)
    if len(out) > MAX_KEYFILE:
        raise ValueError(f"key file is {len(out)} bytes, more than {MAX_KEYFILE}")
    return bytes(out)
