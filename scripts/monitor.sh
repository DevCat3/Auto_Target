#!/system/bin/sh
# AutoTarget - Background monitor with improved reliability

MODDIR=$(dirname "$(dirname "$0")")
CACHE_DIR="$MODDIR/cache"
CURRENT_FILE="/data/local/tmp/current_packages.txt"

mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$CURRENT_FILE")"

log -t Auto_Target "Monitor service started."

# Initialize cache if first run
if [ ! -f "$CACHE_DIR/packages.list" ]; then
    log -t Auto_Target "Initializing package cache..."
    pm list packages -3 | cut -f2 -d: > "$CACHE_DIR/packages.list"
fi

# Run update on start
sh "$MODDIR/scripts/update_target.sh"

while true; do
    sleep 60
    
    # Get current apps
    pm list packages -3 | cut -f2 -d: > "$CURRENT_FILE"
    
    # Compare with cache
    if ! cmp -s "$CACHE_DIR/packages.list" "$CURRENT_FILE"; then
        log -t Auto_Target "New apps detected! Updating target list..."
        
        # Run update (which will merge with existing cache)
        if sh "$MODDIR/scripts/update_target.sh"; then
            # Only update cache after successful target.txt update
            cp "$CURRENT_FILE" "$CACHE_DIR/packages.list"
            log -t Auto_Target "Target and cache updated successfully."
        else
            log -t Auto_Target "Error: Failed to update target.txt! Keeping old cache."
        fi
    fi
done
