# This Puppetfile generates a working Quartermaster for generating all necessary images.
#
# Git Settings
git_protocol=ENV['git_protocol'] || 'git'
base_url = "#{git_protocol}://github.com"

# 
branch_name = 'origin/grizzly'
#mod '/postgresql', :git => "#{base_url}/puppetlabs/puppetlabs-postgresql', :ref => 'master'
mod 'puppetdb', :git => "#{base_url}/puppetlabs/puppetlabs-puppetdb', :ref => 'master'
mod 'firewall', :git => "#{base_url}/puppetlabs/puppetlabs-firewall', :ref => 'master'
mod 'ntp', :git => "#{base_url}/puppetlabs/puppetlabs-ntp', :ref => 'master'
mod 'apache', :git => "#{base_url}/puppetlabs/puppetlabs-apache', :ref => 'master'
mod 'stdlib', :git => "#{base_url}/puppetlabs/puppetlabs-stdlib', :ref => 'master'
mod 'apt', :git => "#{base_url}/puppetlabs/puppetlabs-apt', :ref => 'master'
mod 'inifile', :git => "#{base_url}/puppetlabs/puppetlabs-inifile', :ref => 'master'
mod 'concat', :git => "#{base_url}/puppetlabs/puppetlabs-concat', :ref => 'master'

# stephenrjohnson
# this what I am testing Puppet 3.2 deploys with
# I am pointing it at me until my patch is accepted
mod 'puppet', :git => "#{base_url}/stephenrjohnson/puppetmodule', :ref => 'master'
mod 'quartermaster', :git => "#{base_url}/openstack-hyper-v/puppet-quartermaster', :ref => 'master'


mod 'puppetlabs/stdlib', :ref =>">= 4.3.2"
mod 'puppetlabs/concat', :ref =>">= 1.0.4"
mod 'puppetlabs/apache', :ref =>">= 1.1.1"
mod 'puppetlabs/apt', :ref =>">= 1.6.0"
mod 'puppetlabs/tftp', :ref =>">= 0.2.2"
mod 'puppetlabs/postgresql', :ref =>">= 3.4.2"
mod 'puppetlabs/puppetdb', :ref =>">= 3.4.2"
mod 'stephenrjohnson/puppet', :ref =>">= 1.3.1"
mod 'thais/samba', :ref =>">= 0.1.5"
mod 'pdxcat/autofs', :ref =>">= 1.0.2"
mod 'nanliu/staging', :ref =>">= 1.0.0"

