#!/system/bin/sh
# build_applist.sh — Build app name cache in background (called from service.sh)
# Writes pkg=Name lines to cache/appnames.cache ONE app at a time
# WebUI reads whatever is cached so far — no blocking

MODDIR=$(dirname "$(dirname "$0")")
ARCH=$(getprop ro.product.cpu.abi)
case "$ARCH" in
    arm64*) AAPT="$MODDIR/bin/arm64-v8a/aapt"  ;;
    *)      AAPT="$MODDIR/bin/armeabi-v7a/aapt" ;;
esac
chmod +x "$AAPT" 2>/dev/null

CACHE_DIR="$MODDIR/cache"
NAME_CACHE="$CACHE_DIR/appnames.cache"

mkdir -p "$CACHE_DIR"
touch "$NAME_CACHE" 2>/dev/null

pm list packages -3 2>/dev/null | cut -f2 -d: | while IFS= read -r PKG; do
    [ -z "$PKG" ] && continue

    # Skip if already cached
    grep -qm1 "^${PKG}=" "$NAME_CACHE" 2>/dev/null && continue

    APK=$(pm path "$PKG" 2>/dev/null | head -n1 | cut -d: -f2 | tr -d ' \r\n')
    [ -z "$APK" ] && continue

    NAME=$("$AAPT" dump badging "$APK" 2>/dev/null \
           | grep "^application-label:" | head -n1 \
           | sed "s/application-label://;s/'//g" | tr -d '\n')
    [ -z "$NAME" ] && continue  # skip — fallback handled in get_applist.sh

    NAME_SAFE=$(printf '%s' "$NAME" | sed 's/=/\\=/g')
    printf '%s=%s\n' "$PKG" "$NAME_SAFE" >> "$NAME_CACHE"
done

log -t Auto_Target "App name cache built"
