#!/system/bin/sh
# monitor.sh — Watch for new installs/uninstalls, configurable interval

MODDIR=$(dirname "$(dirname "$0")")
CACHE_DIR="$MODDIR/cache"
CONFIG_DIR="$MODDIR/config"
CURRENT_FILE="/data/local/tmp/at_monitor_packages.txt"

mkdir -p "$CACHE_DIR" "$CONFIG_DIR"

# Read interval from config (default: 60 seconds)
get_interval() {
    if [ -f "$CONFIG_DIR/monitor_interval" ]; then
        VAL=$(cat "$CONFIG_DIR/monitor_interval" | tr -d '[:space:]')
        # Validate: must be a number between 10 and 3600
        case "$VAL" in
            ''|*[!0-9]*) echo 60 ;;
            *) [ "$VAL" -lt 10 ] && echo 10 || \
               { [ "$VAL" -gt 3600 ] && echo 3600 || echo "$VAL"; } ;;
        esac
    else
        echo 60
    fi
}

log -t Auto_Target "Monitor started"

# Initialize cache
if [ ! -f "$CACHE_DIR/packages.list" ]; then
    pm list packages -3 | cut -f2 -d: > "$CACHE_DIR/packages.list"
fi

# Run update on start
sh "$MODDIR/scripts/update_target.sh"

while true; do
    INTERVAL=$(get_interval)
    sleep "$INTERVAL"

    pm list packages -3 | cut -f2 -d: > "$CURRENT_FILE"

    if ! cmp -s "$CACHE_DIR/packages.list" "$CURRENT_FILE"; then
        log -t Auto_Target "Package change detected, updating target..."
        if sh "$MODDIR/scripts/update_target.sh"; then
            cp "$CURRENT_FILE" "$CACHE_DIR/packages.list"
            log -t Auto_Target "Monitor update OK"
        fi
    fi
done
