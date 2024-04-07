export PATH=/usr/local/sbin:$PATH

# Setup Go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Setup Gpg
export GPG_TTY=$(tty)

# Capybara Webkit needs special Qt starting with XCode 10
export PATH=$PATH:$HOME/Qt5.5.0/5.5/clang_64/bin

# Setup Kubebuilder
export PATH=$PATH:/usr/local/kubebuilder/bin

# Mac uses an ancient version of ruby, use homebrew ruby instead
export PATH=/usr/local/opt/ruby/bin:$PATH

# Setup Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
source "$HOME/.cargo/env"

# Use Gcloud Auth Plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# For Lunarvim, put .local/bin in path
export PATH=/Users/ablease/.local/bin:$PATH
