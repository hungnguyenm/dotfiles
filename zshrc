# Path to oh-my-zsh configuration
DOTFILES_DIR=$HOME/dotfiles
ZSH=$DOTFILES_DIR/oh-my-zsh
ZSH_CUSTOM=$DOTFILES_DIR/zsh_custom

# Cache paths
mkdir -p ~/.zsh
ZSH_CACHE=$HOME/.zsh
ZSH_CACHE_DIR=$ZSH_CACHE
ZDOTDIR=$ZSH_CACHE
_Z_DATA=$ZSH_CACHE/.z
HISTFILE=$ZSH_CACHE/.zsh_history

ZSH_VIM_BACKUPS=$ZSH_CACHE_DIR/vim_backups
ZSH_VIM_SWAPS=$ZSH_CACHE_DIR/vim_swaps
ZSH_VIM_UNDO=$ZSH_CACHE_DIR/vim_undo
mkdir -p $ZSH_VIM_BACKUPS $ZSH_VIM_SWAPS $ZSH_VIM_UNDO

# Additional completions
fpath=($ZSH_CUSTOM/completions $fpath)

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

# Enable 256-color
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
fi

# Path
PATH="$HOME/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"
# - OSX - sage
PATH="$PATH:/Applications/sage"

# - Ubuntu - android-studio
PATH="$PATH:$HOME/opt/android-studio/bin"
PATH="$PATH:$HOME/Android/Sdk/platform-tools"

export PATH ZSH_VIM_BACKUPS ZSH_VIM_SWAPS ZSH_VIM_UNDO
export EDITOR=vim

# Configs
ZSH_THEME="hung"
DEFAULT_USER=hung

# - Turn on interactive comments
setopt interactivecomments

# - Enable autocompletion
autoload -U compinit
compinit

# - Enable spelling correction
setopt correct

# - Display dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# - Prevent accidentally overwriting an existing file. Use >! to force overwrite
setopt noclobber

# - History optimization
setopt histignoredups

# ssh-agent
zstyle :omz:plugins:ssh-agent agent-forwarding on

# zsh-git-prompt
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}
autoload -U add-zsh-hook

# git-auto-fetch
GIT_AUTO_FETCH_INTERVAL=3600 #in seconds

# Plugins
plugins=(common-aliases ssh-agent git git-auto-fetch osx debian tmux z extract gradle docker sublime colorize zsh-syntax-highlighting)


# Finally, source OMZ and update styles
source $ZSH/oh-my-zsh.sh
