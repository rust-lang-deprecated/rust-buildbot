FROM ubuntu:15.10

RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        curl make git wget file \
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
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Install arm cross compiler
# NOTE crosstool-ng can't be executed by root so we execute it under the rustbuild user. /x-tools
# is the crosstool-ng output directory and /build is the crosstool-ng build directory so both must
# be writable by rustbuild
WORKDIR /build
COPY linux-cross/build_toolchain_root.sh /build/
RUN /bin/bash build_toolchain_root.sh && \
    mkdir /x-tools && \
    chown rustbuild:rustbuild /build && \
    chown rustbuild:rustbuild /x-tools
COPY linux-cross/build_toolchain.sh \
    linux-cross/arm-linux-gnueabi.config \
    linux-cross/arm-linux-gnueabihf.config \
    /build/
USER rustbuild
RUN /bin/bash build_toolchain.sh arm-linux-gnueabi && \
    /bin/bash build_toolchain.sh arm-linux-gnueabihf
USER root
RUN rm -rf /build

RUN                                               \
  for f in `ls /x-tools/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done &&                                        \
  for f in `ls /x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-*`; do     \
    g=`basename $f`;  \
    ln -vs $f /usr/bin/`echo $g | sed -e 's/-unknown//'`;    \
  done

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
