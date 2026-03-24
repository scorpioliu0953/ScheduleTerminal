import SwiftUI

struct PreferencesView: View {
    @AppStorage("terminalFontSize") private var fontSize: Double = 15

    var body: some View {
        TabView {
            Form {
                Section("字體") {
                    HStack {
                        Text("大小：\(Int(fontSize)) pt")
                            .frame(width: 100, alignment: .leading)
                        Slider(value: $fontSize, in: 10...32, step: 1)
                    }

                    Text("變更將套用到新分頁")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("一般", systemImage: "gear")
            }
        }
        .frame(width: 450, height: 200)
    }
}
