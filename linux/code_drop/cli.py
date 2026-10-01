import sys

from . import l10n, store

COMMANDS = {"add", "remove", "rm", "list", "ls", "lang", "-h", "--help", "help"}


def _err(msg):
    print(msg, file=sys.stderr)


def run(args):
    # First argument that isn't a command is treated as a path to save.
    if args[0] not in COMMANDS:
        args = ["add"] + args
    path = args[1] if len(args) > 1 else "."
    try:
        cmd = args[0]
        if cmd == "add":
            d = store.canonical(path)
            print(l10n.added(d) if store.add(path) else l10n.exists(d))
        elif cmd in ("remove", "rm"):
            d = store.canonical(path)
            print(l10n.removed(d) if store.remove(path) else l10n.not_found(d))
        elif cmd in ("list", "ls"):
            for d in store.load():
                print(d)
        elif cmd == "lang":
            if len(args) > 1:
                if args[1] not in store.LANGUAGES:
                    _err(l10n.invalid_language(args[1]))
                    return 2
                store.set_language(args[1])
            print(l10n.language_set(l10n.lang()))
        elif cmd in ("-h", "--help", "help"):
            print(l10n.usage())
        else:
            _err(l10n.usage())
            return 2
    except Exception as e:
        _err(f"{l10n.error_prefix()}: {e}")
        return 1
    return 0
