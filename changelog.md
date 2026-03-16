# AutoTarget Changelog

## v3.3 (2026-03-16)
### 🖥️ WebUI Improvements
1. Added Fix TEE button wired to `auto_fix_broken_tee.sh`
2. Added Reset Props section with filter input, View Props and Reset Props buttons
3. Added Settings panel (slide-in from right) replacing the old theme toggle in the title bar
4. Moved Dark Mode toggle inside the Settings panel
5. Darkened button and text colors for better readability
6. Increased button font weight for clearer text
7. Removed blue focus outline on all interactive elements
8. Removed tap highlight on buttons and inputs for Android WebView
9. Added `will-change: transform` on buttons and settings panel for smoother animations
10. Fixed card background from semi-transparent `rgba` to solid color to prevent GPU layer glitch
11. Removed `backdrop-filter: blur()` from cards to fix theme-switch rendering glitch
12. Added `forceRepaint()` on theme change to flush stale GPU layers

---

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
