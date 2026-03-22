# dotfiles

Personal dotfiles and machine bootstrap for macOS and Linux.

## Quick Start

```bash
git clone https://github.com/milroc/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## What it does

**macOS:**
- Installs Xcode Command Line Tools
- Installs Homebrew and all packages/apps from `Brewfile`
- Applies macOS defaults (if `.macos` exists)

**Linux:**
- Installs CLI tools from `packages.txt` via apt/dnf/pacman/apk

**Both:**
- Installs Oh-My-Zsh, NVM + Node, pyenv
- Symlinks shell configs (`.zshrc`, `.bash_profile`, `.profile`)
- Symlinks Claude Code config (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`)

## Files

| File | Purpose |
|------|---------|
| `bootstrap.sh` | Cross-platform setup entry point |
| `Brewfile` | macOS Homebrew packages and cask apps |
| `packages.txt` | Linux CLI packages |
| `.zshrc` | Zsh configuration |
| `.alias` | Shell aliases (shared across zsh/bash) |
| `.bash_profile` | Bash profile (sources .bashrc) |
| `.macos` | macOS system defaults (optional) |
| `claude/CLAUDE.md` | Personal Claude Code preferences (symlinked to `~/.claude/`) |
| `claude/settings.json` | Claude Code plugin/permission settings (symlinked to `~/.claude/`) |

## Customizing the Brewfile

Review and uncomment cask apps you want. Run `brew bundle install` to apply changes:

```bash
brew bundle install --file=~/dotfiles/Brewfile
```

## Future: chezmoi migration

This repo is structured to migrate cleanly into [chezmoi](https://www.chezmoi.io/) when multi-machine templating is needed.
