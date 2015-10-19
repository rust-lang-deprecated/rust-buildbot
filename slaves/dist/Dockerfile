FROM centos:5

WORKDIR /build

# curl == now we can download things
# bzip2 == now we can download bz2 things
# wget == gcc download_prerequisites script dep
# gcc == now we can build gcc
# make == now we can build gcc
# glibc-devel == libs for gcc to compile against
# perl == run openssl configure script + runtime dep of git
# autoconf, gettext == deps of git
# zlib-devel == needed by basically everyone
# bzip2-devel == bzip support in python, needed for unzipping snapshots.
# file == needed by the rust build
# setarch == needed to build 32-bit openssl
# xz == needed to extract LLVM sources
# ncurses-devel == needed by gdb
# texinfo == needed by gdb `make install`
RUN yum install -y curl bzip2 wget gcc make glibc-devel perl autoconf \
                   gettext zlib-devel bzip2-devel file setarch xz \
                   ncurses-devel texinfo


ENV PATH=/rustroot/bin:/rust/bin:$PATH
ENV LD_LIBRARY_PATH=/rustroot/lib64:/rustroot/lib

COPY dist/build_binutils.sh dist/build_gcc.sh dist/build_openssl.sh \
    dist/build_curl.sh dist/build_git.sh \
    dist/build_python.sh dist/build_cmake.sh dist/build_tar.sh \
    dist/build_gdb.sh /build/

# binutils < 2.22 has a bug where the 32-bit executables it generates
# immediately segfault in Rust, so we need to install our own binutils.
#
# See https://github.com/rust-lang/rust/issues/20440 for more info
RUN sh build_binutils.sh

# Install gcc 4.7 which has C++11 support which is required by LLVM
#
# After we're done building we erase the binutils/gcc installs from CentOS to
# ensure that we always use the ones that we just built.
RUN sh build_gcc.sh

# We need a build of openssl which supports SNI to download artifacts from
# static.rust-lang.org. This'll be used to link into libcurl below (and used
# later as well), so build a copy of OpenSSL with dynamic libraries into our
# generic root.
RUN sh build_openssl.sh

# The `curl` binary on CenOS doesn't support SNI which is needed for fetching
# some https urls we have, so install a new version of libcurl + curl which is
# using the openssl we just built previously.
#
# Note that we also disable a bunch of optional features of curl that we don't
# really need.
RUN sh build_curl.sh

# Apparently CentOS 5.5 desn't have `git` in yum, but we're gonna need it for
# cloning, so download and build it here.
RUN sh build_git.sh

# CentOS 5.5 has Python 2.4 by default, but LLVM needs 2.7+
RUN sh build_python.sh

# libssh2 (a dependency of Cargo) requires cmake 2.8.11 or higher but CentOS
# only has 2.6.4, so build our own
RUN sh build_cmake.sh

# tar on CentOS is too old as it doesn't understand the --exclude-vcs option
# that the Rust build system passes it, so install a new version.
RUN sh build_tar.sh

# The Rust test suite requires a relatively new version of gdb, much newer than
# CentOS has to offer by default
RUN sh build_gdb.sh

# Install buildbot and prep it to run
RUN curl https://bootstrap.pypa.io/ez_setup.py | python
RUN easy_install buildbot-slave
RUN groupadd -r rustbuild && useradd -r -g rustbuild rustbuild
RUN mkdir /buildslave && chown rustbuild:rustbuild /buildslave

# Clean up after ourselves, make sure that `cc` is a thing, and then make the
# default working directory a "home-ish" directory
WORKDIR /buildslave
RUN rm -rf /build
USER rustbuild
COPY start-docker-slave.sh start-docker-slave.sh
ENTRYPOINT ["sh", "start-docker-slave.sh"]
