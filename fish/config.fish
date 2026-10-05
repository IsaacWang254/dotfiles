# Interactive fish configuration converted from ~/.zshrc.

# Environment
# Homebrew first: everything below (zoxide/direnv init, the eza/bat aliases)
# probes for binaries in /opt/homebrew/bin, so PATH has to be set before them.
# Apple Silicon prefix; Intel Macs use /usr/local.
for __brew in /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $__brew
        $__brew shellenv fish | source
        break
    end
end
set -e __brew

set -gx PATH $HOME/.local/bin $PATH
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin $PATH
set -g fish_history main

# Vercel, light or dark following the macOS appearance. Ghostty switches
# between ghostty/themes/Vercel {Light,Dark} and tells fish, which sets
# $fish_terminal_color_theme; the theme in themes/vercel.theme has a section
# for each and fish swaps them itself. eza and atuin use the terminal's ANSI
# palette, so they follow along with no config.
if status is-interactive
    fish_config theme choose vercel
end

# fzf reads its colours from the environment once per invocation, so re-export
# them whenever the terminal's appearance changes.
function __vercel_fzf_colors --on-variable fish_terminal_color_theme
    if test "$fish_terminal_color_theme" = light
        set -gx FZF_DEFAULT_OPTS "\
--color=fg:#171717,bg:-1,hl:#006bff,fg+:#171717,bg+:#ebebeb,hl+:#006bff \
--color=info:#666666,prompt:#7c00c7,pointer:#bd2864,marker:#297a3a \
--color=spinner:#bd2864,header:#666666,border:#ebebeb,label:#171717 \
--color=selected-bg:#e5e5e5"
    else
        set -gx FZF_DEFAULT_OPTS "\
--color=fg:#ededed,bg:-1,hl:#52a8ff,fg+:#ededed,bg+:#1a1a1a,hl+:#52a8ff \
--color=info:#a0a0a0,prompt:#c472fb,pointer:#f12b82,marker:#00ac3a \
--color=spinner:#f12b82,header:#a0a0a0,border:#2e2e2e,label:#ededed \
--color=selected-bg:#2e2e2e"
    end
end
__vercel_fzf_colors

# Git segment of the stock prompt (fish_vcs_prompt -> __fish_git_prompt).
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream informative

# Do not show a greeting.
set --universal --erase fish_greeting
function fish_greeting; end

# Interactive tooling
if type -q direnv
    direnv hook fish | source
end
if type -q fzf
    fzf --fish | source
end
if type -q zoxide
    zoxide init fish | source
end
if type -q mise
    mise activate fish | source
end
if type -q atuin
    atuin init fish | source
end

# Aliases
alias cc='claude --dangerously-skip-permissions'
alias c='open -a Cursor'
alias vim='nvim'
alias vi='nvim'
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ls='eza'
alias l='eza -l'
alias la='eza -a'
alias lt='eza --tree --level=2'
alias cat='bat --paging=never'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'
alias reload='source ~/.config/fish/config.fish'

# These Tiobi launchers and ~/.tiobi-local.zsh contain zsh-specific functions.
# Keep them available through a clean zsh subprocess until ported natively.
function updateTiobiDev
    zsh -ic 'updateTiobiDev "$@"' fish-compat $argv
end
function tiobiLocalServer
    zsh -ic 'tiobiLocalServer "$@"' fish-compat $argv
end
function tiobiLocal
    zsh -ic 'tiobiLocal "$@"' fish-compat $argv
end
function fuck
    zsh -ic 'eval "$(thefuck --alias)"; fuck "$@"' fish-compat $argv
end
