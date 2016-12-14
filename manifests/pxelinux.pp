# Class: quartermaster::pxelinux
#
# This Class defines the creation of the linux pxe infrastructure
#
define quartermaster::pxelinux {
# this regex works w/ no .
#if $name =~ /([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)/ {

  # Define proper name formatting matching distro-release-p_arch
  if $name =~ /([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)-([a-zA-Z0-9_\.]+)/ {
    $distro  = $1
    $release = $2
    $p_arch  = $3
  } else {
    fail('You must put your entry in format "<Distro>-<Release>-<Processor Arch>" like "centos-7-x86_64" or "ubuntu-14.04-amd64"')
  }
  validate_string($distro, '^(debian|centos|fedora|kali|scientificlinux|opensuse|ubuntu)$', 'The currently supported values for distro are debian, centos, fedora, kali, oraclelinux, scientificlinux, opensuse',)
  # convert release into rel_number to check to major and minor releases
  $rel_number = regsubst($release, '(\.)','','G')

  if $release =~/([0-9]+).([0-9])/{
    $rel_major = $1
    $rel_minor = $2
  } else {
    warning("${distro} ${release} does not have major and minor point releases.")
  }

  if ( $distro == 'centos') and ( $release <= '6.7' ) {
    $centos_url = "http://vault.centos.org/${release}"
  } else {
    $centos_url = "http://mirror.centos.org/centos/${rel_major}"
  }
  if ( $distro == 'fedora') {
    case $release {
      '2','3','4','5','6':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/core"
        $fedora_flavor  = ""
      }
      '7','8','9','10','11','12','13','14','15','16','17','18','19':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases"
        $fedora_flavor  = "Fedora/"
      }
      '20','21':{
        $fedora_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases"
        $fedora_flavor  = "Server/"
      }
      '22','23','24','25':{
        $fedora_url = "http://download.fedoraproject.org/pub/fedora/linux/releases"
        $fedora_flavor  = "Server/"
      }
    }
  }
  if ( $distro == 'scientificlinux'){
    case $release {
      '50','51','52','53','54','55','56','57','58','59','510','511':{
        $scientificlinux_url = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}"
      }
      '6.0','6.1','6.2','6.3','6.4','6.5','6.6','6.7','6.8','7.0','7.1','7.2':{
        $scientificlinux_url = "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os"
      }
    }
  }

  if ( $distro == 'opensuse') and ( $release <= '12.2' ){
    $opensuse_url = "http://ftp5.gwdg.de/pub/opensuse/discontinued/distribution"
  } else {
    $opensuse_url = "http://download.opensuse.org/distribution"
  }
 
  if ($distro == /(centos|fedora|oraclelinux)/) and ( $release >= '7.0' ) and ( $p_arch == 'i386'){
    fail("${distro} ${release} does not provide support for processor architecture i386")
  }
  
  # Begin tests for dealing with OracleLinux Repos
  $is_oracle = $distro ? {
    /(oraclelinux)/ => true,
    default         => 'This is not Oracle Linux',
  }

  $rel_name = $release ? {
    /(11.04)/     => 'natty',
    /(11.10)/     => 'oneric',
    /(12.04)/     => 'precise',
    /(12.10)/     => 'quantal',
    /(13.04)/     => 'raring',
    /(13.10)/     => 'saucy',
    /(14.04)/     => 'trusty',
    /(14.10)/     => 'utopic',
    /(15.04)/     => 'vivid',
    /(15.10)/     => 'wily',
    /(16.04)/     => 'xenial',
    /(16.10)/     => 'yakkety',
    /(17.04)/     => 'zesty',
    /(oldstable)/ => 'squeeze',
    /(stable)/    => 'wheezy',
    /(testing)/   => 'jessie',
    /(unstable)/  => 'sid',
    default      => "Unsupported ${distro} Release",
  }

  $url = $distro ? {
    /(ubuntu)/           => "http://archive.ubuntu.com/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
    /(debian)/           => "http://ftp.debian.org/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
#    /(ubuntu|debian)/   => "http://${webhost}.${distro}.${tld}/${distro}/dists/${rel_name}/main/installer-${p_arch}/current/images/netboot/${distro}-installer/${p_arch}",
    /(centos)/           => "${centos_url}/os/${p_arch}/images/pxeboot",
#    /(fedora)/          => "http://dl.fedoraproject.org/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
#    /(fedora)/          => "http://archives.fedoraproject.org/pub/${distro}/linux/releases/${release}/Fedora/${p_arch}/os/images/pxeboot",
    /(fedora)/           => "${fedora_url}/${release}/${fedora_flavor}${p_arch}/os/images/pxeboot",
    /(kali)/             => "http://http.kali.org/kali/dists/kali-rolling/main/installer-${p_arch}/current/images/netboot/debian-installer/${p_arch}",
    /(scientificlinux)/  => "${scientificlinux_url}/images/pxeboot",
    /(oraclelinux)/      => 'Enterprise ISO Required',
    /(redhat)/           => 'Enterprise ISO Required',
    /(sles)/             => 'Enterprise ISO Required',
    /(sled)/             => 'Enterprise ISO Required',
    /(opensuse)/         => "${opensuse_url}/${release}/repo/oss/boot/${p_arch}/loader",
    default              => 'No URL Specified',
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
    /(kali)/            => 'http://http.kali.org/kali/dists/kali-rolling',
    /(centos)/          => "${centos_url}/os/${p_arch}/",
    /(fedora)/          => "${fedora_url}/${release}/${fedora_flavor}/${p_arch}/os",
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
    /(kali)/            => 'http://http.kali.org/kali/dists/kali-rolling',
    /(centos)/          => "${centos_url}/updates/${p_arch}/",
    /(fedora)/          => "${fedora_url}/${release}/${fedora_flavor}/${p_arch}/os",
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
    /(kali)/           => "http://http.kali.org/kali/dists/kali-rolling/main/installer-${p_arch}/current/images/netboot/debian-installer/${p_arch}/boot-screens/splash.png",
    /(redhat)/          => 'Enterprise ISO Required',
    /(centos)/          => "${centos_url}/os/${p_arch}/isolinux/splash.jpg",
    /(fedora)/          => "${fedora_url}/${release}/${fedora_flavor}/${p_arch}/os/isolinux/splash.png",
    /(scientificlinux)/ => "http://ftp.scientificlinux.org/linux/scientific/${release}/${p_arch}/os/isolinux/splash.jpg",
    /(oraclelinux)/     => "http://public-yum.oracle.com/repo/OracleLinux/OL${rel_major}/${rel_minor}/base/${p_arch}/",
    /(sles)/            => 'Enterprise ISO Required',
    /(sled)/            => 'Enterprise ISO Required',
    /(opensuse)/        => "http://download.opensuse.org/distribution/${release}/repo/oss/boot/${p_arch}/loader/back.jpg",
    default             => 'No URL Specified',
  }

  $bootsplash = $distro ? {
    /(ubuntu|debian|kali|fedora|scientificlinux)/        => '.png',
    /(redhat|centos|opensuse|sles|sled)/                 => '.jpg',
    /(windows)/                                          => 'No Bootsplash',
    /(oraclelinux)/                                      => 'No Bootsplash ',
    default                                              => 'No Bootsplash',
  }

  $autofile = $distro ? {
    /(ubuntu|debian|kali)/                               => 'preseed',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'kickstart',
    /(sles|sled|opensuse)/                               => 'autoyast',
    /(windows)/                                          => 'unattend.xml',
    default                                              => 'No Automation File',
#    default                                              => undef,
  }

  $pxekernel = $distro ? {
    /(ubuntu|debian|kali)/                               => 'linux',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'vmlinuz',
    /(sles|sled|opensuse)/                               => 'linux',
    default                                              => 'No supported Pxe Kernel',
  }

  $initrd = $distro ? {
    /(ubuntu|debian|kali)/                               => '.gz',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => '.img',
    /(sles|sled|opensuse)/                               => undef,
    default                                              => 'No supported Initrd Extension',
  }

  $target_initrd = $distro ? {
    /(sles|sled|opensuse)/                               => "${rel_number}.gz",
    /(fedora)/                                           => "${rel_number}${::pxe_flavor}${initrd}",
    default                                              => "${rel_number}${initrd}",
  }
  $target_kernel = $distro ? {
    /(fedora)/                                           => "${rel_number}${::pxe_flavor}",
    default                                              => $rel_number,
  }

  $linux_installer = $distro ? {
    /(ubuntu|debian|kali)/                               => 'd-i',
    /(redhat|centos|fedora|scientificlinux|oraclelinux)/ => 'anaconda',
    /(sles|sled|opensuse)/                               => 'yast',
    default                                              => 'No Supported Linux Installer',
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
  notify { "${name}: Centos Distro = ${::is_centos}":}
  notify { "${name}: Centos URL = ${centos_url}":}
  notify { "${name}: Fedora Distro = ${::is_fedora}":}
  notify { "${name}: Fedora URL = ${fedora_url}":}
  notify { "${name}: Oracle Distro = ${is_oracle}":}
  notify { "${name}: Target Initrd = ${target_initrd}":}

# Retrieve installation kernel file if supported
#  if $pxekernel == !('No supported Pxe Kernel'){
    if ! defined (Staging::File["${target_kernel}-${name}"]){
      staging::file{"${target_kernel}-${name}":
        source  => "${url}/${pxekernel}",
        target  => "/srv/quartermaster/tftpboot/${distro}/${p_arch}/${target_kernel}",
        require =>  Tftp::File["${distro}/${p_arch}"],
      }
    }
#  }

# Retrieve initrd file if supported
#  if $initrd == !('No supported Initrd Extension'){
    if ! defined (Staging::File["${target_initrd}-${name}"]){
      staging::file{"${target_initrd}-${name}":
        source  => "${url}/initrd${initrd}",
        target  => "/srv/quartermaster/tftpboot/${distro}/${p_arch}/${target_initrd}",
        require =>  Tftp::File["${distro}/${p_arch}"],
      }
    }
#  }

# Retrieve Bootsplash file if present
  if $bootsplash == !('No Bootsplash'){
    if ! defined (Staging::File["bootsplash-${name}"]){
      staging::file{"bootsplash-${name}":
        source  => $splashurl,
        target  => "/srv/quartermaster/tftpboot/${distro}/graphics/${name}${bootsplash}",
        require =>  Tftp::File["${distro}/graphics"],
      }
    }
  }


# Distro Specific TFTP Folders

  if ! defined (Tftp::File[$distro]){
    tftp::file { $distro:
      ensure  => directory,
    }
  }


  if ! defined (Tftp::File["${distro}/menu"]){
    tftp::file { "${distro}/menu":
      ensure  => directory,
    }
  }

  if ! defined (Tftp::File["${distro}/graphics"]){
    tftp::file { "${distro}/graphics":
      ensure  => directory,
    }
  }

  if ! defined (Tftp::File["${distro}/${p_arch}"]){
    tftp::file { "${distro}/${p_arch}":
      ensure  => directory,
    }
  }

# Distro Specific TFTP Graphics.conf

if $linux_installer == !('No Supported Linux Installer') {
  tftp::file { "${distro}/menu/${name}.graphics.conf":
    content => template("quartermaster/pxemenu/${linux_installer}.graphics.erb"),
    require => Tftp::File["${distro}/menu"],
  }
}
# Begin Creating Distro Specific HTTP Folders

  if ! defined (File["/srv/quartermaster/${distro}"]) {
    file { "/srv/quartermaster/${distro}":
      ensure  => directory,
      require => File[ '/srv/quartermaster' ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/${autofile}"]) {
    file { "/srv/quartermaster/${distro}/${autofile}":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/${p_arch}"]) {
    file { "/srv/quartermaster/${distro}/${p_arch}":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }

  if ! defined (File["/srv/quartermaster/${distro}/ISO"]) {
    file { "/srv/quartermaster/${distro}/ISO":
      ensure  => directory,
      require => File[ "/srv/quartermaster/${distro}" ],
    }
  }
  if ! defined (File["/srv/quartermaster/${distro}/${p_arch}/.README.html"]) {
    file { "/srv/quartermaster/${distro}/${p_arch}/.README.html":
      ensure  => file,
      require => File[ "/srv/quartermaster/${distro}" ],
      content => template('quartermaster/README.html.erb'),
    }
  }

# Kickstart/Preseed File
  file { "${name}.${autofile}":
    ensure  => file,
    path    => "/srv/quartermaster/${distro}/${autofile}/${name}.${autofile}",
    content => template("quartermaster/autoinst/${autofile}.erb"),
    require => File[ "/srv/quartermaster/${distro}/${autofile}" ],
  }

  if ! defined (Concat::Fragment["${distro}.default_menu_entry"]) {
    concat::fragment { "${distro}.default_menu_entry":
      target  => "/srv/quartermaster/tftpboot/pxelinux/pxelinux.cfg/default",
      content => template('quartermaster/pxemenu/default.erb'),
      order   => 02,
    }
  }

  if ! defined (Concat["/srv/quartermaster/tftpboot/menu/${distro}.menu"]) {
    concat { "/srv/quartermaster/tftpboot/menu/${distro}.menu":
    }
  }
  if ! defined (Concat::Fragment["${distro}.submenu_header"]) {
    concat::fragment {"${distro}.submenu_header":
      target  => "/srv/quartermaster/tftpboot/menu/${distro}.menu",
      content => template('quartermaster/pxemenu/header2.erb'),
      order   => 01,
    }
  }
#  if $linux_installer == !('No Supported Linux Installer') {
  if ! defined (Concat::Fragment["${distro}${name}.menu_item"]) {
    concat::fragment {"${distro}.${name}.menu_item":
      target  => "/srv/quartermaster/tftpboot/menu/${distro}.menu",
      content => template("quartermaster/pxemenu/${linux_installer}.erb"),
    }
  }
#}

#  if $linux_installer == !('No Supported Linux Installer') {
    tftp::file { "${distro}/menu/${name}.menu":
      content => template("quartermaster/pxemenu/${linux_installer}.erb"),
    }
#  }
}
