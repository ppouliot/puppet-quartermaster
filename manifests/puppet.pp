class quartermaster::puppet {
#include 'puppet'

  class {'passenger':
    passenger_version => '3.0.19',
    passenger_provider => 'apt',
  }

  class {'puppet::master':
    puppet_passenger => "true",
  } 
}
