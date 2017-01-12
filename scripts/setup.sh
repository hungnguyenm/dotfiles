#!/usr/bin/env bash

# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
# list of files/folders to symlink in homedir
files="gitconfig tmux.conf tmux virc vim vimrc zshrc zshenv emacs emacs.d"
linux_files="pam_environment"

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# get the platform of the current machine
platform=$(uname);

install_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install zsh -y
        install_zsh
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

install_tmux () {
    command -v emacs >/dev/null 2>&1 || {
        # If the platform is Linux, try an apt-get to install tmux, bc and then recurse
        if [[ $platform == 'Linux' ]]; then
            sudo apt-get install tmux bc -y
        # If the platform is OS X, tell the user to install tmux, bc
        elif [[ $platform == 'Darwin' ]]; then
            echo "Please install tmux and bc, then re-run this script!"
            exit
        fi
    }
}

install_emacs () {
    command -v emacs >/dev/null 2>&1 || {
        # If the platform is Linux, try an apt-get to install emacs (and vim)
        if [[ $platform == 'Linux' ]]; then
            sudo apt-get install vim emacs -y
        # If the platform is OS X, tell the user to install emacs
        elif [[ $platform == 'Darwin' ]]; then
            echo "Please install emacs and vim, this script won't install emacs on this system!"
        fi
    }
}

install_zsh
install_tmux
install_emacs

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
    echo "Moving $file from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

# run on Linux platform
if [[ $platform == 'Linux' ]]; then
    for linux_file in $linux_files; do
        echo "Moving $linux_file from ~ to $olddir"
        mv ~/.$linux_file ~/dotfiles_old/
        echo "Creating symlink to $linux_file in home directory."
        ln -s $dir/$linux_file ~/.$server_file
    done
fi