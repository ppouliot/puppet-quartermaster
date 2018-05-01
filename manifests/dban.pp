#Class: quartermaster::dban
#
# Installs and configures Dariq's Boot and Nuke as an
# option in the PXEBoot Menu
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
#
class quartermaster::dban {
  validate_bool( $quartermaster::dban_enable )
  validate_string( $quartermaster::dban_version )

  if $quartermaster::dban_enable == true {
    tftp::file{'dban':
      ensure => directory,
    } ->

    file{[
     "/srv/quartermaster/dban",
     "/srv/quartermaster/dban/iso",
     "/srv/quartermaster/dban/mnt",
    ]:
      ensure => directory,
    } ->

    autofs::mount{'dban':
      mount       => '/srv/quartermaster/dban/mnt',
      mapfile     => '/etc/auto.dban',
      mapcontents => [ "${quartermaster::dban_version} -fstype=iso9660,loop :/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso" ],
      options     => '--timeout=10',
      order       => 01,
    } ->
    staging::file{"dban-${quartermaster::dban_version}_i586.iso":
      source  => "http://sourceforge.net/projects/dban/files/dban/dban-${quartermaster::dban_version}/dban-${quartermaster::dban_version}_i586.iso/download",
      target  => "/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso",
      require =>  File["/srv/quartermaster/dban/iso"],
    } ->

    tftp::file {'dban/dban.bzi':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/dban.bzi",
#      require => Staging::File["dban-${quartermaster::dban_version}_i586.iso"],
    } ->
    tftp::file {'dban/warning.txt':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/warning.txt",
    } ->
    tftp::file {'dban/about.txt':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/about.txt",
    } ->
    tftp::file {'dban/quick.txt':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/quick.txt",
    } ->
    tftp::file {'dban/raid.txt':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/raid.txt",
    }
    tftp::file {'menu/dban.menu':
      source  => "/srv/quartermaster/dban/mnt/${quartermaster::dban_version}/isolinux.cfg",
    } ->
    file_line{'path_correction_dban_subdirectory':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'KERNEL ../dban/dban.bzi',
      match    => 'KERNEL dban.bzi',
      multiple => true,
    } ->
    file_line{'dban_f1_warning':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'F1 ../dban/warning.txt',
      match    => 'F1 warning.txt',
    } ->
    file_line{'dban_display_warning':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'DISPLAY ../dban/warning.txt',
      match    => 'DISPLAY warning.txt',
    } ->
    file_line{'dban_f2_about':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'F2 ../dban/about.txt',
      match    => 'F2 about.txt',
    } ->
    file_line{'dban_f3_quick':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'F3 ../dban/quick.txt',
      match    => 'F3 quick.txt',
    } ->
    file_line{'dban_f4_raid':
      ensure   => present,
      path     => '/srv/quartermaster/tftpboot/menu/dban.menu',
      line     => 'F4 ../dban/raid.txt',
      match    => 'F4 raid.txt',
    } ->

    concat::fragment{'default_dban':
      target  => "/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default",
      content => "LABEL dban-${quartermaster::dban_version}.menu
        MENU LABEL DBAN ${quartermaster::dban_version} Installation Menu
        KERNEL menu.c32
        APPEND ../dban/graphics.cfg ../menu/dban.menu
",
      order   => 02,
    }

  } else {

    warning('this is used if dban_enable = true')

  }

}
Class['quartermaster::config'] -> Class['quartermaster::dban']
