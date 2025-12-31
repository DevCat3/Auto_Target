#!/system/bin/sh
MODDIR=${0%/*}
SERVICE_PID=$(ps -ef | grep "$MODDIR/scripts/monitor.sh" | grep -v grep | awk '{print $2}')
case "$1" in
enable)
if [ -z "$SERVICE_PID" ]; then
sh $MODDIR/scripts/monitor.sh &
echo "Monitoring started"
else
echo "Monitoring already running"
fi
;;
disable)
if [ -n "$SERVICE_PID" ]; then
kill $SERVICE_PID
echo "Monitoring stopped"
else
echo "Monitoring not running"
fi
;;
*)
echo "Usage: $0 [enable|disable]"
exit 1
;;
esac
