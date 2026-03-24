import SwiftUI

struct ScheduleListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddSheet = false

    private var scheduler: CommandScheduler { appState.scheduler }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Scheduled Commands")
                    .font(.headline)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .help("Add new scheduled command")
            }
            .padding()

            Divider()

            // Content
            if scheduler.commands.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Scheduled Commands")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Click + to add a scheduled command")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(scheduler.commands) { cmd in
                        ScheduleRowView(command: cmd)
                    }
                    .onDelete { indexSet in
                        let idsToRemove = indexSet.map { scheduler.commands[$0].id }
                        for id in idsToRemove {
                            scheduler.removeCommand(id)
                        }
                    }
                }
            }

            // Execution log
            if !scheduler.executionLog.isEmpty {
                Divider()
                DisclosureGroup("Execution Log") {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(scheduler.executionLog.reversed(), id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 100)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            Divider()

            // Footer
            HStack {
                let activeCount = scheduler.commands.filter { $0.isEnabled }.count
                Text("\(activeCount) active, \(scheduler.commands.count) total")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 560, height: 520)
        .sheet(isPresented: $showAddSheet) {
            ScheduleView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Schedule Row

struct ScheduleRowView: View {
    let command: ScheduledCommand
    @EnvironmentObject var appState: AppState

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                // Command
                Text(command.command)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)

                // Metadata
                HStack(spacing: 10) {
                    Label(Self.dateFormatter.string(from: command.executeAt), systemImage: "clock")
                    Label(command.repeatMode.rawValue, systemImage: "repeat")

                    if command.targetSessionIndex == -1 {
                        Label("Active Tab", systemImage: "terminal")
                    } else {
                        Label("Tab \(command.targetSessionIndex + 1)", systemImage: "terminal")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                // Note
                if !command.note.isEmpty {
                    Text(command.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            // Enable/Disable toggle
            Toggle("", isOn: Binding(
                get: { command.isEnabled },
                set: { _ in appState.scheduler.toggleCommand(command.id) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .padding(.vertical, 4)
        .opacity(command.isEnabled ? 1.0 : 0.5)
    }
}
