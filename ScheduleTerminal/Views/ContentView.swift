import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(
                showScheduleSheet: $appState.showScheduleSheet,
                showScheduleList: $appState.showScheduleList
            )

            Divider()

            TerminalContainerView()
                .environmentObject(appState)
        }
        .background(Color(nsColor: NSColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0)))
        .environmentObject(appState)
        .focusedValue(\.appState, appState)
        .sheet(isPresented: $appState.showScheduleSheet) {
            ScheduleView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showScheduleList) {
            ScheduleListView()
                .environmentObject(appState)
        }
    }
}
