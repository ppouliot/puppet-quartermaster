# Class: quartermaster::server::www
#
# This Class defines a minimal apache::vhosts 
# for use with pxe provisioning
# on the quartermaster node
#

class quartermaster::server::www (

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

}
