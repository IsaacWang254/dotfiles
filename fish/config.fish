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

# Gruvbox Dark Hard for the tools that read their palette from the
# environment rather than a config file. fish's own colours come from its
# default theme (on top of Ghostty's Gruvbox ANSI palette), and eza/theme.yml
# holds the file-listing palette.
set -gx EZA_CONFIG_DIR $HOME/.config/eza
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#fb4934 \
--color=fg:#ebdbb2,header:#fb4934,info:#83a598,pointer:#8ec07c \
--color=marker:#fe8019,fg+:#ebdbb2,prompt:#fabd2f,hl+:#fb4934 \
--color=selected-bg:#504945 \
--color=border:#665c54,label:#ebdbb2"

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
