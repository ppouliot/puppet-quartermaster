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

  $quartermaster::dban_version   = '2.2.8',

)inherits quartermaster::params {

  tftp::file{'dban':
    ensure => directory,
  }

  file{["/srv/quartermaster/dban",
        "/srv/quartermaster/dban/iso",
        "/srv/quartermaster/dban/mnt"]:
    ensure => directory,
  }

  autofs::mount{ "/srv/quartermaster/dban/mnt":
    map     => ":/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso",
    options => [
      '-fstype=iso9660,loop',
    ],
  }

  staging::file{'DBAN_ISO':
    source  => "http://sourceforge.net/projects/dban/files/dban/dban-${quartermaster::dban_version}/dban-${quartermaster::dban_version}_i586.iso/download",
    target  => "/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso",
    require =>  File["/srv/quartermaster/dban/iso"],
  }

}
