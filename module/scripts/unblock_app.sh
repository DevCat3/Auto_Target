#!/system/bin/sh
# unblock_app.sh — Remove package from blocked list and add to target.txt
# Usage: sh unblock_app.sh <package.name>

MODDIR=$(dirname "$(dirname "$0")")
BLOCKED="$MODDIR/cache/blocked_packages.list"
TARGET="/data/adb/tricky_store/target.txt"
PKG="$1"

[ -z "$PKG" ] && echo "[!] No package provided" && exit 1

# Remove from blocked list
if [ -f "$BLOCKED" ] && grep -qxF "$PKG" "$BLOCKED" 2>/dev/null; then
    sed -i "/^${PKG}$/d" "$BLOCKED"
    echo "[+] Unblocked: $PKG"
else
    echo "[*] Not in blocked list: $PKG"
fi

# Add to target.txt if not already there
if [ -f "$TARGET" ]; then
    if grep -qE "^${PKG}[!?]*$" "$TARGET" 2>/dev/null; then
        echo "[*] Already in target.txt: $PKG"
    else
        echo "$PKG" >> "$TARGET"
        echo "[+] Added to target.txt: $PKG"
    fi
else
    echo "$PKG" > "$TARGET"
    echo "[+] Created target.txt with: $PKG"
fi
