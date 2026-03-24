import SwiftUI

@main
struct ScheduleTerminalApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 700, minHeight: 450)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 900, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新增分頁") {
                    appState.addNewSession()
                }
                .keyboardShortcut("t", modifiers: .command)

                Divider()

                Button("關閉分頁") {
                    if let id = appState.activeSessionId {
                        appState.closeSession(id)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }

            CommandMenu("排程") {
                Button("新增排程指令...") {
                    NotificationCenter.default.post(name: .showScheduleSheet, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Button("管理排程...") {
                    NotificationCenter.default.post(name: .showScheduleList, object: nil)
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])
            }

            CommandMenu("分頁") {
                Button("下一個分頁") {
                    appState.selectNextTab()
                }
                .keyboardShortcut("]", modifiers: [.command, .shift])

                Button("上一個分頁") {
                    appState.selectPreviousTab()
                }
                .keyboardShortcut("[", modifiers: [.command, .shift])

                Divider()

                ForEach(Array(appState.sessions.enumerated()), id: \.element.id) { index, session in
                    if index < 9 {
                        Button(session.title) {
                            appState.activeSessionId = session.id
                        }
                        .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                    }
                }
            }
        }

        Settings {
            PreferencesView()
                .environmentObject(appState)
        }
    }
}

extension Notification.Name {
    static let showScheduleSheet = Notification.Name("showScheduleSheet")
    static let showScheduleList = Notification.Name("showScheduleList")
}
