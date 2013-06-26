class quartermaster::puppet {
  include 'puppet'
  class {'puppet::master':
  } 
}
