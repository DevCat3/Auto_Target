#!/system/bin/sh
# reset_props.sh - Reset props matching a given filter pattern using resetprop
# Usage: sh reset_props.sh <pattern>

FILTER="$1"

if [ -z "$FILTER" ]; then
  echo "[!] No filter provided. Usage: reset_props.sh <pattern>"
  exit 1
fi

PROPS=$(getprop | grep -E "$FILTER" | sed -E 's/^\[(.*)\]:.*/\1/')

if [ -z "$PROPS" ]; then
  echo "[*] No props found matching: $FILTER"
  exit 0
fi

COUNT=$(echo "$PROPS" | wc -l)
echo "[*] Found $COUNT prop(s) matching: $FILTER"
echo "[*] Resetting..."
echo ""

echo "$PROPS" | while IFS= read -r prop; do
  if resetprop -p -d "$prop"; then
    echo "[+] Reset: $prop"
  else
    echo "[!] Failed: $prop"
  fi
done

echo ""
echo "[+] Done"
