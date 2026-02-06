# AutoTarget Changelog

## v3.2 (2026-02-06)
### 🔒 Security Tools
- **Auto Security Patch**: Added automatic security patch date spoofing (backdates by 1 month)
- **Boot Hash Sync**: Added vbmeta digest synchronization and persistence
- **Clear Detection Traces**: One-click cleanup for detector apps data, tool apps cache, system properties, and ODEX files
- **Web UI Integration**: New "🔒 Security Tools" section with 3 dedicated buttons

---

## v3.1 (2026-01-06)
### 🐛 Bug Fixes
- **Fixed critical data loss issue**: Resolved problem where `target.txt` would reset to only 3 Google apps after device reboot
- **Persistent app tracking**: Module now correctly preserves all user-installed applications across reboots
- **Enhanced cache system**: `update_target.sh` now merges existing cache with current apps instead of overwriting

### 🔧 Improvements
- Added intelligent cache merging to maintain historical app list
- Improved boot service reliability with proper delay timing
- Enhanced logging for better debugging experience

---

## v3.0 (2026-01-02)
### Features
- Initial release with automatic app detection
- Web UI for manual management
- Custom packages support
