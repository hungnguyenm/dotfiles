# Path to oh-my-zsh configuration
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="mh"

# Configs

# - Disable auto title
DISABLE_AUTO_TITLE=true

# - Turn on interactive comments
setopt interactivecomments

# - Enable autocompletion
autoload -U compinit
compinit

# - Display dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(common-aliases git gitignore macports osx z) 

source $ZSH/oh-my-zsh.sh

# Path
PATH="/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$HOME/bin:$PATH"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"
# - OSX - sage
PATH="$PATH:/Applications/sage"

export PATH