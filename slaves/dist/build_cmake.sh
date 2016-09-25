#!/bin/bash

set -ex

VERSION=3.6.2
SHA256=189ae32a6ac398bb2f523ae77f70d463a6549926cde1544cd9cc7c6609f8b346

curl https://cmake.org/files/v${VERSION%\.*}/cmake-$VERSION.tar.gz | \
  tee >(sha256sum > cmake-$VERSION.tar.gz.sha256)                  | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 cmake-$VERSION.tar.gz.sha256) || exit 1

mkdir cmake-build
cd cmake-build
../cmake-$VERSION/configure --prefix=/rustroot
make -j10
make install
