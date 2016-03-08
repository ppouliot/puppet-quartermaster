# == Define: quartermaster::pxebootfile
# The file created for control of individual
# host pxe menus.
# found ususially in tftpboot/pxelinux/pxelinux.cfg/
#
#
define quartermaster::pxe::bootfile (

  $arp_type               = $quartermaster::params::arp_type,
  $host_macaddress        = $quartermaster::params::host_macaddress,
  $default_pxeboot_option = $quartermaster::params::default_pxe_option
) {
  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  concat{

  }
  file { "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/${arp_type}-${host_macaddress}":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    content => template('quartermaster/pxefile.erb')
    #require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }

}
