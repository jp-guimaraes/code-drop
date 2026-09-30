#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release
BIN="$(swift build -c release --show-bin-path)/code-drop"

APP="$HOME/Applications/CodeDrop.app"
pkill -x code-drop 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/code-drop"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.jp.code-drop</string>
  <key>CFBundleName</key><string>CodeDrop</string>
  <key>CFBundleExecutable</key><string>code-drop</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"

LINK=/usr/local/bin/code-drop
if ! ln -sf "$APP/Contents/MacOS/code-drop" "$LINK" 2>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  LINK="$HOME/.local/bin/code-drop"
  ln -sf "$APP/Contents/MacOS/code-drop" "$LINK"
  echo "Sem permissão em /usr/local/bin; garanta que ~/.local/bin está no PATH."
fi
echo "Instalado em $APP e $LINK"
echo "Iniciar: open \"$APP\""
