#!/bin/sh

set -ex

curl https://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2 | tar xjf -
mkdir binutils-build
cd binutils-build
../binutils-2.25.1/configure --prefix=/rustroot
make -j10
make install
yum erase -y binutils
