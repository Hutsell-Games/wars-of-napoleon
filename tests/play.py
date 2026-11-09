"""Play the port's QB64 builds from the announce-driven keys files, and compare them with the
DOSBox-X recordings: "the check" of step 7 of docs/port-study.md. Step 8 adds the port's own
references and the other commands of the earlier ports' play.py.

Usage (from the repo's folder):
    python -I tests/play.py bridge [--compiler rust|pe|both] [--jobs N] [session ...]

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


def build(compiler):
    """won.exe built by the compiler with the screen hook, unless the same sources are built."""
    exe = COMPILERS[compiler]
    if not exe.is_file():
        raise BuildFailed(f"compiler not found: {exe}")
    folder = OUT / "build" / compiler
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / "won.exe"
    h = hashlib.sha256()
    for p in sorted(REPO.iterdir()):
        if p.is_file() and p.suffix.lower() in SOURCES:
            h.update(p.name.encode() + b"\0" + p.read_bytes() + b"\0")
    st = exe.stat()
    h.update(f"{exe}\0{st.st_size}\0{st.st_mtime_ns}\0".encode() + SCREEN_HOOK.read_bytes())
    stamp, stamp_file = h.hexdigest(), folder / "stamp.txt"
    if target.is_file() and stamp_file.is_file() and stamp_file.read_text() == stamp:
        return target
    target.unlink(missing_ok=True)
    print(f"building WON.BAS with {compiler} ...", flush=True)
    log = folder / "build-log.txt"
    with open(log, "wb") as out:
        rc = subprocess.run([str(exe), "-x", str(REPO / "WON.BAS"), "-o", str(target),
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


def compare_shot(state_text, png, diff_png=None):
    """None when the screens are equal, else what differs. With diff_png, a screen that differs
    is written there: the recorded screen dimmed, with the pixels that differ in magenta."""
    places, records = state_to_png.read_state(state_text)
    rec = records[f"page {places['display']}"]
    if rec["text"]:
        return "text"
    w, h, rows = read_png(png)
    if (w, h) != (rec["width"], rec["height"]):
        return f"size {rec['width']}x{rec['height']}, recorded {w}x{h}"
    colors = [v.to_bytes(4, "big")[1:] for v in rec["palette"]]
    count, box, picture = 0, None, []
    for y, (mine, theirs) in enumerate(zip(rec["rows"], rows)):
        line = b"".join(colors[v] for v in mine)
        out = bytearray(b // 3 for b in theirs)
        if line != theirs:
            for x in range(w):
                if line[3 * x:3 * x + 3] != theirs[3 * x:3 * x + 3]:
                    count += 1
                    box = (x, y, x, y) if box is None else (min(box[0], x), box[1], max(box[2], x), y)
                    out[3 * x:3 * x + 3] = b"\xff\x00\xff"
        picture.append(bytes(out))
    if not count:
        return None
    if diff_png:
        diff_png.parent.mkdir(parents=True, exist_ok=True)
        diff_png.write_bytes(state_to_png.png(w, h, picture))
    return f"{count} pixels differ in ({box[0]},{box[1]})-({box[2]},{box[3]})"


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


# ------------------------------------------------------------------------------------ main


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("command", choices=["bridge"])
    ap.add_argument("sessions", nargs="*")
    ap.add_argument("--compiler", choices=["rust", "pe", "both"], default="rust")
    ap.add_argument("--jobs", type=int, default=4)
    args = ap.parse_args()
    if os.name != "nt":
        raise SystemExit("play.py bridge runs on Windows only for now (TODO.md, Linux)")
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
