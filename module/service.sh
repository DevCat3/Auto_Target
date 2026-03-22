#!/system/bin/sh
# service.sh — Runs after boot, props and su are available
MODDIR=${0%/*}

# Wait for system to fully boot
sleep 30

# Boot logger (enabled by default, toggle in WebUI settings)
LOG_FLAG="$MODDIR/config/boot_log_enabled"
# Default: enabled (create flag if missing)
if [ ! -f "$LOG_FLAG" ]; then
    mkdir -p "$MODDIR/config"
    echo "1" > "$LOG_FLAG"
fi
[ "$(cat "$LOG_FLAG")" = "1" ] && sh "$MODDIR/scripts/boot_logger.sh" &

# Build app name cache in background (used by WebUI apps tab)
sh "$MODDIR/scripts/build_applist.sh" &

sh "$MODDIR/scripts/monitor.sh" &

log -t Auto_Target "Boot service complete"
