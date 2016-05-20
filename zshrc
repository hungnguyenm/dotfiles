# Path to oh-my-zsh configuration
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom/

# Aliases
alias reload="echo 'reload help:\n\r\n\rreloadzsh: reload zsh\n\rreloadtmux: reload tmux'"
alias reloadzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias reloadtmux="source-file ~/.tmux.conf && echo 'tmux config reloaded from ~/.tmux.conf'"

# Path
PATH="/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$HOME/bin:$PATH"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"
# - OSX - sage
PATH="$PATH:/Applications/sage"

export PATH
export EDITOR=vim

# Configs
ZSH_THEME="hung"
DEFAULT_USER=hung

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
plugins=(common-aliases git macports osx tmux z)

source $ZSH/oh-my-zsh.sh