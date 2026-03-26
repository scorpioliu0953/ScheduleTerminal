# Schedule Terminal

一款原生 macOS 終端機工具，支援**排程時間自動輸入指令**。

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Build](https://img.shields.io/github/actions/workflow/status/scorpioliu0953/ScheduleTerminal/build.yml?branch=main&label=%E5%BB%BA%E7%BD%AE)

## 功能特色

- **完整終端機模擬** — 基於 [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) 的 VT100/xterm 終端機
- **分頁頁籤** — 支援多個終端機分頁，可自由切換與關閉
- **頁籤狀態恢復** — 關閉 App 時自動記住所有頁籤，下次開啟自動恢復名稱與工作目錄
- **拖曳路徑切換** — 從 Finder 拖曳檔案或資料夾到終端機，自動 `cd` 到該路徑
- **排程自動輸入** — 設定指定時間，自動輸入指令並送出執行
- **重複排程** — 支援單次、每日、每週、每月重複執行
- **系統通知** — 排程指令執行時透過 macOS 通知提醒
- **深色主題** — 精緻暗色介面，預設較大字體（15pt）方便閱讀
- **原生 macOS** — 使用 SwiftUI + AppKit 打造，效能優異

## 排程指令功能

本工具的核心特色：在指定的時間自動輸入指令到終端機並執行。

1. 按下 **Cmd+Shift+S** 或點擊工具列上的時鐘圖示，新增排程
2. 輸入要執行的指令
3. 設定執行的日期與時間
4. 選擇要送到哪個分頁（或目前使用中的分頁）
5. 可選擇重複模式（每日 / 每週 / 每月）

到了指定時間，指令會自動輸入到終端機並按下 Enter 執行。

## 鍵盤快捷鍵

| 快捷鍵 | 功能 |
|--------|------|
| `Cmd+T` | 新增分頁 |
| `Cmd+W` | 關閉分頁 |
| `Cmd+Shift+S` | 新增排程指令 |
| `Cmd+Shift+M` | 管理排程列表 |
| `Cmd+Shift+]` | 切換到下一個分頁 |
| `Cmd+Shift+[` | 切換到上一個分頁 |
| `Cmd+1~9` | 切換到第 1~9 個分頁 |

## 安裝方式

1. 到 [Releases](../../releases) 頁面下載最新的 **DMG** 檔案
2. 開啟 DMG 檔案
3. 將 **Schedule Terminal** 拖曳到「應用程式」資料夾
4. 從「應用程式」中啟動

> **注意：** 首次啟動時，macOS 可能會顯示安全性警告。請前往「**系統設定 → 隱私權與安全性**」，點擊「強制打開」即可。

## 從原始碼建置

```bash
# 安裝 XcodeGen
brew install xcodegen

# 複製儲存庫並建置
git clone https://github.com/scorpioliu0953/ScheduleTerminal.git
cd ScheduleTerminal
xcodegen generate
xcodebuild -project ScheduleTerminal.xcodeproj \
  -scheme ScheduleTerminal \
  -configuration Release
```

## 系統需求

- macOS 13.0（Ventura）或更新版本
- Apple Silicon 或 Intel Mac

## 技術架構

- **SwiftUI** — 應用程式生命週期與 UI 元件
- **AppKit** — 終端機視圖管理與整合
- **SwiftTerm** — VT100/xterm 終端機模擬引擎
- **UserNotifications** — 排程執行通知

## 專案結構

```
ScheduleTerminal/
├── App/            → 應用程式入口與全域狀態管理
├── Models/         → TerminalSession、ScheduledCommand 資料模型
├── Views/          → SwiftUI 視圖（終端機容器、分頁列、排程面板等）
├── Services/       → CommandScheduler 排程服務（計時器 + JSON 持久化）
└── Assets.xcassets → 應用程式圖示與色彩資源
```

---
*最後建置時間：2026-03-26 10:39:43 UTC*
