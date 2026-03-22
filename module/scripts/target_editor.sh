#!/system/bin/sh
# target_editor.sh — Read or write target.txt
# Usage:
#   sh target_editor.sh read
#   sh target_editor.sh write <base64_content>

TARGET="/data/adb/tricky_store/target.txt"
ACTION="$1"

case "$ACTION" in
    read)
        [ -f "$TARGET" ] || { echo "[!] target.txt not found"; exit 1; }
        cat "$TARGET"
        ;;
    write)
        CONTENT="$2"
        [ -z "$CONTENT" ] && { echo "[!] No content provided"; exit 1; }
        mkdir -p "$(dirname "$TARGET")"
        # Decode base64 and write
        printf '%s' "$CONTENT" | base64 -d > "$TARGET"
        echo "[+] target.txt saved ($(wc -l < "$TARGET") lines)"
        ;;
    *)
        echo "[!] Usage: target_editor.sh <read|write> [base64_content]"
        exit 1
        ;;
esac
