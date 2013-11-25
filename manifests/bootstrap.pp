class quartermaster::bootstrap {

  file { '/etc/puppet/manifests/site.pp':
    ensure => present,
    content => template('quartermaster/site.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec {'default_site_init':
#    command => '/usr/bin/puppet agent --debug --trace --verbose --test --server ${fqdn} --waitforcert=60',
    command => '/usr/bin/puppet apply --debug --trace --verbose --modulepath=/etc/puppet/modules /etc/puppet/manifests/site.pp',
    require => File['/etc/puppet/manifests/site.pp'],
    timeout => 0,
    logoutput => true,
  }

}
