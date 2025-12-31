#!/system/bin/sh
TARGET_FILE="/data/adb/tricky_store/target.txt"
CACHE_DIR="/data/adb/modules/auto_target/cache"
TEMP_FILE="/data/local/tmp/target_temp.txt"
mkdir -p $(dirname "$TARGET_FILE")
mkdir -p "$CACHE_DIR"
pm list packages -3 | cut -f2 -d: > "$TEMP_FILE"
if [ -f "$CACHE_DIR/custom_packages.list" ]; then
cat "$CACHE_DIR/custom_packages.list" >> "$TEMP_FILE"
fi
echo "com.android.vending" >> "$TEMP_FILE"
echo "com.google.android.gms" >> "$TEMP_FILE"
echo "com.google.android.gsf" >> "$TEMP_FILE"
sort -u "$TEMP_FILE" > "$TARGET_FILE"
rm "$TEMP_FILE"
