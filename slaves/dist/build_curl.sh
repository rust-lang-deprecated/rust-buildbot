#!/bin/bash

set -ex

VERSION=7.50.3
SHA256=7b7347d976661d02c84a1f4d6daf40dee377efdc45b9e2c77dedb8acf140d8ec

curl http://cool.haxx.se/download/curl-$VERSION.tar.bz2 | \
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
