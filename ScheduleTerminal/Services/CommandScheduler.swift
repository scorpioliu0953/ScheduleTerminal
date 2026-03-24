import Foundation
import Combine
import UserNotifications

class CommandScheduler: ObservableObject {
    @Published var commands: [ScheduledCommand] = []
    @Published var executionLog: [String] = []

    private var timer: Timer?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        requestNotificationPermission()
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkSchedule()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func addCommand(_ command: ScheduledCommand) {
        commands.append(command)
        saveCommands()
    }

    func removeCommand(_ id: UUID) {
        commands.removeAll { $0.id == id }
        saveCommands()
    }

    func toggleCommand(_ id: UUID) {
        if let index = commands.firstIndex(where: { $0.id == id }) {
            commands[index].isEnabled.toggle()
            saveCommands()
        }
    }

    // MARK: - Schedule Check

    private func checkSchedule() {
        let now = Date()
        var modified = false

        for i in commands.indices {
            guard commands[i].isEnabled, commands[i].executeAt <= now else { continue }

            executeCommand(commands[i])

            if commands[i].repeatMode == .once {
                commands[i].isEnabled = false
            } else {
                commands[i].executeAt = commands[i].nextOccurrence()
            }
            modified = true
        }

        if modified {
            saveCommands()
        }
    }

    private func executeCommand(_ command: ScheduledCommand) {
        guard let appState = appState else { return }

        DispatchQueue.main.async {
            let session = appState.sessionForScheduledCommand(command)
            session?.sendCommand(command.command)

            let logEntry = "[\(Self.dateFormatter.string(from: Date()))] Executed: \(command.command)"
            self.executionLog.append(logEntry)

            // Keep log manageable
            if self.executionLog.count > 200 {
                self.executionLog.removeFirst(self.executionLog.count - 200)
            }

            self.sendNotification(command: command)
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func sendNotification(command: ScheduledCommand) {
        let content = UNMutableNotificationContent()
        content.title = "Scheduled Command Executed"
        content.body = command.command
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Persistence

    private static let fileURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("ScheduleTerminal")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("schedules.json")
    }()

    func loadCommands() {
        guard let data = try? Data(contentsOf: Self.fileURL),
              let decoded = try? JSONDecoder().decode([ScheduledCommand].self, from: data) else { return }
        commands = decoded
    }

    func saveCommands() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(commands) else { return }
        try? data.write(to: Self.fileURL, options: .atomic)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .medium
        return f
    }()
}
