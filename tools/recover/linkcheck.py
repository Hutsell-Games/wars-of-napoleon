"""Link object files with a PDS 7.1 linker response file under DOSBox,
unpack the result and compare it with a shipped executable.

Usage: python -I linkcheck.py PDS71_DIR WORK_DIR LNK_FILE SHIPPED.EXE OBJ...

The response file's "c:\\pds71\\" is rewritten to "c:\\", where PDS 7.1 is
mounted. Both executables go through unlzexe91.unpack, then the load
modules, relocations and entry points are compared.
"""
import os
import shutil
import struct
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unlzexe91 import read_mz, unpack  # noqa: E402

DOSBOX = Path(r"C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe")


def main():
    args = sys.argv[1:]
    drop = []
    while args and args[0] == "--drop":
        drop.append(args[1].lower())
        args = args[2:]
    pds, work, lnk, shipped = (Path(a).resolve() for a in args[:4])
    objs = [Path(a).resolve() for a in args[4:]]
    work.mkdir(parents=True, exist_ok=True)
    for o in objs:
        shutil.copy(o, work / o.name.upper())
    text = lnk.read_bytes().decode("latin1").replace("\r\n", "\n")
    text = text.replace("c:\\pds71\\", "c:\\").replace("C:\\PDS71\\", "c:\\")
    for name in drop:  # --drop noega removes "c:\noega+" from the response file
        text = text.replace("c:\\" + name + "+", "")
    print("response file:", text.replace("\n", " | "))
    (work / "LINK.RSP").write_bytes(text.replace("\n", "\r\n").encode("latin1"))
    conf = work / "run.conf"
    conf.write_text("\n".join([
        "[sdl]", "fullscreen=false", "output=surface", "",
        "[cpu]", "cycles=max", "",
        "[autoexec]",
        f'mount c "{pds}"', f'mount d "{work}"',
        "path c:\\", "set LIB=c:\\", "d:",
        "link @LINK.RSP > LINK.OUT",
        "exit", "",
    ]), encoding="ascii")
    env = dict(os.environ, SDL_VIDEODRIVER="dummy")
    subprocess.run([str(DOSBOX), "-conf", str(conf), "-noconsole"], env=env, timeout=300)
    lines = [l.strip() for l in text.split("\n") if l.strip()]
    switches = next(i for i, l in enumerate(lines) if "/" in l)
    exe_name = lines[switches + 1]
    built = work / (exe_name.upper() + ".EXE")
    if not built.exists():
        print("no executable; LINK.OUT:")
        print((work / "LINK.OUT").read_text(errors="replace"))
        return
    a = read_mz(unpack(built.read_bytes())[0])
    b = read_mz(unpack(shipped.read_bytes())[0])
    print(f"built {built.name}: {len(a.data)} bytes, {len(a.relocs)} relocations, entry {a.cs:04x}:{a.ip:04x}")
    print(f"shipped {shipped.name}: {len(b.data)} bytes, {len(b.relocs)} relocations, entry {b.cs:04x}:{b.ip:04x}")
    n = min(len(a.data), len(b.data))
    diff = [i for i in range(n) if a.data[i] != b.data[i]]
    print(f"load modules: {len(diff)} bytes differ in the first {n}" + (f", first at {diff[0]:#x}" if diff else ""))
    print(f"relocations equal: {sorted(a.relocs) == sorted(b.relocs)}")


if __name__ == "__main__":
    main()
