#!/bin/bash

set -e  # Exit on error

echo "🚀 Setting up dotfiles..."

# Check if we're in the dotfiles directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install Homebrew packages
echo "📦 Installing Homebrew packages..."
brew bundle

# Stow configurations
echo "🔗 Creating symlinks for configurations..."
stow zsh
stow nvim

echo "✅ Dotfiles setup complete!"
echo ""
echo "Note: You may need to restart your shell for zsh changes to take effect."
