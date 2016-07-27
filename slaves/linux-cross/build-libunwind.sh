#!/bin/sh

set -ex

# To build MUSL targets we're going to need a libunwind lying around, so acquire that
# here and build it.
if [ ! -d "llvm-3.8.0.src"  ]; then
    curl http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz | tar xJf -
fi

if [ ! -d "libunwind-3.8.0.src" ]; then
    curl http://llvm.org/releases/3.8.0/libunwind-3.8.0.src.tar.xz | tar xJf -
fi

rm -rf libunwind-build
mkdir libunwind-build
cd libunwind-build
CC=${1/unknown-/}-gcc CXX=${1/unknown-/}-gcc cmake \
  ../libunwind-3.8.0.src \
  -DLLVM_PATH=../llvm-3.8.0.src \
  -DLIBUNWIND_ENABLE_SHARED=0
VERBOSE=1 make -j1
cp lib/libunwind.a /x-tools/${1}/${1}/sysroot/usr/lib/
