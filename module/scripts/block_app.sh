#!/system/bin/sh
# block_app.sh — Add package to blocked list and remove from target.txt
# Usage: sh block_app.sh <package.name>

MODDIR=$(dirname "$(dirname "$0")")
BLOCKED="$MODDIR/cache/blocked_packages.list"
TARGET="/data/adb/tricky_store/target.txt"
PKG="$1"

[ -z "$PKG" ] && echo "[!] No package provided" && exit 1

mkdir -p "$(dirname "$BLOCKED")"
touch "$BLOCKED"

# Add to blocked list if not already there
if grep -qxF "$PKG" "$BLOCKED" 2>/dev/null; then
    echo "[*] Already blocked: $PKG"
else
    echo "$PKG" >> "$BLOCKED"
    echo "[+] Blocked: $PKG"
fi

# Remove from target.txt (strip suffixes ! and ?)
if [ -f "$TARGET" ]; then
    sed -i "/^${PKG}[!?]*$/d" "$TARGET"
    echo "[+] Removed from target.txt: $PKG"
fi
