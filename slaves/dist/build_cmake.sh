#!/bin/bash

set -ex

VERSION=3.3.2
SHA256=e75a178d6ebf182b048ebfe6e0657c49f0dc109779170bad7ffcb17463f2fc22

curl https://cmake.org/files/v${VERSION%\.*}/cmake-$VERSION.tar.gz | \
  tee >(sha256sum > cmake-$VERSION.tar.gz.sha256)                  | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 cmake-$VERSION.tar.gz.sha256) || exit 1

mkdir cmake-build
cd cmake-build
../cmake-$VERSION/configure --prefix=/rustroot
make -j10
make install
