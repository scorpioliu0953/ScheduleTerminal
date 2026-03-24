# Schedule Terminal

A native macOS terminal emulator with **scheduled command execution**.

## Features

- Full Terminal Emulation (VT100/xterm via SwiftTerm)
- Tab Support (Cmd+T / Cmd+W)
- Scheduled Commands — auto-type and execute at set times
- Repeat Schedules (daily / weekly / monthly)
- System Notifications on execution
- Dark Theme with larger default font
- Native macOS (SwiftUI + AppKit)

## Build

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project ScheduleTerminal.xcodeproj -scheme ScheduleTerminal -configuration Release
```

---
*README will be auto-updated by CI on each build.*
