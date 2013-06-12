class quartermaster::wimlib {

  $wimlib_url = 'http://ppa.launchpad.net/ebiggers3/wimlib/ubuntu' 
  

  file { '/etc/apt/sources.list.d/wimlib.list':
    ensure  => file,
    content => "# wimlib-ppa
# Provide wim file manipulation tools
#
deb ${wimlib_url} precise main
deb-src ${wimlib_url} precise main", 
  }
 
  
  package { 'wimtools':
    ensure => installed,
  }


}
