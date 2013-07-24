class quartermaster::puppetmaster {

  class {'puppet::master':
    autosign => true;
  } 
}
