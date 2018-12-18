  class{'quartermaster':
    dban_enable          => true,
    matchbox_enable      => true,
    puppetmaster         => "puppet",
    preferred_nameserver => $::dhcp,
  }
  # Archlinux
  quartermaster::pxelinux{'archlinux-2018.12.01-x86_64':}
  #quartermaster::pxelinux{'archlinux-latest-i686':}
  quartermaster::pxelinux{'archlinux-latest-x86_64':}


  # Fedora
  # i386
  quartermaster::pxelinux{'fedora-28-i386':}
  # Fedora
  # x86_64
  quartermaster::pxelinux{'fedora-28-x86_64':}
  # Ubuntu
  quartermaster::pxelinux{'ubuntu-18.04-i386':}
  quartermaster::pxelinux{'ubuntu-18.04-amd64':}
  # Centos
  quartermaster::pxelinux{'centos-6.9-i386':}
  # x86_64
  quartermaster::pxelinux{'centos-6.9-x86_64':}
  quartermaster::pxelinux{'centos-7.5.1804-x86_64':}
  # CoreOS
  quartermaster::pxelinux{'coreos-stable-amd64':}
  quartermaster::pxelinux{'coreos-beta-amd64':}
  quartermaster::pxelinux{'coreos-alpha-amd64':}
  # Flatcar Linux
  quartermaster::pxelinux{'flatcar-stable-amd64':}
  quartermaster::pxelinux{'flatcar-beta-amd64':}
  quartermaster::pxelinux{'flatcar-alpha-amd64':}
  # Scientific
  # i386
  quartermaster::pxelinux{'scientificlinux-6.9-i386':}
  # Scientific 
  # x86_64
  quartermaster::pxelinux{'scientificlinux-7.4-x86_64':}
  # Oracle Linux
  # i386
  #quartermaster::pxelinux{'oraclelinux-6.9-i386':}

  # Oracle Linux
  quartermaster::pxelinux{'oraclelinux-7.5-x86_64':}

  # Debian
  # i386
  quartermaster::pxelinux{'debian-9-i386':}
  # Debian
  # x86_64
  quartermaster::pxelinux{'debian-9-amd64':}

  # Devuan
  # i386
  quartermaster::pxelinux{'devuan-2.0-i386':}
  # Devuan
  # amd64
  quartermaster::pxelinux{'devuan-2.0-amd64':}


  # Kali Linux 
  quartermaster::pxelinux{'kali-current-amd64':}
  quartermaster::pxelinux{'kali-current-i386':}

  # RancherOS
  quartermaster::pxelinux{'rancheros-1.4.2-amd64':}

  # ReactOS
  quartermaster::pxelinux{'reactos-0.4.10-amd64':}

  # OpenSuse
  # i386
  quartermaster::pxelinux{'opensuse-13.2-i386':}
  # x86_64
  quartermaster::pxelinux{'opensuse-15.1-x86_64':}
  # XCPNG
  #quartermaster::pxelinux{'xcpng-7.5-x86_64':}
  #quartermaster::pxelinux{'xcpng-7.6-x86_64':}
}
