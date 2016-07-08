# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################
git submodule init 
git submodule update

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
# list of files/folders to symlink in homedir
files="gitconfig tmux.conf tmux virc vim vimrc zshrc"
server_files="pam_environment"

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
    # Install oh-my-zsh if it isn't already present
    if [[ ! -d ~/.oh-my-zsh/ ]]; then
        curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
    fi
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

install_zsh
install_tmux

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
    echo "Moving $file from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

# server part - run on Linux platform
if [[ $platform == 'Linux' ]]; then
    for server_file in $server_files; do
        echo "Moving $server_file from ~ to $olddir"
        mv ~/.$server_file ~/dotfiles_old/
        echo "Creating symlink to $server_file in home directory."
        ln -s $dir/$server_file ~/.$server_file
    done
fi