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
  $syslinux     = $quartermaster::params::syslinux,
  $syslinux_url = $quartermaster::params::syslinux_url,
  $syslinux_ver = $quartermaster::params::syslinux_ver,

) inherits quartermaster::params {

  # Syslinux Staging and Extraction
  staging::deploy { "${syslinux}.tar.gz":
    source => "${syslinux_url}/${syslinux}.tar.gz",
    target  => $tmp,
    creates => "${tmp}/${syslinux}",
  }
  Tftp::File{
    owner   => 'tftp',
    group   => 'tftp',
    require => [
      Staging::Deploy["${syslinux}.tar.gz"],
      Tftp::File['pxelinux']
    ],
  }

  tftp::file {'pxelinux/pxelinux.0':
    source  => "${tmp}/${syslinux}/core/pxelinux.0",
  }

  tftp::file { 'pxelinux/gpxelinux0':
    source  => "${tmp}/${syslinux}/gpxe/gpxelinux.0",
  }

  tftp::file { 'pxelinux/isolinux.bin':
    source  => "${tmp}/${syslinux}/core/isolinux.bin",
  }

  tftp::file { 'pxelinux/menu_c32':
    source  => "${tmp}/${syslinux}/com32/menu/menu.c32",
  }

  tftp::file { 'pxelinux/ldlinux_c32':
    source  => "${tmp}/${syslinux}/com32/elflink/ldlinux/ldlinux.c32",
  }

}
