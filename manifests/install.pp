#== Class: quartermaster::install
class quartermaster::install {

  include ::stdlib
  # NGINX Installation
  include ::nginx
  nginx::resource::vhost{ $fqdn:
    ensure               => present,
    www_root             => '/srv/quartermaster',
    use_default_location => false,
    vhost_cfg_append     => {
      autoindex => on,
    }
  }
  nginx::resource::location{'/':
    ensure => present,
    www_root => '/srv/quartermaster',
    vhost    => $fqdn,
  } 
  nginx::resource::location{"$fqdn-tftpboot":
    ensure    => present,
    autoindex => 'on',
    www_root  => '/var/lib/tftpboot',
    vhost     => $fqdn,
    require   => Class['tftp'],
  } 

  # Define dictory structure on the filestem for default locations of bits.

  file{[
    '/srv/quartermaster',
    '/srv/quartermaster/bin',
    '/srv/quartermaster/iso',
    '/srv/quartermaster/kickstart',
    '/srv/quartermaster/preseed',
    '/srv/quartermaster/tftpboot',
    '/srv/quartermaster/unattend.xml',
    '/srv/quartermaster/microsoft',
    '/srv/quartermaster/microsoft/iso',
    '/srv/quartermaster/microsoft/mount',
    '/srv/quartermaster/microsoft/winpe',
    '/srv/quartermaster/microsoft/winpe/bin',
    '/srv/quartermaster/microsoft/winpe/system',
    '/srv/quartermaster/microsoft/winpe/system/menu',
  ]:
    ensure  => directory,
    mode    => '0777',
    owner   => 'nginx',
    group   => 'nginx',
    recurse => true,
  } ->

  # Firstboot Script
  # This is script is added to the ubuntu/debian hosts via
  # the postinstall script. It will install configuration management
  # packages, the secondboot script, sets hostname and additional 
  # startup config then reboots.

  file {'/srv/quartermaster/bin/firstboot':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/firstboot.erb'),
  } ->

  # Secondboot Script
  # Executes configuration managment ( Puppet Currently )
  file {'/srv/quartermaster/bin/secondboot':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/secondboot.erb'),
  } ->

  # Postinstall Script
  # Installs the firstboot script and reboots the system
  file {'/srv/quartermaster/bin/postinstall':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/postinstall.erb'),
  }
    

  # Configured a resolv.conf for dnsmasq to use
  file { '/etc/resolv.conf.dnsmasq':
    ensure  => file,
    owner   => 'dnsmasq',
    group   => 'root',
    mode    => '0644',
    content => "#**** WARNING ****
# This File is manaaged by Puppet
search $::domain
# nameserver $quartermaster::preferred_nameserver
nameserver 10.21.7.1
nameserver 4.2.2.1
nameserver 4.2.2.2
",
  } ->
  
  # Install dnsmasq and configure a dns cache and 
  # proxydhcp server for nextserver and bootfile 
  # dhcp options

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
  dnsmasq::dhcp{'ProdyDHCP-PXE':
    dhcp_start => "$::ipaddress,proxy",
    dhcp_end   => $::netmask,
    lease_time => '',
    netmask    => '',
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

  ## TFTP Server Configuration

  # Create the tftp remap file to allow us to boot
  # Windows and linux installs

  file { '/etc/tftpd.rules':
    content  => template('quartermaster/tftp-remap.erb'),
  } ->

  # Tftp Server Install/Configuration
  class{ 'tftp':
    directory => '/srv/quartermaster/tftpboot',
    inetd     => false,
    options   => '-vvvvs -c -m /etc/tftpd.rules',
  }

  # additional tftp directories
  tftp::file {[
    'menu',
    'network_devices',
    'pxelinux',
    'pxelinux/pxelinux.cfg',
    'winpe',
  ]:
    ensure  => directory,
    mode    => '0777',
  }

  class{'samba::server':
    workgroup => 'quartermaster',
    server_string => "Quartermaster($::ipaddress): Purveyor of Provisions & Tooling",
    interfaces    => $::primary,
    security      => 'share',
  }
  samba::server::share{'IPC$':
    comment       => 'Fake IPC',
    path          => '/etc/samba/fakeIPC',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => true,
  }

  samba::server::share{'installs':
    comment       => 'Installation Bits and Bytes for all platforms',
    path          => '/srv/quartermaster',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => true,
  }
  samba::server::share{'os':
    comment       => 'Microsoft Operating System Platforms',
    path          => '/srv/quartermaster/microsoft',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => true,
  }
  samba::server::share{'ISO':
    comment       => 'Microsoft Operating System Platforms',
    path          => '/srv/quartermaster/microsoft/iso',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => false,
  }
  samba::server::share{'winpe':
    comment       => 'WinPE',
    path          => '/srv/quartermaster/microsoft/iso',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => false,
  }
  samba::server::share{'system':
    comment       => 'WinPE Installation System Scripts',
    path          => '/srv/quartermaster/microsoft/winpe/system',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => false,
  }
  samba::server::share{'pxe-cfg':
    comment       => 'Pxe Configuration Files',
    path          => '/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => false,
  }
  samba::server::share{'pe-pxeroot':
    comment       => 'WinPE PXEBoot Files',
    path          => '/srv/quartermaster/tftpboot/winpe',
    guest_ok      => true,
    guest_account => 'nobody',
    read_only     => false,
  }
}
