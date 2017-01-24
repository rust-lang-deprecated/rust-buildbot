# `linux-cross`

This image is used to cross compile libstd/rustc to targets that run linux but
are not the `x86_64-unknown-linux-gnu` triple which is the "host" triple.

To cross compile libstd/rustc we need a C cross toolchain: a cross gcc and a
cross compiled libc.  For some targets, we use crosstool-ng to build these
toolchains ourselves instead of using the ones packaged for Ubuntu because:

- We can control the glibc version of the toolchain. In particular, we can lower
  its version as much as possible, this lets us generate libstd/rustc binaries
  that run in systems with old glibcs.
- We can create toolchains for targets that don't have an equivalent package
  available in Ubuntu.

crosstool-ng uses a `.config` file, generated via a menuconfig interface, to
specify the target, glibc version, etc. of the toolchain to build. Because this
menuconfig interface requires user intervention we store pre-generated `.config`
files in this repository to keep the `docker build` command free of user
intervention.

The next section explains how to generate a `.config` file for a new target, and
the one after that contains the changes, on top of the default toolchain
configuration, used to generate the `.config` files stored in this repository.

## Generating a `.config` file

If you have a `linux-cross` image lying around you can use that and skip the
next two steps.

- First we spin up a container and copy `build_toolchain_root.sh` into it. All
  these steps are outside the container:

```
# Note: We use ubuntu:15.10 because that's the "base" of linux-cross Docker
# image
$ docker run -it ubuntu:15.10 bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
cfbec05ed730        ubuntu:15.10        "bash"              16 seconds ago      Up 15 seconds                           drunk_murdock
$ docker cp build_toolchain_root.sh drunk_murdock:/
```

- Then inside the container we build crosstool-ng by simply calling the bash
  script we copied in the previous step:

```
$ bash build_toolchain_root.sh
```

- Now, inside the container run the following command to configure the
  toolchain. To get a clue of which options need to be changed check the next
  section and come back.

```
$ ct-ng menuconfig
```

- Finally, we retrieve the `.config` file from the container and give it a
  meaningful name. This is done outside the container.

```
$ docker drunk_murdock:/.config arm-linux-gnueabi.config
```

- Now you can shutdown the container or repeat the two last steps to generate a
  new `.config` file.

## Toolchain configuration

Changes on top of the default toolchain configuration used to generate the
`.config` files in this directory. The changes are formatted as follows:

```
$category > $option = $value -- $comment
```

## `arm-linux-gnueabi.config`

For targets: `arm-unknown-linux-gnueabi`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Floating point = software (no FPU) -- (\*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > glibc version = 2.14.1
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `arm-linux-musleabi.config`

For targets: `arm-unknown-linux-musleabi`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Floating point = software (no FPU) -- (\*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > C library = musl
- C compiler > gcc version = 5.2.0
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `arm-linux-gnueabihf.config`

For targets: `arm-unknown-linux-gnueabihf`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Use specific FPU = vfp -- (+)
- Target options > Floating point = hardware (FPU) -- (\*)
- Target options > Default instruction set mode = arm -- (+)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > glibc version = 2.14.1
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `arm-linux-musleabihf.config`

For targets: `arm-unknown-linux-musleabihf`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Use specific FPU = vfp -- (+)
- Target options > Floating point = hardware (FPU) -- (\*)
- Target options > Default instruction set mode = arm -- (+)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > C library = musl
- C compiler > gcc version = 5.2.0
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `armv7-linux-gnueabihf.config`

For targets: `armv7-unknown-linux-gnueabihf`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Suffix to the arch-part = v7
- Target options > Architecture level = armv7-a -- (+)
- Target options > Use specific FPU = vfpv3-d16 -- (\*)
- Target options > Floating point = hardware (FPU) -- (\*)
- Target options > Default instruction set mode = thumb -- (\*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > glibc version = 2.14.1
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

(\*) These options have been selected to match the configuration of the arm
      toolchains shipped with Ubuntu 15.10
(+) These options have been selected to match the gcc flags we use to compile C
    libraries like jemalloc. See the mk/cfg/arm(v7)-uknown-linux-gnueabi{,hf}.mk
    file in Rust's source code.

## `armv7-linux-musleabihf.config`

For targets: `armv7-unknown-linux-musleabihf`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Suffix to the arch-part = v7
- Target options > Architecture level = armv7-a -- (+)
- Target options > Use specific FPU = vfpv3-d16 -- (\*)
- Target options > Floating point = hardware (FPU) -- (\*)
- Target options > Default instruction set mode = thumb -- (\*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > C library = musl
- C compiler > gcc version = 5.2.0
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `aarch64-linux-gnu.config`

For targets: `aarch64-unknown-linux-gnu`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Bitness = 64-bit
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 4.2.6
- C-library > glibc version = 2.17 -- aarch64 support was introduced in this version
- C compiler > gcc version = 5.2.0
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `mips-linux-musl.config`

For targets: `mips-unknown-linux-musl`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = mips
- Target options > Endianness = **Big** endian
- Target options > Architecture level = mips32r2 -- (+)
- Target options > Floating point = software (no FPU) -- (+)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 4.3 -- OpenWRT trunk uses 4.4 though
- C-library > C library = musl
- C-library > musl version = 1.0.5 -- OpenWRT trunk uses 1.1.14 though
- C compiler > gcc version = 5.2
- C compiler > C++ = ENABLE -- compiler-rt demands a C++ compiler even when we don't use it

## `mipsel-linux-musl.config`

For targets: `mipsel-unknown-linux-musl`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = mips
- Target options > Endianness = **Little** endian
- Target options > Architecture level = mips32 -- (+)
- Target options > Floating point = software (no FPU) -- (+)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 4.3 -- OpenWRT trunk uses 4.4 though
- C-library > C library = musl
- C-library > musl version = 1.0.5 -- OpenWRT trunk uses 1.1.14 though
- C compiler > gcc version = 5.2
- C compiler > C++ = ENABLE -- compiler-rt demands a C++ compiler even when we don't use it

(+) These options have been selected to match the gcc flags we use to compile C
    libraries like jemalloc. See the mk/cfg/mips(el)-uknown-linux-musl.mk
    file in Rust's source code.

## `powerpc-linux-gnu.config`

For targets: `powerpc-unknown-linux-gnu`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Path and misc options > Patches origin = Bundled, then local
- Path and misc options > Local patch directory = /build/patches
- Target options > Target Architecture = powerpc
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 2.6.32.68 -- ~RHEL6 kernel
- C-library > glibc version = 2.12.2 -- ~RHEL6 glibc
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `powerpc64-linux-gnu.config`

For targets: `powerpc64-unknown-linux-gnu`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Path and misc options > Patches origin = Bundled, then local
- Path and misc options > Local patch directory = /build/patches
- Target options > Target Architecture = powerpc
- Target options > Bitness = 64-bit
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 2.6.32.68 -- ~RHEL6 kernel
- C-library > glibc version = 2.12.2 -- ~RHEL6 glibc
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `s390x-linux-gnu.config`

For targets: `s390x-unknown-linux-gnu`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Path and misc options > Patches origin = Bundled, then local
- Path and misc options > Local patch directory = /build/patches
- Target options > Target Architecture = s390
- Target options > Bitness = 64-bit
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 2.6.32.68 -- ~RHEL6 kernel
- C-library > glibc version = 2.12.2 -- ~RHEL6 glibc
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM
