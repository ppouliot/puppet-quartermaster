#Class: quartermaster::server::tftpd
#
# Installs and configures tftpd-hpa for use by pxe
# Also handles naming rules for winpe pxeboot environment
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# }
#

class quartermaster::server::tftpd () inherits quartermaster::params {



  notify {'Creating tftp.rules file to support booting WinPE':}
  file { 'tftpd_rules':
    path     => '/etc/tftpd.rules',
    content  => template('quartermaster/winpe/tftp-remap.erb'),
  }

  class{ 'tftp':
     inetd     => false,
     directory => $quartermaster::params::tftpboot,
     options   => '-vvvvs -c -m /etc/tftpd.rules',
     require   => [ File[ 'tftpd_rules' ], ],
  }
  
  tftp::file {["menu",
               "pxelinux",
               "pxelinux/pxelinux.cfg"]:
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
  }

}
