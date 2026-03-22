#!/system/bin/sh
# run_all.sh - Run all root-hiding scripts + reset pixel props

MODDIR="/data/adb/modules/auto_target"
SCRIPTS="$MODDIR/scripts"

echo "========================================="
echo "  Quick Action - Root Hide"
echo "========================================="
echo ""

# 1. Security Patch
echo "[1/4] Running Security Patch..."
sh "$SCRIPTS/auto_security_patch.sh"
echo ""

# 2. Clear Detection Traces
echo "[2/4] Clearing Detection Traces..."
sh "$SCRIPTS/clear_all_detection_traces.sh"
echo ""

# 3. Fix TEE
echo "[3/4] Fixing TEE..."
sh "$SCRIPTS/auto_fix_broken_tee.sh"
echo ""

# 4. Reset pixel props
echo "[4/4] Resetting pixel props..."
sh "$SCRIPTS/reset_props.sh" "pixel"
echo ""

echo "========================================="
echo "[✓] Quick Action complete"
echo "========================================="
