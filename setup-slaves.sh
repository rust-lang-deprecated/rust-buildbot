#!/bin/sh

while read slave pw
do
        echo "creating slave: $slave"
        buildslave create-slave $slave localhost:9987 $slave "${pw}"
        echo "admin@rust-lang.org" >$slave/info/admin
        echo $HOSTNAME >$slave/info/host
		case $MACHTYPE in
			*-msys)
				# service will start via service console
				;;
			*)
				(cd $slave && buildslave stop; buildslave start)
				;;
		esac
done
