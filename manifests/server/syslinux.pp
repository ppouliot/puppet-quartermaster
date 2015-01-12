# Class: quartermaster::server::syslinux
#
# This Class retrieves and stages the Syslinux/Pxelinux files
# require for pxebooting
#

class quartermaster::server::www (

  $pxeroot  = $quartermaster::params::pxeroot,
  $pxecfg   = $quartermaster::params::pxecfg,
  $pxe_menu = $quartermaster::params::pxe_menu,

) inherits quartermaster::params {

  include 'apache'
  apache::vhost {'quartermaster':
    priority   => '10',
    vhost_name => $::ipaddress,
    port       => 80,
    docroot    => $wwwroot,
    logroot    => $logroot,
  }

}
