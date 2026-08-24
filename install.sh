#!/usr/bin/env bash
#
# dotfiles installer.
# Symlinks configs into place and installs the kanata + VirtualHIDDevice
# launchd services. This does NOT install the driver or grant permissions —
# those are one-time manual steps documented in README.md ("First-time macOS
# setup"). Run those first on a fresh machine.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This installer targets macOS only." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# kanata
# ---------------------------------------------------------------------------
KANATA_CFG_DIR="$HOME/.config/kanata"

echo "==> Symlinking kanata config -> $KANATA_CFG_DIR/kanata.kbd"
mkdir -p "$KANATA_CFG_DIR"
ln -sf "$DOTFILES/kanata/kanata.kbd" "$KANATA_CFG_DIR/kanata.kbd"

KANATA_BIN="$(command -v kanata || true)"
if [[ -z "$KANATA_BIN" ]]; then
  echo "!! kanata not found on PATH. Install it first:  brew install kanata" >&2
  echo "   Then re-run this script." >&2
  exit 1
fi
echo "==> Using kanata: $KANATA_BIN"

echo "==> Validating config"
"$KANATA_BIN" --cfg "$KANATA_CFG_DIR/kanata.kbd" --check

echo "==> Installing LaunchDaemons (sudo)"

# kanata service — generated so the binary + config paths are correct on THIS
# machine (username / homebrew prefix differ between machines).
sudo tee /Library/LaunchDaemons/com.kanata.plist >/dev/null <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata</string>
    <key>ProgramArguments</key>
    <array>
        <string>$KANATA_BIN</string>
        <string>--cfg</string>
        <string>$KANATA_CFG_DIR/kanata.kbd</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <!-- Keep the remapper out of launchd's default daemon CPU/I/O throttling. -->
    <key>ProcessType</key>
    <string>Interactive</string>
    <key>StandardOutPath</key>
    <string>/var/log/kanata.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/kanata.err.log</string>
</dict>
</plist>
PLIST

# VirtualHIDDevice daemon service — driver path is fixed, so copy as-is.
sudo cp "$DOTFILES/kanata/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist" \
        /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

sudo chown root:wheel \
  /Library/LaunchDaemons/com.kanata.plist \
  /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

echo "==> Restarting services"
# bootout first so launchd actually re-reads plist changes (bootstrap alone
# returns "already bootstrapped" and leaves old scheduling properties active).
sudo launchctl bootout system/com.kanata 2>/dev/null || true
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist
sudo launchctl kickstart -k system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon 2>/dev/null || true
sudo launchctl kickstart -k system/com.kanata 2>/dev/null || true

# ---------------------------------------------------------------------------
# Ghostty (terminal)
# ---------------------------------------------------------------------------
echo "==> Symlinking Ghostty config -> ~/.config/ghostty/config"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# ---------------------------------------------------------------------------
# AeroSpace (tiling window manager)
# ---------------------------------------------------------------------------
echo "==> Symlinking AeroSpace config -> ~/.config/aerospace/aerospace.toml"
mkdir -p "$HOME/.config/aerospace"
ln -sf "$DOTFILES/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

if ! command -v aerospace >/dev/null 2>&1; then
  echo "   note: AeroSpace not installed. Install with:"
  echo "         brew install --cask nikitabobko/tap/aerospace"
  echo "         then grant it Accessibility and quit Rectangle (see README)."
else
  aerospace reload-config 2>/dev/null || true
fi

sleep 2
echo
echo "==> Done. kanata process:"
pgrep -fl kanata || echo "   (not running — check /var/log/kanata.err.log)"
echo
echo "If kanata is NOT running or you see 'connect_failed' / permission errors,"
echo "you have not completed the one-time steps in README.md:"
echo "  - Karabiner-DriverKit-VirtualHIDDevice v6.2.0 installed & activated"
echo "  - kanata granted Input Monitoring AND Accessibility"
echo "  - Karabiner-Elements disabled (it grabs the keyboard & ships the wrong driver)"
