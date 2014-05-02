class quartermaster::puppetmaster (
  $use_puppetdb = false,
){
  if ($use_puppetdb) {
    class {'puppetdb': before => Class['puppet::master'],}
  }
  class {'puppet::master':
    autosign     => true,
    storeconfigs => $use_puppetdb,
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
