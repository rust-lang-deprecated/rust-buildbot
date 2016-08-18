#!/bin/bash

set -ex

VERSION=3.6.1
SHA256=28ee98ec40427d41a45673847db7a905b59ce9243bb866eaf59dce0f58aaef11

curl https://cmake.org/files/v${VERSION%\.*}/cmake-$VERSION.tar.gz | \
  tee >(sha256sum > cmake-$VERSION.tar.gz.sha256)                  | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 cmake-$VERSION.tar.gz.sha256) || exit 1

mkdir cmake-build
cd cmake-build
../cmake-$VERSION/configure --prefix=/rustroot
make -j10
make install
