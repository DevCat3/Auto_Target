#!/system/bin/sh
CACHE_DIR="/data/adb/modules/auto_target/cache"
if [ -f "$CACHE_DIR/custom_packages.list" ] && [ -s "$CACHE_DIR/custom_packages.list" ]; then
cat "$CACHE_DIR/custom_packages.list"
else
echo "Custom list is empty"
fi
