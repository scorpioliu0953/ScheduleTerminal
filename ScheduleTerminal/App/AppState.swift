import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var sessions: [TerminalSession] = []
    @Published var activeSessionId: UUID?
    @Published var scheduler: CommandScheduler!

    @AppStorage("terminalFontSize") var fontSize: Double = 15.0

    private var sessionCounter = 0

    init() {
        scheduler = CommandScheduler(appState: self)
        addNewSession()
        scheduler.loadCommands()
        scheduler.start()
    }

    func addNewSession() {
        sessionCounter += 1
        let session = TerminalSession()
        session.title = "Terminal \(sessionCounter)"
        sessions.append(session)
        activeSessionId = session.id
    }

    func closeSession(_ id: UUID) {
        guard sessions.count > 1 else {
            NSApp.terminate(nil)
            return
        }

        if let index = sessions.firstIndex(where: { $0.id == id }) {
            let closedSession = sessions[index]
            sessions.remove(at: index)
            closedSession.terminate()

            if activeSessionId == id {
                let newIndex = min(index, sessions.count - 1)
                activeSessionId = sessions[newIndex].id
            }
        }
    }

    func selectNextTab() {
        guard let currentId = activeSessionId,
              let currentIndex = sessions.firstIndex(where: { $0.id == currentId }) else { return }
        let nextIndex = (currentIndex + 1) % sessions.count
        activeSessionId = sessions[nextIndex].id
    }

    func selectPreviousTab() {
        guard let currentId = activeSessionId,
              let currentIndex = sessions.firstIndex(where: { $0.id == currentId }) else { return }
        let prevIndex = (currentIndex - 1 + sessions.count) % sessions.count
        activeSessionId = sessions[prevIndex].id
    }

    func sessionForScheduledCommand(_ command: ScheduledCommand) -> TerminalSession? {
        if command.targetSessionIndex == -1 {
            return sessions.first { $0.id == activeSessionId }
        } else if command.targetSessionIndex >= 0 && command.targetSessionIndex < sessions.count {
            return sessions[command.targetSessionIndex]
        }
        return sessions.first { $0.id == activeSessionId }
    }
}
