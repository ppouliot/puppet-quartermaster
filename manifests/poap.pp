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

    file{["${wwwroot}/nexus",
          "${wwwroot}/nexus/poap",]:
      ensure => directory,
    }
    tftp::file{'nexus':
      ensure => directory,
    }

  } else {

   warn("this is used if ensure_poap = true")

  }
}
