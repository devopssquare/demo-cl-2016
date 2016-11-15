$hiera_docker = hiera('docker')
$hiera_docker_registry = $hiera_docker['registry']
$hiera_docker_registry_mirror = $hiera_docker_registry['mirror']

class { 'docker':
  manage_kernel 	=> false,
  # tcp_bind		=> 'tcp://0.0.0.0:2375',
  socket_bind		=> 'unix:///var/run/docker.sock',
  extra_parameters	=> "-D --registry-mirror=http://$hiera_docker_registry_mirror --insecure-registry $hiera_docker_registry_mirror",
}

# TODO make this dependant on the "real" virtualization (e.g., Vagrant w/ AWS has user "ubuntu" instead)
user { 'vagrant':
  ensure => present,
  groups => ['docker'],
  require => Class['docker'],
}

file {'/etc/cron.daily/docker-cleanup':
  owner   => 'root',
  group   => 'root',
  mode    => 0755,
  require => Class['docker'],
  content => '#!/bin/bash

set -u

# echo "Cleaning up exited processes"
# docker rm -v $(docker ps -a -q -f status=exited)
echo "Exited Docker containers"
echo "========================================"
docker ps -a -q -f status=exited
echo "----------------------------------------"

echo "Cleaning up dangling Docker images"
echo "========================================"
images=$(docker images -f "dangling=true" -q)
test "${images}" && docker rmi ${images}
echo "----------------------------------------"

echo "Cleaning up orphaned Docker volumes"
echo "========================================"
docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
echo "----------------------------------------"
',
}