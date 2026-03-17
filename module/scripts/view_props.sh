#!/system/bin/sh
# view_props.sh - List props matching a given filter pattern
# Usage: sh view_props.sh <pattern>

FILTER="$1"

if [ -z "$FILTER" ]; then
  echo "[!] No filter provided. Usage: view_props.sh <pattern>"
  exit 1
fi

RESULT=$(getprop | grep -E "$FILTER" | sed -E 's/^\[(.*)\]:.*/\1/')

if [ -z "$RESULT" ]; then
  echo "[*] No props found matching: $FILTER"
else
  COUNT=$(echo "$RESULT" | wc -l)
  echo "$RESULT"
  echo ""
  echo "[+] Found $COUNT prop(s) matching: $FILTER"
fi
