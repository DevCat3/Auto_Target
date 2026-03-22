# AutoTarget Changelog

## v3.6 (2026-03-22)

### WebUI
1. Added Stats card below title — shows Targeted / Blocked / Installed counts, auto-refreshes after any operation
2. Added Tools tab with Target.txt Editor, Backup & Restore, Custom Keybox, and Boot Logs sections
3. Apps tab toggle added to Settings — hidden by default
4. App list now cached in `localStorage` with 5-minute TTL — survives WebView restarts without reloading
5. Refresh button in Apps tab changed to a green rectangle labeled "Refresh"
6. Added Deselect Unnecessary button in Security Tools — removes launchers, keyboards, wallpapers, and other non-Attestation apps from target.txt
7. Tools tab simplified — each input field has a descriptive placeholder explaining what to enter
8. Tools tab has its own terminal output separate from the Main tab terminal
9. Fixed Stats card not updating — `runShell` now accepts `ignoreError` flag so zero-count results don't silently fail
10. Removed boot hash feature from the interface entirely

### Scripts
1. Added `get_stats.sh` — returns JSON with targeted/blocked/installed counts using cache for speed, always exits 0
2. Added `deselect_unnecessary.sh` — removes non-Attestation apps (launchers, keyboards, wallpapers, providers, etc.) from target.txt
3. Added `target_editor.sh` — reads or writes target.txt via base64 encoding for safe shell transfer
4. Added `backup_target.sh` — create/list/restore/delete timestamped target.txt snapshots in `backups/`
5. Added `keybox_manager.sh` — load keybox.xml from URL or file path, with backup and restore support
6. Added `boot_logger.sh` — saves diagnostic snapshot at every boot (device info, target count, interval, version), keeps last 5 logs
7. Removed `auto_boot_hash.sh` and all boot hash logic from `service.sh`, `post-fs-data.sh`, and `run_all.sh`
8. `post-fs-data.sh` is now empty — nothing runs at early boot stage
9. `run_all.sh` updated to 4 steps: Security Patch → Clear Traces → Fix TEE → Reset pixel props
10. `service.sh` now calls `boot_logger.sh` at boot when logging is enabled (default: on)

---

## v3.5 (2026-03-17)

### WebUI
1. Added Apps tab — browse all installed apps, toggle in/out of target.txt
2. Apps tab is hidden by default — enable it from Settings
3. App names fetched via `aapt` and displayed above package name
4. App list loads instantly from pre-built name cache (no blocking)
5. App list cached in `sessionStorage` — no reload on tab switch or panel re-open
6. Added manual refresh button (↻) in Apps tab to force reload
7. Added Quick Action card — runs all root-hide scripts + resets pixel props
8. Quick Action visibility controlled from Settings
9. Added Reset Props section with filter input, View Props and Reset Props buttons
10. Reset Props visibility controlled from Settings
11. Added Fix TEE button in Security Tools section
12. Fix TEE visibility controlled from Settings
13. Added Settings panel (slide-in from right) with all toggles
14. Moved Dark Mode toggle inside Settings panel
15. Added Monitor Interval setting in Settings (10–3600s)
16. Removed all emojis from the interface
17. Darkened colors and increased button font weight for better readability
18. Removed blue focus outline on all interactive elements
19. Removed tap highlight on buttons and inputs for Android WebView
20. Added `will-change: transform` on buttons and settings panel for smoother animations
21. Fixed GPU layer glitch on theme switch — removed `backdrop-filter` from cards
22. Added `forceRepaint()` on theme change to flush stale GPU layers
23. Fixed card background from semi-transparent `rgba` to solid color

### Scripts
1. Added `get_applist.sh` — instant output from `pm list packages` + name cache lookup
2. Added `build_applist.sh` — runs in background at boot, builds `appnames.cache` via `aapt` incrementally
3. Added `toggle_blocked.sh` — block/unblock packages, persisted in `cache/blocked_packages.list`
4. Added `set_monitor_interval.sh` — writes interval to `config/monitor_interval`
5. Added `run_all.sh` — runs Security Patch, Boot Hash, Clear Traces, Fix TEE, reset pixel props
6. Added `view_props.sh` / `reset_props.sh` — filter and reset system props by grep pattern
7. Fixed boot hash — moved from `post-fs-data.sh` to `service.sh` (runs after props are loaded)
8. Boot hash now reads directly from vbmeta block device for the real unmodified digest
9. `action.sh` now calls `run_all.sh` for Magisk action button
10. `update_target.sh` respects `blocked_packages.list` — blocked apps never re-added by monitor
11. Included `aapt` binaries for arm64 and armeabi architectures

---

## v3.2.1 (2026-03-16)
### WebUI
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
### Security Tools
- Added automatic security patch date spoofing (backdates by 1 month)
- Added vbmeta digest synchronization and persistence
- Added one-click cleanup for detector apps data, tool apps cache, system properties, and ODEX files
- New Security Tools section with 3 dedicated buttons

---

## v3.1 (2026-01-06)
### Bug Fixes
- Fixed critical data loss issue where `target.txt` would reset to only 3 Google apps after reboot
- Module now correctly preserves all user-installed applications across reboots
- `update_target.sh` now merges existing cache with current apps instead of overwriting

### Improvements
- Added intelligent cache merging to maintain historical app list
- Improved boot service reliability with proper delay timing
- Enhanced logging for better debugging experience

---

## v3.0 (2026-01-02)
### Features
- Initial release with automatic app detection
- Web UI for manual management
- Custom packages support
