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
PATH="$HOME/opt/anaconda3/bin:$HOME/opt/anaconda2/bin:$PATH"

# - OSX
PATH="$PATH:/opt/X11/bin"
# - OSX - LaTex
PATH="$PATH:/Library/TeX/texbin"

# - Ubuntu - cuda
PATH="/usr/local/cuda/bin/:$PATH"
export CUDA_HOME=/usr/local/cuda

# - Ubuntu - sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH

# Libraries
LD_LIBRARY_PATH=/usr/local/lib

# - Ubuntu - cuda
LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH

# Some additional parameters
# - enforce CUDA to support higher gcc version
export EXTRA_NVCCFLAGS="-Xcompiler -std=c++98"

# Ignore some system global files
skip_global_compinit=1