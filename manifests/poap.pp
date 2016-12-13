#Class: quartermaster::poap
#
# Creates the infrastructure to support Power On Auto Provisioning
# For Cisco's network devices
#
class quartermaster::poap {
  if $quartermaster::ensure_poap == true {
    notice('installing support for nexus power on provisioning')

    file{[
      "/srv/quartermaster/nexus",
      "/srv/quartermaster/nexus/poap",
      "/srv/quartermaster/nexus/scripts",]:
      ensure => directory,
    }
    tftp::file{'nexus':
      ensure => directory,
    }

    file{"/srv/quartermaster/nexus/scripts/config.py":
      ensure  => file,
      content => template('quartermaster/poap.config.py.erb'),
    }

    vcsrepo{"/srv/quartermaster/nexus/scripts/PyMonitor":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/PyMonitor',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/link-state-monitor":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/link-state-monitor',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/nexus5000":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/nexus5000',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/nexus9000":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/nexus9000',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/ABM-Beam":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/ABM-Beam',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/hadoop-integration":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/hadoop-integration',
    }
    vcsrepo{"/srv/quartermaster/nexus/scripts/who-moved-my-cli":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/datacenter/who-moved-my-cli',
    }

  } else {

    warning('this is used if ensure_poap = true')

  }
}
