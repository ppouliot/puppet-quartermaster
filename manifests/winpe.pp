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

# Install WimLib
  apt::ppa {'ppa:nilarimogard/webupd8':}

  package { 'wimtools':
    ensure => latest,
    require => Apt::Ppa['ppa:nilarimogard/webupd8'],
  }


# Samba Services for Hosing Windows Shares
  $samba = ['samba',
            'samba-client',
            'p7zip-full',
            'p7zip-rar',
            'dos2unix',
            'git',
            'git-review']

  package { $samba:
    ensure => latest,
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
    ensure => latest,
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
#  file { "${quartermaster::wwwroot}/microsoft/winpe/unattend":
#    ensure  => directory,
#    owner   => 'nobody',
#    group   => 'nogroup',
#    mode    => $quartermaster::dir_mode,
#    require => [ Package[ $samba ],File[ 'samba.conf' ]],
#  }
  file {"${quartermaster::tftpboot}/winpe":
    ensure  => directory,
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::exe_mode,
    require => [File[ $quartermaster::tftpboot ], Package[ $samba ],File['samba.conf']],
  }

#  file {'winpe_menu_default':
#    ensure  => file,
#    path    => "${quartermaster::tftpboot}/menu/winpe.menu",
#    require => File["${quartermaster::tftpboot}/menu"],
#    content => 'label winpe.menu
#menu label Microsoft Installation Menu
#kernel menu.c32
#append ../winpe/winpe.menu
#',
#  }
  concat::fragment{"winpe_pxe_default_menu":
    target  => "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/default",
    content => template("quartermaster/pxemenu/winpe.erb"),
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
  file { 'menucheck.ps1':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menucheck.ps1",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/menucheckps1.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'puppet_log.ps1':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/puppet_log.ps1",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/winpe/menu/puppet_log.ps1.erb'),
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
  file { 'secondboot.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/secondboot.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/secondbootcmd.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'compute.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/compute.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/computecmd.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'puppetinit.cmd':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/puppetinit.cmd",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/puppetinitcmd.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
  file { 'rename.ps1':
    ensure  => file,
    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/rename.ps1",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/rename.ps1.erb'),
    require => File["${quartermaster::wwwroot}/microsoft/winpe/system"],
  }
#  file { 'A00_init.cmd':
#    ensure  => file,
#    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/A00_init.cmd",
#    owner   => 'nobody',
#    group   => 'nogroup',
#    mode    => $quartermaster::exe_mode,
#    content => template('quartermaster/winpe/menu/A00_init.erb'),
#    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
#  }
#  file { 'B00_init.cmd':
#    ensure  => file,
#    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/B00_init.cmd",
#    owner   => 'nobody',
#    group   => 'nogroup',
#    mode    => $quartermaster::exe_mode,
#    content => template('quartermaster/winpe/menu/B00_init.erb'),
#    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
#  }
#  file { 'C00_init.cmd':
#    ensure  => file,
#    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/C00_init.cmd",
#    owner   => 'nobody',
#    group   => 'nogroup',
#    mode    => $quartermaster::exe_mode,
#    content => template('quartermaster/winpe/menu/C00_init.erb'),
#    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
#  }
#  file { 'D00_init.cmd':
##    ensure  => file,
#    path    => "${quartermaster::wwwroot}/microsoft/winpe/system/menu/D00_init.cmd",
#    owner   => 'nobody',
#    group   => 'nogroup',
#    mode    => $quartermaster::exe_mode,
#    content => template('quartermaster/winpe/menu/D00_init.erb'),
#    require => File["${quartermaster::wwwroot}/microsoft/winpe/system/menu"],
#  }

#Begin Winpe menu
  concat { "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd":
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
  }
  concat::fragment{"winpe_system_cmd_a00_header":
    target  => "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/A00_init.erb'),
    order   => 01,
  }
  concat::fragment{"winpe_system_cmd_b00_init":
    target  => "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/B00_init.erb'),
    order   => 10,
  }
  concat::fragment{"winpe_system_cmd_c00_init":
    target  => "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/C00_init.erb'),
    order   => 20,
  }
  concat::fragment{"winpe_menu_footer":
    target  => "${quartermaster::wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/D00_init.erb'),
    order   => 99,
  }

}
