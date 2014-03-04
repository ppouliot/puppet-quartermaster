# This Puppetfile generates a working Quartermaster for generating all necessary images.
#
# Git Settings
git_protocol=ENV['git_protocol'] || 'git'
base_url = "#{git_protocol}://github.com"

# 
branch_name = 'origin/grizzly'
#mod 'puppetlabs/postgresql', :git => "#{base_url}/puppetlabs/puppetlabs-postgresql", :ref => 'master'
#mod 'puppetlabs/puppetdb', :git => "#{base_url}/puppetlabs/puppetlabs-puppetdb", :ref => 'master'
mod 'puppetlabs/firewall', :git => "#{base_url}/puppetlabs/puppetlabs-firewall", :ref => 'master'
mod 'puppetlabs/ntp', :git => "#{base_url}/puppetlabs/puppetlabs-ntp", :ref => 'master'
mod 'puppetlabs/apache', :git => "#{base_url}/puppetlabs/puppetlabs-apache", :ref => 'master'
mod 'puppetlabs/stdlib', :git => "#{base_url}/puppetlabs/puppetlabs-stdlib", :ref => 'master'
mod 'puppetlabs/apt', :git => "#{base_url}/puppetlabs/puppetlabs-apt", :ref => 'master'
mod 'puppetlabs/inifile', :git => "#{base_url}/puppetlabs/puppetlabs-inifile", :ref => 'master'
mod 'puppetlabs/concat', :git => "#{base_url}/puppetlabs/puppetlabs-concat", :ref => 'master'

# stephenrjohnson
# this what I am testing Puppet 3.2 deploys with
# I am pointing it at me until my patch is accepted
mod 'stephenjohrnson/puppet', :git => "#{base_url}/stephenrjohnson/puppetmodule", :ref => 'master'

mod 'openstack-hyper-v/quartermaster', :git => "#{base_url}/openstack-hyper-v/puppet-quartermaster"
