# Path to oh-my-zsh configuration
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom

# ROS
if [[ -f /opt/ros/indigo/setup.zsh && -r /opt/ros/indigo/setup.zsh ]]; then
  source /opt/ros/indigo/setup.zsh
fi
if [[ -f /opt/ros/kinetic/setup.zsh && -r /opt/ros/kinetic/setup.zsh ]]; then
  source /opt/ros/kinetic/setup.zsh
fi
if [[ -f ~/catkin_ws/devel/setup.zsh && -r ~/catkin_ws/devel/setup.zsh ]]; then
  source ~/catkin_ws/devel/setup.zsh
fi
# ROS -- server's dependent ROS config
if [[ -f ~/iros.zsh && -r ~/iros.zsh ]]; then
  source ~/iros.zsh
fi

# Update tmux environment variables
if [ -n "$TMUX" ]; then
  function tmux_refresh {
    TMUX_ENV_SSH_AUTH_SOCK=$(tmux show-environment | grep "^SSH_AUTH_SOCK")
    [[ -n "$TMUX_ENV_SSH_AUTH_SOCK" ]] && export "$TMUX_ENV_SSH_AUTH_SOCK"

    TMUX_ENV_DISPLAY=$(tmux show-environment | grep "^DISPLAY")
    [[ -n "$TMUX_ENV_DISPLAY" ]] && export "$TMUX_ENV_DISPLAY"
  }
else
  function tmux_refresh { }
fi

function preexec {
    tmux_refresh
}

# Enable 256-color
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
fi

# Aliases
alias reload="echo 'reload help:\n\r\n\rreloadzsh: reload zsh\n\rreloaddotfiles: redownload dotfiles'"
alias reloadzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"
alias reloaddotfiles="rm -rf ~/dotfiles; git clone --recursive https://github.com/hungnguyenm/dotfiles"

alias tn="tmux new-session"
alias tcc="tmux -CC"
alias tlk="tmux list-keys"

case `uname` in
  Darwin)
    alias sshfs-u="umount"
    ;;
  Linux)
    alias sshfs-u="fusermount -u"
    ;;
esac

function sai() { sudo apt-get install "$*"; }
alias sap="sudo apt-get update"
alias sad="sudo apt-get upgrade"

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

# - Ubuntu - android-studio
PATH="$PATH:$HOME/opt/android-studio/bin"
PATH="$PATH:$HOME/Android/Sdk/platform-tools"

# - LD_LIBRARY_PATH ~ for RTI DDS
#LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/hung/exe/rti_connext_dds-5.2.3/lib/x64Linux3gcc4.8.2"

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

# ssh-agent
zstyle :omz:plugins:ssh-agent agent-forwarding on

# zsh-git-prompt
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}
autoload -U add-zsh-hook

# Plugins
plugins=(common-aliases ssh-agent git osx tmux z zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
