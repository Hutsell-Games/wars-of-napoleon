"""The play harness: play WON.EXE by script in a hidden DOSBox-X, with a fixed
random seed, and record or check its screens and the files it writes.

Usage (from the repo's folder):
    python -I tools/play/play.py run SCRIPT.keys...      # one run each; screenshots in tests/out/<name>/
    python -I tools/play/play.py record SCRIPT.keys...   # two runs that must agree; kept in tests/recorded/<name>/
    python -I tools/play/play.py check SCRIPT.keys...    # one run, compared with tests/recorded/<name>/
Options: --exe WON.EXE (another build to play; default the repo's WON.EXE),
         --timr HEX --rnzp HEX (its runtime addresses, for a build other than the shipped one),
         --dosbox PATH (default ../won-hutsellgames/dosbox-x/bin/x64/Release/dosbox-x.exe).

How a run works:
- A fresh folder gets the game's files from the repo's folder, WONSEED.EXE (WON.EXE with
  RANDOMIZE TIMER replaced by RANDOMIZE <seed>, wonseed.py), PLAYKEYS.COM and the key
  file KEYS.BIN (playkeys.py).
- DOSBox-X runs hidden: "-silent" and SDL's dummy video driver, so no window opens. The
  configuration sets fixed CPU cycles, turbo (as fast as the host can), no time
  synchronization with the host, the integration device for screenshots, and no network
  or debugger port. The autoexec sets the date and time, loads PLAYKEYS.COM and starts
  WONSEED.EXE. Every program the game starts (NAPOLEON.EXE, VIC.EXE, ARCH2.EXE, COPY) is
  a DOS program inside DOSBox-X, so no console window opens on the host.
- PLAYKEYS.COM types the keys and takes the screenshots at fixed points of emulated time.
  In the tick of the last screenshot it stops the emulated machine, so the files the game
  wrote are the same in every run. The harness stops DOSBox-X once that screenshot is written.

Script format (SCRIPT.keys), one command per line, "#" starts a comment:
    seed N          the RANDOMIZE value (default 1)
    cycles N        fixed CPU cycles (default 20000)
    pace S          seconds of emulated time before each key or shot (default 0.5)
    wait S          extra seconds before the next key or shot
    key NAME...     keys by name: enter esc space tab bksp up down left right home end
                    pgup pgdn ins del f1-f12, a letter or digit, or a punctuation name
                    (comma period slash semicolon quote minus equals lbracket rbracket
                    backslash grave), or shift-<name> for its shifted character
    type TEXT       the characters of TEXT (the rest of the line), each a key
    shot NAME       a screenshot, saved as NN-NAME.png
    repeat N        the lines up to the matching "end", N times (blocks may nest)
A script must end with a shot, with no wait after it: the machine stops at the last shot.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import playkeys  # noqa: E402
import wonseed  # noqa: E402

REPO = HERE.parent.parent
DEFAULT_DOSBOX = REPO.parent / "won-hutsellgames" / "dosbox-x" / "bin" / "x64" / "Release" / "dosbox-x.exe"
OUT = REPO / "tests" / "out"
RECORDED = REPO / "tests" / "recorded"
# The date of the shipped WON.EXE. DOSBox-X's DATE takes MM/DD/YYYY; with dashes it
# silently keeps the host's date, so each run checks the date it got (RUNDATE.TXT).
DATE, TIME = "06/24/1998", "12:00:00"

# Files of the repo's folder that are not the game's: sources, documents, build files.
NOT_GAME = {".bas", ".bi", ".bm", ".doc", ".txt", ".pag", ".md", ".lnk", ".py", ".gitattributes", ".gitignore"}
NOT_GAME_NAMES = {"license"}
HARNESS_FILES = {"WONSEED.EXE", "PLAYKEYS.COM", "KEYS.BIN", "IDLE.COM", "RUNDATE.TXT"}
# The DOS programs with no source, which left the branch qb64rust in its step 5, and the
# commit that still has them. --port takes them from there.
SHIPPED_COMMIT = "7738434"
SHIPPED_ONLY = ("ARCH2.EXE", "VIC.EXE", "NAPIC.EXE")
# What --port takes from that commit: those three, and the tactical game. The branch still
# tracks the shipped NAPOLEON.EXE, but a QB64 build of the port in the repo's folder
# overwrites it with a Windows program, which DOSBox-X cannot run.
FROM_GIT = SHIPPED_ONLY + ("NAPOLEON.EXE",)

# Key names: (scan code, character, shifted character).
LETTERS = dict(zip("qwertyuiop", range(0x10, 0x1A)))
LETTERS.update(zip("asdfghjkl", range(0x1E, 0x27)))
LETTERS.update(zip("zxcvbnm", range(0x2C, 0x33)))
KEYS = {c: (s, ord(c), ord(c.upper())) for c, s in LETTERS.items()}
KEYS.update({d: (s, ord(d), ord(sh)) for d, s, sh in zip("1234567890", range(0x02, 0x0C), "!@#$%^&*()")})
for name, scan, ch, sh in [
    ("minus", 0x0C, "-", "_"), ("equals", 0x0D, "=", "+"), ("lbracket", 0x1A, "[", "{"),
    ("rbracket", 0x1B, "]", "}"), ("semicolon", 0x27, ";", ":"), ("quote", 0x28, "'", '"'),
    ("grave", 0x29, "`", "~"), ("backslash", 0x2B, "\\", "|"), ("comma", 0x33, ",", "<"),
    ("period", 0x34, ".", ">"), ("slash", 0x35, "/", "?"), ("space", 0x39, " ", " "),
]:
    KEYS[name] = (scan, ord(ch), ord(sh))
KEYS.update({"enter": (0x1C, 13, 13), "esc": (0x01, 27, 27), "tab": (0x0F, 9, 0), "bksp": (0x0E, 8, 8)})
for name, scan in [("up", 0x48), ("down", 0x50), ("left", 0x4B), ("right", 0x4D), ("home", 0x47),
                   ("end", 0x4F), ("pgup", 0x49), ("pgdn", 0x51), ("ins", 0x52), ("del", 0x53)]:
    KEYS[name] = (scan, 0, 0)
for n in range(1, 11):
    KEYS[f"f{n}"] = (0x3A + n, 0, 0)
KEYS["f11"], KEYS["f12"] = (0x85, 0, 0), (0x86, 0, 0)
CHARS = {}
for name, (scan, ch, sh) in KEYS.items():
    if ch >= 32:
        CHARS.setdefault(chr(ch), scan * 256 + ch)
    if sh >= 32:
        CHARS.setdefault(chr(sh), scan * 256 + sh)


def key_word(name):
    shifted = name.startswith("shift-")
    base = name[6:] if shifted else name
    if base not in KEYS:
        raise ValueError(f"unknown key {name!r}")
    scan, ch, sh = KEYS[base]
    return scan * 256 + (sh if shifted else ch)


class Script:
    def __init__(self, path):
        self.path = Path(path)
        self.name = self.path.stem
        self.seed, self.cycles = 1.0, 20000
        self.ops = []  # (op, word, gap_seconds_before)
        self.shots = []
        pace, extra = 0.5, 0.0
        for number, text in self._lines():
            cmd, _, rest = text.partition(" ")
            try:
                if cmd == "seed":
                    self.seed = float(rest)
                elif cmd == "cycles":
                    self.cycles = int(rest)
                elif cmd == "pace":
                    pace = float(rest)
                elif cmd == "wait":
                    extra += float(rest)
                elif cmd == "key":
                    for k in rest.split():
                        self.ops.append((1, key_word(k), pace + extra))
                        extra = 0.0
                elif cmd == "type":
                    for c in rest:
                        if c not in CHARS:
                            raise ValueError(f"no key types {c!r}")
                        self.ops.append((1, CHARS[c], pace + extra))
                        extra = 0.0
                elif cmd == "shot":
                    if not rest or any(not (c.isalnum() or c in "-_") for c in rest):
                        raise ValueError("a shot needs a name of letters, digits, - and _")
                    self.ops.append((2, None, pace + extra))
                    self.shots.append(f"{len(self.shots) + 1:02d}-{rest}")
                    extra = 0.0
                else:
                    raise ValueError(f"unknown command {cmd!r}")
            except ValueError as e:
                raise SystemExit(f"{self.path}:{number}: {e}") from None
        if not self.shots:
            raise SystemExit(f"{self.path}: no shot")
        if self.ops[-1][0] != 2:
            # The machine stops at the last shot (playkeys.py), so later keys would never be typed.
            raise SystemExit(f"{self.path}: the script must end with a shot")
        if extra:
            raise SystemExit(f"{self.path}: a wait after the last shot does nothing; the machine stops at the shot")

    def _lines(self):
        """The script's commands as (line number, text), comments dropped and repeat blocks unrolled."""
        stack = [[]]  # each level: list of (number, text) or ("repeat", count, body)
        counts = []
        for number, line in enumerate(self.path.read_text(encoding="utf-8").splitlines(), 1):
            text = line.strip() if line.lstrip().startswith("type ") else line.split("#", 1)[0].strip()
            if not text:
                continue
            cmd, _, rest = text.partition(" ")
            if cmd == "repeat":
                if not rest.strip().isdigit():
                    raise SystemExit(f"{self.path}:{number}: repeat needs a count")
                counts.append(int(rest))
                stack.append([])
            elif cmd == "end":
                if len(stack) == 1:
                    raise SystemExit(f"{self.path}:{number}: end without repeat")
                body = stack.pop()
                stack[-1].extend(body * counts.pop())
            else:
                stack[-1].append((number, text))
        if len(stack) != 1:
            raise SystemExit(f"{self.path}: repeat without end")
        return stack[0]

    def keyfile(self):
        ticks = [round(gap * playkeys.TICKS_PER_SECOND) for _, _, gap in self.ops]
        # After the last shot the delay is 0: the machine stops in the same tick, so the files
        # the harness keeps are those of that moment, whatever the host does next.
        ops = [(op, word, ticks[i + 1] if i + 1 < len(ticks) else 0) for i, (op, word, _) in enumerate(self.ops)]
        try:
            return playkeys.keyfile(ops, ticks[0])
        except ValueError as e:
            raise SystemExit(f"{self.path}: {e}") from None

    def seconds(self):
        return sum(gap for _, _, gap in self.ops)


