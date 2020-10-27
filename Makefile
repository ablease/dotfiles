.DEFAULT_GOAL := show-help
THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR := $(shell dirname $(realpath $(THIS_FILE)))

.PHONY: show-help
# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.
## This help screen
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

.PHONY: setup
## Installs dotfiles
setup: brew zsh git tmux smith go-tools vscode-extensions cf-plugins spacevim repos fonts allow-internet


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
	gpg --import <(lpass show "Personal/GitHub GPG Key" --notes)
	mkdir -p $(HOME)/.ssh
	lpass show "Personal/GitHub SSH Key" --notes > $(HOME)/.ssh/ssh-key
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
ifneq ($(shell which cred-alert-cli), /usr/local/bin/cred-alert-cli)
	curl -f https://s3.amazonaws.com/cred-alert/cli/current-release/cred-alert-cli_darwin > /usr/local/bin/cred-alert-cli && chmod +x /usr/local/bin/cred-alert-cli
endif
	cred-alert-cli update

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

.PHONY: smith
## Add smith and token hook
smith:
	go get -u github.com/pivotal/smith
	ln -f $(ROOT_DIR)/smith-token-hook.sh $(HOME)/.smith-token-hook.sh

.PHONY: go-tools
## Install golang tools
go-tools:
	go get -u github.com/onsi/ginkgo/ginkgo \
		github.com/onsi/gomega

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

.PHONY: cf-plugins
## Install cf-cli plugins
cf-plugins:
ifneq ($(cf list-plugin-repos | grep CF-Community | wc -l), 1)
	cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org/
endif
	cf install-plugin "Firehose Plugin" -r CF-Community -f
	cf install-plugin "log-cache" -r CF-Community -f
	cf install-plugin "log-stream" -r CF-Community -f

.PHONY: spacevim
## Install spacevim
spacevim:
	curl -sLf https://spacevim.org/install.sh | bash
	rm $(HOME)/.SpaceVim.d/init.toml
	rm $(HOME)/.Spacevim.d/autoload
	ln -s $(ROOT_DIR)/spacevim/autoload $(HOME)/.Spacevim.d
	ln -s $(ROOT_DIR)/spacevim/init.toml $(HOME)/.Spacevim.d

.PHONY: repos
## Clone git repos
repos:
	ln -f $(ROOT_DIR)/mrconfig $(HOME)/.mrconfig
	cd $(HOME) && \
		mr update -q -j 4 --rebase --autostash

.PHONY: fonts
## Install patched fonts
fonts:
	# clone
	git clone https://github.com/powerline/fonts.git --depth=1
	# install
	$(ROOT_DIR)/fonts/install.sh
	# clean-up a bit
	rm -rf $(ROOT_DIR)/fonts/

.PHONY: allow-internet
## Allow executables from the internet
allow-internet:
	sudo spctl --master-disable
