import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "chevron.left.forwardslash.chevron.right",
                                accessibilityDescription: "code-drop")
            image?.isTemplate = true
            button.image = image
        }
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let dirs = Store.load()

        if dirs.isEmpty {
            let empty = NSMenuItem(title: L10n.noDirectories, action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        }

        let counts = Dictionary(grouping: dirs, by: { ($0 as NSString).lastPathComponent }).mapValues(\.count)
        for dir in dirs {
            let name = (dir as NSString).lastPathComponent
            var title = name
            if counts[name, default: 0] > 1 {
                title += "  —  " + ((dir as NSString).deletingLastPathComponent as NSString).lastPathComponent
            }
            let item = NSMenuItem(title: title, action: #selector(openDir(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = dir
            item.toolTip = dir
            item.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            if !FileManager.default.fileExists(atPath: dir) {
                item.isEnabled = false
                item.attributedTitle = NSAttributedString(
                    string: title, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            }
            menu.addItem(item)
        }

        menu.addItem(.separator())
        menu.addItem(item(L10n.addFolder, #selector(addFolder)))
        menu.addItem(item(L10n.openConfig, #selector(openConfig)))
        menu.addItem(.separator())
        menu.addItem(item(L10n.quit, #selector(quit), key: "q"))
    }

    private func item(_ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: key)
        i.target = self
        return i
    }

    private func openInVSCode(_ path: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        p.arguments = ["-b", "com.microsoft.VSCode", path]
        try? p.run()
    }

    @objc private func openDir(_ sender: NSMenuItem) {
        guard let dir = sender.representedObject as? String else { return }
        openInVSCode(dir)
    }

    @objc private func addFolder() {
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = true
        guard panel.runModal() == .OK else { return }
        for url in panel.urls { _ = try? Store.add(url.path) }
    }

    @objc private func openConfig() {
        if !FileManager.default.fileExists(atPath: Store.fileURL.path) { try? Store.save(Store.config()) }
        openInVSCode(Store.fileURL.path)
    }

    @objc private func quit() { NSApp.terminate(nil) }
}

func runMenuBarApp() -> Never {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
    exit(0)
}
