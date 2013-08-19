class quartermaster::bootstrap {

  file { '/etc/puppet/manifests/site.pp':
    ensure => present,
    content => template('quartermaster/site.erb'),
  }

  exec {'default_site_init':
    command => '/usr/bin/puppet apply --debug --trace --verbose /etc/puppet/manifests/site.pp',
    require => File['/etc/puppet/manifests/site.pp'],
    timeout => 0,
  }

}
