if $virtual == 'docker' {
  include dummy_service
}

class{'quartermaster':
  dban_enable          => true,
  matchbox_enable      => true,
  puppetmaster         => "puppetmaster.${domain}",
  preferred_nameserver => $::dhcp,
}

# RancherOS
  quartermaster::pxelinux{'rancheros-1.0.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.1.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.1.1-amd64':}
  quartermaster::pxelinux{'rancheros-1.2.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.3.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.4.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.4.1-amd64':}
  quartermaster::pxelinux{'rancheros-1.4.2-amd64':}
