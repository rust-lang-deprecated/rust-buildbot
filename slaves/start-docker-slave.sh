#!/bin/sh

url=`curl http://169.254.169.254/latest/user-data | tail -n +3 | head -n 1`
branch=`curl http://169.254.169.254/latest/user-data | tail -n +4 | head -n 1`
git clone $url --branch $branch
export NODAEMON=1
exec sh rust-buildbot/setup-slave.sh
