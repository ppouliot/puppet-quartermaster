# Class: quartermaster::scripts
#
# This Class modifies the apache configuraiton to create
# a pxe-bin dir to host scripts to be retrieved during
# automated installs
#


class quartermaster::scripts {

  include 'apache'

  file {'/var/log/quartermaster':
    ensure => directory,
  }


#  file {'/etc/apache2/sites-available/default':
#    ensure  => file,
#    content => template('quartermaster/apache2.erb'),
#    notify  => Service['apache2'],
#  }


  file {"${quartermaster::wwwroot}/bin":
    ensure  => directory,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::dir_mode,
    require => File[$quartermaster::wwwroot],
  }

  file { "${quartermaster::wwwroot}/bin/index.html":
    ensure  => file,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::file_mode,
    require => File[$quartermaster::wwwroot],
  }

  file { 'concatenate_files.sh':
    ensure  => present,
    path    => "${quartermaster::wwwroot}/bin/concatenate_files.sh",
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => $quartermaster::exe_mode,
    require => File["${quartermaster::wwwroot}/bin"],
    content => '#!/bin/bash
# First argument ($1): directory containing the file fragments
# Second argument ($2): path to the resulting file
rm -rf $2
# Concatenate the fragments
for FRAGMENT in `ls $1`; do
     cat $1/$FRAGMENT >> $2
done
',
  }


  exec { 'create_default_pxe_menu':
    command     => "${quartermaster::wwwroot}/bin/concatenate_files.sh ${quartermaster::tftpboot}/menu ${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/default",
    cwd         => "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/",
    creates     => "${quartermaster::tftpboot}/pxelinux/pxelinux.cfg/default",
    refreshonly => true,
    notify      => Service[ 'tftpd-hpa' ],
    require     => File["${quartermaster::wwwroot}/bin/concatenate_files.sh"],
  }

  file {'firstboot.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/firstboot",
    owner    => 'nobody',
    group    => 'nogroup',
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/firstboot.erb'),
  }

  file {'secondboot.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/secondboot",
    owner    => 'nobody',
    group    => 'nogroup',
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/secondboot.erb'),
  }

  file {'postinstall.sh':
    ensure   => present,
    path     => "${quartermaster::wwwroot}/bin/postinstall",
    owner    => 'nobody',
    group    => 'nogroup',
    mode     => $quartermaster::exe_mode,
    content  => template('quartermaster/scripts/postinstall.erb'),
  }
}
