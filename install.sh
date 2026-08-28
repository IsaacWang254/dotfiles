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
# Homebrew
# ---------------------------------------------------------------------------
# Brewfile is a `brew bundle dump` of this machine: taps, formulae, casks,
# Cursor/VS Code extensions and global npm packages.
#
# By default this only REPORTS what is missing — installing 50+ packages should
# be a deliberate act, and the rest of this script is meant to stay fast and
# side-effect-light. Opt in with:
#
#   DOTFILES_INSTALL_PACKAGES=1 ./install.sh
#
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Homebrew not installed. Install it first:"
  echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo "    then re-run this script."
else
  if [[ "${DOTFILES_INSTALL_PACKAGES:-0}" == "1" ]]; then
    echo "==> brew bundle install (this can take a while)"
    brew bundle install --file="$DOTFILES/Brewfile"
  else
    echo "==> Checking Brewfile"
    if brew bundle check --file="$DOTFILES/Brewfile" >/dev/null 2>&1; then
      echo "   all Brewfile entries satisfied"
    else
      echo "   missing entries. To install them:"
      echo "     brew bundle install --file=$DOTFILES/Brewfile"
      echo "   or re-run:  DOTFILES_INSTALL_PACKAGES=1 $0"
    fi
  fi
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

# ---------------------------------------------------------------------------
# fish (shell)
# ---------------------------------------------------------------------------
# Only the hand-written files are symlinked. Everything else under
# ~/.config/fish is generated or fisher-managed and stays untracked:
#   functions/{fish_prompt,fish_right_prompt,fish_mode_prompt,fish_title,
#              fish_greeting,__bobthefish_*,bobthefish_*}.fish  <- fisher plugin
#   conf.d/atuin.env.fish                                        <- atuin installer
#   fish_variables                                               <- universal vars
FISH_CFG_DIR="$HOME/.config/fish"

echo "==> Symlinking fish config -> $FISH_CFG_DIR"
mkdir -p "$FISH_CFG_DIR/conf.d" "$FISH_CFG_DIR/functions"
ln -sf "$DOTFILES/fish/config.fish"                "$FISH_CFG_DIR/config.fish"
ln -sf "$DOTFILES/fish/fish_plugins"               "$FISH_CFG_DIR/fish_plugins"
ln -sf "$DOTFILES/fish/conf.d/dracula-theme.fish"  "$FISH_CFG_DIR/conf.d/dracula-theme.fish"
ln -sf "$DOTFILES/fish/functions/wt.fish"          "$FISH_CFG_DIR/functions/wt.fish"

if ! command -v fish >/dev/null 2>&1; then
  echo "   note: fish not installed. Install with:  brew install fish"
  echo "         then re-run this script to bootstrap fisher plugins."
else
  # fisher + the plugins listed in fish_plugins (theme-bobthefish).
  if ! fish -c 'functions -q fisher' 2>/dev/null; then
    echo "==> Bootstrapping fisher"
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
  fi
  echo "==> Installing fish plugins from fish_plugins"
  fish -c 'fisher update'

  # Make fish the login shell (needs the path registered in /etc/shells).
  FISH_BIN="$(command -v fish)"
  if [[ "${SHELL:-}" != "$FISH_BIN" ]]; then
    echo "   note: fish is not your login shell. To switch:"
    echo "         echo $FISH_BIN | sudo tee -a /etc/shells && chsh -s $FISH_BIN"
  fi
fi

# ---------------------------------------------------------------------------
# CLI tooling (atuin, mise, git, gh)
# ---------------------------------------------------------------------------
# All symlinked. atuin, git and gh each rewrite their config file when you
# change a setting from the CLI/UI, but all three write *through* a symlink
# (open + write, or temp + rename onto the resolved path), so the repo copy
# stays the source of truth. Karabiner above is the exception that must be
# copied.
#
# Deliberately NOT installed here, because they are credentials or machine
# state rather than config:
#   ~/.local/share/atuin/key      <- sync encryption key
#   ~/.local/share/atuin/*.db     <- shell history
#   ~/.config/gh/hosts.yml        <- gh account + auth
echo "==> Symlinking atuin config -> ~/.config/atuin/config.toml"
mkdir -p "$HOME/.config/atuin"
ln -sf "$DOTFILES/atuin/config.toml" "$HOME/.config/atuin/config.toml"
command -v atuin >/dev/null 2>&1 \
  || echo "   note: atuin not installed.  brew install atuin"

echo "==> Symlinking mise config -> ~/.config/mise/config.toml"
mkdir -p "$HOME/.config/mise"
ln -sf "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"
command -v mise >/dev/null 2>&1 \
  || echo "   note: mise not installed.  brew install mise"

echo "==> Symlinking git config -> ~/.gitconfig and ~/.config/git/ignore"
mkdir -p "$HOME/.config/git"
ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/git/ignore"    "$HOME/.config/git/ignore"

echo "==> Symlinking gh config -> ~/.config/gh/config.yml"
mkdir -p "$HOME/.config/gh"
ln -sf "$DOTFILES/gh/config.yml" "$HOME/.config/gh/config.yml"
if ! command -v gh >/dev/null 2>&1; then
  echo "   note: gh not installed.  brew install gh"
elif ! gh auth status >/dev/null 2>&1; then
  echo "   note: gh is not authenticated (hosts.yml is not in this repo).  gh auth login"
fi

# ---------------------------------------------------------------------------
# Shell tools with no config file of their own
# ---------------------------------------------------------------------------
# zoxide, fzf, direnv, eza, bat and thefuck are configured entirely from
# fish/config.fish (init hooks + aliases) and keep no tracked config here.
# They still have to be installed for those aliases to work:
# Plain string, not an array: macOS ships bash 3.2, where expanding an empty
# array under `set -u` is an unbound-variable error.
missing=""
for tool in zoxide fzf direnv eza bat nvim thefuck; do
  command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
done
if [[ -n "$missing" ]]; then
  echo "   note: not installed:$missing"
  echo "         these are in the Brewfile — see the Homebrew step above"
fi

echo
echo "==> Done."
echo
echo "Manual steps this script does NOT do:"
echo "  - Karabiner-Elements: grant Input Monitoring (System Settings > Privacy"
echo "    & Security) the first time it runs."
echo "  - AeroSpace: grant Accessibility, and quit Rectangle/Magnet if running."
