#!/bin/sh

cd `dirname $0`

if [ "$1" = "--manual" ]
then
    echo "Enter slave name: "
    read SLAVENAME
    echo "Enter slave password: "
    read PASSWORD
    echo "Enter master address: "
    read MASTER_ADDY
else
    # Some images take time for the user data to appear
    sleep 1
    echo "Guessing we are on EC2, reading user-data"
    read SLAVENAME PASSWORD MASTER_ADDY <<EOF
`curl -s http://169.254.169.254/latest/user-data`
EOF
fi

rm -f slave/buildbot.tac* slave/twistd.* slave/info/admin slave/info/host
echo "(re)creating slave: ${SLAVENAME:?}"
buildslave create-slave --force slave localhost:9987 "${SLAVENAME:?}" "${PASSWORD:?}"
echo "admin@rust-lang.org" >slave/info/admin
echo $HOSTNAME >slave/info/host

cp rust-buildbot-slave-stunnel.conf rust-buildbot-slave-stunnel-final.conf
echo "connect = ${MASTER_ADDY:?}" >> rust-buildbot-slave-stunnel-final.conf

case $MACHTYPE in
    *-msys)
            # strip out a line that doesn't work on windows
            cat rust-buildbot-slave-stunnel-final.conf | sed 's/pid =//' > stunnel-tmp.conf && mv stunnel-tmp.conf rust-buildbot-slave-stunnel-final.conf
            cp rust-buildbot-slave-stunnel-final.conf "/c/Program Files (x86)/stunnel/stunnel.conf"
        net start stunnel
        net start buildbot
        ;;
    *)
        echo "starting stunnel..."
        for s in stunnel4 stunnel
        do
            if which $s
            then
                $s rust-buildbot-slave-stunnel-final.conf || echo "stunnel startup failed, already running?"
            fi
        done
        echo "starting slave..."
        if [ "$NODAEMON" = "1" ]; then
            buildslave restart --nodaemon slave
        else
            buildslave restart slave
        fi
        ;;
esac
