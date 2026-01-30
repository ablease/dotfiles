# My dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

- **zsh**: Shell configuration (`.zshrc`, `.zshenv`) with oh-my-zsh
- **nvim**: Neovim configuration using [LazyVim](https://lazyvim.org)
- **Brewfile**: Homebrew packages and casks

## Installation

On a new machine:

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles

# Run the install script
cd ~/.dotfiles
./install.sh
```

The install script will:
1. Install all Homebrew packages from the Brewfile
2. Create symlinks for all configuration files using stow

## Manual setup

If you prefer to set things up manually:

```bash
# Install packages
brew bundle

# Symlink individual configs
stow zsh
stow nvim

# Or symlink everything at once
stow */
```

## Uninstalling

To remove symlinks:

```bash
cd ~/.dotfiles
stow -D zsh
stow -D nvim
```