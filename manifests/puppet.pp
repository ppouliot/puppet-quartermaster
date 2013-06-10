class quartermaster::puppet {
include 'puppet'

class {'puppet::master':
  puppet_server    => @fqdn,
  puppet_passenger => "true",
} 
