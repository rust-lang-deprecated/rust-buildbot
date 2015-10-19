#!/bin/sh

set -ex

curl https://ftp.gnu.org/gnu/gdb/gdb-7.9.1.tar.gz | tar xzf -
mkdir gdb-build
cd gdb-build
../gdb-7.9.1/configure --prefix=/rustroot
make -j10
make install
yum erase -y texinfo ncurses-devel
