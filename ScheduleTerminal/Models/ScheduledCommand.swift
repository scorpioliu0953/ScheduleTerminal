import Foundation

struct ScheduledCommand: Identifiable, Codable, Equatable {
    let id: UUID
    var command: String
    var executeAt: Date
    var targetSessionIndex: Int // -1 = 目前分頁, 0+ = 指定分頁索引
    var isEnabled: Bool
    var repeatMode: RepeatMode
    var note: String

    enum RepeatMode: String, Codable, CaseIterable {
        case once = "once"
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"

        var displayName: String {
            switch self {
            case .once: return "單次"
            case .daily: return "每日"
            case .weekly: return "每週"
            case .monthly: return "每月"
            }
        }
    }

    init(
        id: UUID = UUID(),
        command: String,
        executeAt: Date,
        targetSessionIndex: Int = -1,
        isEnabled: Bool = true,
        repeatMode: RepeatMode = .once,
        note: String = ""
    ) {
        self.id = id
        self.command = command
        self.executeAt = executeAt
        self.targetSessionIndex = targetSessionIndex
        self.isEnabled = isEnabled
        self.repeatMode = repeatMode
        self.note = note
    }

    func nextOccurrence() -> Date {
        let calendar = Calendar.current
        switch repeatMode {
        case .once:
            return executeAt
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: executeAt) ?? executeAt
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: executeAt) ?? executeAt
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: executeAt) ?? executeAt
        }
    }
}
