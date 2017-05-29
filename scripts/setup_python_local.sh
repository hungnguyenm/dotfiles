#!/usr/bin/env bash

# Script for installing Python 2 and 3 on systems where you don't have root access.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

P2_VERSION=2.7.13
P2_DIR=$HOME/opt/python2
P3_VERSION=3.6.1
P3_DIR=$HOME/opt/python3
PYTHON_TEMP_DIR=$HOME/tmp/python

# create our directories
rm -rf $P2_DIR $P3_DIR $PYTHON_TEMP_DIR
mkdir -p $P2_DIR $P3_DIR $PYTHON_TEMP_DIR

############
# Python 2 #
############
cd $PYTHON_TEMP_DIR
wget https://www.python.org/ftp/python/${P2_VERSION}/Python-${P2_VERSION}.tar.xz
tar xvf Python-${P2_VERSION}.tar.xz
cd Python-${P2_VERSION}
./configure --prefix=$P2_DIR
make
make install

############
# Python 3 #
############
cd $PYTHON_TEMP_DIR
wget https://www.python.org/ftp/python/${P3_VERSION}/Python-${P3_VERSION}.tar.xz
tar xvf Python-${P3_VERSION}.tar.xz
cd Python-${P3_VERSION}
./configure --prefix=$P3_DIR
make
make install

# cleanup
rm -rf $PYTHON_TEMP_DIR
echo "Done."