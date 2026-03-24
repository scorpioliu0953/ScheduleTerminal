import SwiftUI

struct ScheduleListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddSheet = false
    @State private var editingCommand: ScheduledCommand?
    @State private var commandToDelete: ScheduledCommand?

    private var scheduler: CommandScheduler { appState.scheduler }

    var body: some View {
        VStack(spacing: 0) {
            // 標題
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("排程指令列表")
                    .font(.headline)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .help("新增排程指令")
            }
            .padding()

            Divider()

            // 內容
            if scheduler.commands.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("尚無排程指令")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("點擊 + 新增排程指令")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(scheduler.commands) { cmd in
                        ScheduleRowView(
                            command: cmd,
                            onEdit: { editingCommand = cmd },
                            onDelete: { commandToDelete = cmd }
                        )
                    }
                }
            }

            // 執行紀錄
            if !scheduler.executionLog.isEmpty {
                Divider()
                DisclosureGroup("執行紀錄") {
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

            // 底部
            HStack {
                let activeCount = scheduler.commands.filter { $0.isEnabled }.count
                Text("\(activeCount) 個啟用中，共 \(scheduler.commands.count) 個排程")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("完成") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 580, height: 540)
        .sheet(isPresented: $showAddSheet) {
            ScheduleView()
                .environmentObject(appState)
        }
        .sheet(item: $editingCommand) { cmd in
            ScheduleView(editingCommand: cmd)
                .environmentObject(appState)
        }
        .alert("確認刪除", isPresented: Binding(
            get: { commandToDelete != nil },
            set: { if !$0 { commandToDelete = nil } }
        )) {
            Button("取消", role: .cancel) {
                commandToDelete = nil
            }
            Button("刪除", role: .destructive) {
                if let cmd = commandToDelete {
                    scheduler.removeCommand(cmd.id)
                }
                commandToDelete = nil
            }
        } message: {
            if let cmd = commandToDelete {
                Text("確定要刪除排程指令「\(cmd.command)」嗎？此操作無法復原。")
            }
        }
    }
}

// MARK: - 排程列表項目

struct ScheduleRowView: View {
    let command: ScheduledCommand
    @EnvironmentObject var appState: AppState
    var onEdit: () -> Void
    var onDelete: () -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "zh_TW")
        return f
    }()

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                // 指令
                Text(command.command)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)

                // 資訊
                HStack(spacing: 10) {
                    Label(Self.dateFormatter.string(from: command.executeAt), systemImage: "clock")
                    Label(command.repeatMode.displayName, systemImage: "repeat")

                    if command.targetSessionIndex == -1 {
                        Label("目前分頁", systemImage: "terminal")
                    } else {
                        Label("分頁 \(command.targetSessionIndex + 1)", systemImage: "terminal")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if !command.note.isEmpty {
                    Text(command.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            // 操作按鈕
            VStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { command.isEnabled },
                    set: { _ in appState.scheduler.toggleCommand(command.id) }
                ))
                .toggleStyle(.switch)
                .labelsHidden()

                HStack(spacing: 4) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderless)
                    .help("編輯")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                    .help("刪除")
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(command.isEnabled ? 1.0 : 0.5)
        .contextMenu {
            Button("編輯排程") { onEdit() }
            Divider()
            Button("刪除排程", role: .destructive) { onDelete() }
        }
    }
}
