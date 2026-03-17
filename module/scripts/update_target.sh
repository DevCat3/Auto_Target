#!/system/bin/sh
# update_target.sh — Rebuild target.txt respecting blocked list

TARGET_FILE="/data/adb/tricky_store/target.txt"
CACHE_DIR="/data/adb/modules/auto_target/cache"
BLOCKED="$CACHE_DIR/blocked_packages.list"
TEMP_CURRENT="/data/local/tmp/at_current_packages.txt"
TEMP_ALL="/data/local/tmp/at_all_packages.txt"

mkdir -p "$CACHE_DIR" "$(dirname "$TARGET_FILE")" "$(dirname "$TEMP_CURRENT")"
touch "$BLOCKED" 2>/dev/null

# Get current user apps
pm list packages -3 2>/dev/null | cut -f2 -d: > "$TEMP_CURRENT"

# Merge with existing cache
if [ -f "$CACHE_DIR/packages.list" ]; then
    cat "$CACHE_DIR/packages.list" > "$TEMP_ALL"
else
    touch "$TEMP_ALL"
fi
cat "$TEMP_CURRENT" >> "$TEMP_ALL"
sort -u "$TEMP_ALL" > "$CACHE_DIR/packages.list"

# Build target.txt
{
    # Core Google packages (always included)
    echo "com.android.vending"
    echo "com.google.android.gms"
    echo "com.google.android.gsf"

    # All cached packages — skip blocked ones
    while IFS= read -r PKG; do
        [ -z "$PKG" ] && continue
        grep -qxF "$PKG" "$BLOCKED" 2>/dev/null && continue
        echo "$PKG"
    done < "$CACHE_DIR/packages.list"

    # Custom packages — also skip blocked
    if [ -f "$CACHE_DIR/custom_packages.list" ]; then
        while IFS= read -r PKG; do
            [ -z "$PKG" ] && continue
            grep -qxF "$PKG" "$BLOCKED" 2>/dev/null && continue
            echo "$PKG"
        done < "$CACHE_DIR/custom_packages.list"
    fi
} | sort -u > "$TARGET_FILE"

rm -f "$TEMP_ALL" "$TEMP_CURRENT"
log -t Auto_Target "target.txt updated: $(wc -l < "$TARGET_FILE") packages"
