class quartermaster::puppetmaster {

  include 'puppet::master'
  include 'puppetdb'
  include 'puppetdb::master::config'

  class {'puppet::master':} 
}
