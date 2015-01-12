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
#    class{quartermaster:
#      dhcp_proxy_subnet => ['192.168.1.1',
#         'fr myip 192.168.1.2',
#         'office src 10.0.0.0/24',
#       ],
# }
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
  $linux   = $quartermaster::params::linux,
  $windows = $quartermaster::params::windows
  dhcp_proxy_subnet => [],

) inherits quartermaster::params {

  class{'apt':}
  class { 'quartermaster::commands': }

  class { 'quartermaster::www': }
  class { 'quartermaster::puppetmaster': }
  class { 'quartermaster::squid_deb_proxy': }
  class { 'quartermaster::dnsmasq': }
  class { 'quartermaster::server::tftpd': }
  class { 'quartermaster::syslinux': }
  class { 'quartermaster::nfs': }
  class { 'quartermaster::winpe': }
  class { 'quartermaster::scripts': }

  quartermaster::pxe{$linux:}
  create_resources(quartermaster::windowsmedia,$windows)

}
