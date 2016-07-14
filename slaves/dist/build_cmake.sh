#!/bin/bash

set -ex

VERSION=3.6.0
SHA256=fd05ed40cc40ef9ef99fac7b0ece2e0b871858a82feade48546f5d2940147670

curl https://cmake.org/files/v${VERSION%\.*}/cmake-$VERSION.tar.gz | \
  tee >(sha256sum > cmake-$VERSION.tar.gz.sha256)                  | tar xzf -
test $SHA256 = $(cut -d ' ' -f 1 cmake-$VERSION.tar.gz.sha256) || exit 1

mkdir cmake-build
cd cmake-build
../cmake-$VERSION/configure --prefix=/rustroot
make -j10
make install
