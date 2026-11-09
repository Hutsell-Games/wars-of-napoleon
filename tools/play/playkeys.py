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

Trace mode (com_bytes(trace=...), step 7a of docs/port-study.md). The port's
hooks announce each wait for a key: byte 0:4F0h counts the waits, 0:4F1h holds
the place and 0:4F2h the letter (SCRIPT.BM, announce). In trace mode
PLAYKEYS.COM writes a log of the run into its own memory, which the harness
reads from DOSBox-X's memory file after the run (read_trace):

- At each tick it adds the change of the count to a 16-bit total of waits.
  When the count changed, it logs a sample: the tick, the total, the place and
  the letter.
- At each key and screenshot of the key file it logs an event (K or S).
- It also hooks INT 16h. A call that reads a key (AH = 00h or 10h) is passed
  on, and then logged as an event R with the key read and the buffer slot it
  came from. DOS reads the keyboard through INT 16h too, so INKEY$ and INPUT
  are seen. A key that leaves the buffer with no R was thrown away (BuffClear
  sets the buffer's head and tail).

An event holds the type, the place and letter, the buffer slot, the total of
waits, the key, the tick, the video mode (0:449h) and, for K, 1 when the
buffer was full and the key was dropped. An R event also holds the PSP of the
program that read the key (INT 21h AH = 62h), which tells the strategic game's
reads from those of the programs it starts. The log lives in the part of the key
buffer that the key file does not fill, so the program stays resident with
the same number of paragraphs as without trace mode, and the game loads at
the same address as in the recordings.
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

    def call(self, target):
        self.parts.append(("call", target))

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
        if kind in ("jnear", "call"):
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
            elif kind in ("jnear", "call"):
                opcode = b"\xE9" if kind == "jnear" else b"\xE8"
                out += opcode + struct.pack("<h", labels[payload] - (pc + 3))
            elif kind == "addr":
                prefix, target, suffix = payload
                out += prefix + struct.pack("<H", labels[target]) + suffix
            pc += size
        return bytes(out), labels


def out_byte(a, port, val):
    a.b(0xBA, port & 0xFF, port >> 8)  # mov dx, port
    a.b(0xB0, val)  # mov al, val
    a.b(0xEE)  # out dx, al


def build_com(trace=None):
    """The program. trace is None, or (key area size, number of events) for trace mode."""
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
    if trace:
        # The trace header, at a place read_trace finds by its magic. The first byte is
        # "X" in the file and becomes "P" when the installer runs, so that only the resident
        # copy matches. The four offsets after the pointers are constants of this build.
        a.label("magic")
        a.raw(b"XKTRACE1")
        a.addr([], "magic")  # its own offset: the segment is where the magic is, less this
        a.label("sptr")
        a.b(0, 0)
        a.label("eptr")
        a.b(0, 0)
        a.label("tick")
        a.b(0, 0)
        a.label("total")
        a.b(0, 0)
        a.label("lastc")
        a.b(0)
        a.label("flags")
        a.b(0)  # bit 0: the samples were full; bit 1: the events were full
        a.label("kslot")
        a.b(0, 0)
        a.addr([], "estart_v")
        a.addr([], "eend_v")
        a.addr([], "sstart_v")
        a.addr([], "send_v")
        a.label("old16")
        a.b(0, 0, 0, 0)
        a.label("kpsp")
        a.b(0, 0)  # the PSP of the program that read the key, for the next event

    a.label("handler")
    if trace:
        a.b(0x50, 0x53, 0x51, 0x52, 0x56, 0x57, 0x1E, 0x06)  # push ax bx cx dx si di ds es
    else:
        a.b(0x50, 0x53, 0x52, 0x56, 0x1E, 0x06)  # push ax bx dx si ds es
    a.b(0x0E, 0x1F)  # push cs / pop ds
    a.b(0xFC)  # cld
    a.addr([0x80, 0x3E], "done", [0x00])  # cmp byte [done], 0
    a.jshort(0x75, "chain")  # jne chain
    if trace:
        a.call("sync")
        a.addr([0xFF, 0x06], "tick")  # inc word [tick]
    a.addr([0xFF, 0x0E], "count")  # dec word [count]
    a.jshort(0x74, "next")  # jz next

    a.label("chain")
    if trace:
        a.b(0x07, 0x1F, 0x5F, 0x5E, 0x5A, 0x59, 0x5B, 0x58)  # pop es ds di si dx cx bx ax
    else:
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
    if trace:
        a.b(0xB5, 0x01)  # mov ch, 1 (dropped, unless stored below)
    a.b(0x26, 0x3B, 0x16, 0x1A, 0x00)  # cmp dx, es:[1Ah] (head): full?
    a.jshort(0x74, "keylog" if trace else "after")  # je: drop the key
    a.b(0x26, 0x89, 0x07)  # mov es:[bx], ax
    a.b(0x26, 0x89, 0x16, 0x1C, 0x00)  # mov es:[1Ch], dx
    if trace:
        a.b(0xB5, 0x00)  # mov ch, 0
        a.label("keylog")
        a.b(0x88, 0xD9)  # mov cl, bl (the slot)
        a.b(0x89, 0xC2)  # mov dx, ax (the key)
        a.b(0xB0, ord("K"))  # mov al, 'K'
        a.call("event")
    a.jshort(0xEB, "after")

    a.label("shot")
    out_byte(a, 0x2A, 0)
    for x in struct.pack("<I", SCREENSHOT_REG):
        out_byte(a, 0x28, x)
    out_byte(a, 0x2A, 0)
    for x in struct.pack("<I", 1):
        out_byte(a, 0x29, x)
    if trace:
        a.b(0x31, 0xC9)  # xor cx, cx
        a.b(0x31, 0xD2)  # xor dx, dx
        a.b(0xB0, ord("S"))  # mov al, 'S'
        a.call("event")

    a.label("after")
    a.b(0xAD)  # lodsw (delay to the next op)
    a.addr([0x89, 0x36], "ptr")  # mov [ptr], si
    a.addr([0xA3], "count")  # mov [count], ax
    a.b(0x09, 0xC0)  # or ax, ax
    a.jshort(0x74, "again")  # jz again: a delay of 0 runs the next op now
    a.jnear("chain")
    a.label("again")
    a.jnear("next")

    if trace:
        # sync: add the change of the count at 0:4F0h to the total, and log a sample
        # (tick, total, place, letter) when it changed. ds = cs; uses ax, bx, di, es (left 0).
        a.label("sync")
        a.b(0x31, 0xDB, 0x8E, 0xC3)  # xor bx, bx / mov es, bx
        a.b(0x26, 0xA0, 0xF0, 0x04)  # mov al, es:[4F0h]
        a.b(0x88, 0xC4)  # mov ah, al
        a.addr([0x2A, 0x06], "lastc")  # sub al, [lastc]
        a.jshort(0x74, "syncret")  # jz: no new wait
        a.addr([0x88, 0x26], "lastc")  # mov [lastc], ah
        a.b(0x30, 0xE4)  # xor ah, ah
        a.addr([0x01, 0x06], "total")  # add [total], ax
        a.addr([0x8B, 0x3E], "sptr")  # mov di, [sptr]
        a.addr([0x81, 0xFF], "send_v")  # cmp di, send
        a.jshort(0x73, "sfull")  # jae sfull
        a.addr([0xA1], "tick")  # mov ax, [tick]
        a.b(0x89, 0x05)  # mov [di], ax
        a.addr([0xA1], "total")  # mov ax, [total]
        a.b(0x89, 0x45, 0x02)  # mov [di+2], ax
        a.b(0x26, 0xA0, 0xF1, 0x04)  # mov al, es:[4F1h] (place)
        a.b(0x88, 0x45, 0x04)  # mov [di+4], al
        a.b(0x26, 0xA0, 0xF2, 0x04)  # mov al, es:[4F2h] (letter)
        a.b(0x88, 0x45, 0x05)  # mov [di+5], al
        a.b(0x83, 0xC7, 0x06)  # add di, 6
        a.addr([0x89, 0x3E], "sptr")  # mov [sptr], di
        a.b(0xC3)  # ret
        a.label("sfull")
        a.addr([0x80, 0x0E], "flags", [0x01])  # or byte [flags], 1
        a.label("syncret")
        a.b(0xC3)  # ret

        # event: log al (the type), cl (the slot), dx (the key), ch (dropped), with the
        # place, letter, total, tick and video mode. ds = cs; uses ax, bx, di, es (left 0).
        a.label("event")
        a.b(0x31, 0xDB, 0x8E, 0xC3)  # xor bx, bx / mov es, bx
        a.addr([0x8B, 0x3E], "eptr")  # mov di, [eptr]
        a.addr([0x81, 0xFF], "eend_v")  # cmp di, eend
        a.jshort(0x73, "efull")  # jae efull
        a.b(0x88, 0x05)  # mov [di], al
        a.b(0x26, 0xA0, 0xF1, 0x04)  # mov al, es:[4F1h]
        a.b(0x88, 0x45, 0x01)  # mov [di+1], al
        a.b(0x26, 0xA0, 0xF2, 0x04)  # mov al, es:[4F2h]
        a.b(0x88, 0x45, 0x02)  # mov [di+2], al
        a.b(0x88, 0x4D, 0x03)  # mov [di+3], cl
        a.addr([0xA1], "total")  # mov ax, [total]
        a.b(0x89, 0x45, 0x04)  # mov [di+4], ax
        a.b(0x89, 0x55, 0x06)  # mov [di+6], dx
        a.addr([0xA1], "tick")  # mov ax, [tick]
        a.b(0x89, 0x45, 0x08)  # mov [di+8], ax
        a.b(0x26, 0xA0, 0x49, 0x04)  # mov al, es:[449h] (video mode)
        a.b(0x88, 0x45, 0x0A)  # mov [di+10], al
        a.b(0x88, 0x6D, 0x0B)  # mov [di+11], ch
        a.addr([0xA1], "kpsp")  # mov ax, [kpsp]
        a.b(0x89, 0x45, 0x0C)  # mov [di+12], ax
        a.b(0x31, 0xC0)  # xor ax, ax
        a.addr([0xA3], "kpsp")  # mov [kpsp], ax
        a.b(0x83, 0xC7, 0x0E)  # add di, 14
        a.addr([0x89, 0x3E], "eptr")  # mov [eptr], di
        a.b(0xC3)  # ret
        a.label("efull")
        a.addr([0x80, 0x0E], "flags", [0x02])  # or byte [flags], 2
        a.b(0xC3)  # ret

        # The INT 16h hook. A read (AH = 00h or 10h) is passed on as an interrupt, and
        # the key it gives is then logged with the slot it came from. The rest go on
        # unchanged. sti first, so that the flags pushed for the call, and so those the
        # caller gets back, have interrupts on, as the caller had them.
        a.label("kbd")
        a.b(0xFB)  # sti
        a.b(0x80, 0xFC, 0x00)  # cmp ah, 0
        a.jshort(0x74, "kread")
        a.b(0x80, 0xFC, 0x10)  # cmp ah, 10h
        a.jshort(0x74, "kread")
        a.addr([0x2E, 0xFF, 0x2E], "old16")  # jmp far cs:[old16]
        a.label("kread")
        a.b(0x53, 0x06)  # push bx / push es
        a.b(0x31, 0xDB, 0x8E, 0xC3)  # xor bx, bx / mov es, bx
        a.b(0x26, 0x8A, 0x1E, 0x1A, 0x04)  # mov bl, es:[41Ah] (head: the slot read next)
        a.addr([0x2E, 0x88, 0x1E], "kslot")  # mov cs:[kslot], bl
        a.b(0x07, 0x5B)  # pop es / pop bx
        a.b(0x9C)  # pushf
        a.addr([0x2E, 0xFF, 0x1E], "old16")  # call far cs:[old16]
        a.b(0x9C, 0xFA)  # pushf / cli
        a.b(0x50, 0x53, 0x51, 0x52, 0x57, 0x1E, 0x06)  # push ax bx cx dx di ds es
        a.b(0x0E, 0x1F)  # push cs / pop ds
        a.b(0x89, 0xC2)  # mov dx, ax (the key)
        # INT 21h with interrupts off, maybe from inside DOS's own read of the console. That
        # is safe in DOSBox-X, whose DOS is code of the host and gives the PSP at once. It
        # would not be on a real DOS, where INT 21h is not reentrant.
        a.b(0xB4, 0x62, 0xCD, 0x21)  # mov ah, 62h / int 21h (bx = the current PSP)
        a.addr([0x89, 0x1E], "kpsp")  # mov [kpsp], bx
        a.call("sync")
        a.addr([0x8A, 0x0E], "kslot")  # mov cl, [kslot]
        a.b(0xB5, 0x00)  # mov ch, 0
        a.b(0xB0, ord("R"))  # mov al, 'R'
        a.call("event")
        a.b(0x07, 0x1F, 0x5F, 0x5A, 0x59, 0x5B, 0x58)  # pop es ds di dx cx bx ax
        a.b(0x9D)  # popf
        a.b(0xCA, 0x02, 0x00)  # retf 2

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
    a.addr([0xB9], "keymax")  # mov cx, the size of the key area
    a.addr([0xBA], "keys")  # mov dx, keys
    a.b(0xCD, 0x21)
    a.jshort(0x72, "fail")
    a.b(0xB4, 0x3E, 0xCD, 0x21)  # mov ah, 3Eh / int 21h (close)
    a.addr([0xA1], "keys")  # mov ax, [keys] (first delay)
    a.addr([0xA3], "count")  # mov [count], ax
    a.addr([0xC7, 0x06], "ptr")  # mov word [ptr], imm16 ...
    a.addr([], "keys2")  # ... where imm16 is the address of keys + 2
    if trace:
        a.addr([0xC7, 0x06], "sptr")  # mov word [sptr], sstart
        a.addr([], "sstart_v")
        a.addr([0xC7, 0x06], "eptr")  # mov word [eptr], estart
        a.addr([], "estart_v")
        a.b(0x31, 0xC0)  # xor ax, ax
        a.addr([0xA3], "tick")  # mov [tick], ax
        a.addr([0xA3], "total")  # mov [total], ax
        a.addr([0xA2], "flags")  # mov [flags], al
        a.b(0x06, 0x8E, 0xC0)  # push es / mov es, ax
        a.b(0x26, 0xA0, 0xF0, 0x04)  # mov al, es:[4F0h]
        a.b(0x07)  # pop es
        a.addr([0xA2], "lastc")  # mov [lastc], al
        a.addr([0xC6, 0x06], "magic", [ord("P")])  # mov byte [magic], 'P'
        a.b(0xB8, 0x16, 0x35, 0xCD, 0x21)  # mov ax, 3516h / int 21h (es:bx = old INT 16h)
        a.addr([0x89, 0x1E], "old16")  # mov [old16], bx
        a.addr([0x8C, 0x06], "old16b")  # mov [old16+2], es
        a.addr([0xBA], "kbd")  # mov dx, kbd
        a.b(0xB8, 0x16, 0x25, 0xCD, 0x21)  # mov ax, 2516h / int 21h
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


EVENT_SIZE, SAMPLE_SIZE = 14, 6
VALUE_NAMES = ("old2", "keys2", "paras", "keymax", "old16b", "estart_v", "eend_v", "sstart_v", "send_v")


def _assemble(a, values):
    """Two passes: the sizes do not depend on the values, the values depend on the labels."""
    _, labels = a.assemble(dict.fromkeys(VALUE_NAMES, 0))
    extra = values(labels)
    code, labels = a.assemble(extra)
    return code, labels


def resident_end():
    """Where the resident part ends without trace mode: the key area is MAX_KEYFILE bytes."""
    _, labels = build_com().assemble(dict.fromkeys(VALUE_NAMES, 0))
    return labels["keys"] + MAX_KEYFILE


def com_bytes(trace=None):
    """PLAYKEYS.COM. trace is None, or (the key file's length, the number of its ops) for
    trace mode, whose log fills the key area after the key file, up to the same end."""
    end = resident_end()
    if end > 0xFF00:
        raise ValueError("key buffer does not fit in the segment")
    if trace:
        length, nops = trace

        def values(labels):
            keys = labels["keys"]
            estart = keys + (length + 1) // 2 * 2
            eend = estart + EVENT_SIZE * (3 * nops + 64)
            sstart = eend
            send = sstart + (end - sstart) // SAMPLE_SIZE * SAMPLE_SIZE
            if send - sstart < SAMPLE_SIZE * 1000:
                raise ValueError("the key file leaves too little room for the trace log")
            return {"old2": labels["old"] + 2, "keys2": keys + 2, "paras": (end + 15) // 16,
                    "keymax": length, "old16b": labels["old16"] + 2, "estart_v": estart,
                    "eend_v": eend, "sstart_v": sstart, "send_v": send}
        code, _ = _assemble(build_com(trace), values)
    else:
        code, _ = _assemble(build_com(), lambda labels: {
            "old2": labels["old"] + 2, "keys2": labels["keys"] + 2, "paras": (end + 15) // 16,
            "keymax": MAX_KEYFILE})
    return code


def read_trace(memory):
    """The log of a trace-mode run, from the guest's memory (DOSBox-X's memory file).
    Returns (samples, events, info): samples as (tick, total, place, letter), events as
    dicts. The memory holds the magic once, in the resident copy."""
    first_mb = memory[:0x100000]
    at = first_mb.find(b"PKTRACE1")
    if at < 0:
        raise ValueError("no trace log in the memory file")
    if first_mb.find(b"PKTRACE1", at + 1) >= 0:
        raise ValueError("two trace logs in the memory file")
    (self_off, sptr, eptr, tick, total, _lastc, flags, _kslot, _pad,
     estart, _eend, sstart, _send) = struct.unpack_from("<HHHHHBBBBHHHH", first_mb, at + 8)
    base = at - self_off
    samples = [struct.unpack_from("<HHBB", first_mb, base + o) for o in range(sstart, sptr, SAMPLE_SIZE)]
    events = []
    for o in range(estart, eptr, EVENT_SIZE):
        kind, place, letter, slot, tot, word, tk, mode, dropped, psp = struct.unpack_from(
            "<BBBBHHHBBH", first_mb, base + o)
        events.append({"type": chr(kind), "place": place, "letter": letter, "slot": slot, "total": tot,
                       "key": word, "tick": tk, "mode": mode, "dropped": dropped, "psp": psp})
    return samples, events, {"flags": flags, "ticks": tick, "total": total}


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
