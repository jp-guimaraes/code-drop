import Foundation

enum CLI {
    static let usage = """
    uso: code-drop <caminho>          salva o diretório (ex.: code-drop .)
         code-drop <comando> [caminho]

      add [caminho]      o mesmo que code-drop <caminho> (padrão: diretório atual)
      remove [caminho]   remove o diretório (padrão: diretório atual)
      list               lista os diretórios salvos

    Sem argumentos, inicia o app da barra de menu.
    """

    static func run(_ args: [String]) -> Int32 {
        let commands: Set<String> = ["add", "remove", "rm", "list", "ls", "-h", "--help", "help"]
        // Primeiro argumento que não é comando é tratado como caminho a salvar.
        let args = commands.contains(args[0]) ? args : ["add"] + args
        let path = args.count > 1 ? args[1] : "."
        do {
            switch args[0] {
            case "add":
                let dir = Store.canonical(path)
                print(try Store.add(path) ? "adicionado: \(dir)" : "já existe: \(dir)")
            case "remove", "rm":
                let dir = Store.canonical(path)
                print(try Store.remove(path) ? "removido: \(dir)" : "não encontrado: \(dir)")
            case "list", "ls":
                Store.load().forEach { print($0) }
            case "-h", "--help", "help":
                print(usage)
            default:
                FileHandle.standardError.write(Data((usage + "\n").utf8))
                return 2
            }
        } catch {
            FileHandle.standardError.write(Data("erro: \(error)\n".utf8))
            return 1
        }
        return 0
    }
}
