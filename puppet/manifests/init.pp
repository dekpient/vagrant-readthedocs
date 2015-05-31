$pkgs = [ 'git', 'libxml2-devel', 'libxslt-devel', 'epel-release' ]
$user = 'vagrant'
$group = 'vagrant'
$dir = '/opt/readthedocs'
$venv = "$dir/venv"
$vbin = "$venv/bin/:/usr/bin/"
$supervisord = "$dir/supervisord.conf"
$checkouts = "$dir/checkouts"
$working_dir = "$checkouts/readthedocs"
$port = 8088
$supervisor_port = 9001

Package {
  allow_virtual => false
}

File {
  owner => $user,
  group => $group
}

user { $user :
  ensure => present
}

package { $pkgs :
  ensure        => installed,
}

ssh_keygen { $user :
  comment => 'vagrant@readthedocs',
} ->
file { '/vagrant/id_rsa.pub' :
  ensure => present,
  source => "/home/$user/.ssh/id_rsa.pub",
}

class { 'python' :
  version    => 'system',
  pip        => true,
  dev        => true,
  virtualenv => true,
  # for python-pip
  require    => Package['epel-release'],
}

file { [$dir, $checkouts] :
  ensure => directory,
  before => [ Vcsrepo['rtd'], File[$supervisord] ],
}

file { $supervisord :
  ensure  => file,
  content => template('supervisor/supervisord.conf.erb'),
}

vcsrepo { 'rtd' :
  ensure   => present,
  owner    => $user,
  path     => $checkouts,
  provider => git,
  source   => 'https://github.com/rtfd/readthedocs.org.git',
  require  => Package['git'],
}

file { "$working_dir/settings/local_settings.py" :
  ensure  => present,
  content => 'ALLOW_PRIVATE_REPOS = True',
  require => Vcsrepo['rtd'],
}

python::virtualenv { $venv :
  owner        => $user,
  requirements => "$checkouts/requirements.txt",
  require      => [ Vcsrepo['rtd'], Package['libxml2-devel'], Package['libxslt-devel'] ],
}

python::pip { 'supervisor' :
  pkgname    => 'supervisor',
  owner      => $user,
  virtualenv => $venv,
  require    => Python::Virtualenv[$venv],
}

rtd::setup { 'prepare' :
  dir     => $working_dir,
  user    => $user,
  path    => $vbin,
  require => Python::Virtualenv[$venv],
}

# https://forge.puppetlabs.com/ajcrowe/supervisord
exec { 'runserver' :
  user    => $user,
  path    => $vbin,
  command => "supervisord -c $supervisord",
  require => [ Rtd::Setup['prepare'], File[$supervisord], Python::Pip['supervisor'] ],
}

# OR
# sudo firewall-cmd --zone=public --add-port=8088/tcp --permanent
# sudo firewall-cmd --reload
firewall { "010 accept tcp access" :
  port     => [ $port, $supervisor_port ],
  proto    => tcp,
  action   => accept,
}