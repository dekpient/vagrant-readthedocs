# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  config.vm.network "forwarded_port", guest: 8088, host: 8088
  config.vm.network "forwarded_port", guest: 9001, host: 9001

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
