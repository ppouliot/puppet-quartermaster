# Class: quartermaster::nfs
#
# This Class and configures installs nfs on the quartermaster server
#

class quartermaster::server::nfs (
  $nfsroot = $quartermaster::params::nfsroot,
) inherits quartermaster::params {

  notify {'Exporting Installation Directories via NFS':}
  include nfs::server
  nfs::server::export{ $nfsroot:
    ensure  => 'mounted',
    clients => '*(rw,insecure,all_squash,no_subtree_check,nohide)',
  }

  file { ["${nfsroot}",
         "${nfsroot}\hosts",
         "${nfsroot}\hosts\hiera",
         "${nfsroot}\hosts\pxefiles",
         "${nfsroot}\hardware"]:
    ensure  => 'directory',
    owner   => 'nobody',
    group   => 'nogroup',
    mode    => '0755',
  }
}
