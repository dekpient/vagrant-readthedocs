# https://docs.puppetlabs.com/pe/latest/quick_start_firewall.html
class effing_firewall {

  Firewall {
    before  => Class['effing_firewall::post'],
    require => Class['effing_firewall::pre'],
  }

  class { ['effing_firewall::pre', 'effing_firewall::post']: }

  class { 'firewall': }

  resources { 'firewall':
    purge => true
  }

  # resources { 'firewallchain':
  #   purge => true
  # }

}