#!/bin/bash

set -ex

VERSION=2.11.0
SHA256=d3be9961c799562565f158ce5b836e2b90f38502d3992a115dfb653d7825fd7e

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
