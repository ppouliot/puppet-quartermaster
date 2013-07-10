class quartermaster::puppetmaster {

  include 'puppet'
  include 'puppetdb'
  include 'puppetdb::master::config'

  class {'puppet::master':} 
}
