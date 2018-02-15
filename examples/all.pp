if $virtual == 'docker' {
  include dummy_service
}

node /quartermaster.*/ {
#  include munki

  class{'quartermaster':
    dban_enable          => true,
    matchbox_enable      => true,
    puppetmaster         => "puppetmaster.${domain}",
    preferred_nameserver => $::dhcp,
  }
  # Fedora
  quartermaster::pxelinux{'fedora-25-i386':}
  quartermaster::pxelinux{'fedora-25-x86_64':}
  quartermaster::pxelinux{'fedora-26-x86_64':}
  quartermaster::pxelinux{'fedora-27-x86_64':}
  # Ubuntu
  quartermaster::pxelinux{'ubuntu-12.04-amd64':}
  quartermaster::pxelinux{'ubuntu-12.04-i386':}
  quartermaster::pxelinux{'ubuntu-14.04-amd64':}
  quartermaster::pxelinux{'ubuntu-14.04-i386':}
  quartermaster::pxelinux{'ubuntu-16.04-amd64':}
  quartermaster::pxelinux{'ubuntu-16.04-i386':}
  quartermaster::pxelinux{'ubuntu-16.10-amd64':}
  quartermaster::pxelinux{'ubuntu-16.10-i386':}
  quartermaster::pxelinux{'ubuntu-17.04-amd64':}
  quartermaster::pxelinux{'ubuntu-17.04-i386':}
  quartermaster::pxelinux{'ubuntu-17.10-amd64':}
  quartermaster::pxelinux{'ubuntu-17.10-i386':}
  # Centos
  quartermaster::pxelinux{'centos-6.8-i386':}
  quartermaster::pxelinux{'centos-6.8-x86_64':}
  quartermaster::pxelinux{'centos-6.9-i386':}
  quartermaster::pxelinux{'centos-6.9-x86_64':}
  quartermaster::pxelinux{'centos-7.0.1406-x86_64':}
  quartermaster::pxelinux{'centos-7.1.1503-x86_64':}
  quartermaster::pxelinux{'centos-7.2.1511-x86_64':}
  quartermaster::pxelinux{'centos-7.3.1611-x86_64':}
  quartermaster::pxelinux{'centos-7.4.1708-x86_64':}
  # CoreOS
  quartermaster::pxelinux{'coreos-stable-amd64':}
  quartermaster::pxelinux{'coreos-beta-amd64':}
  quartermaster::pxelinux{'coreos-alpha-amd64':}
  # Scientific
  quartermaster::pxelinux{'scientificlinux-6.8-i386':}
  quartermaster::pxelinux{'scientificlinux-6.8-x86_64':}
  quartermaster::pxelinux{'scientificlinux-6.9-i386':}
  quartermaster::pxelinux{'scientificlinux-6.9-x86_64':}
  quartermaster::pxelinux{'scientificlinux-7.0-x86_64':}
  quartermaster::pxelinux{'scientificlinux-7.1-x86_64':}
  quartermaster::pxelinux{'scientificlinux-7.2-x86_64':}
  quartermaster::pxelinux{'scientificlinux-7.3-x86_64':}
  quartermaster::pxelinux{'scientificlinux-7.4-x86_64':}
  # Oracle Linux
  quartermaster::pxelinux{'oraclelinux-7.3-x86_64':}
  quartermaster::pxelinux{'oraclelinux-7.4-x86_64':}
  # Debian
  quartermaster::pxelinux{'debian-5-i386':}
  quartermaster::pxelinux{'debian-5-amd64':}
  quartermaster::pxelinux{'debian-6-i386':}
  quartermaster::pxelinux{'debian-6-amd64':}
  quartermaster::pxelinux{'debian-7-amd64':}
  quartermaster::pxelinux{'debian-7-i386':}
  quartermaster::pxelinux{'debian-8-amd64':}
  quartermaster::pxelinux{'debian-8-i386':}
  quartermaster::pxelinux{'debian-9-amd64':}
  quartermaster::pxelinux{'debian-9-i386':}
  # Kali Linux 
  # Kali Linux 
  quartermaster::pxelinux{'kali-current-amd64':}
  quartermaster::pxelinux{'kali-current-i386':}
# RancherOS
  quartermaster::pxelinux{'rancheros-1.1.0-amd64':}
  quartermaster::pxelinux{'rancheros-1.1.1-amd64':}
  quartermaster::pxelinux{'rancheros-latest-amd64':}
# OpenSuse
  quartermaster::pxelinux{'opensuse-13.2-x86_64':}
  quartermaster::pxelinux{'opensuse-42.2-x86_64':}
  quartermaster::pxelinux{'opensuse-42.3-x86_64':}
  quartermaster::windowsmedia{'en_microsoft_hyper-v_server_2016_x64_dvd_9347277.iso': activationkey => undef, }
}
