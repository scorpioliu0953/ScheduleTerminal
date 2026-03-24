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

    /// 送出指令到終端機
    ///
    /// 先送出指令文字，延遲後再送 \r（Enter），
    /// 確保 TUI 程式（如 Claude Code、vim 等 raw mode 應用）
    /// 能正確將文字填入輸入框後再觸發送出。
    /// 一般 shell（bash/zsh）也能正常運作。
    func sendCommand(_ command: String) {
        guard let tv = terminalView else { return }

        // 先逐行送文字（不含 Enter）
        tv.send(txt: command)

        // 延遲 150ms 後送 Enter，讓 TUI 程式有時間處理文字輸入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            tv.send(txt: "\r")
        }
    }

    func terminate() {
        terminalView = nil
    }
}
