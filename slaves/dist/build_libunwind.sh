#!/bin/sh

set -ex

curl http://llvm.org/releases/3.7.0/llvm-3.7.0.src.tar.xz | tar xJf -
curl http://llvm.org/releases/3.7.0/libunwind-3.7.0.src.tar.xz | tar xJf -
mkdir libunwind-build
cd libunwind-build
cmake ../libunwind-3.7.0.src -DLLVM_PATH=../llvm-3.7.0.src \
          -DLIBUNWIND_ENABLE_SHARED=0
make -j10
cp lib/libunwind.a /rustroot/musl/lib
