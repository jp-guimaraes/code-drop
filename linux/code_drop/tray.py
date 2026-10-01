import os
import subprocess
from collections import Counter

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("AyatanaAppIndicator3", "0.1")
from gi.repository import AyatanaAppIndicator3 as AppIndicator  # noqa: E402
from gi.repository import Gio, GLib, Gtk  # noqa: E402

from . import l10n, store  # noqa: E402


def _mtime(path):
    try:
        return os.stat(path).st_mtime_ns
    except OSError:
        return None


class TrayApp:
    def __init__(self):
        self.indicator = AppIndicator.Indicator.new(
            "code-drop", "folder-symbolic", AppIndicator.IndicatorCategory.APPLICATION_STATUS)
        self.indicator.set_title("code-drop")
        self.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE)
        self._stamp = None
        self._rebuild()

        # The indicator can't refresh the menu on open (no menuNeedsUpdate), so
        # watch the config file and keep a cheap mtime poll as a fallback.
        os.makedirs(store.config_dir(), exist_ok=True)
        self._monitor = Gio.File.new_for_path(store.config_dir()).monitor_directory(
            Gio.FileMonitorFlags.NONE, None)
        self._monitor.connect("changed", lambda *_: self._refresh())
        GLib.timeout_add_seconds(2, self._poll)

    def _signature(self):
        return (_mtime(store.config_path()), _mtime(store._legacy_path()))

    def _poll(self):
        self._refresh()
        return True

    def _refresh(self):
        if self._signature() != self._stamp:
            self._rebuild()

    def _rebuild(self):
        self._stamp = self._signature()
        menu = Gtk.Menu()
        dirs = store.load()

        if not dirs:
            empty = Gtk.MenuItem(label=l10n.no_directories())
            empty.set_sensitive(False)
            menu.append(empty)

        counts = Counter(os.path.basename(d) for d in dirs)
        for d in dirs:
            name = os.path.basename(d) or d
            title = name
            if counts[os.path.basename(d)] > 1:
                title += "  —  " + os.path.basename(os.path.dirname(d))
            item = Gtk.MenuItem()
            label = Gtk.Label(xalign=0)
            if os.path.exists(d):
                label.set_text(title)
                item.connect("activate", lambda _w, p=d: self._open(p))
            else:
                label.set_markup(f"<s>{GLib.markup_escape_text(title)}</s>")
                item.set_sensitive(False)
            item.add(label)
            item.set_tooltip_text(d)
            menu.append(item)

        menu.append(Gtk.SeparatorMenuItem())
        menu.append(self._item(l10n.add_folder(), self._add_folder))
        menu.append(self._item(l10n.open_config(), self._open_config))
        menu.append(Gtk.SeparatorMenuItem())
        menu.append(self._item(l10n.quit_label(), lambda *_: Gtk.main_quit()))
        menu.show_all()
        self.indicator.set_menu(menu)
        self._menu = menu  # keep a reference

    @staticmethod
    def _item(title, callback):
        item = Gtk.MenuItem(label=title)
        item.connect("activate", callback)
        return item

    def _open(self, path):
        editor = store.editor()
        try:
            subprocess.Popen([editor, path], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except OSError:
            self._notify(l10n.editor_failed(editor))

    def _notify(self, message):
        try:
            subprocess.Popen(["notify-send", "code-drop", message])
        except OSError:
            pass

    def _add_folder(self, *_):
        try:
            proc = subprocess.Popen(
                ["zenity", "--file-selection", "--directory", "--multiple",
                 "--separator=\n", f"--title={l10n.select_folder_title()}"],
                stdout=subprocess.PIPE, text=True)
        except OSError:
            self._notify("zenity not found")
            return

        def on_exit(_pid, _status):
            out = proc.stdout.read()
            for line in out.splitlines():
                if line.strip():
                    try:
                        store.add(line.strip())
                    except Exception:
                        pass
            self._refresh()

        GLib.child_watch_add(proc.pid, on_exit)

    def _open_config(self, *_):
        if not os.path.exists(store.config_path()):
            store.save(store.config())
        self._open(store.config_path())


def run_tray():
    TrayApp()
    Gtk.main()
