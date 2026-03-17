#!/system/bin/sh
# get_app_status.sh — Return blocked list and target list for WebUI to diff
# Output format: two sections separated by "---"
# Section 1: blocked packages (one per line)
# Section 2: target.txt contents (one per line)

MODDIR=$(dirname "$(dirname "$0")")
BLOCKED="$MODDIR/cache/blocked_packages.list"
TARGET="/data/adb/tricky_store/target.txt"

echo "BLOCKED:"
[ -f "$BLOCKED" ] && cat "$BLOCKED" || true
echo "TARGET:"
[ -f "$TARGET" ] && cat "$TARGET" || true
