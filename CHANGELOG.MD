# Changelog

All notable changes to **BreakTimerLite** will be documented in this file.

This project follows a simple versioned changelog format (not strict SemVer).

---

## [1.0.7] - 2026-01-27
### Added
- **More slash aliases**: `/breaktime` and `/bt` (in addition to `/break` and `/breaktimer`).
- **Default duration support**: `/break` with no arguments starts the configured default break length.
- **Status command**: `/break status` prints remaining time, reason, caller, and authority.
- **Late-join sync**: players joining mid-break automatically request and receive the current timer state.
- **Sync throttling** to reduce addon chat spam in raids/large groups.
- **Conflict resolution** for overlapping timers:
  - Prefer higher authority (Raid Leader > Assist > Party Leader)
  - If equal authority, prefer newer timer (server timestamp).
- **Version handshake** (HELLO exchange) with warnings for older/incompatible major versions.
- **DBM-ish bar polish**:
  - Bar **spark** at the bar edge
  - **Glow** effect during the last 10 seconds
- **Screen-edge pulse** (vignette) during the last 10 seconds.
- **Optional beeps** at **10 / 3 / 1** seconds remaining (built-in sounds; no packaged audio).
- **DBM-style chat formatting** for announcements (e.g. `*** Break (Bio) - 5:00 ***`).
- **Optional ready check** when the break ends (leader/assist only).
- **Reminder cadence updated** to DBM-ish timing: **2:00, 1:00, 0:30, 0:10**.
- **Smart announce rules** to avoid spam for very short timers (configurable threshold).

### Changed
- Sync payload now uses **server-time timestamps** for better cross-client accuracy.
- Start/stop/extend sync now includes authority/version metadata for safety and diagnostics.

### Fixed
- Improved robustness when a client misses a START but receives an EXTEND (falls back to requesting state).

---

## [1.0.6] - 2026-01-27
### Added
- **Extend support**:
  - `/break +<minutes>`
  - `/break extend <minutes>`
  - Extend events are synced to the group.
- **DBM-style center banner animation** on start/extend/end/cancel.
- Minimap menu enhancements:
  - Quick extend actions (+1/+2/+5)
  - Quick start durations

### Changed
- Improved big timer visuals (pulse/shake/flash behaviors tightened to last seconds).

---

## [1.0.5] - 2026-01-27
### Added
- **Blizzard countdown integration** (initiator triggers countdown at **10 seconds**).
- **Best-effort countdown cancel** when the break is stopped.

### Changed
- Messaging tuned closer to DBM tone (more consistent wording).

---

## [1.0.4] - 2026-01-27
### Added
- **Big center timer** (DBM-ish) with:
  - configurable scale
  - ALT-drag repositioning
  - last-seconds urgency effects (visual emphasis)

### Changed
- Improved bar color transitions (green → yellow → red).

---

## [1.0.3] - 2026-01-27
### Added
- **Minimap button** with tooltip and quick menu:
  - start common durations
  - stop break
  - open options

### Changed
- General UI polish (spacing/alignment for bar text).

---

## [1.0.2] - 2026-01-27
### Added
- **Options panel** (ESC → Options → AddOns → BreakTimerLite) with toggles for:
  - announcements
  - raid warning behavior (when possible)
  - basic visuals

### Changed
- Internal settings persistence (SavedVariables) stabilized.

---

## [1.0.1] - 2026-01-27
### Added
- **Leader/assist restrictions** enforced:
  - Party: leader only
  - Raid: leader + assist
- **Addon sync always enabled**:
  - group members with the addon see the same timer state.

### Changed
- Improved start/stop sync reliability and reduced redundant local prints.

---

## [1.0.0] - 2026-01-27
### Added
- Initial release:
  - DBM-style break timer with synced bar + timer logic
  - `/break <minutes> [reason]` and `/break stop`
  - Basic bar UI and group announcements
