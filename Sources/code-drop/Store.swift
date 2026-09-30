import Foundation

enum Store {
    static let fileURL: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/code-drop/dirs.json")

    static func load() -> [String] {
        guard let data = try? Data(contentsOf: fileURL),
              let dirs = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return dirs
    }

    static func save(_ dirs: [String]) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        try encoder.encode(dirs).write(to: fileURL, options: .atomic)
    }

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
        var dirs = load()
        if dirs.contains(dir) { return false }
        dirs.append(dir)
        try save(dirs)
        return true
    }

    @discardableResult
    static func remove(_ path: String) throws -> Bool {
        let dir = canonical(path)
        var dirs = load()
        guard let i = dirs.firstIndex(of: dir) else { return false }
        dirs.remove(at: i)
        try save(dirs)
        return true
    }
}

enum StoreError: Error, CustomStringConvertible {
    case notADirectory(String)
    var description: String {
        switch self {
        case .notADirectory(let p): return "não é um diretório: \(p)"
        }
    }
}
