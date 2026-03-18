# Auto-start tmux on terminal open (skip in VS Code, nested tmux, or non-interactive shells)
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ $- == *i* ]]; then
    exec tmux new-session -A -s main
fi

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — Powerlevel10k loaded directly below

plugins=(
    git                        # git aliases (gst, gco, gp, etc.)
    z                          # jump to frecent directories (z foo)
    zsh-autosuggestions        # fish-like inline suggestions
    zsh-syntax-highlighting    # command highlighting as you type
)

source "$ZSH/oh-my-zsh.sh"

# --- Powerlevel10k ---
source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- History ---
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS       # Don't show duplicates when searching
setopt HIST_REDUCE_BLANKS      # Remove unnecessary blanks
setopt SHARE_HISTORY           # Share history across all sessions
setopt INC_APPEND_HISTORY      # Write to history immediately, not on exit

# --- Completion ---
setopt AUTO_CD                 # cd by typing directory name alone
setopt CORRECT                 # Suggest corrections for typos

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Aliases ---
alias ll="ls -lAFh"
alias la="ls -A"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias md="mkdir -p"
alias rr="rm -rf"
alias c="clear"
alias reload="exec zsh"
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias tmuxrc='${EDITOR:-vim} ~/.tmux.conf'

# Git shortcuts (beyond oh-my-zsh git plugin)
alias gs="git status -sb"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph -20"
alias gca="git commit --amend --no-edit"
alias gpf="git push --force-with-lease"

# --- VS Code Shell Integration ---
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    unset RPROMPT
    unset RPS1
    [[ -f "$(code --locate-shell-integration-path zsh)" ]] && \
        . "$(code --locate-shell-integration-path zsh)"
fi
