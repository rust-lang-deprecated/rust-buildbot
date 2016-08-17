#!/bin/bash

set -ex

VERSION=7.11.1
SHA256=57e9e9aa3172ee16aa1e9c66fef08b4393b51872cc153e3f1ffdf18a57440586

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
