# code-drop

A macOS menu bar app that lists your favorite directories and opens VS Code in them with one click (like `cd dir && code .`).

A Linux (Ubuntu) version lives in [`linux/`](#linux-ubuntu); both share the same `config.json` format and CLI.

## Install (macOS)

```sh
scripts/build-app.sh      # builds, installs ~/Applications/CodeDrop.app, links `code-drop` into /usr/local/bin (or ~/.local/bin if not writable)
open ~/Applications/CodeDrop.app
```

To launch at login: System Settings → General → Login Items → add `CodeDrop.app`.

## Usage

```sh
cd ~/projects/my-project
code-drop .              # saves the current directory (or: code-drop /some/path)
code-drop list
code-drop remove .       # removes it again
```

`add`, `remove` (`rm`), `list` (`ls`), `lang` and `help` are reserved words; use `./list` to save a directory with one of those names.

## Settings

Everything lives in `~/.config/code-drop/config.json`; the menu re-reads it every time it opens.

```json
{
  "language": "en",
  "directories": ["/Users/me/projects/my-project"]
}
```

`language` is `en` or `pt` (defaults to your system language) and affects both the menu and the CLI messages. Change it with `code-drop lang pt`, or edit the file (menu → *Open config file*). An old `dirs.json` is migrated automatically.

 Clicking a directory in the menu runs `open -b com.microsoft.VSCode <dir>`.

## Linux (Ubuntu)

A Python + GTK tray app (AppIndicator) with the same CLI and `config.json` as the macOS version. It lives in [`linux/`](linux/).

```sh
sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-ayatanaappindicator3-0.1 zenity
linux/install.sh          # installs to ~/.local/share/code-drop, links ~/.local/bin/code-drop, enables autostart at login
code-drop &               # or just log in again
```

- GNOME needs the AppIndicator extension to show the tray icon (`sudo apt install gnome-shell-extension-appindicator`, then enable it).
- Config is `${XDG_CONFIG_HOME:-~/.config}/code-drop/config.json`. Linux adds an optional `"editor"` key (default `"code"`), the command run as `<editor> <dir>` when you click a directory; the macOS app ignores it.
- *Add folder…* uses `zenity`. The menu refreshes automatically when the config file changes.
- Tests: `python3 -m unittest discover linux/tests`.
