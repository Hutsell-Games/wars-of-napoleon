"""Compares a screen state of a QB64 build with a DOSBox-X screenshot (docs/port-study.md,
section 5, "Comparing a DOSBox-X screenshot with a QB64 screen"). tests/play.py uses it for
its bridge and tactical commands.

- A graphics screen (SCREEN 12, 640 x 480, and SCREEN 9, 640 x 350) is compared pixel by
  pixel, after each palette index of the state is turned into its color. In SCREEN 9 an
  8 x 14 cell that differs counts as equal when one character, drawn with each side's own
  glyph, explains it (text_cell_equal): QB64 has no 8 x 14 font of DOS's (QB64Rust's
  DIVERGENCES-QB45.md, Q-023).
- A text screen (SCREEN 0, 80 x 25) is drawn as DOSBox-X saves one, 720 x 400: each cell 9
  pixels wide and 16 high, its glyph from QB64's 8 x 16 font, which is DOSBox-X's pixel for
  pixel (docs/devnotes.md, "The fonts"). The ninth column repeats the eighth for the
  characters C0 to DF, as a VGA does, and is the background for the others. A cell with the
  blink bit may show its character or only its background, as the screenshot caught it.
- A difference that tests/known-differences.txt lists is left out (Known). What is left
  decides whether the shot is equal.

Standard library only.
"""

from __future__ import annotations

import fnmatch
import re
import struct
import zlib
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
KNOWN_FILE = REPO / "tests" / "known-differences.txt"

# A byte of a text row of a state that is not printable ASCII, a backslash or a quote: \xNN.
ESCAPE = re.compile(r"\\x([0-9A-F]{2})")


# ---------------------------------------------------------------------------------- pictures


def read_png(path: Path) -> tuple[int, int, list[bytes]]:
    """(width, height, rows of RGB bytes) of an 8-bit RGB or RGBA PNG, not interlaced."""
    data = path.read_bytes()
    pos, idat, head = 8, b"", None
    while pos < len(data):
        n, tag = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + n]
        if tag == b"IHDR":
            head = struct.unpack(">IIBBBBB", body)
        elif tag == b"IDAT":
            idat += body
        pos += 12 + n
    w, h, depth, ctype, _, _, interlace = head
    if depth != 8 or ctype not in (2, 6) or interlace:
        raise ValueError(f"{path.name}: a PNG of depth {depth}, color type {ctype}, interlace {interlace}")
    bpp = 3 if ctype == 2 else 4
    raw, stride = zlib.decompress(idat), w * bpp
    rows, prev = [], bytes(stride)
    for y in range(h):
        f = raw[y * (stride + 1)]
        line = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        if f == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 255
        elif f == 2:
            line = bytearray((a + b) & 255 for a, b in zip(line, prev))
        elif f == 3:
            for i in range(stride):
                left = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 255
        elif f == 4:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                b, c = prev[i], prev[i - bpp] if i >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        prev = bytes(line)
        rows.append(prev if bpp == 3 else bytes(b for i, b in enumerate(prev) if i % 4 != 3))
    return w, h, rows


def write_png(path: Path, width: int, height: int, rgb_rows: list[bytes]) -> None:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b"".join(b"\0" + row for row in rgb_rows)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
                     + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


# ---------------------------------------------------------------------------------- states


def runs(words: list[str]) -> list[int]:
    """The values of a run-length line of a state: "v" or "v*n", v in hex."""
    out: list[int] = []
    for word in words:
        value, _, count = word.partition("*")
        out += [int(value, 16)] * int(count or 1)
    return out


@dataclass
class Page:
    """The displayed page of a state: a graphics page's pixel rows (palette indexes), or a
    text page's character and attribute rows."""
    text: bool
    width: int
    height: int
    palette: list[int]
    rows: list[list[int]] = field(default_factory=list)  # pixels, or characters
    attrs: list[list[int]] = field(default_factory=list)
    cursor: tuple[int, int] | None = None  # (column, row) from 1, when shown

    def colors(self) -> list[bytes]:
        return [v.to_bytes(4, "big")[1:] for v in self.palette]


