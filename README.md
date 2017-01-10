# Dotfiles

This repository includes all of my custom dotfiles.  They should be cloned to your home directory so that the path is `~/dotfiles/`.  The included setup script creates symlinks from your home directory to the files which are located in `~/dotfiles/`.

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
