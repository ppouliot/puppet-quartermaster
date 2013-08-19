class quartermaster::puppetmaster {
  class {'puppetdb':}
  class {'puppet::master':
    autosign     => true,
    storeconfigs => true,
  } 
  file  {'/etc/puppet/files':
    ensure => directory,
    require => Class['puppet::master'],
  }
}
