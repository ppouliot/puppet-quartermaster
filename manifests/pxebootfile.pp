# == Define: quartermaster::pxebootfile
# The file created for control of individual
# host pxe menus.
# found ususially in tftpboot/pxelinux/pxelinux.cfg/
#
#
define quartermaster::pxebootfile (
  $arp_type               = $quartermaster::params::arp_type,
  $host_macaddress        = $quartermaster::params::host_macaddress,
  $default_pxeboot_option = $quartermaster::params::default_pxe_option
  $pxe_menu_timeout       = $quartermaster::params::pxe_menu_timeout
  
) {


  #$host_macaddress = regsubst($macaddress, '(\:)','(\-)','G')
  #$host_macaddress = regsubst($macaddress, '(\:)','-','G')

  $bootfile = ${arp_type}-${host_macaddress}"

  case $osfamily {
    'Debian':{

    }
    'RedHat':{}
    'windows':{}
    default:{}
  }





  ## creates files tftpboot/pxelinux/pxelinux.cfg/
  @@concat { "${tftpboot}/pxelinux/pxelinux.cfg/${bootfile}":
    mode    => $tftp_filemode,
  }
    
  ## Set a Default target for concat 
  @@Concat:Fragment{
    target  => "${tftpboot}/pxelinux/pxelinux.cfg/boot",
  }

  ## Bootfile Header 
  @@concat::fragment{"$bootfile.header":
    content => template("quartermaster/pxemenu/header.erb"),
    order   => 01,
  }

  ## Localboot - Boot from the local disk
  @@concat::fragment{"$bootfile.localboot":
    content => template("quartermaster/pxemenu/localboot.erb"),
    order   => 02,
  }
  ## Puppet Fact Detected Menu Option
#  @@concat::fragment{"$bootfile.operatingsystem":
#    content => template("quartermaster/pxemenu/localboot.erb"),
#    order   => 02,
#  }

}
