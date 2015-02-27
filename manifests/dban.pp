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
class quartermaster::dban(

  $dban_version   = '2.2.8',
  $dban_url       = "http://sourceforge.net/projects/dban/files/dban/dban-${dban_version}/dban-${dban_version}_i586.iso/download",
  $tmp            = $quartermaster::params::tmp,
  $pxeroot        = $quartermaster::params::pxeroot,
  $pxecfg         = $quartermaster::params::pxecfg,
  $pxe_menu       = $quartermaster::params::pxe_menu,
  $tftpboot       = $quartermaster::params::tftpboot,
  $tftp_username  = $quartermaster::params::tftp_username,
  $tftp_group     = $quartermaster::params::tftp_group,
  $tftp_filemode  = $quartermaster::params::tftp_filemode,
  $wwwroot        = $quartermaster::params::wwwroot,
  $www_username   = $quartermaster::params::www_username,
  $www_group      = $quartermaster::params::www_group,
  $file_mode      = $quartermaster::params::file_mode,


)inherits quartermaster::params {

  tftp::file{'dban':
    ensure => directory, 
  }

  file{["${wwwroot}/dban",
        "${wwwroot}/dban/iso",
        "${wwwroot}/dban/mnt"]:
    ensure => directory,
  }

  autofs::mount{ "dban-${dban_version}_i586.iso":
    map     => ":${wwwroot}/dban/iso/&",
    options => [
      '-fstype=iso9660,loop',
    ],
    mapfile => '/etc/auto.dban',
  }

  staging::file{'DBAN_ISO':
    source => $dban_url,
    target => "${wwwroot}/dban/iso/dban-${dban_version}/dban-${dban_version}_i586.iso",
    require =>  File["${wwwroot}/dban/iso"],
  }

}
