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
                Button("New Tab") {
                    appState.addNewSession()
                }
                .keyboardShortcut("t", modifiers: .command)

                Divider()

                Button("Close Tab") {
                    if let id = appState.activeSessionId {
                        appState.closeSession(id)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }

            CommandMenu("Schedule") {
                Button("New Scheduled Command...") {
                    NotificationCenter.default.post(name: .showScheduleSheet, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Button("Manage Schedules...") {
                    NotificationCenter.default.post(name: .showScheduleList, object: nil)
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])
            }

            CommandMenu("Tab") {
                Button("Next Tab") {
                    appState.selectNextTab()
                }
                .keyboardShortcut("]", modifiers: [.command, .shift])

                Button("Previous Tab") {
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
