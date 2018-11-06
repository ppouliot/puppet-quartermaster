#== Class: quartermaster::proxydhcp_subnet
define quartermaster::proxydhcp_subnet(
  $network_ipaddr,
  $network_subnet_mask,
) {

# new format using saz/dnsmasq
# #dhcp-range=172.20.230.92,proxy,255.255.255.192,,
  dnsmasq::conf{"$name":
    ensure => present,
    content => "dhcp-range=${network_ipaddr},proxy,${network_subnet_mask},",
  }
# Old Format using lex/dnsmasq  
#  dnsmasq::dhcp{$name:
#    dhcp_start => "${network_ipaddr},proxy",
#    dhcp_end   => $network_subnet_mask,
#    lease_time => '',
#    netmask    => '',
#    notify     => Service['dnsmasq'],
#  }


}
