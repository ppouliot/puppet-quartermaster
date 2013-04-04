# Class: quartermaster::dnsmasq
#
# This Class configures dnsmasq as a proxydhcp server
#
# Parameters: none
#
# Actions:
#

class quartermaster::dnsmasq {
  package { 'dnsmasq':
    ensure => installed,
  }

  file {'quartermaster.conf':
    ensure  => file,
    path    => '/etc/dnsmasq.d/quartermaster.conf',
    content => template('quartermaster/proxydhcp/dnsmasq.erb'),
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

  service {'dnsmasq':
    ensure  => running,
    enable  => true,
    require => [Package['dnsmasq'],File['quartermaster.conf']],
  }
}
