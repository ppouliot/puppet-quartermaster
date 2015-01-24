# Class: quartermaster::winpe
#
# This Class installs and configures services to support
# deploying Windows Unattended via Pxe.
# A Samba share is created for ISO placement.
# ISO put in that directory will be automated and exported via
# Samba and Apache
#
class quartermaster::winpe (
  $wwwroot  = $quartermaster::params::wwwroot,
  $tftpboot = $quartermaster::params::tftpboot,
  $dir_mode = $quartermaster::params::dir_mode,
  $exe_mode = $quartermaster::params::exe_mode,
  $tftp_username  = $quartermaster::params::tftp_username,
  $tftp_group     = $quartermaster::params::tftp_group,
  $www_username  = $quartermaster::params::www_username,
  $www_group     = $quartermaster::params::www_group,


  $os           = "${wwwroot}/microsoft/mount",
  $windows_isos = "${wwwroot}/microsoft/iso",

) inherits params {


# Install WimLib
  case $osfamily {

    'Debian':{
      apt::ppa{'ppa:nilarimogard/webupd8':}
      $wimtool_repo = Apt::Ppa['ppa:nilarimogard/webupd8'] 
    }

    'RedHat':{
      yumrepo{'nux-misc':
        name     => 'Nux Misc',
        baseurl  => 'http://li.nux.ro/download/nux/misc/el6/x86_64/',
        enabled  => '0',
        gpgcheck => '1',
        gpgkey   => 'http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro',
      }
      $wimtool_repo = Yumrepo['nux-misc']
    }

    default:{
      warn('Currently Unsupported OSFamily for this feature')
    }
  }

  package { 'wimtools':
    ensure  => latest,
    require => $wimtool_repo,
  }


# Samba Services for Hosing Windows Shares

  tftp::file{'winpe':
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
  }

  file{[
    "${wwwroot}/microsoft",
    "${wwwroot}/microsoft/iso",
    "${wwwroot}/microsoft/mount",
    "${wwwroot}/microsoft/winpe",
    "${wwwroot}/microsoft/winpe/bin",
    "${wwwroot}/microsoft/winpe/system",
    "${wwwroot}/microsoft/winpe/system/menu",
    ]:
    ensure => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $dir_mode,

  }

  class{'::samba::server':
    workgroup            => 'quartermaster',
    netbios_name         => "${::hostname}",
    security             => 'SHARE',
    guest_account        => 'nobody',
    extra_global_options => [
      'wide links    = yes',
      'unix extensions = no',
      'follow symlins = yes',
      'kernel oplocks = no',
    ],
    shares => {
      'installs' => [
        "path = ${wwwroot}",
        'read only = yes',
        'guest ok = yes',
        'fake oplocks = true',
      ],
      'os' => [
        "path = ${wwwroot}/microsoft",
        'read only = yes',
        'guest ok = yes',
        'fake oplocks = true',
      ],
      'ISO' => [
        "path = ${wwwroot}/microsoft/iso",
        'read only = no',
        'guest ok = yes',
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
  autofs::mount{ "${wwwroot}/microsoft/iso":
    map => '*',
    options => [
      '-fstype=udf,loop',
      '-fstype=iso9660,loop', 
    ],
  }

  # Add Winpe to the PXE menu

  concat::fragment{"winpe_pxe_default_menu":
    target  => "${tftpboot}/pxelinux/pxelinux.cfg/default",
    content => template("quartermaster/pxemenu/winpe.erb"),
    require => Tftp::File['pxelinux/pxelinux.cfg']
  }

  # Begin Windows provisioning Scripts

  file { "${wwwroot}/microsoft/winpe/system/init.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/winpe/menu/init.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/menucheck.ps1":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/winpe/menu/menucheckps1.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/puppet_log.ps1":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/scripts/puppet_log.ps1.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/firstboot.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/scripts/firstbootcmd.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/secondboot.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/scripts/secondbootcmd.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/compute.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/scripts/computecmd.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/puppetinit.cmd":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $exe_mode,
    content => template('quartermaster/scripts/puppetinitcmd.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }
  file { "${wwwroot}/microsoft/winpe/system/rename.ps1":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    content => template('quartermaster/scripts/rename.ps1.erb'),
    require => File["${wwwroot}/microsoft/winpe/system"],
  }

#Begin Winpe menu
  concat { "${wwwroot}/microsoft/winpe/system/setup.cmd":
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
  }
  concat::fragment{"winpe_system_cmd_a00_header":
    target  => "${wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/A00_init.erb'),
    order   => 01,
  }
  concat::fragment{"winpe_system_cmd_b00_init":
    target  => "${wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/B00_init.erb'),
    order   => 10,
  }
  concat::fragment{"winpe_system_cmd_c00_init":
    target  => "${wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/C00_init.erb'),
    order   => 20,
  }
  concat::fragment{"winpe_menu_footer":
    target  => "${wwwroot}/microsoft/winpe/system/setup.cmd",
    content => template('quartermaster/winpe/menu/D00_init.erb'),
    order   => 99,
  }

}
