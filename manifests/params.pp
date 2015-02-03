class quartermaster::params {

  # Include Params from other modules so we can use them here
  include tftp::params
  include apache::params
  case $osfamily {
    'Debian':{ include apt }
    default:{ warn("${osfamily} doesn't require the Apt Class") }
  }

  $arp_type = '01'
  $host_macaddress = regsubst($macaddress, '(\:)','-','G')
  $default_pxeboot_option = 'menu.c32'

  $q_home            = '/srv/quartermaster'
  $tmp               = '/tmp'
  $logroot           = '/var/log/quartermaster'
  $tftpboot          = $tftp::params::directory
  $tftp_username     = $tftp::params::username
  $tftp_group        = $tftp::params::username

  $www_username      = $apache::params::user
  $www_group         = $apache::params::group
   
  $wwwroot           = $q_home
  $nfsroot           = $q_home
  $bin               = "${q_home}/bin"
  $pxeroot           = "${tftp::params::directory}/pxelinux"
  $pxecfg            = "${tftp::params::directory}/pxelinux/pxelinux.cfg"
  $pxe_menu          = "${tftp::params::directory}/menu"
  $puppetmaster_fqdn = "${fqdn}"
  $exe_mode          = '0777'
  $file_mode         = '0644'
  $dir_mode          = '0755'
  $counter           = '0'
  $nameserver        = '4.2.2.2'

  # DNSMASQ Configuration
  $dhcp_proxy_subnets = undef

  # Syslinux 
  $syslinux_url = 'http://www.kernel.org/pub/linux/utils/boot/syslinux'
  $syslinux_ver  = '5.01'
  # Broken
  #  $syslinux_ver  = '6.01'
  $syslinux      = "syslinux-${syslinux_ver}"
  $syslinuxroot  = "${tmp}/${syslinux}"


  # Used to process distro's from hiera
  #$linux   = hiera('linux',{})
  #$windows = hiera('windows',{})


  case $osfamily {
    'Debian':{}
    'RedHat':{}
    default:{
      warning("quartermaster: $osfamily is not currently supported")
    }
  }
}
