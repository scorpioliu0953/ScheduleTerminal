import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    /// 若傳入，表示編輯模式
    var editingCommand: ScheduledCommand?

    @State private var command = ""
    @State private var selectedDate = Date().addingTimeInterval(60)
    @State private var targetTab = -1
    @State private var repeatMode: ScheduledCommand.RepeatMode = .once
    @State private var note = ""
    @State private var isEnabled = true

    private var isEditing: Bool { editingCommand != nil }

    var body: some View {
        VStack(spacing: 0) {
            // 標題
            HStack {
                Image(systemName: isEditing ? "pencil.circle" : "clock.badge.plus")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text(isEditing ? "編輯排程指令" : "新增排程指令")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            Form {
                Section("指令") {
                    TextField("輸入要執行的指令...", text: $command, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(2...5)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(nsColor: .textBackgroundColor))
                        )
                }

                Section("排程時間") {
                    DatePicker("執行時間：", selection: $selectedDate)
                        .datePickerStyle(.stepperField)

                    Picker("重複：", selection: $repeatMode) {
                        ForEach(ScheduledCommand.RepeatMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                }

                Section("目標") {
                    Picker("送到：", selection: $targetTab) {
                        Text("目前使用中的分頁").tag(-1)
                        ForEach(Array(appState.sessions.enumerated()), id: \.element.id) { index, session in
                            Text(session.title).tag(index)
                        }
                    }
                }

                Section("備註（選填）") {
                    TextField("描述或提醒...", text: $note)
                }

                if isEditing {
                    Section("狀態") {
                        Toggle("啟用排程", isOn: $isEnabled)
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Text(timeUntilExecution)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(isEditing ? "儲存" : "新增排程") {
                    if let editing = editingCommand {
                        appState.scheduler.updateCommand(
                            editing.id,
                            command: command.trimmingCharacters(in: .whitespacesAndNewlines),
                            executeAt: selectedDate,
                            targetSessionIndex: targetTab,
                            repeatMode: repeatMode,
                            note: note,
                            isEnabled: isEnabled
                        )
                    } else {
                        let scheduled = ScheduledCommand(
                            command: command.trimmingCharacters(in: .whitespacesAndNewlines),
                            executeAt: selectedDate,
                            targetSessionIndex: targetTab,
                            repeatMode: repeatMode,
                            note: note
                        )
                        appState.scheduler.addCommand(scheduled)
                    }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 480, height: isEditing ? 540 : 480)
        .onAppear {
            if let cmd = editingCommand {
                command = cmd.command
                selectedDate = cmd.executeAt
                targetTab = cmd.targetSessionIndex
                repeatMode = cmd.repeatMode
                note = cmd.note
                isEnabled = cmd.isEnabled
            }
        }
    }

    private var timeUntilExecution: String {
        let interval = selectedDate.timeIntervalSinceNow
        if interval <= 0 {
            return "將立即執行"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        if let str = formatter.string(from: interval) {
            return "\(str) 後執行"
        }
        return ""
    }
}
