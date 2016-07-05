# Path to oh-my-zsh configuration
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom/

# Enable 256-color
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
fi

# Aliases
alias reload="echo 'reload help:\n\r\n\rreloadzsh: reload zsh\n\rreloadtmux: reload tmux'"
alias reloadzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias reloadtmux="source-file ~/.tmux.conf && echo 'tmux config reloaded from ~/.tmux.conf'"

alias tn="tmux new-session"
alias tcc="tmux -CC"
alias tlk="tmux list-keys"

function sai() { sudo apt-get install "$*"; }
alias sap="sudo apt-get update"
alias sad="sudo apt-get upgrade"

alias cdu="cd .."
alias cduu="cd ../.."
alias cduuu="cd ../../.."

alias emacs="emacs -nw"

function xcopy() { xsel --clipboard < "$*"; }
function xover() { xsel --clipboard > "$*"; }
function xpaste() { xsel --clipboard >> "$*"; }

# Path
PATH="/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$HOME/bin:$PATH"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"
# - OSX - sage
PATH="$PATH:/Applications/sage"

# - LD_LIBRARY_PATH ~ for RTI DDS
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/hung/exe/rti_connext_dds-5.2.3/lib/x64Linux3gcc4.8.2"

export PATH
export EDITOR=vim

# Configs
ZSH_THEME="hung"
DEFAULT_USER=hung

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
