FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        curl make cmake git wget file \
        python-dev python-pip python-setuptools stunnel \
        zlib1g-dev \
        bzip2 xz-utils \
        g++ libc6-dev \
        bsdtar \
        cmake \
        rpm2cpio cpio \
        g++-5-mips-linux-gnu libc6-dev-mips-cross \
        g++-5-mipsel-linux-gnu libc6-dev-mipsel-cross \
        pkg-config

# Rename compilers to variants without version numbers so the build
# configuration in the standard library can pick them up.
RUN                                              \
  for f in `ls /usr/bin/mips*-linux-*-*-5`; do   \
    ln -vs $f `echo $f | sed -e 's/-5$//'`;      \
  done &&                                        \
  for f in `ls /usr/bin/*-linux-*-*-4.8`; do     \
    ln -vs $f `echo $f | sed -e 's/-4.8$//'`;    \
  done &&                                        \
  for f in `ls /usr/bin/*-linux-*-*-4.7`; do     \
    ln -vs $f `echo $f | sed -e 's/-4.7$//'`;    \
  done

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -m -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Install rumprun cross compiler
WORKDIR /build
COPY linux-cross/build_rumprun.sh /build/
RUN /bin/bash build_rumprun.sh && rm -rf /build

# Build/install crosstool-ng cross compilers
# NOTE crosstool-ng can't be executed by root so we execute it under the
# rustbuild user. /x-tools is the crosstool-ng output directory and /build is
# the crosstool-ng build directory so both must be writable by rustbuild
WORKDIR /build
COPY linux-cross/build_toolchain_root.sh /build/
RUN /bin/bash build_toolchain_root.sh && \
    mkdir /x-tools && \
    chown rustbuild:rustbuild /build && \
    chown rustbuild:rustbuild /x-tools
COPY linux-cross/build_toolchain.sh \
    linux-cross/aarch64-linux-gnu.config \
    linux-cross/arm-linux-gnueabi.config \
    linux-cross/arm-linux-musleabi.config \
    linux-cross/arm-linux-gnueabihf.config \
    linux-cross/arm-linux-musleabihf.config \
    linux-cross/mips-linux-musl.config \
    linux-cross/mipsel-linux-musl.config \
    linux-cross/armv7-linux-gnueabihf.config \
    linux-cross/armv7-linux-musleabihf.config \
    linux-cross/powerpc-linux-gnu.config \
    linux-cross/powerpc64-linux-gnu.config \
    linux-cross/s390x-linux-gnu.config \
    /build/
COPY linux-cross/patches /build/patches
USER rustbuild

# Build three full toolchains for the `arm-unknown-linux-gneuabi`,
# `arm-unknown-linux-gnueabihf` and `aarch64-unknown-linux-gnu` targets. We
# build toolchains from scratch to primarily move to an older glibc. Ubuntu
# does indeed have these toolchains in its repositories (so we could install
# that package), but they package a relatively newer version of glibc. In order
# for the binaries we produce to be maximall compatible, we push the glibc
# version back to 2.14 for arm and 2.17 for aarch64
RUN /bin/bash build_toolchain.sh arm-linux-gnueabi
RUN /bin/bash build_toolchain.sh arm-linux-gnueabihf
RUN /bin/bash build_toolchain.sh aarch64-linux-gnu

# Also build two full toolchains for the `{mips,mipsel}-unknown-linux-musl`
# targets. Currently these are essentially aliases to run on OpenWRT devices and
# are different from the x86_64/i686 MUSL targets in that MUSL is dynamically
# linked instead of statically. As a result, we also need to dynamically link to
# an unwinder and other various runtime bits.
#
# We in theory could *only* build the MUSL library itself and use the standard
# MIPS toolchains installed above to link against the library, except it gets
# difficult figuring out how to link, for example, `gcc_s` dynamically. For that
# reason we just give up and build a whole toolchain which is dedicated to
# targeting this triple.
RUN /bin/bash build_toolchain.sh mips-linux-musl
RUN /bin/bash build_toolchain.sh mipsel-linux-musl

