"""Play the port's QB64 builds from the announce-driven keys files, and compare them with the
DOSBox-X recordings: "the check" of step 7 of docs/port-study.md. Step 8 adds the port's own
references and the other commands of the earlier ports' play.py.

Usage (from the repo's folder):
    python -I tests/play.py bridge [--compiler rust|pe|both] [--jobs N] [session ...]
    python -I tests/play.py tactical [--compiler rust|pe|both] [--jobs N] [battle ...]

tactical plays the battles of tests/battles/ with the tactical game alone (Battle, below).

A session is a keys file of tests/sessions/ (written by tools/play/sessions.py), named by its
file name, its stem, or a pattern such as "14*"; none means all 15. For each session and
compiler the strategic game is built with QB64Rust's screen hook (tools/screen/screen_state.cpp
in the QB64Rust repo, beside this one), played once in a fresh folder of the game's files, and
compared with tests/recorded/<session>/:

- each kept shot: the state that the keys file's "state" step after it wrote, against the
  recorded PNG. A graphics screen is compared pixel by pixel, after the palette index of each
  pixel of the state is turned into its color; the report gives the pixels that differ and the
  box around them. A text screen (SCREEN 0) is not compared yet: DOSBox-X saves it as a
  720 x 400 picture of 9-pixel cells (port-study.md, section 5, dosshot.py of step 8);
- each file the recording's run wrote (tests/recorded/<session>/manifest.txt), byte for byte.

How a run is kept safe on the host (CLAUDE.md of QB64Rust, working rule 6): the window goes on
a desktop of its own that is never shown (press_any_key.py --hidden-desktop). The run's folder
holds no DOS program, so the game's SHELLs of ARCH2.EXE, VIC.EXE and RRS.EXE do not run; under
a script the copy of the history file is done in BASIC (SCRIPT.BM); and WON_OUTCOME is always
set, so that no battle starts NAPOLEON.EXE: a session with a battle gets its recorded
OUTCOME.&&& (D4), the others a name that is not there, which scriptbattle copies as nothing.
The keys file ends at the wait of the last shot, where the game waits for its next key; the
run is stopped once its last state is written.

Exit code: 0 when every run gave the recording, 1 when one differed, 2 when a build failed.
"""
import argparse
import concurrent.futures
import fnmatch
import hashlib
import importlib.util
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import zlib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent


def load(name, path):
    """A module from its file: tools/play/play.py has this file's name, so it is not imported."""
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.path.insert(0, str(Path(path).parent))  # for the modules it imports itself
    spec.loader.exec_module(module)
    return module


# The DOSBox-X harness, for the game's files and the recordings' manifests.
harness = load("harness", REPO / "tools" / "play" / "play.py")

SESSIONS = REPO / "tests" / "sessions"
BATTLES = REPO / "tests" / "battles"
RECORDED = REPO / "tests" / "recorded"
OUT = REPO / "tests" / "out" / "qb64"
QB64RUST = Path(os.environ.get("WON_QB64RUST_REPO") or REPO.parent / "QB64Rust")
COMPILERS = {
    "rust": Path(os.environ.get("QB64RUST") or QB64RUST / "target" / "release" / "qb64rust.exe"),
    "pe": Path(os.environ.get("QB64PE") or QB64RUST.parent / "QB64pe" / "qb64pe.exe"),
}
SCREEN_HOOK = QB64RUST / "tools" / "screen" / "screen_state.cpp"
PRESS_ANY_KEY = QB64RUST / "tools" / "legacy_tests" / "press_any_key.py"
# QB64Rust's reader of screen states (read_state, split_states, png).
state_to_png = load("state_to_png", QB64RUST / "tools" / "screen" / "state_to_png.py")

SOURCES = {".bas", ".bi", ".bm"}
# The name that scriptbattle copies as nothing: no file of the run's folder has it.
NO_OUTCOME = "no-battle.&&&"
TIMEOUT = 900


