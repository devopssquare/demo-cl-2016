#!/bin/bash

set -eu

dir=`dirname $0`

basedir="${dir}/.."

modulename=`dirname $basedir`
modulename=`dirname $modulename`
modulename=`basename $modulename`
cat<<EOM
======================================================================
Installing "${modulename}"
======================================================================
EOM

if test -r /vagrant/.vagrantenv
   then echo "Loading Vagrant environment"
        source /vagrant/.vagrantenv
fi

sudo=/usr/bin/sudo
if test -x $sudo
   then sudo="$sudo -E"
   else sudo=
fi

test -r /etc/puppet/modules/docker || $sudo puppet module install garethr-docker

: ${DOCKER_STRACE:=""}

strace=""
if test -n "${DOCKER_STRACE}"
   then date=`date +%y%m%d-%H%M%S`
        $sudo mkdir -p /vagrant/docker-setup/$date
        strace="/usr/bin/strace -o /vagrant/docker-setup/$date/docker-strace -f -ttt"
        echo "Performing Docker setup with '${strace}'" >&2
fi
$sudo $strace puppet apply "$basedir/puppet/init.pp"

set +u # Avoid hassles if $TEST_SKIP is not set!
if test -z "${TEST_SKIP}" -o "${TEST_SKIP}" != "false"
   then set -u
        # Sometimes docker does not directly come up? TODO: Investigate this!!!
        sleeptime=10
        maxtries=5
        try=0
        echo "Sleeping ${sleeptime}s until Docker is up and running (first)"
        sleep $sleeptime
        until $dir/test.sh || test $try -ge $maxtries
        do  $sudo service docker stop || echo "Docker was not yet started (ignored)" >&2
            # Check out https://github.com/docker/docker/issues/23078
            $sudo /bin/rm -f /var/lib/docker/network/files/local-kv.db
            $sudo /bin/rm -f /var/run/docker.*
            $sudo service docker start
            try=`expr $try + 1`
            echo "Sleeping ${sleeptime}s until Docker is up and running (try #$try/$maxtries)"
            sleep $sleeptime
        done
        $dir/test.sh
fi
