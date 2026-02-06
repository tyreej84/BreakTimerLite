# Break Timer Lite

A lightweight, synced break + pull timer addon for World of Warcraft.

**Break Timer Lite** is designed to feel like a polished, purpose-built timer utility: one person starts it, everyone with the addon sees the same timer, and it can trigger Blizzard’s built-in countdown text and a Ready Check — **without spamming group chat**.

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
- **Big break countdown (optional)**
  - Large center-screen countdown with last-seconds polish (pulse/shake/flash options)
- **Blizzard countdown at 10 seconds (break timer)**
  - At **10 seconds remaining**, the break timer triggers Blizzard’s built-in countdown text
- **Automatic Ready Check**
  - When the break completes, the addon **automatically starts a Ready Check**
  - Requires **Party Leader / Raid Leader / Raid Assistant**
  - Can be toggled on or off in the options
- **Late-join sync**
  - Players joining mid-break will automatically sync and see the correct remaining time
- **Conflict handling**
  - If multiple breaks are started, the timer from the **highest authority** wins

### Pull Timer

- **/pull countdown (synced)**
  - `/pull [seconds]` starts a pull countdown (defaults to **10 seconds**)
  - Shows **big on-screen numbers** locally for the pull timer (no chat)
  - Plays an alert at **10 seconds**, and again at **5, 4, 3, 2, 1**
  - When possible, also starts Blizzard’s built-in countdown text for the same duration
  - Synced via addon messages so everyone’s pull numbers align

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

### Pull Timer

`/pull [seconds]`

#### Examples

`/pull`  
Starts a 10-second pull countdown (default)

`/pull 8`  
Starts an 8-second pull countdown

> Note: While grouped, starting Blizzard’s built-in countdown requires leader/assist permissions, but the on-screen pull numbers are still shown locally and synced to other addon users.

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

### Pull Timer Options
- Enable/disable the **pull timer overlay**
- Adjust **pull number scale**
- Configure default `/pull` duration (seconds)
- Toggle alert at **10 seconds**
- Toggle alerts at **5 to 1**

---

## Moving the UI

- Hold **ALT** and drag the **timer bar** to reposition it
- Hold **ALT** and drag the **big break countdown** to reposition it
- Hold **ALT** and drag the **pull numbers** to reposition them

---

## Installation

1. Download or clone this repository
2. Copy the folder `BreakTimerLite` into:

`World of Warcraft/_retail_/Interface/AddOns/`

3. Restart WoW or run `/reload`

---

## Notes

- Blizzard’s countdown text and the **Ready Check** require:
  - Being in a party or raid
  - Having leader or assist permissions
- The addon’s notifications (banners, raid warning frame messages, big numbers) are **local-only** and **never** sent to group chat.

---

## License

This project is licensed under the **MIT License**.  
See `LICENSE.md` for details.
