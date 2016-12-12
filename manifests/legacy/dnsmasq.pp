#== Class: quartermaster::dnsmasq
class quartermaster::dnsmasq {

  # Configured a resolv.conf for dnsmasq to use
  file { '/etc/resolv.conf.dnsmasq':
    ensure  => file,
    owner   => 'dnsmasq',
    group   => 'root',
    mode    => '0644',
    content => "#**** WARNING ****
# This File is manaaged by Puppet
search $::domain
nameserver $quartermaster::preferred_nameserver
nameserver 4.2.2.1
nameserver 4.2.2.2
",
  } ->
  
  # Install dnsmasq and configure a dns cache and 
  # proxydhcp server for nextserver and bootfile 
  # dhcp options

  # Caching Name Server
  class { 'dnsmasq':
    interface         => 'lo',
    expand_hosts      => true,
    dhcp_no_override  => true,
    domain_needed     => true,
    bogus_priv        => true,
    no_negcache       => true,
    no_hosts          => true,
    resolv_file       => '/etc/resolv.conf.dnsmasq',
    reload_resolvconf => false,
    cache_size        => '1000',
    strict_order      => false,
    restart           => true,
  }
  # Dhcp Range for PXE to Listen to
  dnsmasq::dhcp{'ProdyDHCP-PXE':
    dhcp_start   => "$::ipaddress,proxy",
    dhcp_end   => $::netmask,
    lease_time   => '',
    netmask => '',
  }
  dnsmasq::dhcpoption{'vendor_pxeclient':
    option  => 'vendor:PXEClient',
    content => '6,2b',
  }
  dnsmasq::pxe_service{'Quartermaster PXE Provisioning':
    content => 'pxelinux/pxelinux.0',
  }

  # Configure dnsmasq log rotation
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


}
    
