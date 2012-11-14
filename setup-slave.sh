#!/bin/sh

if [ ! -d slave ]
then
	echo "No slave/ dir, setting up..."
	if hostname | grep -q '^ip-'
	then
		echo "Guessing we are on EC2, reading user-data"
		read SLAVENAME PASSWORD <<EOF
`curl -s http://169.254.169.254/latest/user-data`
EOF
	else
		echo "Enter slave name: "
		read SLAVENAME
		echo "Enter slave password: "
		read PASSWORD
	fi

	echo "creating slave: ${SLAVENAME:?}"
	buildslave create-slave slave localhost:9987 "${SLAVENAME:?}" "${PASSWORD:?}"
	echo "admin@rust-lang.org" >slave/info/admin
	echo $HOSTNAME >slave/info/host
fi

case $MACHTYPE in
	*-msys)
				# service will start via service console
		;;
	*)
		echo "starting stunnel..."
		for s in stunnel4 stunnel
		do
			if which $s
			then
				$s rust-buildbot-slave-stunnel.conf || echo "stunnel startup failed, already running?"
			fi
		done
		echo "starting slave..."
		buildslave restart slave
		;;
esac
