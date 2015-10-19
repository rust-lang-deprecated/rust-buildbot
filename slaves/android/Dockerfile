FROM ubuntu:14.04

RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install --force-yes \
        curl make git expect libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
        python-dev python-pip stunnel \
        g++-multilib openjdk-6-jre

# Install buildbot and prep it to run
RUN pip install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Setup PATH to allow running android tools.
ENV PATH=$PATH:/android/ndk-arm/bin:/android/ndk-aarch64/bin:/android/ndk-x86:/android/sdk/tools:/android/sdk/platform-tools

WORKDIR /android
RUN chown rustbuild:rustbuild /android
USER rustbuild

# Prep the Android NDK
#
# See https://github.com/servo/servo/wiki/Building-for-Android
RUN curl -O http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
RUN chmod +x android-ndk-r10e-linux-x86_64.bin
RUN ./android-ndk-r10e-linux-x86_64.bin
RUN bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-18 \
        --toolchain=arm-linux-androideabi-4.8 \
        --install-dir=/android/ndk-arm \
        --ndk-dir=/build/android-ndk-r10e \
        --arch=arm
RUN bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=aarch64-linux-android-4.9 \
        --install-dir=/android/ndk-aarch64 \
        --ndk-dir=/build/android-ndk-r10e \
        --arch=arm64
RUN bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-18 \
        --toolchain=x86-4.9 \
        --install-dir=/android/ndk-x86 \
        --ndk-dir=/build/android-ndk-r10e \
        --arch=x86
RUN bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=x86_64-4.9 \
        --install-dir=/android/ndk-x86_64 \
        --ndk-dir=/build/android-ndk-r10e \
        --arch=x86_64
RUN rm -rf ./android-ndk-r10e-linux-x86_64.bin ./android-ndk-r10e

# Prep the SDK and emulator
#
# Note that the update process requires that we accept a bunch of licenses, and
# we can't just pipe `yes` into it for some reason, so we take the same strategy
# located in https://github.com/appunite/docker by just wrapping it in a script
# which apparently magically accepts the licenses.
RUN curl -O http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz
RUN tar xf android-sdk_r24.3.4-linux.tgz
COPY android/android-accept-licenses.sh /android/android-accept-licenses.sh
RUN mv android-sdk-linux sdk
RUN ["./android-accept-licenses.sh", \
     "android - update sdk -a --no-ui --filter platform-tools,android-18,android-21,sys-img-x86-android-18,sys-img-x86_64-android-21,sys-img-armeabi-v7a-android-18"]
RUN echo "no" | android create avd \
                --name arm-18 \
                --target android-18 \
                --abi armeabi-v7a
RUN echo "no" | android create avd \
                --name x86-18 \
                --target android-18 \
                --abi x86
RUN echo "no" | android create avd \
                --name x86_64-21 \
                --target android-21 \
                --abi x86_64
RUN rm android-accept-licenses.sh

# When running this container, startup buildbot
WORKDIR /buildslave
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
