# code-drop

A macOS menu bar app that lists your favorite directories and opens VS Code in them with one click (like `cd dir && code .`).

## Install

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
