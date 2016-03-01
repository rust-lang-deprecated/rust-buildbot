#!/bin/bash

set -ex

VERSION=7.11
SHA256=9382f5534aa0754169e1e09b5f1a3b77d1fa8c59c1e57617e06af37cb29c669a

yum install -y texinfo ncurses-devel
curl https://ftp.gnu.org/gnu/gdb/gdb-$VERSION.tar.gz | \
  tee >(sha256sum > gdb-$VERSION.tar.gz.sha256)      | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 gdb-$VERSION.tar.gz.sha256) || exit 1

mkdir gdb-build
cd gdb-build
../gdb-$VERSION/configure --prefix=/rustroot
make -j10
make install
yum erase -y texinfo ncurses-devel
