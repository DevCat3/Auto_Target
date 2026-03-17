#!/system/bin/sh

echo "teeBroken=false" > /data/adb/tricky_store/tee_status

if [ ! -f "/data/adb/trick_store/keybox.xml" ]; then
    cp /data/adb/modules/auto_target/scripts/keybox.xml /data/adb/trick_store/
    echo "copying done"
else
    echo "skipped"
fi
