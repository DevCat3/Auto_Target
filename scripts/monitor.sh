#!/system/bin/sh
# Fix: Set MODDIR to root of the module
MODDIR=$(dirname "$(dirname "$0")")
CACHE_DIR="$MODDIR/cache"
CURRENT_FILE="/data/local/tmp/current_packages.txt"

mkdir -p "$CACHE_DIR"
mkdir -p $(dirname "$CURRENT_FILE")

log -t Auto_Target "Monitor service started."

if [ ! -f "$CACHE_DIR/packages.list" ]; then
    log -t Auto_Target "Initializing package cache..."
    pm list packages -3 | cut -f2 -d: > "$CACHE_DIR/packages.list"
fi

sh $MODDIR/scripts/update_target.sh

while true; do
    sleep 60
    
    pm list packages -3 | cut -f2 -d: > "$CURRENT_FILE"
    
    if ! cmp -s "$CACHE_DIR/packages.list" "$CURRENT_FILE"; then
        log -t Auto_Target "New apps detected! Updating target list..."
        
        if sh "$MODDIR/scripts/update_target.sh"; then
            cp "$CURRENT_FILE" "$CACHE_DIR/packages.list"
            log -t Auto_Target "Target and Cache updated successfully."
        else
            log -t Auto_Target "Error: Failed to update target.txt! Keeping old cache."
        fi
    fi
done