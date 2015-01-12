# Class: quartermaster::server::syslinux
#
# This Class retrieves and stages the Syslinux/Pxelinux files
# require for pxebooting
#

class quartermaster::server::www (

  $pxeroot      = $quartermaster::params::pxeroot,
  $pxecfg       = $quartermaster::params::pxecfg,
  $pxe_menu     = $quartermaster::params::pxe_menu,
  $syslinux_url = $quartermaster::params::syslinux_url,
  $syslinux_ver = $quartermaster::params::syslinux_ver,

) inherits quartermaster::params {

  # Syslinux Staging
  staging::file{ $syslinux:
    source => "${syslinux_url}/syslinux-${syslinux_ver}.tar.xz"
  }

}
