import contextlib
import io
import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from code_drop import cli, store  # noqa: E402


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = os.path.realpath(self.tmp.name)
        self.saved_env = {k: os.environ.get(k) for k in ("XDG_CONFIG_HOME", "HOME", "LANG", "LANGUAGE", "LC_ALL", "LC_MESSAGES")}
        os.environ["XDG_CONFIG_HOME"] = os.path.join(self.root, "cfg")
        os.environ["LANG"] = "en_US.UTF-8"
        for k in ("LANGUAGE", "LC_ALL", "LC_MESSAGES"):
            os.environ.pop(k, None)
        self.addCleanup(self.restore_env)

    def restore_env(self):
        for k, v in self.saved_env.items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v

    def mkdir(self, *parts):
        p = os.path.join(self.root, *parts)
        os.makedirs(p, exist_ok=True)
        return p

    def run_cli(self, *args):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = cli.run(list(args))
        return code, out.getvalue(), err.getvalue()


class StoreTests(Base):
    def test_add_remove_dedupe(self):
        d = self.mkdir("proj")
        self.assertTrue(store.add(d))
        self.assertFalse(store.add(d))
        self.assertEqual(store.load(), [d])
        self.assertTrue(store.remove(d))
        self.assertFalse(store.remove(d))
        self.assertEqual(store.load(), [])

    def test_symlink_is_canonicalised(self):
        d = self.mkdir("real")
        link = os.path.join(self.root, "link")
        os.symlink(d, link)
        store.add(link)
        self.assertEqual(store.load(), [d])

    def test_not_a_directory(self):
        with self.assertRaises(store.StoreError):
            store.add(os.path.join(self.root, "missing"))

    def test_legacy_migration(self):
        d = self.mkdir("old")
        os.makedirs(store.config_dir())
        legacy = os.path.join(store.config_dir(), "dirs.json")
        with open(legacy, "w") as f:
            json.dump([d], f)
        self.assertEqual(store.load(), [d])
        store.set_language("pt")
        self.assertFalse(os.path.exists(legacy))
        self.assertEqual(store.load(), [d])

    def test_extra_keys_preserved(self):
        os.makedirs(store.config_dir())
        with open(store.config_path(), "w") as f:
            json.dump({"language": "en", "directories": [], "editor": "codium"}, f)
        store.set_language("pt")
        self.assertEqual(store.editor(), "codium")
        with open(store.config_path()) as f:
            self.assertEqual(json.load(f)["language"], "pt")

    def test_default_language_from_env(self):
        os.environ["LANG"] = "pt_BR.UTF-8"
        self.assertEqual(store.language(), "pt")
        os.environ["LANG"] = "de_DE.UTF-8"
        self.assertEqual(store.language(), "en")

    def test_editor_default(self):
        self.assertEqual(store.editor(), "code")


class CLITests(Base):
    def test_add_list_remove(self):
        d = self.mkdir("proj")
        code, out, _ = self.run_cli(d)
        self.assertEqual((code, out.strip()), (0, f"added: {d}"))
        self.assertEqual(self.run_cli("add", d)[1].strip(), f"already saved: {d}")
        self.assertEqual(self.run_cli("ls")[1].strip(), d)
        self.assertEqual(self.run_cli("rm", d)[1].strip(), f"removed: {d}")
        self.assertEqual(self.run_cli("remove", d)[1].strip(), f"not found: {d}")

    def test_default_path_is_cwd(self):
        d = self.mkdir("cwd")
        old = os.getcwd()
        os.chdir(d)
        self.addCleanup(os.chdir, old)
        self.run_cli("add")
        self.assertEqual(store.load(), [d])

    def test_lang(self):
        self.assertEqual(self.run_cli("lang", "pt"), (0, "idioma: pt\n", ""))
        self.assertEqual(self.run_cli("lang")[1], "idioma: pt\n")
        code, _, err = self.run_cli("lang", "xx")
        self.assertEqual(code, 2)
        self.assertIn("idioma inválido 'xx'", err)

    def test_help_and_errors(self):
        self.assertEqual(self.run_cli("help")[0], 0)
        self.assertIn("usage:", self.run_cli("--help")[1])
        code, _, err = self.run_cli("add", os.path.join(self.root, "nope"))
        self.assertEqual(code, 1)
        self.assertTrue(err.startswith("error: not a directory"))


if __name__ == "__main__":
    unittest.main()
