# dotfiles

Personal config, portable across machines.

## Contents

| What | Where | Notes |
|------|-------|-------|
| **kanata** conservative remap (macOS) | [`kanata/`](kanata/) | Ordinary typing unchanged; CapsLock→Esc/Ctrl via [kanata](https://github.com/jtroo/kanata) |
| **AeroSpace** tiling WM (macOS) | [`aerospace/`](aerospace/) | Keyboard-driven tiling via [AeroSpace](https://github.com/nikitabobko/AeroSpace) |
| **Ghostty** terminal | [`ghostty/`](ghostty/) | Nerd Font + native auto light/dark theme |
| **Neovim** | [github.com/IsaacWang254/nvim](https://github.com/IsaacWang254/nvim) | Lives in its own repo — clone into `~/.config/nvim` |

### Neovim

The nvim config is a standalone repo:

```sh
git clone https://github.com/IsaacWang254/nvim ~/.config/nvim
```

---

## kanata (macOS key remapping)

The configuration deliberately keeps normal typing conventional. Letter,
number, punctuation, and physical modifier keys pass through one-to-one. Caps
Lock is the only dual-role key:

```
CapsLock:  tap = Escape,  hold = Left Control
```

Unlisted media and navigation keys bypass Kanata. This replaces the previous
timing-sensitive home-row modifiers, which could misread normal typing rolls as
macOS shortcuts (for example, `d` followed by `o` becoming Command+O), resulting
in accidental commands, missing letters, repeats, and lag.

### Quick install (existing machine that already has the driver + permissions)

```sh
git clone https://github.com/IsaacWang254/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` symlinks `kanata/kanata.kbd` → `~/.config/kanata/`, generates and
installs the two LaunchDaemons (with the correct paths for this machine), and
starts them. It does **not** do the one-time driver/permission setup below.

### First-time macOS setup (do this once per machine)

kanata on macOS is fiddly. All four of these must be true or it silently does
nothing:

1. **Install kanata**
   ```sh
   brew install kanata
   ```

2. **Install the *exact* VirtualHIDDevice driver kanata expects — v6.2.0.**
   kanata is built against one driver version and pqrs changes the protocol
   between releases. A newer driver (e.g. the v8 that ships with modern
   **Karabiner-Elements**) fails with `connect_failed asio.system:2` and nothing
   remaps.
   - Download: <https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0>
   - If a newer driver is already installed, deactivate it first:
     ```sh
     sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
     ```
   - Install the v6.2.0 `.pkg`, then activate:
     ```sh
     sudo installer -pkg ~/Downloads/Karabiner-DriverKit-VirtualHIDDevice-6.2.0.pkg -target /
     sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate
     ```
   - Approve it: **System Settings → General → Login Items & Extensions →
     Driver Extensions →** enable `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.
   - Verify: `systemextensionsctl list | grep pqrs` shows **6.2.0**, activated.

3. **Grant kanata two permissions.** Under **System Settings → Privacy &
   Security**, add the kanata binary to **BOTH**:
   - **Input Monitoring**
   - **Accessibility**

   Use the real binary path (⌘⇧G in the file picker), not the symlink:
   ```
   /opt/homebrew/Cellar/kanata/<version>/bin/kanata
   ```
   > ⚠️ This path contains the version number. After `brew upgrade kanata` the
   > path changes and you must re-add it in both panes.

4. **Disable Karabiner-Elements** (if installed). It grabs the keyboard
   exclusively (kanata can't) *and* ships the wrong (v8) driver. Turn it off at
   **System Settings → General → Login Items & Extensions → Allow in the
   Background** (may be listed as *Fumihiko Takayama* / *org.pqrs*). The
   VirtualHIDDevice *driver* is separate and stays.

Then run `~/dotfiles/install.sh`.

### Managing it

```sh
# Reload after editing kanata/kanata.kbd (the file is symlinked, but the daemon
# still needs a restart to read it)
kanata --check --cfg ~/.config/kanata/kanata.kbd    # validate first
sudo launchctl kickstart -k system/com.kanata       # apply

# Stop / start the kanata service
sudo launchctl bootout system/com.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist

# Logs
tail -f /var/log/kanata.log /var/log/kanata.err.log
```

### Troubleshooting

| Symptom | Cause |
|---------|-------|
| `connect_failed asio.system:2` (looping) | Wrong driver version — install **v6.2.0** (step 2) |
| Keys pass through untouched, caps still toggles | kanata not intercepting: driver not connected, or permissions missing (step 3) |
| `exclusive access ... device already open` | Something else grabbed the keyboard — usually **Karabiner-Elements** (step 4) |
| `needs Accessibility permission` in err log | Grant Accessibility too, not just Input Monitoring (step 3) |
| Normal letters launch commands or disappear | A stale home-row config is still running — validate the current config and restart `com.kanata` |
| Typing lags and `/var/log/kanata.log` grows rapidly | Kanata was launched with `--debug`/`-d` — reinstall the generated service with `install.sh` and restart it |

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