def read_page(state: str) -> Page:
    """The displayed page of one state (QB64Rust's tools/screen/README.md, "The state file")."""
    lines = state.replace("\r\n", "\n").split("\n")
    if lines[0] != "screen-state 1":
        raise ValueError(f"not a screen state of version 1: {lines[0]!r}")
    top = lines[1].split()
    display = dict(zip(top[2::2], top[3::2]))["display"]
    page, inside = None, False
    for line in lines[2:]:
        kind, _, rest = line.partition(" ")
        if kind in ("page", "image"):
            words = rest.split()
            inside = kind == "page" and words[0] == display
            if inside:
                at = words.index("mode")
                w, h = (int(v) for v in words[at + 3].split("x"))
                page = Page(text=words[at + 2] == "text", width=w, height=h, palette=[])
                if "cursor" in words:
                    c = words.index("cursor")
                    col, row = (int(v) for v in words[c + 1].split(","))
                    if words[c + 2] == "on":
                        page.cursor = (col, row)
            continue
        if not inside:
            continue
        if kind == "palette":
            page.palette = runs(rest.split())
        elif kind == "p":
            page.rows.append(runs(rest.split()))
        elif kind == "t":
            body = rest[1:-1]
            chars, i = [], 0
            while i < len(body):
                m = ESCAPE.match(body, i)
                if m:
                    chars.append(int(m.group(1), 16))
                    i = m.end()
                else:
                    chars.append(ord(body[i]))
                    i += 1
            page.rows.append(chars)
        elif kind == "a":
            page.attrs.append(runs(rest.split()))
        elif kind == "=":
            page.rows += [page.rows[-1]] * int(rest)
            if page.text:
                page.attrs += [page.attrs[-1]] * int(rest)
    if page is None:
        raise ValueError(f"no record of the displayed page {display}")
    return page


# ---------------------------------------------------------------------------------- known differences


@dataclass
class Known:
    """One line of tests/known-differences.txt."""
    run: str  # a run's name, or a pattern such as "*"
    shot: str  # a shot's name, a pattern, or NAME+ for that shot and every later one
    kind: str  # markers, ships, box, color, any, file
    args: list[str]
    why: str
    line: int

    def applies(self, run: str, shot: str, shots: list[str]) -> bool:
        if not fnmatch.fnmatchcase(run, self.run):
            return False
        if self.shot.endswith("+"):
            first = self.shot[:-1]
            return first in shots and shot in shots and shots.index(shot) >= shots.index(first)
        return fnmatch.fnmatchcase(shot, self.shot)


KINDS = {"markers": 0, "pointer": 0, "ships": 0, "raid": 0, "box": 4, "color": 2, "any": 0, "file": 1}
# The kinds that leave out a fixed set of pixels of the strategic game's map (map_masks).
MAP_KINDS = ("markers", "pointer", "ships", "raid")


def read_known(path: Path = KNOWN_FILE) -> list[Known]:
    """The known differences: one per line, "<run> <shot> <kind> [args] -- <why>". "#" starts a
    comment line. A line that does not fit stops the program with its number."""
    found: list[Known] = []
    if not path.is_file():
        return found
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        what, sep, why = line.partition(" -- ")
        words = what.split()
        if not sep or len(words) < 3 or words[2] not in KINDS or len(words) - 3 != KINDS[words[2]]:
            raise SystemExit(f"{path.name} line {n}: not '<run> <shot> <kind> [args] -- <why>': {line}")
        found.append(Known(words[0], words[1], words[2], words[3:], why.strip(), n))
    return found


