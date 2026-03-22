#!/system/bin/sh
# backup_target.sh — Backup / restore / list target.txt snapshots
# Usage:
#   sh backup_target.sh create
#   sh backup_target.sh list
#   sh backup_target.sh restore <filename>
#   sh backup_target.sh delete <filename>

TARGET="/data/adb/tricky_store/target.txt"
BACKUP_DIR="/data/adb/modules/auto_target/backups"
ACTION="$1"
FILE="$2"

mkdir -p "$BACKUP_DIR"

case "$ACTION" in
    create)
        [ -f "$TARGET" ] || { echo "[!] target.txt not found"; exit 1; }
        TS=$(date '+%Y%m%d_%H%M%S')
        DEST="$BACKUP_DIR/target_${TS}.txt"
        cp "$TARGET" "$DEST"
        COUNT=$(wc -l < "$TARGET")
        echo "[+] Backup created: target_${TS}.txt ($COUNT packages)"
        ;;
    list)
        BACKUPS=$(ls -1t "$BACKUP_DIR"/*.txt 2>/dev/null)
        [ -z "$BACKUPS" ] && { echo "[*] No backups found"; exit 0; }
        echo "$BACKUPS" | while IFS= read -r f; do
            NAME=$(basename "$f")
            COUNT=$(wc -l < "$f")
            printf '%s  (%d packages)\n' "$NAME" "$COUNT"
        done
        ;;
    restore)
        [ -z "$FILE" ] && { echo "[!] Specify backup filename"; exit 1; }
        SRC="$BACKUP_DIR/$FILE"
        [ -f "$SRC" ] || { echo "[!] Backup not found: $FILE"; exit 1; }
        # Save current as pre-restore backup
        TS=$(date '+%Y%m%d_%H%M%S')
        [ -f "$TARGET" ] && cp "$TARGET" "$BACKUP_DIR/pre_restore_${TS}.txt"
        cp "$SRC" "$TARGET"
        echo "[+] Restored from $FILE ($(wc -l < "$TARGET") packages)"
        ;;
    delete)
        [ -z "$FILE" ] && { echo "[!] Specify backup filename"; exit 1; }
        SRC="$BACKUP_DIR/$FILE"
        [ -f "$SRC" ] || { echo "[!] Backup not found: $FILE"; exit 1; }
        rm "$SRC"
        echo "[+] Deleted: $FILE"
        ;;
    *)
        echo "[!] Usage: backup_target.sh <create|list|restore|delete> [filename]"
        exit 1
        ;;
esac
