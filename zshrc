export ZSH="/Users/mgary/.oh-my-zsh"

ZSH_THEME="custom-refined"

DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    autojump
    aws
    brew
    bundler
    cargo
    colored-man-pages
    colorize
    direnv
    docker
    gcloud
    git
    golang
    rust
    terraform
    thefuck
    yarn
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

unsetopt correct_all

HISTSIZE=1000000
SAVEHIST=1000000

# fzf
export FZF_DEFAULT_OPTS="--extended --cycle --reverse --ansi"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# direnv
eval "$(direnv hook zsh)"
alias da="direnv allow"

# Always use nvim
export EDITOR=nvim
alias vim="nvim"
alias vi="nvim"

alias ll="ls -al"
alias cat="ccat"

alias pip="pip3"

alias k="kubectl"

# Use gnumake
alias make="/usr/local/bin/make"

# git short commands
alias gp="git push"
alias gap="git add -p"
alias gs="git switch"
alias gpr="git pull --rebase"
export GIT_DUET_GLOBAL=true
export GIT_DUET_ROTATE_AUTHOR=1

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

export PATH=/usr/local/opt/ruby/bin:$PATH
