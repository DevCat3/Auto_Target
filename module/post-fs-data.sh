#!/system/bin/sh
# post-fs-data.sh — Early boot stage
# NOTE: props are NOT available here, su is NOT available here.
# Boot hash is handled in service.sh after system is fully loaded.

MODDIR=${0%/*}
