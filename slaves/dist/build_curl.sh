#!/bin/bash

set -ex

VERSION=7.44.0
SHA256=1e2541bae6582bb697c0fbae49e1d3e6fad5d05d5aa80dbd6f072e0a44341814

curl http://curl.haxx.se/download/curl-$VERSION.tar.bz2 | \
  tee >(sha256sum > curl-$VERSION.tar.bz2.sha256)       | tar xjf -
test $SHA256 = $(cut -d ' ' -f 1 curl-$VERSION.tar.bz2.sha256) || exit 1

mkdir curl-build
cd curl-build
../curl-$VERSION/configure --prefix=/rustroot --with-ssl=/rustroot \
      --disable-sspi --disable-gopher --disable-smtp --disable-smb \
      --disable-imap --disable-pop3 --disable-tftp --disable-telnet \
      --disable-manual --disable-dict --disable-rtsp --disable-ldaps \
      --disable-ldap
make -j10
make install
yum erase -y curl