# Also build a toolchain tuned for the armv7 architecture which is going to be
# used with the armv7-unknown-linux-gnueabihf target.
#
# Why are we not using the arm-linux-gnueabihf toolchain with the armv7 target?
# We actually tried that setup but we hit `ar` errors caused by the different
# codegen options used by crosstool-ng and the rust build system. crosstool-ng
# uses `-march=armv6` to build the toolchain and related C(++) libraries, like
# libstdc++ which gets statically linked to LLVM; on the other hand the rust
# build system builds its C(++) libraries, like LLVM, with `-march=armv7-a`.
#
# By using this armv7 compiler we can ensure the same codegen options are used
# everywhere and avoid these codegen mismatch issues. Also compiling libstdc++
# for armv7 instead of for armv6 should make rustc (slightly) faster.
RUN /bin/bash build_toolchain.sh armv7-linux-gnueabihf

# Build a bunch of toolchains for ARM musl targets
RUN /bin/bash build_toolchain.sh arm-linux-musleabi
RUN /bin/bash build_toolchain.sh arm-linux-musleabihf
RUN /bin/bash build_toolchain.sh armv7-linux-musleabihf

# Also build toolchains for {powerpc{,64},s390x}-unknown-linux-gnu,
# primarily to support older glibc than found in the Ubuntu root.
RUN /bin/bash build_toolchain.sh powerpc-linux-gnu
RUN /bin/bash build_toolchain.sh powerpc64-linux-gnu
RUN /bin/bash build_toolchain.sh s390x-linux-gnu

USER root

# Rename all the compilers we just built into /usr/bin and also without
# `-unknown-` in the name because it appears lots of other compilers in Ubuntu
# don't have this name in the component by default either.
# Also rename `-ibm-` out of the s390x compilers.
# Also the aarch64 compiler is prefixed with `aarch64-unknown-linux-gnueabi`
# by crosstool-ng, but Ubuntu just prefixes it with `aarch64-linux-gnu` so
# we'll, additionally, strip the eabi part from its binaries.
RUN                                                                           \
  for f in `ls /x-tools/*-unknown-linux-*/bin/*-unknown-linux-*`; do          \
    g=`basename $f`;                                                          \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;                     \
  done && \
  for f in `ls /x-tools/*-ibm-linux-*/bin/*-ibm-linux-*`; do                  \
    g=`basename $f`;                                                          \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-ibm//'`;                         \
  done && \
  for f in `ls /usr/bin/aarch64-linux-gnueabi-*`; do                          \
    g=`basename $f`;                                                          \
    mv -v $f /usr/bin/`echo $g | sed -e 's/eabi//'`;                          \
  done

COPY linux-cross/build_freebsd_toolchain.sh /tmp/
RUN bash /tmp/build_freebsd_toolchain.sh i686
RUN bash /tmp/build_freebsd_toolchain.sh x86_64
COPY linux-cross/build_dragonfly_toolchain.sh /tmp/
RUN bash /tmp/build_dragonfly_toolchain.sh
COPY linux-cross/build_netbsd_toolchain.sh /tmp/
RUN bash /tmp/build_netbsd_toolchain.sh

# powerpc64le is built using centos7 glibc, because that has
# backports that weren't committed upstream until glibc-2.19.
COPY linux-cross/build_powerpc64le_linux_toolchain.sh /tmp/
RUN bash /tmp/build_powerpc64le_linux_toolchain.sh

# Also build libunwind.a for the ARM musl targets
COPY linux-cross/build-libunwind.sh \
    /build/
RUN /bin/bash build-libunwind.sh arm-unknown-linux-musleabi
RUN /bin/bash build-libunwind.sh arm-unknown-linux-musleabihf
RUN /bin/bash build-libunwind.sh armv7-unknown-linux-musleabihf

RUN apt-get install -y --force-yes --no-install-recommends \
        g++-mips64-linux-gnuabi64 \
        g++-mips64el-linux-gnuabi64

