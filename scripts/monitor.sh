#!/system/bin/sh
MODDIR=${0%/*}
CACHE_DIR="$MODDIR/cache"
CURRENT_FILE="/data/local/tmp/current_packages.txt"
mkdir -p "$CACHE_DIR"
mkdir -p $(dirname "$CURRENT_FILE")
sh $MODDIR/scripts/update_target.sh
while true; do
sleep 60
pm list packages -3 | cut -f2 -d: > "$CURRENT_FILE"
if ! cmp -s "$CACHE_DIR/packages.list" "$CURRENT_FILE"; then
sh $MODDIR/scripts/update_target.sh
cp "$CURRENT_FILE" "$CACHE_DIR/packages.list"
fi
done
