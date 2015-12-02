#!/bin/bash

set -ex

VERSION=4.7.4
SHA256=92e61c6dc3a0a449e62d72a38185fda550168a86702dea07125ebd3ec3996282

yum install -y wget
curl https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.bz2 | \
  tee >(sha256sum > gcc-$VERSION.tar.bz2.sha256) | tar xjf -
test $SHA256 = $(cut -d ' ' -f 1 gcc-$VERSION.tar.bz2.sha256) || exit 1

cd gcc-$VERSION
./contrib/download_prerequisites
mkdir ../gcc-$VERSION-build
cd ../gcc-$VERSION-build
../gcc-$VERSION/configure --prefix=/rustroot --enable-languages=c,c++
make -j10
make install
ln -nsf gcc /rustroot/bin/cc
yum erase -y gcc wget
