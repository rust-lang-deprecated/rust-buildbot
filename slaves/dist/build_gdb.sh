#!/bin/bash

set -ex

VERSION=7.9.1
SHA256=4994ad986726ac4128a6f1bd8020cd672e9a92aa76b80736563ef992992764ef

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
