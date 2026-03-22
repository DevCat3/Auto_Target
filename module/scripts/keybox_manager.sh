#!/system/bin/sh
# keybox_manager.sh — Load keybox.xml from file path or URL
# Usage:
#   sh keybox_manager.sh file /path/to/keybox.xml
#   sh keybox_manager.sh url  https://example.com/keybox.xml
#   sh keybox_manager.sh backup
#   sh keybox_manager.sh restore

KB_DIR="/data/adb/tricky_store"
KB="$KB_DIR/keybox.xml"
KB_BAK="$KB_DIR/keybox.xml.bak"
ACTION="$1"
SRC="$2"

download() {
    if command -v curl >/dev/null 2>&1; then
        curl --connect-timeout 15 -fsSL "$1"
    else
        busybox wget -T 15 --no-check-certificate -qO- "$1"
    fi
}

validate_keybox() {
    grep -q "AndroidAttestation\|PrivateKey\|Certificate" "$1" 2>/dev/null
}

case "$ACTION" in
    file)
        [ -f "$SRC" ] || { echo "[!] File not found: $SRC"; exit 1; }
        validate_keybox "$SRC" || { echo "[!] File does not look like a valid keybox.xml"; exit 1; }
        [ -f "$KB" ] && cp "$KB" "$KB_BAK"
        cp "$SRC" "$KB"
        echo "[+] Keybox loaded from file: $SRC"
        ;;
    url)
        echo "[*] Downloading from: $SRC"
        TMPKB=$(mktemp)
        download "$SRC" > "$TMPKB" || { echo "[!] Download failed"; rm -f "$TMPKB"; exit 1; }
        [ -s "$TMPKB" ] || { echo "[!] Downloaded file is empty"; rm -f "$TMPKB"; exit 1; }
        validate_keybox "$TMPKB" || { echo "[!] Downloaded file is not a valid keybox.xml"; rm -f "$TMPKB"; exit 1; }
        [ -f "$KB" ] && cp "$KB" "$KB_BAK"
        cp "$TMPKB" "$KB"
        rm -f "$TMPKB"
        echo "[+] Keybox loaded from URL"
        ;;
    backup)
        [ -f "$KB" ] || { echo "[!] No keybox.xml found"; exit 1; }
        cp "$KB" "$KB_BAK"
        echo "[+] Keybox backed up to keybox.xml.bak"
        ;;
    restore)
        [ -f "$KB_BAK" ] || { echo "[!] No backup found"; exit 1; }
        cp "$KB_BAK" "$KB"
        echo "[+] Keybox restored from backup"
        ;;
    *)
        echo "[!] Usage: keybox_manager.sh <file|url|backup|restore> [path/url]"
        exit 1
        ;;
esac
