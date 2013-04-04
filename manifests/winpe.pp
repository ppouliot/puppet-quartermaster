# Class: quartermaster::winpe
#
# This Class installs and configures services to support
# deploying Windows Unattended via Pxe.
# A Samba share is created for ISO placement.
# ISO put in that directory will be automated and exported via
# Samba and Apache
#
class quartermaster::winpe {
$os           = "${quartermaster::wwwroot}/microsoft/mount"
$windows_isos = "${quartermaster::wwwroot}/microsoft/iso"

# Samba Services for Hosing Windows Shares
  $samba = ['samba',
            'samba-client',
            'p7zip-full',
            'p7zip-rar',
            'dos2unix',
            'git',
            'git-review']

  package { $samba:
    ensure => installed,
  }

  service { 'smbd':
    ensure  => running,
    enable  => true,
    require => Package [ $samba ],
  }

  file { 'samba.conf':
    path     => '/etc/samba/smb.conf',
    notify   => Service['smbd'],
    require  => Package[ $samba ],
    content  => template('quartermaster/winpe/samba.erb'),
  }
# Autofs For Automouting Windows iso's
  package { 'autofs5':
    ensure => installed,
  }


  service { 'autofs':
    ensure  => running,
    enable  => true,
    require => Package['autofs5'],
  }

  file {'auto.master':
    ensure  => file,
    path    => '/etc/auto.master',
    owner   => 'root',
    group   => 'root',
    mode    => $quartermaster::file_mode,
    content => template('quartermaster/autofs/master.erb'),
    require => Package['autofs5'],
    notify  => Service['autofs'],
  }
  file {'auto.quartermaster':
    ensure  => file,
    path    => '/etc/auto.quartermaster',
    owner   => 'root',
    group   => 'root',
    mode    => $quartermaster::file_mode,
    content => template('quartermaster/autofs/quartermaster.erb'),
    require => Package['autofs5'],
    notify  => Service['autofs'],
  }

  file { $quartermaster::wwwroot:
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/winpe":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/winpe/bin":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/winpe/system":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/winpe/system/menu":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/iso":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
    notify  => Service['autofs'],
  }
  file { "${quartermaster::wwwroot}/microsoft/mount":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File['samba.conf']],
  }
  file { "${quartermaster::wwwroot}/microsoft/winpe/unattend":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ $samba ],File[ 'samba.conf' ]],
  }
  file {"${quartermaster::tftpboot}/winpe":
    ensure  => directory,
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::exe_mode,
    require => [File[ $quartermaster::tftpboot ], Package[ $samba ],File['samba.conf']],
  }

  file {'winpe_menu_default':
    ensure  => file,
    path    => "${quartermaster::tftpboot}/menu/winpe.menu",
    require => File["${quartermaster::tftpboot}/menu"],
    content => 'label winpe.menu
menu label Microsoft Installation Menu
kernel menu.c32
append ../winpe/winpe.menu
',
  }

  file { 'init.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/init.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/init.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'firstboot.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/firstboot.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/firstbootcmd.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'A00_init.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/A00_init.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/A00_init.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
  }
  file { 'B00_init.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/B00_init.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/B00_init.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
  }
  file { 'C00_init.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/C00_init.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/C00_init.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
  }
  file { 'D00_init.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/D00_init.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/D00_init.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
  }
}
