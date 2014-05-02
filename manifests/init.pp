# Class: quartermaster
#
# This module manages quartermaster
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
# Example: Usage at Node.
# node foo {
#    class{quartermaster: }:
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
class quartermaster(
  $use_puppetdb      = false,
  $tmp               = '/tmp'
  $logroot           = '/var/log/quartermaster'
  $tftpboot          = '/srv/tftpboot'
  $wwwroot           = '/srv/install'
  $nfsroot           = '/srv/nfs'
  $bin               = "${wwwroot}/bin"
  $puppetmaster_fqdn = "${fqdn}"
  $exe_mode          = '0777'
  $file_mode         = '0644'
  $dir_mode          = '0755'
  $counter           = '0'
  $nameserver        = '4.2.2.2'
  $linux             = hiera('linux',{}),
  $windows           = hiera('windows',{}),
){

  class{'apt':}
  class { 'quartermaster::commands': }
  class { 'quartermaster::www': }
  class { 'quartermaster::puppetmaster': use_puppetdb => $use_puppetdb,}
  class { 'quartermaster::squid_deb_proxy': }
  if ! defined (Class['ipam']){
    # This only applies if we aren't already the IPAM host.
    class { 'quartermaster::dnsmasq': }
  }
  class { 'quartermaster::tftpd': }
  class { 'quartermaster::syslinux': }
  class { 'quartermaster::nfs': }
  class { 'quartermaster::winpe': }
  class { 'quartermaster::scripts': }

  if is_array($linux) {
    quartermaster::pxe{$linux:}
  } else if is_hash($linux) {
    create_resources(quartermaster::pxe,$linux)
  } else {
    notify {'Variable $linux must be a hash or an array to be processed.  Skipping Linux distros.':}
  }
  create_resources(quartermaster::windowsmedia,$windows)

}
