export ZSH="/Users/${USERNAME}/.oh-my-zsh"

ZSH_THEME="frisk"

DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    brew
    bundler
    colored-man-pages
    colorize
    docker
    git
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

unsetopt correct_all

HISTSIZE=1000000
SAVEHIST=1000000

# Always use lazyvim
export EDITOR=nvim
alias vim="nvim"
alias vi="nvim"

alias ll="ls -al"

alias pip="pip3"

# git short commands
alias gp="git push"
alias gap="git add -p"
alias gs="git switch"
alias gpr="git pull --rebase"

export LPASS_AGENT_TIMEOUT=28800

# Add zsh completion
fpath+=("$(brew --prefix)/share/zsh-completions")
source "$(brew --prefix)/share/zsh/site-functions"

# Tweak zsh highlighting colors
export ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
export ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=043,bold'
export ZSH_HIGHLIGHT_STYLES[cursor]='bg=049'
export ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=133'
export ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=198'
