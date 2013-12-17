class quartermaster::params {
  $arp_type = '01',
  $host_macaddress = regsubst($macaddress, '(\:)','-','G'),
  $default_pxeboot_option = 'menu.c32'

}
