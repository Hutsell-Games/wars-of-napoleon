PY=../venv/Scripts/python.exe; T=../../wars-of-napoleon/tools/recover
$PY -I make_won_bi.py >/dev/null && cp WON.BI src/ && $PY make_won.py >/dev/null || exit 1
$PY -I $T/calibrate_bc.py src ../../pds71/install out WON=O,E,Fs >/dev/null || { tr -d '\a' < out/WON.CMP | grep -B1 "\^" | head -30; exit 1; }
$PY -I $T/compare.py WON_unp.EXE won_runtime.tsv out/WON.OBJ ${1:+--show $1} > show_won.txt
grep "  WON\.\|  WON(\|BC_CN\|exact,\|procedures compiled\|header" show_won.txt
