define quartermaster::proxydhcp_subnet(
  $network_ipaddr
  $network_subnet_mask
) {
  
  dnsmasq::dhcp{$name:
    dhcp_start => "${network_ipaddr},proxy",
    dhcp_end   => $network_subnet_mask,
    lease_time => '',
    netmask    => '',
    notify     => Service['dnsmasq'],
  }


}
