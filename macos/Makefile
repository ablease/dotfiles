.DEFAULT_GOAL := show-help
THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR := $(shell dirname $(realpath $(THIS_FILE)))
GPG_SIGNING_KEY := $(shell lpass show --password gpg-signing-key)

.PHONY: show-help
# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.
## This help screen
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

.PHONY: setup
## Installs dotfiles
setup: brew zsh git tmux rust vscode-extensions fonts allow-internet lunarvim lunarvim-config


.PHONY: zsh
## Installs oh-my-zsh and configures zsh dotfiles
zsh:
	# Install oh-my-zsh if not present
	if [ ! -d "$(HOME)/.oh-my-zsh" ]; then \
		curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh && \
		rm $(HOME)/.zshrc; \
	fi
	# Update zsh dotfiles
	ln -f $(ROOT_DIR)/zshrc $(HOME)/.zshrc
	ln -f $(ROOT_DIR)/zshenv $(HOME)/.zshenv
	# Add custom theme
	ln -f $(ROOT_DIR)/custom-refined.zsh-theme $(HOME)/.oh-my-zsh/custom/themes/custom-refined.zsh-theme
	# Add zsh-syntax-highlighting plugin
	if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		git clone git@github.com:zsh-users/zsh-syntax-highlighting.git $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; fi
	cd $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull

.PHONY: brew
## Installs homebrew and dependencies in Brewfile
brew:
ifneq ($(shell which brew), /usr/local/bin/brew)
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
endif
	brew update
	brew tap Homebrew/bundle
	ln -f $(ROOT_DIR)/Brewfile $(HOME)/.Brewfile
	brew bundle --global
	brew cleanup

.PHONY: keys
## Loads SSH and GPG keys for interacting with GitHub. Interactive
keys: brew
	gpg --import <(lpass show "Code/GitHub GPG Key" --notes)
	mkdir -p $(HOME)/.ssh
	lpass show "Code/GitHub SSH Key" --notes > $(HOME)/.ssh/ssh-key
	eval "$(ssh-agent -s )" && ssh-add -D && ssh-add $(HOME)/.ssh/ssh-key

.PHONY: git
## Configures git dotfiles
git:
	ln -f $(ROOT_DIR)/gitconfig $(HOME)/.gitconfig
	ln -f $(ROOT_DIR)/gitignore_global $(HOME)/.gitignore_global
	if [ ! -d $(HOME)/workspace ]; then mkdir -p $(HOME)/workspace; fi
	if [ ! -d $(HOME)/workspace/git-hooks-core ]; then \
		git clone git@github.com:pivotal-cf/git-hooks-core.git $(HOME)/workspace/git-hooks-core; fi
	cd $(HOME)/workspace/git-hooks-core && git pull
	git config --global user.signingkey $(GPG_SIGNING_KEY)

.PHONY: tmux
## Configures tmux
tmux:
	ln -f $(ROOT_DIR)/tmux.conf $(HOME)/.tmux.conf
	if [ ! -d $(HOME)/.tmux/plugins/tpm ]; then \
		mkdir -p $(HOME)/.tmux/plugins && \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm && \
		$(HOME)/.tmux/plugins/tpm/bin/install_plugins all; else \
		cd $(HOME)/.tmux/plugins/tpm && \
		git pull && \
		$(HOME)/.tmux/plugins/tpm/bin/update_plugins all; fi

.PHONY: rust
rustupcmd := $(shell command -v rustup 2> /dev/null)
## Install rust and rust toolchain
rust:
ifndef rustupcmd
	echo "rustup could not be found"
	echo "performing first install of rust!"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif
	rustup update

.PHONY: vscode-extensions
## Install vscode extensions
vscode-extensions:
	code --install-extension minherz.copyright-inserter
	code --install-extension ms-azuretools.vscode-docker
	code --install-extension pgourlain.erlang
	code --install-extension golang.go
	code --install-extension hashicorp.terraform
	code --install-extension johnpapa.vscode-peacock
	code --install-extension rebornix.ruby
	code --install-extension castwide.solargraph
	code --install-extension timonwong.shellcheck
	code --install-extension sonarsource.sonarlint-vscode
	code --install-extension redhat.vscode-xml
	code --install-extension gamunu.vscode-yarn

.PHONY: fonts
## Install patched fonts
fonts:
	# clone
	git clone https://github.com/ronniedroid/getnf.git

	# install
	$(ROOT_DIR)/getnf/install.sh

	# clean-up a bit
	rm -rf $(ROOT_DIR)/getnf/

.PHONY: allow-internet
## Allow executables from the internet still works in OS Ventura 13.6.3!
allow-internet:
	sudo spctl --master-disable

.PHONY: lunarvim
## Install lvim if not already installed
lunarvim:
ifneq ($(shell which git), /usr/local/bin/git)
	echo "git not installed. Go get it `brew install git`"
endif
ifneq ($(shell which lazygit), /usr/local/bin/lazygit)
	echo "Lazygit not installed. Go get it `brew install lazygit`"
endif
	curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash

.PHONY: lunarvim-config
## Copy over lvim config
lunarvim-config:
	cp $(ROOT_DIR)/lvim/config.lua $(HOME)/.config/lvim/
