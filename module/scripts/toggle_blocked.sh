#!/system/bin/sh
# toggle_blocked.sh - Block or unblock a package from being added to target.txt
# Usage: sh toggle_blocked.sh <package> <1=block|0=unblock>

PKG="$1"
ACTION="$2"

CACHE_DIR="/data/adb/modules/auto_target/cache"
BLOCKED="$CACHE_DIR/blocked_packages.list"
TARGET="/data/adb/tricky_store/target.txt"

[ -z "$PKG" ] && echo "[!] No package specified" && exit 1
[ -z "$ACTION" ] && echo "[!] No action specified (1=block, 0=unblock)" && exit 1

mkdir -p "$CACHE_DIR"
touch "$BLOCKED" 2>/dev/null

if [ "$ACTION" = "1" ]; then
    # Block: add to blocked list, remove from target.txt immediately
    grep -qxF "$PKG" "$BLOCKED" || echo "$PKG" >> "$BLOCKED"
    [ -f "$TARGET" ] && sed -i "/^${PKG}$/d" "$TARGET"
    echo "[+] Blocked: $PKG"
    echo "[*] Removed from target.txt — monitor will not re-add it"
else
    # Unblock: remove from blocked list, re-add to target.txt
    if [ -f "$BLOCKED" ]; then
        sed -i "/^${PKG}$/d" "$BLOCKED"
    fi
    if [ -f "$TARGET" ]; then
        grep -qxF "$PKG" "$TARGET" || echo "$PKG" >> "$TARGET"
    fi
    echo "[+] Unblocked: $PKG"
    echo "[*] Added back to target.txt"
fi
