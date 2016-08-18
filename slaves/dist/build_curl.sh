#!/bin/bash

set -ex

VERSION=7.50.1
SHA256=3c12c5f54ccaa1d40abc65d672107dcc75d3e1fcb38c267484334280096e5156

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
