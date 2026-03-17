#!/system/bin/sh
# set_monitor_interval.sh - Set the monitor refresh interval in seconds
# Usage: sh set_monitor_interval.sh <seconds>

VAL="$1"
CONFIG_DIR="/data/adb/modules/auto_target/config"

[ -z "$VAL" ] && echo "[!] No interval specified" && exit 1

# Validate: must be a number
case "$VAL" in
    ''|*[!0-9]*) echo "[!] Invalid value: must be a number" && exit 1 ;;
esac

# Clamp to 10–3600
[ "$VAL" -lt 10   ] && VAL=10
[ "$VAL" -gt 3600 ] && VAL=3600

mkdir -p "$CONFIG_DIR"
echo "$VAL" > "$CONFIG_DIR/monitor_interval"

echo "[+] Monitor interval set to ${VAL}s"
echo "[*] Takes effect on next monitor cycle"
