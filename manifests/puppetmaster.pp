class quartermaster::puppetmaster {
#  class {'puppetdb':}
  class {'puppet::master':
    autosign     => true,
#    storeconfigs => true,
    parser       => 'future',
  } 
  file  {'/etc/puppet/files':
    ensure => directory,
    require => Class['puppet::master'],
  }

  file {'/etc/puppet/fileserver.conf':
    ensure  => file,
    require => Class['puppet::master'],
    source  => "puppet:///modules/quartermaster/puppetmaster/fileserver.conf",
    notify  => Service['apache2'],
  }

}
