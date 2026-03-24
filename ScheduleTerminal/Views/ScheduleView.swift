import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var command = ""
    @State private var selectedDate = Date().addingTimeInterval(60)
    @State private var targetTab = -1
    @State private var repeatMode: ScheduledCommand.RepeatMode = .once
    @State private var note = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "clock.badge.plus")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("New Scheduled Command")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // Form
            Form {
                Section("Command") {
                    TextField("Enter command to execute...", text: $command, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(2...5)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(nsColor: .textBackgroundColor))
                        )
                }

                Section("Schedule") {
                    DatePicker("Execute at:", selection: $selectedDate)
                        .datePickerStyle(.stepperField)

                    Picker("Repeat:", selection: $repeatMode) {
                        ForEach(ScheduledCommand.RepeatMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }

                Section("Target") {
                    Picker("Send to:", selection: $targetTab) {
                        Text("Active Tab").tag(-1)
                        ForEach(Array(appState.sessions.enumerated()), id: \.element.id) { index, session in
                            Text(session.title).tag(index)
                        }
                    }
                }

                Section("Note (optional)") {
                    TextField("Description or reminder...", text: $note)
                }
            }
            .formStyle(.grouped)

            Divider()

            // Actions
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Text(timeUntilExecution)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("Add Schedule") {
                    let scheduled = ScheduledCommand(
                        command: command.trimmingCharacters(in: .whitespacesAndNewlines),
                        executeAt: selectedDate,
                        targetSessionIndex: targetTab,
                        repeatMode: repeatMode,
                        note: note
                    )
                    appState.scheduler.addCommand(scheduled)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 480, height: 480)
    }

    private var timeUntilExecution: String {
        let interval = selectedDate.timeIntervalSinceNow
        if interval <= 0 {
            return "Will execute immediately"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return "in \(formatter.string(from: interval) ?? "")"
    }
}
