# `linux-cross`

This image is used to cross compile libstd/rustc to targets that run linux but are not the
`x86_64-unknown-linux-gnu` triple which is the "host" triple.

To cross compile libstd/rustc we need a C cross toolchain: a cross gcc and a cross compiled libc.
For some targets, we use crosstool-ng to build these toolchains ourselves instead of using the ones
packaged for Ubuntu because:

- We can control the glibc version of the toolchain. In particular, we can lower its version as much
    as possible, this lets us generate libstd/rustc binaries that run in systems with old glibcs.
- We can create toolchains for targets that don't have an equivalent package available in Ubuntu.

crosstool-ng uses a `.config` file, generated via a menuconfig interface, to specify the target,
glibc version, etc. of the toolchain to build. Because this menuconfig interface requires user
intervention we store pre-generated `.config` files in this repository to keep the `docker build`
command free of user intervention.

The next section explains how to generate a `.config` file for a new target, and the one after that
contains the changes, on top of the default toolchain configuration, used to generate the `.config`
files stored in this repository.

## Generating a `.config` file

If you have a `linux-cross` image lying around you can use that and skip the next two steps.

- First we spin up a container and copy `build_toolchain_root.sh` into it. All these steps are
    outside the container:

```
# Note: We use ubuntu:15.10 because that's the "base" of linux-cross Docker image
$ docker run -it ubuntu:15.10 bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
cfbec05ed730        ubuntu:15.10        "bash"              16 seconds ago      Up 15 seconds                           drunk_murdock
$ docker cp build_toolchain_root.sh drunk_murdock:/
```

- Then inside the container we build crosstool-ng by simply calling the bash script we copied in the
    previous step:

```
$ bash build_toolchain_root.sh
```

- Now, inside the container run the following command to configure the toolchain. To get a clue of
    which options need to be changed check the next section and come back.

```
$ ct-ng menuconfig
```

- Finally, we retrieve the `.config` file from the container and give it a meaningful name. This is
    done outside the container.

```
$ docker drunk_murdock:/.config arm-linux-gnueabi.config
```

- Now you can shutdown the container or repeat the two last steps to generate a new `.config` file.

## Toolchain configuration

Changes on top of the default toolchain configuration used to generate the `.config` files in this
directory. The changes are formatted as follows:

```
$category > $option = $value -- $comment
```

## `arm-linux-gnueabi.config`

For targets: `arm-unknown-linux-gnueabi`

- Path and misc options > Prefix directory = /x-tools/${CT_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Floating point = software (no FPU) -- (*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > glibc version = 2.14.1
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

## `arm-linux-gnueabihf.config`

For targets: `arm-unknown-linux-gnueabihf`, `armv7-unknown-linux-gnueabihf`

- Path and misc options > Prefix directory = /x-tools/${CT_TARGET}
- Target options > Target Architecture = arm
- Target options > Architecture level = armv6 -- (+)
- Target options > Use specific FPU = vfpv3-d16 -- (*)
- Target options > Floating point = hardware (FPU) -- (*)
- Target options > Default instruction set mode (thumb) -- (*)
- Operating System > Target OS = linux
- Operating System > Linux kernel version = 3.2.72 -- Precise kernel
- C-library > glibc version = 2.14.1
- C compiler > gcc version = 4.9.3
- C compiler > C++ = ENABLE -- to cross compile LLVM

(*) These options have been selected to match the configuration of the arm toolchains shipped with
Ubuntu 15.10
(+) These options have been selected to match the gcc flags we use to compile C libraries like
jemalloc. See the mk/cfg/arm-uknown-linux-gnueabi{,hf}.mk file in Rust's source code.
