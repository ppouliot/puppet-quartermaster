#Class: quartermaster::tftpd
#
# Installs and configures tftpd-hpa for use by pxe
# Also handles naming rules for winpe pxeboot environment
#
# Parameters:
# //** enable_netmgmt **// 
#  creates a cisco Power On Auto Provisioning Ifrastructure.
#
# Actions:
#
# Requires: see Modulefile
#
# }
#

class quartermaster::tftpd () inherits quartermaster::params {



# Create the tftp remap file
  file { 'tftpd_rules':
    path     => '/etc/tftpd.rules',
    content  => template('quartermaster/tftp-remap.erb'),
  }

# Tftp Server Configuration
  class{ 'tftp':
     inetd     => false,
     directory => $quartermaster::params::tftpboot,
     options   => '-vvvvs -c -m /etc/tftpd.rules',
     require   => [ File[ 'tftpd_rules' ], ],
  }
  
# additional tftp directories
  tftp::file {["menu",
               "network_devices",
               "pxelinux",
               "pxelinux/pxelinux.cfg"]:
    ensure  => directory,
  }
}
