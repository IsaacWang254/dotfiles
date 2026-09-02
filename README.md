# dotfiles

Personal config, portable across machines.

## Contents

| What | Where | Notes |
|------|-------|-------|
| **fish** shell | [`fish/`](fish/) | Aliases, adaptive Dracula/Alucard theme, bobthefish prompt via [fisher](https://github.com/jorgebucaran/fisher) |
| **Karabiner-Elements** key remap (macOS) | [`karabiner/`](karabiner/) | CapsLock → Esc on tap, Control on hold |
| **AeroSpace** tiling WM (macOS) | [`aerospace/`](aerospace/) | Keyboard-driven tiling via [AeroSpace](https://github.com/nikitabobko/AeroSpace) |
| **Corne** keyboard keymap | [`corne/`](corne/) | 42-key split on a 2.4GHz dongle; keymap written over raw HID, not flashed |
| **Ghostty** terminal | [`ghostty/`](ghostty/) | NK57 Monospace + native auto light/dark theme |
| **Homebrew** packages | [`Brewfile`](Brewfile) | Taps, formulae, casks, editor extensions, global npm packages |
| **atuin** shell history | [`atuin/`](atuin/) | Daemon + sync-records + `enter_accept`; key and history DB are *not* tracked |
| **mise** runtime manager | [`mise/`](mise/) | Global tool pins (node) |
| **git** | [`git/`](git/) | Identity + global ignore |
| **gh** CLI | [`gh/`](gh/) | Prefs and aliases; `hosts.yml` (auth) is *not* tracked |
| **Neovim** | [github.com/IsaacWang254/nvim](https://github.com/IsaacWang254/nvim) | Lives in its own repo — clone into `~/.config/nvim` |
| **Terminal font** | [github.com/IsaacWang254/nk57-monospace-nerd-font](https://github.com/IsaacWang254/nk57-monospace-nerd-font) | Patched build of the font `ghostty/config` asks for — own repo |

### Neovim

The nvim config is a standalone repo:

```sh
git clone https://github.com/IsaacWang254/nvim ~/.config/nvim
```

### Terminal font

`ghostty/config` selects the font by family name only — nothing in this repo
installs it, so a fresh machine renders in a fallback face until the font is
present. The patched build lives in its own repo:

```sh
git clone https://github.com/IsaacWang254/nk57-monospace-nerd-font
cp nk57-monospace-nerd-font/fonts/*.otf ~/Library/Fonts/
```

The base font (NK57 Monospace, by Ray Larabie) is CC0. The repo holds a build
patched with [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) glyphs plus
the script to reproduce it.

---

## Karabiner-Elements (macOS key remapping)

One remap, nothing else. Ordinary typing is untouched:

```
CapsLock:  tap = Escape,  hold = Left Control
```

### Setup

```sh
brew install --cask karabiner-elements
```

Launch it once and grant **Input Monitoring** when macOS prompts (System
Settings → Privacy & Security → Input Monitoring). Then `install.sh` copies
`karabiner/karabiner.json` into `~/.config/karabiner/`.

### Editing it

The config is **copied**, not symlinked. Karabiner rewrites `karabiner.json`
itself (temp file + rename) on every change made through its UI, which would
replace a symlink with a regular file. So the flow is two-way by hand:

```sh
~/dotfiles/install.sh                                   # repo  -> live
cp ~/.config/karabiner/karabiner.json ~/dotfiles/karabiner/   # live -> repo
```

`install.sh` backs up the live file first if it differs from the repo copy.

### Why not kanata

This repo used to configure [kanata](https://github.com/jtroo/kanata) for the
same single remap. It was dropped because the cost was all downside on a
machine already running Karabiner-Elements:

- kanata is built against Karabiner-DriverKit-VirtualHIDDevice **v6.2.0** and
  fails with `connect_failed asio.system:2` against anything newer. Current
  Karabiner-Elements ships **v8**, so the two cannot share a machine — running
  kanata means downgrading the driver and disabling Karabiner entirely.
- It also needs two separate permission grants (Input Monitoring *and*
  Accessibility) against a Homebrew Cellar path that changes on every
  `brew upgrade kanata`, plus two root LaunchDaemons.
- All of that to produce the CapsLock behaviour Karabiner already provides
  with one rule and no root.

kanata earns its keep for layers, home-row mods, and cross-platform configs.
For one dual-role key on a Mac, it does not. The old config and its setup
notes are in the git history if this ever needs revisiting.

---

## AeroSpace (tiling window manager)

Keyboard-driven i3-style tiling. No SIP disabling required. Modifier is **Option (alt)**.

### Keybindings

Workspaces are named by purpose rather than numbered, and every binding sits on
the Corne's base layer — one thumb plus one key. See [`corne/`](corne/) for why:
that keyboard reaches Alt only through the right thumb's hold and keeps its
digits a layer down, so `alt-1` would pin both thumbs.

| Keys | Action |
|------|--------|
| `alt` + `h/j/k/l` | Focus window left/down/up/right |
| `alt-shift` + `h/j/k/l` | Move window |
| `alt` + `e/t/b/n/c/m` | Switch to workspace **E**ditor / **T**erminal / **B**rowser / **N**otes / **C**hat / **M**edia |
| `alt-shift` + `e/t/b/n/c/m` | Send window to that workspace (and follow) |
| `alt-tab` | Previous workspace |
| `alt-shift-tab` | Move workspace to the next monitor |
| `alt-;` / `alt-'` | Resize smaller / larger |
| `alt-shift-'` | Balance sizes |
| `alt-/` | Toggle tiling orientation |
| `alt-,` | Accordion layout |
| `alt-f` | Fullscreen |
| `alt-shift-space` | Float / unfloat window |
| `alt-shift-;` | Enter *service* mode (then `esc` back; `c` reload config, `r` reset tree, `backspace` close others, `alt-shift-hjkl` join) |

Apps are sent to their workspace on launch by the `on-window-detected` rules at
the top of the config — editors to `E`, Ghostty to `T`, browsers to `B`, and so
on. Anything not listed opens where you are.

### Setup

```sh
brew install --cask nikitabobko/tap/aerospace
```

1. `install.sh` symlinks `aerospace/aerospace.toml` → `~/.config/aerospace/`.
2. Launch AeroSpace (it lives in the menu bar) and grant it **Accessibility**
   (System Settings → Privacy & Security → Accessibility).
3. **Quit Rectangle / Magnet / other window managers** and turn off their
   "open at login" — running two window managers fights over window placement.
4. `start-at-login = true` is set, so it comes back on reboot.

Edit `aerospace/aerospace.toml`, then `alt-shift-c` (or `aerospace reload-config`) to apply.

---

## Corne keyboard

42-key split (3x6 + 3 thumbs) on a 2.4GHz dongle — a Keyclicks w-corne-choc
running a QMK/Vial vendor fork. The **dongle** holds the firmware and keymap;
the halves just report matrix events, and their USB-C ports are charge-only.

So there is nothing to flash and nothing to symlink. The keymap is written to
the dongle over Vial's raw HID interface, and `install.sh` only reports whether
the dongle is plugged in:

```sh
python3 corne/apply.py            # write the tracked keymap, verify by read-back
python3 corne/apply.py --read b.bin   # dump what's on the dongle right now
```

`corne/keymap.layout.json` is the same keymap in VIA's export format, for
<https://vial.rocks> if you'd rather edit it in a GUI.

Layout is adapted from [charlietlamb/corne-config](https://github.com/charlietlamb/corne-config):
QWERTY, `Tab`/`Ctrl`/`Shift` down the outer column, and two layers behind the
thumbs — symbols and digits on `MO(1)`, function keys and arrows on `MO(2)`.
Full layer diagrams and the device's raw-HID details are in
[`corne/README.md`](corne/README.md).

The AeroSpace bindings above are shaped around this keyboard.

## fish (shell)

The tracked files are the hand-written ones only:

| File | What |
|------|------|
| `fish/config.fish` | Env, PATH, tool hooks (direnv/fzf/zoxide/mise/atuin), aliases |
| `fish/fish_plugins` | fisher manifest — currently `oh-my-fish/theme-bobthefish` |
| `fish/conf.d/dracula-theme.fish` | Adaptive Dracula (dark) / Alucard (light) theme that follows the macOS appearance |
| `fish/functions/wt.fish` | Wrapper so `wt <branch>` can `cd` the parent shell into the new worktree |

Deliberately **not** tracked, because something else owns them:

- `functions/fish_prompt.fish`, `fish_right_prompt.fish`, `fish_mode_prompt.fish`,
  `fish_title.fish`, `fish_greeting.fish`, `__bobthefish_*`, `bobthefish_*` —
  installed by fisher from `fish_plugins`, so `fisher update` regenerates them.
- `conf.d/atuin.env.fish` — written by the atuin installer.
- `fish_variables` — fish universal variables (theme colors, fisher state). The
  colors here are re-derived by `dracula_theme sync`, and the rest is
  machine-local.

### Setup

```sh
brew install fish
~/dotfiles/install.sh          # symlinks the files above, bootstraps fisher, runs `fisher update`
```

`install.sh` prints the `chsh` line if fish is not yet the login shell:

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### Theme

`dracula-theme.fish` defines a `dracula_theme` command:

```sh
dracula_theme auto      # follow macOS light/dark (default)
dracula_theme dark      # pin Dracula
dracula_theme light     # pin Alucard
dracula_theme status    # show current mode + resolved appearance
dracula_theme sync      # re-apply after editing the file
```

`reload` (alias) re-sources the theme and `config.fish` in the current shell.

### Expected external tools

`config.fish` guards every hook with `type -q`, so missing tools degrade
quietly. Aliases do not — these are assumed present:

```sh
brew install eza bat fzf zoxide direnv mise atuin nvim thefuck
```

The `wt` function shells out to `~/.local/bin/wt`, which is **not** in this
repo — the function is inert until that script exists on the machine.

The `updateTiobiDev` / `tiobiLocalServer` / `tiobiLocal` / `fuck` functions
delegate to a zsh subprocess because they are defined in work-specific
zsh files (`~/.tiobi-local.zsh`) that are not part of this repo.

---

## CLI tooling

Symlinked by `install.sh` alongside fish:

| Repo file | Installed to | What |
|-----------|--------------|------|
| `atuin/config.toml` | `~/.config/atuin/config.toml` | `enter_accept`, `daemon-fuzzy` search, daemon + autostart, sync records, AI |
| `mise/config.toml` | `~/.config/mise/config.toml` | Global tool pins — currently `node = "25"` |
| `git/gitconfig` | `~/.gitconfig` | `user.name` / `user.email` |
| `git/ignore` | `~/.config/git/ignore` | Global gitignore (XDG default path — needs no `core.excludesFile`) |
| `gh/config.yml` | `~/.config/gh/config.yml` | `git_protocol`, prompts, the `co = pr checkout` alias |

atuin, git and gh all rewrite their config file when you change a setting from
the CLI, but all three write **through** a symlink onto the resolved path, so
the repo copy stays the source of truth and your edits land in git. (Karabiner
is the one exception in this repo — it replaces the file, so it is copied.)

### Not tracked, on purpose

These are credentials or machine state, not config, and this repo is public:

| Path | Why |
|------|-----|
| `~/.local/share/atuin/key` | Sync **encryption key**. Losing it loses your synced history; publishing it hands it over. Back it up somewhere private, not here. |
| `~/.local/share/atuin/*.db` | Shell history itself. |
| `~/.config/gh/hosts.yml` | gh account + auth. Re-create with `gh auth login`. |
| `~/.aws/`, `~/.ssh/` | Credentials. |
| `~/.zsh_history` | History. |

### Tools with no config file

`zoxide` (the `cd` → `z` alias), `fzf`, `direnv`, `eza`, `bat` and `thefuck`
are driven entirely from `fish/config.fish` — init hooks and aliases, no config
file of their own. `install.sh` only checks they are installed:

```sh
brew install zoxide fzf direnv eza bat neovim thefuck
```

### The zsh config is not here

`~/.zshrc` is deliberately absent. `fish/config.fish` still depends on it —
`updateTiobiDev`, `tiobiLocalServer`, `tiobiLocal` and `fuck` shell out to
`zsh -ic`, which sources `~/.zshrc` and `~/.tiobi-local.zsh`. Those files
contain work-specific tooling (internal paths, package names and ports), and
this repository is public, so they stay out of it.

Consequence: on a fresh machine those four fish functions exist but fail. Every
other alias and hook in `config.fish` works standalone.

---

## Homebrew

`Brewfile` is a `brew bundle dump` of this machine — 4 taps, 50 formulae,
7 casks, the Cursor/VS Code extension list, and global npm packages.

```sh
brew bundle install --file=~/dotfiles/Brewfile     # install everything
brew bundle check   --file=~/dotfiles/Brewfile     # what is missing?
brew bundle dump --file=~/dotfiles/Brewfile --force  # re-capture after installing something
```

`install.sh` only *reports* what is missing by default, because installing 50+
packages should be deliberate. To let it install:

```sh
DOTFILES_INSTALL_PACKAGES=1 ~/dotfiles/install.sh
```

### Not covered by the Brewfile

Installed outside Homebrew, so `brew bundle` will not restore them:

| Tool | Install |
|------|---------|
| **Karabiner-Elements** | Installed manually, *not* via brew — the app is in `/Applications` but absent from `brew list --cask`. Deliberately left out of the Brewfile: adding it would make `brew bundle install` collide with the existing app and fail the whole run. Install by hand, or `brew install --cask karabiner-elements` on a clean machine. |
| **atuin** | `curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh \| sh` — lives in `~/.atuin/bin` |
| **bun** | `curl -fsSL https://bun.sh/install \| bash` — `~/.bun` |
| **uv** | `curl -LsSf https://astral.sh/uv/install.sh \| sh` — `~/.local/bin` |
| **Claude Code** | `~/.local/bin/claude` |
| **cursor-agent** | `~/.local/bin/cursor-agent` |
| **node** | Managed by **mise** (`mise/config.toml` pins `node = "25"`), not brew. `nvm` is also present but only lazy-loaded from the zsh config. |

### Stale entry

`Brewfile` still lists `brew "kanata"`, because it is still installed on this
machine — but this repo replaced kanata with Karabiner. It is kept so the
Brewfile stays a truthful dump; `brew uninstall kanata` and re-dump when you
are ready to drop it.
