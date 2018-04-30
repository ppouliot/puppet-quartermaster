forge "http://forge.puppetlabs.com"

# Misc Modules
mod 'ajjahn/samba', :latest
mod "derdanne/nfs", :latest

# Changes to allow for proxydhcp
mod "lex/dnsmasq",
  :git    => 'https://github.com/ppouliot/puppet-dnsmasq',
  :branch => 'master'

# Voxpupuli Modules
mod "puppet/autofs", '4.3.0'
mod 'puppet/nginx', :latest
mod "puppet/squid", :latest
mod 'puppet/staging', :latest

# Puppetlabs Modules
mod 'puppetlabs/apt', :latest
mod 'puppetlabs/concat', :latest
mod 'puppetlabs/dummy_service', :latest
mod 'puppetlabs/stdlib', :latest
mod 'puppetlabs/vcsrepo', :latest
mod 'puppetlabs/xinetd', :latest

# Master branch accounts for systemd/upstart change in ubuntu
mod "puppetlabs/tftp", # :latest
  :git    => 'https://github.com/puppetlabs/puppetlabs-tftp',
  :branch => 'master'

mod "puppet/quartermaster", 
  :git    => 'https://github.com/ppouliot/puppet-quartermaster',
  :branch => 'master'
