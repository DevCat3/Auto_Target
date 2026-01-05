#!/system/bin/sh
# AutoTarget - Complete cache-aware update script
# This version properly preserves app list across reboots

TARGET_FILE="/data/adb/tricky_store/target.txt"
CACHE_DIR="/data/adb/modules/auto_target/cache"
TEMP_ALL="/data/local/tmp/all_packages.txt"
TEMP_CURRENT="/data/local/tmp/current_packages.txt"

# Ensure directories exist
mkdir -p "$(dirname "$TARGET_FILE")"
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$TEMP_ALL")"

# Get current installed apps (user apps only)
pm list packages -3 2>/dev/null | cut -f2 -d: > "$TEMP_CURRENT"

# Load cached packages from previous runs
if [ -f "$CACHE_DIR/packages.list" ]; then
    cat "$CACHE_DIR/packages.list" > "$TEMP_ALL"
else
    touch "$TEMP_ALL"
fi

# Merge current apps with cache (remove duplicates)
cat "$TEMP_CURRENT" >> "$TEMP_ALL"
sort -u "$TEMP_ALL" > "$CACHE_DIR/packages.list"

# Now build target.txt from complete cache
{
    # Core Google packages (always first)
    echo "com.android.vending"
    echo "com.google.android.gms"
    echo "com.google.android.gsf"
    
    # All cached packages (including current and historical)
    cat "$CACHE_DIR/packages.list"
    
    # Custom packages if exist
    if [ -f "$CACHE_DIR/custom_packages.list" ]; then
        cat "$CACHE_DIR/custom_packages.list"
    fi
} > "$TARGET_FILE"

# Clean up temp files
rm -f "$TEMP_ALL" "$TEMP_CURRENT"

# Log success
log -t Auto_Target "✓ Updated target.txt with $(wc -l < "$TARGET_FILE") total packages"
