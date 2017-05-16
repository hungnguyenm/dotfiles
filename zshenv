# Environment setup for all types of shell
export DOTFILES_DIR=$HOME/dotfiles
export ZSH_CACHE_DIR=$HOME/.zsh

export ZSH_VIM_BACKUPS=$ZSH_CACHE_DIR/vim_backups
export ZSH_VIM_SWAPS=$ZSH_CACHE_DIR/vim_swaps
export ZSH_VIM_UNDO=$ZSH_CACHE_DIR/vim_undo

export EDITOR=vim
export PRIVATE_FOLDER=$ZSH_CACHE_DIR/private
export PRIVATE_GIT="git@github.com:hungnguyenm/dotfiles_private.git"

# Path
PATH="$HOME/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
PATH="$PATH:$DOTFILES_DIR/scripts"

# - anaconda
PATH="$HOME/opt/anaconda3/bin:$PATH"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"

# - Ubuntu - android-studio
PATH="$PATH:$HOME/opt/android-studio/bin"
PATH="$PATH:$HOME/Android/Sdk/platform-tools"

# - Ubuntu - sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH

# Libraries
LD_LIBRARY_PATH=/usr/local/lib

# - Embedded
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/i386-linux-gnu"

export LD_LIBRARY_PATH

# Ignore some system global files
skip_global_compinit=1