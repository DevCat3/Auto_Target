#!/system/bin/sh
PACKAGE=$1
CACHE_DIR="/data/adb/modules/auto_target/cache"

if [ -z "$PACKAGE" ]; then
    echo "Error: No package specified"
    exit 1
fi

if [ ! -f "$CACHE_DIR/custom_packages.list" ]; then
    echo "Custom list is empty"
    exit 0
fi

if ! grep -Fxq "$PACKAGE" "$CACHE_DIR/custom_packages.list"; then
    echo "Package $PACKAGE not in custom list"
    exit 0
fi

TEMP_FILE="/data/local/tmp/custom_temp.txt"
mkdir -p $(dirname "$TEMP_FILE")

grep -Fxv "$PACKAGE" "$CACHE_DIR/custom_packages.list" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CACHE_DIR/custom_packages.list"

if sh /data/adb/modules/auto_target/scripts/update_target.sh; then
    echo "Removed $PACKAGE from custom list"
else
    echo "Error: Failed to update target file!"
    exit 1
fi