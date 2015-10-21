#!/bin/sh

set -ex

curl http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz | tar xzf -
mkdir pkg-config-build
cd pkg-config-build
../pkg-config-0.29/configure --prefix=/rustroot --with-internal-glib
make -j10
make install
