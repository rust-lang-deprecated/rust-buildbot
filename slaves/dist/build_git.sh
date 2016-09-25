#!/bin/bash

set -ex

VERSION=2.10.0
SHA256=207cfce8cc0a36497abb66236817ef449a45f6ff9141f586bbe2aafd7bc3d90b

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
