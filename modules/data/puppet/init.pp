# # If we run in vagrant, create /vagrant/data and /data as link to it
# exec { '/vagrant/data':
#   command	=>	'mkdir /vagrant/data',
#   creates	=>	'/vagrant/data',
#   onlyif	=>	'/usr/bin/test -d /vagrant',
#   cwd		=>	'/etc',
#   path		=>	'/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
# }
# exec { '/vagrant/data-link':
#   command	=>	'ln -s vagrant/data /data',
#   creates	=>	'/data',
#   onlyif	=>	'/usr/bin/test -d /vagrant',
#   cwd		=>	'/etc',
#   path		=>	'/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
# }
# # Otherwise create /data only
# exec { '/data':
#   command	=>	'mkdir /data',
#   creates	=>	'/data',
#   unless	=>	'/usr/bin/test -s /data',
#   cwd		=>	'/etc',
#   path		=>	'/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
# }
file { '/data':
  path		=>	'/data',
  ensure	=>	directory,
  owner		=>	root,
  group		=>	root,
  mode		=>	0755,
}
