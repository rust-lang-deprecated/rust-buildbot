#!/bin/sh

set -ex

curl https://ftp.gnu.org/gnu/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2 | tar xjf -
cd gcc-4.7.4
./contrib/download_prerequisites
mkdir ../gcc-4.7.4-build
cd ../gcc-4.7.4-build
../gcc-4.7.4/configure --prefix=/rustroot --enable-languages=c,c++
make -j10
make install
yum erase -y gcc wget binutils
