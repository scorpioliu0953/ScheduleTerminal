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

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(session.isAlive ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(session.title)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: 130)

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
    }
}
