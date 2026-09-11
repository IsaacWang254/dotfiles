# Catppuccin Mocha for fish: syntax highlighting, the pager, and the
# bobthefish prompt.
#
# Dark only, on purpose. Ghostty is pinned to Mocha (see ghostty/config), so
# there is no light background for these colours ever to land on and nothing
# to detect. This file replaces the old adaptive Dracula/Alucard theme, which
# polled macOS appearance on every prompt to solve a problem that a pinned
# terminal does not have.
#
# `set -g`, not `set -U`: universal variables persist into ~/.config/fish/
# fish_variables, which is untracked machine state. A global is re-read from
# this tracked file on every shell start, and shadows any stale universal of
# the same name left over from an earlier theme.

# --- Prompt -------------------------------------------------------------
# bobthefish ships the four Catppuccin flavours in __bobthefish_colors.fish,
# so the prompt needs no hand-written colour override.
set -g theme_color_scheme catppuccin-mocha

# --- Syntax highlighting ------------------------------------------------
set -g fish_color_normal          cdd6f4  # text
set -g fish_color_command         89b4fa  # blue
set -g fish_color_keyword         f38ba8  # red
set -g fish_color_quote           a6e3a1  # green
set -g fish_color_redirection     f5c2e7  # pink
set -g fish_color_end             fab387  # peach
set -g fish_color_error           f38ba8  # red
set -g fish_color_param           f2cdcd  # flamingo
set -g fish_color_comment         7f849c  # overlay1
set -g fish_color_selection       --background=313244  # surface0
set -g fish_color_search_match    --background=313244
set -g fish_color_operator        f5c2e7  # pink
set -g fish_color_escape          eba0ac  # maroon
set -g fish_color_autosuggestion  6c7086  # overlay0
set -g fish_color_cancel          f38ba8
set -g fish_color_option          a6e3a1
set -g fish_color_valid_path      --underline
set -g fish_color_cwd             f9e2af  # yellow
set -g fish_color_cwd_root        f38ba8
set -g fish_color_user            94e2d5  # teal
set -g fish_color_host            89b4fa
set -g fish_color_host_remote     a6e3a1
set -g fish_color_status          f38ba8
set -g fish_color_history_current --bold

# --- Pager --------------------------------------------------------------
set -g fish_pager_color_progress    6c7086
set -g fish_pager_color_prefix      f5c2e7 --bold
set -g fish_pager_color_completion  cdd6f4
set -g fish_pager_color_description 6c7086
