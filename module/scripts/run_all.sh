#!/system/bin/sh
# run_all.sh - Run all root-hiding scripts + reset pixel props

MODDIR="/data/adb/modules/auto_target"
SCRIPTS="$MODDIR/scripts"

echo "========================================="
echo "  Quick Action - Root Hide"
echo "========================================="
echo ""

# 1. Security Patch
echo "[1/5] Running Security Patch..."
sh "$SCRIPTS/auto_security_patch.sh"
echo ""

# 2. Boot Hash
echo "[2/5] Running Boot Hash..."
sh "$SCRIPTS/auto_boot_hash.sh"
echo ""

# 3. Clear Detection Traces
echo "[3/5] Clearing Detection Traces..."
sh "$SCRIPTS/clear_all_detection_traces.sh"
echo ""

# 4. Fix TEE
echo "[4/5] Fixing TEE..."
sh "$SCRIPTS/auto_fix_broken_tee.sh"
echo ""

# 5. Reset pixel props
echo "[5/5] Resetting pixel props..."
sh "$SCRIPTS/reset_props.sh" "pixel"
echo ""

echo "========================================="
echo "[✓] Quick Action complete"
echo "========================================="
