import difflib, sys
sys.path.insert(0, sys.argv[0].rsplit('/',1)[0])
from omfdump import parse
a = parse(sys.argv[1]); b = parse(sys.argv[2])
for i in (1, 9):
    x = bytes(a[2].get(i, b'')); y = bytes(b[2].get(i, b''))
    sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
    same = sum(bl.size for bl in sm.get_matching_blocks())
    print(f"{a[1][i][0]}: {same} of {len(y)} shipped bytes align ({100*same/len(y):.1f}%)")
    ops = [o for o in sm.get_opcodes() if o[0] != 'equal']
    print("   differing runs:", len(ops), ops[:6])
