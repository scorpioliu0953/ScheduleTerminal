import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var sessions: [TerminalSession] = []
    @Published var activeSessionId: UUID?
    @Published var scheduler: CommandScheduler!
    @Published var showScheduleSheet = false
    @Published var showScheduleList = false

    @AppStorage("terminalFontSize") var fontSize: Double = 15.0

    private var sessionCounter = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        scheduler = CommandScheduler(appState: self)

        scheduler.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)

        restoreSessions()
        scheduler.loadCommands()
        scheduler.start()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc private func appWillTerminate() {
        saveSessions()
    }

    private func saveSessions() {
        let infos = sessions.map { session in
            SessionInfo(
                customTitle: session.customTitle,
                currentDirectory: session.currentDirectory
            )
        }
        if let data = try? JSONEncoder().encode(infos) {
            UserDefaults.standard.set(data, forKey: "savedSessions")
        }
    }

    private func restoreSessions() {
        guard let data = UserDefaults.standard.data(forKey: "savedSessions"),
              let infos = try? JSONDecoder().decode([SessionInfo].self, from: data),
              !infos.isEmpty else {
            addNewSession()
            return
        }

        for info in infos {
            sessionCounter += 1
            let session = TerminalSession()
            session.title = info.customTitle ?? "終端機 \(sessionCounter)"
            session.customTitle = info.customTitle
            session.initialDirectory = info.currentDirectory
            sessions.append(session)
        }
        activeSessionId = sessions.first?.id
    }

    func addNewSession() {
        sessionCounter += 1
        let session = TerminalSession()
        session.title = "終端機 \(sessionCounter)"
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

// MARK: - FocusedValue 讓選單指令能取得目前視窗的 AppState

struct AppStateFocusedKey: FocusedValueKey {
    typealias Value = AppState
}

extension FocusedValues {
    var appState: AppState? {
        get { self[AppStateFocusedKey.self] }
        set { self[AppStateFocusedKey.self] = newValue }
    }
}
