#!/system/bin/sh
PACKAGE=$1
CACHE_DIR="/data/adb/modules/auto_target/cache"
if [ -z "$PACKAGE" ]; then
echo "Error: No package specified"
exit 1
fi
if ! pm path "$PACKAGE" >/dev/null 2>&1; then
echo "Error: Package $PACKAGE not found"
exit 1
fi
mkdir -p "$CACHE_DIR"
if grep -Fxq "$PACKAGE" "$CACHE_DIR/custom_packages.list" 2>/dev/null; then
echo "Package $PACKAGE already in custom list"
exit 0
fi
echo "$PACKAGE" >> "$CACHE_DIR/custom_packages.list"
echo "Added $PACKAGE to custom list"
