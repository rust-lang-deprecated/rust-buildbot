#!/bin/bash

set -ex

VERSION=2.5.3
SHA256=ebf3fb0f3f286d5f193efeca88e34c40a3cb53c985a1f53de0dbf08c3e5af979

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
