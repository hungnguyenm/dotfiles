#!/bin/bash

# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in $HOME/opt/tmux
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

TMUX_VERSION=2.3

# create our directories
rm -rf $HOME/opt/tmux $HOME/temp/tmux
mkdir -p $HOME/bin $HOME/opt/tmux $HOME/temp/tmux

############
# libevent #
############
cd $HOME/temp/tmux
wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
tar xvzf libevent-2.0.19-stable.tar.gz
cd libevent-*/
./configure --prefix=$HOME/opt/tmux --disable-shared
make
make install

############
# ncurses  #
############
cd $HOME/temp/tmux
wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
tar xvzf ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=$HOME/opt/tmux LDFLAGS="-static"
make
make install

############
# tmux     #
############
cd $HOME/temp/tmux
wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure --prefix=$HOME/opt/tmux --enable-static CFLAGS="-I$HOME/opt/tmux/include -I$HOME/opt/tmux/include/ncurses" LDFLAGS="-static -L$HOME/opt/tmux/lib64 -L$HOME/opt/tmux/include/ncurses -L$HOME/opt/tmux/include" PKG_CONFIG=/bin/false
CPPFLAGS="-I$HOME/opt/tmux/include -I$HOME/opt/tmux/include/ncurses" LDFLAGS="-static -L$HOME/opt/tmux/include -L$HOME/opt/tmux/include/ncurses -L$HOME/opt/tmux/lib64" make
cp tmux $HOME/bin
cd ~/

# cleanup
rm -rf $HOME/temp/tmux