# Class: quartermaster::squid_deb_proxy
#
# This Class installs squid-deb-proxy and modifies the configuration
# to support other package formats
#
#

class quartermaster::squid_deb_proxy {

  $squid_deb_proxy = ['squid-deb-proxy','squid-deb-proxy-client',]
  $squid_services  = ['squid-deb-proxy','squid3',]

  package {$squid_deb_proxy: ensure => installed,}

  service { $squid_services:
    ensure  => running,
    require => Package[ $squid_deb_proxy ],
  }

  file { '/etc/squid-deb-proxy/squid-deb-proxy.conf':
    source  => 'puppet:///modules/quartermaster/squid-deb-proxy/squid-deb-proxy.conf',
    notify  => Service[ $squid_services ],
    require => Package[ $squid_deb_proxy ],
  }

  file {'/etc/squid-deb-proxy/mirror-dstdomain.acl.d/10-debian':
    source  => 'puppet:///modules/quartermaster/squid-deb-proxy/10-debian',
    notify  => Service[ $squid_services ],
    require => Package[ $squid_deb_proxy ],
  }

  file {'/etc/squid-deb-proxy/allowed-networks-src.acl.d/10-lab':
    source  => 'puppet:///modules/quartermaster/squid-deb-proxy/10-lab',
    notify  => Service[ $squid_services ],
    require => Package[ $squid_deb_proxy ],
  }

}
