# AutoTarget - Magisk Module

A Magisk module that automatically adds user-installed applications to TrickyStore's `target.txt` with a built-in web UI for management.

## Features

- Automatic Package Detection: Monitors and automatically adds newly installed user apps to TrickyStore target list
- Persistent Google Services: Always ensures core Google packages are included
- Custom Packages: Manually add specific packages that persist across updates
- Web UI: Terminal-style interface with dark/light mode support
- Real-time Monitoring: Background service checks for new apps every 60 seconds
- Multi-Root Support: Compatible with Magisk, KernelSU, and APatch
- Modern Manager Integration: Works with MMRL/Kitsune Mask

## Requirements

- Rooted device with Magisk (21.0+) / KernelSU / APatch
- TrickyStore module installed
- Android 8.0+ (API 26+)

## Installation

### Method 1: Magisk Manager

1. Download `auto_target.zip`
2. Open Magisk → Modules → Install from storage
3. Select the ZIP file
4. Reboot when complete

### Method 2: Command Line

```bash
adb push auto_target.zip /sdcard/
adb shell su -c "magisk --install-module /sdcard/auto_target.zip"
adb reboot
```

### Method 3: KernelSU/APatch

1. Open your root manager app
2. Navigate to Modules
3. Tap install and select the ZIP

# Usage

## Web UI

Open your root manager's module page and tap "AutoTarget" to launch the web interface.

Main Controls:
- Update Now: Immediately refresh target list with all user apps
- Clear List: Empty the target.txt file
- View List: Display current target.txt contents

Auto Monitor:
- Start Monitor: Begin background monitoring service
- Stop Monitor: Stop background monitoring

Custom Packages:
- Enter package name in input field (e.g., `com.example.app`)
- Add Custom: Add to permanent custom list
- Remove Custom: Remove from custom list
- View Custom: Show all manually added packages

Command Line

```bash
# Service control
su -c "/data/adb/modules/auto_target/action.sh enable"   # Start monitor
su -c "/data/adb/modules/auto_target/action.sh disable"  # Stop monitor

# Manual operations
su -c "sh /data/adb/modules/auto_target/scripts/update_target.sh"  # Update now
su -c "sh /data/adb/modules/auto_target/scripts/view_target.sh"    # View list
su -c "sh /data/adb/modules/auto_target/scripts/clear_target.sh"   # Clear list

# Custom packages
su -c "sh /data/adb/modules/auto_target/scripts/add_custom.sh com.example.app"
su -c "sh /data/adb/modules/auto_target/scripts/remove_custom.sh com.example.app"
su -c "sh /data/adb/modules/auto_target/scripts/list_custom.sh"
```

File Structure

```
auto_target/
├── META-INF/
│   └── com/google/android/
│       ├── update-binary
│       └── updater-script
├── action.sh                 # Monitor service control
├── common/
│   └── service.sh           # Boot service starter
├── module.prop              # Module metadata
├── scripts/
│   ├── add_custom.sh        # Add custom package
│   ├── clear_target.sh      # Clear target list
│   ├── list_custom.sh       # List custom packages
│   ├── monitor.sh          # Background monitoring
│   ├── remove_custom.sh    # Remove custom package
│   ├── update_target.sh    # Core update logic
│   └── view_target.sh      # View target list
├── uninstall.sh             # Cleanup script
└── webroot/
    ├── index.html          # Web UI
    ├── scripts.js          # Frontend logic
    └── styles.css          # Styling
```

Configuration

The module stores data in:

- Main target: `/data/adb/tricky_store/target.txt`
- Package cache: `/data/adb/modules/auto_target/cache/packages.list`
- Custom list: `/data/adb/modules/auto_target/cache/custom_packages.list`

Always Included Packages

- `com.android.vending` (Play Store)
- `com.google.android.gms` (Google Play Services)
- `com.google.android.gsf` (Google Services Framework)

Troubleshooting

Issue: Web UI not loading

Solution: Ensure your root manager supports web UI (Magisk 25.2+, KernelSU Manager, APatch)

Issue: Monitor not starting

Check status:

```bash
su -c "ps -ef | grep monitor.sh"
```

Manual start:

```bash
su -c "/data/adb/modules/auto_target/action.sh enable"
```

## Issue: Permission denied errors

Fix:

```bash
su -c "chmod -R 755 /data/adb/modules/auto_target/scripts"
su -c "chmod 755 /data/adb/modules/auto_target/action.sh"
```

Issue: Target file not updating

Verify:

```bash
su -c "ls -l /data/adb/tricky_store/target.txt"
su -c "cat /data/adb/tricky_store/target.txt"
```

## Building from Source

```bash
# Ensure correct structure
cd auto_target

# Create ZIP
zip -r9 auto_target.zip . -x "*.git*" "*.DS_Store" "*.zip"

# Or use recursive zip
zip -r9 ../auto_target.zip ../auto_target -x "*.git*" "*.DS_Store" "*.zip"
```

# License

MIT License - free to modify and distribute

# Credits

- DevCat3
- Shell Compatibility: Magisk/KernelSU/APatch APIs
- Font: Mona Sans monospace

## Support

For issues and feature requests, open an issue on GitHub.
or contact me on telegram @CatDev3
