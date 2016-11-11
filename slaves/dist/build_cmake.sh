#!/bin/bash

set -ex

VERSION=3.6.3
SHA256=7d73ee4fae572eb2d7cd3feb48971aea903bb30a20ea5ae8b4da826d8ccad5fe

curl https://cmake.org/files/v${VERSION%\.*}/cmake-$VERSION.tar.gz | \
  tee >(sha256sum > cmake-$VERSION.tar.gz.sha256)                  | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 cmake-$VERSION.tar.gz.sha256) || exit 1

mkdir cmake-build
cd cmake-build
../cmake-$VERSION/configure --prefix=/rustroot
make -j10
make install
