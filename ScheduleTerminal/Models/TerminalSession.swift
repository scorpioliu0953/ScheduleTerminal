import SwiftUI
import SwiftTerm

class TerminalSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "終端機"
    @Published var customTitle: String?
    @Published var isAlive: Bool = true
    @Published var currentDirectory: String?

    weak var terminalView: LocalProcessTerminalView?

    /// 顯示用的標題：優先使用自訂名稱，否則用 shell 偵測的標題
    var displayTitle: String {
        customTitle ?? title
    }

    /// 設定自訂標題，空字串表示清除自訂名稱
    func setCustomTitle(_ newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        customTitle = trimmed.isEmpty ? nil : trimmed
    }

    func sendText(_ text: String) {
        terminalView?.send(txt: text)
    }

    func sendCommand(_ command: String) {
        guard let tv = terminalView else { return }
        tv.send(txt: command)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            tv.send(txt: "\r")
        }
    }

    func terminate() {
        terminalView = nil
    }
}
