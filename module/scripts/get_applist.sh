#!/system/bin/sh
# get_applist.sh — Returns app list INSTANTLY from pm list packages
# Names come from cache if available, otherwise fallback to package name
# Never blocks waiting for aapt

MODDIR="/data/adb/modules/auto_target"
BLOCKED="$MODDIR/cache/blocked_packages.list"
NAME_CACHE="$MODDIR/cache/appnames.cache"  # format: pkg=Name per line

touch "$BLOCKED"    2>/dev/null
touch "$NAME_CACHE" 2>/dev/null

pm list packages -3 2>/dev/null | cut -f2 -d: | sort | while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue

    b=0
    grep -qxF "$pkg" "$BLOCKED" 2>/dev/null && b=1

    # Fast name lookup from cache only — no aapt here
    name=$(grep -m1 "^${pkg}=" "$NAME_CACHE" 2>/dev/null | cut -d= -f2-)
    [ -z "$name" ] && name="$pkg"

    name_safe=$(printf '%s' "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"p":"%s","n":"%s","b":%d}\n' "$pkg" "$name_safe" "$b"
done
