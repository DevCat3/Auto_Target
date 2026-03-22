# Auto Target

Automatically adds installed apps to TrickyStore `target.txt` with a full WebUI for management, root-hide tools, and smart monitoring.

[![Latest Release](https://img.shields.io/github/v/release/DevCat3/Auto-Target?label=Release&logo=github)](https://github.com/DevCat3/Auto-Target/releases/latest)

## Requirements

- [TrickyStore](https://github.com/5ec1cff/TrickyStore) module installed
- KernelSU / APatch / Magisk (25.2+)
- Android 10+ (API 29+)

## Installation

1. Download the latest ZIP from [Releases](https://github.com/DevCat3/Auto-Target/releases/latest)
2. Open your root manager → Modules → Install from storage
3. Select the ZIP and reboot

## Features

| Feature | Status |
| :--- | :---: |
| Auto-add all user-installed apps to target.txt on boot | ✅ |
| Smart monitor — detects installs/uninstalls at configurable interval | ✅ |
| Block specific apps from ever being added by the monitor | ✅ |
| Custom packages list — persistent across updates | ✅ |
| App Manager tab with display names (via aapt) | ✅ |
| Stats card — Targeted / Blocked / Installed counts | ✅ |
| Target.txt editor — view and edit directly from WebUI | ✅ |
| Backup & Restore — timestamped snapshots of target.txt | ✅ |
| Custom Keybox — load keybox.xml from URL or file path | ✅ |
| Deselect Unnecessary — remove apps that don't need Attestation | ✅ |
| Security Patch spoofing | ✅ |
| Clear all detection traces | ✅ |
| Fix TEE | ✅ |
| Reset system props by filter pattern | ✅ |
| Quick Action — runs all root-hide steps at once | ✅ |
| Boot diagnostics log (auto-saved on every boot) | ✅ |
| Dark / Light theme | ✅ |
| Configurable monitor refresh interval (10–3600s) | ✅ |

## WebUI

Open the WebUI from your root manager's module page.

### Main Tab

- **Update Now** — immediately rebuilds target.txt from all installed apps
- **Clear List** — empties target.txt
- **View List** — shows current target.txt content in the terminal
- **Start / Stop Monitor** — control the background monitor service
- **Custom Packages** — add or remove a specific package manually
- **Security Tools** — Security Patch, Clear Traces, Deselect Unnecessary, Fix TEE (optional)
- **Reset Props** — filter and reset system props by grep pattern (optional)
- **Quick Action** — runs all root-hide scripts + resets pixel props (optional)

### Tools Tab

- **Target.txt Editor** — load, edit, and save target.txt directly
- **Backup & Restore** — create timestamped backups, restore or delete them by filename
- **Custom Keybox** — paste a URL or file path to replace keybox.xml; backup and restore supported
- **Boot Logs** — list, read, or delete diagnostic logs saved at boot time

### Apps Tab *(enable from Settings)*

Displays all installed user apps with their display names.
Tap any app to toggle it in/out of target.txt.
Blocked apps are saved permanently — the monitor will never re-add them.
Use the **Refresh** button to reload the list manually.

### Settings Panel

| Setting | Default | Description |
| :--- | :---: | :--- |
| Dark Mode | off | Toggle light/dark theme |
| Quick Action | off | Show Run All button |
| Reset Props | off | Show Reset Props section |
| Fix TEE | off | Show Fix TEE button |
| Apps Tab | off | Show App Manager tab |
| Monitor Interval | 60s | How often to check for package changes (10–3600s) |
| Boot Log | on | Save diagnostics log on every boot |

## How It Works

1. At boot, `service.sh` waits 30 seconds then starts:
   - `build_applist.sh` in the background — builds app display name cache using `aapt`
   - `monitor.sh` in the background — watches for package changes at the configured interval
   - `boot_logger.sh` — saves a diagnostic snapshot to `logs/`

2. When a package change is detected, `update_target.sh` rebuilds target.txt:
   - Always includes core Google packages (`com.android.vending`, `com.google.android.gms`, `com.google.android.gsf`)
   - Skips any package in `cache/blocked_packages.list`
   - Merges custom packages from `cache/custom_packages.list`

3. The WebUI reads from cached files for instant load — no blocking shell calls on open.

## File Structure

```
module/
├── action.sh                         # Magisk action button → runs run_all.sh
├── service.sh                        # Boot service
├── post-fs-data.sh                   # Early boot (empty — nothing runs here)
├── bin/
│   ├── arm64-v8a/aapt
│   └── armeabi-v7a/aapt
├── scripts/
│   ├── update_target.sh              # Rebuild target.txt
│   ├── clear_target.sh               # Empty target.txt
│   ├── view_target.sh                # Print target.txt
│   ├── monitor.sh                    # Background package watcher
│   ├── build_applist.sh              # Build app name cache at boot
│   ├── get_applist.sh                # Fast read from cache for WebUI
│   ├── toggle_blocked.sh             # Block / unblock a package
│   ├── add_custom.sh                 # Add to custom list
│   ├── remove_custom.sh              # Remove from custom list
│   ├── list_custom.sh                # Show custom list
│   ├── run_all.sh                    # Run all root-hide steps
│   ├── auto_security_patch.sh        # Security patch spoofing
│   ├── clear_all_detection_traces.sh # Wipe detector app data/cache
│   ├── auto_fix_broken_tee.sh        # Fix TEE
│   ├── view_props.sh                 # List props by filter
│   ├── reset_props.sh                # Delete props by filter
│   ├── deselect_unnecessary.sh       # Remove non-Attestation apps from target
│   ├── target_editor.sh              # Read / write target.txt via WebUI
│   ├── backup_target.sh              # Create / restore / list / delete backups
│   ├── keybox_manager.sh             # Load / backup / restore keybox.xml
│   ├── get_stats.sh                  # Return JSON stats for WebUI header
│   ├── boot_logger.sh                # Save boot diagnostics log
│   └── set_monitor_interval.sh       # Write monitor interval to config
└── webroot/
    ├── index.html
    ├── scripts.js
    └── styles.css
```

## Data Paths

| Path | Description |
| :--- | :--- |
| `/data/adb/tricky_store/target.txt` | Main target file (TrickyStore reads this) |
| `/data/adb/tricky_store/keybox.xml` | Keybox file |
| `/data/adb/modules/auto_target/cache/packages.list` | Cached package list |
| `/data/adb/modules/auto_target/cache/custom_packages.list` | Persistent custom packages |
| `/data/adb/modules/auto_target/cache/blocked_packages.list` | Permanently blocked packages |
| `/data/adb/modules/auto_target/cache/appnames.cache` | App display name cache |
| `/data/adb/modules/auto_target/config/monitor_interval` | Monitor interval in seconds |
| `/data/adb/modules/auto_target/config/boot_log_enabled` | Boot log flag (1/0) |
| `/data/adb/modules/auto_target/backups/` | target.txt backups |
| `/data/adb/modules/auto_target/logs/` | Boot diagnostic logs |

## CLI Reference

```sh
MODDIR=/data/adb/modules/auto_target

# Core
su -c "sh $MODDIR/scripts/update_target.sh"
su -c "sh $MODDIR/scripts/view_target.sh"
su -c "sh $MODDIR/scripts/clear_target.sh"

# Custom packages
su -c "sh $MODDIR/scripts/add_custom.sh com.example.app"
su -c "sh $MODDIR/scripts/remove_custom.sh com.example.app"
su -c "sh $MODDIR/scripts/list_custom.sh"

# Block / unblock
su -c "sh $MODDIR/scripts/toggle_blocked.sh com.example.app 1"   # block
su -c "sh $MODDIR/scripts/toggle_blocked.sh com.example.app 0"   # unblock

# Security
su -c "sh $MODDIR/scripts/run_all.sh"
su -c "sh $MODDIR/scripts/auto_security_patch.sh"
su -c "sh $MODDIR/scripts/clear_all_detection_traces.sh"
su -c "sh $MODDIR/scripts/reset_props.sh 'pixel|pihook'"

# Backup & restore
su -c "sh $MODDIR/scripts/backup_target.sh create"
su -c "sh $MODDIR/scripts/backup_target.sh list"
su -c "sh $MODDIR/scripts/backup_target.sh restore target_20260101_120000.txt"

# Keybox
su -c "sh $MODDIR/scripts/keybox_manager.sh url https://example.com/keybox.xml"
su -c "sh $MODDIR/scripts/keybox_manager.sh file /sdcard/keybox.xml"
su -c "sh $MODDIR/scripts/keybox_manager.sh backup"
su -c "sh $MODDIR/scripts/keybox_manager.sh restore"

# Monitor interval
su -c "sh $MODDIR/scripts/set_monitor_interval.sh 120"
```

## Building

No build step required. The GitHub Actions workflow packages `module/` into a ZIP on every push to `main` and creates a GitHub Release automatically when `version` in `module.prop` changes.

```sh
cd module
zip -r ../Auto_Target-v3.6.zip . -x "*.DS_Store" -x "__MACOSX/*"
```

## License

GPL-3.0 — see [LICENSE](LICENSE)

## Credits

- **DevCat3** — author
- [KOWX712/Tricky-Addon-Update-Target-List](https://github.com/KOWX712/Tricky-Addon-Update-Target-List) — `aapt` binaries and WebUI inspiration
- [5ec1cff/TrickyStore](https://github.com/5ec1cff/TrickyStore) — the root of everything
- Font: Mona Sans (monospace)

## Support

Telegram: [@DevCatowa](https://t.me/DevCatowa)
