#!/system/bin/sh
# AutoTarget boot service with delayed start

MODDIR=${0%/*}

# Wait for system to fully boot and apps to be ready
sleep 30

# Start monitor in background
sh "$MODDIR/scripts/monitor.sh" &

log -t Auto_Target "Boot service started with 30s delay"
