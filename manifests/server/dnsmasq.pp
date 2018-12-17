# Class quartermaster::dnsmasq
class quartermaster::server::dnsmasq {

  # A file to use for name resolution
  file { '/etc/resolv.conf.dnsmasq':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "#**** WARNING ****
# This File is manaaged by Puppet
search ${::domain}
nameserver ${quartermaster::preferred_nameserver}
nameserver 1.1.1.1
nameserver 4.2.2.2
",
  }

  # Install dnsmasq and configure a dns cache and 
  # proxydhcp server for nextserver and bootfile 
  # dhcp options
  class {'dnsmasq':
    configs_hash     => {
      'quartermaster-cfg' => {
        content => template('quartermaster/dnsmasq.conf.erb'),
      },
    },
    purge_config_dir => true,
  }

  # DNSMasq Logging
  #
  file {'/etc/logrotate.d/dnsmasq':
    ensure  => file,
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
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
  }

  # dnsmasq default
  file_line{'etc_default_dnsmasq_DNSMASQ_EXCEPT_lo':
    ensure => present,
    path   => '/etc/default/dnsmasq',
    line   => 'DNSMASQ_EXCEPT=lo',
    notify => Service['dnsmasq'],
  }
}
