# Class: quartermaster::commands
#
# build standard command reference 
#

class quartermaster::commands {

  exec {'update_and_upgrade':
    command     => '/usr/bin/apt-get update -y && /usr/bin/apt-get upgrade -y',
    refreshonly => true,
  }
}
