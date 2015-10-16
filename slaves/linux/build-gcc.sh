#!/bin/sh

set -ex

curl https://ftp.gnu.org/gnu/gcc/gcc-4.8.4/gcc-4.8.4.tar.bz2 | tar xjf -
(cd gcc-4.8.4 && ./contrib/download_prerequisites)

mkdir gcc-build
cd gcc-build
../gcc-4.8.4/configure --prefix=/opt/gcc --enable-languages=c,c++
make -j10
make install
