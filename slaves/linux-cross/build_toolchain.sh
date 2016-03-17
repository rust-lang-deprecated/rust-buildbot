#!/bin/bash

set -ex

mkdir $1
pushd $1
cp ../${1}.config .config
ct-ng oldconfig
ct-ng build
rm -rf .build
popd
rm -rf $1
