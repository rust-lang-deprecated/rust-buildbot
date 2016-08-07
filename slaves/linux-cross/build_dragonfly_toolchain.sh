#!/bin/bash

set -ex

ARCH=x86_64
BINUTILS=2.25.1
GCC=5.3.0
DF_VERSION=4.6.0_REL
URL_DFLY_ISO=https://mirror-master.dragonflybsd.org/iso-images/dfly-x86_64-${DF_VERSION}.iso.bz2

mkdir binutils
cd binutils

# First up, build binutils
curl https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.bz2 | tar xjf -
mkdir binutils-build
cd binutils-build
../binutils-$BINUTILS/configure \
  --target=$ARCH-unknown-dragonfly
make -j10
make install
cd ../..
rm -rf binutils

# Next, download the DragonFly libc and relevant header files
mkdir dragonfly
curl $URL_DFLY_ISO | bzcat | bsdtar xf - -C dragonfly ./usr/include ./usr/lib ./lib

dst=/usr/local/$ARCH-unknown-dragonfly

cp -r dragonfly/usr/include $dst/
cp dragonfly/usr/lib/crt1.o $dst/lib
cp dragonfly/usr/lib/Scrt1.o $dst/lib
cp dragonfly/usr/lib/crti.o $dst/lib
cp dragonfly/usr/lib/crtn.o $dst/lib
cp dragonfly/usr/lib/libc.a $dst/lib
cp dragonfly/usr/lib/libutil.a $dst/lib
#cp dragonfly/usr/lib/libutil_p.a $dst/lib
cp dragonfly/usr/lib/libm.a $dst/lib
cp dragonfly/usr/lib/librt.so.0 $dst/lib
cp dragonfly/usr/lib/libexecinfo.so.1 $dst/lib
cp dragonfly/lib/libc.so.8 $dst/lib
cp dragonfly/lib/libm.so.4 $dst/lib
cp dragonfly/lib/libutil.so.4 $dst/lib
#cp dragonfly/lib/libthr.so.3 $dst/lib/libpthread.so
cp dragonfly/usr/lib/libpthread.so $dst/lib/libpthread.so
cp dragonfly/usr/lib/thread/libthread_xu.so.2 $dst/lib/libpthread.so.0

ln -s libc.so.8 $dst/lib/libc.so
ln -s libm.so.4 $dst/lib/libm.so
ln -s librt.so.0 $dst/lib/librt.so
ln -s libutil.so.4 $dst/lib/libutil.so
ln -s libexecinfo.so.1 $dst/lib/libexecinfo.so
rm -rf dragonfly

# Finally, download and build gcc to target DragonFly
mkdir gcc
cd gcc
curl https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.bz2 | tar xjf -
cd gcc-$GCC

patch -p0 <<'EOF'
--- libatomic/configure.tgt.orig	2015-07-09 16:08:55 UTC
+++ libatomic/configure.tgt
@@ -110,7 +110,7 @@ case "${target}" in
 	;;
 
   *-*-linux* | *-*-gnu* | *-*-k*bsd*-gnu \
-  | *-*-netbsd* | *-*-freebsd* | *-*-openbsd* \
+  | *-*-netbsd* | *-*-freebsd* | *-*-openbsd* | *-*-dragonfly* \
   | *-*-solaris2* | *-*-sysv4* | *-*-irix6* | *-*-osf* | *-*-hpux11* \
   | *-*-darwin* | *-*-aix* | *-*-cygwin*)
 	# POSIX system.  The OS is supported.
EOF

patch -p0 <<'EOF'
--- libstdc++-v3/config/os/bsd/dragonfly/os_defines.h.orig	2015-07-09 16:08:54 UTC
+++ libstdc++-v3/config/os/bsd/dragonfly/os_defines.h
@@ -29,4 +29,9 @@
 // System-specific #define, typedefs, corrections, etc, go here.  This
 // file will come before all others.
 
+#define _GLIBCXX_USE_C99_CHECK 1
+#define _GLIBCXX_USE_C99_DYNAMIC (!(__ISO_C_VISIBLE >= 1999))
+#define _GLIBCXX_USE_C99_LONG_LONG_CHECK 1
+#define _GLIBCXX_USE_C99_LONG_LONG_DYNAMIC (_GLIBCXX_USE_C99_DYNAMIC || !defined __LONG_LONG_SUPPORTED)
+
 #endif
EOF

patch -p0 <<'EOF'
--- libstdc++-v3/configure.orig	2016-05-26 18:34:47.163132921 +0200
+++ libstdc++-v3/configure	2016-05-26 18:35:29.594590648 +0200
@@ -52013,7 +52013,7 @@
 
     ;;
 
-  *-freebsd*)
+  *-freebsd* | *-dragonfly*)
     SECTION_FLAGS='-ffunction-sections -fdata-sections'
 
 
EOF

./contrib/download_prerequisites

mkdir ../gcc-build
cd ../gcc-build
../gcc-$GCC/configure                            \
  --enable-languages=c,c++                       \
  --target=$ARCH-unknown-dragonfly               \
  --disable-multilib                             \
  --disable-nls                                  \
  --disable-libgomp                              \
  --disable-libquadmath                          \
  --disable-libssp                               \
  --disable-libvtv                               \
  --disable-libcilkrts                           \
  --disable-libada                               \
  --disable-libsanitizer                         \
  --disable-libquadmath-support                  \
  --disable-lto
make -j10
make install
cd ../..
rm -rf gcc
