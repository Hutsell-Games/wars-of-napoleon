PY=../venv/Scripts/python.exe; T=../../wars-of-napoleon/tools/recover
$PY -I make_won_bi.py >/dev/null && cp WON.BI src/ && $PY make_won2.py >/dev/null || exit 1
$PY -I $T/calibrate_bc.py src ../../pds71/install out WON2=O,Fs >/dev/null || { tr -d '\a' < out/WON2.CMP | grep -B1 "\^" | head -20; exit 1; }
$PY -I $T/compare.py WON_unp.EXE won_runtime.tsv out/WON2.OBJ ${1:+--show $1} > show_won2.txt
grep "  WON2\|BC_CN\|exact,\|procedures compiled" show_won2.txt
