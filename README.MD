# Break Timer Lite

**Break Timer Lite** is a lightweight, fully synced break timer addon for World of Warcraft.

It provides a clear, authoritative break timer for groups and raids with strong visuals, synced state, and built-in Blizzard countdown support.

---

## What it does
- **Synced break timer** for the entire group (addon sync is always on)
- **Only leader/assist can start, stop, or extend** while grouped
- Clear **timer bar + large center countdown**
- Center-screen banners for start, extend, end, and cancel
- Uses **Blizzard’s built-in countdown**, started at **10 seconds**
  - Blizzard audio typically plays from **5 → 1**

---

## Commands

Primary:
- `/break [minutes] [reason]`
  - If no arguments are provided, starts the configured default duration
- `/break +<minutes>` — extend the current break
- `/break extend <minutes>` — extend the current break
- `/break stop` — cancel the break
- `/break status` — show remaining time and caller
- `/break options` — open settings

Aliases:
- `/breaktimer`
- `/breaktime`
- `/bt`

Examples:
- `/break`
- `/break 5 bio`
- `/break +5`
- `/break status`
- `/break stop`

---

## Sync behavior

### Always-on sync
All players with Break Timer Lite installed will see the same:
- Timer bar
- Center countdown
- Extensions and cancellations

### Late join support
Players who join while a break is already running will automatically request and receive the current break state.

### Authority rules
- **Party:** Party Leader only
- **Raid:** Raid Leader and Assist
- **Solo:** Always allowed

### Conflict handling
If multiple break timers collide:
- Higher authority wins
- If authority is equal, the newer timer (server timestamp) wins

---

## Visual features
- Color-changing timer bar (green → yellow → red)
- Spark and glow effects as the timer nears completion
- Large center countdown with:
  - Pulse during the last 10 seconds
  - Shake and flash effects in the final seconds
- Screen-edge pulse during the last 10 seconds
- Center banner messages for:
  - Break started
  - Break extended
  - Break ended
  - Break canceled

---

## Audio
- Blizzard group countdown is triggered at 10 seconds
- Optional built-in beeps at **10 / 3 / 1** seconds
- No custom sound files required

---

## Optional ready check
If enabled, a ready check is automatically triggered when the break ends (leader/assist only).

---

## Installation
Copy the addon folder to:

The folder should contain:
- `BreakTimerLite.toc`
- `Core.lua`
- `Options.lua`

Reload your UI:
- `/reload`

---

## License
MIT — see `LICENSE.md`
