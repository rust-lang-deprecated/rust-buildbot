FROM ubuntu:15.10

RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        curl make git wget file \
        python-dev python-pip stunnel \
        g++ gcc libc6-dev \
        gcc-4.7-arm-linux-gnueabi libc6-dev-armel-cross \
        gcc-4.7-arm-linux-gnueabihf libc6-dev-armhf-cross \
        gcc-4.8-aarch64-linux-gnu libc6-dev-arm64-cross \
        gcc-4.8-powerpc-linux-gnu libc6-dev-powerpc-cross \
        gcc-4.8-powerpc64le-linux-gnu libc6-dev-ppc64el-cross \
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
RUN git clone --recursive http://repo.rumpkernel.org/rumprun
WORKDIR /build/rumprun
RUN CC=cc ./build-rr.sh hw

ENV PATH=$PATH:/build/rumprun/rumprun/bin

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
