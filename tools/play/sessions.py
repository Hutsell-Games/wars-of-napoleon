"""Turn the trace of a timed session into an announce-driven keys file for the port.

Usage (from the repo's folder), after "play.py check --port WON.EXE SCRIPT.keys...":
    python -I tools/play/sessions.py SCRIPT.keys...      # writes tests/sessions/<name>.keys
    python -I tools/play/sessions.py --check SCRIPT.keys # only says whether the file would change

This is step 7a of docs/port-study.md. A timed script (tests/scripts/) types each key at a
fixed tick. The QB64 builds of the port take keys from QB64Rust's screen tool instead, which
gives a key only when the program announces a wait (SCRIPT.BM, announce). The trace run of
the PDS 7.1 build logs, for each key, the wait that read it (playkeys.py, trace mode). From
that log this writes a keys file in the screen tool's format (QB64Rust's
tools/screen/README.md, "The keys file"):

- first a "prompt" for the built-in title's TICK 2. The recordings ran ARCH2.EXE instead, whose
  picture took the first key; the port runs no DOS program (D6);
- one "prompt" for each wait the strategic game announced, in order, up to the last shot;
- after it, the keys that the wait read in DOS;
- a wait that read no key in DOS gets "key f12", the filler. Under a script every TICK waits
  for a key and throws it away (D2 of the plan), also the pauses that ran out in DOS. The game
  reads F12 nowhere else, and scripttick (SCRIPT.BM) takes it back out of the BIOS buffer, so
  that the four PEEK(1052) = 30 checks of naval combat see the buffer as DOS left it
  (docs/devnotes.md, "Step 7b"). A wait at another place that read no key is listed as a
  finding: there the key changes what the game does;
- a "state" for each screenshot of the session: right after the prompt of the wait at which
  DOS took it, or, for a shot taken while the game was busy between two waits, after the
  prompt of the next wait (a finding too, since the screen may differ);
- runs of waits that only take the filler are written as a repeat block.

Left out, each with a comment: the keys and shots of the other programs (ARCH2.EXE, VIC.EXE,
NAPIC.EXE and the shipped NAPOLEON.EXE, D6 and D3), told apart by the PSP that read each key
and the video mode of each shot, and the shots named "dos", taken at the DOS prompt after Quit.
A session with a battle is written for its run with WON_OUTCOME (D4): the battle's keys are
left out, and the header names the recorded OUTCOME.&&& to give it.

Keys that no program read were thrown away, by a pause that ran out with the key still
waiting and BuffClear after it, or left in the buffer when the session stopped. They are
listed in the header. The header ends with the counts, and a line "finding:" for each thing
that step 7b must look at.
"""
import argparse
import json
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import play  # noqa: E402

SESSIONS = play.REPO / "tests" / "sessions"
# The strategic game's video modes: SCREEN 12 and SCREEN 0 (the Hall of Fame).
STRATEGIC_MODES = {0x12, 0x03}
# Key names of the screen tool for the BIOS key words that are not printable characters.
SCREEN_NAMES = {"enter": "enter", "esc": "esc", "tab": "tab", "bksp": "backspace", "space": "space",
                "up": "up", "down": "down", "left": "left", "right": "right", "home": "home", "end": "end",
                "pgup": "pageup", "pgdn": "pagedown", "ins": "insert", "del": "delete",
                **{f"f{n}": f"f{n}" for n in range(1, 13)}}
WORD_NAMES = {}
for _name, (_scan, _ch, _sh) in play.KEYS.items():
    WORD_NAMES.setdefault(_scan * 256 + _ch, _name)
    WORD_NAMES.setdefault(_scan * 256 + _sh, "shift-" + _name)
# The key for a pause that read no key in DOS. It must be a key that only TICK reads, since
# scripttick takes it back out of the buffer (SCRIPT.BM).
FILLER = "key f12"


def key_step(word):
    """The keys-file step for a BIOS key word, and its name in the timed script."""
    name = WORD_NAMES.get(word)
    if name is None:
        raise ValueError(f"no key name for the key word {word:#06x}")
    base = name[6:] if name.startswith("shift-") else name
    if base in SCREEN_NAMES and not name.startswith("shift-"):
        return f"key {SCREEN_NAMES[base]}", name
    ch = chr(word & 0xFF)
    if not 33 <= ord(ch) <= 126:
        raise ValueError(f"the key {name} has no step in the screen tool")
    return f"text {ch}", name


def place_text(place, letter):
    return f"{place}:{chr(letter)}" if letter else f"{place}"


