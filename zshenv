export PATH=/usr/local/sbin:$PATH

# Setup Go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

export PATH=$PATH:$HOME/workspace/rabbitmq-tile-home/bin

# Capybara Webkit needs special Qt starting with XCode 10
export PATH=$PATH:$HOME/Qt5.5.0/5.5/clang_64/bin

export PATH=$PATH:/usr/local/kubebuilder/bin