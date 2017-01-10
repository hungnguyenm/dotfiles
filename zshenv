# Environment setup for all types of shell
export DOTFILES_DIR=$HOME/dotfiles
export ZSH_CACHE_DIR=$HOME/.zsh

export ZSH_VIM_BACKUPS=$ZSH_CACHE_DIR/vim_backups
export ZSH_VIM_SWAPS=$ZSH_CACHE_DIR/vim_swaps
export ZSH_VIM_UNDO=$ZSH_CACHE_DIR/vim_undo

export EDITOR=vim

# Path
PATH="$HOME/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

PATH="$PATH:$DOTFILES_DIR/scripts"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"
# - OSX - sage
PATH="$PATH:/Applications/sage"

# - Ubuntu - android-studio
PATH="$PATH:$HOME/opt/android-studio/bin"
PATH="$PATH:$HOME/Android/Sdk/platform-tools"

export PATH