class BuildFailed(Exception):
    pass


# ------------------------------------------------------------------------------- building


def build(compiler, program="WON.BAS"):
    """The program built by the compiler with the screen hook, unless the same sources are
    built: won.exe from WON.BAS, napoleon.exe from NAPOLEON.BAS."""
    exe = COMPILERS[compiler]
    if not exe.is_file():
        raise BuildFailed(f"compiler not found: {exe}")
    folder = OUT / "build" / compiler / Path(program).stem.lower()
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / (Path(program).stem.lower() + ".exe")
    h = hashlib.sha256()
    for p in sorted(REPO.iterdir()):
        if p.is_file() and p.suffix.lower() in SOURCES:
            h.update(p.name.encode() + b"\0" + p.read_bytes() + b"\0")
    h.update(program.encode() + b"\0" + (REPO / program).read_bytes() + b"\0")
    st = exe.stat()
    h.update(f"{exe}\0{st.st_size}\0{st.st_mtime_ns}\0".encode() + SCREEN_HOOK.read_bytes())
    stamp, stamp_file = h.hexdigest(), folder / "stamp.txt"
    if target.is_file() and stamp_file.is_file() and stamp_file.read_text() == stamp:
        return target
    target.unlink(missing_ok=True)
    print(f"building {program} with {compiler} ...", flush=True)
    log = folder / "build-log.txt"
    with open(log, "wb") as out:
        rc = subprocess.run([str(exe), "-x", str(REPO / program), "-o", str(target),
                             f"-f:ExtraLinkerFlags={SCREEN_HOOK.resolve().as_posix()}"],
                            stdout=out, stderr=subprocess.STDOUT, cwd=REPO).returncode
    if rc != 0 or not target.is_file():
        raise BuildFailed(f"the {compiler} build failed (exit code {rc}); see {log.relative_to(REPO)}")
    stamp_file.write_text(stamp)
    return target


# -------------------------------------------------------------------------------- sessions


class Session:
    def __init__(self, keys):
        self.keys = keys
        self.name = keys.stem
        text = keys.read_text(encoding="ascii")
        self.seed = re.search(r"^# seed (\S+) \(WON_SEED\)", text, re.M).group(1)
        self.battle = "WON_OUTCOME" in text.split("\n\n", 1)[0]
        # The shot of each "state" step, in order: the comment "# shot NAME" before it.
        self.shots, pending = [], None
        for line in text.splitlines():
            m = re.match(r"# shot (\S+?)(:.*)?$", line)
            if m:
                pending = m.group(1)
            elif line == "state":
                self.shots.append(pending)
                pending = None

    def outcome(self):
        if not self.battle:
            return NO_OUTCOME
        return str(RECORDED / self.name / "files" / "OUTCOME.&&&")


def find_sessions(names):
    every = sorted(SESSIONS.glob("*.keys"))
    if not names:
        return [Session(k) for k in every]
    picked = []
    for n in names:
        stem = Path(n).stem
        hits = [k for k in every if fnmatch.fnmatch(k.stem, stem) or k.stem == stem]
        if not hits:
            raise SystemExit(f"no session {n!r} in {SESSIONS.relative_to(REPO)}")
        picked += [k for k in hits if k not in picked]
    return [Session(k) for k in picked]


# ------------------------------------------------------------------------------------ runs


def kill_tree(proc):
    subprocess.run(["taskkill", "/F", "/T", "/PID", str(proc.pid)], capture_output=True)
    proc.wait()


def count_states(path):
    try:
        return path.read_bytes().count(b"\nend\n")
    except OSError:
        return 0


