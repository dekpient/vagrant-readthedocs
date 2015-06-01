include effing_firewall

firewall { "010 accept tcp access" :
  port     => [ 8088, 9001 ],
  proto    => tcp,
  action   => accept,
}