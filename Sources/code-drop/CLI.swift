import Foundation

enum CLI {
    static func run(_ args: [String]) -> Int32 {
        let commands: Set<String> = ["add", "remove", "rm", "list", "ls", "lang", "-h", "--help", "help"]
        // Primeiro argumento que não é comando é tratado como caminho a salvar.
        let args = commands.contains(args[0]) ? args : ["add"] + args
        let path = args.count > 1 ? args[1] : "."
        do {
            switch args[0] {
            case "add":
                let dir = Store.canonical(path)
                print(try Store.add(path) ? L10n.added(dir) : L10n.exists(dir))
            case "remove", "rm":
                let dir = Store.canonical(path)
                print(try Store.remove(path) ? L10n.removed(dir) : L10n.notFound(dir))
            case "list", "ls":
                Store.load().forEach { print($0) }
            case "lang":
                if args.count > 1 {
                    guard let lang = Language(rawValue: args[1]) else {
                        FileHandle.standardError.write(Data((L10n.invalidLanguage(args[1]) + "\n").utf8))
                        return 2
                    }
                    try Store.setLanguage(lang)
                }
                print(L10n.languageSet(L10n.lang))
            default:
                if args[0] == "-h" || args[0] == "--help" || args[0] == "help" {
                    print(L10n.usage)
                } else {
                    FileHandle.standardError.write(Data((L10n.usage + "\n").utf8))
                    return 2
                }
            }
        } catch {
            FileHandle.standardError.write(Data("\(L10n.errorPrefix): \(error)\n".utf8))
            return 1
        }
        return 0
    }
}
