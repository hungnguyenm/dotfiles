# Re-source zshenv in case values were overwritten (in arch and macOS)
if [[ -f ~/.zshenv ]]; then
  source ~/.zshenv
elif [[ -f ~/dotfiles/zshenv ]]; then
  source ~/dotfiles/zshenv
else
  echo "Cannot find zshenv, environment may not be setup correctly."
fi

# Prepare directories
mkdir -p $ZSH_CACHE_DIR $ZSH_VIM_BACKUPS $ZSH_VIM_SWAPS $ZSH_VIM_UNDO

# Path to oh-my-zsh configuration
ZSH=$DOTFILES_DIR/oh-my-zsh
ZSH_CUSTOM=$DOTFILES_DIR/zsh_custom

# Cache paths
_Z_DATA=$ZSH_CACHE_DIR/.z
HISTFILE=$ZSH_CACHE_DIR/.zsh_history

if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
else
  SHORT_HOST=${HOST/.*/}
fi
ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"

# Additional completions
fpath=($ZSH_CUSTOM/completions $fpath)

# ROS
if [[ -f /opt/ros/indigo/setup.zsh ]]; then
  source /opt/ros/indigo/setup.zsh
fi
if [[ -f /opt/ros/kinetic/setup.zsh ]]; then
  source /opt/ros/kinetic/setup.zsh
fi
if [[ -f ~/catkin_ws/devel/setup.zsh ]]; then
  source ~/catkin_ws/devel/setup.zsh
fi

# Enable 256-color
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
fi

# Configs
ZSH_THEME="hung"
DEFAULT_USER=hung

# - Turn on interactive comments
setopt interactivecomments

# - Enable autocompletion - no need, oh-my-zsh will call this anw
#autoload -U compinit
#compinit

# - Enable spelling correction
setopt correct

# - Display dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# - Prevent accidentally overwriting an existing file. Use >! to force overwrite
setopt noclobber

# - History optimization
setopt histignoredups

# - Extended globbing
setopt extended_glob

# ssh-agent
zstyle :omz:plugins:ssh-agent agent-forwarding on

# zsh-git-prompt
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}
autoload -U add-zsh-hook

# git-auto-fetch
GIT_AUTO_FETCH_INTERVAL=3600 #in seconds

# Plugins
plugins=(common-aliases ssh-agent git git-auto-fetch osx debian systemd sudo tmux z extract gradle docker sublime colorize zsh-syntax-highlighting)


# Finally, source local files
for local_file ($DOTFILES_DIR/local/*.zsh(.N)); do
  source $local_file
done

# and source OMZ
source $ZSH/oh-my-zsh.sh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/hung/.sdkman"
[[ -s "/home/hung/.sdkman/bin/sdkman-init.sh" ]] && source "/home/hung/.sdkman/bin/sdkman-init.sh"
