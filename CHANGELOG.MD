# Changelog

All notable changes to **Break Timer Lite** are documented in this file.

---

## [1.4.2] - 2026-04-21
### Changed
- While a break is active, new break starts are now always blocked for everyone (including leader/assist). Active breaks can only be extended or canceled.
- Updated local start rejection messaging to direct users to `/break +<minutes>` and `/break stop`.

### Fixed
- Removed remaining break-path Blizzard countdown cancellation hooks so break stop/cancel no longer interacts with `/cd` APIs.

## [1.4.1] - 2026-04-21
### Fixed
- Restored reliable group break sync for control actions by removing an over-aggressive local sync throttle that could drop `START`/`STOP`/`EXTEND`/`PULL` addon messages.
- Hardened sender authority resolution for synced `START`/`STATE`/`EXTEND`/`PULL` actions so valid leader/assist messages still apply when unit lookups are temporarily unavailable.

### Changed
- Removed the break timer's automatic final-10 warning countdown behavior (including the forced 10-second warning trigger and per-second end beeps), while keeping the shared break timer bar sync behavior.

## [1.4.0] - 2026-04-21
### Changed
- Updated Interface version to 120005 for Patch 12.0.5 compatibility.
- Verified no breaking changes from 12.0.5 API updates (secret unit token restrictions on `UnitName` do not affect party/raid unit enumeration used by this addon).

## [1.3.9] - 2026-04-08
### Fixed
- Fixed a runtime compatibility bug where `table.pack` was unavailable on some clients, causing addon sync initialization and message sends to error.
- Replaced `table.pack` usage in addon-message API wrappers with a local compatible result-packing helper so prefix registration and sync traffic work reliably across clients.

## [1.3.8] - 2026-04-04
### Fixed
- Improved existing-break visibility by having authorized clients proactively reply with current break `STATE` on both `HELLO` and `REQUEST`, so addon users joining late or recovering from missed broadcasts sync more reliably.
- Added a local authority guard that prevents lower-authority local starts from overriding an already-running higher-authority break, with a clear local warning when blocked.
- Preserved authoritative override behavior so higher-authority incoming starts/states still replace lower-authority timers.

## [1.3.7] - 2026-04-03
### Fixed
- Restored reliable group sync by reading the final API return value from `C_ChatInfo.SendAddonMessage*` and `RegisterAddonMessagePrefix` calls, fixing wrapper/multi-return compatibility.
- Ensured combat-lockdown detection uses the real addon-message result code so blocked sync payloads are queued and sent after combat as intended.

## [1.3.6] - 2026-04-02
### Fixed
- Deferred `!break` status replies requested during combat and automatically sent one reply after combat ends, avoiding restricted chat calls.
- Added combat-lockdown handling for addon sync sends (`AddOnMessageLockdown`) by queueing blocked payloads and flushing them after combat.
- Updated in-game options wording to match current behavior (no proactive chat spam, explicit `!break` replies only when allowed).

## [1.3.5] - 2026-04-01
### Fixed
- Hardened Blizzard API integration by validating modern addon-message return codes, sanitizing sync payloads, and using safer countdown/ready-check fallbacks.

## [1.3.4] - 2026-04-01
### Changed
- Removed the automatic Blizzard 10-second `/cd` countdown from break timers so the addon now relies only on its own built-in timer visuals/sounds at the end of a break.

## [1.3.3] - 2026-04-01
### Fixed
- Guarded Blizzard's group countdown API so a client-side `mgt.clearMarks is not a function` failure no longer throws from the addon; it now falls back to local visuals instead of repeatedly re-triggering the broken countdown path.

## [1.3.2] - 2026-03-31
### Fixed
- Stopped every assist-capable client from trying to fire the final 10-second Blizzard countdown during a break; only the player who started the break now initiates it, with the guarded sync fallback still preserved.

## [1.3.1] - 2026-03-30
### Fixed
- Prevented a follow-up secret-string taint compare fault in `!break` query detection by protecting the exact-match check with a guarded comparison path.

## [1.3.0] - 2026-03-29
### Fixed
- Prevented a secret-string taint error in `!break` chat query handling by adding a safe direct comparison path and protecting normalization against forbidden string conversions.

## [1.2.10] - 2026-03-25
### Changed
- `!break` replies are now restricted to a single responder: only the player who started the active break timer.

## [1.2.9] - 2026-03-25
### Changed
- `!break` status replies are no longer restricted to a single designated responder, so queries from the break starter are also answered reliably.

## [1.2.8] - 2026-03-25
### Fixed
- Hardened addon-message self-filtering to compare short names, preventing accidental processing of self-sent sync messages when sender names include realm suffixes.

## [1.2.7] - 2026-03-24
### Fixed
- Fixed a Lua taint/index error in `!break` query parsing by avoiding method-style calls on chat message values and normalizing with safe string APIs.

## [1.2.6] - 2026-03-18
### Fixed
- Active break timers now persist through `/reload` by saving the running break state and restoring it on addon load if it has not expired.
- Hardened saved-variable access paths against malformed data to prevent table-index Lua errors in core runtime and options.
- Added startup saved-variable self-healing that normalizes malformed values and shows one local repair notice when fixes were applied.

### Added
- Added `!break` group chat query support. While a break is active, typing `!break` in party/raid/instance chat posts the remaining time.

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
