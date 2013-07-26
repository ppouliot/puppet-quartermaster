# Class: quartermaster::pxe
#
# This Class defines the creation of the linux pxe infrastructure
#


define quartermaster::pxe {
# account for "."
  if $name =~ /([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)/ {
# works w/ no .
#if $name =~ /([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)/ {
    $distro  = $1
#    $rel_number = regsubst($2, '(\.)','','G')
    $release = $2
    $p_arch  = $3
  }

  $rel_number = regsubst($release, '(\.)','','G')

  if $release =~/([0-9]+).([0-9])/{
    $el_major = $1
    $el_minor = $2
  }

  # Begin Tests to deal with Centos Minor Point releases
  $is_centos = $distro ? {
    /(centos)/   => 'true',
    default      => 'This is not centos',  
  }

  $el_legacy = $el_minor ? {
    /(0|1|2|3)/ => 'true',
    /(4)/       => 'false',
    default	=> 'This is not a EL Distro',
  }

  if $is_centos == 'true' {
     $centos_url = $el_legacy ? {
      /(true)/   => "http://vault.centos.org/${release}",
      /(false)/  => "http://mirror.centos.org/centos/${el_major}",
    }
  }
  # Begin tests for dealing with OracleLinux Repos
  $is_oracle = $distro ? {
    /(oraclelinux)/ => 'true',
    default         => 'This is not Oracle Linux',  
  }

  $rel_name = $release ? {
    /(11.04)/    => 'natty',
    /(11.10)/    => 'oneric',
    /(12.04)/    => 'precise',
    /(12.10)/    => 'quantal',
    /(13.04)/    => 'raring',
    /(stable)/   => 'squeeze',
    /(testing)/  => 'wheezy',
    /(unstable)/ => 'sid',
    default      => "Unsupported ${distro} Release",
  }

  $url = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
    /(debian)/          => "http://ftp.us.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
#   /(ubuntu|debian)/   => "http://mirrors.mit.edu/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
    /(centos)/          => "${centos_url}/os/${p_arch}/images/pxeboot",
#    /(centos)/         => "http://vault.centos.org/${release}/os/${p_arch}/images/pxeboot",
#    /(centos)/         => "http://mirrors.med.harvard.edu/${distro}/${release}/os/${p_arch}/images/pxeboot",
#   /(fedora)/          => "http://download.fedora.redhat.com/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
    /(fedora)/          => "http://mirrors.med.harvard.edu/${distro}/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
#  /(scientificlinux)/  => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os/images/pxeboot",
    /(scientificlinux)/ => "http://mirrors.med.harvard.edu/${distro}/${release}/${p_arch}/os/images/pxeboot",
    /(oraclelinux)/     => "Enterprise ISO Required",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
#    /(opensuse)/       => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader",
    /(opensuse)/        => "http://mirrors.med.harvard.edu/${distro}/distribution/${release}/repo/oss/boot/${p_arch}/loader",
    default             => 'No URL Specified',
  }

  $inst_repo = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}",
    /(debian)/          => "http://ftp.us.debian.org/${distro}/dists/${rel_name}",
#   /(ubuntu|debian)/   => "http://mirrors.med.harvard.edu/${distro}/dists/${rel_name}",
    /(centos)/          => "${centos_url}/os/${p_arch}/",
    /(fedora)/          => "http://download.fedora.redhat.com/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${el_major}/${el_minor}/base/${p_arch}/",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader",
    default             => 'No URL Specified',
  }

  $update_repo = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}",
    /(debian)/          => "http://ftp.us.debian.org/${distro}/dists/${rel_name}",
