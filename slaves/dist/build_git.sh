#!/bin/bash

set -ex

VERSION=2.8.3
SHA256=2dad50c758339d6f5235309db620e51249e0000ff34aa2f2acbcb84c2123ed09

yum install -y gettext autoconf
curl https://www.kernel.org/pub/software/scm/git/git-$VERSION.tar.gz | \
  tee >(sha256sum > git-$VERSION.tar.gz.sha256) | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 git-$VERSION.tar.gz.sha256) || exit 1

cd git-$VERSION
make configure
./configure --prefix=/rustroot
make -j10
make install
yum erase -y gettext autoconf
