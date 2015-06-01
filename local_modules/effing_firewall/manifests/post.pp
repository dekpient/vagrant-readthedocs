class effing_firewall::post {

  firewall { '999 drop all other requests':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

 }