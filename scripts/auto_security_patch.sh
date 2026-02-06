#!/system/bin/sh

#  Configuration & Constants

readonly CONFIG_PATH="/data/adb/tricky_store/security_patch.txt"
readonly PATCH_DAY="05"
readonly BACKDATE_MONTHS=1

# Timestamp generator
now() { date '+%F %H:%M:%S'; }

# Logger with levels
notify()  { echo "$(now) [PATCH-MGR] 📢 $1"; }
warn()    { echo "$(now) [PATCH-MGR] ⚠️  $1"; }
fatal()   { echo "$(now) [PATCH-MGR] 💥 $1"; exit 1; }
success() { echo "$(now) [PATCH-MGR] ✓  $1"; }

#  Date Calculation Engine

compute_prior_date() {
    local offset_months=$1
    local yr mo
    
    yr=$(date +%Y)  || fatal "Cannot extract year from system clock"
    mo=$(date +%m)  || fatal "Cannot extract month from system clock"
    
    # Strip leading zeros to avoid octal interpretation
    mo=$((10#$mo))
    
    local target_mo=$((mo - offset_months))
    local target_yr=$yr
    
    # Handle year rollover
    while [ $target_mo -le 0 ]; do
        target_mo=$((target_mo + 12))
        target_yr=$((target_yr - 1))
    done
    
    printf '%d-%02d-%s' "$target_yr" "$target_mo" "$PATCH_DAY"
}

#  File Operations

ensure_directory_exists() {
    local dir=$(dirname "$1")
    [ -d "$dir" ] && return 0
    mkdir -p "$dir" 2>/dev/null || fatal "Directory creation failed: $dir"
}

write_patch_manifest() {
    local output_file=$1
    local patch_value=$2
    
    # Atomic write using temp file
    local tmpfile="${output_file}.tmp.$$"
    
    {
        echo "system=prop"
        echo "boot=${patch_value}"
        echo "vendor=${patch_value}"
    } > "$tmpfile" || fatal "Cannot stage manifest to temp file"
    
    mv "$tmpfile" "$output_file" || fatal "Cannot commit manifest to final location"
}

#  Main Execution Flow

main() {
    notify "Patch manifest generator initialized"
    
    # Calculate target date (1 month prior)
    local target_date
    target_date=$(compute_prior_date $BACKDATE_MONTHS)
    notify "Computed rollback date: $target_date"
    
    # Prepare filesystem
    ensure_directory_exists "$CONFIG_PATH"
    
    # Generate manifest
    notify "Persisting configuration..."
    write_patch_manifest "$CONFIG_PATH" "$target_date"
    
    # Verify result
    [ -f "$CONFIG_PATH" ] && [ -s "$CONFIG_PATH" ] || fatal "Manifest validation failed"
    
    success "Security patch spoofing configured successfully"
    notify "Stored at: $CONFIG_PATH"
}

#  Entry Point
main "$@"
