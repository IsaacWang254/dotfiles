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

# Catppuccin Mocha for the tools that read their palette from the
# environment rather than a config file. See fish/conf.d/catppuccin-theme.fish
# for fish's own colours, and eza/theme.yml for the file-listing palette.
set -gx EZA_CONFIG_DIR $HOME/.config/eza
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4"

# Concise Nix segment for bobthefish.
function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = 'no' -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns N ' '

    set_color normal
end

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
alias reload='source ~/.config/fish/conf.d/catppuccin-theme.fish; source ~/.config/fish/config.fish'

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
