# Class: quartermaster::syslinux
#
# This Class downloads syslinux and installs
# the necessary files to support pxebooting
#
#
class quartermaster::syslinux {
  $pxeroot       = "${quartermaster::tftpboot}/pxelinux"
  $pxecfg        = "${pxeroot}/pxelinux.cfg"
  $pxe_menu      = "${quartermaster::tftpboot}/menu"
  #$syslinux_url  = 'http://mirrors.med.harvard.edu/linux/utils/boot/syslinux'
  $syslinux_url = 'http://www.kernel.org/pub/linux/utils/boot/syslinux'
  #$syslinux_ver = '4.05'
  #$syslinux_ver  = '5.01'
  $syslinux_ver  = '5.10'
# Broken 
#  $syslinux_ver  = '6.01'
  $syslinux      = "syslinux-${syslinux_ver}"
  $syslinuxroot  = "${quartermaster::tmp}/${syslinux}"

  exec { 'get_syslinux':
    command => "/usr/bin/wget -cv ${syslinux_url}/syslinux-${syslinux_ver}.tar.xz -O - | tar xJf -",
    cwd     => $quartermaster::tmp,
    creates => $syslinuxroot,
  }


  file { 'pxelinux0':
    ensure  => file,
    path    => "${pxeroot}/pxelinux.0",
    source  => "${syslinuxroot}/core/pxelinux.0",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'gpxelinux0':
    ensure  => file,
    path    => "${pxeroot}/gpxelinux.0",
    source  => "${syslinuxroot}/gpxe/gpxelinux.0",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'isolinux':
    ensure  => file,
    path    => "${pxeroot}/isolinux.bin",
    source  => "${syslinuxroot}/core/isolinux.bin",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[$quartermaster::tftpboot], Exec['get_syslinux']],
  }

  file { 'menu_c32':
    ensure  => file,
    path    => "${pxeroot}/menu.c32",
    source  => "${syslinuxroot}/com32/menu/menu.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'ldlinux_c32':
    ensure  => file,
    path    => "${pxeroot}/ldlinux.c32",
    source  => "${syslinuxroot}/com32/elflink/ldlinux/ldlinux.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'libutil_c32':
    ensure  => file,
    path    => "${pxeroot}/libutil.c32",
    source  => "${syslinuxroot}/com32/libutil/libutil.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'vesamenu':
    ensure  => file,
    path    => "${pxeroot}/vesamenu.c32",
    source  => "${syslinuxroot}/com32/menu/vesamenu.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'gfxboot':
    ensure  => file,
    path    => "${pxeroot}/gfxboot.c32",
    source  => "${syslinuxroot}/com32/gfxboot/gfxboot.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'mboot_c32':
    ensure  => file,
    path    => "${pxeroot}/mboot.c32",
    source  => "${syslinuxroot}/com32/mboot/mboot.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'chain_c32':
    ensure  => file,
    path    => "${pxeroot}/chain.c32",
    source  => "${syslinuxroot}/com32/chain/chain.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file { 'libcom32_c32':
    ensure  => file,
    path    => "${pxeroot}/libcom32.c32",
    source  => "${syslinuxroot}/com32/lib/libcom32.c32",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
  }

  file {'localboot.menu':
    ensure  => file,
    path    => "${quartermaster::tftpboot}/menu/00_localboot.menu",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
    content => 'default menu.c32
prompt 0
MENU TITLE Quartermaster PXE System
MENU INCLUDE graphics.cfg
MENU AUTOBOOT Starting Local System in # seconds

LABEL localboot
        MENU LABEL ^Boot local system
        MENU DEFAULT
        COM32 chain.c32
        APPEND hd0
        TIMEOUT 80
        TOTALTIMEOUT 600
',
  }
concat {"${pxecfg}/default.new":
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
}

concat::fragment{"default_header":
    target  => "${pxecfg}/default.new",
    content => template("quartermaster/pxemenu/header.erb"),
    order   => 01,
}


  file {'graphics_cfg':
    ensure  => file,
    path    => "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/graphics.cfg",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::file_mode,
    require => [ File[ $quartermaster::tftpboot ], Exec['get_syslinux']],
    content =>"menu width 80
menu margin 10
menu passwordmargin 3
menu rows 12
menu tabmsgrow 18
menu cmdlinerow 18
menu endrow 24
menu passwordrow 11
",
  }
}
