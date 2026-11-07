"""Compare procedures of BASIC PDS 7.1 code: shared by compare.py and pairprocs.py.

A procedure is turned into a list of instructions. Each instruction gets a
shape: its mnemonic and operands with every number replaced by N, except
that a CALL FAR names its callee ("lcall B$PESD", or "lcall proc" for a
game procedure). Two procedures with equal shapes run the same statements
in the same order; only addresses, constants and variable places may differ.

The exact comparison also needs every byte that is not a fixup to be equal,
and each fixup to mean the same thing: the same runtime routine, the
paired game procedure, or the same place in a data segment.
"""
import difflib
import re
import struct
from dataclasses import dataclass

import capstone

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_16)
md.detail = True  # for the ModR/M byte (disp_shape)
NUM = re.compile(r"(0x[0-9a-f]+|\b\d+\b)")


@dataclass
class Insn:
    addr: int  # offset in the module's code
    size: int
    text: str  # disassembly
    shape: str


def emulated(d, p, end):
    """Decode BC's floating-point emulator call at p, or return None.

    BC writes each 8087 instruction as a software interrupt that the runtime
    emulates or patches: INT 34h..3Bh stand for the opcodes D8h..DFh and are
    followed by the instruction's ModR/M byte and displacement; INT 3Ch has a
    segment override, its next byte is the opcode with the segment in bits 6
    and 7; INT 3Dh is FWAIT. Returns (size, text)."""
    if d[p] != 0xCD or p + 1 >= end:
        return None
    n = d[p + 1]
    if n == 0x3D:
        return 2, "fwait"
    if 0x34 <= n <= 0x3B:
        raw, extra = bytes([0xD8 + n - 0x34]) + d[p + 2 : min(end, p + 8)], 1
    elif n == 0x3C and p + 2 < end:
        raw, extra = bytes([d[p + 2] | 0xC0]) + d[p + 3 : min(end, p + 9)], 2
    else:
        return None
    insn = next(md.disasm(raw, 0), None)
    if insn is None:
        return None
    text = f"{insn.mnemonic} {insn.op_str}".strip()
    if n == 0x3C:
        text = f"(seg {d[p + 2] >> 6}) {text}"
    return insn.size + extra, text


def instructions(view, start, end):
    out = []
    d = view.data
    p = start
    while p < end:
        if p in view.calls:
            callee = view.calls[p]
            shape = "lcall proc" if callee.startswith(("proc:", "addr:")) else f"lcall {callee}"
            out.append(Insn(p, 5, f"call far {callee}", shape))
            p += 5
            continue
        em = emulated(d, p, end)
        if em is not None:
            size, text = em
            out.append(Insn(p, size, "emu " + text, "emu " + NUM.sub("N", text)))
            p += size
            continue
        if d[p] == 0x90:
            # BC pads the start of a loop to an even address with NOP. Whether
            # the NOP is there depends on the size of the code before, so it is
            # left out of the shapes; the exact comparison still sees it.
            p += 1
            continue
        insn = next(md.disasm(d[p : min(end, p + 16)], p), None)
        if insn is None:
            out.append(Insn(p, 1, f"db {d[p]:02x}", "db"))
            p += 1
            continue
        text = f"{insn.mnemonic} {insn.op_str}".strip()
        out.append(Insn(p, insn.size, text, insn.mnemonic + " " + NUM.sub("N", disp_shape(insn))))
        p += insn.size
    return out


MEM_NO_DISP = re.compile(r"\[(\w+)\]")


def disp_shape(insn):
    """The operands of insn, with a 16-bit displacement of 0 written out:
    capstone prints [si + 0] as [si], but in an object file a displacement
    LINK will fill in (a static array in BC_DATA) is 0, and the program has
    the place, [si + 0x1da4]. Both have the same shape."""
    ops = insn.op_str
    if "[" not in ops or not MEM_NO_DISP.search(ops):
        return ops
    if insn.modrm is not None and insn.modrm >> 6 == 2:
        return MEM_NO_DISP.sub(r"[\1 + 0]", ops)
    return ops


def shape_match(a, b):
    """(ratio of instructions in matching runs of 4 or more, index of the first
    differing instruction in a and in b, or None when the shapes are equal)."""
    x = [i.shape for i in a]
    y = [i.shape for i in b]
    if x == y:
        return 1.0, None
    # The exact alignment is quadratic; for long procedures difflib's junk
    # heuristic is much faster and good enough for the percentage shown.
    sm = difflib.SequenceMatcher(None, x, y, autojunk=len(x) + len(y) > 3000)
    same = sum(bl.size for bl in sm.get_matching_blocks() if bl.size >= 4)
    first = next((k for k in range(min(len(x), len(y))) if x[k] != y[k]), min(len(x), len(y)))
    return 2 * same / (len(x) + len(y)) if x or y else 1.0, (first, first)


