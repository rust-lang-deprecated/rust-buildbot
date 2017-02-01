FROM centos:5

WORKDIR /build

# Install updates.
RUN yum upgrade -y

# curl == now we can download things
# bzip2 == now we can download bz2 things
# gcc == now we can build gcc
# make == now we can build gcc
# glibc-devel == libs for gcc to compile against
# perl == run openssl configure script + runtime dep of git
# zlib-devel == needed by basically everyone
# file == needed by the rust build
# xz == needed to extract LLVM sources
# which, stunnel == needed by rust-buildbot startup scripts
RUN yum install -y curl bzip2 gcc make glibc-devel perl zlib-devel file xz \
          which stunnel pkg-config

ENV PATH=/rustroot/bin:/rust/bin:$PATH
ENV LD_LIBRARY_PATH=/rustroot/lib64:/rustroot/lib

# prep the buildslave user and some directories
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave
RUN mkdir /home/rustbuild
RUN chown rustbuild:rustbuild /home/rustbuild

# We need a build of openssl which supports SNI to download artifacts from
# static.rust-lang.org. This'll be used to link into libcurl below (and used
# later as well), so build a copy of OpenSSL with dynamic libraries into our
# generic root.
COPY dist/build_openssl.sh /build/
RUN /bin/bash build_openssl.sh && rm -rf /build

# The `curl` binary on CentOS doesn't support SNI which is needed for fetching
# some https urls we have, so install a new version of libcurl + curl which is
# using the openssl we just built previously.
#
# Note that we also disable a bunch of optional features of curl that we don't
# really need.
COPY dist/build_curl.sh /build/
RUN /bin/bash build_curl.sh

# Install gcc 4.7 which has C++11 support which is required by LLVM
#
# After we're done building we erase the binutils/gcc installs from CentOS to
# ensure that we always use the ones that we just built.
COPY dist/build_gcc.sh /build/
RUN /bin/bash build_gcc.sh && rm -rf /build

# binutils < 2.22 has a bug where the 32-bit executables it generates
# immediately segfault in Rust, so we need to install our own binutils.
#
# See https://github.com/rust-lang/rust/issues/20440 for more info
COPY dist/build_binutils.sh /build/
RUN /bin/bash build_binutils.sh && rm -rf /build

# libssh2 (a dependency of Cargo) requires cmake 2.8.11 or higher but CentOS
# only has 2.6.4, so build our own
COPY dist/build_cmake.sh /build/
RUN /bin/bash build_cmake.sh && rm -rf /build

# tar on CentOS is too old as it doesn't understand the --exclude-vcs option
# that the Rust build system passes it, so install a new version.
COPY dist/build_tar.sh /build/
RUN /bin/bash build_tar.sh && rm -rf /build

# CentOS 5.5 has Python 2.4 by default, but LLVM needs 2.7+
COPY dist/build_python.sh /build/
RUN /bin/bash build_python.sh && rm -rf /build

# The Rust test suite requires a relatively new version of gdb, much newer than
# CentOS has to offer by default, and we want it to use the newly installed
# python so it's ordered here.
COPY dist/build_gdb.sh /build/
RUN /bin/bash build_gdb.sh && rm -rf /build

# Apparently CentOS 5.5 desn't have `git` in yum, but we're gonna need it for
# cloning, so download and build it here.
COPY dist/build_git.sh /build/
RUN /bin/bash build_git.sh && rm -rf /build

# Install buildbot and prep it to run
RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install buildbot-slave

# Clean up after ourselves, make sure that `cc` is a thing, and then make the
# default working directory a "home-ish" directory
WORKDIR /buildslave
RUN rm -rf /build
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
