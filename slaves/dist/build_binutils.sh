#!/bin/bash

set -ex

VERSION=2.25.1
SHA256=b5b14added7d78a8d1ca70b5cb75fef57ce2197264f4f5835326b0df22ac9f22

curl https://ftp.gnu.org/gnu/binutils/binutils-$VERSION.tar.bz2 | \
  tee >(sha256sum > binutils-$VERSION.tar.bz2.sha256)           | tar xjf -
test $SHA256 = $(cut -d ' ' -f 1 binutils-$VERSION.tar.bz2.sha256) || exit 1

mkdir binutils-build
cd binutils-build
../binutils-$VERSION/configure --prefix=/rustroot
make -j10
make install
yum erase -y binutils
