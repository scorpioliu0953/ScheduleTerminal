import SwiftUI
import SwiftTerm

class TerminalSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "Terminal"
    @Published var isAlive: Bool = true
    @Published var currentDirectory: String?

    weak var terminalView: LocalProcessTerminalView?

    /// Send raw text to the terminal (no newline appended)
    func sendText(_ text: String) {
        terminalView?.send(txt: text)
    }

    /// Send a command to the terminal (appends newline to execute)
    func sendCommand(_ command: String) {
        terminalView?.send(txt: command + "\n")
    }

    func terminate() {
        terminalView = nil
    }
}
