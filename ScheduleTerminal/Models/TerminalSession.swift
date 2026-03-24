import SwiftUI
import SwiftTerm

class TerminalSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "終端機"
    @Published var isAlive: Bool = true
    @Published var currentDirectory: String?

    weak var terminalView: LocalProcessTerminalView?

    /// 送出原始文字到終端機（不附加換行）
    func sendText(_ text: String) {
        terminalView?.send(txt: text)
    }

    /// 送出指令到終端機（附加 CR 模擬按下 Enter）
    /// 使用 \r（Carriage Return）而非 \n（Line Feed），
    /// 因為鍵盤按 Enter 實際送出的是 \r，
    /// 這樣在一般 shell 和 raw mode 程式（如 Claude Code）下都能正確送出。
    func sendCommand(_ command: String) {
        terminalView?.send(txt: command + "\r")
    }

    func terminate() {
        terminalView = nil
    }
}
