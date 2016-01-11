#!/bin/bash

set -ex

VERSION=2.7.11
SHA256=82929b96fd6afc8da838b149107078c02fa1744b7e60999a8babbc0d3fa86fc6

yum install -y bzip2-devel
curl https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz | \
  tee >(sha256sum > Python-$VERSION.tgz.sha256) | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 Python-$VERSION.tgz.sha256) || exit 1

mkdir python-build
cd python-build

# Gotta do some hackery to tell python about our custom OpenSSL build, but other
# than that fairly normal.
CFLAGS='-I /rustroot/include' LDFLAGS='-L /rustroot/lib -L /rustroot/lib64' \
    ../Python-$VERSION/configure --prefix=/rustroot
make -j10
make install
yum erase -y bzip2-devel
