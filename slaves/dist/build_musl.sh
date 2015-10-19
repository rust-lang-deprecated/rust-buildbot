#!/bin/sh

set -ex

curl http://www.musl-libc.org/releases/musl-1.1.11.tar.gz | tar xzf -
cd musl-1.1.11
./configure --prefix=/rustroot/musl --disable-shared
make -j10
make install
