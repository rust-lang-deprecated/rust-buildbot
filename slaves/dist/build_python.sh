#!/bin/sh

set -ex

yum install -y bzip2-devel
curl https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz | tar xzf -
mkdir python-build
cd python-build

# Gotta do some hackery to tell python about our custom OpenSSL build, but other
# than that fairly normal.
CFLAGS='-I /rustroot/include' LDFLAGS='-L /rustroot/lib -L /rustroot/lib64' \
    ../Python-2.7.10/configure --prefix=/rustroot
make -j10
make install
yum erase -y bzip2-devel
