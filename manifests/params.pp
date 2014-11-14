class quartermaster::params {
  $arp_type = '01'
  $host_macaddress = regsubst($macaddress, '(\:)','-','G')
  $default_pxeboot_option = 'menu.c32'


  $tmp               = '/tmp'
  $logroot           = '/var/log/quartermaster'
  $tftpboot          = '/srv/tftpboot'
  $wwwroot           = '/srv/install'
  $nfsroot           = '/srv/nfs'
  $bin               = "${wwwroot}/bin"
  $puppetmaster_fqdn = "${fqdn}"
  $exe_mode          = '0777'
  $file_mode         = '0644'
  $dir_mode          = '0755'
  $counter           = '0'
  $nameserver        = '4.2.2.2'
  $linux = hiera('linux',{})
  $windows = hiera('windows',{})

}
