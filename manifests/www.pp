# Class: quartermaster::www
#
# This Class defines a minimal apache::vhosts 
# for use with pxe provisioning
# on the quartermaster node
#

class quartermaster::www (

  $wwwroot = $quartermaster::params::wwwroot,
  $logroot = $quartermaster::params::logroot,

) inherits quartermaster::params {

  include 'apache'
  apache::vhost {'quartermaster':
    priority   => '10',
    vhost_name => $::ipaddress,
    port       => 80,
    docroot    => $wwwroot,
    logroot    => $logroot,
  }

  file {[
   "${wwwroot}/bin",
   "${wwwroot}/kickstart",
   "${wwwroot}/preseed",
  ]:
    ensure => directory,
  }

  # Linux Provisioning Scripts

  file {'firstboot.sh':
    ensure   => present,
    path     => "${wwwroot}/bin/firstboot",
    mode     => $exe_mode,
    content  => template('quartermaster/scripts/firstboot.erb'),
  }

  file {'secondboot.sh':
    ensure   => present,
    path     => "${wwwroot}/bin/secondboot",
    mode     => $exe_mode,
    content  => template('quartermaster/scripts/secondboot.erb'),
  }

  file {'postinstall.sh':
    ensure   => present,
    path     => "${wwwroot}/bin/postinstall",
    mode     => $exe_mode,
    content  => template('quartermaster/scripts/postinstall.erb'),
  }


}
