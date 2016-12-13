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

  if $dban_enable == true {

    tftp::file{'dban':
      ensure => directory,
    }

    file{[
     "/srv/quartermaster/dban",
     "/srv/quartermaster/dban/iso",
     "/srv/quartermaster/dban/mnt",
    ]:
      ensure => directory,
    }

    autofs::mount{'/srv/quartermaster/dban/mnt':
      mapfile     => '/etc/auto.quartermaster_dban',
      mapcontents => [ "-fstype=iso9660,loop :/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso" ],
      options     => '--timeout=10',
      order       => '01',
    }

    staging::file{"dban-${quartermaster::dban_version}_i586.iso":
      source  => "http://sourceforge.net/projects/dban/files/dban/dban-${quartermaster::dban_version}/dban-${quartermaster::dban_version}_i586.iso/download",
      target  => "/srv/quartermaster/dban/iso/dban-${quartermaster::dban_version}_i586.iso",
      require =>  File["/srv/quartermaster/dban/iso"],
    }

  } else {

    warning('this is used if ensure_dban = true')

  }

}
