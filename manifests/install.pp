#== Class: quartermaster::install
class quartermaster::install (
  $default_pxeboot_option        = $quartermaster::default_pxeboot_option,
  $pxe_menu_timeout              = $quartermaster::pxe_menu_timeout,
  $pxe_menu_total_timeout        = $quartermaster::pxe_menu_total_timeout,
  $pxe_menu_allow_user_arguments = $quartermaster::pxe_menu_allow_user_arguments,
  $pxe_menu_default_graphics     = $quartermaster::pxe_menu_default_graphics,
  $puppetmaster                  = $quartermaster::puppetmaster,
  $vnc_passwd                    = $quartermaster::vnc_passwd,
){

  include ::stdlib

  # NGINX Installation
#  include ::nginx
  class{'::nginx':
    package_name => 'nginx-extras',
  }
  # nginx module = 0.5.0
  # nginx::resource::vhost{ $::fqdn:
  nginx::resource::server{ $::fqdn:
    ensure               => present,
    www_root             => '/srv/quartermaster',
    use_default_location => false,
    # nginx module = 0.5.0
    #vhost_cfg_append     => {
    server_cfg_append     => {
      autoindex             => on,
      fancyindex            => on,
      fancyindex_exact_size => off,
      fancyindex_footer     => '.README.html',
    },
  }
  nginx::resource::location{'/':
    ensure   => present,
    www_root => '/srv/quartermaster',
    # nginx module  0.5.0
    # vhost   => $::fqdn,
    server   => $::fqdn,
  }
  nginx::resource::location{'/status':
    ensure      => present,
    # nginx module  0.5.0
    # vhost   => $::fqdn,
    server      => $::fqdn,
    www_root    => '/srv/quartermaster',
    stub_status => true,
  }

  # Log Visualization Tools
  # https://code.google.com/p/logstalgia/
  # http://goaccess.prosoftcorp.com/

  package{['logstalgia','goaccess']:
    ensure  => latest,
    require => File['/srv/quartermaster/logs'],
  }
  
  # Define dictory structure on the filestem for default locations of bits.

  file{[
    '/srv/quartermaster',
    '/srv/quartermaster/bin',
    '/srv/quartermaster/iso',
    '/srv/quartermaster/images',
    '/srv/quartermaster/logs',
    '/srv/quartermaster/usb',
    '/srv/quartermaster/kickstart',
    '/srv/quartermaster/preseed',
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
# nginx module  0.5.0
#    owner   => 'nginx',
#    group   => 'nginx',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::daemon_user,
    recurse => true,
  } ->
  file{ '/srv/quartermaster/tftpboot':
    ensure  => directory,
    mode    => '0777',
    owner   => $::tftp::username,
    group   => $::tftp::username,
    recurse => true,
    require => Class['tftp'],
  } ->
  ## .README.html (FILE) /srv/quartermaster/distro/.README.html
  file{[
    '/srv/quartermaster/.README.html',
    '/srv/quartermaster/bin/.README.html',
    '/srv/quartermaster/iso/.README.html',
    '/srv/quartermaster/logs/.README.html',
    '/srv/quartermaster/usb/.README.html',
    '/srv/quartermaster/kickstart/.README.html',
    '/srv/quartermaster/preseed/.README.html',
    '/srv/quartermaster/tftpboot/.README.html',
    '/srv/quartermaster/unattend.xml/.README.html',
    '/srv/quartermaster/microsoft/.README.html',
    '/srv/quartermaster/microsoft/iso/.README.html',
    '/srv/quartermaster/microsoft/winpe/.README.html',
    '/srv/quartermaster/microsoft/winpe/bin/README.html',
    '/srv/quartermaster/microsoft/winpe/system/README.html',
    '/srv/quartermaster/microsoft/winpe/system/menu/.README.html',
  ]:
    ensure  => file,
    owner   => $::nginx::daemon_user,
    group   => $::nginx::daemon_user,
    mode    => '0644',
    content => '<html>
<head>
<title>Quartermaster</title></head>
<style>
div.container {
    width: 100%;
    border: 0px solid gray;
}

header, footer {
    padding: 1em;
    color: white;
    background-color: black;
    clear: left;
    text-align: center;
}

nav {
    float: left;
    max-width: 240px;
    margin: 0;
    padding: 1em;
}

nav ul {
    list-style-type: none;
    padding: 0;
}
   
nav ul a {
    text-decoration: none;
}
nav iframe {
    border-width: 0px;
}

article {
    margin-left: 170px;
<!--    border-left: 2px solid gray; -->
    padding: 1em;
    overflow: hidden;
}
</style>
</head>
<body>
<div class="container">
<header>
Supplies, Tools & Provisions
</header>
<nav>
<ul>
<li><img src="http://images.vector-images.com/217/quartermaster_corps_emb_n11082.gif" alt="Quartermaster Military Insignia" height="100"></li>
<li><h4><u>Nginx Status</u></h4>
<iframe src="http://quartermaster.openstack.tld/status" frameborder="0" width="240" height="80" >Nginx Status</iframe></li>
</ul>
</nav>
<article>
<dl>
<dt><h1>Quartermaster</h1><dt>
<dd> A military or naval term, the meaning of which depends on the country and service.</dd>
<dd>In land armies, a quartermaster is generally a relatively senior soldier who supervises stores and 
distributes supplies and provisions.</dd>
<dd>In many navies, quartermaster is a non-commissioned officer (petty officer) rank.</dd>
</dl>
<small>
<ul style="list-style-type:disc">
<li>Quartermaster - <a href="https://en.wikipedia.org/wiki/Quartermaster">Wikipedia</a> </li>
</ul>
</small>
</article>
<footer>
<small>
***
<a href="https://github.com/ppouliot/puppet-quartermaster.git">
Quartermaster on GitHub
</a>
***
</small>
</footer></div></body></html>
',
  }

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
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "#**** WARNING ****
# This File is manaaged by Puppet
search ${::domain}
nameserver ${quartermaster::preferred_nameserver}
nameserver 4.2.2.1
nameserver 4.2.2.2
",
  }
  
  # Install dnsmasq and configure a dns cache and 
  # proxydhcp server for nextserver and bootfile 
  # dhcp options

  class { 'dnsmasq':
#  Begin Disable DNS Cache
    port              => 0,
    expand_hosts      => false,
    bogus_priv        => false,
    no_negcache       => false,
    domain_needed     => false,
    strict_order      => false,
    no_resolv         => true,
    no_hosts          => true,
    reload_resolvconf => false,
    cache_size        => '0',
#  End Disable DNS Cache
#  Begin Enable DNS Cache
#    interface         => 'lo',
#    expand_hosts      => true,
#    dhcp_no_override  => true,
#    domain_needed     => true,
#    bogus_priv        => true,
#    no_negcache       => true,
#    no_hosts          => true,
#    reload_resolvconf => false,
#    cache_size        => '1000',
#    strict_order      => false,
#    restart           => true,
#  End Enable DNS Cache
#    resolv_file       => '/etc/resolv.conf.dnsmasq',
    config_hash       => {
#      'log-facility' => '/var/log/quartermaster/dnsmasq.log',
      'log-queries'  => true,
      'log-dhcp'     => true,
      'no-poll'      => true,
    },
  }
  dnsmasq::dhcp{'ProxyDHCP-PXE':
    dhcp_start => "${::ipaddress},proxy",
    dhcp_end   => $::netmask,
    lease_time => '',
    netmask    => '',
  }
  dnsmasq::dhcpoption{'vendor_pxeclient':
    option  => 'vendor:PXEClient',
    content => '6,2b',
  }
  dnsmasq::pxe_service{'Quartermaster PXE Provisioning':
    content => 'pxelinux/pxelinux',
  }
#  dnsmasq::dhcpboot{'proxydhcp':
#    file => 'pxelinux/pxelinux.0',
#    tag  => 'p1p0',
#    bootserver=> $::ipaddress,
#  }
  # Configure dnsmasq log rotation
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

  ## TFTP Server Configuration

  # Create the tftp remap file to allow us to boot
  # Windows and linux installs

  file { '/etc/tftpd.rules':
    content => template('quartermaster/tftp-remap.erb'),
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
    ensure => directory,
    mode   => '0777',
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

  # Squid monitoring tools
  package{[
    'squidview',
    'squidtaild',
    'squidclient',
  ]:
    ensure => latest,
  }
  class {'squid':
    http_ports   => {
      '3128' => {
        options => ''
      }
    },
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
    type    => port,
    entries => ['443'],
  }
  squid::acl{'CONNECT':
    type    => method,
    entries => ['CONNECT'],
  }
  squid::http_access{'CONNECT !SSL_ports':
    action => deny,
  }
  squid::http_access{'localhost manager':
    action => 'allow',
  }
  squid::http_access{'localhost':
    action => 'allow',
  }
  squid::http_access{'manager':
    action => 'deny',
  }
  squid::http_access{'all':
    action => 'allow',
  }
  squid::extra_config_section{'refresh_pattern':
    config_entries => {
      'refresh_pattern -i .*microsoft\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)'     => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern -i .*windowsupdate\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)' => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern -i .*windows\.com/.*\.(cab|exe|ms[i|u|f]|asf|wm[v|a]|dat|zip|psf)'       => '129600 100% 129600 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-cache ignore-private',
      'refresh_pattern ^ftp:'                                                                   => '1440 20% 10080',
      'refresh_pattern ^gopher:'                                                                => '1440 0% 1440',
      'refresh_pattern -i (/cgi-bin/|\?)'                                                       => '0 0% 0',
      'refresh_pattern (Release|Packagesi(.gz)*)$'                                              => '0 20% 2880',
      'refresh_pattern .'                                                                       => '0 20% 4230',
    },
  }
 ->
  file_line{'add_proxy_to_etc_environment':
    ensure => present,
    path   => '/etc/environment',
    match   => 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"',
    line   => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games\"
http_proxy=http://${::ipaddress}:3128/
ftp_proxy=http://${::ipaddress}:3128/
",
  }

  concat {'/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default':
    owner => $::tftp::username,
    group => $::tftp::username,
  }
  concat::fragment{'default_header':
    target  => '/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default',
    content => template('quartermaster/pxemenu/header.erb'),
    order   => 01,
  }

  concat::fragment{'default_localboot':
    target  => '/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default',
    content => template('quartermaster/pxemenu/localboot.erb'),
    order   => 01,
  }

  tftp::file {'pxelinux/graphics.cfg':
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
  staging::deploy { "syslinux-${quartermaster::syslinux_version}.tar.gz":
    source  => "${quartermaster::syslinux_url}/syslinux-${quartermaster::syslinux_version}.tar.gz",
    target  => '/tmp',
    creates => "/tmp/syslinux-${quartermaster::syslinux_version}",
  } ->
  # Move extracted files into position into TFTPDir
  tftp::file {'pxelinux/pxelinux.0':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/core/pxelinux.0",
  } ->

  tftp::file { 'pxelinux/gpxelinux0':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/gpxe/gpxelinux.0",
  } ->

  tftp::file { 'pxelinux/isolinux.bin':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/core/isolinux.bin",
  } ->

  tftp::file { 'pxelinux/menu.c32':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/com32/menu/menu.c32",
  } ->

  tftp::file { 'pxelinux/ldlinux.c32':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/com32/elflink/ldlinux/ldlinux.c32",
  } ->
  tftp::file { 'pxelinux/libutil.c32':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/com32/libutil/libutil.c32",
  } ->
  tftp::file { 'pxelinux/chain.c32':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/com32/chain/chain.c32",
  } ->
  tftp::file { 'pxelinux/libcom32.c32':
    source => "/tmp/syslinux-${quartermaster::syslinux_version}/bios/com32/lib/libcom32.c32",
  }

  # Installl WimLib
  case $::osfamily {
    'Debian':{
      package {'software-properties-common':
        ensure => latest,
      } -> 
      apt::ppa{'ppa:nilarimogard/webupd8':}
      $wimtool_repo = Apt::Ppa['ppa:nilarimogard/webupd8']
    }
    'RedHat':{
      yumrepo{'Nux Misc':
        name     => 'nux-misc',
        baseurl  => 'http://li.nux.ro/download/nux/misc/el6/x86_64/',
        enabled  => '0',
        gpgcheck => '1',
        gpgkey   => 'http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro',
      }
      $wimtool_repo = Yumrepo['Nux Misc']
    }
    default:{
      warn('Currently Unsupported OSFamily for this feature')
    }
  } ->

  package { 'wimtools':
    ensure  => latest,
    require => $wimtool_repo,
  } ->

  concat::fragment{'winpe_pxe_default_menu':
    target  => '/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default',
    content => template('quartermaster/pxemenu/winpe.erb'),
    require => Tftp::File['pxelinux/pxelinux.cfg']
  }
  include autofs
  autofs::mount{'*':
    mount       => '/srv/quartermaster/microsoft/mnt',
    mapfile     => '/etc/auto.quartermaster',
    mapcontents => [
      '* -fstype=iso9660,loop :/srv/quartermaster/microsoft/iso/&',
      '* -fstype=udf,loop :/srv/quartermaster/microsoft/iso/&',
    ],
    options     => '--timeout=10',
    order       => 01,
  }

  concat { '/srv/quartermaster/microsoft/winpe/system/setup.cmd': }
  concat::fragment{'winpe_system_cmd_a00_header':
    target  => '/srv/quartermaster/microsoft/winpe/system/setup.cmd',
    content => template('quartermaster/winpe/menu/A00_init.erb'),
    order   => 01,
  }
  concat::fragment{'winpe_system_cmd_b00_init':
    target  => '/srv/quartermaster/microsoft/winpe/system/setup.cmd',
    content => template('quartermaster/winpe/menu/B00_init.erb'),
    order   => 10,
  }
  concat::fragment{'winpe_system_cmd_c00_init':
    target  => '/srv/quartermaster/microsoft/winpe/system/setup.cmd',
    content => template('quartermaster/winpe/menu/C00_init.erb'),
    order   => 20,
  }
  concat::fragment{'winpe_menu_footer':
    target  => '/srv/quartermaster/microsoft/winpe/system/setup.cmd',
    content => template('quartermaster/winpe/menu/D00_init.erb'),
    order   => 99,
  }

  class{'::nfs':
    server_enabled => true,
  }
  nfs::server::export{'/srv/quartermaster':
    ensure  => 'mounted',
    clients => '*(ro,sync)',
  }
}