def city_centers(repo: Path = REPO) -> set[tuple[int, int]]:
    """The centers of the cities of every scenario's map (EURO<year>.MAP: number, name, x, y, ...)."""
    centers = set()
    for path in repo.glob("scenarios/EURO*.MAP"):
        for line in path.read_text(encoding="latin-1").splitlines():
            parts = line.split(",")
            if len(parts) >= 6:
                try:
                    centers.add((int(parts[2]), int(parts[3])))
                except ValueError:
                    pass
    return centers


# The pixels, from the center, where QB 4.5 and QB64 draw CIRCLE (x, y), 18, c, , , .4 otherwise in
# SCREEN 12: QB 4.5 lights them and QB64 does not (QB64Rust's verification\qb45\q45_circle_pixels,
# the block "radius 18 aspect .4"; Q-036). shipicon (WON2.BM) draws that ellipse twice, in colors 9
# and 10, with PAINT between, so in QB64 these pixels keep the color under the ship.
def mirrored(quadrant: list[tuple[int, int]]) -> list[tuple[int, int]]:
    """The offsets of one quadrant, and their mirrors across both axes."""
    return sorted({(sx * x, sy * y) for sx in (-1, 1) for sy in (-1, 1) for x, y in quadrant})


SHIP_OFFSETS = mirrored([(16, 4), (17, 3), (18, 2)])
# The same for CIRCLE (140, 405), 70, 13, , , .25, the "RAID COMMERCE" mark of a fleet that raids
# (europe, WONMENU.BM; the block "radius 70 aspect .25"): 128 pixels, where the two compilers put
# the flat top and bottom one row apart and step to the next row at other columns.
# The arrow pointer of an army (icon, kind 9, WON1.BM) is drawn from the city at x - 5, y - 6 with
# solid LINEs. Its one edge that is neither flat nor at 45 degrees, LINE -(x - 10, y) from
# (x - 6, y - 2), lights other pixels in QB64 (QB64Rust's DIVERGENCES-QB45.md, Q-025), and PAINT
# then fills one more pixel. These are the three pixels, from the city's center.
POINTER_OFFSETS = [(-12, -8), (-14, -7), (-12, -7)]
RAID_CENTER = (140, 405)
RAID_OFFSETS = mirrored([(x, y) for y in (17, 18) for x in range(9)] + [
    (24, 17), (24, 16), (33, 16), (33, 15), (45, 14), (45, 13), (53, 12), (53, 11), (56, 11), (56, 10),
    (59, 10), (65, 6), (68, 5), (69, 4), (70, 2)])
# Where ships stand on the map: map_ships (WON2.BM) puts the ship of a port at the city plus an
# offset that the port's seventh matrix field chooses (96 to 99), Genoa (city 24) 5 to the left
# and 5 lower, and a ship at sea at 150, 420. shipicon centers the ellipse 10 up and 10 left of it.
PORT_OFFSETS = {96: (50, 10), 97: (-15, 10), 98: (25, -10), 99: (5, 30)}


def ship_centers(repo: Path = REPO) -> set[tuple[int, int]]:
    """The centers of the ships' ellipses at every port of every scenario's map, and at sea."""
    centers = {(140, 410)}
    for path in repo.glob("scenarios/EURO*.MAP"):
        for line in path.read_text(encoding="latin-1").splitlines():
            parts = line.split(",")
            if len(parts) < 13:
                continue
            try:
                number, x, y, port = int(parts[0]), int(parts[2]), int(parts[3]), int(parts[12])
            except ValueError:
                continue
            if port in PORT_OFFSETS:
                dx, dy = PORT_OFFSETS[port]
                x, y = x + dx, y + dy
                if number == 24:
                    x, y = x - 5, y + 5
                centers.add((x - 10, y - 10))
    return centers


def ship_pixels(centers: set[tuple[int, int]]) -> set[tuple[int, int]]:
    return {(x + dx, y + dy) for x, y in centers for dx, dy in SHIP_OFFSETS}


