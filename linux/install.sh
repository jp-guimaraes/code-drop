#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# gi precisa do python3 do sistema (não de venv/pyenv).
PY=/usr/bin/python3
if ! "$PY" -c 'import gi; gi.require_version("Gtk","3.0"); gi.require_version("AyatanaAppIndicator3","0.1")' 2>/dev/null; then
  echo "Dependências ausentes. Instale com:"
  echo "  sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-ayatanaappindicator3-0.1"
  exit 1
fi
command -v zenity >/dev/null || echo "Aviso: 'zenity' não encontrado (sudo apt install zenity); \"Adicionar pasta…\" não vai funcionar."

SHARE="$HOME/.local/share/code-drop"
BIN="$HOME/.local/bin"
pkill -f 'code_drop' 2>/dev/null || true
rm -rf "$SHARE"
mkdir -p "$SHARE" "$BIN" "$HOME/.local/share/applications" "$HOME/.config/autostart"
cp -r code_drop "$SHARE/"
find "$SHARE" -name __pycache__ -type d -prune -exec rm -rf {} +

cat > "$BIN/code-drop" <<WRAPPER
#!/bin/sh
PYTHONPATH="$SHARE" exec $PY -m code_drop "\$@"
WRAPPER
chmod +x "$BIN/code-drop"

cp code-drop.desktop "$HOME/.local/share/applications/code-drop.desktop"
cp code-drop.desktop "$HOME/.config/autostart/code-drop.desktop"

echo "Instalado em $SHARE e $BIN/code-drop"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "Garanta que $BIN está no PATH." ;; esac
echo "Iniciar: code-drop &   (inicia sozinho no próximo login)"
echo "No GNOME, o ícone precisa da extensão AppIndicator (gnome-shell-extension-appindicator)."
