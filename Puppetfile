# This Puppetfile generates a working Quartermaster for generating all necessary images.
#
# Git Settings
git_protocol=ENV['git_protocol'] || 'git'
base_url = "#{git_protocol}://github.com"

# 
branch_name = 'origin/grizzly'
#mod '/postgresql', :git => "#{base_url}/puppetlabs/puppetlabs-postgresql", :ref => 'master'
mod 'puppetdb', :git => "#{base_url}/puppetlabs/puppetlabs-puppetdb", :ref => 'master'
mod 'firewall', :git => "#{base_url}/puppetlabs/puppetlabs-firewall", :ref => 'master'
mod 'ntp', :git => "#{base_url}/puppetlabs/puppetlabs-ntp", :ref => 'master'
mod 'apache', :git => "#{base_url}/puppetlabs/puppetlabs-apache", :ref => 'master'
mod 'stdlib', :git => "#{base_url}/puppetlabs/puppetlabs-stdlib", :ref => 'master'
mod 'apt', :git => "#{base_url}/puppetlabs/puppetlabs-apt", :ref => 'master'
mod 'inifile', :git => "#{base_url}/puppetlabs/puppetlabs-inifile", :ref => 'master'
mod 'concat', :git => "#{base_url}/puppetlabs/puppetlabs-concat", :ref => 'master'

# stephenrjohnson
# this what I am testing Puppet 3.2 deploys with
# I am pointing it at me until my patch is accepted
mod 'puppet', :git => "#{base_url}/stephenrjohnson/puppetmodule", :ref => 'master'
mod 'quartermaster', :git => "#{base_url}/openstack-hyper-v/puppet-quartermaster", :ref => 'master'
