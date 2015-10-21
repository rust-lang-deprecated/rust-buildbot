#!/bin/sh

set -ex

yum install -y gettext autoconf
curl https://www.kernel.org/pub/software/scm/git/git-2.5.3.tar.gz | tar xzf -
cd git-2.5.3
make configure
./configure --prefix=/rustroot
make -j10
make install
yum erase -y gettext autoconf
