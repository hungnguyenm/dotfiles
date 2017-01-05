# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
# list of files/folders to symlink in homedir
files="gitconfig tmux.conf tmux virc vim vimrc zshrc emacs emacs.d"
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