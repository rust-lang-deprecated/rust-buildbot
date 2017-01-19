#!/bin/sh

set -ex

export CFLAGS="-fPIC -Wa,-mrelax-relocations=no"
export CXXFLAGS="-Wa,-mrelax-relocations=no"
MUSL=musl-1.1.14
# Support building MUSL
curl http://www.musl-libc.org/releases/$MUSL.tar.gz | tar xzf -
cd $MUSL
# for x86_64
./configure --prefix=/musl-x86_64 --disable-shared
make -j10
make install
make clean
# for i686
CFLAGS="$CFLAGS -m32" ./configure --prefix=/musl-i686 --disable-shared --target=i686
make -j10
make install
cd ..

# To build MUSL we're going to need a libunwind lying around, so acquire that
# here and build it.
curl http://releases.llvm.org/3.7.0/llvm-3.7.0.src.tar.xz | tar xJf -
curl http://releases.llvm.org/3.7.0/libunwind-3.7.0.src.tar.xz | tar xJf -
mkdir libunwind-build
cd libunwind-build
# for x86_64
cmake ../libunwind-3.7.0.src -DLLVM_PATH=/build/llvm-3.7.0.src \
          -DLIBUNWIND_ENABLE_SHARED=0
make -j10
cp lib/libunwind.a /musl-x86_64/lib

# (Note: the next cmake call doesn't fully override the previous cached one, so remove the cached
# configuration manually. IOW, if don't do this or call make clean we'll end up building libunwind
# for x86_64 again)
rm -rf *
# for i686
CFLAGS="$CFLAGS -m32" CXXFLAGS="$CXXFLAGS -m32" cmake /build/libunwind-3.7.0.src \
          -DLLVM_PATH=/build/llvm-3.7.0.src \
          -DLIBUNWIND_ENABLE_SHARED=0
make -j10
cp lib/libunwind.a /musl-i686/lib
