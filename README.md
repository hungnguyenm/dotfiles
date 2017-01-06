# Dotfiles

The project was originally based on [aharris88](https://github.com/aharris88/dotfiles)

This repository includes all of my custom dotfiles.  They should be cloned to your home directory so that the path is `~/dotfiles/`.  The included setup script creates symlinks from your home directory to the files which are located in `~/dotfiles/`.

The setup script is smart enough to back up your existing dotfiles into a `~/dotfiles_old/` directory if you already have any dotfiles of the same name as the dotfile symlinks being created in your home directory.

## Installation
``` bash
git clone git://github.com/hungnguyenm/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## Keyboard Settings

I remap my keys so that the caps lock key is control, but it's only control if you press it in combination with another key, otherwise it's escape. And then my enter/return key is control if pressed in combination, otherwise it's enter.

Install [Karabiner](https://github.com/tekezo/Karabiner). And turn on these settings:

Control-L to Control_L (+ When you type Control_L only, send Escape)

Return to Control_L (+ When you type Return only, send Return) + [KeyRepeat]
