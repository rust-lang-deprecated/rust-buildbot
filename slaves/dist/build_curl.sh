#!/bin/sh

set -ex

curl http://curl.haxx.se/download/curl-7.44.0.tar.bz2 | tar xjf -
mkdir curl-build
cd curl-build
../curl-7.44.0/configure --prefix=/rustroot --with-ssl=/rustroot \
      --disable-sspi --disable-gopher --disable-smtp --disable-smb \
      --disable-imap --disable-pop3 --disable-tftp --disable-telnet \
      --disable-manual --disable-dict --disable-rtsp --disable-ldaps \
      --disable-ldap
make -j10
make install
yum erase -y curl
