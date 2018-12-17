# == Class: quartermaster::hp_spp
#
class quartermaster::hp_spp (
    $hp_spp_iso_complete_url_location = 'ftp://ftp.hp.com/pub/softlib2/software1/cd-generic/p67859018/v108240/SPP2015040.2015_0407.5.iso',
    $hp_spp_iso_name = 'SPP2015040.2015_0407.5.iso',
) inherits quartermaster::params {
  if $quartermaster::enable_hp_spp == true {
    tftp::file{'hp_spp':
      ensure => directory,
    }
->  file{'/srv/quartermaster/HP_SPP':
      ensure => directory,
    }
->  file{'/srv/quartermaster/HP_SPP/iso':
      ensure => directory,
    }
->  staging::file{'HP_SPP_ISO':
      source  => $quartermaster::hp_spp_iso_complete_url_location,
      target  => "/srv/quartermaster/HP_SPP/iso/${hp_spp_iso_name}",
      timeout => 0,
      require =>  File['/srv/quartermaster/HP_SPP/iso'],
    }
->  concat::fragment{'pxeboot_hp_spp_default_menu':
      target  => '/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default',
      content => 'LABEL hp_spp.menu
          MENU LABEL HP Service Pack for Proliant Menu
          KERNEL menu.c32
          APPEND graphics.cfg ../menu/hp_spp.menu
  
  ',
      order   => 02,
    }
->  file{'/srv/quartermaster/tftpboot/menu/hp_spp.menu':
      ensure  => file,
      content => template('quartermaster/pxemenu/hp_spp.erb'),
    }

  } else {

    warning('this is used if ensure_hp_spp = true')

  }

}
