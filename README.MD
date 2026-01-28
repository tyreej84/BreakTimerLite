# BreakTimerLite

A lightweight **DBM-style break timer** replacement for World of Warcraft.

## What it does
- **Synced timer** for the whole group (addon sync is always on)
- **Only leader/assist can start/stop/extend** while grouped
- **DBM-ish visuals**: bar + big center timer + banners + urgency effects
- Uses **Blizzard’s built-in countdown** (started at **10** seconds; Blizzard voice typically plays **5 → 1**)

## Commands (DBM-like)
Primary:
- `/break [minutes] [reason]`  
  - If no args: starts your **default duration**
- `/break +<minutes>` (extend)
- `/break extend <minutes>` (extend)
- `/break stop`
- `/break status`
- `/break options`

Aliases:
- `/breaktimer`
- `/breaktime`
- `/bt`

Examples:
- `/break` (starts default minutes)
- `/break 5 bio`
- `/break +5`
- `/break status`
- `/break stop`

## Sync behavior
### Always-on sync
If other players have BreakTimerLite installed, they’ll see the same:
- timer bar
- big center countdown
- extend/cancel/end

### Late-join sync
If someone joins while a break is already running, their addon will automatically request the current state and display it.

### Conflict resolution
If multiple timers collide:
- Higher authority wins (Raid Leader > Assist > Party Leader)
- If equal authority, the newer timer (timestamp) wins

### Version handshake
Players exchange versions automatically and you’ll see a warning if someone is running an older or incompatible major version.

## DBM-ish visuals
- Bar color shifts (green → yellow → red)
- **Spark** at the end of the bar
- **Glow** overlay in last 10 seconds
- Big timer pulse/shake/flash in the last seconds
- **Center banner**: start / extend / end / cancel
- Optional **screen-edge pulse** in the last 10 seconds

## Audio
- Blizzard countdown is triggered at 10 seconds on break start
- Optional extra built-in **beeps at 10/3/1**

## Optional ready check
Optionally triggers a ready check at the end of break (leader/assist only).

## Install
Copy this folder to:
`World of Warcraft/_retail_/Interface/AddOns/BreakTimerLite/`

Contains:
- `BreakTimerLite.toc`
- `Core.lua`
- `Options.lua`

Reload:
- `/reload`

## License
MIT — see `LICENSE.md`.
