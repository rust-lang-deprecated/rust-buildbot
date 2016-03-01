#!/bin/bash

set -ex

VERSION=2.7.2
SHA256=58959e3ef3046403216a157dfc683c4d7f0dd83365463b8dd87063ded940a0df

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
