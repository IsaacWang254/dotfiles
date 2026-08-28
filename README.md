# dotfiles

Personal config, portable across machines.

## Contents

| What | Where | Notes |
|------|-------|-------|
| **fish** shell | [`fish/`](fish/) | Aliases, adaptive Dracula/Alucard theme, bobthefish prompt via [fisher](https://github.com/jorgebucaran/fisher) |
| **Karabiner-Elements** key remap (macOS) | [`karabiner/`](karabiner/) | CapsLock → Esc on tap, Control on hold |
| **AeroSpace** tiling WM (macOS) | [`aerospace/`](aerospace/) | Keyboard-driven tiling via [AeroSpace](https://github.com/nikitabobko/AeroSpace) |
| **Ghostty** terminal | [`ghostty/`](ghostty/) | NK57 Monospace + native auto light/dark theme |
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

| Keys | Action |
|------|--------|
| `alt` + `h/j/k/l` | Focus window left/down/up/right |
| `alt-shift` + `h/j/k/l` | Move window |
| `alt` + `1`–`9` | Switch to workspace |
| `alt-shift` + `1`–`9` | Send window to workspace (and follow) |
| `alt-tab` | Previous workspace |
| `alt` + `-` / `=` | Resize smaller / larger |
| `alt-/` | Toggle tiling orientation |
| `alt-,` | Accordion layout |
| `alt-f` | Fullscreen |
| `alt-shift-space` | Float / unfloat window |
| `alt-shift-c` | Reload config |
| `alt-shift-;` | Enter *service* mode (then `esc` back; `r` reset tree, `backspace` close others, `alt-shift-hjkl` join) |

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
