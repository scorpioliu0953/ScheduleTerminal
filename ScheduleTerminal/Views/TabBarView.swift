import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showScheduleSheet: Bool
    @Binding var showScheduleList: Bool

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(appState.sessions) { session in
                        TabItemView(
                            session: session,
                            isActive: session.id == appState.activeSessionId
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                appState.activeSessionId = session.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }

            Spacer()

            HStack(spacing: 4) {
                let activeCount = appState.scheduler.commands.filter({ $0.isEnabled }).count
                if activeCount > 0 {
                    Button(action: { showScheduleList = true }) {
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                            Text("\(activeCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.orange)
                    }
                    .buttonStyle(.borderless)
                    .help("\(activeCount) 個排程執行中")
                }

                Button(action: { showScheduleSheet = true }) {
                    Image(systemName: "clock.badge.plus")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .help("新增排程指令（Cmd+Shift+S）")

                Divider()
                    .frame(height: 18)

                Button(action: { appState.addNewSession() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .help("新增分頁（Cmd+T）")
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct TabItemView: View {
    @ObservedObject var session: TerminalSession
    let isActive: Bool
    @EnvironmentObject var appState: AppState
    @State private var isHovering = false
    @State private var isRenaming = false
    @State private var editableTitle = ""

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(session.isAlive ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            // 標題：重新命名模式顯示 TextField，否則顯示 Text
            if isRenaming {
                TextField("", text: $editableTitle, onCommit: {
                    session.setCustomTitle(editableTitle)
                    isRenaming = false
                })
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .frame(maxWidth: 130)
                .onExitCommand {
                    isRenaming = false
                }
            } else {
                Text(session.displayTitle)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .frame(maxWidth: 130)
                    .onTapGesture(count: 2) {
                        editableTitle = session.displayTitle
                        isRenaming = true
                    }
            }

            if isActive || isHovering {
                Button(action: {
                    appState.closeSession(session.id)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .frame(width: 16, height: 16)
            } else {
                Color.clear
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive
                    ? Color(nsColor: .controlBackgroundColor)
                    : (isHovering ? Color(nsColor: .controlBackgroundColor).opacity(0.5) : Color.clear))
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("重新命名") {
                editableTitle = session.displayTitle
                isRenaming = true
            }
            if session.customTitle != nil {
                Button("恢復預設名稱") {
                    session.customTitle = nil
                }
            }
            Divider()
            Button("關閉分頁") {
                appState.closeSession(session.id)
            }
        }
    }
}
