import SwiftUI

@main
struct ScheduleTerminalApp: App {
    @FocusedValue(\.appState) var focusedAppState

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 450)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 900, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新增視窗") {
                    NSApp.sendAction(NSSelectorFromString("newDocument:"), to: nil, from: nil)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("新增分頁") {
                    focusedAppState?.addNewSession()
                }
                .keyboardShortcut("t", modifiers: .command)

                Divider()

                Button("關閉分頁") {
                    if let id = focusedAppState?.activeSessionId {
                        focusedAppState?.closeSession(id)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }

            CommandMenu("排程") {
                Button("新增排程指令...") {
                    focusedAppState?.showScheduleSheet = true
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Button("管理排程...") {
                    focusedAppState?.showScheduleList = true
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])
            }

            CommandMenu("分頁") {
                Button("下一個分頁") {
                    focusedAppState?.selectNextTab()
                }
                .keyboardShortcut("]", modifiers: [.command, .shift])

                Button("上一個分頁") {
                    focusedAppState?.selectPreviousTab()
                }
                .keyboardShortcut("[", modifiers: [.command, .shift])

                Divider()

                if let sessions = focusedAppState?.sessions {
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                        if index < 9 {
                            Button(session.displayTitle) {
                                focusedAppState?.activeSessionId = session.id
                            }
                            .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                        }
                    }
                }
            }
        }

        Settings {
            PreferencesView()
        }
    }
}
