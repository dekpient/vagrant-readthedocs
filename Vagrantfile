# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.name = "readthedocs"
  end

  config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  # see commit d21ba953c1b1ba5f0b55e25783e038f2deaaaea1
  # config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  config.vm.hostname = "readthedocs"
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 9001, host: 9001
  config.vm.network "private_network", ip: "192.168.59.100"

  config.vm.post_up_message = "It's Up !!
    - To access Read the Docs, visit http://localhost:8000 and login with admin / b
    - To access Supervisor console, visit http://localhost:9001"

  # `vagrant plugin install vagrant-librarian-puppet`
  # OR
  # comment the following line and
  # run `librarian-puppet install` in puppet folder manually
  config.librarian_puppet.puppetfile_dir = "puppet"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "init.pp"
    puppet.module_path = ["puppet/modules", "local_modules"]
    # puppet.options = "--verbose --debug"
  end

end
