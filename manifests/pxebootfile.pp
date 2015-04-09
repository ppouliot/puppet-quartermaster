# == Define: quartermaster::pxebootfile
# The file created for control of individual
# host pxe menus.
# found ususially in tftpboot/pxelinux/pxelinux.cfg/
#
#
define quartermaster::pxebootfile (
  $arp_type               = $quartermaster::params::arp_type,
  $host_macaddress        = $quartermaster::params::host_macaddress,
  $default_pxeboot_option = $quartermaster::params::default_pxe_option,
  $pxe_menu_timeout       = $quartermaster::params::pxe_menu_timeout,
){


  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  $bootfile = ${arp_type}-${host_macaddress}"

case $interfaces != 'lo'{

  @@file{"${tftpboot}/pxelinux/pxelinux.cfg/${bootfile}":
    ensure = file,
  }
}
}
