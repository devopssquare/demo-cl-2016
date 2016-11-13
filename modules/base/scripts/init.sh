#!/bin/bash

set -e

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

$sudo apt-get update
$sudo apt-get install -qq puppet
# Fix for https://stackoverflow.com/questions/37892435/cant-install-puppet-modules-302-found-win-8-1-64-running-ubuntu-trusty-64-i
if grep -q module_repository= /etc/puppet/puppet.conf
   then echo "Current Puppet module repository is already set!"
   else sed -i -e '/\[main\]/a module_repository=https://forge.puppet.com' /etc/puppet/puppet.conf
fi

test -r /etc/puppet/modules/etckeeper || $sudo puppet module install thomasvandoren-etckeeper
test -r /etc/puppet/modules/stdlib || $sudo puppet module install puppetlabs-stdlib

# Avoid warning from initial puppet run
test -r /etc/puppet/hiera.yaml || $sudo touch /etc/puppet/hiera.yaml

$sudo puppet apply "$basedir/puppet/init.pp"
