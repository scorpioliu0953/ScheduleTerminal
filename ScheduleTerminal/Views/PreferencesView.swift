import SwiftUI

struct PreferencesView: View {
    @AppStorage("terminalFontSize") private var fontSize: Double = 15

    var body: some View {
        TabView {
            Form {
                Section("Font") {
                    HStack {
                        Text("Size: \(Int(fontSize)) pt")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: $fontSize, in: 10...32, step: 1)
                    }

                    Text("Changes apply to new tabs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 450, height: 200)
    }
}
