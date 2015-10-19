FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y \
        curl make git wget \
        python-dev python-pip stunnel \
        g++

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

WORKDIR /build
COPY linux-cross/build-gcc.sh /build/

# Unfortunately on Ubuntu we can't install both gcc-multilib and all the cross
# compilers we want, so we just build our own gcc with multilib and then
# uninstall the standard gcc/g++ and then install all the standard cross
# compilers.
RUN sh build-gcc.sh
RUN apt-get remove -y g++-multilib gcc-multilib g++ gcc
RUN apt-get install -y --force-yes \
        gcc-arm-linux-gnueabi \
        gcc-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu \
        gcc-4.4-mips-linux-gnu \
        gcc-4.4-mipsel-linux-gnu
ENV PATH=$PATH:/opt/gcc/bin
ENV LD_LIBRARY_PATH=/opt/gcc/lib
RUN ln -nsf gcc /opt/gcc/bin/cc

# When running this container, startup buildbot
WORKDIR /buildslave
RUN rm -rf /build
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
