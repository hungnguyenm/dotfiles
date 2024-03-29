# Re-source zshenv in case values were overwritten (in arch and macOS)
if [[ -f ~/.zshenv ]]; then
  source ~/.zshenv
elif [[ -f ~/dotfiles/zshenv ]]; then
  source ~/dotfiles/zshenv
else
  echo "Cannot find zshenv, environment may not be setup correctly."
fi

# Prepare directories
mkdir -p $ZSH_CACHE_DIR $ZSH_VIM_BACKUPS $ZSH_VIM_SWAPS $ZSH_VIM_UNDO $ZSH_VIM_TMP

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

# Google Cloud SDK
if [[ -f ~/opt/google-cloud-sdk/completion.zsh.inc ]]; then
  source ~/opt/google-cloud-sdk/completion.zsh.inc
fi
if [[ -f ~/opt/google-cloud-sdk/path.zsh.inc ]]; then
  source ~/opt/google-cloud-sdk/path.zsh.inc
fi

# Enable 256-color
if [ "$TERM" = "xterm" ]; then
  export TERM="xterm-256color"
fi
[[ $TMUX != "" ]] && export TERM="screen-256color"

# Configs
ZSH_THEME="hung"
DEFAULT_USER=hung

# - Turn on interactive comments
setopt interactivecomments

# - Enable spelling correction
#setopt correct

# - Enable editor for command line
autoload -U edit-command-line

# - Display dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# - History optimization
setopt histignoredups

# - Extended globbing
setopt extended_glob

# - Disable error for null globbing
setopt null_glob

# - Enable preserve partial line (enabled by default, this is for eniac)
setopt prompt_cr
setopt prompt_sp

# ssh-agent
zstyle :omz:plugins:ssh-agent agent-forwarding on

# zsh-git-prompt
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}
autoload -U add-zsh-hook

# zsh-mv
autoload -U zmv

# git-auto-fetch
GIT_AUTO_FETCH_INTERVAL=3600 #in seconds

# Plugins
plugins=(common-aliases ssh-agent git git-auto-fetch debian macos archlinux yum systemd sudo docker docker-compose kubectl gradle pip golang rsync sublime tmux z colorize extract conda zsh-syntax-highlighting)

# Finally, source local files
for local_file ($DOTFILES_DIR/local/*.zsh(.N)); do
  source $local_file
done

# and source OMZ
source $ZSH/oh-my-zsh.sh

# Binding keys (some overwritten)
bindkey "^W" beginning-of-line
bindkey "^B" backward-delete-word
bindkey "^F" forward-word
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward

## ** SDKMAN needs to be loaded at the end, also requires clobber to be enabled
# -- Enable clobber
setopt clobber

# -- Load SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# - Prevent accidentally overwriting an existing file. Use >! to force overwrite
# -- Put at the end to avoid error during loading previous scripts
setopt noclobber