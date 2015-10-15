#!/bin/sh

git clone https://github.com/alexcrichton/rust-buildbot
export NODAEMON=1
exec sh rust-buildbot/setup-slave.sh
