#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
SKIP_BREW=false
ONLY_BREW=false

for arg in "$@"; do
  case "$arg" in
    --skip-brew) SKIP_BREW=true ;;
    --only-brew) ONLY_BREW=true ;;
  esac
done

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
success() { printf "\033[0;32m[ok]\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }

# =============================================================================
# macOS-specific setup
# =============================================================================
setup_macos() {
  # Xcode Command Line Tools
  if ! xcode-select -p &> /dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after Xcode CLI tools finish installing..."
    read -n 1 -s
  fi
  success "Xcode Command Line Tools installed"

  # Homebrew
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"

  # Brewfile
  if $SKIP_BREW; then
    warn "Skipping Brewfile (--skip-brew)"
  elif [ -f "$DOTFILES_DIR/Brewfile" ]; then
    info "Updating Homebrew..."
    brew update
    brew upgrade
    info "Installing packages from Brewfile..."
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
    success "Brewfile packages installed"
  fi

  # macOS defaults
  if [ -f "$DOTFILES_DIR/.macos" ]; then
    info "Applying macOS defaults..."
    source "$DOTFILES_DIR/.macos"
    success "macOS defaults applied"
  fi
}

# =============================================================================
# Linux-specific setup
# =============================================================================
setup_linux() {
  # Detect package manager
  if command -v apt-get &> /dev/null; then
    PKG_INSTALL="sudo apt-get install -y"
    sudo apt-get update -y
  elif command -v dnf &> /dev/null; then
    PKG_INSTALL="sudo dnf install -y"
  elif command -v pacman &> /dev/null; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
  elif command -v apk &> /dev/null; then
    PKG_INSTALL="sudo apk add"
  else
    warn "No supported package manager found (apt, dnf, pacman, apk)"
    return 1
  fi

  # Install packages from packages.txt
  if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    info "Installing packages from packages.txt..."
    grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$' | while read -r pkg; do
      $PKG_INSTALL "$pkg" || warn "Failed to install $pkg"
    done
    success "Linux packages installed"
  fi
}

# =============================================================================
# Shared setup (both macOS and Linux)
# =============================================================================
setup_shared() {
  # Zsh
  if ! command -v zsh &> /dev/null; then
    info "Installing zsh..."
    if [[ "$OS" == "Linux" ]]; then
      $PKG_INSTALL zsh
    fi
  fi
  success "zsh available"

  # Oh-My-Zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  success "Oh-My-Zsh installed"

  # NVM
  if [ ! -d "$HOME/.nvm" ]; then
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  success "NVM installed"

  # Node (latest LTS via NVM)
  if ! command -v node &> /dev/null; then
    info "Installing Node.js (LTS)..."
    nvm install --lts
  fi
  success "Node.js available"

  # pyenv
  if ! command -v pyenv &> /dev/null && [[ "$OS" == "Linux" ]]; then
    info "Installing pyenv..."
    curl https://pyenv.run | bash
  fi
  if command -v pyenv &> /dev/null; then
    success "pyenv available"
  fi

  # Symlink dotfiles
  info "Symlinking dotfiles..."
  ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  ln -sf "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
  ln -sf "$DOTFILES_DIR/.profile" "$HOME/.profile"
  success "Dotfiles symlinked"

  # Claude Code config
  info "Symlinking Claude Code config..."
  mkdir -p "$HOME/.claude"
  ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
  success "Claude Code config symlinked"

  # Claude Code skills
  if [ -d "$DOTFILES_DIR/claude/skills" ]; then
    info "Symlinking Claude Code skills..."
    mkdir -p "$HOME/.claude/skills"
    for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name="$(basename "$skill_dir")"
      ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
    done
    success "Claude Code skills symlinked"
  fi

  # Create .bashrc
  if [ ! -f "$HOME/.bashrc" ] || ! grep -q "dotfiles/.alias" "$HOME/.bashrc" 2>/dev/null; then
    info "Creating .bashrc..."
    cat > "$HOME/.bashrc" << 'BASHRC'
export PATH="/usr/local/bin:$PATH"
export PS1="\[\e[38;5;208m\][\h]\[\e[0m\] \[\e[38;5;226m\]\w\[\e[0m\]: "
if [ -f ~/dotfiles/.alias ]; then
  source ~/dotfiles/.alias
fi
BASHRC
    success ".bashrc created"
  fi
}

# =============================================================================
# Main
# =============================================================================
info "Bootstrapping on $OS..."

if $ONLY_BREW; then
  if [[ "$OS" != "Darwin" ]]; then
    warn "--only-brew is only supported on macOS"
    exit 1
  fi
  if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    info "Updating Homebrew..."
    brew update
    brew upgrade
    info "Installing packages from Brewfile..."
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
    success "Brewfile packages installed"
  fi
else
  case "$OS" in
    Darwin) setup_macos ;;
    Linux)  setup_linux ;;
    *)      warn "Unsupported OS: $OS" ;;
  esac

  setup_shared
fi

echo ""
success "Bootstrap complete! Open a new shell to apply changes."
