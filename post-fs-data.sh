#!/system/bin/sh

# Configuration
readonly HASH_FILE="/data/adb/boot_hash"
readonly DEFAULT_HASH="0000000000000000000000000000000000000000000000000000000000000000"
readonly PROP_NAME="ro.boot.vbmeta.digest"

# Logge
timestamp() { date '+%F %H:%M:%S'; }

info()  { echo "$(timestamp) [BOOT-HASH] ℹ️  $1"; }
error() { echo "$(timestamp) [BOOT-HASH] ❌ $1"; }
success() { echo "$(timestamp) [BOOT-HASH] ✅ $1"; }

# Core Functions 
fetch_vbmeta_hash() {
    local hash
    hash=$(su -c "getprop $PROP_NAME" 2>/dev/null)
    printf '%s' "${hash:-$DEFAULT_HASH}"
}

persist_hash() {
    local hash="$1"
    local dir=$(dirname "$HASH_FILE")
    
    # Ensure directory exists
    [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null || {
        error "Failed to create directory: $dir"
        return 1
    }
    
    # Write hash atomically
    printf '%s' "$hash" > "$HASH_FILE.tmp" && \
    mv "$HASH_FILE.tmp" "$HASH_FILE" && \
    chmod 644 "$HASH_FILE"
}

update_system_property() {
    local hash="$1"
    su -c "resetprop -n $PROP_NAME '$hash'" >/dev/null 2>&1
}

# Main
main() {
    info "Initializing boot hash synchronization..."
    
    # Retrieve hash
    local current_hash
    current_hash=$(fetch_vbmeta_hash)
    info "Retrieved vbmeta digest: ${current_hash:0:16}..."
    
    # Persist to file
    if persist_hash "$current_hash"; then
        success "Hash persisted to $HASH_FILE"
    else
        error "Failed to persist hash"
        exit 1
    fi
    
    # Update property
    update_system_property "$current_hash"
    success "System property updated"
    
    info "Operation completed successfully"
}

# Execute
main "$@"
