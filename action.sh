#!/system/bin/sh

echo "Updating security patch"
./$(pwd)/auto_security_patch.sh

echo "clearing all detections"
./$(pwd)/clear_all_detection_traces.sh

echo "Updating taget list"
./$(pwd)/update_target.sh