def game_files(replaced=()):
    """The game's files: the files git tracks in the repo's top folder, without sources and documents.
    Untracked files (a save left by playing the game in the repo's folder) are not copied: they
    would change the game's menus, and so every screen of a recording. The files named in
    replaced are left out: the run writes them itself."""
    def git(*cmd):
        try:
            return subprocess.run(["git", "-C", str(REPO), *cmd], capture_output=True, text=True,
                                  check=True).stdout.splitlines()
        except (OSError, subprocess.CalledProcessError) as e:
            raise SystemExit(f"the harness needs git to list the game's files: {e}") from None
    names = [n for n in git("ls-files") if "/" not in n]
    changed = {line[3:] for line in git("status", "--porcelain", "--", *names)}
    for name in sorted(names):
        p = REPO / name
        if p.suffix.lower() in NOT_GAME or name.lower() in NOT_GAME_NAMES or name.startswith("."):
            continue
        if name in replaced:
            continue
        if not p.exists():
            raise SystemExit(f"missing: {name} is tracked by git but not in the repo's folder")
        if name in changed:
            print(f"  warning: {name} has local changes; the run uses them")
        yield p


def git_show(commit, name):
    try:
        return subprocess.run(["git", "-C", str(REPO), "show", f"{commit}:{name}"], capture_output=True,
                              check=True).stdout
    except (OSError, subprocess.CalledProcessError) as e:
        raise SystemExit(f"cannot take {name} from git {commit}: {e}") from None


