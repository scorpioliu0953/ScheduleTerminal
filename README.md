# Schedule Terminal

A native macOS terminal emulator with **scheduled command execution**.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Full Terminal Emulation** — Complete VT100/xterm terminal powered by [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)
- **Tab Support** — Multiple terminal sessions with tab management
- **Scheduled Commands** — Set a date/time to automatically execute commands
- **Repeat Schedules** — One-time, daily, weekly, or monthly repetition
- **Notifications** — System notifications when scheduled commands execute
- **Dark Theme** — Clean dark terminal interface with larger default font (15pt)
- **Native macOS** — Built with SwiftUI + AppKit for optimal performance

## Scheduled Command Feature

The key feature: schedule commands to run at specific times.

1. Press **Cmd+Shift+S** or click the clock icon to add a schedule
2. Enter the command to execute
3. Set the date and time
4. Choose which tab to send it to (or the active tab)
5. Optionally set it to repeat (daily / weekly / monthly)

The command will be typed into the terminal and submitted automatically at the scheduled time.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New Tab |
| `Cmd+W` | Close Tab |
| `Cmd+Shift+S` | New Scheduled Command |
| `Cmd+Shift+M` | Manage Schedules |
| `Cmd+Shift+]` | Next Tab |
| `Cmd+Shift+[` | Previous Tab |
| `Cmd+1~9` | Switch to Tab 1-9 |

## Installation

1. Download the latest **DMG** from [Releases](../../releases) or [Actions artifacts](../../actions)
2. Open the DMG file
3. Drag **Schedule Terminal** to your Applications folder
4. Launch from Applications

> **Note:** On first launch, macOS may show a security warning. Go to **System Settings > Privacy & Security** and click "Open Anyway".

## Build from Source

```bash
# Install XcodeGen
brew install xcodegen

# Clone and build
git clone https://github.com/scorpioliu0953/ScheduleTerminal.git
cd ScheduleTerminal
xcodegen generate
xcodebuild -project ScheduleTerminal.xcodeproj \
  -scheme ScheduleTerminal \
  -configuration Release
```

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac

## Tech Stack

- **SwiftUI** — App lifecycle and UI components
- **AppKit** — Terminal view management and integration
- **SwiftTerm** — VT100/xterm terminal emulation engine
- **UserNotifications** — Schedule execution alerts

---
*Last built: not yet*
