#!/system/bin/sh
# deselect_unnecessary.sh — Remove apps that don't need Attestation from target.txt

TARGET="/data/adb/tricky_store/target.txt"

[ -f "$TARGET" ] || { echo "[!] target.txt not found"; exit 1; }

# Categories that don't need Play Integrity / Attestation
EXCLUDE_PATTERNS='
com\.android\.launcher
com\.google\.android\.launcher
com\.sec\.android\.app\.launcher
com\.miui\.home
com\.huawei\.android\.launcher
com\.oppo\.launcher
com\.bbk\.launcher
\.launcher[23]?$
\.launcher\..
com\.android\.inputmethod
com\.google\.android\.inputmethod
com\.samsung\.android\.honeyboard
com\.swiftkey
com\.touchtype\.swiftkey
com\.nuance\.swype
com\.google\.android\.tts
com\.samsung\.android\.tts
com\.android\.wallpaper
com\.google\.android\.wallpaper
com\.samsung\.android\.app\.wallpaper
\.wallpaper\.
com\.android\.systemui
com\.samsung\.android\.systemui
com\.android\.settings
com\.google\.android\.packageinstaller
com\.android\.packageinstaller
com\.android\.vending\.billing
com\.android\.bluetooth
com\.android\.nfc
com\.google\.android\.gms\.location
com\.google\.android\.gsf\.login
com\.android\.providers\.
com\.android\.externalstorage
com\.android\.mtp
\.test$
\.debug$
\.beta$
'

BEFORE=$(wc -l < "$TARGET")
REMOVED=0

TMPFILE=$(mktemp)
cp "$TARGET" "$TMPFILE"

echo "$EXCLUDE_PATTERNS" | grep -v '^$' | while IFS= read -r pattern; do
    grep -Ev "$pattern" "$TMPFILE" > "$TMPFILE.new" && mv "$TMPFILE.new" "$TMPFILE"
done

AFTER=$(wc -l < "$TMPFILE")
REMOVED=$((BEFORE - AFTER))

cp "$TMPFILE" "$TARGET"
rm -f "$TMPFILE"

echo "[+] Removed $REMOVED unnecessary apps from target.txt"
echo "[*] Remaining: $AFTER packages"
