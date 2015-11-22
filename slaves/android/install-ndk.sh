#!/bin/sh

set -ex

# Prep the Android NDK
#
# See https://github.com/servo/servo/wiki/Building-for-Android
curl -O http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
chmod +x android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin > /dev/null
bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=arm-linux-androideabi-4.8 \
        --install-dir=/android/ndk-arm \
        --ndk-dir=/android/android-ndk-r10e \
        --arch=arm
bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=aarch64-linux-android-4.9 \
        --install-dir=/android/ndk-aarch64 \
        --ndk-dir=/android/android-ndk-r10e \
        --arch=arm64
bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=x86-4.9 \
        --install-dir=/android/ndk-x86 \
        --ndk-dir=/android/android-ndk-r10e \
        --arch=x86
bash android-ndk-r10e/build/tools/make-standalone-toolchain.sh \
        --platform=android-21 \
        --toolchain=x86_64-4.9 \
        --install-dir=/android/ndk-x86_64 \
        --ndk-dir=/android/android-ndk-r10e \
        --arch=x86_64

rm -rf ./android-ndk-r10e-linux-x86_64.bin ./android-ndk-r10e
