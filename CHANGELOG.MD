# Changelog

All notable changes to **Break Timer Lite** are documented in this file.

---

## [1.1.1] - 2026-01-28
### Changed
- **Timer bar visual redesign**:
  - Replaced classic-style status bar texture with a **sleek flat fill**
  - Bar is now a **thicker translucent black container** with a subtle border
  - Inner progress fill uses a **modern flat blue color**
  - Added a **thin leading-edge line** to indicate remaining progress
- Improved overall visual clarity to better match modern UI expectations

### Fixed
- Resolved issue where the bar appeared overly thin and green by default

---

## [1.1.0] - 2026-01-28
### Changed
- **Blizzard countdown behavior corrected**:
  - Blizzard’s built-in countdown now starts **when the break reaches 10 seconds remaining**
  - Countdown is only triggered once per break by the authoritative caller
- Countdown cancellation now occurs correctly when a break is stopped early

---

## [1.0.9] - 2026-01-27
### Fixed
- Fixed an addon load error caused by accessing saved variables before initialization
- Slash commands (`/break`, `/bt`, etc.) now register reliably on login and reload

---

## [1.0.8] - 2026-01-27
### Changed
- Removed all third-party addon references
- Standardized naming across all files to **Break Timer Lite**

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
- Enhanced timer bar effects:
  - Glow effect during the final 10 seconds
- Screen-edge pulse during the final 10 seconds
- Optional built-in beeps at 10, 3, and 1 seconds remaining
- Improved announcement formatting
- Optional ready check when the break ends (leader/assist only)
- Updated reminder cadence: 2:00, 1:00, 0:30, 0:10
- Smart announce rules to reduce chat spam for short timers

---

## [1.0.6] - 2026-01-27
### Added
- Break extension support:
  - `/break +<minutes>`
  - `/break extend <minutes>`
- Center-screen banners for break start, extension, end, and cancellation
- Expanded minimap menu with quick extend options

---

## [1.0.5] - 2026-01-27
### Added
- Blizzard group countdown integration

---

## [1.0.4] - 2026-01-27
### Added
- Large center countdown timer with configurable scale and position
- Visual urgency effects as the timer nears completion

---

## [1.0.3] - 2026-01-27
### Added
- Minimap button with quick-access menu and tooltip

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
  - Progress bar and group announcements
  - `/break <minutes> [reason]` and `/break stop`
