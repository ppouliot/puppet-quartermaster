# Class: quartermaster::tftpd
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

class quartermaster::tftpd {

  $tftp_pkgs = [ 'tftp-hpa', 'tftpd-hpa' ]
  package { $tftp_pkgs:
    ensure   => installed,
  }

  service { 'tftpd-hpa':
    ensure   => running,
    require  => Package [ 'tftpd-hpa' ],
  }

  file { 'tftpd_config':
    path    => '/etc/default/tftpd-hpa',
    notify  => Service[ 'tftpd-hpa' ],
    require => Package[ 'tftpd-hpa' ],
    content => "#/etc/default/tftpd-hpa
TFTP_USERNAME=\"tftp\"
TFTP_DIRECTORY=\"${quartermaster::tftpboot}\"
TFTP_ADDRESS=\"0.0.0.0:69\"
TFTP_OPTIONS=\"-vvvvs -c -m /etc/default/tftpd.rules\"
#TFTP_OPTIONS=\"-vc -m /etc/default/tftpd.rules\"
",
  }

  notify {'Creating tftp.rules file to support booting WinPE':}
  file { 'tftpd_rules':
    path     => '/etc/default/tftpd.rules',
    #content => "rg \\ / # Convert backslashes to slashes",
    content  => template('quartermaster/winpe/tftp-remap.erb'),
    notify   => Service[ 'tftpd-hpa' ],
    require  => Package[ 'tftpd-hpa' ],
  }

  file { $quartermaster::tftpboot:
    ensure  => directory,
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }
  file { "${quartermaster::tftpboot}/menu":
    ensure  => directory,
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }
  file { "${quartermaster::tftpboot}/pxelinux":
    ensure  => directory,
    owner   => 'tftp',
    group   => 'tftp',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }
  file { "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => [ Package[ 'tftpd-hpa' ],File[ tftpd_config ]],
  }

}
