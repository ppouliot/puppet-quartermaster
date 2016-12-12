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
    '/srv/quartermaster/dban',
    '/srv/quartermaster/dban/iso',
    '/srv/quartermaster/dban/mnt',
    '/srv/quartermaster/iso',
    '/srv/quartermaster/usb',
    '/srv/quartermaster/kickstart',
    '/srv/quartermaster/preseed',
    '/srv/quartermaster/tftpboot',
    '/srv/quartermaster/unattend.xml',
    '/srv/quartermaster/microsoft',
    '/srv/quartermaster/microsoft/iso',
    '/srv/quartermaster/microsoft/mnt',
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


  file { '/srv/quartermaster/bin/concatenate_files.sh':
    ensure  => present,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0777',
    content => '#!/bin/bash
# First argument ($1): directory containing the file fragments
# Second argument ($2): path to the resulting file
rm -rf $2
# Concatenate the fragments
for FRAGMENT in `ls $1`; do
     cat $1/$FRAGMENT >> $2
done
',
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

  file{'/srv/quartermaster/microsoft/winpe/system/init.cmd':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/winpe/menu/init.erb'),
  } ->
  file {'/srv/quartermaster/microsoft/winpe/system/menucheck.ps1':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/winpe/menu/menucheckps1.erb'),
  } ->
  file {'/srv/quartermaster/microsoft/winpe/system/puppet_log.ps1':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/puppet_log.ps1.erb'),
  } ->
  file {'/srv/quartermaster/microsoft/winpe/system/firstboot.cmd':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/firstbootcmd.erb'),
  } ->
  file {'/srv/quartermaster/microsoft/winpe/system/secondboot.cmd':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/secondbootcmd.erb'),
  }->
  file {'/srv/quartermaster/microsoft/winpe/system/compute.cmd':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/computecmd.erb'),
  }->
  file {'/srv/quartermaster/microsoft/winpe/system/puppetinit.cmd':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/puppetinitcmd.erb'),
  } ->
  file {'/srv/quartermaster/microsoft/winpe/system/rename.ps1':
    ensure  => file,
    mode    => '0777',
    content => template('quartermaster/scripts/rename.ps1.erb'),
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

  $quartermaster_samba_interface = $::facts['networking']['primary']
  class{'samba::server':
    workgroup      => 'quartermaster',
    server_string  => 'Samba Server Version %v',
    netbios_name   => $::hostname,
    interfaces     => "${::facts['networking']['primary']} lo",
    guest_account  => 'nobody',
    map_to_guest   => 'Bad User',
    kernel_oplocks => 'no',
    security       => 'user',
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

  # Squid Package Cache for Caching Installations Sources and Updates
  class {'squid':
    http_ports   => { '3128' => { options => '' }},
    coredump_dir => '/var/spool/squid3',
  }
  squid::acl{'Safe_ports': 
    type    => port,
    entries => [
      # http
      '80',
      # ftp
      '21',
      # https
      '443',
      # gopher
      '70',
      # wais
      '210',
      # unregistered ports
      '1025-65535',
      # http-mgmt
      '280',
      # gss-http
      '488',
      # filemaker 
      '591',
      # multiling http
      '777',
    ],
  }
  squid::http_access{'!Safe_ports':
    action => deny,
  }
  squid::acl{'SSL_ports':
    type => port,
    entries => ['443'],
  }
  squid::acl{'CONNECT':
    type => method,
    entries => ['CONNECT'],
  }
  squid::http_access{'CONNECT !SSL_ports':
    action => deny,
  }
  squid::http_access{'localhost manager':
    action => 'allow',
  }
  squid::http_access{'manager':
    action => 'deny',
  }
  squid::http_access{'all':
    action => 'deny',
  }
#  squid:::extra_config_section{'refresh_pattern':
#    order          => '60',
  squid::extra_config_section{'refresh_pattern':
    config_entries => {
      'refresh_pattern -i .*microsoft\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)'     => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern -i .*windowsupdate\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)' => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern -i .*windows\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)'       => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern ^ftp:'                                                                   => '1440	20%	10080',
      'refresh_pattern ^gopher:'                                                                => '1440	0%	1440',
      'refresh_pattern -i (/cgi-bin/|\?)'                                                       => '0	0%	0',
      'refresh_pattern (Release|Packagesi(.gz)*)$'                                              => '0	20%	2880',
      'refresh_pattern .'                                                                       => '0	20%	4230',
    },
  }

  concat {"/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default":
    owner   => $tftp_username,
    group   => $tftp_group,
    mode    => $file_mode,
  }

  concat::fragment{'default_header':
    target  => "/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default",
    content => template('quartermaster/pxemenu/header.erb'),
    order   => 01,
  }

  concat::fragment{'default_localboot':
    target  => "/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default",
    content => template('quartermaster/pxemenu/localboot.erb'),
    order   => 01,
  }


  tftp::file {'pxelinux/pxelinux.cfg/graphics.cfg':
    content =>"menu width 80
menu margin 10
menu passwordmargin 3
menu rows 12
menu tabmsgrow 18
menu cmdlinerow 18
menu endrow 24
menu passwordrow 11
",
  }

  # Syslinux Staging and Extraction
  staging::deploy { "syslinux-${syslinux_version}.tar.gz":
    source  => "${syslinux_url}/${syslinux}.tar.gz",
    target  => '/tmp',
    creates => "/tmp/${syslinux}",
  }





}