class Session:
    """What the trace says about one session."""

    def __init__(self, script):
        self.script = play.Script(script)
        self.trace_path = play.OUT / self.script.name / "check" / "trace.json"
        if not self.trace_path.exists():
            raise SystemExit(f"{self.script.name}: no trace; run play.py check --port first "
                             f"({self.trace_path.relative_to(play.REPO)} is missing)")
        trace = json.loads(self.trace_path.read_text(encoding="ascii"))
        if trace["info"]["flags"]:
            raise SystemExit(f"{self.script.name}: the trace log was full; it misses the end of the run")
        self.events = trace["events"]
        self.findings = []
        # The place and letter of each wait, where the trace has them: a sample holds the
        # last wait of its tick, a read the wait that read it.
        self.places = {}
        for _tick, total, place, letter in trace["samples"]:
            self.places[total] = (place, letter)
        reads = [e for e in self.events if e["type"] == "R"]
        for e in reads:
            self.places[e["total"]] = (e["place"], e["letter"])
        # The strategic game is the program that read the most keys.
        self.won_psp = Counter(e["psp"] for e in reads).most_common(1)[0][0] if reads else None
        self._match_keys()
        self._place_shots()
        # Written once: writing the file adds the findings of the waits.
        self.text = self._keys_text()

    def _match_keys(self):
        """Pair each key typed (K) with the read (R) that took it from the same buffer slot."""
        pending = {}  # slot: the K event whose key waits there
        self.typed, self.unread, self.dropped = [], [], []
        for e in self.events:
            if e["type"] == "K":
                e["read"] = None
                self.typed.append(e)
                if e["dropped"]:
                    self.dropped.append(e)
                    continue
                if e["slot"] in pending:  # the key there before was thrown away
                    self.unread.append(pending.pop(e["slot"]))
                pending[e["slot"]] = e
            elif e["type"] == "R":
                k = pending.pop(e["slot"], None)
                if k is None or k["key"] != e["key"]:
                    raise SystemExit(f"{self.script.name}: a read at tick {e['tick']} took a key that "
                                     f"no K event typed into slot {e['slot']}")
                k["read"] = e
        self.unread += pending.values()
        self.unread.sort(key=lambda k: k["tick"])
        self.won_keys = {}  # total: [R events of the strategic game]
        self.other_keys = []
        for k in self.typed:
            r = k["read"]
            if r is None:
                continue
            if r["psp"] == self.won_psp:
                self.won_keys.setdefault(r["total"], []).append(r)
            else:
                self.other_keys.append(r)

    def _place_shots(self):
        """For each shot: the wait after whose prompt its state goes, or why it is left out."""
        shots = [e for e in self.events if e["type"] == "S"]
        if len(shots) != len(self.script.shots):
            raise SystemExit(f"{self.script.name}: the trace has {len(shots)} shots, the script "
                             f"{len(self.script.shots)}")
        self.shots = []  # (name, total or None, note)
        read_before = set()  # the totals whose wait had read a key by then
        order = {id(e): i for i, e in enumerate(self.events)}
        won_reads = sorted((r for rs in self.won_keys.values() for r in rs), key=lambda r: order[id(r)])
        for name, s in zip(self.script.shots, shots):
            read_before = {r["total"] for r in won_reads if order[id(r)] < order[id(s)]}
            if name.split("-", 1)[1] == "dos":
                self.shots.append((name, None, "the DOS prompt after Quit"))
            elif s["mode"] not in STRATEGIC_MODES:
                self.shots.append((name, None, f"another program's screen (video mode {s['mode']:02X}h)"))
            elif s["total"] in read_before:
                self.shots.append((name, s["total"] + 1, f"taken between waits {s['total']} and "
                                                         f"{s['total'] + 1}, while the game was busy"))
                self.findings.append(f"{name}: taken between waits {s['total']} and {s['total'] + 1}; its "
                                     f"state is at wait {s['total'] + 1}")
            else:
                self.shots.append((name, s["total"], ""))
        kept = [t for _, t, _ in self.shots if t is not None]
        self.last = max(kept) if kept else 0

    def _keys_text(self):
        """The keys file. It adds the findings of the waits to self.findings."""
        name = self.script.name
        battles = sorted({r["total"] for r in self.other_keys if r["mode"] == 0x10})
        n_won = sum(len(v) for v in self.won_keys.values())
        lines = [
            f"# {name}: the session of tests/scripts/{name}.keys, for the scripted port.",
            "# Written by tools/play/sessions.py from its trace run with the PDS 7.1 build; do not",
            "# edit, write it again. The first prompt is the port's built-in title; each other prompt",
            "# is a wait the strategic game announced in DOS.",
            f"# seed {play.seed_text(self.script.seed)} (WON_SEED)",
        ]
        if battles:
            lines.append(f"# Run with WON_OUTCOME set to tests/recorded/{name}/files/OUTCOME.&&& (D4): the "
                         f"battle at wait {', '.join(map(str, battles))} is left out.")
        lines.append(f"# {self.last} waits in DOS, {self.last + 1} prompts; {len(self.typed)} keys typed: "
                     f"{n_won} read by the strategic "
                     f"game, {len(self.other_keys)} by other programs, {len(self.unread)} by none, "
                     f"{len(self.dropped)} dropped with the buffer full.")
        def during(total):
            return f"during wait {total}" if total else "before the first wait"

        for r in self.other_keys:
            lines.append(f"#   left out: {key_step(r['key'])[1]} at tick {r['tick']}, read by another program "
                         f"(PSP {r['psp']:04X}h, video mode {r['mode']:02X}h) {during(r['total'])}")
        for k in self.unread:
            lines.append(f"#   left out: {key_step(k['key'])[1]} typed at tick {k['tick']}, {during(k['total'])}, "
                         f"read by no program")
        for k in self.dropped:
            lines.append(f"#   left out: {key_step(k['key'])[1]} typed at tick {k['tick']}, the buffer was full")
        for shot, total, note in self.shots:
            if total is None:
                lines.append(f"#   shot {shot}: left out, {note}")
        # A key typed while the game was busy waited in the buffer until the next wait. Under
        # a script it is typed at its wait, later than in DOS. That could matter to the four
        # PEEK(1052) = 30 checks of WON2.BM (naval combat). They read the buffer's tail, which
        # every key typed moves on and only BuffClear sets back to 30, so each one asks whether
        # a key was typed since the last BuffClear. Each guards a TICK, so the answer changes
        # the number of waits (docs/devnotes.md, "Step 7a"). The filler cannot help here, so
        # the header names these keys for the check of step 7b.
        ahead = [k for k in self.typed if k["read"] and k["read"]["psp"] == self.won_psp
                 and k["read"]["total"] > k["total"]]
        if ahead:
            waits = ", ".join(str(k["read"]["total"]) for k in ahead)
            lines.append(f"# Typed before its wait was announced, and waited in the buffer: the key of "
                         f"wait{'s' if len(ahead) > 1 else ''} {waits}.")
        late = [t for t in self.won_keys if t > self.last]
        if late:
            self.findings.append(f"keys read after the last shot's wait {self.last}, left out")
        if 0 in self.won_keys:
            self.findings.append("keys read before the first wait was announced; they come before the "
                                 "first prompt")
        body = []
        # The recordings ran ARCH2.EXE, whose picture took the session's first key. The port
        # has no ARCH2.EXE (D6), so WON.BAS draws its built-in title instead, and that title's
        # TICK 2 is one more wait before wait 1 of the trace.
        body.append((None, ["# the built-in title's TICK 2: the port runs no ARCH2.EXE (D6)", "prompt",
                            FILLER], False))
        for r in self.won_keys.get(0, []):
            body.append((None, [f"# {key_step(r['key'])[1]}, read before any wait", key_step(r["key"])[0]],
                         False))
        states = {}
        for shot, total, note in self.shots:
            if total is not None:
                states.setdefault(total, []).append((shot, note))
        for k in range(1, self.last + 1):
            place, letter = self.places.get(k, (None, 0))
            where = place_text(place, letter) if place is not None else "? (in a tick with others)"
            # The screen tool takes "#" only at the start of a line, and a text step takes
            # the rest of its line, so each comment is a line of its own.
            block = [f"# wait {k}, place {where}", "prompt"]
            for shot, note in states.get(k, []):
                block += [f"# shot {shot}" + (f": {note}" if note else ""), "state"]
            if k == self.last:
                body.append((k, block, False))
                break
            keys = self.won_keys.get(k, [])
            if keys:
                for r in keys:
                    block.append(key_step(r["key"])[0])
                if len(keys) > 1 and place != 4:
                    self.findings.append(f"wait {k} (place {where}) read {len(keys)} keys")
            else:
                block.append(FILLER)
                # A wait of unknown place came with others in one tick. Every wait but a
                # TICK loops until a key comes, so one that read no key was a pause.
                if place is not None and place != 3:
                    self.findings.append(f"wait {k} (place {where}) read no key in DOS; it gets "
                                         f"\"{FILLER}\"")
            body.append((k, block, not keys and k not in states))
        for f in self.findings:
            lines.append(f"# finding: {f}")
        lines.append("")
        lines += compress(body)
        return "\n".join(lines) + "\n"


