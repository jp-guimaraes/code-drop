import Foundation

struct Config: Codable {
    var language: Language = .systemDefault
    var directories: [String] = []
}

enum Store {
    static let dir: URL = URL(fileURLWithPath: ProcessInfo.processInfo.environment["HOME"]
        ?? NSHomeDirectory()).appendingPathComponent(".config/code-drop")
    static let fileURL = dir.appendingPathComponent("config.json")
    private static let legacyURL = dir.appendingPathComponent("dirs.json")

    static func config() -> Config {
        if let data = try? Data(contentsOf: fileURL),
           let cfg = try? JSONDecoder().decode(Config.self, from: data) {
            return cfg
        }
        // Migrate the old format: a bare JSON array of paths.
        if let data = try? Data(contentsOf: legacyURL),
           let dirs = try? JSONDecoder().decode([String].self, from: data) {
            return Config(directories: dirs)
        }
        return Config()
    }

    static func save(_ cfg: Config) throws {
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        try encoder.encode(cfg).write(to: fileURL, options: .atomic)
        try? FileManager.default.removeItem(at: legacyURL)
    }

    static func load() -> [String] { config().directories }

    static func canonical(_ path: String) -> String {
        let expanded = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
        return url.standardizedFileURL.resolvingSymlinksInPath().path
    }

    @discardableResult
    static func add(_ path: String) throws -> Bool {
        let dir = canonical(path)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: dir, isDirectory: &isDir), isDir.boolValue else {
            throw StoreError.notADirectory(dir)
        }
        var cfg = config()
        if cfg.directories.contains(dir) { return false }
        cfg.directories.append(dir)
        try save(cfg)
        return true
    }

    @discardableResult
    static func remove(_ path: String) throws -> Bool {
        let dir = canonical(path)
        var cfg = config()
        guard let i = cfg.directories.firstIndex(of: dir) else { return false }
        cfg.directories.remove(at: i)
        try save(cfg)
        return true
    }

    static func setLanguage(_ lang: Language) throws {
        var cfg = config()
        cfg.language = lang
        try save(cfg)
    }
}

enum StoreError: Error, CustomStringConvertible {
    case notADirectory(String)
    var description: String {
        switch self {
        case .notADirectory(let p): return L10n.notADirectory(p)
        }
    }
}