# How far up the map can stand: a PRINT on the last text row of SCREEN 12 scrolls the whole
# screen up one row of 16 pixels, in DOS and in QB64 alike (Utility's Drill screens, session 1).
SCROLLS = (0, 16)


def map_masks(repo: Path = REPO) -> dict[str, set[tuple[int, int]]]:
    """The pixels of the kinds markers, pointer, ships and raid, with the map where it is drawn
    and scrolled up."""
    def shifted(centers):
        return {(x, y - s) for x, y in centers for s in SCROLLS}

    cities = shifted(city_centers(repo))
    return {"markers": marker_pixels(cities),
            "pointer": {(x + dx, y + dy) for x, y in cities for dx, dy in POINTER_OFFSETS},
            "ships": ship_pixels(shifted(ship_centers(repo))),
            "raid": {(x + dx, y + dy) for x, y in shifted({RAID_CENTER}) for dx, dy in RAID_OFFSETS}}


def marker_pixels(centers: set[tuple[int, int]]) -> set[tuple[int, int]]:
    """The pixels where the city markers of QB64 and DOS differ: QB 4.5 lights two pixels side
    by side at each diagonal of a CIRCLE of radius 4, QB64 one (QB64Rust's DIVERGENCES-QB45.md,
    Q-036). cityicon (WON2.BM) draws that circle in color 0 around each city, so the pixel 3 to
    the side and 3 up or down of the center is black in DOS and the map's own color in QB64."""
    return {(x + dx, y + dy) for x, y in centers for dx in (-3, 3) for dy in (-3, 3)}


# ---------------------------------------------------------------------------------- comparing


@dataclass
class Result:
    """What a comparison found. equal: nothing differs, or only what known differences
    explain (used names them, by line). problem: why the shot could not be compared."""
    equal: bool
    summary: str = ""
    used: set[int] = field(default_factory=set)
    problem: str = ""


