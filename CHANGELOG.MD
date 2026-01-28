# Changelog

All notable changes to **Break Timer Lite** are documented here.

---

## [1.0.7] - 2026-01-27
### Added
- Additional slash command aliases: `/breaktime` and `/bt`
- Default duration support: `/break` with no arguments starts the configured default break length
- `/break status` command showing remaining time, reason, caller, and authority
- Late-join sync: players joining mid-break automatically receive the current timer
- Sync throttling to reduce addon message spam
- Conflict resolution for overlapping timers:
  - Higher authority wins
  - If authority is equal, newer timer wins
- Version handshake between group members with warnings for mismatched versions
- Enhanced timer bar visuals:
  - Spark indicator at the bar edge
  - Glow effect during the last 10 seconds
- Screen-edge pulse during the final 10 seconds
- Optional built-in beeps at 10, 3, and 1 seconds remaining
- Improved announcement formatting for clarity
- Optional ready check when the break ends (leader/assist only)
- Updated reminder cadence: 2:00, 1:00, 0:30, 0:10
- Smart announce rules to reduce chat spam for very short timers

### Changed
- Sync timing now uses server timestamps for improved accuracy
- Start/stop/extend sync messages now include authority and version data

### Fixed
- Improved recovery when a client misses the initial start but receives an extension

---

## [1.0.6] - 2026-01-27
### Added
- Break extension support:
  - `/break +<minutes>`
  - `/break extend <minutes>`
- Center-screen banner notifications for start, extend, end, and cancel
- Expanded minimap menu with quick extend options

---

## [1.0.5] - 2026-01-27
### Added
- Blizzard group countdown integration (triggered at 10 seconds)
- Best-effort cancellation of the Blizzard countdown when stopping a break

---

## [1.0.4] - 2026-01-27
### Added
- Large center countdown timer with configurable scale and positioning
- Visual urgency effects as the timer nears completion

---

## [1.0.3] - 2026-01-27
### Added
- Minimap button with quick access menu and tooltip

---

## [1.0.2] - 2026-01-27
### Added
- In-game options panel for configuring announcements and visuals

---

## [1.0.1] - 2026-01-27
### Added
- Leader and assist permission enforcement
- Always-on addon sync for group members

---

## [1.0.0] - 2026-01-27
### Added
- Initial release:
  - Synced break timer
  - Timer bar and group announcements
  - `/break <minutes> [reason]` and `/break stop`
