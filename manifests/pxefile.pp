define quartermaster::pxefile (
  $arp_type = '01',
  $host_macaddress = regsubst($macaddress, '(\:)','-','G'),
){


  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  file { "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/${arp_type}-${host_macaddress}":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }

}
