#!/usr/bin/env bash
#
# dotfiles installer.
# Puts the configs in this repo into place: Ghostty and AeroSpace are
# symlinked, Karabiner is copied (it rewrites its own file). Needs no sudo.
# It does NOT install applications or grant macOS permissions — see README.md.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This installer targets macOS only." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Karabiner-Elements (CapsLock -> Esc on tap, Control on hold)
# ---------------------------------------------------------------------------
KARABINER_CFG="$HOME/.config/karabiner/karabiner.json"

echo "==> Installing Karabiner config -> $KARABINER_CFG"
mkdir -p "$(dirname "$KARABINER_CFG")"

# Copied, not symlinked, on purpose: Karabiner-Elements rewrites this file
# (temp file + rename) whenever anything changes in its UI, which replaces a
# symlink with a regular file. Copy in, and copy back out when you change
# something worth keeping.
if [[ -e "$KARABINER_CFG" ]] && ! diff -q "$DOTFILES/karabiner/karabiner.json" "$KARABINER_CFG" >/dev/null; then
  backup="$KARABINER_CFG.bak.$(date +%Y%m%d%H%M%S)"
  echo "   existing config differs — backing up to $(basename "$backup")"
  cp "$KARABINER_CFG" "$backup"
fi
cp "$DOTFILES/karabiner/karabiner.json" "$KARABINER_CFG"

if [[ ! -d /Applications/Karabiner-Elements.app ]]; then
  echo "   note: Karabiner-Elements not installed. Install with:"
  echo "         brew install --cask karabiner-elements"
  echo "         then grant it Input Monitoring when prompted."
fi

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

echo
echo "==> Done."
echo
echo "Manual steps this script does NOT do:"
echo "  - Karabiner-Elements: grant Input Monitoring (System Settings > Privacy"
echo "    & Security) the first time it runs."
echo "  - AeroSpace: grant Accessibility, and quit Rectangle/Magnet if running."
