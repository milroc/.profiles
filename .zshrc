
# PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Homebrew (macOS)
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Oh-My-Zsh plugins
plugins=(git brew github python grep)

# Prompt
export PS1="%F{208}[%m]%f %F{226}%~%f: "

# Aliases
if [ -f ~/dotfiles/.alias ]; then
  source ~/dotfiles/.alias
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# thefuck
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
fi