def compare_shot(state: str, png: Path, run: str, shot: str, shots: list[str], known: list[Known],
                 fonts: dict[str, dict[int, bytes]], diff_png: Path | None = None,
                 masks: dict[str, set[tuple[int, int]]] | None = None) -> Result:
    """Compares one state with the screenshot. fonts: "qb64-14" and "dos-14", QB64's and DOS's
    8 x 14 glyphs (SCREEN 9), and "qb64-16", QB64's 8 x 16 glyphs (SCREEN 0); each a dict of
    character: one byte per row, bit 7 the left pixel. diff_png, when given, gets a picture of a
    shot that differs: the recorded screen dimmed, the pixels that differ in magenta."""
    page = read_page(state)
    rules = [k for k in known if k.kind != "file" and k.applies(run, shot, shots)]
    if any(k.kind == "any" for k in rules):
        return Result(True, "known", {k.line for k in rules if k.kind == "any"})
    w, h, theirs = read_png(png)
    if page.text:
        mine = draw_text(page, fonts.get("qb64-16"), w, h)
        if mine is None:
            return Result(False, problem=f"a text screen of {page.width} x {page.height} against a picture of {w} x {h}")
        cells = text_cells(page, mine, theirs, fonts["qb64-16"])
        cw, ch = 9, 16
    else:
        if (w, h) != (page.width, page.height):
            return Result(False, problem=f"size {page.width}x{page.height}, recorded {w}x{h}")
        colors = page.colors()
        mine = [b"".join(colors[v] for v in row) for row in page.rows]
        cells = pixel_cells(mine, theirs, w)
        if (w, h) == (640, 350) and "qb64-14" in fonts:
            for cell in list(cells):
                if text_cell_equal(mine, theirs, cell, (fonts["qb64-14"], fonts["dos-14"])):
                    del cells[cell]
        cw, ch = 8, 14
    used: set[int] = set()
    for k in rules:
        before = sum(len(p) for p in cells.values())
        leave_out(k, cells, mine, theirs, page, masks or {})
        if sum(len(p) for p in cells.values()) < before:
            used.add(k.line)
    count = sum(len(p) for p in cells.values())
    if not count:
        return Result(True, "known" if used else "", used)
    xs = [x for p in cells.values() for x, _ in p]
    ys = [y for p in cells.values() for _, y in p]
    if diff_png:
        picture = [bytearray(b // 3 for b in row) for row in theirs]
        for x, y in (xy for p in cells.values() for xy in p):
            picture[y][3 * x:3 * x + 3] = b"\xff\x00\xff"
        write_png(diff_png, w, h, [bytes(r) for r in picture])
    what = "cells of text" if page.text else "cells"
    return Result(False, f"{count} pixels in {len(cells)} {what} differ in ({min(xs)},{min(ys)})-({max(xs)},{max(ys)})"
                  + (f", cells ({min(xs) // cw},{min(ys) // ch})-({max(xs) // cw},{max(ys) // ch})" if page.text else ""),
                  used)


def pixel_cells(mine: list[bytes], theirs: list[bytes], w: int) -> dict[tuple[int, int], list[tuple[int, int]]]:
    """The pixels that differ, by 8 x 14 cell."""
    cells: dict[tuple[int, int], list[tuple[int, int]]] = {}
    for y, (a, b) in enumerate(zip(mine, theirs)):
        if a != b:
            for x in range(w):
                if a[3 * x:3 * x + 3] != b[3 * x:3 * x + 3]:
                    cells.setdefault((x // 8, y // 14), []).append((x, y))
    return cells


def leave_out(k: Known, cells: dict, mine: list[bytes], theirs: list[bytes], page: Page,
              masks: dict[str, set[tuple[int, int]]]) -> None:
    """Drops from cells the differing pixels that the known difference k explains."""
    if k.kind in MAP_KINDS:
        # The strategic game's map: SCREEN 12 only.
        mask = masks.get(k.kind)
        if page.text or (page.width, page.height) != (640, 480) or not mask:
            return
        keep = lambda x, y: (x, y) not in mask  # noqa: E731
    elif k.kind == "box":
        x0, y0, x1, y1 = (int(v) for v in k.args)
        keep = lambda x, y: not (x0 <= x <= x1 and y0 <= y <= y1)  # noqa: E731
    elif k.kind == "color":
        a, b = (bytes.fromhex(v) for v in k.args)
        keep = lambda x, y: not (mine[y][3 * x:3 * x + 3] == a and theirs[y][3 * x:3 * x + 3] == b)  # noqa: E731
    else:
        return
    for cell in list(cells):
        rest = [p for p in cells[cell] if keep(*p)]
        if rest:
            cells[cell] = rest
        else:
            del cells[cell]


def text_cell_equal(mine_rows: list[bytes], theirs_rows: list[bytes], cell: tuple[int, int],
                    fonts: tuple[dict[int, bytes], dict[int, bytes]]) -> bool:
    """True when the 8 x 14 cell holds the same character on both sides, each drawn with its
    own font, over the same picture. fonts: (QB64's glyphs, DOS's glyphs), each a dict of
    character: 14 bytes, one per row, bit 7 the left pixel.

    Character c in color fg explains the cell when each row of it is either one color across
    and the same on both sides (a line, a fill, or a blank row of the glyph), or holds the
    row of each glyph in full in fg, with the other fg pixels the same on both sides and no
    pixel outside the two glyphs that differs. So text over a line, and text that a box was
    later drawn over in part, count too. A glyph that misses a stroke does not: the row
    with the stroke is not one color across."""
    qb64_glyphs, dos_glyphs = fonts
    cx, cy = cell
    mine = [[mine_rows[cy * 14 + r][cx * 24 + 3 * i:cx * 24 + 3 * i + 3] for i in range(8)] for r in range(14)]
    theirs = [[theirs_rows[cy * 14 + r][cx * 24 + 3 * i:cx * 24 + 3 * i + 3] for i in range(8)] for r in range(14)]
    # The pixels that differ, as a mask: they must all lie in the two glyphs.
    diff = [sum(128 >> i for i in range(8) if mine[r][i] != theirs[r][i]) for r in range(14)]
    rows = [r for r in range(14) if diff[r] or len(set(mine[r])) > 1]  # the rows to explain
    for fg in {p for row in mine + theirs for p in row}:
        m = [sum(128 >> i for i in range(8) if mine[r][i] == fg) for r in range(14)]
        t = [sum(128 >> i for i in range(8) if theirs[r][i] == fg) for r in range(14)]
        for c, q in qb64_glyphs.items():
            d = dos_glyphs[c]
            if all(q[r] & ~m[r] == 0 and d[r] & ~t[r] == 0 and m[r] & ~q[r] == t[r] & ~d[r]
                   and diff[r] & ~(q[r] | d[r]) == 0 for r in rows):
                return True
    return False


# ---------------------------------------------------------------------------------- text screens

CELL_W, CELL_H = 9, 16


def glyph_pixel(glyph: bytes, char: int, gx: int, gy: int) -> bool:
    """Whether pixel gx (0 to 8), gy (0 to 15) of a 9 x 16 cell is lit for this character."""
    if gx == 8:
        return 0xC0 <= char <= 0xDF and bool(glyph[gy] & 1)
    return bool(glyph[gy] & (128 >> gx))


def draw_text(page: Page, glyphs: dict[int, bytes] | None, w: int, h: int,
              blink_off: bool = False) -> list[bytes] | None:
    """The text page drawn as DOSBox-X saves it: 9 x 16 cells. None when the sizes do not fit.
    blink_off draws each cell with the blink bit as its background only."""
    if glyphs is None or (page.width * CELL_W, page.height * CELL_H) != (w, h):
        return None
    colors = page.colors()
    rows: list[bytes] = []
    for r in range(page.height):
        chars, attrs = page.rows[r], page.attrs[r]
        for gy in range(CELL_H):
            line = bytearray()
            for c in range(page.width):
                ch, at = chars[c], attrs[c]
                fg, bg = colors[at & 15], colors[(at >> 4) & 7]
                if blink_off and at & 128:
                    fg = bg
                g = glyphs[ch]
                for gx in range(CELL_W):
                    line += fg if glyph_pixel(g, ch, gx, gy) else bg
            rows.append(bytes(line))
    return rows


def text_cells(page: Page, mine: list[bytes], theirs: list[bytes],
               glyphs: dict[int, bytes]) -> dict[tuple[int, int], list[tuple[int, int]]]:
    """The pixels that differ, by 9 x 16 cell. A cell with the blink bit is equal when it shows
    its character or only its background. In the cell of a shown cursor, pixels of rows 13 to
    15 are left out: DOSBox-X draws the cursor there in the phase the screenshot caught."""
    off = None
    cells: dict[tuple[int, int], list[tuple[int, int]]] = {}
    w = page.width * CELL_W
    for y, (a, b) in enumerate(zip(mine, theirs)):
        if a == b:
            continue
        for x in range(w):
            if a[3 * x:3 * x + 3] != b[3 * x:3 * x + 3]:
                cells.setdefault((x // CELL_W, y // CELL_H), []).append((x, y))
    for cx, cy in list(cells):
        at = page.attrs[cy][cx]
        if at & 128:
            if off is None:
                off = draw_text(page, glyphs, w, page.height * CELL_H, blink_off=True)
            if all(off[y][3 * x:3 * x + 3] == theirs[y][3 * x:3 * x + 3] for x, y in cells[cx, cy]):
                del cells[cx, cy]
                continue
        if page.cursor and (cx + 1, cy + 1) == page.cursor:
            rest = [(x, y) for x, y in cells[cx, cy] if y % CELL_H < 13]
            if rest:
                cells[cx, cy] = rest
            else:
                del cells[cx, cy]
    return cells
