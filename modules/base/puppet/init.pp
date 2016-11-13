# Default: ensure latest version!
Package {
  ensure  => "latest"
}

# Delete some default packages ...
package { 'nfs-common':
  ensure  => "purged"
}
package { 'rpcbind':
  ensure  => "purged"
}

# The minimal set of packages we would like to see!
package { "git": }
package { "screen": }
package { "apticron": }

# Some Packages required for testing
package { "libwww-mechanize-perl": }
package { "libtest-html-content-perl": }

# Install hiera (at least to make warnings disappear :-)
file { '/etc/puppet':
  ensure  => 'directory',
  owner   => 'root',
  group   => 'root',
  mode    => 0755,
}

file { '/etc/puppet/hiera.yaml':
  owner    => 'root',
  group    => 'root',
  mode     => 0444,
  content  => "---
:backends:
  - yaml

:logger: console

:hierarchy:
  - \"networks/%{::network_enp0s3}\"
  # This is a work around for older hiera versions! It may not work for hosts without any default network!!!
  - \"networks/$network_eth0\"
  - \"%{::operatingsystem}\"
  - common

:yaml:
   :datadir: /etc/puppet/hieradata
",
  require => File['/etc/puppet'],
}

file { '/etc/hiera.yaml':
  ensure  => 'link',
  target  => 'puppet/hiera.yaml',
  require => File['/etc/puppet/hiera.yaml'],
}

file { '/etc/puppet/hieradata':
  ensure  => 'directory',
  owner   => 'root',
  group   => 'root',
  mode    => 0755,
  require => File['/etc/puppet'],
}

file { '/etc/puppet/hieradata/networks':
  ensure  => 'directory',
  owner   => 'root',
  group   => 'root',
  mode    => 0755,
  require => File['/etc/puppet/hieradata'],
}

file { '/etc/puppet/hieradata/networks/10.0.2.0.yaml':
  owner    => 'root',
  group    => 'root',
  mode     => 0444,
  content  => '---
docker:
  registry:
    mirror: 10.0.2.3:5000
',
  require => File['/etc/puppet/hieradata/networks'],
}

file { '/etc/puppet/hieradata/networks/10.211.55.0.yaml':
  owner    => 'root',
  group    => 'root',
  mode     => 0444,
  content  => '---
docker:
  registry:
    mirror: 10.211.55.6:5000
',
  require => File['/etc/puppet/hieradata/networks'],
}

include etckeeper

# Tweak etckeeper
file_line { 'etckeeper:git':
  path    => '/etc/etckeeper/etckeeper.conf',
  line    => 'VCS="git"',
}
file_line { 'etckeeper:no-nightly-commit':
  path    => '/etc/etckeeper/etckeeper.conf',
  line    => 'AVOID_DAILY_AUTOCOMMITS=1',
  match   => '#AVOID_DAILY_AUTOCOMMITS=1',
}
# TODO: Some modules, e.g., docker do not install cleanly and confuse etckeeper
# file_line { 'etckeeper:no-auto-commit':
#   path  	=> '/etc/etckeeper/etckeeper.conf',
#   line  	=> 'AVOID_COMMIT_BEFORE_INSTALL=1',
#   match 	=> '#AVOID_COMMIT_BEFORE_INSTALL=1',
# }

exec { 'etckeeper-init-git':
  command  => 'git init',
  creates  => '/etc/.git',
  cwd      => '/etc',
  path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  require  => [
    Package['git'],
    File_line['etckeeper:no-nightly-commit'],
    File_line['etckeeper:git']
  ]
}
exec { 'etckeeper-initial-commit':
  command  => 'git commit -m "Initial commit"',
  creates  => '/etc/.git/refs/heads/master',
  cwd      => '/etc',
  path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  require  => Exec['etckeeper-init-git']
}

