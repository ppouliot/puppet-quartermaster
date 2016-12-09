# Class: quartermaster::proxydhcp
#
# This Class configures dnsmasq as a proxydhcp server
#
# Parameters: none
#
# Actions:
#

# Install DNSMasq and configure as a proxydhcp server
class quartermaster::proxydhcp {

# Install DNSMasq Package
  package { 'dnsmasq':
    ensure => latest,
  }

# Configure DNSMasq as ProxyDHCP

  file {'quartermaster.conf':
    ensure  => file,
    path    => '/etc/dnsmasq.d/quartermaster.conf',
    content => template('quartermaster/dnsmasq.erb'),
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

  file {'/etc/logrotate.d/dnsmasq':
    ensure  => file,
    content => '/var/log/dnsmasq.log {
    monthly
    missingok
    notifempty
    delaycompress
    sharedscripts
    postrotate
        [ ! -f /var/run/dnsmasq.pid ] || kill -USR2 `cat /var/run/dnsmasq.pid`
    endscript
    create 0640 dnsmasq dnsmasq
}',
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

  service {'dnsmasq':
    ensure  => running,
    enable  => true,
    require => [Package['dnsmasq'],File['quartermaster.conf']],
  }

}
