#!/system/bin/sh
# service.sh — Runs after boot, props and su are available
MODDIR=${0%/*}

# Wait for system to fully boot
sleep 30

# ── Boot Hash (correct place — props are loaded here) ─────────────────────────
# Read vbmeta digest from the actual block device to get the real unmodified hash
HASH_FILE="/data/adb/boot_hash"
PROP_NAME="ro.boot.vbmeta.digest"

vbmeta_from_block() {
    # Try common vbmeta block device paths
    for blk in \
        /dev/block/by-name/vbmeta \
        /dev/block/by-name/vbmeta_a \
        /dev/block/by-name/vbmeta_b \
        /dev/block/platform/*/by-name/vbmeta \
        /dev/block/platform/*/by-name/vbmeta_a; do
        [ -b "$blk" ] || continue
        # AVB vbmeta digest starts at offset 0x140 (320), length 32 bytes (sha256)
        hash=$(dd if="$blk" bs=1 skip=320 count=32 2>/dev/null | od -An -tx1 | tr -d ' \n')
        [ ${#hash} -eq 64 ] && printf '%s' "$hash" && return 0
    done
    return 1
}

REAL_HASH=$(vbmeta_from_block)
if [ -n "$REAL_HASH" ]; then
    printf '%s' "$REAL_HASH" > "$HASH_FILE"
    resetprop -n "$PROP_NAME" "$REAL_HASH"
else
    # Fallback: use the prop value already set by bootloader (still better than nothing)
    BOOT_HASH=$(getprop "$PROP_NAME")
    if [ -n "$BOOT_HASH" ]; then
        printf '%s' "$BOOT_HASH" > "$HASH_FILE"
    fi
fi

# ── Monitor ───────────────────────────────────────────────────────────────────
# Build app name cache in background (used by WebUI apps tab)
sh "$MODDIR/scripts/build_applist.sh" &

sh "$MODDIR/scripts/monitor.sh" &

log -t Auto_Target "Boot service complete"
