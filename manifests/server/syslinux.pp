# Class: quartermaster::server::syslinux
#
# This Class retrieves and stages the Syslinux/Pxelinux files
# require for pxebooting
#

class quartermaster::server::syslinux (

  $tmp          = $quartermaster::params::tmp,
  $pxeroot      = $quartermaster::params::pxeroot,
  $pxecfg       = $quartermaster::params::pxecfg,
  $pxe_menu     = $quartermaster::params::pxe_menu,
  $syslinux_url = $quartermaster::params::syslinux_url,
  $syslinux_ver = $quartermaster::params::syslinux_ver,

) inherits quartermaster::params {

  # Syslinux Staging
 # staging::file { "syslinux-${syslinux_ver}.tar.xz":
  staging::deploy { "syslinux-${syslinux_ver}.tar.xz":
    source => "${syslinux_url}/syslinux-${syslinux_ver}.tar.gz"
    target  => $tmp,
  }
  # Syslinux Extraction
#  staging::extract { "syslinux-${syslinux_ver}.tar.xz":
#    target  => "${tmp}/${syslinux}",
#    creates => "${tmp}/${syslinux}",
#    require => Staging::File["syslinux-${syslinux_ver}.tar.gz"],
#  }

}
