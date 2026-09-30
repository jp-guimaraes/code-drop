import Foundation

enum Language: String, Codable, CaseIterable {
    case en, pt

    static var systemDefault: Language {
        (Locale.preferredLanguages.first ?? "en").hasPrefix("pt") ? .pt : .en
    }
}

enum L10n {
    static var lang: Language { Store.config().language }

    private static func t(_ en: String, _ pt: String) -> String { lang == .pt ? pt : en }

    static var noDirectories: String { t("No saved directories", "Nenhum diretório salvo") }
    static var addFolder: String { t("Add folder…", "Adicionar pasta…") }
    static var openConfig: String { t("Open config file", "Abrir arquivo de config") }
    static var quit: String { t("Quit", "Sair") }

    static func added(_ p: String) -> String { t("added: \(p)", "adicionado: \(p)") }
    static func exists(_ p: String) -> String { t("already saved: \(p)", "já existe: \(p)") }
    static func removed(_ p: String) -> String { t("removed: \(p)", "removido: \(p)") }
    static func notFound(_ p: String) -> String { t("not found: \(p)", "não encontrado: \(p)") }
    static func notADirectory(_ p: String) -> String { t("not a directory: \(p)", "não é um diretório: \(p)") }
    static func languageSet(_ l: Language) -> String { t("language: \(l.rawValue)", "idioma: \(l.rawValue)") }
    static func invalidLanguage(_ s: String) -> String {
        t("invalid language '\(s)' (use en or pt)", "idioma inválido '\(s)' (use en ou pt)")
    }
    static var errorPrefix: String { t("error", "erro") }

    static var usage: String {
        t("""
        usage: code-drop <path>           save a directory (e.g. code-drop .)
               code-drop <command> [path]

          add [path]      same as code-drop <path> (default: current directory)
          remove [path]   remove a directory (default: current directory)
          list            list saved directories
          lang [en|pt]    show or set the interface language

        With no arguments, starts the menu bar app.
        """, """
        uso: code-drop <caminho>          salva o diretório (ex.: code-drop .)
             code-drop <comando> [caminho]

          add [caminho]      o mesmo que code-drop <caminho> (padrão: diretório atual)
          remove [caminho]   remove o diretório (padrão: diretório atual)
          list               lista os diretórios salvos
          lang [en|pt]       mostra ou define o idioma da interface

        Sem argumentos, inicia o app da barra de menu.
        """)
    }
}
