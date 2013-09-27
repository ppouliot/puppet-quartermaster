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
    $rel_major = $1
    $rel_minor = $2
  }

  # Begin Tests to deal with centos point release issues
  $is_centos = $distro ? {
    /(centos)/   => 'true',
    default      => 'This is not centos',  
  }

  if $is_centos == 'true' {
   $centos_legacy = $rel_minor ? {
      /(0|1|2|3)/ => 'true',
      /(4)/       => 'false',
      default	=> 'This is not a EL Distro',
    }
  }

  if $is_centos == 'true' {
     $centos_url = $centos_legacy ? {
      /(true)/   => "http://vault.centos.org/${release}",
      /(false)/  => "http://mirror.centos.org/centos/${rel_major}",
    }
  }

  # Tests to determine fedora versioning to enable proper download repos
  $is_fedora = $distro ? {
    /(fedora)/   => 'true',
    default      => 'This is not fedora',  
  }
  if ( $is_fedora == 'true') and ($release < 18) {
      $fedora_legacy = 'true'
  }
  if ( $is_fedora == 'true') and ($release >= 18) {
      $fedora_legacy = 'false'
  }
  if $is_fedora == 'true' {
     $fedora_url = $fedora_legacy ? {
      /(true)/   => "http://archives.fedoraproject.org/pub/archive",
      /(false)/  => "http://dl.fedoraproject.org/pub",
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
    /(debian)/          => "http://ftp.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
#    /(ubuntu|debian)/   => "http://${webhost}.${distro}.${tld}/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
    /(centos)/          => "${centos_url}/os/${p_arch}/images/pxeboot",
#    /(fedora)/          => "http://dl.fedoraproject.org/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
#    /(fedora)/          => "http://archives.fedoraproject.org/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
    /(fedora)/          => "${fedora_url}/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
    /(scientificlinux)/  => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os/images/pxeboot",
    /(oraclelinux)/     => "Enterprise ISO Required",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader",
    default             => 'No URL Specified',
  }

  $tld = $distro ?{
    /(ubuntu)/ => 'com',
    /(debian)/ => 'org',
    default    => "tld isn't needed for ${distro}",   
  }
  $webhost = $distro ?{
    /(ubuntu)/ => 'archive',
    /(debian)/ => 'ftp.us',
    default    => "webhost isn't needed for ${distro}",   
  }


  $inst_repo = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}",
    /(debian)/          => "http://ftp.debian.org/${distro}/dists/${rel_name}",
    /(centos)/          => "${centos_url}/os/${p_arch}/",
    /(fedora)/          => "${fedora_url}/${distro}/linux/releases/${release}/Fedora/${p_arch}/os",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${rel_major}/${rel_minor}/base/${p_arch}/",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader",
    default             => 'No URL Specified',
  }

  $update_repo = $distro ? {
    /(ubuntu)/          => "http://archive.ubuntu.com/${distro}/dists/${rel_name}",
    /(debian)/          => "http://ftp.debian.org/${distro}/dists/${rel_name}",
    /(centos)/          => "${centos_url}/updates/${p_arch}/",
    /(fedora)/          => "${fedora_url}/${distro}/linux/releases/${release}/Fedora/${p_arch}/os",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/updates/security",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${rel_major}/${rel_minor}/base/${p_arch}/",
    /(redhat)/          => 'Enterprise ISO Required',
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/non-oss/suse",
    default             => 'No URL Specified',
  }


  $splashurl = $distro ? {
    /(ubuntu)/         => "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash.png",
    /(debian)/         => "http://ftp.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}/boot-screens/splash.png",
    /(redhat)/          => 'Enterprise ISO Required',
    /(centos)/          => "${centos_url}/os/${p_arch}/isolinux/splash.jpg",
    /(fedora)/          => "${fedora_url}/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/isolinux/splash.png",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os/isolinux/splash.jpg",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${rel_major}/${rel_minor}/base/${p_arch}/",
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader/back.jpg",
    default             => 'No URL Specified',
  }
  $bootsplash = $distro ? {
    /(ubuntu|debian|fedora|scientificlinux)/             => '.png',
    /(redhat|centos|opensuse|sles|sled)/                 => '.jpg',
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
    /(redhat|centos|scientificlinux|oraclelinux)/        => "http://yum.puppetlabs.com/el/${rel_major}/products/${p_arch}",
    default                                              => 'No PuppetLabs Repo',
  }




  notify { "${name}: distro is ${distro}":}
  notify { "${name}: release is ${release}":}
  notify { "${name}: rel_major is ${rel_major}":}
  notify { "${name}: rel_minor is ${rel_minor}":}
  notify { "${name}: p_arch is  ${p_arch}":}
  notify { "${name}: url is ${url}":}
  notify { "${name}: inst_repo is ${inst_repo}":}
  notify { "${name}: kernel is ${pxekernel}":}
  notify { "${name}: initrd is ${initrd}":}
  notify { "${name}: linux_installer is ${linux_installer}":}
  notify { "${name}: PuppetLabs Repo is ${puppetlabs_repo}":}
  notify { "${name}: Centos Distro = ${is_centos}":}
  notify { "${name}: Centos Legacy = ${centos_legacy}":}
  notify { "${name}: Centos URL = ${centos_url}":}
  notify { "${name}: Fedora Distro = ${is_fedora}":}
  notify { "${name}: Fedora Distro = ${fedora_legacy}":}
  notify { "${name}: Fedora URL = ${fedora_url}":}
  notify { "${name}: Oracle Distro = ${is_oracle}":}


  exec {"get_net_kernel-${name}":
    command => "/usr/bin/wget -c ${url}/${pxekernel} -O ${rel_number}",
    cwd     => "${quartermaster::tftpboot}/${distro}/${p_arch}",
    creates => "${quartermaster::tftpboot}/${distro}/${p_arch}/${rel_number}",
    require =>  [Class['quartermaster::squid_deb_proxy'], File[ "${quartermaster::tftpboot}/${distro}/${p_arch}" ]],
  }

  exec {"get_net_initrd-${name}":
    command => "/usr/bin/wget -c ${url}/initrd${initrd} -O ${rel_number}${initrd}",
    cwd     => "${quartermaster::tftpboot}/${distro}/${p_arch}",
    creates => "${quartermaster::tftpboot}/${distro}/${p_arch}/${rel_number}${initrd}",
    require =>  [Class['quartermaster::squid_deb_proxy'], File[ "${quartermaster::tftpboot}/${distro}/${p_arch}" ]],
  }

  exec {"get_bootsplash-${name}":
    command => "/usr/bin/wget -c ${splashurl}  -O ${name}${bootsplash}",
    cwd     => "${quartermaster::tftpboot}/${distro}/graphics",
    creates => "${quartermaster::tftpboot}/${distro}/graphics/${name}${bootsplash}",
    require =>  [ Class['quartermaster::squid_deb_proxy'], File[ "${quartermaster::tftpboot}/${distro}/graphics" ]],
  }

