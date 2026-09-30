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

`add`, `remove` (`rm`), `list` (`ls`) and `help` are reserved words; use `./list` to save a directory with one of those names.

Saved directories live in `~/.config/code-drop/dirs.json`; the menu re-reads it every time it opens. Clicking an entry runs `open -b com.microsoft.VSCode <dir>`.
