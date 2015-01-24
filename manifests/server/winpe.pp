# Class: quartermaster::server::winpe
#
# This Class installs and configures services to support
# deploying Windows Unattended via Pxe.
# A Samba share is created for ISO placement.
# ISO put in that directory will be automated and exported via
# Samba and Apache
#
class quartermaster::server::winpe (
  $wwwroot = $quartermaster::params::wwwroot,
  $os           = "${quartermaster::wwwroot}/microsoft/mount",
  $windows_isos = "${quartermaster::wwwroot}/microsoft/iso",
) inherits params {


# Install WimLib
#  apt::ppa {'ppa:nilarimogard/webupd8':}

#  package { 'wimtools':
#    ensure => latest,
#    require => Apt::Ppa['ppa:nilarimogard/webupd8'],
#  }


# Samba Services for Hosing Windows Shares
  tftp::file{'winpe':}
  file{

  class{'::samba::server':
    $workgroup     => 'quartermaster':
    $netbios_name  => $::hostname,
    $security      => 'SHARE',
    $guest_account => 'nobody',
    extra_global_options => [
      'wide links    = yes,
      'unix extensions = no',
      'follow symlins = yes',
      'kernel oplocks = no',
    ],
    shares => {
      'installs' => [
        'comment = Installs',
        "path = ${wwwroot}",
        'read only = yes',
        'guest ok = yes',
        'fake oplocks = true',
      ],
      'os' => [
        'comment = MS Operating Systems',
        "path = ${wwwroot}/microsoft",
        'read only = yes',
        'guest ok = yes',
        'fake oplocks = true',
      ],
      'winpe' => [
        "path = ${wwwroot}/microsoft/winpe",
        'read only = no',
        'guest ok = yes',
      ],
      'system' => [
        "path = ${wwwroot}/microsoft/winpe/system",
        'read only = no',
        'guest ok = yes',
      ],
      'pxe-cfg' => [
        "path = ${tftpboot}/pxelinux/pxelinux.cfg",
        'read only = no',
        'guest ok = yes',
      ],
     'pe-pxeroot' => [
        "path = ${tftpboot}/winpe",
        'read only = no',
        'guest ok = yes',
      ],

    },


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
    content => template('quartermaster/scripts/puppet_log.ps1.erb'),
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
