FROM ubuntu:15.10

RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        curl make cmake git wget file \
        python-dev python-pip stunnel \
        g++ gcc libc6-dev \
        gcc-4.8-aarch64-linux-gnu libc6-dev-arm64-cross \
        gcc-4.8-powerpc-linux-gnu libc6-dev-powerpc-cross \
        gcc-4.8-powerpc64le-linux-gnu libc6-dev-ppc64el-cross \
        lib64gcc-4.8-dev-powerpc-cross libc6-dev-ppc64-powerpc-cross \
        software-properties-common
RUN add-apt-repository ppa:angelsl/mips-cross && apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        gcc-5-mips-linux-gnu libc6-dev-mips-cross \
        gcc-5-mipsel-linux-gnu libc6-dev-mipsel-cross

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

# Install rumprun cross compiler
WORKDIR /build
COPY linux-cross/build_rumprun.sh /build/
RUN /bin/bash build_rumprun.sh && rm -rf /build

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -m -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

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
    linux-cross/arm-linux-gnueabi.config \
    linux-cross/arm-linux-gnueabihf.config \
    linux-cross/mips-linux-musl.config \
    linux-cross/mipsel-linux-musl.config \
    linux-cross/armv7-linux-gnueabihf.config \
    /build/
USER rustbuild

# Build two full toolchains for the `arm-unknown-linux-gneuabi` and
# `arm-unknown-linux-gnueabihf` targets. We build toolchains from scratch to
# primarily move to an older glibc. Ubuntu does indeed have these toolchains in
# its repositories (so we could install that package), but they package a
# relatively newer version of glibc. In order for the binaries we produce to be
# maximall compatible, we push the glibc version back to 2.14
RUN /bin/bash build_toolchain.sh arm-linux-gnueabi
RUN /bin/bash build_toolchain.sh arm-linux-gnueabihf

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

RUN /bin/bash build_toolchain.sh armv7-linux-gnueabihf

USER root
RUN rm -rf /build

# Rename all the compilers we just built into /usr/bin and also without
# `-unknown-` in the name because it appears lots of other compilers in Ubuntu
# don't have this name in the component by default either.
RUN                                               \
  for f in `ls /x-tools/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done &&                                        \
  for f in `ls /x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done &&                                        \
  for f in `ls /x-tools/mips-unknown-linux-musl/bin/mips-unknown-linux-musl-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done &&                                        \
  for f in `ls /x-tools/mipsel-unknown-linux-musl/bin/mipsel-unknown-linux-musl-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done &&                                        \
  for f in `ls /x-tools/armv7-unknown-linux-gnueabihf/bin/armv7-unknown-linux-gnueabihf-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done

# Instruct rustbuild to use the armv7-linux-gnueabihf toolchain instead of the default
# arm-linux-gnueabihf one
ENV AR_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-ar \
  CC_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-gcc \
  CXX_armv7_unknown_linux_gnueabihf=armv7-linux-gnueabihf-g++

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
