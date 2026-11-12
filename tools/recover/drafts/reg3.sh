# Usage: bash reg3.sh LABEL [context]  -- changed regions of one WON procedure (or 'WON(module)')
bash rt3.sh "$1" >/dev/null
c=${2:-3}
awk -v L="$1" '$1==L && /^  /{on=1;next} on && /^  WON[.(]/{exit} on && /^  BC_CN/{exit} on' show_won.txt > /tmp/sbs3.txt
grep -n "|" /tmp/sbs3.txt | cut -d: -f1 | awk -v c=$c 'NR==1{s=$1;p=$1;next} $1<=p+2*c{p=$1;next} {print s"-"p; s=$1;p=$1} END{if(s)print s"-"p}' | while IFS=- read a b; do echo "----- $a-$b"; sed -n "$((a>c?a-c:1)),$((b+c))p" /tmp/sbs3.txt; done
