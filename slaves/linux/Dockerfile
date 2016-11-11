FROM ubuntu:16.04

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y \
        curl make xz-utils git \
        python-dev python-pip stunnel \
        g++-multilib libssl-dev libssl-dev:i386 gdb \
        valgrind libc6-dbg:i386 \
        cmake pkg-config

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

WORKDIR /build
COPY linux/build-musl.sh /build/

# Install MUSL to support crossing to that target
RUN sh build-musl.sh

# When running this container, startup buildbot
WORKDIR /buildslave
RUN rm -rf /build
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
