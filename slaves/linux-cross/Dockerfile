FROM ubuntu:15.10

RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        curl make git wget file \
        python-dev python-pip stunnel \
        g++ gcc libc6-dev \
        gcc-arm-linux-gnueabi libc6-dev-armel-cross \
        gcc-arm-linux-gnueabihf libc6-dev-armhf-cross \
        gcc-aarch64-linux-gnu libc6-dev-arm64-cross \
        software-properties-common
RUN add-apt-repository ppa:angelsl/mips-cross
RUN apt-get update
RUN apt-get install -y --force-yes --no-install-recommends \
        gcc-5-mips-linux-gnu libc6-dev-mips-cross \
        gcc-5-mipsel-linux-gnu libc6-dev-mipsel-cross
RUN for f in `ls /usr/bin/mips*-linux-gnu-*-5`; do ln -vs $f `echo $f | sed -e 's/-5$//'`; done

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
