#!/bin/bash

set -ex

VERSION=0.29.1
SHA256=beb43c9e064555469bd4390dcfd8030b1536e0aa103f08d7abf7ae8cac0cb001

curl http://pkgconfig.freedesktop.org/releases/pkg-config-$VERSION.tar.gz | \
  tee >(sha256sum > pkg-config-$VERSION.tar.gz.sha256) | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 pkg-config-$VERSION.tar.gz.sha256) || exit 1

mkdir pkg-config-build
cd pkg-config-build
../pkg-config-$VERSION/configure --prefix=/rustroot --with-internal-glib
make -j10
make install
