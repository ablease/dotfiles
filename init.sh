#!/usr/bin/env bash
set -euo pipefail

log()  { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*" >&2; }

require_macos() {
  if [[ "${OSTYPE:-}" != darwin* ]]; then
    err "This script is intended for macOS only."; exit 1
  fi
}

need_sudo() {
  # Ask for sudo up-front and keep it alive for the duration
  if command -v sudo >/dev/null 2>&1; then
    if ! sudo -v; then
      err "sudo privileges are required."; exit 1
    fi
    # Keep-alive: update existing `sudo` time stamp until the script finishes.
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  else
    warn "sudo not found; some steps may fail."
  fi
}

have_xcode_clt() {
  # Returns 0 if CLT appears installed
  xcode-select -p >/dev/null 2>&1 && return 0
  pkgutil --pkg-info=com.apple.pkg.CLTools_Executables >/dev/null 2>&1 && return 0
  return 1
}

install_xcode_clt() {
  if have_xcode_clt; then
    log "Xcode Command Line Tools already installed."
    return
  fi

  log "Installing Xcode Command Line Tools (this can take a few minutes)..."
  # Non-interactive CLT install using softwareupdate
  local inprog="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "$inprog"

  # Find the latest "Command Line Tools" product
  # Works across macOS versions by extracting the labeled product line
  local product
  product="$(softwareupdate -l 2>/dev/null | \
              sed -n 's/^[[:space:]]*\* Label: //p' | \
              grep -i 'Command Line Tools' | tail -n1 || true)"

  if [[ -z "${product:-}" ]]; then
    sudo rm -f "$inprog"
    err "Could not find 'Command Line Tools' in softwareupdate listings."
    err "Try running: xcode-select --install   (GUI prompt)"; exit 1
  fi

  # Install the identified CLT product
  if ! sudo softwareupdate -i "$product" -v; then
    sudo rm -f "$inprog"
    err "softwareupdate failed installing: $product"; exit 1
  fi
  sudo rm -f "$inprog"

  # Point xcode-select at the CommandLineTools path if needed
  if ! xcode-select -p >/dev/null 2>&1; then
    sudo xcode-select --switch /Library/Developer/CommandLineTools || true
  fi

  log "Xcode Command Line Tools installed."
}

brew_prefix_target() {
  # Echo expected brew prefix per architecture
  if [[ "$(uname -m)" == "arm64" ]]; then
    printf "/opt/homebrew"
  else
    printf "/usr/local"
  fi
}

brew_is_installed() {
  command -v brew >/dev/null 2>&1
}

install_homebrew() {
  if brew_is_installed; then
    log "Homebrew already installed at: $(brew --prefix 2>/dev/null || true)"
    return
  fi

  log "Installing Homebrew..."
  # Official installer; non-interactive when possible
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure Brew is on PATH for this session
  ensure_brew_path

  log "Homebrew installation complete."
}

ensure_brew_path() {
  local target_prefix shell_rc
  target_prefix="$(brew_prefix_target)"
  # Determine user shell profile to modify
  # Prefer zsh (default on modern macOS), fallback to bash
  if [[ -n "${ZSH_VERSION:-}" || "${SHELL:-}" =~ zsh$ ]]; then
    shell_rc="$HOME/.zprofile"
  elif [[ -n "${BASH_VERSION:-}" || "${SHELL:-}" =~ bash$ ]]; then
    shell_rc="$HOME/.bash_profile"
  else
    # Fallback to .profile
    shell_rc="$HOME/.profile"
  fi

  # Brew's recommended PATH snippet
  local export_line
  if [[ "$target_prefix" == "/opt/homebrew" ]]; then
    export_line='eval "$(/opt/homebrew/bin/brew shellenv)"'
  else
    export_line='eval "$(/usr/local/bin/brew shellenv)"'
  fi

  # Apply to current shell
  if command -v brew >/dev/null 2>&1; then
    eval "$("$(command -v brew)" shellenv)"
  else
    # If brew not on PATH yet, try the expected location
    if [[ -x "$target_prefix/bin/brew" ]]; then
      eval "$("$target_prefix/bin/brew" shellenv)"
    fi
  fi

  # Persist to the user’s profile if not already present
  if [[ -f "$shell_rc" ]] && grep -Fq "$export_line" "$shell_rc"; then
    : # already present
  else
    log "Adding Homebrew to PATH in $shell_rc"
    {
      echo ""
      echo "# Added by setup-macos.sh on $(date)"
      echo "$export_line"
    } >> "$shell_rc"
  fi
}

install_or_update_git() {
  log "Installing/upgrading Git via Homebrew..."
  if brew list --formula git >/dev/null 2>&1; then
    brew upgrade git || true
  else
    brew install git
  fi
  log "Git version: $(git --version)"
}

configure_git() {
  log "Installing/upgrading Git via Homebrew..."
  git config --global user.name "Alex Blease"
  git config --global user.email "alexblease@gmail.com"
  git config --global alias.st status
  git config --global alias.co checkout
  git config --global alias.ds "diff --staged"
  git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

main() {
  require_macos
  need_sudo
  install_xcode_clt
  install_homebrew
  ensure_brew_path
  install_or_update_git
  configure_git
  install_oh_my_zsh
  log "All done! You may need to open a new terminal for PATH changes to take effect."
}

main "$@"

