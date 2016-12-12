# Class: quartermaster::www
#
# This Class defines a minimal apache::vhosts
# for use with pxe provisioning
# on the quartermaster node
#

class quartermaster::www {

  include 'apache'
  apache::vhost {'quartermaster':
    priority   => '10',
    vhost_name => $::ipaddress,
    port       => 80,
    docroot    => $quartermaster::wwwroot,
    logroot    => $quartermaster::logroot,
  } ->

  file {[
    "${quartermaster::wwwroot}/bin",
    "${quartermaster::wwwroot}/kickstart",
    "${quartermaster::wwwroot}/preseed",
  ]:
    ensure => directory,
  } ->

  # Linux Provisioning Scripts

  file {'firstboot.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/firstboot",
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/firstboot.erb'),
  } ->

  file {'secondboot.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/secondboot",
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/secondboot.erb'),
  }

  file {'postinstall.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/postinstall",
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/postinstall.erb'),
  }
}
