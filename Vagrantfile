# -*- mode: ruby -*-
# vi: set ft=ruby :

composite = ENV['VAGRANT_COMPOSITE'] || "minimal"

name = ENV['VAGRANT_NAME'] || "devopssquare-cl-2016"
# Memory settings for "minimal" environment
memory = ENV['VAGRANT_MEMORY'] || 2048
ip_unique = ENV['VAGRANT_IP_UNIQUE'] || "48"
port_unique = ENV['VAGRANT_PORT_UNIQUE'] || "48"
box = ENV['VAGRANT_BOX'] || "bento/ubuntu-16.04"

Vagrant.configure("2") do |boxname|
  # Generic/Defaults
  boxname.vm.box = box
  boxname.vm.hostname = name
  # Mount-Sync this explicitely - otherwise some boxes will only rsync the folder
  boxname.vm.synced_folder ".", "/vagrant"
  boxname.vm.synced_folder "cache/apt-archives", "/var/cache/apt/archives"

  boxname.vm.provider "virtualbox" do |vbox, override|
    vbox.name = name
    vbox.memory = memory
    # Cf. https://github.com/chef/bento/issues/682 for bento/ubuntu 2.3.x boxes
    vbox.customize ["modifyvm", :id, "--cableconnected1", "on"]
    # override.vm.network "private_network", ip: "192.168.50.#{ip_unique}", virtualbox__intnet: true
    # Docker
    # override.vm.network "forwarded_port", guest: 2375, host: 42375
    # Docker Registry
    override.vm.network "forwarded_port", guest: 5000, host: "#{port_unique}050"
    # Docker Registry UI - beware of conflicts with Jenkins!
    override.vm.network "forwarded_port", guest: 8055, host: "#{port_unique}055"
    # Jenkins
    override.vm.network "forwarded_port", guest: 8080, host: "#{port_unique}080"
    # Nexus
    override.vm.network "forwarded_port", guest: 8081, host: "#{port_unique}081"
    # SCM-Manager
    override.vm.network "forwarded_port", guest: 8082, host: "#{port_unique}082"
    # SonarQube
    override.vm.network "forwarded_port", guest: 9000, host: "#{port_unique}090"
  end

  boxname.vm.provider "libvirt" do |domain|
    prefix = name[name.index('-')+1..-1]
    domain.default_prefix = prefix
    domain.memory = memory
    domain.graphics_autoport = "no"
    domain.graphics_port = "59#{port_unique}"
  end

  # ATTENTIION: Current module structure does not work with Parallels provider
  # boxname.vm.provider "parallels" do |parallels, override|
  #   override.vm.box = "parallels/ubuntu-14.04"
  #   parallels.name = name
  #   parallels.memory = memory
  #   override.vm.network "private_network", ip: "10.211.55.#{ip_unique}", virtualbox__intnet: true
  # end

  boxname.vm.provider "aws" do |aws, override|
    # Add dummy box using
    # vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
    override.vm.box = "dummy"
    # https://console.aws.amazon.com/iam/home#users
    # User must be assigned permissions to work with ec2.
    # This can be achieved by assigning the AmazonEC2FullAccess policy to the user.
    aws.access_key_id = ENV['AWS_ACCESS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    # https://console.aws.amazon.com/ec2/v2/home#KeyPairs
    # Please note that keypairs are region specific
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']

    aws.region = "eu-central-1"
    aws.instance_type = "t2.micro"

    # Ensure that the configured security groups allow connections to port 22
    # to allow vagrant provisioning over SSH.
    # https://console.aws.amazon.com/ec2/v2/home#SecurityGroups
    aws.security_groups = ['default']

    # Overview of Ubuntu AMIs
    # http://cloud-images.ubuntu.com/locator/ec2/
    aws.ami = "ami-ffaab693"

    override.ssh.username = "ubuntu"
    # Path to the private key file of the keypair defined in aws.keypair_name.
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']

    # Cf. https://github.com/mitchellh/vagrant-aws/issues/331
    override.nfs.functional = false
    override.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: "cache"
    override.vm.synced_folder "cache/apt-archives", "/var/cache/apt/archives", type: "rsync", rsync__exclude: "*.deb"
  end

  boxname.vm.provision "shell", path: "composites/scripts/run.sh", args: composite

end