#   /(ubuntu|debian)/   => "http://mirrors.med.harvard.edu/${distro}/dists/${rel_name}",
    /(centos)/          => "${centos_url}/updates/${p_arch}/",
    /(fedora)/          => "http://download.fedoraproject.org/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/updates/security",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${el_major}/${el_minor}/base/${p_arch}/",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)         => "http://download.opensuse.org/distribution/${release}/repo/non-oss/suse",
    default             => 'No URL Specified',
  }


  $splashurl = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash.png",
    /(debian)/          => "http://ftp.us.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash.png",
    #/(ubuntu|debian)/   => "http://mirrors.med.harvard.edu/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash.png",
    /(redhat)/          => 'Enterprise ISO Required',
    /(centos)/          => "${centos_url}/os/${p_arch}/isolinux/splash.jpg",
    /(fedora)/          => "http://download.fedoraproject.org/pub/fedora/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os/isolinux/splash.jpg",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${el_major}/${el_minor}/base/${p_arch}/",
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/      => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader/boot.jpg"
    default             => 'No URL Specified',
  }
  $bootsplash = $distro ? {
    /(ubuntu|debian|fedora)/                             => '.png',
    /(redhat|centos|scientificlinux|opensuse|sles|sled)/ => '.jpg',
    /(windows)/                                          => 'No Bootsplash',
    /(oraclelinux)/                                      => 'No Bootsplash ',
    default                                              => 'No Bootsplash',
  }


  $autofile = $distro ? {
    /(ubuntu|debian)/                                    => 'preseed',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'kickstart',
    /(sles|sled|opensuse)/                               => 'autoyast',
    /(windows)/                                          => 'unattend.xml',
    default                                              => 'No supported automated installation method',
  }

  $pxekernel = $distro ? {
    /(ubuntu|debian)/                                    => 'linux',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'vmlinuz',
    /(sles|sled|opensuse)/                               => 'linux',
    default                                              => 'No supported Pxe Kernel',
  }

  $initrd = $distro ? {
    /(ubuntu|debian)/                                    => '.gz',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => '.img',
    /(sles|sled|opensuse)/                               => '',
    default                                              => 'No supported Initrd Extension',
  }
  $linux_installer = $distro ? {
    /(ubuntu|debian)/                                    => 'd-i',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'anaconda',
    /(sles|sled|opensuse)/                               => 'yast',
    default                                              => 'No Supported Installer',
  }
  $puppetlabs_repo = $distro ? {
    /(ubuntu|debian)/                                    => "http://apt.puppetlabs.com/dists/${rel_name}",
    /(fedora)/                                           => "http://yum.puppetlabs.com/fedora/f${rel_number}/products/${p_arch}",
    /(redhat|centos|scientificlinux|oraclelinux)/        => "http://yum.puppetlabs.com/el/${el_major}/products/${p_arch}",
    default                                              => 'No PuppetLabs Repo',
  }




  notify { "${name}: distro is ${distro}":}
  notify { "${name}: release is ${release}":}
  notify { "${name}: el_major is ${el_major}":}
  notify { "${name}: el_minor is ${el_minor}":}
  notify { "${name}: p_arch is  ${p_arch}":}
  notify { "${name}: url is ${url}":}
  notify { "${name}: inst_repo is ${inst_repo}":}
  notify { "${name}: kernel is ${pxekernel}":}
  notify { "${name}: initrd is ${initrd}":}
  notify { "${name}: linux_installer is ${linux_installer}":}
  notify { "${name}: PuppetLabs Repo is ${puppetlabs_repo}":}
  notify { "${name}: ${is_centos}":}


  exec {"get_net_kernel-${name}":
    command => "/usr/bin/wget -c ${url}/${pxekernel} -O ${rel_number}",
    cwd     => "${quartermaster::tftpboot}/${distro}/${p_arch}",
    creates => "${quartermaster::tftpboot}/${distro}/${p_arch}/${rel_number}",
    require =>  File[ "${quartermaster::tftpboot}/${distro}/${p_arch}" ],
  }

  exec {"get_net_initrd-${name}":
    command => "/usr/bin/wget -c ${url}/initrd${initrd} -O ${rel_number}${initrd}",
    cwd     => "${quartermaster::tftpboot}/${distro}/${p_arch}",
    creates => "${quartermaster::tftpboot}/${distro}/${p_arch}/${rel_number}${initrd}",
    require =>  File[ "${quartermaster::tftpboot}/${distro}/${p_arch}" ],
  }

  exec {"get_bootsplash-${name}":
    command => "/usr/bin/wget -c ${splashurl}  -O ${name}${bootsplash}",
    cwd     => "${quartermaster::tftpboot}/${distro}/images",
    creates => "${quartermaster::tftpboot}/${distro}/images/${name}${bootsplash}",
    require =>  File[ "${quartermaster::tftpboot}/${distro}/images" ],
  }

  exec {"create_submenu-${name}":
    command     => "${quartermaster::wwwroot}/bin/concatenate_files.sh ${quartermaster::tftpboot}/${distro}/menu ${quartermaster::tftpboot}/${distro}/${distro}.menu",
    cwd         => "${quartermaster::tftpboot}/${distro}/",
    creates     => "${quartermaster::tftpboot}/${distro}/${distro}.menu",
    notify      => Service[ 'tftpd-hpa' ],
    require     => File["${quartermaster::wwwroot}/bin/concatenate_files.sh"],
  }


  if ! defined (File["${quartermaster::tftpboot}/${distro}"]){
    file { "${quartermaster::tftpboot}/${distro}":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require =>  File[$quartermaster::tftpboot],
    }
  }


  if ! defined (File["${quartermaster::tftpboot}/${distro}/menu"]){
    file { "${quartermaster::tftpboot}/${distro}/menu":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}" ],
    }
  }

  if ! defined (File["${quartermaster::tftpboot}/${distro}/images"]){
    file { "${quartermaster::tftpboot}/${distro}/images":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}" ],
    }
  }

  if ! defined (File["${quartermaster::tftpboot}/${distro}/${p_arch}"]){
    file { "${quartermaster::tftpboot}/${distro}/${p_arch}":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}" ],
    }
  }

  if ! defined (File["${quartermaster::wwwroot}/${distro}"]) {
    file { "${quartermaster::wwwroot}/${distro}":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ $quartermaster::wwwroot ],
    }
  }

  if ! defined (File["${quartermaster::wwwroot}/${distro}/${autofile}"]) {
    file { "${quartermaster::wwwroot}/${distro}/${autofile}":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => File[ $quartermaster::wwwroot ],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/${distro}/${p_arch}"]) {
    file { "${quartermaster::wwwroot}/${distro}/${p_arch}":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => File[ $quartermaster::wwwroot ],
    }
  }
  if ! defined (File["${quartermaster::wwwroot}/${distro}/ISO"]) {
    file { "${quartermaster::wwwroot}/${distro}/ISO":
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      require => File[$quartermaster::wwwroot],
    }
  }


  file { "${name}.${autofile}":
    ensure  => file,
    path    => "${quartermaster::wwwroot}/${distro}/${autofile}/${name}.${autofile}",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    content => template("quartermaster/autoinst/${autofile}.erb"),
    require => File[ "${quartermaster::wwwroot}/${distro}/${autofile}" ],
  }


  if ! defined (File["${quartermaster::tftpboot}/menu/${distro}.menu"]) {
    file { "${quartermaster::tftpboot}/menu/${distro}.menu":
      ensure  => file,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}/menu" ],
      notify  => Exec['create_default_pxe_menu'],
      content => template('quartermaster/pxemenu/default.erb'),
    }
  }
  file { "${name}.menu":
    ensure  => file,
    path    => "${quartermaster::tftpboot}/${distro}/menu/${name}.menu",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => '0644',
    require => File[ "${quartermaster::tftpboot}/${distro}/menu" ],
    notify  => Exec["create_submenu-${name}"],
    content => template("quartermaster/pxemenu/${linux_installer}.erb"),
  }


}
