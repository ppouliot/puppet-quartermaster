
  class{'quartermaster::dnsmasq': }  ->
  class{'quartermaster::tftpd':}       ->
  class{'quartermaster::squid':}         ->
  class{'quartermaster::syslinux':}

