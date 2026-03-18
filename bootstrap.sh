#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# Prompt before overwriting an existing file
link_file() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            info "Already linked: $dest"
            return
        fi
        warn "$dest already exists"
        read -rp "     Overwrite? (y/n/b=backup) " choice
        case "$choice" in
            y|Y) rm -f "$dest" ;;
            b|B) mv "$dest" "${dest}.bak"; info "Backed up to ${dest}.bak" ;;
            *)   warn "Skipping $dest"; return ;;
        esac
    fi
    ln -sf "$src" "$dest"
    info "Linked: $dest -> $src"
}

echo ""
echo "========================================"
echo "  localconfig bootstrap"
echo "========================================"
echo ""

# --- Tmux ---
info "Setting up tmux..."
link_file "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- Zsh ---
info "Setting up zsh..."
link_file "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# --- VS Code ---
info "Setting up VS Code..."
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_DIR" ]; then
    link_file "$REPO_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
else
    warn "VS Code config directory not found, skipping"
fi

# --- Dependencies check ---
echo ""
info "Checking dependencies..."

check_cmd() {
    if command -v "$1" &>/dev/null; then
        info "$1 found: $(command -v "$1")"
    else
        warn "$1 not found — install with: $2"
    fi
}

check_cmd tmux "brew install tmux"
check_cmd zsh "brew install zsh"
check_cmd code "Install VS Code and add 'code' to PATH"

if [ -d "$HOME/.oh-my-zsh" ]; then
    info "oh-my-zsh found"
else
    warn "oh-my-zsh not found — install: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
fi

if command -v brew &>/dev/null && brew list powerlevel10k &>/dev/null 2>&1; then
    info "powerlevel10k found"
else
    warn "powerlevel10k not found — install: brew install powerlevel10k"
fi

echo ""
info "Bootstrap complete! Open a new terminal to see changes."
