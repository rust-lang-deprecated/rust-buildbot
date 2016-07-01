FROM ubuntu:16.04

RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install --force-yes \
        curl make git expect libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
        python-dev python-pip stunnel \
        g++-multilib openjdk-9-jre psmisc unzip cmake

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Setup PATH to allow running android tools.
ENV PATH=$PATH:/android/ndk-arm/bin:/android/ndk-aarch64/bin:/android/ndk-x86:/android/sdk/tools:/android/sdk/platform-tools

# Not sure how to install 64-bit binaries in the sdk?
ENV ANDROID_EMULATOR_FORCE_32BIT=true

RUN mkdir /android && chown rustbuild:rustbuild /android
RUN mkdir /home/rustbuild && chown rustbuild:rustbuild /home/rustbuild

WORKDIR /android
USER rustbuild

COPY android/install-ndk.sh android/install-sdk.sh android/accept-licenses.sh \
    /android/

RUN sh install-ndk.sh
RUN sh install-sdk.sh
RUN rm *.sh

# When running this container, startup buildbot
WORKDIR /buildslave
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