def run(session, compiler, exe):
    """One run of the session; returns (folder, problem or None, seconds)."""
    folder = OUT / "run" / f"{session.name}-{compiler}"
    shutil.rmtree(folder, ignore_errors=True)
    game = folder / "game"
    game.mkdir(parents=True)
    for p in harness.game_files():
        if p.suffix.lower() != ".exe":
            shutil.copy2(p, game / p.name)
    before = {p.name: harness.sha(p) for p in game.iterdir()}
    shutil.copy2(exe, game / "won.exe")
    state = folder / "screen.txt"
    env = dict(os.environ)
    for name in ("WON_TRACE", "NAP_SEED", "NAP_TRACE", "QB64_SCREEN_DIGEST_AS_STATE", "QB64_SCREEN_PROMPT_MS"):
        env.pop(name, None)
    env.update({
        "WON_SEED": session.seed, "WON_OUTCOME": session.outcome(),
        "QB64PE_NOPROMPT": "y", "QB64_SCREEN_KEYS": str(session.keys.resolve()),
        "QB64_SCREEN_STATE": str(state),
    })
    cmd = [sys.executable, "-I", str(PRESS_ANY_KEY), "--hidden-desktop", str(game / "won.exe")]
    want, problem = len(session.shots), None
    start = time.monotonic()
    with open(folder / "log.txt", "wb") as log:
        proc = subprocess.Popen(cmd, cwd=game, env=env, stdout=log, stderr=subprocess.STDOUT,
                                stdin=subprocess.DEVNULL, creationflags=subprocess.CREATE_NO_WINDOW)
        while True:
            if count_states(state) >= want:
                time.sleep(0.5)  # let the files of that moment be closed
                kill_tree(proc)
                break
            if proc.poll() is not None:
                tail = state.read_bytes().rstrip().rsplit(b"\n", 1)[-1] if state.is_file() else b""
                problem = (f"ended with exit code {proc.returncode} after {count_states(state)} of {want} "
                           f"states: {tail.decode(errors='replace')}")
                break
            # A run out of step stops by itself within 30 s: the screen tool ends it when a prompt
            # gets no announcement (exit code 124) or the game announces more waits (125).
            if time.monotonic() - start > TIMEOUT:
                kill_tree(proc)
                problem = f"stopped after {TIMEOUT} s with {count_states(state)} of {want} states"
                break
            time.sleep(0.2)
    files = folder / "files"
    files.mkdir()
    for p in sorted(game.iterdir()):
        if p.name != "won.exe" and before.get(p.name) != harness.sha(p):
            shutil.copy2(p, files / p.name)
    return folder, problem, time.monotonic() - start


# ------------------------------------------------------------------------------- comparing


def read_png(path):
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


