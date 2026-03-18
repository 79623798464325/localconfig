#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=false

# --- Flags ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force|--yes) FORCE=true; shift ;;
        -h|--help) echo "Usage: ./bootstrap.sh [-f|--force]"; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# --- OS Detection ---
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      error "Unsupported OS: $OS"; exit 1 ;;
esac
info "Detected platform: $PLATFORM"

# --- Symlink helper ---
link_file() {
    local src="$1" dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir"
        info "Created directory: $dest_dir"
    fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        info "Already linked: $dest"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if $FORCE; then
            local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
            mv "$dest" "$backup"
            info "Backed up: $backup"
        else
            warn "$dest already exists"
            read -rp "     Overwrite? (y/n/b=backup) " choice
            case "$choice" in
                y|Y) rm -f "$dest" ;;
                b|B)
                    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
                    mv "$dest" "$backup"
                    info "Backed up to $backup"
                    ;;
                *) warn "Skipping $dest"; return ;;
            esac
        fi
    fi

    ln -sf "$src" "$dest"
    info "Linked: $dest -> $src"
}

# --- Dependency checker ---
check_cmd() {
    if command -v "$1" &>/dev/null; then
        info "$1 found: $(command -v "$1")"
    else
        warn "$1 not found — install with: $2"
    fi
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

# --- Zsh plugins ---
info "Setting up zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
    local name="$1" url="$2"
    local dest="$ZSH_CUSTOM/plugins/$name"
    if [ -d "$dest" ]; then
        info "$name already installed"
    else
        info "Installing $name..."
        git clone --depth 1 "$url" "$dest"
        info "$name installed"
    fi
}

clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

# --- VS Code ---
info "Setting up VS Code..."
if [[ "$PLATFORM" == "macos" ]]; then
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_DIR="$HOME/.config/Code/User"
fi

if [ -d "$VSCODE_DIR" ]; then
    link_file "$REPO_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
else
    warn "VS Code config directory not found ($VSCODE_DIR), skipping"
fi

# --- Dependency check ---
echo ""
info "Checking dependencies..."

check_cmd tmux "brew install tmux"
check_cmd zsh "brew install zsh"
check_cmd git "brew install git"
check_cmd code "Install VS Code and add 'code' to PATH"

if [ -d "$HOME/.oh-my-zsh" ]; then
    info "oh-my-zsh found"
else
    warn "oh-my-zsh not found — install: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
fi

if [[ "$PLATFORM" == "macos" ]]; then
    if [ -d "/opt/homebrew/opt/powerlevel10k" ] || [ -d "/usr/local/opt/powerlevel10k" ]; then
        info "powerlevel10k found"
    else
        warn "powerlevel10k not found — install: brew install powerlevel10k"
    fi
else
    if [ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
        info "powerlevel10k found"
    else
        warn "powerlevel10k not found — install: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM}/themes/powerlevel10k"
    fi
fi

echo ""
info "Bootstrap complete! Open a new terminal to see changes."
