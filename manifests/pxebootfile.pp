# == Define: quartermaster::pxebootfile
# The file created for control of individual
# host pxe menus.
# found ususially in tftpboot/pxelinux/pxelinux.cfg/
#
#
define quartermaster::pxebootfile (
  $interface_name         = split($::interfaces,','),
  $interface_macaddr      = inline_template("\$macaddress_${interface_name}"),
  $arp_type               = '01',
  $default_pxeboot_option = 'menu.c32',
  $pxe_menu_timeout       = '10',
){

  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  case $interface_name != 'lo' {
    @file{"/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/${::arptype}-${::interface_macaddr}":
      ensure => file,
    }
  }
}
