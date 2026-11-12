# Scratch: build the library in a part order ($1, comma-separated), link Hutsell's CWS objects without nocom, compare.
set -e
cd "$(dirname "$0")/../../../../../won-hutsellgames"  # the scratch folder beside the repo, deleted 2026-11-12
W=work/try; rm -rf $W work/link-try; mkdir -p $W
python -I tools/mkefr.py "$(cd ../pds71/install && pwd -W)" "$(pwd -W)/$W" "$1" > /dev/null
cp ../pds71/install/LINK.EXE ../pds71/install/QBX.LIB ../pds71/install/NO*.OBJ $W/
C=work/cws-orig
python -I ../wars-of-napoleon/tools/recover/linkcheck.py --drop nocom $W work/link-try $C/CWS.LNK $C/CWS.EXE $C/CWSTRAT.OBJ $C/CWSTRAT2.OBJ $C/CWSMENU.OBJ | tail -4
