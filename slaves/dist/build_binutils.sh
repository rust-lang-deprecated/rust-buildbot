#!/bin/bash

set -ex

VERSION=2.27
SHA256=369737ce51587f92466041a97ab7d2358c6d9e1b6490b3940eb09fb0a9a6ac88

curl https://ftp.gnu.org/gnu/binutils/binutils-$VERSION.tar.bz2 | \
  tee >(sha256sum > binutils-$VERSION.tar.bz2.sha256)           | tar xjf -
test $SHA256 = $(cut -d ' ' -f 1 binutils-$VERSION.tar.bz2.sha256) || exit 1

mkdir binutils-build
cd binutils-build
../binutils-$VERSION/configure --prefix=/rustroot
make -j10
make install
yum erase -y binutils
