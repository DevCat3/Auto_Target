#!/system/bin/sh
# boot_logger.sh — Log boot-time diagnostics
# Called from service.sh when logging is enabled
# Output: /data/adb/modules/auto_target/logs/boot_YYYYMMDD_HHMMSS.log

MODDIR="/data/adb/modules/auto_target"
LOG_DIR="$MODDIR/logs"
mkdir -p "$LOG_DIR"

# Keep only last 5 logs
LOG_COUNT=$(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)
if [ "$LOG_COUNT" -ge 5 ]; then
    ls -1t "$LOG_DIR"/*.log | tail -n +5 | while read -r f; do rm -f "$f"; done
fi

TS=$(date '+%Y%m%d_%H%M%S')
LOG="$LOG_DIR/boot_${TS}.log"

{
    echo "===== Auto Target Boot Log ====="
    echo "Date     : $(date)"
    echo "Device   : $(getprop ro.product.model)"
    echo "Android  : $(getprop ro.build.version.release)"
    echo "SDK      : $(getprop ro.build.version.sdk)"
    echo ""
    echo "--- Target.txt ---"
    TARGET="/data/adb/tricky_store/target.txt"
    if [ -f "$TARGET" ]; then
        echo "Packages : $(wc -l < "$TARGET")"
        echo "Path     : $TARGET"
    else
        echo "NOT FOUND"
    fi
    echo ""
    echo "--- Blocked List ---"
    BLOCKED="$MODDIR/cache/blocked_packages.list"
    if [ -f "$BLOCKED" ]; then
        echo "Blocked  : $(grep -c '[^[:space:]]' "$BLOCKED" 2>/dev/null || echo 0)"
    else
        echo "Empty"
    fi
    echo ""
    echo "--- Monitor Config ---"
    CFG="$MODDIR/config/monitor_interval"
    [ -f "$CFG" ] && echo "Interval : $(cat "$CFG")s" || echo "Interval : 60s (default)"
    echo ""
    echo "--- Module ---"
    grep -E '^(version|versionCode)=' "$MODDIR/module.prop" 2>/dev/null
    echo ""
    echo "===== End ====="
} > "$LOG" 2>&1

log -t Auto_Target "Boot log saved: $LOG"
