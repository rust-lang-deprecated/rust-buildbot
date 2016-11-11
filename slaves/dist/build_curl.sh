#!/bin/bash

set -ex

VERSION=7.51.0
SHA256=7f8240048907e5030f67be0a6129bc4b333783b9cca1391026d700835a788dde

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
