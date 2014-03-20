# Class: quartermaster::nfs
#
# This Class and configures installs nfs on the quartermaster server
#


class quartermaster::nfs {
  $nfs = ['nfs-kernel-server',
        'nfs-client',
        'tree',]

  package { $nfs:
    ensure => installed,
  }

  service { 'nfs-kernel-server':
    ensure   => running,
    require  => Package [ $nfs ],
  }

  file { '/etc/exports':
    ensure  => file,
    content => template('quartermaster/exports.erb'),
    notify  => Service['nfs-kernel-server'],
    require => [ Package[ $nfs ], File [$quartermaster::wwwroot]],
  }


  notify {'Exporting Installation Directories via NFS':}

  file { 'nfsroot':
    ensure  => 'directory',
    path    => $quartermaster::nfsroot,
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
    require => [ Package[ $nfs ], File[ $quartermaster::wwwroot ]],
  }

  file {"${quartermaster::nfsroot}/hosts":
    ensure  => 'directory',
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
    require => [ Package[ $nfs ], File[ $quartermaster::nfsroot ]],
  }
  file {"${quartermaster::nfsroot}/hardware":
    ensure  => 'directory',
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
    require => [ Package[ $nfs ], File[ $quartermaster::nfsroot ]],
  }
  file {"${quartermaster::nfsroot}/hosts/pxefiles":
    ensure  => 'directory',
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
    require => [ Package[ $nfs ], File[ $quartermaster::nfsroot ]],
  }
  file {"${quartermaster::nfsroot}/hosts/hiera":
    ensure  => 'directory',
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
    require => [ Package[ $nfs ], File[ $quartermaster::nfsroot ]],
  }
}
