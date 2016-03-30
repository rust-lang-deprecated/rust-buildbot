FROM ubuntu:14.04

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y \
        curl make xz-utils git \
        python-dev python-pip stunnel \
        g++-multilib libssl-dev libssl-dev:i386 gdb \
        valgrind libc6-dbg:i386 software-properties-common

# for cargo, we need cmake-3.1.2+ to avoid a cmake bug where it doesn't detect
# OpenSSL-1.0.2.
# See https://cmake.org/Bug/bug_relationship_graph.php?bug_id=15386
RUN add-apt-repository ppa:george-edison55/cmake-3.x && apt-get update
RUN apt-get install -y cmake

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
