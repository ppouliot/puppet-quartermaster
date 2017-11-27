# == Define: quartermaster::matchbox
# Adds CoreOS Matchbox as part of the CoreOS deployment infrastructure
#
class quartermaster::matchbox (){

  validate_bool( $quartermaster::matchbox_enable )
  validate_string( $quartermaster::matchbox_version )

  if $quartermaster::matchbox_enable == true {
    file{'/srv/quartermaster/matchbox':
      ensure => directory,
    }  -> 
    staging::deploy{"matchbox-v${quartermaster::matchbox_version}-linux-amd64.tar.gz":
      source => "https://github.com/coreos/matchbox/releases/download/v${quartermaster::matchbox_version}/matchbox-v${quartermaster::matchbox_version}-linux-amd64.tar.gz",
      target => '/srv/quartermaster/matchbox',
    }

  }

}
