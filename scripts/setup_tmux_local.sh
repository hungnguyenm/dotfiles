#!/bin/bash

# Script for installing tmux on systems where you don't have root access.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

TMUX_VERSION=2.3
TMUX_DIR=$HOME/opt/tmux
TMUX_BIN_DIR=$HOME/bin
TMUX_TEMP_DIR=$HOME/temp/tmux

# create our directories
rm -rf $TMUX_DIR $TMUX_TEMP_DIR
mkdir -p $TMUX_BIN_DIR $TMUX_DIR $TMUX_TEMP_DIR

############
# libevent #
############
cd $TMUX_TEMP_DIR
wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
tar xvzf libevent-2.0.19-stable.tar.gz
cd libevent-*/
./configure --prefix=$TMUX_DIR --disable-shared
make
make install

############
# ncurses  #
############
cd $TMUX_TEMP_DIR
wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
tar xvzf ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=$TMUX_DIR LDFLAGS="-static" CPPFLAGS="-P"
make
make install

############
# tmux     #
############
cd $TMUX_TEMP_DIR
wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure --prefix=$TMUX_DIR --enable-static CFLAGS="-I$TMUX_DIR/include -I$TMUX_DIR/include/ncurses" LDFLAGS="-static -L$TMUX_DIR/lib -L$TMUX_DIR/lib64 -L$TMUX_DIR/include/ncurses -L$TMUX_DIR/include" PKG_CONFIG=/bin/false
CPPFLAGS="-I$TMUX_DIR/include -I$TMUX_DIR/include/ncurses" LDFLAGS="-static -L$TMUX_DIR/include -L$TMUX_DIR/include/ncurses -L$TMUX_DIR/lib -L$TMUX_DIR/lib64" make
cp tmux $TMUX_BIN_DIR
cd ~/

# cleanup
rm -rf $TMUX_TEMP_DIR
echo "$TMUX_BIN_DIR/tmux is now available."