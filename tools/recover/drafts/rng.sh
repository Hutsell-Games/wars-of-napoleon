# Usage: bash rng.sh FILE FROM TO   (hex addresses)
awk -v A=$((16#$2)) -v B=$((16#$3)) '{x=strtonum("0x"$1)} x>=A && x<=B' $1