class Bases:
    """The place of each data segment of an object module (BC_CN, COMMON,
    BC_DATA, ...) in the program's DGROUP, learned from the fixups: the
    program's word minus the object's displacement. The value seen most often
    is taken; a fixup that gives another value points at another place."""

    def __init__(self):
        self.votes = {}
        self.known = {}  # from the module header, which names each segment's place

    def vote(self, seg, delta):
        v = self.votes.setdefault(seg, {})
        v[delta] = v.get(delta, 0) + 1

    def base(self, seg):
        if seg in self.known:
            return self.known[seg]
        v = self.votes.get(seg)
        return max(v, key=v.get) if v else None


HEADER = 0x2E  # BC's module header: the "bl" marker, then the places of the data segments
UNKNOWN_HEADER_WORD = 0x2C  # FFFF from our BC, 0002 in Hutsell's objects; cause not known


def header_bases(obj_view, exe_view, bases):
    """Learn each data segment's place from the module header: each fixed word
    there points at one of the module's data segments."""
    for off, (seg, disp) in obj_view.refs.items():
        if off < HEADER:
            word = struct.unpack_from("<H", exe_view.data, off)[0]
            bases.known[seg] = (word - disp) & 0xFFFF


def header_diff(obj_view, exe_view):
    """Offsets in the module header where unfixed bytes differ, apart from the
    word at UNKNOWN_HEADER_WORD."""
    return [
        k for k in range(HEADER)
        if not obj_view.fixed[k] and k not in (UNKNOWN_HEADER_WORD, UNKNOWN_HEADER_WORD + 1)
        and obj_view.data[k] != exe_view.data[k]
    ]


def collect_bases(obj_view, exe_view, pairs, bases):
    """Vote, over the paired procedures whose shapes are equal, for the place
    of each data segment."""
    for po, pe in pairs:
        a = instructions(obj_view, po.start, po.end)
        b = instructions(exe_view, pe.start, pe.end)
        if [i.shape for i in a] != [i.shape for i in b]:
            continue
        for ia, ib in zip(a, b):
            for off in range(ia.addr, ia.addr + ia.size):
                ref = obj_view.refs.get(off)
                if ref is None:
                    continue
                seg, disp = ref
                word = struct.unpack_from("<H", exe_view.data, ib.addr + (off - ia.addr))[0]
                bases.vote(seg, (word - disp) & 0xFFFF)


def exact_diff(obj_view, exe_view, po, pe, bases, name_of):
    """Return None if the procedure is equal byte for byte (fixups by meaning),
    else (offset in the procedure, a description) of the first difference.
    name_of maps a program procedure label to the object's procedure name."""
    if po.size != pe.size:
        return 0, f"size {po.size} against {pe.size}"
    a, b = obj_view.data, exe_view.data
    k = 0
    while k < po.size:
        p, q = po.start + k, pe.start + k
        if p in obj_view.calls and b[q] == 0x9A:
            ca, cb = obj_view.calls[p], exe_view.calls.get(q, "?")
            if ca.startswith("proc:") and cb.startswith("addr:"):
                pass  # a procedure of a module not being compared: not checked
            elif ca.startswith("proc:") and cb.startswith("proc:"):
                want = name_of.get(cb[5:])
                if want is not None and want.upper() != ca[5:].upper():
                    return k, f"calls {ca[5:]} where the program calls {cb[5:]} ({want})"
            elif ca != cb:
                return k, f"calls {ca} where the program calls {cb}"
            k += 5
            continue
        if p in obj_view.refs:
            seg, disp = obj_view.refs[p]
            word = struct.unpack_from("<H", b, q)[0]
            base = bases.base(seg)
            if base is not None and (word - disp) & 0xFFFF != base:
                return k, f"{seg}+{disp:04x} where the program has {seg}+{(word - base) & 0xFFFF:04x}"
            k += 2
            continue
        if obj_view.fixed[p]:
            k += 1
            continue
        if a[p] != b[q]:
            return k, f"byte {a[p]:02x} where the program has {b[q]:02x}"
        k += 1
    return None