#  exec {"create_submenu-${name}":
#    command     => "${quartermaster::wwwroot}/bin/concatenate_files.sh ${quartermaster::tftpboot}/${distro}/menu ${quartermaster::tftpboot}/${distro}/${distro}.menu",
#    cwd         => "${quartermaster::tftpboot}/${distro}/",
#    creates     => "${quartermaster::tftpboot}/${distro}/${distro}.menu",
#    notify      => Service[ 'tftpd-hpa' ],
#    require     => File["${quartermaster::wwwroot}/bin/concatenate_files.sh"],
#  }


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

  if ! defined (File["${quartermaster::tftpboot}/${distro}/graphics"]){
    file { "${quartermaster::tftpboot}/${distro}/graphics":
      ensure  => directory,
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}" ],
    }
  }
    file { "${name}.graphics.conf":
      ensure  => file,
      path    => "${quartermaster::tftpboot}/${distro}/menu/${name}.graphics.conf",
      owner   => 'tftp',
      group   => 'tftp',
      mode    => '0644',
      require => File[ "${quartermaster::tftpboot}/${distro}/menu" ],
      content => template("quartermaster/pxemenu/${linux_installer}.graphics.erb"),
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


  if ! defined (Concat::Fragment["${distro}.default_menu_entry"]) {
    concat::fragment { "${distro}.default_menu_entry":
      target  => "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/default",
      content => template("quartermaster/pxemenu/default.erb"),
    }
  }
  if ! defined (Concat["${quartermaster::tftpboot}/menu/${distro}.menu"]) {
    concat { "${quartermaster::tftpboot}/menu/${distro}.menu":
      owner   => 'tftp',
      group   => 'tftp',
      mode    => $quartermaster::file_mode,
      notify => Service['tftpd-hpa'],
    }
  }
  if ! defined (Concat::Fragment["${distro}.submenu_header"]) {
    concat::fragment {"${distro}.submenu_header":
      target  => "${quartermaster::tftpboot}/menu/${distro}.menu",
      content => template("quartermaster/pxemenu/header2.erb"),
      order   => 01,
    }
  }
  if ! defined (Concat::Fragment["${distro}${name}.menu_item"]) {
    concat::fragment {"${distro}.${name}.menu_item":
      target  => "${quartermaster::tftpboot}/menu/${distro}.menu",
      content => template("quartermaster/pxemenu/${linux_installer}.erb"),
    }
  }



  file { "${name}.menu":
    ensure  => file,
    path    => "${quartermaster::tftpboot}/${distro}/menu/${name}.menu",
    owner   => 'tftp',
    group   => 'tftp',
    mode    => '0644',
    require => File[ "${quartermaster::tftpboot}/${distro}/menu" ],
    content => template("quartermaster/pxemenu/${linux_installer}.erb"),
  }
}