# Instruct rustbuild to use the armv7-linux-gnueabihf toolchain instead of the
# default arm-linux-gnueabihf one
ENV AR_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-ar \
    CC_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-gcc \
    CXX_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-g++ \
    AR_arm_unknown_linux_musleabi=arm-linux-musleabi-ar \
    CC_arm_unknown_linux_musleabi=arm-linux-musleabi-gcc \
    CXX_arm_unknown_linux_musleabi=arm-linux-musleabi-g++ \
    AR_arm_unknown_linux_musleabihf=arm-linux-musleabihf-ar \
    CC_arm_unknown_linux_musleabihf=arm-linux-musleabihf-gcc \
    CXX_arm_unknown_linux_musleabihf=arm-linux-musleabihf-g++ \
    AR_armv7_unknown_linux_musleabihf=armv7-linux-musleabihf-ar \
    CC_armv7_unknown_linux_musleabihf=armv7-linux-musleabihf-gcc \
    CXX_armv7_unknown_linux_musleabihf=armv7-linux-musleabihf-g++ \
    AR_x86_64_unknown_freebsd=x86_64-unknown-freebsd10-ar \
    CC_x86_64_unknown_freebsd=x86_64-unknown-freebsd10-gcc \
    CXX_x86_64_unknown_freebsd=x86_64-unknown-freebsd10-g++ \
    AR_i686_unknown_freebsd=i686-unknown-freebsd10-ar \
    CC_i686_unknown_freebsd=i686-unknown-freebsd10-gcc \
    CXX_i686_unknown_freebsd=i686-unknown-freebsd10-g++ \
    AR_x86_64_unknown_netbsd=x86_64-unknown-netbsd-ar \
    CC_x86_64_unknown_netbsd=x86_64-unknown-netbsd-gcc \
    CXX_x86_64_unknown_netbsd=x86_64-unknown-netbsd-g++ \
    AR_x86_64_unknown_dragonfly=x86_64-unknown-dragonfly-ar \
    CC_x86_64_unknown_dragonfly=x86_64-unknown-dragonfly-gcc \
    CXX_x86_64_unknown_dragonfly=x86_64-unknown-dragonfly-g++ \
    AR_mips_unknown_linux_gnu=mips-linux-gnu-ar \
    CC_mips_unknown_linux_gnu=mips-linux-gnu-gcc-5 \
    CXX_mips_unknown_linux_gnu=mips-linux-gnu-g++-5 \
    AR_mips_unknown_linux_musl=mips-linux-musl-ar \
    CC_mips_unknown_linux_musl=mips-linux-musl-gcc \
    CXX_mips_unknown_linux_musl=mips-linux-musl-g++ \
    AR_mipsel_unknown_linux_gnu=mipsel-linux-gnu-ar \
    CC_mipsel_unknown_linux_gnu=mipsel-linux-gnu-gcc-5 \
    CXX_mipsel_unknown_linux_gnu=mipsel-linux-gnu-g++-5 \
    AR_mipsel_unknown_linux_musl=mipsel-linux-musl-ar \
    CC_mipsel_unknown_linux_musl=mipsel-linux-musl-gcc \
    CXX_mipsel_unknown_linux_musl=mipsel-linux-musl-g++ \
    AR_powerpc_unknown_linux_gnu=powerpc-linux-gnu-ar \
    CC_powerpc_unknown_linux_gnu=powerpc-linux-gnu-gcc \
    CXX_powerpc_unknown_linux_gnu=powerpc-linux-gnu-g++ \
    AR_powerpc64_unknown_linux_gnu=powerpc64-linux-gnu-ar \
    CC_powerpc64_unknown_linux_gnu=powerpc64-linux-gnu-gcc \
    CXX_powerpc64_unknown_linux_gnu=powerpc64-linux-gnu-g++ \
    AR_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-ar \
    CC_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-gcc \
    CXX_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-g++ \
    AR_s390x_unknown_linux_gnu=s390x-linux-gnu-ar \
    CC_s390x_unknown_linux_gnu=s390x-linux-gnu-gcc \
    CXX_s390x_unknown_linux_gnu=s390x-linux-gnu-g++ \
    AR_mips64_unknown_linux_gnuabi64=mips64-linux-gnuabi64-ar \
    CC_mips64_unknown_linux_gnuabi64=mips64-linux-gnuabi64-gcc \
    CXX_mips64_unknown_linux_gnuabi64=mips64-linux-gnuabi64-g++ \
    AR_mips64el_unknown_linux_gnuabi64=mips64el-linux-gnuabi64-ar \
    CC_mips64el_unknown_linux_gnuabi64=mips64el-linux-gnuabi64-gcc \
    CXX_mips64el_unknown_linux_gnuabi64=mips64el-linux-gnuabi64-g++

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
