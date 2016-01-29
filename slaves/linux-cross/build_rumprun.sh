#!/bin/bash

set -ex

git clone --recursive https://github.com/rumpkernel/rumprun
cd rumprun
CC=cc ./build-rr.sh -d /usr/local hw
