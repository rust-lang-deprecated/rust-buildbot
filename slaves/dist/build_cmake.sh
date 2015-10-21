#!/bin/sh

set -ex

curl http://www.cmake.org/files/v3.3/cmake-3.3.2.tar.gz | tar xzf -
mkdir cmake-build
cd cmake-build
../cmake-3.3.2/configure --prefix=/rustroot
make -j10
make install
