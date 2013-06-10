class quartermaster::www {
  include 'apache'
#  class {'apache':}
  apache::vhost {'quartermaster':
    priority => '10',
    vhost_name => $ipaddress,
    port       => 80,
    docroot    => $quartermaster::wwwroot,
    logroot    => '/var/log/quartermaster/',
  }

#  file {'/var/log/quartermaster':
#    ensure => directory,
#  }

}