def seed_text(seed):
    """The seed as WON_SEED gives it to VAL: 1.0 is "1", the same DOUBLE as wonseed.py's RANDOMIZE 1#."""
    return str(int(seed)) if seed == int(seed) else repr(seed)


def dosbox_version(dosbox):
    """The version, and the SHA-256 of the program: another build may draw other PNG bytes."""
    changelog = Path(dosbox).parent / "CHANGELOG.txt"
    first = changelog.read_text(errors="replace").splitlines()[0].rstrip(":") if changelog.exists() else "?"
    return f"DOSBox-X {first}, dosbox-x.exe SHA-256 {sha(dosbox)[:16]}"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(script, out, args):
    """Play the script once into the folder out; return {shot or file name: SHA-256}."""
    out.mkdir(parents=True, exist_ok=True)
    for old in out.iterdir():  # empty it; the folder itself may be a shell's working folder
        shutil.rmtree(old) if old.is_dir() else old.unlink()
    game, cap = out / "game", out / "capture"
    game.mkdir(parents=True)
    cap.mkdir()
    for p in game_files(("WON.EXE",) + FROM_GIT if args.port else ()):
        shutil.copy2(p, game / p.name)
    if args.port:
        # A PDS 7.1 build of the port (tools/pdsbuild.py) seeds itself from WON_SEED, so it
        # is not patched. The DOS programs come from git, so that it runs them as the
        # recordings did (docs/port-study.md, step 7a).
        (game / "WON.EXE").write_bytes(Path(args.port).read_bytes())
        for name in FROM_GIT:
            (game / name).write_bytes(git_show(SHIPPED_COMMIT, name))
        program = "WON.EXE"
    else:
        exe = wonseed.unpacked(Path(args.exe).read_bytes())
        if hashlib.sha256(exe).hexdigest() != wonseed.SHIPPED_UNPACKED_SHA256 and args.timr is None:
            raise SystemExit("--exe is not the shipped WON.EXE: pass --timr and --rnzp")
        seeded, _, _ = wonseed.patch(exe, args.timr or wonseed.B_TIMR, args.rnzp or wonseed.B_RNZP, script.seed)
        (game / "WONSEED.EXE").write_bytes(seeded)
        program = "WONSEED.EXE"
    keys = script.keyfile()
    # With --port, PLAYKEYS.COM runs in trace mode and logs the waits the port announces,
    # the keys it reads and the shots (playkeys.py). DOSBox-X maps the guest's memory to
    # MEMORY.BIN, where the harness reads the log after the run.
    trace = (len(keys), len(script.ops)) if args.port else None
    (game / "PLAYKEYS.COM").write_bytes(playkeys.com_bytes(trace))
    (game / "KEYS.BIN").write_bytes(keys)
    (game / "IDLE.COM").write_bytes(bytes([0xFB, 0xF4, 0xEB, 0xFD]))  # sti / hlt / jmp hlt
    before = {p.name: sha(p) for p in game.iterdir()}

    log = out / "dosbox.log"
    conf = out / "run.conf"
    conf.write_text("\n".join([
        "[sdl]", "output=surface", "",
        "[log]", f"logfile={log}", "",
        "[dosbox]", "mcp_server=0", f"captures={cap}", "synchronize time=false",
        *([f"memory file={out / 'MEMORY.BIN'}"] if trace else []), "",
        "[cpu]", "core=normal", "cputype=pentium", f"cycles=fixed {script.cycles}", "turbo=true",
        "stop turbo on key=false", "stop turbo after second=0", "integration device=true", "",
        "[serial]", "serial1=disabled", "serial2=disabled", "",
        "[ipx]", "ipx=false", "", "[ne2000]", "ne2000=false", "",
        "[autoexec]",
        f'mount c "{game}"', "c:", f"date {DATE}", f"time {TIME}", "date /t > RUNDATE.TXT",
        # After the game quits, IDLE.COM waits forever without printing, so a last shot shows
        # what the game left on the screen (-silent would end DOSBox-X with the autoexec).
        # The harness stops DOSBox-X after the last shot.
        # The port's hooks read their variables (SCRIPT.BM). PDS 7.1's ENVIRON cannot add one
        # in DOS, so the autoexec sets them before the game starts (docs/devnotes.md, step 6).
        *([f"set WON_SEED={seed_text(script.seed)}", "set WON_TRACE=1"] if args.port else []),
        "PLAYKEYS.COM KEYS.BIN", program, "IDLE.COM", "",
    ]), encoding="ascii")
    env = dict(os.environ, SDL_VIDEODRIVER="dummy", SDL_AUDIODRIVER="dummy")
    limit = 120 + 3 * script.seconds()
    start = time.monotonic()
    proc = subprocess.Popen([str(args.dosbox), "-silent", "-conf", str(conf), "-noconsole",
                             "-nopromptfolder"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    shots = []
    try:
        while True:
            if log.exists():
                shots = [l.split("Capturing Screenshot to ", 1)[1].strip()
                         for l in log.read_text(errors="replace").splitlines() if "Capturing Screenshot to" in l]
            if len(shots) >= len(script.shots) or proc.poll() is not None:
                break
            if time.monotonic() - start > limit:
                print(f"  {script.name}: stopped after {limit:.0f} s with {len(shots)} of {len(script.shots)} shots")
                break
            time.sleep(0.2)
        time.sleep(1.0)  # let the last PNG and the game's files be written
    finally:
        if proc.poll() is None:
            proc.kill()
            proc.wait()
    elapsed = time.monotonic() - start
    rundate = game / "RUNDATE.TXT"
    got = rundate.read_text(errors="replace").strip() if rundate.exists() else "nothing"
    if got != DATE:
        raise SystemExit(f"  {script.name}: DOS date is {got!r}, not {DATE}; the run is not repeatable")

    if trace:
        write_trace(out, script)

    result = {}
    (out / "shots").mkdir()
    for name, src in zip(script.shots, shots):
        dest = out / "shots" / f"{name}.png"
        shutil.copy2(src, dest)
        result[f"shots/{name}.png"] = sha(dest)
    (out / "files").mkdir()
    for p in sorted(game.iterdir()):
        if p.name in HARNESS_FILES or before.get(p.name) == sha(p):
            continue
        shutil.copy2(p, out / "files" / p.name)
        result[f"files/{p.name}"] = sha(p)
    print(f"  {script.name}: {len(shots)} of {len(script.shots)} shots, "
          f"{sum(1 for k in result if k.startswith('files/'))} files written, {elapsed:.0f} s")
    return result


class RunFailed(Exception):
    """A run that gave no result; the next script still runs."""


def write_trace(out, script):
    """The trace log of the run, from DOSBox-X's memory file, into out/trace.json."""
    memory = out / "MEMORY.BIN"
    try:
        samples, events, info = playkeys.read_trace(memory.read_bytes())
    except (OSError, ValueError) as e:
        raise RunFailed(f"{script.name}: no trace log: {e}") from None
    memory.unlink()  # 16 MB, and nothing else in it is needed
    if info["flags"]:
        print(f"  warning: the trace log was full (flags {info['flags']}); it misses the end of the run")
    (out / "trace.json").write_text(json.dumps({
        "script": script.name, "shots": script.shots, "info": info,
        "samples": [list(s) for s in samples], "events": events}, indent=0), encoding="ascii")
    reads = sum(1 for e in events if e["type"] == "R")
    print(f"  trace: {len(samples)} samples, {info['total']} waits announced, {reads} keys read")


def manifest_text(script, result, args):
    lines = [f"# {script.name}: recorded by tools/play/play.py",
             f"# {dosbox_version(args.dosbox)}, seed {script.seed!r}, cycles fixed {script.cycles}",
             f"# script SHA-256 {sha(script.path)}"]
    lines += [f"{h}  {k}" for k, h in sorted(result.items())]
    return "\n".join(lines) + "\n"


def read_manifest(path):
    result = {}
    for line in Path(path).read_text().splitlines():
        if line and not line.startswith("#"):
            h, k = line.split("  ", 1)
            result[k] = h
    return result


def diff(a, b):
    return sorted(k for k in set(a) | set(b) if a.get(k) != b.get(k))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["run", "record", "check"])
    ap.add_argument("scripts", nargs="+")
    ap.add_argument("--exe", default=str(REPO / "WON.EXE"))
    ap.add_argument("--timr", type=lambda s: int(s, 16))
    ap.add_argument("--rnzp", type=lambda s: int(s, 16))
    ap.add_argument("--dosbox", default=str(DEFAULT_DOSBOX))
    ap.add_argument("--port", help="a PDS 7.1 build of the port (tools/pdsbuild.py), played in trace mode")
    args = ap.parse_args()
    if args.port and (args.timr is not None or args.exe != str(REPO / "WON.EXE")):
        raise SystemExit("--port plays the port's own build: it takes no --exe, --timr or --rnzp")
    if (args.timr is None) != (args.rnzp is None):
        raise SystemExit("--timr and --rnzp go together: both from the build's runtime map")
    if not Path(args.dosbox).exists():
        raise SystemExit(f"no DOSBox-X at {args.dosbox}")
    failed = 0
    for s in args.scripts:
        script = Script(s)
        print(f"{args.command} {script.name} ({script.seconds():.0f} s of play, {len(script.shots)} shots)")
        try:
            ok = play_one(script, args)
        except RunFailed as e:
            print(f"  FAILED: {e}")
            ok = False
        failed += 0 if ok else 1
    sys.exit(1 if failed else 0)


def play_one(script, args):
    """Run, record or check one script; True when it went as it should."""
    if args.command == "run":
        run(script, OUT / script.name, args)
        return True
    if args.command == "record":
        first = run(script, OUT / script.name / "record-1", args)
        second = run(script, OUT / script.name / "record-2", args)
        if len([k for k in first if k.startswith("shots/")]) != len(script.shots):
            print("  NOT RECORDED: missing shots")
            return False
        if diff(first, second):
            print(f"  NOT RECORDED: the two runs differ in {diff(first, second)}")
            return False
        dest = RECORDED / script.name
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(OUT / script.name / "record-1" / "shots", dest / "shots")
        shutil.copytree(OUT / script.name / "record-1" / "files", dest / "files")
        (dest / "manifest.txt").write_text(manifest_text(script, first, args))
        print(f"  recorded in {dest.relative_to(REPO)}")
        return True
    manifest = RECORDED / script.name / "manifest.txt"
    if not manifest.exists():
        print(f"  NO RECORDING: {manifest.relative_to(REPO)} does not exist; run record first")
        return False
    expected = read_manifest(manifest)
    got = run(script, OUT / script.name / "check", args)
    bad = diff(expected, got)
    if bad:
        print(f"  DIFFERS: {', '.join(bad)}")
        return False
    print("  same as recorded")
    return True


if __name__ == "__main__":
    main()
