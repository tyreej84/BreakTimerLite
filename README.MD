# Break Timer Lite

A lightweight, synced break timer addon for World of Warcraft.

**Break Timer Lite** is designed to feel like a polished, purpose-built timer utility: one person starts it, everyone with the addon sees the same timer, and it can trigger a Ready Check at the end.

---

## Features

### Addon Coverage Note

Break Timer Lite synchronizes party and raid breaks with **BigWigs and DBM**.

- Starting or stopping a break in any of these addons updates the others in the group, including boss addons running on the same client.
- Extending a break in Break Timer Lite updates the remaining duration in the boss addons.
- You do not need either boss addon installed to communicate with group members using them.
- Each player sees their own addon's display and warnings. Custom reasons and late-join state requests remain Break Timer Lite features; this does not add cross-addon late-join recovery.
- Keep using **`/break`** exactly as before, including reasons, extensions, cancellation, and your configured default duration. Compatibility messages are sent in addition to the existing Break Timer Lite messages.
- Break Timer Lite keeps its original duration and encounter behavior. Other addons apply their own limits (including a 1–60 minute range and encounter restrictions), so they may not display every timer that Break Timer Lite supports.
- Solo timers remain local to Break Timer Lite; cross-addon synchronization uses party/raid addon messages.

- **Synced timers** across the party/raid via addon communication
- **Leader/assist control**
  - In parties: **Party Leader** can start/extend/stop
  - In raids: **Raid Leader or Assistant** can start/extend/stop
- **Local notifications**
  - Screen banners, Raid Warning text, and sounds stay on the player’s client
- **Sleek timer bar**
  - Translucent black container with a blue progress fill
  - **White text** for maximum readability
- **Big break countdown (optional)**
  - Large center-screen countdown with last-seconds polish (pulse/shake/flash options)
- **Local-only final seconds (break timer)**
  - The break timer stays on the addon's own visuals and sounds at the end instead of triggering Blizzard's built-in `/cd` text
- **Automatic Ready Check**
  - When the break completes, the addon **automatically starts a Ready Check**
  - Requires **Party Leader / Raid Leader / Raid Assistant**
  - Can be toggled on or off in the options
- **Late-join sync**
  - Players joining mid-break will automatically sync and see the correct remaining time
- **Reload-safe break timer**
  - An active break is restored after `/reload` as long as it has not already expired
- **Group chat status query**
  - During an active break, anyone can type `!break` in party/raid/instance chat to get a time-left reply
- **Conflict handling**
  - Only group leaders/raid assistants can control synchronized breaks. Incoming boss-addon duration changes update the active break; duplicate broadcasts do not restart it.

---

## Commands

### Break Timer

**Primary command:**

`/break [minutes] [reason]`

#### Examples

`/break`  
Starts a break using the configured default duration (default: 5 minutes)

`/break 10`  
Starts a 10-minute break

`/break 7 bio`  
Starts a 7-minute break with the reason “bio”

#### Extend / Stop

`/break +2`  
Extends the current break by 2 minutes  
(or starts a 2-minute break if none is running)

`/break extend 3`  
Extends the current break by 3 minutes

`/break stop`  
Cancels the current break

#### Status / Options

`/break status`  
Prints the current break status (local only)

`/break options`  
Opens the addon options panel

#### Aliases

- `/breaktimer`
- `/breaktime`
- `/bt`

---

## Options

Open options via:

- **Esc → Options → AddOns → Break Timer Lite**
- Or via: `/break options`

Available options include:

### Break Timer Options
- Toggle **local Raid Warning** messages
- Toggle **warning sounds** and short beeps
- Toggle **automatic Ready Check on break completion**
- Adjust **bar width and height**
- Enable/disable **big break countdown** and adjust its scale
- Enable/disable **banner notifications**
- Configure default `/break` duration

---

## Moving the UI

- Hold **ALT** and drag the **timer bar** to reposition it
- Hold **ALT** and drag the **big break countdown** to reposition it

---

## Installation

1. Download or clone this repository
2. Copy the folder `BreakTimerLite` into:

`World of Warcraft/_retail_/Interface/AddOns/`

3. Restart WoW or run `/reload`

---

## Notes

- Automatic **Ready Check** at break end also requires the appropriate leader/assist permissions.
- The addon’s notifications (banners, raid warning frame messages, big numbers) are **local-only**.

---

## License

This project is licensed under the **MIT License**.  
See `LICENSE.md` for details.
