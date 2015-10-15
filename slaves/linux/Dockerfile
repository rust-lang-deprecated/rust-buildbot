FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y curl g++-multilib make cmake xz-utils git \
                       python-dev python-pip stunnel

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Install all our build dependencies
WORKDIR /build
COPY build-musl.sh build-musl.sh
RUN sh build-musl.sh

# When running this container, startup buildbot
USER rustbuild
WORKDIR /buildslave
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
