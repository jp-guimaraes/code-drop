import json
import os
import tempfile

LANGUAGES = ("en", "pt")
DEFAULT_EDITOR = "code"


class StoreError(Exception):
    pass


def config_dir():
    base = os.environ.get("XDG_CONFIG_HOME") or os.path.join(
        os.environ.get("HOME") or os.path.expanduser("~"), ".config")
    return os.path.join(base, "code-drop")


def config_path():
    return os.path.join(config_dir(), "config.json")


def _legacy_path():
    return os.path.join(config_dir(), "dirs.json")


def system_language():
    for var in ("LANGUAGE", "LC_ALL", "LC_MESSAGES", "LANG"):
        value = os.environ.get(var)
        if value:
            return "pt" if value.startswith("pt") else "en"
    return "en"


def _read_json(path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError):
        return None


def config():
    """Returns the config dict. Unknown keys (e.g. `editor`) are preserved."""
    data = _read_json(config_path())
    if isinstance(data, dict):
        cfg = dict(data)
    else:
        # Migrate the old format: a bare JSON array of paths.
        legacy = _read_json(_legacy_path())
        cfg = {"directories": legacy} if isinstance(legacy, list) else {}
    if cfg.get("language") not in LANGUAGES:
        cfg["language"] = system_language()
    dirs = cfg.get("directories")
    cfg["directories"] = [d for d in dirs if isinstance(d, str)] if isinstance(dirs, list) else []
    return cfg


def save(cfg):
    os.makedirs(config_dir(), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=config_dir(), prefix=".config-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2, sort_keys=True, ensure_ascii=False)
            f.write("\n")
        os.chmod(tmp, 0o644)
        os.replace(tmp, config_path())
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise
    try:
        os.unlink(_legacy_path())
    except OSError:
        pass


def load():
    return config()["directories"]


def language():
    return config()["language"]


def editor():
    value = config().get("editor")
    return value if isinstance(value, str) and value.strip() else DEFAULT_EDITOR


def canonical(path):
    return os.path.realpath(os.path.abspath(os.path.expanduser(path)))


def add(path):
    from . import l10n
    d = canonical(path)
    if not os.path.isdir(d):
        raise StoreError(l10n.not_a_directory(d))
    cfg = config()
    if d in cfg["directories"]:
        return False
    cfg["directories"].append(d)
    save(cfg)
    return True


def remove(path):
    d = canonical(path)
    cfg = config()
    if d not in cfg["directories"]:
        return False
    cfg["directories"].remove(d)
    save(cfg)
    return True


def set_language(lang):
    cfg = config()
    cfg["language"] = lang
    save(cfg)
