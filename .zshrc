
# Customize to your needs...
export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin

# Edited Section
# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx brew github python grep)

export PATH=$PATH:$HOME/spark

export PS1="%F{208}[%m]%f %F{226}%~%f: "
if [ -f ~/.profiles/.alias ]; then
    source ~/.profiles/.alias
fi
