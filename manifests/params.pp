class quartermaster::params {

  # Include Params from other modules so we can use them here
  include tftp::params
  include apache::params

  $arp_type = '01'
  $host_macaddress = regsubst($macaddress, '(\:)','-','G')
  $default_pxeboot_option = 'menu.c32'

  $q_home            = '/srv/quartermaster'
  $tmp               = '/tmp'
  $logroot           = '/var/log/quartermaster'
  $tftpboot          = $tftp::params::directory
  $wwwroot           = $q_home
  $nfsroot           = $q_home
  $bin               = "${q_home}/bin"
  $pxeroot           = "${tftpboot}/pxelinux"
  $pxecfg            = "${pxeroot}/pxelinux.cfg"
  $pxe_menu          = "${tftpboot}/menu"
  $puppetmaster_fqdn = "${fqdn}"
  $exe_mode          = '0777'
  $file_mode         = '0644'
  $dir_mode          = '0755'
  $counter           = '0'
  $nameserver        = '4.2.2.2'

  # DNSMASQ Configuration
  $dhcp_proxy_subnets = []

  # Syslinux 
  $syslinux_url = 'http://www.kernel.org/pub/linux/utils/boot/syslinux'
  $syslinux_ver  = '5.01'
  # Broken
  #  $syslinux_ver  = '6.01'
  $syslinux      = "syslinux-${syslinux_ver}"
  $syslinuxroot  = "${tmp}/${syslinux}"


  # Used to process distro's from hiera
  $linux = hiera('linux',{})
  $windows = hiera('windows',{})


  case $osfamily {
    'Debian':{}
    'RedHat':{}
    default:{
      warning("quartermaster: $osfamily is not currently supported")
    }
  }
}
