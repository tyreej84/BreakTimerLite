# Break Timer Lite

A lightweight, synced break timer addon for World of Warcraft.

**Break Timer Lite** is designed to feel like a polished, purpose-built break timer: one person starts it, everyone with the addon sees the same timer, and it automatically triggers Blizzard’s built-in 10-second countdown text/sound at the end — without spamming group chat.

## Features

* **Synced timers** across the party/raid via addon communication
* **Leader/assist control**

  * In parties: **Party Leader** can start/extend/stop
  * In raids: **Raid Leader or Assistant** can start/extend/stop
* **No chat spam**

  * Break Timer Lite sends **no PARTY/RAID/INSTANCE chat messages** at any time
  * Notifications are **local-only** (screen banners / RaidWarning frame / sounds)
* **Sleek timer bar**

  * Translucent black bar with a blue countdown fill
  * **White text** for clear visibility at all times
* **Big countdown (optional)**

  * Large center-screen countdown with “last 10 seconds” polish
* **Blizzard countdown at 10 seconds**

  * At **10 seconds remaining**, the addon triggers Blizzard’s built-in countdown (`/cd 10`) so everyone sees the official countdown text
  * Also plays local warning sounds at 10 seconds and at timer end
* **Late-join sync**

  * Players who join mid-break will request state and see the correct remaining time
* **Conflict handling**

  * If multiple timers are started, the addon prefers the **higher-authority** starter (leader > assist > member), otherwise the newest start

## Commands

Primary command:

* `/break [minutes] [reason]`

Examples:

* `/break`
  Starts a break using the configured default duration (default: 5 minutes)

* `/break 10`
  Starts a 10-minute break

* `/break 7 bio`
  Starts a 7-minute break with the reason “bio”

Extend / stop:

* `/break +2`
  Extends the current break by 2 minutes (or starts a 2-minute break if none running)

* `/break extend 3`
  Extends the current break by 3 minutes

* `/break stop`
  Cancels the current break

Status / options:

* `/break status`
  Prints the current break status to your chat frame (local)

* `/break options`
  Opens the addon options panel

Aliases:

* `/breaktimer`
* `/breaktime`
* `/bt`

## Options

Open options via:

* **Esc → Options → AddOns → Break Timer Lite**
* Or: `/break options`

Available options include:

* Toggle **local Raid Warning** display
* Toggle **warning sounds** and short beeps
* Toggle **ready check on end** (leader/assist only)
* Adjust **bar width/height**
* Toggle **big countdown** + scale
* Toggle banner visuals
* Configure default `/break` minutes

### Moving the UI

* Hold **ALT** and drag the **timer bar** to reposition
* Hold **ALT** and drag the **big countdown** to reposition

## Installation

1. Download/clone this repository
2. Copy the folder `BreakTimerLite` into:

   * `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or run `/reload`

## Compatibility Notes

* **Blizzard countdown (/cd 10)** requires being in a group and requires **leader/assist** to trigger (Blizzard restriction).
* If someone in your group is running an older version of this addon, they may still produce chat spam on their client. Updating everyone removes that.

## License

This project is licensed under the MIT License — see `LICENSE.md`.
