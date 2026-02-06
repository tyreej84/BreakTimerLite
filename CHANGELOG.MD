# Changelog

All notable changes to **Break Timer Lite** are documented in this file.

---

## [1.2.5] - 2026-02-05
### Added
- Added **/pull [seconds]** (defaults to 10 seconds):
  - Shows big on-screen numbers locally (no chat).
  - Starts Blizzard countdown text when possible (leader/assist while grouped).
  - Plays a sound at **10** and again at **5, 4, 3, 2, 1**.
  - Syncs pull starts across the group via addon messages so everyone’s big numbers line up.

### Fixed
- Sound API compatibility: safer playback across clients using `C_Sound.PlaySound(params)` when required, with fallbacks.

---

## [1.2.4] - 2026-02-03
### Fixed
- Sound API compatibility: SafePlaySound() supports modern `C_Sound.PlaySound(params)` and safely falls back.

---

## [1.2.3] - 2026-02-01
### Fixed
- Prevented rare `db` nil errors when receiving sync messages before the addon finishes loading by initializing the database at the start of the synced timer path.
- Added extra safety guards for saved anchor points and bar label building.

### Changed
- Reworked the Options panel into a **two-column layout** so it no longer runs off-screen in the in-game Settings UI (no scrolling required).

---

## [1.2.2] - 2026-01-28
### Fixed
- Removed SendChatMessage shim (avoids taint / cross-addon issues)
- Robust DB init (db never nil; ns.GetDB always safe)
- Drag-stop guards rel:GetName() nil cases
- Forces legacy chat/reminder flags off (if present in saved vars)

---

## [1.2.1] - 2026-01-28
### Changed
- **Completely removed all chat output** (no PARTY/RAID/INSTANCE chat announcements at any time).
- Added a safety block to prevent legacy-style break reminder messages (e.g. `*** Break - 2:00 ***`) from being sent.

---

## [1.2.0] - 2026-01-28
### Fixed
- Perfectly aligned the on-bar countdown with Blizzard’s `/cd 10` display:
  - Countdown text uses `ceil(remaining)` so it flips exactly on integer boundaries.
  - The 10-second warning + Blizzard countdown now trigger when the display hits **10**, not early.

### Changed
- Removed group chat announcements for break reminders (visuals/sounds only).

---

## [1.1.9] - 2026-01-28
### Changed
- Removed all group chat announcements (no 2m/1m/30s/10s spam). Visuals/sounds only.

---

## [1.1.8] - 2026-01-28
### Fixed
- Restored full timer functionality after a bad update (ticker/UI updates and text objects were missing).
### Changed
- Timer bar text is now **simple white** (no outline, no shadow), rendered above the progress fill.

---

## [1.1.7] - 2026-01-28
### Changed
- Timer bar text styling adjustments (experimental).

---

## [1.1.6] - 2026-01-28
### Changed
- Timer bar text styling adjustments (experimental).

---

## [1.1.5] - 2026-01-28
### Changed
- Timer bar text outline experiment.

---

## [1.1.4] - 2026-01-28
### Changed
- Timer bar text styling experiment.

---

## [1.1.3] - 2026-01-28
### Changed
- Bar text now renders above the progress fill so it never disappears during countdown.

---

## [1.1.2] - 2026-01-28
### Added
- Blizzard **/cd-style countdown text** starts automatically at **10 seconds remaining**
- Countdown start is synchronized across the group (`CDREQUEST` / `COUNTDOWN`)
### Changed
- Removed the minimap button and all minimap-related options/settings

---

## [1.1.1] - 2026-01-28
### Changed
- Timer bar visual redesign (sleek translucent container, flat fill, edge indicator)

---

## [1.1.0] - 2026-01-28
### Changed
- Countdown behavior corrected to trigger at the 10-second mark
- Countdown cancellation improved when stopping early

---

## [1.0.9] - 2026-01-27
### Fixed
- Saved variable init timing and slash command registration reliability

---

## [1.0.8] - 2026-01-27
### Changed
- Removed all third-party addon references
- Standardized naming to **Break Timer Lite**

---

## [1.0.7] - 2026-01-27
### Added
- Extra aliases, default duration, status command, late-join sync, conflict handling, version handshake
- Screen-edge pulse, beeps, reminders, smart announce rules, optional ready check

---

## [1.0.6] - 2026-01-27
### Added
- Break extension commands and banners

---

## [1.0.5] - 2026-01-27
### Added
- Blizzard group countdown integration (initial implementation)

---

## [1.0.4] - 2026-01-27
### Added
- Large center countdown timer + urgency effects

---

## [1.0.2] - 2026-01-27
### Added
- In-game options panel

---

## [1.0.1] - 2026-01-27
### Added
- Leader/assist permission enforcement and always-on sync

---

## [1.0.0] - 2026-01-27
### Added
- Initial release
