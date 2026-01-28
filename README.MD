# Break Timer Lite

A lightweight, synced break timer addon for World of Warcraft.

**Break Timer Lite** is designed to feel like a polished, purpose-built break timer: one person starts it, everyone with the addon sees the same timer, and it automatically triggers Blizzard’s built-in 10-second countdown **and a Ready Check** at the end — without spamming group chat.

---

## Features

- **Synced timers** across the party/raid via addon communication
- **Leader/assist control**
  - In parties: **Party Leader** can start/extend/stop
  - In raids: **Raid Leader or Assistant** can start/extend/stop
- **No chat spam**
  - Break Timer Lite sends **no PARTY / RAID / INSTANCE chat messages**
  - All notifications are **local-only** (screen banners, Raid Warning frame, sounds)
- **Sleek timer bar**
  - Translucent black container with a blue progress fill
  - **White text** for maximum readability
- **Big countdown (optional)**
  - Large center-screen countdown with last-seconds polish
- **Blizzard countdown at 10 seconds**
  - At **10 seconds remaining**, the addon triggers Blizzard’s built-in countdown (`/cd 10`)
- **Automatic Ready Check**
  - When the break completes, the addon **automatically starts a Ready Check**
  - Requires **Party Leader / Raid Leader / Raid Assistant**
  - Can be toggled on or off in the options
- **Late-join sync**
  - Players joining mid-break will automatically sync and see the correct remaining time
- **Conflict handling**
  - If multiple breaks are started, the timer from the **highest authority** wins

---

## Commands

**Primary command:**

/break [minutes] [reason]

### Examples

/break  
Starts a break using the configured default duration (default: 5 minutes)

/break 10  
Starts a 10-minute break

/break 7 bio  
Starts a 7-minute break with the reason “bio”

### Extend / Stop

/break +2  
Extends the current break by 2 minutes  
(or starts a 2-minute break if none is running)

/break extend 3  
Extends the current break by 3 minutes

/break stop  
Cancels the current break

### Status / Options

/break status  
Prints the current break status (local only)

/break options  
Opens the addon options panel

### Aliases

- /breaktimer
- /breaktime
- /bt

---

## Options

Open options via:

- **Esc → Options → AddOns → Break Timer Lite**
- Or via: `/break options`

Available options include:

- Toggle **local Raid Warning** messages
- Toggle **warning sounds** and short beeps
- Toggle **automatic Ready Check on break completion**
- Adjust **bar width and height**
- Enable/disable **big countdown** and adjust its scale
- Enable/disable **banner notifications**
- Configure default `/break` duration

---

## Moving the UI

- Hold **ALT** and drag the **timer bar** to reposition it
- Hold **ALT** and drag the **big countdown** to reposition it

---

## Installation

1. Download or clone this repository
2. Copy the folder `BreakTimerLite` into:

World of Warcraft/_retail_/Interface/AddOns/

3. Restart WoW or run `/reload`

---

## Notes

- Blizzard’s countdown text (`/cd 10`) and the **Ready Check** both require:
  - Being in a party or raid
  - Having leader or assist permissions

---

## License

This project is licensed under the **MIT License**.  
See `LICENSE.md` for details.
