# == Define: quartermaster::pxebootfile
# The file created for control of individual
# host pxe menus.
# found ususially in tftpboot/pxelinux/pxelinux.cfg/
#
#
define quartermaster::pxebootfile (
  $interface_name         = split($interfaces,","),
  $interface_macaddr      = inline_template("\$macaddress_${interface_name}"),
  $arp_type               = $quartermaster::params::arp_type,
  $default_pxeboot_option = $quartermaster::params::default_pxe_option,
  $pxe_menu_timeout       = $quartermaster::params::pxe_menu_timeout,
){


  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  case $interface_name != 'lo' {
    @file{"${tftpboot}/pxelinux/pxelinux.cfg/${arptype}-${interface_macaddr}":
      ensure => file,
    }
  }
}
