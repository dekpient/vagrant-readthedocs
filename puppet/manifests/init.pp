# modify to your heart's content
$dir = '/opt/readthedocs'
$reset_db = false
$ssh = false
$connect_port = 7999
$connect_host = 'stash'

# not so safe to change, but you can try
$port = 8000 # hell, it MUST be this port for rtd to build stuff!!
$supervisor_port = 9001
$user = 'vagrant'
$group = 'vagrant'

# should not change
$libxml = 'libxml2-devel'
$libxslt = 'libxslt-devel'
$zlib = 'zlib-devel'
$libyaml = 'libyaml-devel'
$supervisor_service = 'supervisord'
$supervisor_config = '/etc/supervisord.conf'
$pkgs = [ 'git', 'supervisor', $libxml, $libxslt, $zlib, $libyaml, 'epel-release' ]
$venv = "$dir/venv"
$vbin = "$venv/bin/:/usr/bin/:/bin/"
$checkouts = "$dir/checkouts"
$working_dir = "$checkouts/readthedocs"

Package {
  allow_virtual => false,
}

File {
  owner => $user,
  group => $group,
}

user { $user :
  ensure => present
}

package { $pkgs :
  ensure => installed,
}

if $ssh {
  ssh_keygen { $user :
    comment => 'vagrant@readthedocs',
  } ->
  file { '/vagrant/id_rsa.pub' :
    ensure => present,
    source => "/home/$user/.ssh/id_rsa.pub",
  }

  exec { "adding $connect_host to known_hosts" :
    command => "ssh-keyscan -p $connect_port $connect_host >> ~/.ssh/known_hosts",
    user    => $user,
    group   => $group,
    path    => $vbin,
    onlyif  => 'test ! -e ~/.ssh/known_hosts',
  }
}

class { 'python' :
  version    => 'system',
  pip        => true,
  dev        => true,
  virtualenv => true,
  require    => Package['epel-release'],
} ->
exec { 'upgrade_pip' :
  command => 'pip install --upgrade pip',
  user    => 'root',
  path    => $vbin,
} ->
exec { 'upgrade_virtualenv' :
  command => 'pip install --upgrade virtualenv',
  user    => 'root',
  path    => $vbin,
}

file { [$dir, $checkouts] :
  ensure => directory,
  before => Vcsrepo['rtd'],
}

vcsrepo { 'rtd' :
  ensure   => present,
  owner    => $user,
  group    => $group,
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
  group        => $group,
  requirements => "$checkouts/requirements.txt",
  timeout      => 3600,
  require      => [
    Exec['upgrade_virtualenv'],
    Vcsrepo['rtd'], 
    Package[$libxml], 
    Package[$libxslt], 
    Package[$zlib],
    Package[$libyaml],
  ],
}

rtd::database { 'prepare' :
  dir     => $working_dir,
  user    => $user,
  path    => $vbin,
  clean   => $reset_db,
  require => Python::Virtualenv[$venv],
}

file { $supervisor_config :
  ensure  => file,
  mode    => '0644',
  owner   => 'root',
  group   => 'root',
  content => template('supervisor/supervisord.conf.erb'),
  require => [ Rtd::Database['prepare'], Package['supervisor'] ],
} ~>
service { $supervisor_service :
  ensure => running,
  enable => true,
}

# I do not deny...
Firewalld_rich_rule {
  ensure => present,
  zone   => 'public',
  action => 'accept',
}

firewalld_rich_rule { 'allow rtd access in public zone':
  port => {
    'port'     => $port,
    'protocol' => 'tcp',
  },
}

firewalld_rich_rule { 'allow supervisord access in public zone':
  port => {
    'port'     => $supervisor_port,
    'protocol' => 'tcp',
  },
}