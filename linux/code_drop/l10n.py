from . import store


def lang():
    return store.language()


def t(en, pt):
    return pt if lang() == "pt" else en


def no_directories():
    return t("No saved directories", "Nenhum diretório salvo")


def add_folder():
    return t("Add folder…", "Adicionar pasta…")


def open_config():
    return t("Open config file", "Abrir arquivo de config")


def quit_label():
    return t("Quit", "Sair")


def added(p):
    return t(f"added: {p}", f"adicionado: {p}")


def exists(p):
    return t(f"already saved: {p}", f"já existe: {p}")


def removed(p):
    return t(f"removed: {p}", f"removido: {p}")


def not_found(p):
    return t(f"not found: {p}", f"não encontrado: {p}")


def not_a_directory(p):
    return t(f"not a directory: {p}", f"não é um diretório: {p}")


def language_set(code):
    return t(f"language: {code}", f"idioma: {code}")


def invalid_language(s):
    return t(f"invalid language '{s}' (use en or pt)", f"idioma inválido '{s}' (use en ou pt)")


def error_prefix():
    return t("error", "erro")


def select_folder_title():
    return t("Select folders", "Selecione as pastas")


def editor_failed(editor):
    return t(f"could not run '{editor}'", f"não foi possível executar '{editor}'")


_USAGE_EN = """\
usage: code-drop <path>           save a directory (e.g. code-drop .)
       code-drop <command> [path]

  add [path]      same as code-drop <path> (default: current directory)
  remove [path]   remove a directory (default: current directory)
  list            list saved directories
  lang [en|pt]    show or set the interface language

With no arguments, starts the tray app."""

_USAGE_PT = """\
uso: code-drop <caminho>          salva o diretório (ex.: code-drop .)
     code-drop <comando> [caminho]

  add [caminho]      o mesmo que code-drop <caminho> (padrão: diretório atual)
  remove [caminho]   remove o diretório (padrão: diretório atual)
  list               lista os diretórios salvos
  lang [en|pt]       mostra ou define o idioma da interface

Sem argumentos, inicia o app da bandeja do sistema."""


def usage():
    return t(_USAGE_EN, _USAGE_PT)
