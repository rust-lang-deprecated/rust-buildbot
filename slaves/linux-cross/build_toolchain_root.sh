#!/bin/bash

set -ex

install_deps() {
  apt-get install -y --force-yes --no-install-recommends \
    automake bison bzip2 curl flex g++ gawk gperf help2man libncurses-dev libtool-bin make texinfo \
    patch wget
}

# gcc-4.8 can't be built with the make-4 that's ships with Ubuntu 15.10. This overrides it with
# make-3
mk_make() {
  local version=3.81

  curl ftp://ftp.gnu.org/gnu/make/make-${version}.tar.gz | tar xz
  pushd make-${version}
  ./configure --prefix=/usr
  make
  make install
  popd
}

mk_crosstool_ng() {
  local version=1.22.0

  curl http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${version}.tar.bz2 | tar xj
  pushd crosstool-ng
  ./configure --prefix=/usr/local
  make
  make install
  popd
}

main() {
  install_deps
  mk_make
  mk_crosstool_ng
}

main
