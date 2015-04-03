#Class: quartermaster::poap
#
# Creates the infrastructure to support Power On Auto Provisioning
# For Cisco's network devices
#
class quartermaster::poap (

  $ensure_poap = $quartermaster::params::enable_poap,
  $wwwroot = $quartermaster::params::wwwroot,

) inherits quartermaster::params {
  if $ensure_poap == 'true' {
    notice('installing support for nexus power on provisioning')

    file{["${wwwroot}/nexus",
          "${wwwroot}/nexus/poap",
          "${wwwroot}/nexus/scripts",]:
      ensure => directory,
    }
    tftp::file{'nexus':
      ensure => directory,
    }

    file{"${wwwroot}/nexus/scripts/config.py":
      ensure => file,
      content => template("quartermaster/poap.config.py.erb"),
    }

   vcsrepo{"${wwwroot}/nexus/scripts/PyMonitor":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/PyMonitor',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/link-state-monitor":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/link-state-monitor',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/nexus5000":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/nexus5000',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/nexus9000":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/nexus9000',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/ABM-Beam":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/ABM-Beam',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/hadoop-integration":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/hadoop-integration',
   }
   vcsrepo{"${wwwroot}/nexus/scripts/who-moved-my-cli":
     ensure   => present,
     provider => git,
     source   => 'https://github.com/datacenter/who-moved-my-cli',
   }

  } else {

   warning("this is used if ensure_poap = true")

  }
}
