# localconfig

Personal dotfiles and editor settings.

## What's included

- **tmux/** — tmux config with 3-pane auto-layout, vi mode, mouse support
- **zsh/** — zshrc + Powerlevel10k theme config
- **vscode/** — VS Code editor settings

## Setup

```bash
git clone git@github.com:79623798464325/localconfig.git
cd localconfig
./bootstrap.sh
```

The bootstrap script symlinks configs to their expected locations and checks for missing dependencies. It will prompt before overwriting existing files (with an option to back up).

## Dependencies

- [tmux](https://github.com/tmux/tmux)
- [oh-my-zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [VS Code](https://code.visualstudio.com/)
