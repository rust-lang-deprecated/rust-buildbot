#!/bin/bash

set -ex

VERSION=2.7.13
SHA256=35d543986882f78261f97787fd3e06274bfa6df29fac9b4a94f73930ff98f731

yum install -y bzip2-devel
curl https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz | \
  tee >(sha256sum > Python-$VERSION.tar.xz.sha256) | tar xJf -
test $SHA256 = $(cut -d ' ' -f 1 Python-$VERSION.tar.xz.sha256) || exit 1

mkdir python-build
cd python-build

# Gotta do some hackery to tell python about our custom OpenSSL build,
# but other than that fairly normal.
CFLAGS='-I /rustroot/include' LDFLAGS='-L /rustroot/lib -L /rustroot/lib64' \
    ../Python-$VERSION/configure --prefix=/rustroot
make -j10
make install
yum erase -y bzip2-devel
