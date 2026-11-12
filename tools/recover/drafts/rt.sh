PY=../venv/Scripts/python.exe; T=../../wars-of-napoleon/tools/recover
$PY make_wonmenu.py >/dev/null && $PY -I $T/calibrate_bc.py src ../../pds71/install out WONMENU=O,Fs >/dev/null || { tr -d '\a' < out/WONMENU.CMP | grep -B1 "\^"; exit 1; }
$PY -I $T/compare.py WON_unp.EXE won_runtime.tsv out/WONMENU.OBJ --show WONMENU.03 > show_menu.txt
grep "  WONMENU\|BC_CN\|exact," show_menu.txt
grep -n "|" show_menu.txt | awk -F: '{print $1}' | awk 'NR==1{s=$1;p=$1;next} $1<=p+3{p=$1;next} {print s"-"p; s=$1;p=$1} END{print s"-"p}' | tr '\n' ' '; echo
