FROM ubuntu:14.04

# MIPS compilers aren't available by default in ubuntu's repos, so we follow
# these intructions:
#
# http://sathisharada.blogspot.com/2014/10/hi-surfers-i-have-came-across-some.html
RUN echo 'deb http://ftp.de.debian.org/debian squeeze main' \
      | tee -a /etc/apt/sources.list
RUN echo 'deb http://www.emdebian.org/debian squeeze main' \
      | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes \
        curl make git wget \
        python-dev python-pip stunnel \
        g++ \
        gcc-arm-linux-gnueabi \
        gcc-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu \
        gcc-4.4-mips-linux-gnu \
        gcc-4.4-mipsel-linux-gnu

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# When running this container, startup buildbot
WORKDIR /buildslave
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
