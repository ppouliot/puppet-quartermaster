class quartermaster::puppetmaster {
  class {'puppetdb':}
  class {'puppet::master':
    autosign     => true,
    storeconfigs => true,
  } 
}
