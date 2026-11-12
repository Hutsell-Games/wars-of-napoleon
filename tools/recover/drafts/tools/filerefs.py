"""Which of the game's files do the programs name?

Usage: python -I filerefs.py GAME_DIR WON_UNPACKED NAPOLEON_UNPACKED

For each file in GAME_DIR, reports where its full name appears (case
ignored): in WON.EXE, in NAPOLEON.EXE, in the tactical source (*.BAS), in
the batch files. Also prints every string in the two programs that looks like
a file name or a name prefix, so that names built at run time
("lead" + year + ".dat") can be seen.
"""
import re
import sys
from pathlib import Path


def main():
    game = Path(sys.argv[1])
    won = Path(sys.argv[2]).read_bytes().lower()
    nap = Path(sys.argv[3]).read_bytes().lower()
    src = b"".join(p.read_bytes() for p in game.glob("*.BAS")).lower()
    bat = b"".join(p.read_bytes() for p in game.glob("*.BAT")).lower()
    print(f"{'file':14} WON  NAP  SRC  BAT")
    for f in sorted(p.name for p in game.iterdir() if p.is_file()):
        n = f.lower().encode("latin1")
        cols = ["yes " if n in blob else "-   " for blob in (won, nap, src, bat)]
        print(f"{f:14} {' '.join(cols)}")
    pat = re.compile(rb"[a-z0-9_~$&*?.]{2,12}\.(?:dat|map|ini|ega|vga|cfg|sav|nws|his|exe|com|doc|txt|ory|\$\$\$|&&&)")
    for label, blob in (("WON.EXE", won), ("NAPOLEON.EXE", nap)):
        names = sorted({m.group().decode("latin1") for m in pat.finditer(blob)})
        print(f"\nfile names in {label}: {' '.join(names)}")
    for label, blob in (("WON.EXE", won), ("NAPOLEON.EXE", nap)):
        hits = sorted({m.group().decode("latin1") for m in re.finditer(rb"\b(?:lead|euro|nws|battsumm|generalz|maxskors|hiscore|prefer|setup|quotes)[a-z0-9.]*", blob)})
        print(f"name prefixes in {label}: {' '.join(hits)}")


if __name__ == "__main__":
    main()
