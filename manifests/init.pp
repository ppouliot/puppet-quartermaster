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
#  [*  enable_dban *]
#  Turns on DBAN functionality.  DBAN provides automated disk erasure and data wiping
#  By default this is set to undef, setting to enabled will download and integrage 
#  The components into the pxe infrastructure.  For more information on DBAN
#  http://www.dban.org
#
#  [* dban_version *]
#  Version of DBAN to download and use.  Defaults to 2.2.8
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
#    quartermaster::pxe{"fedora-17-x86_64":}
#    quartermaster::pxe{"fedora-16-i386":}
#    quartermaster::pxe{"ubuntu-12.04-amd64":}
#    quartermaster::pxe{"ubuntu-12.10-amd64":}
#    quartermaster::pxe{"centos-6.3-x86_64":}
#    quartermaster::pxe{"scientificlinux-6.3-x86_64":}
#    quartermaster::pxe{"opensuse-12.2-x86_64":}
#    quartermaster::pxe{"debian-stable-amd64":}
#    quartermaster::windowsmedia{"en_windows_server_2012_x64_dvd_915478.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" }
#    quartermaster::windowsmedia{"en_microsoft_hyper-v_server_2012_x64_dvd_915600.iso": activationkey => "" }
#    quartermaster::windowsmedia{"en_windows_8_enterprise_x64_dvd_917522.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
#    quartermaster::windowsmedia{"en_windows_8_enterprise_x86_dvd_917587.iso": activationkey => "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"}
# }
#
class quartermaster (
  $preferred_nameserver = undef,
  $syslinux_url         = 'http://www.kernel.org/pub/linux/utils/boot/syslinux',
  $syslinux_version     = '6.03',
  $enable_dban          = undef,
  $dban_version         = '2.2.8',
  $proxydhcp_subnets    = [],
  $linux                = hiera('linux',{}),
  $windows              = hiera('windows',{}),
  $enable_poap          = undef,

) inherits quartermaster::params {

  validate_re($::osfamily, '^(Debian|RedHat)$', 'This module only works on Debian and Red Hat based systems.')

  contain quartermaster::install
  contain quartermaster::configure


  class{'::quartermaster::install': }     ->
  class{'::quartermaster::configure': }     

  if $enable_poap == true {
    contain quartermaster::poap
    class{'::quartermaster::poap':}     
  }

  if $enable_dban == true {
    contain quartermaster::dban
    class{'::quartermaster::dban':}     
  }

#if $linux {
##  create_resources(quartermaster::pxe,$linux)
#  quartermaster::pxe{$linux:}
#}

#if $windows {
#  create_resources(quartermaster::windowsmedia,$windows)
#}
#Quartermaster::Pxebootfile <<| |>>

#  Class['quartermaster'] -> Quartermaster::Pxe <||>
#  Class['quartermaster'] -> Quartermaster::Windowsmedia <||>

}
