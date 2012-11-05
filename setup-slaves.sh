#!/bin/sh

echo "Enter slave name: "
read SLAVENAME

echo "Enter slave password: "
read -s PASSWORD

echo "creating slave: $SLAVENAME"
buildslave create-slave slave localhost:9987 "${SLAVENAME}" "${PASSWORD}"
echo "admin@rust-lang.org" >slave/info/admin
echo $HOSTNAME >slave/info/host
case $MACHTYPE in
	*-msys)
				# service will start via service console
		;;
	*)
		echo "starting slave..."
		(cd slave && buildslave stop; buildslave start)
		;;
esac
