# == Class: quartermaster
# This module provides an opinionated toolbox of various pxeable resources..
# It uses a ProxyDhcp server to provide dropin bootfile/nextserver values to clients
# on the subnet it is on without modification needed to the existing network infrastructure.
# Additional Services are privided depending on resource by TFTP, HTTP, SMB, NFS
# PXE Installations are provided for most major Linux platforms as well as Windows platforms.
# Windows installations require the ISO file to be put in the ISO smb share unmodified as downloaded from MSDN.
#
# === Parameters
#  [* preferred_nameserver *]
#  The Nameserver on your local subnet for internal name resolution.
#  By default we'll use an available upstream dns server.
#
#  [* syslinux_version *]
#  The version of syslinux to use. Default syslinux_version used is 6.03
#
#  [* syslinux_url *]
#   The default syslinux_url is http://www.kernel.org/pub/linux/utils/boot/syslinux
#
#  [*  dban_enable *]
#  Turns on DBAN functionality.  DBAN provides automated disk erasure and data wiping
#  By default this is set to undef, setting to enabled will download and integrage 
#  The components into the pxe infrastructure.  For more information on DBAN
#  http://www.dban.org
#
#  [* dban_version *]
#  Version of DBAN to download and use.  Defaults to 2.2.8
#
#  [* matchbox_version *]
#  Version of Matchbox to download and use.  Defaults to 0.6.1
#
#  [* enable_poap *]
#  This is currently experimental.  As of now it gathers and deploys scripts
#  for Cisco's Power On Auto Provisioning for Nexus platform switches.
#
#
# === Requires:
# see Modulefile
#
# ===Sample Usage
# ====Example
# Usage at Node.
# node foo {
#    class{quartermaster:
#      dhcp_proxy_subnet => ['192.168.1.1',
#         'fr myip 192.168.1.2',
#         'office src 10.0.0.0/24',
#       ],
#    }
#    quartermaster::pxelinux{"fedora-17-x86_64":}
#    quartermaster::pxelinux{"fedora-16-i386":}
#    quartermaster::pxelinux{"ubuntu-12.04-amd64":}
#    quartermaster::pxelinux{"ubuntu-12.10-amd64":}
#    quartermaster::pxelinux{"centos-6.3-x86_64":}
#    quartermaster::pxelinux{"scientificlinux-6.3-x86_64":}
#    quartermaster::pxelinux{"opensuse-12.2-x86_64":}
#    quartermaster::pxelinux{"debian-stable-amd64":}
#    quartermaster::windowsmedia{"en_windows_server_2012_x64_dvd_915478.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" }
#    quartermaster::windowsmedia{"en_microsoft_hyper-v_server_2012_x64_dvd_915600.iso": activationkey => "" }
#    quartermaster::windowsmedia{"en_windows_8_enterprise_x64_dvd_917522.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
#    quartermaster::windowsmedia{"en_windows_8_enterprise_x86_dvd_917587.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
# }
#
class quartermaster (
  Optional[String] $preferred_nameserver             = undef,
  String $syslinux_url                               = 'http://www.kernel.org/pub/linux/utils/boot/syslinux',
  String $syslinux_version                           = '6.03',
  Optional[Boolean] $dban_enable                     = undef,
  Optional[String] $dban_version                     = '2.3.0',
  Optional[Boolean] $matchbox_enable                 = undef,
  Optional[String] $matchbox_version                 = '0.7.1',
  Optional[String] $go_version                       = '1.11.2',
  Optional[String] $terraform_version                = '0.11.10',

  $proxydhcp_subnets                                 = [],

  Optional[Boolean] $enable_poap                     = undef,
  Optional[Boolean] $enable_hp_spp                   = undef,
  Optional[String] $hp_spp_iso_complete_url_location = 'ftp://ftp.hp.com/pub/softlib2/software1/cd-generic/p67859018/v108240/SPP2015040.2015_0407.5.iso',
  Optional[String] $hp_spp_iso_name                  = 'SPP2015040.2015_0407.5.iso',
  Optional[String] $jenkins_swarm_version_to_use     = '3.3',
  String $default_pxeboot_option                     = 'menu.c32',
  String $pxe_menu_timeout                           = '10',
  String $pxe_menu_total_timeout                     = '120',
  String $pxe_menu_allow_user_arguments              = '0',
  String $pxe_menu_default_graphics                  = '../pxelinux/pxelinux.cfg/graphics.cfg',
  Optional[String] $puppetmaster                     = undef,
  Optional[String] $use_local_proxy                  = undef,
  String $vnc_passwd                                 = 'letmein',
  Optional[String] $etcd_token                       = '42af8a395def005a2b952b429de3417f'

) inherits quartermaster::params {

  if $::osfamily {
    assert_type(Pattern[/(^Debian|RedHat)$/], $::osfamily) |$a, $b| {
      fail translate(('This Module only works on Debian and RedHat like systems.'))
    }
  }


  class{'::quartermaster::install': }
->class{'::quartermaster::configure': }

  contain quartermaster::install
  contain quartermaster::configure

  if $enable_poap == true {
    class{'::quartermaster::poap':}
    contain quartermaster::poap
  }

  if $dban_enable == true {
    class{'::quartermaster::dban':}
    contain quartermaster::dban
  }
  if $matchbox_enable == true {
    class{'::quartermaster::matchbox':}
    contain quartermaster::matchbox
  }


#if $linux {
#  create_resources( quartermaster::pxe,$linux)
#  quartermaster::pxe{$linux:}
#}

#if $windows {
#  create_resources(quartermaster::windowsmedia,$windows)
#}
#Quartermaster::Pxebootfile <<| |>>

# Class['quartermaster::install'] -> Quartermaster::Pxe <||>
#  Class['quartermaster'] -> Quartermaster::Windowsmedia <||>

}
