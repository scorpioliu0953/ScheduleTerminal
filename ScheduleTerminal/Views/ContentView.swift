import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showScheduleSheet = false
    @State private var showScheduleList = false

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(
                showScheduleSheet: $showScheduleSheet,
                showScheduleList: $showScheduleList
            )

            Divider()

            TerminalContainerView()
                .environmentObject(appState)
        }
        .background(Color(nsColor: NSColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0)))
        .onReceive(NotificationCenter.default.publisher(for: .showScheduleSheet)) { _ in
            showScheduleSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showScheduleList)) { _ in
            showScheduleList = true
        }
        .sheet(isPresented: $showScheduleSheet) {
            ScheduleView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showScheduleList) {
            ScheduleListView()
                .environmentObject(appState)
        }
    }
}
