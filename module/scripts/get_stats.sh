#!/system/bin/sh
# get_stats.sh — Output JSON stats (always exits 0)
TARGET="/data/adb/tricky_store/target.txt"
BLOCKED="/data/adb/modules/auto_target/cache/blocked_packages.list"
CACHE="/data/adb/modules/auto_target/cache/packages.list"

targeted=0
blocked=0
total=0

if [ -f "$TARGET" ]; then
    n=$(grep -c '.' "$TARGET" 2>/dev/null); targeted=${n:-0}
fi
if [ -f "$BLOCKED" ]; then
    n=$(grep -c '.' "$BLOCKED" 2>/dev/null); blocked=${n:-0}
fi
if [ -f "$CACHE" ]; then
    n=$(grep -c '.' "$CACHE" 2>/dev/null); total=${n:-0}
else
    total=$(pm list packages -3 2>/dev/null | wc -l | tr -d ' \n')
fi

printf '{"targeted":%d,"blocked":%d,"total":%d}\n' "$targeted" "$blocked" "$total"
exit 0
