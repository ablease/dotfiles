#!/usr/bin/env bash
set -euo pipefail

log() { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[x]\033[0m %s\n" "$*" >&2; }

append_unique_line() {
  local line="$1"
  local file="$2"

  grep -Fqx "$line" "$file" || {
    echo "$line" >>"$file"
    echo "[add] $line"
  }
}

install_lazyvim() {
  TARGET_DIR="~/.config/nvim"
  REPO_URL="https://github.com/LazyVim/starter"

  if [[ -d "$TARGET_DIR" ]]; then
    log "LazyVim config found, skipping!"
  else
    log "LazyVim starter not found. Installing LazyVim via git clone..."
    git clone "$REPO_URL" "$TARGET_DIR"
    rm -rf $TARGET_DIR/.git
    nvim
  fi
}

configure_shell_aliases() {
  log "Setting up shell aliases..."
  append_unique_line 'vim=nvim' "$HOME/.zshrc"
}

upgrade_pip3() {
  log "Upgrading pip3..."
  python3 -m pip install --upgrade pip
}

main() {
  install_lazyvim
  configure_shell_aliases
  upgrade_pip3() {}
  log "All done! You may need to open a new terminal for PATH changes to take effect."
}

main "$@"
