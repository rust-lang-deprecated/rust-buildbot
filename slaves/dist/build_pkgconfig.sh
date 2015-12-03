#!/bin/bash

set -ex

VERSION=0.29
SHA256=c8507705d2a10c67f385d66ca2aae31e81770cc0734b4191eb8c489e864a006b

curl http://pkgconfig.freedesktop.org/releases/pkg-config-$VERSION.tar.gz | \
  tee >(sha256sum > pkg-config-$VERSION.tar.gz.sha256) | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 pkg-config-$VERSION.tar.gz.sha256) || exit 1

mkdir pkg-config-build
cd pkg-config-build
../pkg-config-$VERSION/configure --prefix=/rustroot --with-internal-glib
make -j10
make install
