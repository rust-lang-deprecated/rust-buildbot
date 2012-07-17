#!/bin/sh

while read slave pw
do
        echo "creating slave: $slave"
        buildslave create-slave $slave localhost:9987 $slave "${pw}"
        echo "admin@rust-lang.org" >$slave/info/admin
        echo `hostname -f` >$slave/info/host
done