def compress(blocks):
    """The lines of the blocks (wait, lines, filler only), with each run of three or more
    waits that take only the filler written as a repeat block."""
    out, i = [], 0
    while i < len(blocks):
        j = i
        while j < len(blocks) and blocks[j][2]:
            j += 1
        if j - i >= 3:
            out += [f"# waits {blocks[i][0]} to {blocks[j - 1][0]}: pauses that read no key in DOS",
                    f"repeat {j - i}", "prompt", FILLER, "end"]
            i = j
        else:
            out += blocks[i][1]
            i += 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("scripts", nargs="+")
    ap.add_argument("--check", action="store_true", help="only say whether each keys file would change")
    args = ap.parse_args()
    changed = 0
    for s in args.scripts:
        session = Session(s)
        text = session.text
        dest = SESSIONS / f"{session.script.name}.keys"
        old = dest.read_text(encoding="ascii") if dest.exists() else None
        state = "same" if old == text else ("new" if old is None else "changed")
        n_findings = len(session.findings)
        print(f"{session.script.name}: {session.last} waits, {state}, {n_findings} findings")
        for f in session.findings:
            print(f"  {f}")
        if state != "same":
            changed += 1
            if not args.check:
                SESSIONS.mkdir(parents=True, exist_ok=True)
                dest.write_text(text, encoding="ascii", newline="\n")
    sys.exit(1 if args.check and changed else 0)


if __name__ == "__main__":
    main()
