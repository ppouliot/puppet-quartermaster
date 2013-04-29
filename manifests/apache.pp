class quartermaster::apache {
 include 'apache'

  apache::vhost {'quartermaster':
    priority => '10',
    vhost_name => $ipaddress,
    port       => 80,
    docroot    => $wwwroot,
    logroot    => /var/log/quartermaster/
  }

  file {'/var/log/quartermaster':
    ensure => directory,
  }


