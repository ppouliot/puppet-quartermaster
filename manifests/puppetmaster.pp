# Class: quartermaster::puppetmaster
#
# This Class installs puppetmaster-passenger
# as the configuration management engine used by the quartermaster server
#


class quartermaster::puppetmaster{

#  file { '/etc/apt/sources.list.d/puppetlabs.list':
#    ensure  => file,
#    content => '# Puppetlabs products
#    deb https://apt.puppetlabs.com precise main
#    deb-src https://apt.puppetlabs.com precise main

    # Puppetlabs devel (uncomment to activate)
    # deb http://apt.puppetlabs.com precise devel
    # deb-src http://apt.puppetlabs.com precise devel
#  }

  package { 'puppetlabs-release':
    ensure => installed,
    notify => Exec['update_and_upgrade'],
  }

# Moving to commands.pp
#
#  exec {'update_and_upgrade':
#    command     => '/usr/bin/apt-get update -y && /usr/bin/apt-get upgrade -y',
#    refreshonly => true,
#  }

  $puppetmaster = [ 'puppetmaster',
                    'augeas-tools',
                    'vim-puppet']

  $puppetdb   = [ 'puppetdb',
                  'puppetdb-terminus']



  $mod_passenger = [ 'puppetmaster-passenger',
                    'libapache2-mod-passenger',
                    'librack-ruby',
                    'libmysql-ruby']

 package { $puppetmaster:
   ensure  => installed,
 #  require => [File ['/etc/apt/sources.list.d/puppetlabs.list'],Package['puppetlabs-release']],
   require => Package['puppetlabs-release'],
 }
 
 package { $mod_passenger:
    ensure  => installed,
#   require => [File ['/etc/apt/sources.list.d/puppetlabs.list'],Package['puppetlabs-release']],
#   require => Package[ $puppetmaster ],
    require => Package['puppetlabs-release', $puppetmaster ],
  }
  package { $puppetdb:
    ensure  => installed,
    require => Package[ $mod_passenger ],
  }


  service {'puppetmaster':
    ensure  => stopped,
    enable  => false,
    require => Package[ 'puppetmaster' ]
  }

  service {'puppetdb':
    ensure  => running,
    enable  => true,
    require => Package['puppetdb'],
  }


  file {'/etc/puppet/puppet.conf':
    ensure  => file,
    source  => 'puppet:///modules/quartermaster/puppetmaster/puppet.conf',
    require => Package['puppetmaster-passenger'],
    notify  => Service['httpd'],
  }
  file {'/etc/puppet/auth.conf':
    ensure  => file,
    source  => 'puppet:///modules/quartermaster/puppetmaster/auth.conf',
    require => Package['puppetmaster-passenger'],
    notify  => Service['httpd'],
 }

 file {'/etc/puppet/puppetdb.conf':
   ensure  => file,
   source  => 'puppet:///modules/quartermaster/puppetmaster/puppetdb.conf',
   require => Package['puppetdb'],
   notify  => Service['puppetdb'],
 }


  file {'/etc/puppet/autosign.conf':
    ensure  => file,
    content => '*.openstack.tld
*.ipmi.openstack.tld
*.demo.openstack.tld',
    require => Package['puppetmaster-passenger'],
    notify  => Service['httpd'],
  }

  file {'/etc/puppet/routes.yaml':
    ensure  => file,
    source  => 'puppet:///modules/quartermaster/puppetmaster/routes.yaml',
    require => Package['puppetdb'],
    notify  => Service['puppetdb','httpd'],
  }

#  file {'/etc/puppet/device.conf':
#    ensure => file,
#    source => '/etc/puppet/ops/device.conf',
#  }

}