def compare_shot(state_text, png, diff_png=None, fonts=None):
    """None when the screens are equal, else what differs. With diff_png, a screen that differs
    is written there: the recorded screen dimmed, with the pixels that differ in magenta.

    fonts, for SCREEN 9 (640 x 350), is (QB64's glyphs, DOS's glyphs): QB64 draws its text with
    other glyphs than DOS (Q-023). An 8 x 14 cell that differs counts as equal when one
    character, drawn with each side's glyph, explains every pixel that differs
    (text_cell_equal)."""
    places, records = state_to_png.read_state(state_text)
    rec = records[f"page {places['display']}"]
    if rec["text"]:
        return "text"
    w, h, rows = read_png(png)
    if (w, h) != (rec["width"], rec["height"]):
        return f"size {rec['width']}x{rec['height']}, recorded {w}x{h}"
    colors = [v.to_bytes(4, "big")[1:] for v in rec["palette"]]
    mine_rows = [b"".join(colors[v] for v in mine) for mine in rec["rows"]]
    cells = {}  # (cell x, cell y): the pixels that differ in it
    for y, (line, theirs) in enumerate(zip(mine_rows, rows)):
        if line != theirs:
            for x in range(w):
                if line[3 * x:3 * x + 3] != theirs[3 * x:3 * x + 3]:
                    cells.setdefault((x // 8, y // 14), []).append((x, y))
    text_equal = 0
    if fonts and (w, h) == (640, 350):
        for cell in list(cells):
            if text_cell_equal(mine_rows, rows, cell, fonts):
                del cells[cell]
                text_equal += 1
    count = sum(len(p) for p in cells.values())
    if not count:
        return None
    xs = [x for p in cells.values() for x, _ in p]
    ys = [y for p in cells.values() for _, y in p]
    if diff_png:
        picture = [bytearray(b // 3 for b in theirs) for theirs in rows]
        for x, y in (xy for p in cells.values() for xy in p):
            picture[y][3 * x:3 * x + 3] = b"\xff\x00\xff"
        diff_png.parent.mkdir(parents=True, exist_ok=True)
        diff_png.write_bytes(state_to_png.png(w, h, [bytes(r) for r in picture]))
    text = f" ({text_equal} cells of text equal by character)" if text_equal else ""
    return f"{count} pixels in {len(cells)} cells differ in ({min(xs)},{min(ys)})-({max(xs)},{max(ys)}){text}"


def text_cell_equal(mine_rows, theirs_rows, cell, fonts):
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


def load_fonts(compiler):
    """(QB64's 8 x 14 glyphs, DOS's): QB64's from tests/font9.bas built by the compiler and run
    once under the screen tool, DOS's from tests/recorded/dosbox-x-font-8x14.bin, which
    tools/play/play.py font writes."""
    dos_file = RECORDED / "dosbox-x-font-8x14.bin"
    if not dos_file.is_file():
        raise BuildFailed(f"no DOS font: run tools/play/play.py font to write {dos_file.relative_to(REPO)}")
    data = dos_file.read_bytes()
    dos = {c: data[14 * c:14 * c + 14] for c in range(256)}
    exe = build(compiler, "tests/font9.bas")
    folder = OUT / "run" / f"font9-{compiler}"
    shutil.rmtree(folder, ignore_errors=True)
    folder.mkdir(parents=True)
    state = folder / "screen.txt"
    env = dict(os.environ, QB64PE_NOPROMPT="y", QB64_SCREEN_STATE=str(state))
    env.pop("QB64_SCREEN_KEYS", None)
    subprocess.run([sys.executable, "-I", str(PRESS_ANY_KEY), "--hidden-desktop", str(exe)], cwd=folder,
                   env=env, stdin=subprocess.DEVNULL, capture_output=True, timeout=120, check=False,
                   creationflags=subprocess.CREATE_NO_WINDOW)
    states = screen_states(folder)
    if not states:
        raise BuildFailed(f"tests/font9.bas wrote no state with {compiler}")
    places, records = state_to_png.read_state(states[-1])
    rec = records[f"page {places['display']}"]
    qb64 = {}
    for c in range(256):
        if c in (7, 9, 10, 11, 12, 13, 28, 29, 30, 31):
            continue  # font9.bas does not print them
        x0, y0 = (c % 32) * 8, (c // 32) * 14
        qb64[c] = bytes(sum(128 >> i for i in range(8) if rec["rows"][y0 + r][x0 + i] != 0) for r in range(14))
    return qb64, dos


def compare(session, folder):
    """The report lines of one run: shots, then files."""
    lines, bad = [], 0
    states = state_to_png.split_states((folder / "screen.txt").read_text(encoding="latin-1")) \
        if (folder / "screen.txt").is_file() else []
    states = [s for s in states if s.startswith("screen-state")]
    text_screens = 0
    for i, shot in enumerate(session.shots):
        if i >= len(states):
            lines.append(f"  {shot}: no state")
            bad += 1
            continue
        recorded = RECORDED / session.name / "shots" / f"{shot}.png"
        if not recorded.is_file():
            lines.append(f"  {shot}: no recorded shot {recorded.relative_to(REPO).as_posix()}")
            bad += 1
            continue
        got = compare_shot(states[i], recorded, folder / "diff" / f"{shot}.png")
        if got == "text":
            text_screens += 1
        elif got:
            lines.append(f"  {shot}: {got}")
            bad += 1
    shots_bad = bad
    manifest_file = RECORDED / session.name / "manifest.txt"
    if not manifest_file.is_file():
        lines.append(f"  no recording: {manifest_file.relative_to(REPO).as_posix()} is missing")
        bad += 1
    manifest = harness.read_manifest(manifest_file) if manifest_file.is_file() else {}
    for key, digest in sorted(manifest.items()):
        if not key.startswith("files/"):
            continue
        name = key[6:]
        if session.battle and name.upper() == "OUTCOME.&&&":
            continue  # given by WON_OUTCOME, not written by the strategic game
        mine = next((p for p in (folder / "files").iterdir() if p.name.lower() == name.lower()), None)
        if mine is None:
            lines.append(f"  file {name}: not written")
            bad += 1
        elif harness.sha(mine) != digest:
            lines.append(f"  file {name}: differs")
            bad += 1
    shots_ok = len(session.shots) - text_screens - shots_bad
    summary = f"{shots_ok} shots equal, {text_screens} text screens not compared"
    return bad, summary, lines


# --------------------------------------------------------------------------------- battles


class Battle:
    """A keys file of tests/battles/, with its BATTLE.$$$ beside it as NAME.battle. The same
    file plays the PDS 7.1 build in DOSBox-X (tools/play/play.py --napoleon, which records
    tests/recorded/<name>/) and the QB64 builds here."""

    def __init__(self, keys):
        self.keys = keys
        self.name = keys.stem
        self.battle = keys.with_suffix(".battle")
        text = keys.read_text(encoding="ascii")
        seed = re.search(r"^# seed (\S+) \(NAP_SEED\)", text, re.M)
        if not seed:
            raise SystemExit(f"{keys.relative_to(REPO)}: no '# seed N (NAP_SEED)' line")
        self.seed = seed.group(1)
        self.shots, pending = [], None
        for line in text.splitlines():
            m = re.match(r"# shot (\S+?)(:.*)?$", line)
            if m:
                pending = m.group(1)
            elif line == "state":
                self.shots.append(pending)
                pending = None


def find_battles(names):
    every = sorted(BATTLES.glob("*.keys"))
    if not names:
        return [Battle(k) for k in every]
    picked = []
    for n in names:
        stem = Path(n).stem
        hits = [k for k in every if fnmatch.fnmatch(k.stem, stem)]
        if not hits:
            raise SystemExit(f"no battle {n!r} in {BATTLES.relative_to(REPO)}")
        picked += [k for k in hits if k not in picked]
    return [Battle(k) for k in picked]


def run_battle(battle, compiler, exe):
    """One run of the tactical game alone; returns (folder, problem or None, seconds). The
    game ends by itself (SYSTEM) once the battle is over; its last state is the one at exit."""
    folder = OUT / "run" / f"{battle.name}-{compiler}"
    shutil.rmtree(folder, ignore_errors=True)
    game = folder / "game"
    game.mkdir(parents=True)
    for p in harness.game_files(("BATTLE.$$$", "OUTCOME.&&&")):
        if p.suffix.lower() != ".exe":
            shutil.copy2(p, game / p.name)
    shutil.copy2(battle.battle, game / "BATTLE.$$$")
    before = {p.name: harness.sha(p) for p in game.iterdir()}
    shutil.copy2(exe, game / "napoleon.exe")
    state = folder / "screen.txt"
    env = dict(os.environ)
    for name in ("WON_SEED", "WON_TRACE", "WON_OUTCOME", "NAP_TRACE", "QB64_SCREEN_DIGEST_AS_STATE",
                 "QB64_SCREEN_PROMPT_MS"):
        env.pop(name, None)
    env.update({"NAP_SEED": battle.seed, "QB64PE_NOPROMPT": "y",
                "QB64_SCREEN_KEYS": str(battle.keys.resolve()), "QB64_SCREEN_STATE": str(state)})
    cmd = [sys.executable, "-I", str(PRESS_ANY_KEY), "--hidden-desktop", str(game / "napoleon.exe")]
    problem, start = None, time.monotonic()
    with open(folder / "log.txt", "wb") as log:
        proc = subprocess.Popen(cmd, cwd=game, env=env, stdout=log, stderr=subprocess.STDOUT,
                                stdin=subprocess.DEVNULL, creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            proc.wait(timeout=TIMEOUT)
        except subprocess.TimeoutExpired:
            kill_tree(proc)
            problem = f"stopped after {TIMEOUT} s"
    tail = state.read_bytes().rstrip().rsplit(b"\n", 1)[-1].decode(errors="replace") if state.is_file() else ""
    if problem is None and tail.startswith("stopped "):
        problem = tail
    elif problem is None and proc.returncode != 0:
        problem = f"ended with exit code {proc.returncode}"
    files = folder / "files"
    files.mkdir()
    for p in sorted(game.iterdir()):
        if p.name != "napoleon.exe" and before.get(p.name) != harness.sha(p):
            shutil.copy2(p, files / p.name)
    return folder, problem, time.monotonic() - start


def screen_states(folder):
    """The states a run wrote, in order: those of the state steps, then the one at exit."""
    path = folder / "screen.txt"
    if not path.is_file():
        return []
    return [s for s in state_to_png.split_states(path.read_text(encoding="latin-1"))
            if s.startswith("screen-state")]


def same_outcome(mine, dos):
    """True when two OUTCOME.&&& texts give the same values. PDS 7.1's WRITE # gives a DOUBLE
    15 digits, QB64's 16 (QB64Rust's DIVERGENCES-QB45.md, Q-021): ".57999998703599" against
    ".5799999870359898". A field counts as equal when its text is, or when QB64's number
    rounded to 15 digits is DOS's."""
    a, b = mine.strip().split(","), dos.strip().split(",")
    if len(a) != len(b):
        return False
    for x, y in zip(a, b):
        if x == y:
            continue
        try:
            # BASIC writes a DOUBLE's exponent with D: 7.99999982118607D-02.
            mine_value, dos_value = float(x.replace("D", "E")), float(y.replace("D", "E"))
            if float(f"{mine_value:.15g}") != dos_value:
                return False
        except ValueError:
            return False
    return True


def compare_battle(battle, folder, fonts):
    """The report lines of one battle: its shots, then its files. The state at exit is not
    compared: the PDS runtime goes back to text mode at SYSTEM. A battle's last shot is at
    scriptend instead (NAPSCRIPT.BM)."""
    lines, bad, text_screens, equal = [], 0, 0, 0
    states = screen_states(folder)
    kept = battle.shots
    for i, shot in enumerate(kept):
        recorded = RECORDED / battle.name / "shots" / f"{i + 1:02d}-{shot}.png"
        if i >= len(states):
            lines.append(f"  {shot}: no state")
            bad += 1
        elif not recorded.is_file():
            lines.append(f"  {shot}: no recorded shot {recorded.relative_to(REPO).as_posix()}")
            bad += 1
        else:
            got = compare_shot(states[i], recorded, folder / "diff" / f"{shot}.png", fonts)
            if got == "text":
                text_screens += 1
            elif got:
                lines.append(f"  {shot}: {got}")
                bad += 1
            else:
                equal += 1
    manifest_file = RECORDED / battle.name / "manifest.txt"
    manifest = harness.read_manifest(manifest_file) if manifest_file.is_file() else {}
    if not manifest:
        lines.append(f"  no recording: {manifest_file.relative_to(REPO).as_posix()} is missing")
        bad += 1
    written = {p.name.lower(): p for p in (folder / "files").iterdir()}
    for key, digest in sorted(manifest.items()):
        if key.startswith("files/"):
            mine = written.pop(key[6:].lower(), None)
            if mine is None:
                lines.append(f"  file {key[6:]}: not written")
                bad += 1
            elif harness.sha(mine) != digest:
                dos = RECORDED / battle.name / "files" / key[6:]
                if key[6:].upper() == "OUTCOME.&&&" and dos.is_file() and same_outcome(
                        mine.read_text(encoding="ascii"), dos.read_text(encoding="ascii")):
                    continue
                lines.append(f"  file {key[6:]}: differs: {mine.read_bytes()!r}")
                bad += 1
    for name in sorted(written):
        lines.append(f"  file {name}: written, and not by DOS")
        bad += 1
    summary = f"{equal} of {len(kept)} shots equal"
    if text_screens:
        summary += f", {text_screens} text screens not compared"
    return bad, summary, lines


def tactical(args):
    """The command tactical: each battle with each compiler, held to its DOS recording, and
    with both compilers, the two runs' states held to each other."""
    battles = find_battles(args.sessions)
    compilers = ["rust", "pe"] if args.compiler == "both" else [args.compiler]
    try:
        exes = {c: build(c, "NAPOLEON.BAS") for c in compilers}
        fonts = {c: load_fonts(c) for c in compilers}
    except BuildFailed as e:
        print(f"play.py: {e}")
        return 2
    work = [(b, c) for c in compilers for b in battles]

    def one(item):
        b, c = item
        folder, problem, seconds = run_battle(b, c, exes[c])
        bad, summary, lines = compare_battle(b, folder, fonts[c])
        return b, c, folder, problem, seconds, bad, summary, lines

    failed, folders = 0, {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for b, c, folder, problem, seconds, bad, summary, lines in pool.map(one, work):
            folders[b.name, c] = folder
            ok = not problem and not bad
            failed += not ok
            print(f"{'PASS' if ok else 'FAIL'} {b.name} [{c}] {seconds:.0f} s: {summary}"
                  + (f"; {problem}" if problem else ""), flush=True)
            for line in lines:
                print(line)
    if len(compilers) == 2:
        for b in battles:
            one_, two = (screen_states(folders[b.name, c]) for c in compilers)
            same = one_ == two and one_
            failed += not same
            print(f"{'SAME' if same else 'DIFFERENT'} {b.name}: rust and pe, {len(one_)} and {len(two)} states")
    print(f"{len(work) - failed} passed, {failed} failed" if len(compilers) == 1 else f"{failed} failed")
    return 1 if failed else 0


# ------------------------------------------------------------------------------------ main


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("command", choices=["bridge", "tactical"])
    ap.add_argument("sessions", nargs="*", help="sessions (bridge) or battles (tactical); none means all")
    ap.add_argument("--compiler", choices=["rust", "pe", "both"], default="rust")
    ap.add_argument("--jobs", type=int, default=4)
    args = ap.parse_intermixed_args()
    if os.name != "nt":
        raise SystemExit("play.py runs on Windows only for now (TODO.md, Linux)")
    if args.command == "tactical":
        return tactical(args)
    sessions = find_sessions(args.sessions)
    compilers = ["rust", "pe"] if args.compiler == "both" else [args.compiler]
    try:
        exes = {c: build(c) for c in compilers}
    except BuildFailed as e:
        print(f"play.py: {e}")
        return 2
    work = [(s, c) for c in compilers for s in sessions]

    def one(item):
        s, c = item
        folder, problem, seconds = run(s, c, exes[c])
        bad, summary, lines = compare(s, folder)
        return s, c, problem, seconds, bad, summary, lines

    failed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for s, c, problem, seconds, bad, summary, lines in pool.map(one, work):
            ok = not problem and not bad
            failed += not ok
            print(f"{'PASS' if ok else 'FAIL'} {s.name} [{c}] {seconds:.0f} s: {summary}"
                  + (f"; {problem}" if problem else ""), flush=True)
            for line in lines:
                print(line)
    print(f"{len(work) - failed} passed, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
