#!/bin/sh

set -ex

# Support building MUSL
curl http://www.musl-libc.org/releases/musl-1.1.11.tar.gz | tar xzf -
cd musl-1.1.11
./configure --prefix=/musl --disable-shared
make -j10
make install
cd ..

# To build MUSL we're going to need a libunwind lying around, so acquire that
# here and build it.
curl http://llvm.org/releases/3.7.0/llvm-3.7.0.src.tar.xz | tar xJf -
curl http://llvm.org/releases/3.7.0/libunwind-3.7.0.src.tar.xz | tar xJf -
mkdir libunwind-build
cd libunwind-build
cmake ../libunwind-3.7.0.src -DLLVM_PATH=/build/llvm-3.7.0.src \
          -DLIBUNWIND_ENABLE_SHARED=0
make -j10
cp lib/libunwind.a /musl/lib
