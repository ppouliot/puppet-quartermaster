class quartermaster::bootstrap {

  file { '/etc/puppet/manifests/site.pp':
    ensure => present,
    content => template('quartermaster/site.erb'),
  }

  exec {'default_site_init':
#    command => '/usr/bin/puppet agent --debug --trace --verbose --test --server ${fqdn} --waitforcert=60',
    command => '/usr/bin/puppet apply --debug --trace --verbose --test --modulepath=/etc/puppet/modules',
    require => File['/etc/puppet/manifests/site.pp'],
    timeout => 0,
    logoutput => true,
  }

}
