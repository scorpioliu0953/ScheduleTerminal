import SwiftUI
import SwiftTerm

struct TerminalContainerView: NSViewRepresentable {
    @EnvironmentObject var appState: AppState

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let container = DropContainerView()
        container.wantsLayer = true
        container.coordinator = context.coordinator
        context.coordinator.containerView = container
        context.coordinator.appState = appState
        context.coordinator.syncTerminals()
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.appState = appState
        context.coordinator.syncTerminals()
    }

    // MARK: - Coordinator

    class Coordinator: NSObject {
        var containerView: NSView?
        var appState: AppState?
        var terminalViews: [UUID: LocalProcessTerminalView] = [:]
        var delegates: [UUID: SessionDelegate] = [:]

        func syncTerminals() {
            guard let appState = appState, let container = containerView else { return }

            let currentIds = Set(appState.sessions.map { $0.id })

            for session in appState.sessions where terminalViews[session.id] == nil {
                createTerminal(for: session, in: container)
            }

            for (id, tv) in terminalViews where !currentIds.contains(id) {
                tv.removeFromSuperview()
                terminalViews.removeValue(forKey: id)
                delegates.removeValue(forKey: id)
            }

            for (id, tv) in terminalViews {
                let isActive = id == appState.activeSessionId
                tv.isHidden = !isActive
                if isActive {
                    tv.frame = container.bounds
                    tv.autoresizingMask = [.width, .height]
                    DispatchQueue.main.async {
                        container.window?.makeFirstResponder(tv)
                    }
                }
            }
        }

        private func createTerminal(for session: TerminalSession, in container: NSView) {
            let tv = LocalProcessTerminalView(frame: container.bounds)
            tv.autoresizingMask = [.width, .height]

            let fontSize = UserDefaults.standard.double(forKey: "terminalFontSize")
            let size = fontSize > 0 ? CGFloat(fontSize) : 15.0
            tv.font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)

            tv.nativeBackgroundColor = NSColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0)
            tv.nativeForegroundColor = NSColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
            tv.caretColor = NSColor(red: 0.40, green: 0.85, blue: 0.40, alpha: 1.0)
            tv.optionAsMetaKey = true

            let delegate = SessionDelegate(session: session)
            tv.processDelegate = delegate
            delegates[session.id] = delegate

            let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
            let shellName = "-" + ((shell as NSString).lastPathComponent)
            let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
            let startDir = session.initialDirectory ?? homeDir
            tv.startProcess(executable: shell, execName: shellName, currentDirectory: startDir)

            session.terminalView = tv
            terminalViews[session.id] = tv
            container.addSubview(tv)
        }
    }
}

// MARK: - Drop Container View

class DropContainerView: NSView {
    weak var coordinator: TerminalContainerView.Coordinator?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) else {
            return []
        }
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
              let url = urls.first else {
            return false
        }

        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        let targetPath = isDirectory.boolValue ? url.path : url.deletingLastPathComponent().path

        let escaped = targetPath.replacingOccurrences(of: "'", with: "'\\''")
        let cdCommand = "cd '\(escaped)'"

        if let appState = coordinator?.appState,
           let activeId = appState.activeSessionId,
           let session = appState.sessions.first(where: { $0.id == activeId }) {
            session.sendCommand(cdCommand)
        }

        return true
    }
}

// MARK: - Session Delegate

class SessionDelegate: NSObject, LocalProcessTerminalViewDelegate {
    weak var session: TerminalSession?

    init(session: TerminalSession) {
        self.session = session
    }

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        DispatchQueue.main.async {
            // 只在沒有自訂標題時才更新（避免覆蓋使用者命名）
            if self.session?.customTitle == nil {
                self.session?.title = title.isEmpty ? "終端機" : title
            }
        }
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        DispatchQueue.main.async {
            self.session?.currentDirectory = directory
        }
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        DispatchQueue.main.async {
            self.session?.isAlive = false
        }
    }
}
